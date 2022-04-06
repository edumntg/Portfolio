clc, clear all, close all

%% PARAMETERS OF THE ITERATIVE METHOD
maxIters = 5000;        % Max. number of iterations. For part 2, set this value equal to 3. 
tol = 1e-12;            % Tolerance

%% Declaration of DATA

Sb = 100;
Vb = 10;

%       From To R       X       G       B       MVAr    tap
LINES = [1  2   0.0108  0.0649  2.5     -15     6.6     1
         1  4   0.0235  0.0941  2.5     -10     4.0     1
         2  3   0.04    0       0        0      0       0.975
         2  5   0.0118  0.0471  5.0     -20     7.0     1
         3  5   0.0147  0.0588  4.0     -16     8.0     1
         4  5   0.0118  0.0529  4.0     -18     6.0     1];   

%      ID   Pload   Qload   Pgen    Qgen    V       theta
BUS = [1    0       0       0       0       1.01    0
       2    0       0       60/Sb   35/Sb   1.0     0
       3    0       0       70/Sb   42/Sb   1.0     0
       4    0       0       80/Sb   50/Sb   1.0     0
       5    190/Sb  0       65/Sb   36/Sb   1.0     0];
  
%      Bus  MVAr
CAP = [3    18/Sb
       4    15/Sb];

   
n = size(BUS, 1); % number of buses


%% Construct Ybus
Ybus = zeros(n,n);
g0 = zeros(n,n);
b0 = zeros(n,n);
for l = 1:size(LINES,1)
    Z = LINES(l, 3) + 1i*LINES(l,4);        % Impedance
    Yshunt = 0;
    
    a = LINES(l, 8);                        % TAP
    
    i = LINES(l,1); % bus i
    k = LINES(l,2); % bus k
    
    Ybus(i,i) = Ybus(i,i) + 1/Z/(a^2);
    Ybus(k,k) = Ybus(k,k) + 1/Z/(a^2);
    Ybus(i,k) = Ybus(i,k) - 1/Z/a;
    Ybus(k,i) = Ybus(k,i) - 1/Z/a;
    
    % Now add shunts
    Ybus(i,i) = Ybus(i,i) + Yshunt/2;
    Ybus(k,k) = Ybus(k,k) + Yshunt/2;
    
    g0(i,k) = real(Yshunt/2);
    g0(k,i) = real(Yshunt/2);
    b0(i,k) = imag(Yshunt/2);
    b0(k,i) = imag(Yshunt/2);
end

G = real(Ybus);
B = imag(Ybus);

%% Load setpoints and initial values
Pg = BUS(:, 2);
Qg = BUS(:, 3);
Pload = BUS(:,4);
Qload = BUS(:,5);

%% Now, we have 5 busses and 1 slack. This means, we will have 2*10-1 = 9 variables (and 9 equations)
%   The variables are defined in the following lines as symbolic variables

%   We will construc the Jacobian using symbolic expressions. In this way,
%   we can find the derivates easily

syms Pg1 V2 th2 V3 th3 V4 th4 th5 Qg5

%% Now define the known values for voltages and angles

V = BUS(:, 6);
th = BUS(:, 7);

%% Pflows (Symbolic equations, do not touch)
P12 = (-G(1,2) + g0(1,2))*V(1)^2 + V(1)*V2*(G(1,2)*cos(th(1)-th2) + B(1,2)*sin(th(1)-th2));
P14 = (-G(1,4) + g0(1,4))*V(1)^2 + V(1)*V4*(G(1,4)*cos(th(1)-th4) + B(1,4)*sin(th(1)-th4));
P25 = (-G(2,5) + g0(2,5))*V2^2 + V2*V(5)*(G(2,5)*cos(th2-th5) + B(2,5)*sin(th2-th5));
P35 = (-G(3,5) + g0(3,5))*V3^2 + V3*V(5)*(G(3,5)*cos(th3-th5) + B(3,5)*sin(th3-th5));
P45 = (-G(4,5) + g0(4,5))*V4^2 + V4*V(5)*(G(4,5)*cos(th4-th5) + B(4,5)*sin(th4-th5));

P21 = (-G(2,1) + g0(2,1))*V2^2 + V2*V(1)*(G(2,1)*cos(th2-th(1)) + B(2,1)*sin(th2-th(1)));
P41 = (-G(4,1) + g0(4,1))*V4^2 + V4*V(1)*(G(4,1)*cos(th4-th(1)) + B(4,1)*sin(th4-th(1)));
P52 = (-G(5,2) + g0(5,2))*V(5)^2 + V(5)*V2*(G(5,2)*cos(th5-th2) + B(5,2)*sin(th5-th2));
P53 = (-G(5,3) + g0(5,3))*V(5)^2 + V(5)*V3*(G(5,3)*cos(th5-th3) + B(5,3)*sin(th5-th3));
P54 = (-G(5,4) + g0(5,4))*V(5)^2 + V(5)*V4*(G(5,4)*cos(th5-th4) + B(5,4)*sin(th5-th4));

%% Qflows (Symbolic equations, do not touch)
Q12 = (B(1,2) - b0(1,2))*V(1)^2 + V(1)*V2*(-B(1,2)*cos(th(1)-th2) + G(1,2)*sin(th(1)-th2));
Q14 = (B(1,4) - b0(1,4))*V(1)^2 + V(1)*V4*(-B(1,4)*cos(th(1)-th4) + G(1,4)*sin(th(1)-th4));
Q25 = (B(2,5) - b0(2,5))*V2^2 + V2*V(5)*(-B(2,5)*cos(th2-th5) + G(2,5)*sin(th2-th5));
Q35 = (B(3,5) - b0(3,5))*V3^2 + V3*V(5)*(-B(3,5)*cos(th3-th5) + G(3,5)*sin(th3-th5));
Q45 = (B(4,5) - b0(4,5))*V4^2 + V4*V(5)*(-B(4,5)*cos(th4-th5) + G(4,5)*sin(th4-th5));

Q21 = (B(2,1) - b0(2,1))*V2^2 + V2*V(1)*(-B(2,1)*cos(th2-th(1)) + G(2,1)*sin(th2-th(1)));
Q41 = (B(4,1) - b0(4,1))*V4^2 + V4*V(1)*(-B(4,1)*cos(th4-th(1)) + G(4,1)*sin(th4-th(1)));
Q52 = (B(5,2) - b0(5,2))*V(5)^2 + V(5)*V2*(-B(5,2)*cos(th5-th2) + G(5,2)*sin(th5-th2));
Q53 = (B(5,3) - b0(5,3))*V(5)^2 + V(5)*V3*(-B(5,3)*cos(th5-th3) + G(5,3)*sin(th5-th3));
Q54 = (B(5,4) - b0(5,4))*V(5)^2 + V(5)*V4*(-B(5,4)*cos(th5-th4) + G(5,4)*sin(th5-th4));

%% Capacitors
Qcap = zeros(n,1);
for i = 1:size(CAP)
    Qcap(CAP(i,1)) = CAP(i,2);
end

%% Equations
Eq1 = Pg1 - P12 - P14 - Pload(1);
Eq2 = P21 + P25 + Pload(2);
Eq3 = P35 + Pload(3);
Eq4 = P45 + P41 + Pload(4);
Eq5 = Pg(5) - P52 - P53 - P54 - Pload(5);
Eq6 = Q25 + Q21 + Qload(2);
Eq7 = Qcap(3) - Q35 - Qload(3);
Eq8 = Qcap(4) - Q45 - Q41 - Qload(4);
Eq9 = Qg5 - Q52 - Q53 - Q54 - Qload(5);

%% Newton-Raphson Starts here

x_old = [Pg(1); V(2); th(2); V(3); th(3); V(4); th(4); th(5); Qg(5)];

% Jacobian matrix
J = [diff(Eq1, Pg1), diff(Eq1, V2), diff(Eq1, th2), diff(Eq1, V3), diff(Eq1, th3), diff(Eq1, V4), diff(Eq1, th4), diff(Eq1, th5), diff(Eq1, Qg5)
     diff(Eq2, Pg1), diff(Eq2, V2), diff(Eq2, th2), diff(Eq2, V3), diff(Eq2, th3), diff(Eq2, V4), diff(Eq2, th4), diff(Eq2, th5), diff(Eq2, Qg5)
     diff(Eq3, Pg1), diff(Eq3, V2), diff(Eq3, th2), diff(Eq3, V3), diff(Eq3, th3), diff(Eq3, V4), diff(Eq3, th4), diff(Eq3, th5), diff(Eq3, Qg5)
     diff(Eq4, Pg1), diff(Eq4, V2), diff(Eq4, th2), diff(Eq4, V3), diff(Eq4, th3), diff(Eq4, V4), diff(Eq4, th4), diff(Eq4, th5), diff(Eq4, Qg5)
     diff(Eq5, Pg1), diff(Eq5, V2), diff(Eq5, th2), diff(Eq5, V3), diff(Eq5, th3), diff(Eq5, V4), diff(Eq5, th4), diff(Eq5, th5), diff(Eq5, Qg5)
     diff(Eq6, Pg1), diff(Eq6, V2), diff(Eq6, th2), diff(Eq6, V3), diff(Eq6, th3), diff(Eq6, V4), diff(Eq6, th4), diff(Eq6, th5), diff(Eq6, Qg5)
     diff(Eq7, Pg1), diff(Eq7, V2), diff(Eq7, th2), diff(Eq7, V3), diff(Eq7, th3), diff(Eq7, V4), diff(Eq7, th4), diff(Eq7, th5), diff(Eq7, Qg5)
     diff(Eq8, Pg1), diff(Eq8, V2), diff(Eq8, th2), diff(Eq8, V3), diff(Eq8, th3), diff(Eq8, V4), diff(Eq8, th4), diff(Eq8, th5), diff(Eq8, Qg5)
     diff(Eq9, Pg1), diff(Eq9, V2), diff(Eq9, th2), diff(Eq9, V3), diff(Eq9, th3), diff(Eq9, V4), diff(Eq9, th4), diff(Eq9, th5), diff(Eq9, Qg5)];

% Objective function
F = [Eq1;Eq2;Eq3;Eq4;Eq5;Eq6;Eq7;Eq8;Eq9];

% Here the iterative method starts
iterations = 2;
while(iterations < maxIters)
    
    % Find the Jacobian matrix for the values found in the previous
    % iteration
    Jk = double(subs(J, [Pg1 V2 th2 V3 th3 V4 th4 th5 Qg5], [Pg(1) V(2) th(2) V(3) th(3) V(4) th(4) th(5) Qg(5)]));

    % Evaluate the objective function with the values found in the previous
    % iteration
    Fk = double(subs(F, [Pg1 V2 th2 V3 th3 V4 th4 th5 Qg5], [Pg(1) V(2) th(2) V(3) th(3) V(4) th(4) th(5) Qg(5)]));
    
    % Values from previous iteration
    x_old = [Pg(1); V(2); th(2); V(3); th(3); V(4); th(4); th(5); Qg(5)];
    
    % The new values found using Newtoh-Raphson are obtained using the
    % following expresion:
    %   x_new = x_old - inv(J(x_old))*F(x_old)
    
    % Where:
    %   J(x_old) = Jk
    %   F(x_old) = Fk
    %   x_new is the solution found in iteration i
    %   x_old is the solution found in the iteration i-1
    
    x_sol = double(x_old - inv(Jk)*Fk);
    
    % Save the solutions into the corresponding variables
    Pg(1) = x_sol(1);
    V(2) = x_sol(2);
    th(2) = x_sol(3);
    V(3) = x_sol(4);
    th(3) = x_sol(5);
    V(4) = x_sol(6);
    th(4) = x_sol(7);
    th(5) = x_sol(8);
    Qg(5) = x_sol(9);
     
    % Calculate error
    error = max(abs(x_sol - x_old));
    
    iterations = iterations + 1;
    
    if error <= tol % If error is less than the tolerance, the iterative process ends
        break;
    end
    
    if iterations >= maxIters
        fprintf('Iterative process ended without a solution (iteraionts = %s)\n', num2str(maxIters));
    end
    
end

% Calculate the Qgenerated (for slack and PV buses, for PQ buses, it should
% be zero)
for i = 1:n
    if i == 1 % slack bus, we have to calculate Qgen
        Qg(i) = Qcap(i)-Qload(i);
        for k = 1:n
            if i ~= k
                Qg(i) = Qg(i) + (B(i,k) - b0(i,k))*V(i)^2 + V(i)*V(k)*(-B(i,k)*cos(th(i)-th(k)) + G(i,k)*sin(th(i)-th(k)));
            end
        end
    end
end

%% Calculate line flows
Pik = zeros(n,n);
Qik = zeros(n,n);
Ploss_total = 0;
Qloss_total = 0;
for i = 1:n
    for k = 1:n
        if i ~= k
            Pik(i,k) = (-G(i,k) + g0(i,k))*V(i)^2 + V(i)*V(k)*(G(i,k)*cos(th(i)-th(k)) + B(i,k)*sin(th(i)-th(k)));
            Ploss_total = Ploss_total + Pik(i,k);
            
            Qik(i,k) = (B(i,k) - b0(i,k))*V(i)^2 + V(i)*V(k)*(-B(i,k)*cos(th(i)-th(k)) + G(i,k)*sin(th(i)-th(k)));
            Qloss_total = Qloss_total + Qik(i,k);
        end
    end
end

head = ['    Bus  Voltage  Angle    ------Load------    ---Generation---   Injected'
        '    No.  Mag.      Rad      (p.u)   (p.u)       (p.u)    (p.u)     (p.u)  '
        '                                                                          '];
disp(head)

for i = 1:n
     fprintf(' %5g', i), fprintf(' %7.4f', V(i)),
     fprintf(' %8.4f', th(i)), fprintf(' %9.4f', abs(Pload(i))),
     fprintf(' %9.4f', abs(Qload(i))),  fprintf(' %9.4f', Pg(i)),
     fprintf(' %9.4f ', Qg(i)), fprintf(' %8.4f\n', Qcap(i))
end
    fprintf('      \n'), fprintf('    Total              ')
    fprintf(' %9.4f', abs(sum(Pload))), fprintf(' %9.4f', abs(sum(Qload))),
    fprintf(' %9.4f', sum(Pg)), fprintf(' %9.4f', sum(Qg)), fprintf(' %9.4f\n\n', sum(Qcap))
    fprintf('    Total loss AC:           ')
    fprintf(' P: %9.4f ', Ploss_total), fprintf(' Q: %9.4f', Qloss_total)
    fprintf('\n\n\n');


fprintf('\n\n');
  
head_line = ['                              Line Flows                                '
             '    Line   Pik       Pki       Ploss     Qik       Qki       Qloss      '
             '                                                                        '];
disp(head_line);
for l = 1:size(LINES,1)
    i = LINES(l, 1);
    k = LINES(l, 2);
    if(i ~= k)
        fprintf('    %i-%i', i, k), fprintf(' %9.4f', Pik(i,k)), fprintf(' %9.4f', Pik(k,i)), fprintf(' %9.4f', Pik(i,k)+Pik(k,i)), fprintf(' %9.4f', Qik(i,k)), fprintf(' %9.4f', Qik(k,i)), fprintf(' %9.4f', Qik(i,k)+Qik(k,i))
        fprintf('\n');
    end
end

fprintf('Newton-Raphson method converged after %s iterations, with error: %s\n', num2str(iterations), num2str(error));
