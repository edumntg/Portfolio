clc, clear all, close all

m1 = 1;
m2 = 0.2;
R = 10;
L = 0.5;
Kt = 50;
Ke = 10;
J = 10;
r = 0.1;
b = 2;
k = 1000;

g = 9.8;

s = tf('s');

figure(1)
subplot(4,1,1);
theta = (Kt/((s*J+b)*(s*L+R) + Kt*Ke))*(1/s);
step(theta)
title('Theta Vs Ea');

I = s*theta*(s*J+b)/Kt;
subplot(4,1,2);
step(I)
title('Current Vs Ea');

X1 = r*theta;
% X1 = (Kt*I/r)/(m1*s^2);
subplot(4,1,3);
step(X1)
title('X1 Vs Ea');

X2 = k*X1/(m2*s^2 + k);
subplot(4,1,4);
step(X2);
title('X2 Vs Ea');

% G = (k*Kt/r/m1) * (1/s^2) * (s*J+b)/((s*J+b)*(s*L+R) + Kt*Ke) *1/(m2*s^2 + k);
% step(G)