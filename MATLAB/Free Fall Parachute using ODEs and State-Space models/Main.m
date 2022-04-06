 clc, clear all, close all

Mp = 10
Mj = 60
Bp = 100
Bj = 10
Kr = 400

g = 9.807

V0p = 20
V0j = 20

X0p = 0
X0j = 0

%% Space State for part a 

A =[-Bp/Mp 0 -Kr/Mp Kr/Mp;
    0 -Bj/Mj Kr/Mj -Kr/Mj;
    1 0 0 0;
    0 1 0 0];

B = [Mp;Mj;0;0];

C = [1 1 0 0];

D = 0;

u = g;

X0 = [20; 20; 0; 0];