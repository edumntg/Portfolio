clc, clear all, close all

%% Heat Diffusion in a plane

k = 237; % Aluminum (W/(mK))
p = 2.7; % g/cm^3 
% p = p /1000 *100^3; % convert to kg/m^3
cp = 910; % aluminum (J/(kg*K))

% k = k /100; % to cm

alpha = k/cp;

tf = 1000;
dt = 0.1;

L = 100; % in cm
dx = 1;

Nt = tf/dt;
Nx = L/dx;

% Initial condition
U = zeros(Nt, Nx);

U(:, 1) = 100; % 100 degrees at left
U(:, Nx) = 100;
for n = 1:Nt-1
    for i = 2:Nx-1
        U(n+1, i) = U(n,i) + (dt*alpha/dx^2)*(U(n,i+1) - 2*U(n,i) + U(n,i-1));
    end
    U(:, 1) = 100; % 100 degrees at left
    U(:, Nx) = 100;
end

% Plot
% figure
% for n = 1:Nt-1
%     if mod(n, 10) == 0
%         clf
%         plot(dx:dx:L, U(n, :))
%         title(sprintf("t = %.2f", n*dt));
%         pause(0.05)
% 
%     end
% end

% Test implicit
a = alpha*dt/dx^2;
d = (1+2*a)*ones(1, Nx);
A = diag(d);
A(1,1) = 1;
A(Nx,Nx) = 1;

for i = 2:Nx-1
    A(i, i-1) = -a;
end

for i = 3:Nx
    A(i-1,i) = -a;
end

U2 = zeros(Nt, Nx);
U2(:,1) = 100;
U2(:,Nx) = 100;
for n = 2:Nt-1
    % construct B
    B = U(n-1,:)';
    
    % Solve
    Usol = inv(A)*B;
    U2(n,:) = Usol;
end


figure
for n = 1:Nt-1
    if mod(n, 10) == 0
        clf
        plot(dx:dx:L, U2(n, :))
        title(sprintf("t = %.2f", n*dt));
        pause(0.05)

    end
end