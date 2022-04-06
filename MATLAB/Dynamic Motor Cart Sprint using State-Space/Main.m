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

s = tf('s');

num = -k*r*Kt;
denom = (s^2 + k)*s*((s*J+b)*(s*L+R) + Kt*Ke);

% G = num/denom

num2 = k*Kt*(s*J+b);
denom2 = (s^2 *m2+k)*((s*J+b)*(s*L+R) + Ke*Kt)*(r*(m1+m2)*s^2);

theta = Kt/s /((s*J + b)*(s*L+R) + Ke*Kt);
% step(theta)

x1 = r*theta;
x2 = k*x1/(s^2 *m2 + k);
step(x2)
% step(G)

c  = 0.15
g = 9.8
G_x2e = (k*r*Kt - c*m2*g)/(s*((s*J+b)*(s*L+R)+Ke*Kt)*(m2*s^2 + k));

step(G_x2e)

%% Las try

theta = Kt/s/((s*J+b)*(s*L+R) + Ke*Kt);
I = s*(s*J+b)/Kt *theta;
X1 = r*theta;
X2 = (k*X1)/(m2*s^2 + k);