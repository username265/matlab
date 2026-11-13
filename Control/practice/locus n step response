% 1. tf 함수 사용
% G(S)= (2s^2 + 4s + 1) / (5s^3 + 4s^2 + 3s + 2)
G1 = tf([2, 4, 1], [5, 4, 3, 2]);

% 2. zpk 함수 사용
% G(s) = (s+2)(s+3)/((s+1)(s+5)(s-6))
G2 = zpk([-2, -3], [-1, -5, 6], 1)

% 3. s변수 사용
% s = tf('s');
G3 = ((s+2)*(s+3))/((s+1)*(s+5)*(s-6)) 
G4 = 1/(5*s^3+4*s^2+3*s+2)

clc;
clearvars;

% Locus & Step response
K2 = 10;
G = zpk([], [0,-10], K2);

K1 = 1;

Gcl = feedback(K1*G, 1)
[y1, t1] = step(Gcl, [0, 5]);

K1 = 2.5;
Gcl2 = feedback(K1*G, 1)
[y2, t2] = step(Gcl2, [0, 5]);

plot(t1, y1, t2, y2)

rlocus(G);
