clear; clc; close all;
% DSP ultrasound project: corrected Q1-Q8
% Requires Signal Processing Toolbox.
% Keep this script, generateUSimage.m, and both RF MAT files together.
% The supplied my_filter.mat is intentionally NOT loaded.

%% Load data and set axes
scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir), scriptDir = pwd; end
S = load(fullfile(scriptDir, 'usRFdata.mat'), 'usRFdata');
T = load(fullfile(scriptDir, 'usRFdata_noisy.mat'), 'usRFdata_noisy');
usRFdata = double(S.usRFdata);
usRFdata_noisy = double(T.usRFdata_noisy);
assert(isequal(size(usRFdata), size(usRFdata_noisy)), ...
    'Original and noisy data must have identical sizes.');
assert(all(isfinite(usRFdata(:))) && all(isfinite(usRFdata_noisy(:))), ...
    'Data contain NaN or Inf.');

fs = 16.6667e6;                 % Sampling frequency [Hz]
c = 1540;                      % Assumed sound speed [m/s]
sensorIndex = 10;
[numDataSamples, numSensors] = size(usRFdata);
N = numDataSamples;
assert(numSensors >= sensorIndex, 'Channel 10 is unavailable.');

% Q1: rows = depth/time samples, columns = sensors (assignment convention).
t_axis = (0:N-1).' / fs * 1e6;               % [us]
x_image_axis = linspace(-20, 20, numSensors); % Given lateral range [mm]
z_image_axis = (0:N-1).' / fs * c * 1000 / 2; % Round-trip time to depth [mm]
% Exact FFT bins, valid for both odd and even N.
f_axis = (-floor(N/2):ceil(N/2)-1).' * fs / N / 1e6;
f_positive = (0:floor(N/2)).' * fs / N;

fprintf('Q1: %d samples x %d channels\n', N, numSensors);
fprintf('Sample interval: %.6f us; final time: %.6f us\n', ...
    1e6/fs, t_axis(end));
fprintf('FFT bin spacing: %.6f kHz\n', fs/N/1e3);

%% Q2: original time-domain signal
x10 = usRFdata(:, sensorIndex);
figure(1);
plot(t_axis, x10); grid on;
xlabel('Time [us]'); ylabel('RF amplitude');
title('Original RF signal - channel 10');
xlim([t_axis(1), t_axis(end)]);

%% Q3: original two-sided FFT magnitude, peak normalized to 0 dB
X = fft(x10, N);
Xshift = fftshift(X);
originalSpectrumRef = max(abs(Xshift));
assert(originalSpectrumRef > 0, 'Original channel is all zeros.');
originalDB = 20*log10(max(abs(Xshift)/originalSpectrumRef, eps));
figure(2);
plot(f_axis, originalDB); grid on;
xlim([-fs/2, fs/2]/1e6); ylim([-50, 0]);
xlabel('Frequency [MHz]'); ylabel('Normalized magnitude [dB]');
title('Original RF spectrum - channel 10');

%% Q4: dominant positive-frequency FFT bin (excluding DC)
Xpositive = abs(X(1:floor(N/2)+1));
[~, peakIndex] = max(Xpositive(2:end));
peakIndex = peakIndex + 1;
f_main = f_positive(peakIndex);
fprintf('Q4: Original dominant FFT bin = %.6f MHz\n', f_main/1e6);
% This peak is not a calibrated transducer center-frequency specification.

%% Q5: envelope detection and log compression
dynamicRange = 60; % Display range [dB]
[usImage, imageReference] = generateUSimage(usRFdata, [], dynamicRange);
figure(3);
imagesc(x_image_axis, z_image_axis, usImage, [-dynamicRange, 0]);
axis image; colormap(gray(256)); colorbar;
xlabel('X [mm]'); ylabel('Z [mm]');
title('Original ultrasound image');

%% Q6: noisy time signal, spectrum, dominant bin, and image
noisy10 = usRFdata_noisy(:, sensorIndex);
Y = fft(noisy10, N);
Ypositive = abs(Y(1:floor(N/2)+1));
[~, noisyPeakIndex] = max(Ypositive(2:end));
noisyPeakIndex = noisyPeakIndex + 1;
fprintf('Q6: Noisy dominant FFT bin = %.6f MHz\n', ...
    f_positive(noisyPeakIndex)/1e6);

% Reference data are available here, so their difference identifies added noise.
% This difference is used for diagnosis/evaluation, not subtracted to denoise.
addedNoise = usRFdata_noisy - usRFdata;
noise10 = addedNoise(:, sensorIndex);
NoiseFFT = fft(noise10, N);
noisePositive = abs(NoiseFFT(1:floor(N/2)+1));
[~, noisePeakIndex] = max(noisePositive(2:end));
noisePeakIndex = noisePeakIndex + 1;
fprintf('Q6: Added-noise peak bin = %.6f MHz (approximately 1 MHz)\n', ...
    f_positive(noisePeakIndex)/1e6);

figure(4);
subplot(3,1,1);
plot(t_axis, noisy10); grid on;
xlabel('Time [us]'); ylabel('RF amplitude');
title('Noisy RF signal - channel 10');
subplot(3,1,2);
noisyDB = 20*log10(max(abs(fftshift(Y))/max(abs(Y)), eps));
plot(f_axis, noisyDB); grid on;
xlim([-fs/2, fs/2]/1e6); ylim([-50, 0]);
xlabel('Frequency [MHz]'); ylabel('Magnitude [dB]');
title('Noisy spectrum: normalized to its own peak');
subplot(3,1,3);
noiseDB = 20*log10(max(abs(fftshift(NoiseFFT))/max(abs(NoiseFFT)), eps));
plot(f_axis, noiseDB); grid on;
xlim([-fs/2, fs/2]/1e6); ylim([-60, 0]);
xlabel('Frequency [MHz]'); ylabel('Magnitude [dB]');
title('Added-noise spectrum: noisy minus original');

usImage_noisy = generateUSimage(usRFdata_noisy, imageReference, dynamicRange);
figure(5);
imagesc(x_image_axis, z_image_axis, usImage_noisy, [-dynamicRange, 0]);
axis image; colormap(gray(256)); colorbar;
xlabel('X [mm]'); ylabel('Z [mm]');
title('Noisy image - original image reference');

%% Q7: compare two independently designed FIR filters
% Baseline: the 50th-order 3-6 MHz bandpass described in the old report.
bandpassOrder = 50;
b_bandpass = fir1(bandpassOrder, [3e6, 6e6]/(fs/2), ...
    'bandpass', hamming(bandpassOrder+1), 'scale');

% Selected design: suppress approximately 1 MHz while retaining other bands.
% These are fir1 cutoff edges (approximately -6 dB), not guaranteed stopband edges.
filterOrder = 100;
cutoffHz = [0.7e6, 1.3e6];
my_filter = fir1(filterOrder, cutoffHz/(fs/2), ...
    'stop', hamming(filterOrder+1), 'scale');

% Force column coefficients: filter only along depth, never across sensors.
b_bandpass = b_bandpass(:);
my_filter = my_filter(:);
usRFdata_bandpass = zeros(size(usRFdata_noisy));
usRFdata_noise_removed = zeros(size(usRFdata_noisy));
for k = 1:numSensors
    usRFdata_bandpass(:,k) = conv(usRFdata_noisy(:,k), b_bandpass, 'same');
    usRFdata_noise_removed(:,k) = conv(usRFdata_noisy(:,k), my_filter, 'same');
end
% For these symmetric odd-length FIRs, central cropping aligns the output.
% Zero extension is still assumed outside the record; edge effects remain.
% This is offline processing, not a causal real-time implementation.

[Hbp, fH] = freqz(b_bandpass, 1, 8192, fs);
[Hbs, ~] = freqz(my_filter, 1, 8192, fs);
figure(6);
plot(fH/1e6, 20*log10(max(abs(Hbp), eps)), 'LineWidth', 1.2);
hold on;
plot(fH/1e6, 20*log10(max(abs(Hbs), eps)), 'LineWidth', 1.2);
grid on; xlim([0, fs/2/1e6]); ylim([-90, 5]);
xlabel('Frequency [MHz]'); ylabel('Filter gain [dB]');
legend('50th-order bandpass', '100th-order bandstop', 'Location', 'best');
title('FIR magnitude responses');

% Evaluate the selected FIR at exactly 1 MHz, using its coefficients.
H1MHz = sum(my_filter .* exp(-1j*2*pi*1e6/fs*(0:filterOrder).'));
fprintf('Q7: Selected FIR order = %d; taps = %d\n', ...
    filterOrder, numel(my_filter));
fprintf('Selected FIR gain at 1 MHz = %.2f dB\n', 20*log10(abs(H1MHz)));
fprintf('Causal FIR group delay = %d samples = %.6f us\n', ...
    filterOrder/2, filterOrder/2/fs*1e6);

%% Q8: image and spectrum comparisons using common references
usImage_bandpass = generateUSimage(usRFdata_bandpass, imageReference, dynamicRange);
usImage_noise_removed = generateUSimage(usRFdata_noise_removed, imageReference, dynamicRange);
imageList = {usImage, usImage_noisy, usImage_bandpass, usImage_noise_removed};
imageTitles = {'Original', 'Noisy', '50th-order bandpass', '100th-order bandstop'};
figure(7);
for k = 1:4
    subplot(2,2,k);
    imagesc(x_image_axis, z_image_axis, imageList{k}, [-dynamicRange, 0]);
    axis image; colorbar;
    xlabel('X [mm]'); ylabel('Z [mm]'); title(imageTitles{k});
end
colormap(gray(256));

signals10 = [x10, noisy10, usRFdata_bandpass(:,sensorIndex), ...
    usRFdata_noise_removed(:,sensorIndex)];
comparisonFFT = fftshift(fft(signals10, N, 1), 1);
comparisonDB = 20*log10(max(abs(comparisonFFT)/originalSpectrumRef, eps));
figure(8);
plot(f_axis, comparisonDB); grid on;
xlim([0, fs/2/1e6]); ylim([-60, 10]);
xlabel('Frequency [MHz]'); ylabel('Magnitude [dB re original peak]');
legend(imageTitles, 'Location', 'best');
title('Spectral comparison with a common reference');

% Reference-based SNR includes residual noise AND filtering distortion.
% Evaluate ALL samples/channels, including both boundary regions.
signalEnergy = sum(usRFdata(:).^2);
dataList = {usRFdata_noisy, usRFdata_bandpass, usRFdata_noise_removed};
methodNames = {'Noisy'; 'Bandpass50'; 'Bandstop100'};
snrValues = zeros(3,1); rmseValues = zeros(3,1);
for k = 1:3
    errorData = dataList{k} - usRFdata;
    errorEnergy = sum(errorData(:).^2);
    snrValues(k) = 10*log10(signalEnergy/max(errorEnergy, realmin));
    rmseValues(k) = sqrt(mean(errorData(:).^2));
end
results = table(methodNames, snrValues, rmseValues, ...
    'VariableNames', {'Method', 'ReferenceSNR_dB', 'RMSE'});
disp(results);

%% Save reproducible results and all figures
outputDir = fullfile(scriptDir, 'dsp_results');
if ~exist(outputDir, 'dir'), mkdir(outputDir); end
save(fullfile(outputDir, 'processed_results.mat'), ...
    'fs', 'filterOrder', 'cutoffHz', 'my_filter', 'b_bandpass', ...
    'usRFdata_bandpass', 'usRFdata_noise_removed', 'results', 'imageReference');
for k = 1:8
    print(figure(k), fullfile(outputDir, sprintf('Figure_%02d.png', k)), ...
        '-dpng', '-r180');
end
fprintf('Results saved to: %s\n', outputDir);
