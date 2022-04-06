clc, clear all, close all

%% Base of the system
Sb = 60e6;
Vb = 132e3;
Ib = Sb/(sqrt(3)*Vb);
Zb = Vb^2 /Sb;
%% System known parameters

E = 1*(cos(0) + 1i*sin(0)); % E = 1.0 with angle = 0 rads

%% Calculations

a = exp(1i*2*pi/3);
T = [1 1 1
     1 a^2 a
     1 a a^2];
 
 Zg1 = 0.1;
 Zg2 = 0.07;
 
 Zt1 = 0.1;
 Zt2 = 0.1;
 Zt0 = 0.1;
 
 Zl1 = 0.7*40/Zb;
 Zl2 = 0.7*40/Zb;
 Zl0 = 2.5*Zl1;
 
E = 1;

Z1 = Zg1 + Zt1 + Zl1/2;
Z2 = Zg2 + Zt2 + Zl2/2;
Z0 = Zt0 + Zl0/2;

I1 = E/(Z1+Z2+Z0);
I2 = I1;
I0 = I1;

If = I1+I2+I0;

Iabc = T*[I0;I1;I2];