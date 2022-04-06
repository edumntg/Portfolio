clc, clear all, close all

%% Ask user for length of time, initial position and initial velocity

tf = 24;
vx0 = 0;
vy0 = 0.008688;
x0 = 1.15;
y0 = 0;

%% IF YOU WANT TO RECEIVE THE PARAMETERS AS INPUTS, UNCOMMENT THE FOLLOWING 5 LINES
% tf = input("Please enter the length of the simulation: ");
% vx0 = input("Please enter the x-component of the initial velocity: ");
% vy0 = input("Please enter the y-component of the initial velocity: ");
% x0 = input("Please enter the x-component of the initial position: ");
% y0 = input("Please enter the y-component of the initial position: ");

%% Constant Parameters
E = 0.012277; % Earth's Location
M = 1-E; % Moon's Location

%% Start Simulation

% Define the vectors of initial values
% The simulation will contain 4 variables:
    % X position
    % Y position
    % x-velocity X'
    % y-velocity Y'

%% Using Euler's 
% Define step size
h = 1e-5;

% Initial time
t0 = 0;

% Number of points
N = (tf-t0)/h;

% Euler's Method

% Define initial values
Z1(1) = x0; % x-pos
Z2(1) = vx0; % x-velocity
Z3(1) = y0; % y-pos
Z4(1) = vy0; % y-velocity
t(1) = t0;
for i = 2:N
    t(i) = t(i-1) + h;
    f_old = f(t(i-1), [Z1(i-1), Z2(i-1), Z3(i-1), Z4(i-1)], E, M);

    Z1(i) = Z1(i-1) + h*f_old(1);
    Z2(i) = Z2(i-1) + h*f_old(2);
    Z3(i) = Z3(i-1) + h*f_old(3);
    Z4(i) = Z4(i-1) + h*f_old(4);
end

%% NOTE
%   Z1 is the X-position
%   Z2 is the X-velocity
%   Z3 is the Y-position
%   Z4 is the Y-velocity

%%

figure
plot(Z1, Z3)
hold on

% Plot earth and moon
plot(-E, 0, 'ko', 'linewidth', 2)
text(-E+0.05,0,'\leftarrow Earth', 'FontSize',8)
plot(M, 0, 'ko', 'linewidth', 2)
text(M+0.05,0,'\leftarrow Moon', 'FontSize',8)
title('The trajectory of the spacecraft in a rotating coordinate system')
grid on

% Function containing the equations of each derivative.
function dYdt = f(t, y, E, M)

    z1 = y(1);
    z2 = y(2);
    z3 = y(3);
    z4 = y(4);
    
    rE = sqrt((z1+E)^2 +z3^2);
    rM = sqrt((z1-M)^2 + z3^2);
    
    dx = z2;
    dx2 = 2*z4 + z1 - M*(z1+E)/rE^3 - E*(z1-M)/rM^3;
    dy = z4;
    dy2 = -2*z2 + z3 - M*z3/rE^3 - E*z3/rM^3;
  
    dYdt = [dx;dx2;dy;dy2];
    
end



