clc, clear all, close all

syms x1 x2 lbd


f(x1,x2) = -x1*x2;
g(x1,x2) = x1 + x2 - 2; % constraint

%% Lagrangian Multipliers method
L = f(x1,x2) - lbd*g(x1,x2);
eqs = [diff(L,x1)
       diff(L,x2)
       diff(L,lbd)]
   
sol = solve(eqs)