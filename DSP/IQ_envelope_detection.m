%% 설계 결과 2


%% 조건 생성
f_mod = 5e3;
fm = 100e3;
fs_mod = 1e6;
t_mod = 0 : 1/fs_mod : 0.4e-3;
L_mod = length(t_mod);


%% 신호 생성
a_t = 1 + cos(2*pi*f_mod*t_mod);
a_q = a_t .* cos(2*pi*fm*t_mod);

% Block Diagram에서 -90도 위상 이동: cos(x - 90도) = sin(x)
a_i = a_t .* sin(2*pi*fm*t_mod);

% Envelope 계산 (복소수 크기)
envelope = sqrt(a_i.^2 + a_q.^2);


%% FFT 수행
A_t = fftshift(fft(a_t, N));
A_q = fftshift(fft(a_q, N));
A_i = fftshift(fft(a_i, N));
Env = fftshift(fft(envelope, N));
f_analog_mod = (-N/2 : N/2-1) * (fs_mod/N);

figure('Name', '2) I/Q Modulation & Envelope', 'Position', [300 300 1200 800]);


%% 시간 영역 (Time Domain), 세개 플롯 생성
subplot(3,2,1); plot(t_mod, a_t, 'k', 'LineWidth', 1.5);
title('Time: a(t)'); xlabel('Time (s)'); ylabel('Amplitude'); grid on;

subplot(3,2,3); hold on; plot(t_mod, a_q, 'b'); plot(t_mod, envelope, 'r--', 'LineWidth', 1.5);
title('Time: a_q(t) & Envelope'); xlabel('Time (s)'); ylabel('Amplitude'); legend('a_q(t)','Envelope'); grid on; hold off;

subplot(3,2,5); hold on; plot(t_mod, a_i, 'g'); plot(t_mod, envelope, 'r--', 'LineWidth', 1.5);
title('Time: a_i(t) & Envelope'); xlabel('Time (s)'); ylabel('Amplitude'); legend('a_i(t)','Envelope'); grid on; hold off;


%% 주파수 영역 (Frequency Domain), 세개 플롯 생성
subplot(3,2,2); plot(f_analog_mod, abs(A_t)/L_mod, 'k', 'LineWidth', 1.5);
title('Freq: a(t)'); xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on;

subplot(3,2,4); plot(f_analog_mod, abs(A_q)/L_mod, 'b', 'LineWidth', 1.5);
title('Freq: a_q(t)'); xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on;

subplot(3,2,6); hold on; 
plot(f_analog_mod, abs(A_i)/L_mod, 'g', 'LineWidth', 1.5); 
plot(f_analog_mod, abs(Env)/L_mod, 'r--', 'LineWidth', 1.2);
title('Freq: a_i(t) & Envelope'); xlabel('Frequency (Hz)'); ylabel('Magnitude'); legend('A_i(f)','Envelope(f)'); grid on; hold off;
