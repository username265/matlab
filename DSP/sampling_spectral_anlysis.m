%% 설계 결과 1 (Hw3)


%% 조건 생성
clear; clc; 
f1 = 5e3;       % 주파수: 5kHz
f2 = 10e3;      % 주파수: 10kHz
fs1 = 400e3;    % 주파수: 400kHz
t1 = 0 : 1/fs1 : 0.4e-3; % 시간 범위: 0 부터 0.4ms 까지
L1 = length(t1);


%% 신호 생성
xc1 = 1 + sin(2*pi*f1*t1);
xc2 = 2 * cos(2*pi*f2*t1).^2;
N = 2048; % 2048 point DFT

% FFT 및 Shift
X1 = fftshift(fft(xc1, N));
X2 = fftshift(fft(xc2, N));

% 주파수 축 생성 (아날로그주파수, 정규화 디지털주파수, 디지털 각주파수)
f_analog = (-N/2 : N/2-1) * (fs1/N);        % Analog Frequency 
f_norm = f_analog / fs1;                    % Normalized Digital Frequency
f_omega = f_norm * 2 * pi;                  % Digital Angular Frequency 


%% 1) 두 입력 신호 Plot (Time & Frequency) 
figure('Name', '1-1) Time & Frequency Analysis of xc1 and xc2', 'Position', [100 100 1200 800]);

% 시간 영역 그래프
subplot(4,2,1);
plot(t1, xc1, 'b', 'LineWidth', 1.5);
title('Time Domain: x_{c1}(t)'); xlabel('Time (s)'); ylabel('Amplitude'); grid on;

subplot(4,2,2);
plot(t1, xc2, 'r', 'LineWidth', 1.5);
title('Time Domain: x_{c2}(t)'); xlabel('Time (s)'); ylabel('Amplitude'); grid on;

% 주파수 영역(아날로그) 그래프 (Analog Frequency)
subplot(4,2,3);
plot(f_analog, abs(X1)/L1, 'b', 'LineWidth', 1.5);
title('Freq Domain (Analog): x_{c1}'); xlabel('Frequency (Hz)'); ylabel('|X(\Omega)|'); grid on;

subplot(4,2,4);
plot(f_analog, abs(X2)/L1, 'r', 'LineWidth', 1.5);
title('Freq Domain (Analog): x_{c2}'); xlabel('Frequency (Hz)'); ylabel('|X(\Omega)|'); grid on;

% 주파수 영역(정규화된 디지털) 그래프 (Normalized Digital Frequency)
subplot(4,2,5);
plot(f_norm, abs(X1)/L1, 'b', 'LineWidth', 1.5);
title('Freq Domain (Norm): x_{c1}'); xlabel('Normalized Freq (cycles/sample)'); ylabel('|X(\omega)|'); grid on;

subplot(4,2,6);
plot(f_norm, abs(X2)/L1, 'r', 'LineWidth', 1.5);
title('Freq Domain (Norm): x_{c2}'); xlabel('Normalized Freq (cycles/sample)'); ylabel('|X(\omega)|'); grid on;

% F주파수 영역(디지털 각주파수) 그래프 (Digital Angular Frequency)
subplot(4,2,7);
plot(f_omega, abs(X1)/L1, 'b', 'LineWidth', 1.5);
title('Freq Domain (Angular): x_{c1}'); xlabel('Angular Freq (rad/sample)'); ylabel('|X(\omega)|'); grid on;

subplot(4,2,8);
plot(f_omega, abs(X2)/L1, 'r', 'LineWidth', 1.5);
title('Freq Domain (Angular): x_{c2}'); xlabel('Angular Freq (rad/sample)'); ylabel('|X(\omega)|'); grid on;


%% 2) 두 입력 신호 곱한 결과 Plot (Time & Frequency)
x_mul = xc1 .* xc2;
X_mul = fftshift(fft(x_mul, N));

figure('Name', '1-2) Multiplication of xc1 and xc2', 'Position', [150 150 1000 400]);
subplot(1,2,1);
plot(t1, x_mul, 'k', 'LineWidth', 1.5);
title('Time Domain: x_{c1}(t) \times x_{c2}(t)'); xlabel('Time (s)'); ylabel('Amplitude'); grid on;

subplot(1,2,2);
plot(f_norm, abs(X_mul)/L1, 'k', 'LineWidth', 1.5); % b) 방식 사용
title('Freq Domain: Multiplication (Normalized Freq)'); xlabel('Normalized Freq'); ylabel('Magnitude'); grid on;


%% 3) 두 입력 신호 convolution 결과 Plot (Time & Frequency)
x_conv = conv(xc1, xc2);
t_conv = (0:length(x_conv)-1) * (1/fs1); % 컨볼루션 된 시간 축
X_conv = fftshift(fft(x_conv, N));

figure('Name', '1-3) Convolution of xc1 and xc2', 'Position', [200 200 1000 400]);
subplot(1,2,1);
plot(t_conv, x_conv, 'm', 'LineWidth', 1.5);
title('Time Domain: x_{c1}(t) * x_{c2}(t)'); xlabel('Time (s)'); ylabel('Amplitude'); grid on;

subplot(1,2,2);
plot(f_norm, abs(X_conv)/L1, 'm', 'LineWidth', 1.5); % b) 방식 사용
title('Freq Domain: Convolution (Normalized Freq)'); xlabel('Normalized Freq'); ylabel('Magnitude'); grid on;


%% 4) Sampling Frequency 변경한 Plot (fs = 15 kHz)
fs2 = 15e3; 
t2 = 0 : 1/fs2 : 0.4e-3;
L2 = length(t2);

xc1_15k = 1 + sin(2*pi*f1*t2);
xc2_15k = 2 * cos(2*pi*f2*t2).^2;

X1_15k = fftshift(fft(xc1_15k, N));
X2_15k = fftshift(fft(xc2_15k, N));
f_norm_15k = (-N/2 : N/2-1) / N; % 정규화 fs = 15kHz

figure('Name', '1-4) fs = 15kHz Analysis', 'Position', [250 250 1200 600]);
subplot(2,2,1); plot(t2, xc1_15k, '-o'); title('Time: x_{c1} (fs=15kHz)'); xlabel('Time (s)'); ylabel('Amplitude'); grid on;
subplot(2,2,2); plot(t2, xc2_15k, '-o'); title('Time: x_{c2} (fs=15kHz)'); xlabel('Time (s)'); ylabel('Amplitude'); grid on;
subplot(2,2,3); plot(f_norm_15k, abs(X1_15k)/L2); title('Freq: x_{c1} (fs=15kHz)'); xlabel('Norm Freq'); ylabel('Magnitude'); grid on;
subplot(2,2,4); plot(f_norm_15k, abs(X2_15k)/L2); title('Freq: x_{c2} (fs=15kHz)'); xlabel('Norm Freq'); ylabel('Magnitude'); grid on;
