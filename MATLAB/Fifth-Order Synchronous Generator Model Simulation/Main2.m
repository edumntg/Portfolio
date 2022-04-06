clc, clear all, close all

%% Equivalent Resistances and Inductances
f = 50;

Rs = 1.6e-3;
Rf = 0.985e-3;
Ld = 7e-3;
Lf = 7.384e-3;
Lm = 6.656e-3;
Lq = 5.61e-3;

%% Steady State Variable
S = 370e6; %Apparent Power
V = 20e3; %Voltage
H = 3.75; %Inertia Constant
W = 2*pi*50; %Synchronous Speed in Rad/sec
pf = 0.9; %Power Factor
phi = acos(pf); %Flux
pole = 1; % Number of poles
f = 50; %Frequency
I = S/V %Current
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

Wm0 = double(ws);
Tm0 = double(Tm);
phi_D0 = double(phi_d);
phi_Q0 = double(phi_q);
phi_F0 = double(phi_f);
delta0 = double(delta);



Vrms = 20e3;