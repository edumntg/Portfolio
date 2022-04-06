clc, clear all

f = 50;
ws = 2*pi*f;

Rs = 1.6e-3;
Rf = 0.985e-3;
Ld = 7e-3;
Lf = 7.384e-3;
Lm = 6.656e-3;
Lq = 5.61e-3;
I = 3.75;
J = I;
Vf = 24.7252;



f = 50;

Rs = 1.6e-3;
Rf = 0.985e-3;
Ld = 7e-3;
Lf = 7.384e-3;
Lm = 6.656e-3;
Lq = 5.61e-3;

%% Steady State Variable
S = 448e6; %Apparent Power
V = 22e3; %Voltage
H = 3.75; %Inertia Constant
W = 2*pi*50; %Synchronous Speed in Rad/sec
pf = 0.9; %Power Factor
phi = acos(pf); %Flux
pole = 1; % Number of poles
f = 50; %Frequency
I = sqrt(S.^2/V.^2); %Current
P = -S*pf; %Real Power
Q = -S*sin(phi); %Reactive Power
tan_angles = (Q-(W*Lq*I.^2))/(P-Rs*I.^2); % tan(delta + phi)
angles = atan(tan_angles); % getting (delta+phi values)
delta = angles-phi %Delta (power angle) value
Vd = V*sin(delta) %Vd value
Vq = V*cos(delta) %Vq value
I = (H*S)/(0.5*W.^2) %Inertia Value
%% Solving equation to find stator stead-state Parameters (Id and Iq).
syms id iq
eqns = [Vd*id+Vq*iq==P, Vq*id-Vd*iq==Q];
S = solve(eqns,[id iq]);
Id = vpa(S.id)
Iq = vpa(S.iq)
%% Rotor Parameters
If = double((Vq-(Rs*Iq)-(W*Ld*Id))/(W*Lm))
Vf = double(Rf*If)
% Rotor Flux
phi_f = double(Lm*Id+Lf*If)
% Stator Flux
phi_d = double(Ld*Id+Lm*If)
phi_q = Lq*Iq
%% Electro-magnetic Torque
Te = double((phi_q*Id)-(phi_d*Iq)) %Te = Tm , in steady state conditions.

Tm = Te;
ws = 2*pi*f;
J = I;

wm0 = ws;
Tm0 = Tm;
lambdad0 = phi_d;
lambdaq0 = phi_q;
lambdaf0 = phi_f;
theta0 = delta;

%% Steady State
tspan = 0:1e-3:50;
y0 = double([lambdad0 lambdaq0 lambdaf0 wm0 theta0]);
[t, x] = ode45(@(t, x)SolverODE(t,x, Vf, J, Tm),tspan,y0);

lambda_d = x(:, 1);
lambda_q = x(:, 2);
lambda_f = x(:, 3);
wm = x(:, 4);
theta = x(:, 5);

Vrms = 22e3;
k = 1;
L = [Ld 0 Lm;0 Lq 0;Lm 0 Lf];
iL = inv(L);
% for t = tspan
%     Vd = Vrms*sin(theta(k));
%     Vq = Vrms*cos(theta(k));
% 
%     lambda_vec = [lambda_d(k);lambda_q(k);lambda_f(k)];
% 
%     I = iL*lambda_vec;
%     id(k) = I(1);
%     iq(k) = I(2);
%     ifield(k) = I(3);
%     
%     Te(k) = lambda_q(k)*id(k) - lambda_d(k)*iq(k);
%     k = k + 1;
% end

figure(1)
plot(tspan, lambda_d)
figure(2)
plot(tspan, lambda_q)
figure(3)
plot(tspan, lambda_f)
figure(4)
plot(tspan, wm)
figure(5)
plot(tspan, theta)

