clc, clear all, close all

%% Orbita
global G M m

% Create sphere
% Scaling factr
k = 6.371e6;

R = 6.371e6;

G = 6.674e-11;
M = 5.972e24;
m = 10000;

x0 = [2e6 + R, 7800, 2e6 + R, 6400, 2e6 + R, 3900];
tspan = 0:1:3600*72;

options = odeset('RelTol',5.421011e-20,'AbsTol',5.421011e-20);%'OutputFcn',@odeplot,'Stats','on');

[t,vars] = ode45(@(t,x)orbit(t,x), tspan, x0, options);


figure
[X,Y,Z] = sphere();
X = X*R/k;
Y = Y*R/k;
Z = Z*R/k;

surf(X,Y,Z), hold on

plot3(vars(:,1)/k, vars(:,3)/k, vars(:,5)/k)

xlim([-5,5])
ylim([-5,5])
zlim([-5,5])

xlabel('X')
ylabel('Y')
zlabel('Z')

function df = orbit(t, vars)
    global M m G
   
    x = vars(1);
    vx = vars(2);
    y = vars(3);
    vy = vars(4);
    z = vars(5);
    vz = vars(6);
    D = sqrt(x^2 + y^2 + z^2);
    dvx = -(1/m)*(G*M*m)/D^2;
    dvy = -(1/m)*(G*M*m)/D^2;
    dvz = -(1/m)*(G*M*m)/D^2;
    
    df = zeros(6,1);
    df(1) = vx; % dxdt
    df(2) = dvx; % dvxdt
    df(3) = vy;
    df(4) = dvy;
    df(5) = vz;
    df(6) = dvz;
    
end