% DSP_HW2_Main, 모두 초기화하고 시작
clear; clc; close all;

%% 1. 신호 생성, Sampling Rate: 1MHz
fs = 1e6;           % 샘플링 주파수
ts = 1/fs;          % 주기: 1us

% x1(t), (0 ~ 1000us)
t1 = 0 : ts : 1000e-6; 
x1 = zeros(1, length(t1));

% x1(t)에 조건 대입
x1(t1 >= 201e-6 & t1 <= 300e-6) = 1;
idx_tri1 = (t1 >= 701e-6 & t1 <= 750e-6);
x1(idx_tri1) = 2e4 * (t1(idx_tri1) - 750e-6) + 1;
idx_tri2 = (t1 >= 751e-6 & t1 <= 800e-6);
x1(idx_tri2) = -2e4 * (t1(idx_tri2) - 750e-6) + 1;

% x2(t), (0 ~ 300us 구간)
t2 = 0 : ts : 300e-6;
x2 = zeros(1, length(t2));

% x2(t)에 조건 대입
x2(t2 >= 100e-6 & t2 <= 150e-6) = 1;
x2(t2 > 150e-6 & t2 <= 200e-6) = -1; 

%% 2. Test Input Plot
figure('Position', [100, 500, 800, 300]);
subplot(1,2,1); %왼쪽 위치
plot(t1*1e6, x1, 'LineWidth', 1.5);
title('Input Signal x_1(t)'); xlabel('Time (\mus)'); ylabel('Amplitude'); %가로축 시간 세로축 진폭
grid on; axis tight; ylim([-0.5 1.5]);

subplot(1,2,2);
plot(t2*1e6, x2, 'LineWidth', 1.5, 'Color', 'r');
title('Input Signal x_2(t)'); xlabel('Time (\mus)'); ylabel('Amplitude'); %가로축 시간 세로축 진폭
grid on; axis tight; ylim([-1.5 1.5]);

%% Convolution 실행, 비교
% 직접 만든 함수(full, same)_custom
y_full_custom = dsp32221004_conv_full(x1, x2);
y_same_custom = dsp32221004_conv_same(x1, x2);

% MATLAB 내장(library) 함수
y_full_lib = conv(x1, x2, 'full');
y_same_lib = conv(x1, x2, 'same');

% 시간 축 생성
t_full = 0 : ts : (length(y_full_custom)-1)*ts;
t_same = t1; 

%% 결과 출력, 비교
figure('Position', [100, 100, 800, 600]);

% Full Convolution 비교
subplot(2,2,1); % 좌상단 위치
plot(t_full*1e6, y_full_custom, 'b', 'LineWidth', 2);
title('Custom: conv\_full'); xlabel('Time (\mus)'); ylabel('Amplitude'); %가로축 시간 세로축 진폭
grid on; axis tight;

subplot(2,2,2);
plot(t_full*1e6, y_full_lib, 'r--', 'LineWidth', 2);
title('Library: conv(x1, x2, ''full'')'); xlabel('Time (\mus)'); ylabel('Amplitude'); 
grid on; axis tight;

% Same Convolution 비교
subplot(2,2,3);
plot(t_same*1e6, y_same_custom, 'b', 'LineWidth', 2);
title('Custom: conv\_same'); xlabel('Time (\mus)'); ylabel('Amplitude'); 
grid on; axis tight;

subplot(2,2,4);
plot(t_same*1e6, y_same_lib, 'r--', 'LineWidth', 2);
title('Library: conv(x1, x2, ''same'')'); xlabel('Time (\mus)'); ylabel('Amplitude'); 
grid on; axis tight;

% 오차율 계산
error_full = sum(abs(y_full_custom - y_full_lib));
error_same = sum(abs(y_same_custom - y_same_lib));
fprintf('Full Convolution 에러 합: %e\n', error_full);
fprintf('Same Convolution 에러 합: %e\n', error_same);
