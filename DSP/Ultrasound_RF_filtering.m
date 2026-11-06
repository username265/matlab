clear; clc; close all;
%% DSP Project: Design of Ultrasound Signal Processing Systems
% The main goal of this project is to understand and process ultrasound signals to display properly
% You are given two-dimensional signals as a 2-D array, which contains ultrasound RF signals
% Rows and columns of the array represent "depth" and "sensors". 
% In other words, rows and columns represent z-axis and x-axis, respectively.
% Your final images should be given as the same format.


%% Load ultrasound RF signals
load([cd '/usRFdata.mat']);


%% Basic conditions
fs = 16.6667e6;     % sampling freuqnecy [MHz]


%% QUESTION NUMBER 1
% Find the number of sensors and the number of data samples from the data loaded (read your workspace!)
% Data variable name: usRFdata
% usRFdata is two-dimensional data (row: data samples, column: the number of sensors)
% Imagine you have X number of sensors and you get Y number of samples with those sensors over time

numDataSamples = size(usRFdata, 1);
numSensors = size(usRFdata, 2);

x_image_axis = linspace(-20,20,numSensors);         % mm unit
z_image_axis = (0:numDataSamples-1)/fs*1540000/2;   % mm unit


%% QUESTION NUMBER 2
% Plot your data samples only with a 10th sensor in the array.
% Basically, plot one column (10th column) of the data with proper axis.
% X-axis of the plot should have a time unit like us (microsecond)
% For your X-axis, know that the time starts at 0 seconds

t_axis = (0:numDataSamples-1) / fs * 1e6; %시간축을 샘플링 주파수로 나눈다. 단위는 us, (1e6 곱함)
usRFdata10 = usRFdata(:, 10); % 10번째 열 데이터 선택한다.
figure, plot(t_axis, usRFdata10);

xlabel('Time [us]'); ylabel('Amplitude')
title('Ultrasound RF signal at the 10th sensor');


%% QUESTION NUMBER 3
% Plot the frequency response (magnitude response) with your data samples at 10th sensor above.
% X-axis of the plot should have a frequency unit like MHz.
% Frequency spectrum should be plotted in a decibel unit
% Use fftshift to have a DC component in the middle of the plot.
% Magnitude should range from -50 dB to 0 dB (for y-axis of the plot)

fft_num = numDataSamples; % n-point dft에서 데이터 샘플 수와 동일하게 설정한다.
f_axis = linspace(-fs/2, fs/2, fft_num) / 1e6; % Mhz 단위의 주파수 축을 생성한다.

usRFdata10_fft = fft(usRFdata10, fft_num); %fft 수행
usRFdata10_fft_shifted = fftshift(usRFdata10_fft); % 중앙 정렬

mag_response = abs(usRFdata10_fft_shifted); % 크기 계산
mag_response_norm = mag_response / max(mag_response); % 최댓값을 1로 정규화

usRFdata10_freq = 20 * log10(mag_response_norm + eps); %dB 단위를 변환한다.

figure, plot(f_axis, usRFdata10_freq);
axis([-fs/2/1e6, fs/2/1e6, -50 0]);
xlabel('Frequency [MHz]'); ylabel('Magnitude [dB]')
title('Frequency spectrum of ultrasound RF signal at the 10th sensor');


%% QUESTION NUMBER 4 (Discussion problem)
% What do you observe from the 3 and 4?
% What is the "main" frequency of your ultrasound signal?
% 0Hz를 기준으로 양쪽에 대칭으로 솟아오른 가장 큰 피크(Peak)가 있을 것입니다. 
% 그 피크가 위치한 주파수(MHz)가 바로 이 초음파 신호의 중심 주파수(Main frequency)입니다. 
% 일반적으로 의료용 초음파는 수 MHz 대역(예: 2~10MHz)을 가집니다.
% Main frequency estimation

usRFdata10_zeroMean = usRFdata10 - mean(usRFdata10);
US10_single = abs(fft(usRFdata10_zeroMean, fft_num));
f_axis_single = (0:fft_num/2)*(fs/fft_num);     % Hz
US10_pos = US10_single(1:fft_num/2+1);

% Ignore DC component
[~, idx_main] = max(US10_pos(2:end));
idx_main = idx_main + 1;
f_main = f_axis_single(idx_main);   % Hz
fprintf('Q4. Main frequency of original RF signal = %.3f MHz\n', f_main/1e6);


%% QUESTION NUMBER 5
% Display your ultrasound images
% Run the generateUSimage function first to make image from RF data

usImage = generateUSimage(usRFdata);
figure, 

imagesc(x_image_axis, z_image_axis, usImage, [-60 5]); 
axis image; colormap('gray'); colorbar;
xlabel('X axis [mm]'); ylabel('Z axis [mm]')
title('Original ultrasound image');


%% QUESTION NUMBER 6
% Now your same ultrasound data is corrupted with unknown noise sources.
% Repeat the QUESTION NUMBER 2, 3, 4, 5 for the new data and discuss/show your results

load([cd '/usRFdata_noisy.mat']);
usImage_noisy = generateUSimage(usRFdata_noisy);
figure, 

imagesc(x_image_axis,z_image_axis,usImage_noisy, [-60 5]); 
axis image; colormap('gray'); colorbar;
xlabel('X axis [mm]'); ylabel('Z axis [mm]')
title('Noisy ultrasound image');


%% QUESITION NUMBER 7: Design your filter to remove the noise
% You should have noticed that your US data is now corrupted with noise.
% Based on your time/frequency observation on the noisy data.
% Design your filter that removes this noise source to recover the original image
% My filter example (FIR type)
% You can use any filter but designed by you (IIR or FIR)
% You have to design your filter! my_filter is just for the example to show

f_low = 3e6;  % 하한 주파수 3MHz
f_high = 6e6; % 상한 주파수 6MHz

Wn = [f_low, f_high] / (fs/2); % Nyquist 주파수로 정규화 (fs/2 = 1)
filter_order = 50; % FIR 필터차수 설정

my_filter = fir1(filter_order, Wn, 'bandpass'); % fir1 함수 사용, Bandpass 필터 계수 설정
load([cd '/my_filter.mat']);
usRFdata_noise_removed = zeros(size(usRFdata_noisy));
for i=1:numSensors
    usRFdata_noise_removed(:,i) = convn(usRFdata_noisy(:,i), my_filter, 'same');
end

usImage_noise_removed = generateUSimage(usRFdata_noise_removed);
figure, 
imagesc(x_image_axis, z_image_axis, usImage_noise_removed, [-60 5]); 
axis image; colormap('gray'); colorbar;
xlabel('X axis [mm]'); ylabel('Z axis [mm]')
title('Noise-removed ultrasound image');


%% QUESTION NUMBER 8 (Discussion problem)
% Discuss what is your criteria to design your filter.
% 원본 신호의 주파수 성분은 그대로 보존(유지)하고 노이즈가 존재하는 주파수 대역만 선택적으로 삭제(감쇄)시키는 것이 내 필터 설계의 기준이다. 

% Why do you choose that filter? What parameters did you have to consider?
% 위상 왜곡을 방지하기 위해서 선형 위상 특성을 가진 FIR Bandpass(High는 6, Low는 3) 필터를 선택했고 차수(50)와 cutoff를 고려하였다.

% How do you filter your data with MATLAB?
% fir1 함수로 필터 계수를 생성하고 convn('…, same')를 통해 컨볼루션 연산을 수행했다.

% What is the transient reponse of the filtred results?
% 디지털 필터는 이전 입력 데이터를 저장하는 메모리를 가진다. 
% 이때 신호가 입력되는 시작점과 끝점에는 필터의 윈도우가 데이터랑 안겹치고 0이랑 연산하게 되는데 
% 이것 때문에 신호의 양 끝단이 완만하게 상승하거나 왜곡되는 과도응답이 나타나게 된다.

% How do you avoid "transient reponse"?
% 과도 응답을 방지하기 위해서 데이터 양 끝에 zero padding을 적용한 뒤 필터링하고 잘라내거나 filtfilt 함수를 사용한다. 
% 이 함수를 사용하면 순방향과 역방향으로 두번 필터링해서 위상 지연을 제거해서 과도 응답 구간을 효율적으로 제거할 수 있다고 한다.

% What do you observe the difference between the original and the noise images?
% 기존 노이즈 영상에는 가로줄무늬가 생겨서 내부 구조를 보기 힘들었지만 설계된 필터를 잡음 데이터와 컨볼루션연산한 후 영상을 다시 생성한 결과 
% 최종 이미지(Figure5)에서는 가로줄무늬가 제거돼서 기존 이미지처럼 깨끗하게 복원됐음을 확인할 수 있다.
