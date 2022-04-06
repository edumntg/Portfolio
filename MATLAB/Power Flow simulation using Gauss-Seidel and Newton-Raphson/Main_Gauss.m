clc, clear all, close all

%% Parameters of the iterative process
tol = 1e-12;
maxIters = 5000; % Max. number of iterations. For part 2, set this value equal to 3. 

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

%      ID   Pload   Qload   Pgen    Qgen    V       theta   typr
BUS = [1    0       0       0       0       1.01    0       1
       2    0       0       60/Sb   35/Sb   1.0     0       0
       3    0       0       70/Sb   42/Sb   1.0     0       0
       4    0       0       80/Sb   50/Sb   1.0     0       0
       5    190/Sb  0       65/Sb   36/Sb   1.0     0       2];
  
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
Pgconsig = BUS(:,2);
Qgconsig = BUS(:,3);
Pload = BUS(:,4);
Qload = BUS(:,5);

%% Now define the known values

Vprev = BUS(:, 6); % Initial values
V = Vprev;

%% Calcualte net power injection in each bus
P = Pg - Pload;
Q = Qg - Qload;
Qcap = zeros(n,1);
for i = 1:size(CAP,1)
    bus = CAP(i,1);
    Qcap(bus) = CAP(i,2);
    Q(bus) = Q(bus) + Qcap(bus);
end

Y = Ybus;

%% HEre the iterative process starts
iterations = 2;


while(iterations < maxIters)
    for i = 2:n
        sumyv = 0;
        for j = 1:n
            if i ~= j
                sumyv = sumyv + Y(i,j)*V(j);
            end
        end
        
        if BUS(i,8) == 2 % PV. If bus is PV, calcualte the Q injectedinto the bus
            Q(i) = -imag(conj(V(i))*(sumyv + Y(i,i)*V(i)));
        end
        
        V(i) = (1/Y(i,i))*((P(i)-1i*Q(i))/conj(V(i)) - sumyv); % Compute bus voltages
        
        if BUS(i,8) == 2 % For PV buses, the voltage magnitude remains same, but the angle changes
            V(i) = abs(Vprev(i))*(cos(angle(V(i)))+1i*sin(angle(V(i))));
        end
    end
    
    iterations = iterations + 1;
    error = max(abs(abs(V)-abs(Vprev))); % calculate error
    Vprev = V; % update previous values
    
    if error <= tol % if error is less than tolerance, iterative process ends
        break;
    end
    
    if iterations >= maxIters
        fprintf('Iterative process ended without a solution (iteraionts = %s)\n', num2str(maxIters));
    end

end

% Save solution into vectors

Vcomplex = V;
th = angle(V);
V = abs(V);
Pik = zeros(n,n);
Qik = zeros(n,n);

Ploss_total = 0;
Qloss_total = 0;
for i = 1:n
    for k = 1:n
        if i ~= k
            Iik(i,k) = (V(i)-V(k))*(-Y(i,k));
            Pik(i,k) = real(V(i)*conj(Iik(i,k)));
            Ploss_total = Ploss_total + Pik(i,k);
            
            Qik(i,k) = imag(V(i)*conj(Iik(i,k)));
            Qloss_total = Qloss_total + Qik(i,k);
        end
    end
end

% Calculate power generated
Pg = zeros(n,1);
Qg = zeros(n,1);
for i = 1:n
    Pg(i) = Pload(i);
    Qg(i) = Qload(i);
    for k = 1:n
        if i ~= k
            Pg(i) = Pg(i) + Pik(i,k);
            Qg(i) = Qg(i) + Qik(i,k);
        end
    end
end

Pgreal = zeros(n,1);
Qgreal = zeros(n,1);
Pgreal(1) = sum(Pg)-Pgconsig(5);
Pgreal(5) = Pgconsig(5);
Qgreal(1) = sum(Qg)-Qg(5);
Qgreal(5) = Qg(5)-sum(Qcap);
head = ['    Bus  Voltage  Angle    ------Load------    ---Generation---   Injected  '
        '    No.  Mag.      Rad      (p.u)   (p.u)       (p.u)    (p.u)     (p.u)    '
        '                                                                            '];
disp(head)

for i = 1:n
     fprintf(' %5g', i), fprintf(' %7.4f', V(i)),
     fprintf(' %8.4f', th(i)), fprintf(' %9.4f', abs(Pload(i))),
     fprintf(' %9.4f', abs(Qload(i))),  fprintf(' %9.4f', Pgreal(i)),
     fprintf(' %9.4f ', Qgreal(i)), fprintf(' %8.4f\n', Qcap(i))
end
    fprintf('      \n'), fprintf('    Total              ')
    fprintf(' %9.4f', abs(sum(Pload))), fprintf(' %9.4f', abs(sum(Qload))),
    fprintf(' %9.4f', sum(Pgreal)), fprintf(' %9.4f', sum(Qgreal)), fprintf(' %9.4f\n\n', sum(Qcap))
    fprintf('    Total loss AC:           ')
    fprintf(' P: %9.4f ', Ploss_total), fprintf(' Q: %9.4f', Qloss_total)
    fprintf('\n\n\n');

fprintf('Gauss Seidel method converged after %s iterations, with error: %s\n', num2str(iterations), num2str(error));
