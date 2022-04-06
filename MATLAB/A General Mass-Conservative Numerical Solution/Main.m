clc, clear all, close all

%% Simulation parameters

z = 40; % dimension in cm
dz = 0.1; % step in grid
% Define the time window
tf = 10; % 360 seconds
dt = 1e-4;

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

% Define the initial values

hz_0 = -61.5; % h(z,0)
% htop = -20.7; % htop = h(40,t)
% hbottom = -61.5;
htop = -61.5; % htop = h(40,t)
hbottom = -20.7;

% Define the array that will hold the solution
H = zeros(Nz, Nt);

% Set the initial conditions
H(Nz, :) = htop;
H(1,:) = hbottom;
% pause

% Begin with Finite Diff method

h = dz:dz:z;

% First, we calculate the values of theta(h) and K(h)
theta = alpha*(theta_s - theta_r)./(alpha + abs(h).^beta) + theta_r;
K = Ks*A./(A + abs(h).^gamma);
C = alpha.*(theta_s - theta_r).*beta.*abs(h).^(beta-1) ./(alpha + abs(h).^beta).^2;
dK = Ks*A*gamma*abs(h).^(gamma-1) ./(A + abs(h).^gamma).^2;

figure
subplot(1,3,1)
plot(h, theta), grid on
xlabel('Pressure head (cm)')
ylabel('Water content')

subplot(1,3,2)
plot(h, K), grid on
xlabel('Pressude head (cm)')
ylabel('Unsaturared Hydraulic Conductivity')

subplot(1,3,3)
plot(h, C), grid on
xlabel('Pressude head (cm)')
ylabel('C(h)')

options = optimset('display', 'off');

v = 1;
for n = 1:Nt-1
    for i = 2:Nz-1
        % Fsolve used for the iterative part. It is used to get the value
        % of H(n+1,i) because the equation is not linear
        
        % Also, the equation is multiplied by 1000 because of fsolve's
        % tolerance, since the equation is in units of CMs, the numeric
        % values are too small.
        
%         [x, fval, exitflag] = fsolve(@(x)[
%             1e6*(((theta(i+1)-theta(i))/dz)*((x - H(n,i))/dt) - ((K(i+1)-K(i))/dz)*((H(n,i+1)-H(n,i))/dz) - K(i)*((H(n,i+1) - 2*H(n,i) + H(n,i-1))/dz^2) + ((K(i+1) - K(i))/dz))
%         ], H(n,i), options);

%         [x, fval, exitflag] = fsolve(@(x)f(x, H, K, theta, i, n, dt, dz), H(n,i), options);
%         [x, fval, exitflag] = fsolve(@(x)f2(x, H, K, dK, C, i, n, dt, dz), H(i,n), options);
        [x, fval, exitflag] = fsolve(@(x)f3(x, H, K, dK, C, i, n, dt, dz), 1, options);


%         dHdz = (H(i+1,n) - H(i,n))/dz;
    
%         d2Hdz = (H(i+1,n) - 2*H(i,n) + H(i-1,n))/(dz^2);

%         H(i,n+1) = H(i,n) + (dt/C(i))*(dK(i)*dHdz^2 + K(i)*d2Hdz + dK(i)*dHdz);

        
%         C = (theta(i+1)-theta(i))/dz;
%         H(n+1,i) = H(n,i) + dt*(1/C)*(((K(i+1)-K(i))/dz)*((H(n,i+1)-H(n,i))/dz) + K(i)*((H(n,i+1) - 2*H(n,i) + H(n,i-1))/dz^2) - ((K(i+1) - K(i))/dz));
        H(i, n+1) = x;
        exitflags(v) = exitflag;
        v = v + 1;
        

    end
    H(Nz, :) = htop;
    H(1,:) = hbottom;
end
Z = 0:dz:z;


figure
plot(Z, H(:, end))
xlabel('DEPTH (CM)')
ylabel('PRESSURE HEAD (CM)')
grid on