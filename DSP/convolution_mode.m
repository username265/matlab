%% 1.2 MATLAB library의 Convolution 조사 및 예시 구현

% 예시 신호
a = [1, 1, 1, 1, 1];         % 길이 5인 Pulse
b = [1, 2, 3];               % 길이 3인 Ramp

% 내장된 conv 사용
y_full = conv(a, b, 'full'); 
y_same = conv(a, b, 'same');

% 결과 확인
disp('입력 a:'); disp(a);
disp('입력 b:'); disp(b);
disp('Full Convolution 결과:'); disp(y_full);
disp('Same Convolution 결과:'); disp(y_same);

% 표 생성
figure;
subplot(2,1,1);
stem(y_full, 'filled', 'LineWidth', 1.5);
title('MATLAB Library: conv(a, b, ''full'')');
xlabel('n'); ylabel('Amplitude'); grid on;

subplot(2,1,2);
stem(y_same, 'filled', 'Color', 'r', 'LineWidth', 1.5);
title('MATLAB Library: conv(a, b, ''same'')');
xlabel('n'); ylabel('Amplitude'); grid on;
