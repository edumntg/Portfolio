function f = SolverODE(t, x, Vf0, J, Tm0)

lambda_d = x(1);
lambda_q = x(2);
lambda_f = x(3);
wm = x(4);
theta = x(5);

f = 50;
ws = 2*pi*f;

Rs = 1.6e-3;
Rf = 0.985e-3;
Ld = 7e-3;
Lf = 7.384e-3;
Lm = 6.656e-3;
Lq = 5.61e-3;
% J = 3.75;

Vf = Vf0;
Tm = Tm0;

Vrms = 22e3;

% Va = sqrt(2)*Vrms*sin(ws*t);
% Vb = sqrt(2)*Vrms*sin(ws*t - 100*pi/180);
% Vc = sqrt(2)*Vrms*sin(ws*t + 100*pi/180);
% theta = ws*t;
% Vd = sqrt(3)/2* (Va*cos(theta)+Vb*cos(theta-2*pi/3)+Vc*cos(theta+2*pi/3));
% Vq = sqrt(3)/2* (-Va*sin(theta)-Vb*sin(theta-2*pi/3)-Vc*sin(theta+2*pi/3));

lambda_vec = [lambda_d;lambda_q;lambda_f];

Vd = Vrms*sin(theta);
Vq = Vrms*cos(theta);

L = [Ld 0 Lm;0 Lq 0;Lm 0 Lf];

I = inv(L)*lambda_vec;
Id = I(1);
Iq = I(2);
If = I(3);

if t >= 20
    Tm = 1.2*Tm0;
end

Te = -lambda_d*Iq + lambda_q*Id;
S = 448e6;
fp = 0.9;
P = S*fp;
% J = (J*S)/(0.5*ws.^2); %Inertia Value

dlambdad = Vd - Rs*Id + wm*lambda_q;
dlambdaq = Vq - Rs*Iq - wm*lambda_d;
dlambdaf = Vf - Rf*If;
dwm = (Tm - Te)/J;
dtheta = wm - ws;

f = [dlambdad;dlambdaq;dlambdaf;dwm;dtheta];
% t
end