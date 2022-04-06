clc, clear all, close all

% Parameters
mu = 0.1;

% Part a) Find critical points
x0 = rand(1,6);
[vars, fval, exitflag] = fsolve('OrbitalMotionCritical', x0, [], mu);
x0 = vars(1);
u0 = vars(2);
y0 = vars(3);
v0 = vars(4);
z0 = vars(5);
w0 = vars(6);
fprintf("The critical points are:\nx = %.10f\nu = %.10f\ny = %.10f\nv = %.10f\nz = %.10f\nw = %.10f\n", x0, u0, y0, v0, z0, w0);

%% Part b): Apply linearization

A = [1 0 0 0 0 0;
     0 2 0 0.75 1.0392 0;
     0 1 0 0 0 0;
     -2 0 0 1.0392 2.25 0;
     0 0 1 0 0 0;
     0 0 0 0 0 -1];
 
 
% Display the root locus of the system

% Now, find the eigen values
lambda = eig(A);
fprintf("The eigenvalues (critical points) are:\n");
disp(lambda)

pause
%% Part c)
mu = 0.35;
tspan = 0:1e-3:24;
xinit = [0.3, 0, 0, 0, 0, 0];
[t, vars] = ode45(@(t,vars)OrbitalMotion(t, vars, mu), tspan, xinit);
x = vars(:,1);
u = vars(:,2);
y = vars(:,3);
v = vars(:,4);
z = vars(:,5);
w = vars(:,6);

figure
% Plot planets
plot(0, 0, 'r*'), hold on
plot(-1, 0, 'm*')
plot(x, y), grid on
xlabel('x');
ylabel('y');
xlabel('z');
pause
%% Part d)

% Run the simulation for two initial conditions nearly identical
figure

xinit = [-1.2, 0, 0, 0, 0, 0];
[t, vars] = ode45(@(t,vars)OrbitalMotion(t, vars, mu), tspan, xinit);
x = vars(:,1);
y = vars(:,3);
z = vars(:,5);
plot(0, 0, 'r*'), hold on
plot(-1, 0, 'm*')
plot(x, y), grid on
hold on

xinit = [-1.3, 0, 0, 0, 0, 0];
[t, vars] = ode45(@(t,vars)OrbitalMotion(t, vars, mu), tspan, xinit);
x = vars(:,1);
y = vars(:,3);
z = vars(:,5);
plot(0, 0, 'r*'), hold on
plot(-1, 0, 'm*')
plot(x, y), grid on
grid on
xlabel('x');
ylabel('y');
xlabel('z');
legend('{x_0 = -1.2}', '{x_0 = -1.3}');
pause

%% Part e)
% The stable evolutions around m1, m2 or transfer orbit from m1 to m2, will
% depend of the initial conditions
figure
% Transfer orbit
mu = 0.9;
xinit = [-1.2, 0, 0, 0, 0, 0];
[t, vars] = ode45(@(t,vars)OrbitalMotion(t, vars, mu), tspan, xinit);
x = vars(:,1);
y = vars(:,3);
z = vars(:,5);
plot(0, 0, 'r*', 'linewidth', 2), hold on
plot(-1, 0, 'm*', 'linewidth', 2)
plot(x, y), grid on
hold on
xlabel('x');
ylabel('y');
xlabel('z');
legend('{m_1}', '{m_2}', '{m_3}');
title('Transfer orbit');

% Stable around m1
figure
mu = 1;
xinit = [0.4, 0, 0, 0, 0, 0];
[t, vars] = ode45(@(t,vars)OrbitalMotion(t, vars, mu), tspan, xinit);
x = vars(:,1);
y = vars(:,3);
z = vars(:,5);
plot(0, 0, 'r*', 'linewidth', 2), hold on
plot(-1, 0, 'm*', 'linewidth', 2)
plot(x, y), grid on
grid on
xlabel('x');
ylabel('y');
legend('{m_1}', '{m_2}', '{m_3}');
title('Stable around {m_1}');

% Stable around m2
figure
mu = 0.95;
xinit = [-1.07, 0, 0.01, 0, 0, 0];
[t, vars] = ode45(@(t,vars)OrbitalMotion(t, vars, mu), tspan, xinit);
x = vars(:,1);
y = vars(:,3);
z = vars(:,5);
plot(0, 0, 'r*', 'linewidth', 2), hold on
plot(-1, 0, 'm*', 'linewidth', 2)
plot(x, y), grid on
grid on
xlabel('x');
ylabel('y');
legend('{m_1}', '{m_2}', '{m_3}');
title('Stable around {m_2}');

% Stable around Lagrange points
figure
mu = 0.7;
xinit = [-1.07, -0.5, 0.01, 0, 0, 0];
[t, vars] = ode45(@(t,vars)OrbitalMotion(t, vars, mu), tspan, xinit);
x = vars(:,1);
y = vars(:,3);
z = vars(:,5);
plot(0, 0, 'r*', 'linewidth', 2), hold on
plot(-1, 0, 'm*', 'linewidth', 2)
plot(x, y), grid on
grid on
xlabel('x');
ylabel('y');
legend('{m_1}', '{m_2}', '{m_3}');

% Escape from system
figure
mu = 0.05;
xinit = [-0.9, -0.5, -0.01, 0, 0, 0];
[t, vars] = ode45(@(t,vars)OrbitalMotion(t, vars, mu), tspan, xinit);
x = vars(:,1);
y = vars(:,3);
z = vars(:,5);
plot(0, 0, 'r*', 'linewidth', 2), hold on
plot(-1, 0, 'm*', 'linewidth', 2)
plot(x, y), grid on
grid on
xlabel('x');
ylabel('y');
legend('{m_1}', '{m_2}', '{m_3}');

%% Part f)

% Show trajectories for changes in mu from 0.05 to 1
legends = {};
figure
hold on
i = 1;
for mu = 0.05:0.05:1
    xinit = [-1.07, -0.5, -0.01, 0, 0, 0];
    [t, vars] = ode45(@(t,vars)OrbitalMotion(t, vars, mu), tspan, xinit);
    x = vars(:,1);
    u = vars(:,2);
    y = vars(:,3);
    v = vars(:,4);
    z = vars(:,5);
    w = vars(:,6);

    plot(x, y)
    legends{i} = sprintf("mu = %.4f", mu);
    i = i + 1;
end
legends{i} = sprintf('{m_1}');
legends{i+1} = sprintf('{m_2}');
plot(0, 0, 'r*', 'linewidth', 2), hold on
plot(-1, 0, 'm*', 'linewidth', 2)
legend(legends);
xlabel('X');
ylabel('Y');
title('{Trajectories for different values of \mu}');
grid on