clc, clear all, close all

%% Script to calculate steady-state values

f = 50; % System frequency


%% Machine physical parameters
Rs = 1.6e-3;
Rf = 0.985e-3;
Ld = 7e-3;
Lf = 7.384e-3;
Lm = 6.656e-3;
Lq = 5.61e-3;

%% Calculations 
S = 370e6;              % Rated Power
V = 20e3;               % Nominal Voltage
H = 3.75;               % Inertia Constant
ws = 2*pi*50;           % Synchronous Speed in Rad/sec
pf = 0.9;               % Load Power Factor
phi = acos(pf);         % Load factor angle

I = S/V                 % Current demanded by the load
P = -S*pf               % Real Power demanded by the load
Q = -sqrt(S^2 - P^2)    % Reactive Power demanded by the load
tanfidelta = (Q - ws*Lq*I^2)/(P - Rs*I^2); 	% Tan(fi + delta)
delta = atan(tanfidelta) - phi % Load angle
Vd = V*sin(delta)       %Vd value
Vq = V*cos(delta)       %Vq value
J = (1/2)*(H*S)/(ws^2)  %Inertia Value

%% To find Id and Iq, we use the fsolve function and the two functions regarding P and Q
% Id = x(1), Iq = x(2)
x0 = [0 0];
[x, fval, exitflag] = fsolve(@(x)[Vd*x(1) + Vq*x(2) - P;Vq*x(1) - Vd*x(2) - Q], x0);

if exitflag < 0
        fprintf('Solution not found. Please check values.\n');
        pause
end

Id = x(1)
Iq = x(2)

If = (Vq - Rs*Iq - ws*Ld*Id)/(ws*Lm);     % Rotor Current
Vf = Rf*If                              % Rotor Induced Voltage

%% Linkages
phi_f = Lm*Id + Lf*If                 
phi_d = Ld*Id + Lm*If
phi_q = Lq*Iq

%% Torque
Te = phi_q*Id - phi_d*Iq                        % In steady condition, the mechanical torque is equal to the electrico torque

Tm = Te;

Wm0 = double(ws);
Tm0 = double(Tm);
phi_D0 = double(phi_d);
phi_Q0 = double(phi_q);
phi_F0 = double(phi_f);
delta0 = double(delta);

Vrms = 20e3;