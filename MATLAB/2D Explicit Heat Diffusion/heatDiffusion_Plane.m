clc, clear all, close all

%% Heat Diffusion in a plane

k = 237; % Aluminum (W/(mK))
p = 2.7; % g/cm^3 
p = p /1000 *100^3; % convert to kg/m^3
cp = 910; % aluminum (J/(kg*K))

Lx = 1;
Ly = 1;

dx = 0.01;
dy = 0.01;

Nx = Lx/dx;
Ny = Ly/dy;

% Time window
t = linspace(0, 200, 2000);
Nt = length(t);
dt = t(2)-t(1);

T = zeros(Nt, Nx, Ny);

% Boundary conditions
T(:, :, 1) = 100;
T(:, :, Ny) = 100;
T(:, 1, :) = 100;
T(:, Nx, :) = 100;

T(:, round(Nx/4):round(3*Nx/4), round(Ny/4)) = 100;
T(:, round(Nx/4):round(3*Nx/4), round(3*Ny/4)) = 100;
T(:, round(Nx/4), round(Ny/4):round(3*Ny/4)) = 100;
T(:, round(3*Nx/4), round(Ny/4):round(3*Ny/4)) = 100;
iteration = 0;
% while iteration <= 100000
%     
%     if mod(iteration, 100) == 0
%         imagesc(T);
%         title(sprintf("Iteration = %d", iteration));
%         colorbar
%         drawnow
%         
%     end
%     
%     Lu = del2(T);
%     T(2:Nx-1, 2:Ny-1) = T(2:Nx-1, 2:Ny-1) + Lu(2:Nx-1, 2:Ny-1);
%     
%     iteration = iteration + 1;
%     
% end

for n = 1:Nt
    for i = 2:Nx-1
        for j = 2:Ny-1
            dTx = (T(n, i+1, j) - 2*T(n, i, j) + T(n, i-1, j))/dx^2;
            dTy = (T(n, i, j+1) - 2*T(n, i, j) + T(n, i, j-1))/dy^2;
            T(n+1, i, j) = T(n, i, j) + (dt*k/p/cp)*(dTx + dTy);
        end
    end
    T(:, round(Nx/4):round(3*Nx/4), round(Ny/4)) = 100;
    T(:, round(Nx/4):round(3*Nx/4), round(3*Ny/4)) = 100;
    if mod(n, 10) == 0
        imagesc(squeeze(T(n,:,:)));
        title(sprintf("t = %.2f", t(n)));
        colorbar
        drawnow
        
    end
end
        

