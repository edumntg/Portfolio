clc, clear all, close all

%Machine parameters
Rs = 1.6e-3;
Rf = 0.985e-3;
Ld = 7e-3;
Lf = 7.384e-3;
Lm = 6.656e-3;
Lq = 5.61e-3;

%system parameters
f = 50;
ws = 2*pi*f;

%reactances
Xd = ws*Ld;
Xq = ws*Lq;
Xf = ws*Lf;
Xm = ws*Lm;

S = 370000000;              
V = 20000;               
H = 3.75;               
pf = 0.9;               
Phi = acos(pf);         

%load parameters
Iload = S/V                 
Pload = -S*pf               
Qload = -S*sin(Phi)    	
delta = atan((Qload - Xq*Iload^2)/(Pload - Rs*Iload^2)) - Phi 
Vd = V*sin(delta) % voltage in d axis  
Vq = V*cos(delta) % voltage in q axis  
J = 0.5*H*S/(ws^2)  

syms Id Iq
Equations = [Vd*Id + Vq*Iq == Pload, Vq*Id - Vd*Iq == Qload];
S = solve(Equations,[Id Iq]);
Id = double(vpa(S.Id))
Iq = double(vpa(S.Iq))

If = (Vq - Rs*Iq - Xd*Id)/Xm;     
Vf = Rf*If                              

PhiF = Lm*Id + Lf*If                 
PhiD = Ld*Id + Lm*If
PhiQ = Lq*Iq

Te = PhiQ*Id - PhiD*Iq
