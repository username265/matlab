%% 완전 초기화 상태
clc; clear; close all;

%% 기본 변수를 설정
tp = 0.01; % 0.01초마다 한번씩 샘플링
A = 5; % 진폭 5
theta = pi/2; % 위상(신호위치) cos(pi/2)=0
N = 1024; % FFT 계산할 점 많이 둬서 부드럽게 함

%% 시간 길이를 설정
T = 4; % 신호 관측 시간 (크면 주파수 정확하고 작으면 퍼진다)
t_vec = 0:tp:T; % 시간 벡터 생성 (0~1초까지 0.01간격)

%% 신호를 생성
f1 = 1;
f2 = 4;
x_t = A*cos(2*pi*f1*t_vec) + A*cos(2*pi*f2*t_vec); % 실제 신호 생성

%% FFT
x_f = fftshift(abs(fft(x_t, N))); % 주파수 변환, 크기 사용, 가운데 이동
x_f = db(x_f ./ max(x_f(:))); % db변환

%% 주파수 축 변환
f_vec = linspace(-1/(2*tp), 1/(2*tp), N); % 주파수 범위 생성(-50~50hz)
w_vec = 2*pi * f_vec; % hz -> rad 변환

%% 그래프 출력
figure, % 새그래프창 생성

subplot(2,1,1); % 2행 1열 중 첫번째 그래프
plot(t_vec, x_t, 'linewidth', 2.0); % 시간 vs 신호 그래프
xlabel('Time (s)'); % x축 이름 설정
title('x(t)'); % 그래프 제목

subplot(2,1,2); % 두번째 그래프
plot(w_vec, x_f, 'linewidth', 2.0); % 스펙트럼
ylim([-30 0]); xlim([-60 60]) % y축 범위(dB), x축 범위 제한
xlabel('Angular Frequency (rad/s)'); % 단위 (rad/s)
title('X(\omega)'); %CTFT 형태로 표기함
