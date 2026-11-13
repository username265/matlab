x = -2*pi : 0.1 : 2*pi;     % x벡터 생성
y1 = sin(x);                %sin(x)값을 y1에 저장
plot (x, y1, 'r--');        % 그래프를 빨간 점섬으로 그림
grid on                     % 그래프에 격자 생성
title('sine and cosine')    % 그래프 제목 설정
xlabel('time');             % x축 이름 설정
ylabel('y1 and y2');        % y축 이름 설정
hold on                     % 현재 그래프에 다른 그래프 겹쳐 그리기 허용
y2 = cos(x);                % cos(x)값을 y2에 저장
plot(x, y2, 'b', 'LineWidth', 2); % 그래프를 파란색으로 그리되 두께 2로 설정
legend('sin(x)', 'cos(x)'); % 현재 그려진 그래프들의 이름 화면에 띄움
axis([0 pi 0 1]);           % 그래프를 x축은 0~pi, y축은 0~1까지만 그림
