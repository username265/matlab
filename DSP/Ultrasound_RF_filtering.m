%% HW4 | Ultrasound RF Analysis and FIR Filtering
% 초음파 RF 신호를 분석하고 50차 FIR 대역통과 필터로 잡음을 저감합니다.
% Requirements: MATLAB + Signal Processing Toolbox (fir1, freqz, hilbert)
% Keep generateUSimage.m, usRFdata.mat, and usRFdata_noisy.mat in this folder.
clear; clc; close all;

%% Data and basic conditions
% 현재 작업 폴더가 아니라 이 스크립트의 위치를 기준으로 불러옵니다.
projectDir = fileparts(mfilename('fullpath'));
addpath(projectDir);
originalData = load(fullfile(projectDir, 'usRFdata.mat'), 'usRFdata');
noisyData = load(fullfile(projectDir, 'usRFdata_noisy.mat'), 'usRFdata_noisy');
usRFdata = originalData.usRFdata;
usRFdata_noisy = noisyData.usRFdata_noisy;

validateattributes(usRFdata, {'double'}, ...
    {'2d', 'real', 'finite', 'nonempty'}, mfilename, 'usRFdata');
validateattributes(usRFdata_noisy, {'double'}, ...
    {'2d', 'real', 'finite', 'nonempty'}, mfilename, 'usRFdata_noisy');
assert(isequal(size(usRFdata), size(usRFdata_noisy)), ...
    'Original and noisy data must have the same size.');

fs = 16.6667e6;                    % Sampling frequency [Hz]
soundSpeed = 1540000;              % Sound speed [mm/s]
sensorIndex = 10;

%% Q1. Data dimensions and physical axes
[numDataSamples, numSensors] = size(usRFdata);
assert(numSensors >= sensorIndex && numDataSamples >= 2, ...
    'At least 10 sensor columns and 2 samples are required.');
fprintf('Q1. Samples per sensor: %d, sensors: %d\n', ...
    numDataSamples, numSensors);

t_axis = (0:numDataSamples-1).' / fs * 1e6;       % [us]
x_image_axis = linspace(-20, 20, numSensors);     % [mm]
z_image_axis = (0:numDataSamples-1).' / fs * soundSpeed / 2;

% fftshift 결과에 대응하는 실제 DFT 빈: 간격은 fs / N입니다.
fft_num = numDataSamples;
f_axis = (-floor(fft_num/2):ceil(fft_num/2)-1).' * fs / fft_num / 1e6;
f_axis_single = (0:floor(fft_num/2)).' * fs / fft_num;  % [Hz]

usRFdata10 = usRFdata(:, sensorIndex);
usRFdata10_noisy = usRFdata_noisy(:, sensorIndex);

%% Q2-Q4. Original RF waveform, spectrum, and dominant frequency
originalMagnitude = abs(fftshift(fft(usRFdata10, fft_num)));
spectrumReference = max(max(originalMagnitude), eps);
originalSpectrumDB = 20 * log10(max(originalMagnitude / spectrumReference, eps));

figure('Name', 'Original RF Analysis');
subplot(2, 1, 1);
plot(t_axis, usRFdata10); grid on;
xlabel('Time [us]'); ylabel('Amplitude');
title('Original RF signal: sensor 10');
subplot(2, 1, 2);
plot(f_axis, originalSpectrumDB); grid on;
xlim([-fs/2, fs/2] / 1e6); ylim([-50, 0]);
xlabel('Frequency [MHz]'); ylabel('Magnitude [dB]');
title('Original RF spectrum');

originalFFT = abs(fft(usRFdata10 - mean(usRFdata10), fft_num));
positiveMagnitude = originalFFT(1:floor(fft_num/2)+1);
[~, peakIndex] = max(positiveMagnitude(2:end));   % Exclude DC
f_main = f_axis_single(peakIndex + 1);
fprintf('Q4. Original dominant non-DC frequency: %.3f MHz\n', f_main / 1e6);

%% Q5. Original ultrasound image
% 원본 포락선 최댓값을 모든 영상의 공통 정규화 기준으로 사용합니다.
[usImage, imageReference] = generateUSimage(usRFdata);
figure('Name', 'Original Ultrasound Image');
imagesc(x_image_axis, z_image_axis, usImage, [-60, 5]);
axis image; colormap('gray'); colorbar;
xlabel('X axis [mm]'); ylabel('Z axis [mm]');
title('Original ultrasound image');

%% Q6. Noisy RF waveform, spectrum, dominant frequency, and image
noisyMagnitude = abs(fftshift(fft(usRFdata10_noisy, fft_num)));
noisySpectrumDB = 20 * log10(max(noisyMagnitude / spectrumReference, eps));
noisyFFT = abs(fft(usRFdata10_noisy - mean(usRFdata10_noisy), fft_num));
positiveMagnitude = noisyFFT(1:floor(fft_num/2)+1);
[~, peakIndex] = max(positiveMagnitude(2:end));
f_main_noisy = f_axis_single(peakIndex + 1);
fprintf('Q6. Noisy dominant non-DC frequency: %.3f MHz\n', f_main_noisy / 1e6);
% 잡음 데이터의 최대 피크는 초음파 신호가 아니라 잡음일 수 있습니다.

figure('Name', 'Noisy RF Analysis');
subplot(2, 1, 1);
plot(t_axis, usRFdata10_noisy); grid on;
xlabel('Time [us]'); ylabel('Amplitude');
title('Noisy RF signal: sensor 10');
subplot(2, 1, 2);
plot(f_axis, originalSpectrumDB, f_axis, noisySpectrumDB); grid on;
xlim([-fs/2, fs/2] / 1e6);
ylim([-60, max(5, max(noisySpectrumDB) + 5)]);
xlabel('Frequency [MHz]'); ylabel('Magnitude [dB, original peak reference]');
legend('Original', 'Noisy'); title('Original and noisy RF spectra');

usImage_noisy = generateUSimage(usRFdata_noisy, imageReference);
figure('Name', 'Noisy Ultrasound Image');
imagesc(x_image_axis, z_image_axis, usImage_noisy, [-60, 5]);
axis image; colormap('gray'); colorbar;
xlabel('X axis [mm]'); ylabel('Z axis [mm]');
title('Noisy ultrasound image');

%% Q7. Design and apply the FIR bandpass filter
f_low = 3e6;                       % Lower cutoff [Hz]
f_high = 6e6;                      % Upper cutoff [Hz]
filter_order = 50;                 % Order 50 => 51 coefficients
assert(0 < f_low && f_low < f_high && f_high < fs/2, ...
    'Cutoff frequencies must satisfy 0 < f_low < f_high < fs/2.');
Wn = [f_low, f_high] / (fs/2);
my_filter = fir1(filter_order, Wn, 'bandpass');
my_filter = my_filter(:);
% 필터를 열벡터로 통일하고 1차원 conv를 사용합니다.
% 기존 my_filter.mat을 load하면 위에서 설계한 계수가 덮어써지므로 불러오지 않습니다.

[H, filterFrequency] = freqz(my_filter, 1, 4096, fs);
figure('Name', 'Designed FIR Response');
plot(filterFrequency / 1e6, 20 * log10(max(abs(H), eps))); grid on;
xlabel('Frequency [MHz]'); ylabel('Magnitude [dB]'); ylim([-100, 5]);
title('Order-50 FIR bandpass filter: 3-6 MHz');

usRFdata_noise_removed = zeros(size(usRFdata_noisy));
for sensor = 1:numSensors
    usRFdata_noise_removed(:, sensor) = ...
        conv(usRFdata_noisy(:, sensor), my_filter, 'same');
end

usImage_noise_removed = generateUSimage(usRFdata_noise_removed, imageReference);
figure('Name', 'Ultrasound Image Comparison');
imageSets = {usImage, usImage_noisy, usImage_noise_removed};
imageTitles = {'Original', 'Noisy', 'FIR filtered'};
for k = 1:3
    subplot(1, 3, k);
    imagesc(x_image_axis, z_image_axis, imageSets{k}, [-60, 5]);
    axis image; colorbar;
    xlabel('X axis [mm]'); ylabel('Z axis [mm]'); title(imageTitles{k});
end
colormap('gray');

filteredMagnitude = abs(fftshift(fft(usRFdata_noise_removed(:, sensorIndex), fft_num)));
filteredSpectrumDB = 20 * log10(max(filteredMagnitude / spectrumReference, eps));
figure('Name', 'RF Spectrum Comparison');
plot(f_axis, originalSpectrumDB, f_axis, noisySpectrumDB, ...
    f_axis, filteredSpectrumDB); grid on;
xlim([-fs/2, fs/2] / 1e6);
ylim([-60, max(5, max(noisySpectrumDB) + 5)]);
xlabel('Frequency [MHz]'); ylabel('Magnitude [dB, original peak reference]');
legend('Original', 'Noisy', 'FIR filtered'); title('RF spectra: sensor 10');

%% Q8. Interpretation and limitations
% 1) 설계 목적: 3-6 MHz 주변의 유효 성분을 유지하고 대역 밖 성분을 감쇠합니다.
%    fir1의 경계는 이상적인 통과/차단 경계가 아닙니다. 천이대역이 존재하며,
%    경계 부근의 유효 신호도 감쇠할 수 있습니다.
% 2) 대칭 51탭 FIR의 인과적 구현은 25샘플의 군지연을 갖습니다.
%    여기서는 conv(..., 'same')의 중앙 추출로 이 지연을 정렬합니다.
%    이는 오프라인 처리이며, 실시간 구현의 지연이 사라진다는 뜻은 아닙니다.
% 3) 양 끝 25샘플은 경계 밖을 0으로 가정하는 영향을 받습니다.
%    단순 zero padding 후 잘라내는 것만으로 이 영향이 제거되지는 않습니다.
%    경계 확장 방식 또는 유효 평가 구간을 별도로 고려해야 합니다.
% 4) filtfilt는 전후방 처리로 위상 지연을 제거하지만 크기 응답도 바뀌며,
%    경계 과도응답이 항상 사라지는 것은 아닙니다. 이 코드에서는 사용하지 않습니다.
% 5) 영상은 원본 기준으로 정규화합니다. 필터링이 원본의 완전한 복원을 보장하지는 않습니다.

