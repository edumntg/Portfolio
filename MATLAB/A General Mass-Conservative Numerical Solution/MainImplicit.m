clc, clear all, close all

%% Simulation parameters
global alpha theta_s theta_r beta A gamma Ks
z = 40; % dimension in cm
dz = 1; % step in grid
% Define the time window
tf = 360; % 360 seconds
dt = 1;

% Compute number of values
Nz = z/dz+1; % number of nodes in the grid
Nt = tf/dt;

%%
alpha = 1.611e6;
theta_s = 0.287;
theta_r = 0.075;
beta = 3.96;
Ks = 0.00944;
gamma = 4.74;
A = 1.175e6;

%% Compute graphs for K and theta
h = 0:dz:z;
K = Ks*A./(A + abs(h)).^gamma;
theta = alpha*(theta_s - theta_r)./(alpha + abs(h).^gamma) + theta_r;

% Plot
figure
subplot(1,2,1)
plot(h, K), grid on
xlabel('Pressure Head (h)');
ylabel('Hydraulic Conductivity ({K(h)})');

subplot(1,2,2)
plot(h, theta), grid on
xlabel('Pressure Head (h)');
ylabel('Water Content ({\theta(h)})');
% Define the initial values

hz_0 = -61.5; % h(z,0)
% htop = -20.7; % htop = h(40,t)
% hbottom = -61.5;
htop = -61.5; % htop = h(40,t)
hbottom = -20.7;

% Define the array that will hold the solution
H = zeros(Nz, Nt);

% Set the initial conditions
H(:,1)= hz_0;
H(Nz, :) = htop;
H(1,:) = hbottom;
% pause

h = 0:dz:z;

% First, we calculate the values of theta(h) and K(h)
theta = alpha*(theta_s - theta_r)./(alpha + abs(h).^beta) + theta_r;
K = Ks*A./(A + abs(h).^gamma);
C = alpha.*(theta_s - theta_r).*beta.*abs(h).^(beta-1) ./(alpha + abs(h).^beta).^2;
dK = Ks*A*gamma*abs(h).^(gamma-1) ./(A + abs(h).^gamma).^2;

lambda = dt./C;
a = lambda.*dK./dz;
b = lambda.*K./(dz^2);
c = dK;

options = optimset('display', 'off');
for n = 2:Nt
    % build vector of initial seeds
    x0 = H(:, n-1);
    
    [x, fval, exitflag, output] = fsolve(@(x)ImplicitSystemEq(x, H, dt, dz, Nz, n, htop, hbottom), x0, options);
    exitflags(n-1) = exitflag;
    iters(n-1) = output.iterations;
    
    H(:, n) = x;
    
%     v = 1;
%     for i = 1:Nz
%         H(i, n) = x(v);
%         v = v + 1;
%     end
    H(:,1)= hz_0;
end

Z = 0:dz:z;
figure
for n = 1:Nt
    clf
    plot(Z, H(:, n))
    xlabel('DEPTH (CM)')
    ylabel('PRESSURE HEAD (CM)')
    grid on
    pause(0.1);
end

% save('sim1', 'H', 'Z', 'iters');