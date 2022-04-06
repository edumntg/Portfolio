clc, clear all, close all

km = 237; % Aluminum (W/(mK))
p = 2.7; % g/cm^3 
p = p /1000 *100^3; % convert to kg/m^3
cp = 910; % aluminum (J/(kg*K))

qv = 20; % rate at which energy is generated per unit volume (W/m^3)

% Size of box
Lx = 1;
Ly = 1;
Lz = 1;

Nx = 20;
Ny = 20;
Nz = 20;

dx = Lx/Nx;
dy = Ly/Ny;
dz = Lz/Nz;

tspan = linspace(0, 3600, 3600);
Nt = length(tspan);
dt = tspan(2)-tspan(1);
T = zeros(Nt, Nx, Ny, Nz);

% Define boundary conditions
% T(:, :, :, Nz) = 600; % Kelvin
% T(:, :, Ny, :) = 373;
% T(:, 7:15, 1, 7:15) = 600;
T(:, :, :, Nz) = 100;
for n = 1:Nt-1
    for i = 2:Nx-1
        for j = 2:Ny-1
            for k = 2:Nz-1
                dTx = (T(n, i+1, j, k) - 2*T(n, i, j, k) + T(n, i-1, j, k))/dx^2;
                dTy = (T(n, i, j+1,k) - 2*T(n, i, j, k) + T(n, i, j-1, k))/dy^2;
                dTz = (T(n, i, j, k+1) - 2*T(n, i, j, k) + T(n, i, j, k-1))/dz^2;
                
                T(n+1, i, j, k) = (dt*km/p/cp)*(dTx + dTy + dTz + qv/km) + T(n, i, j, k);
            end
        end
    end
%     T(:, :, :, Nz) = 373; % Kelvin
%     T(:, :, Ny, :) = 373;
%     T(:, 7:15, 1, 7:15) = 600;
end

[X, Y, Z] = meshgrid(linspace(0, Lx, Nx), linspace(0, Ly, Ny), linspace(0, Lz, Nz));

figure
t = 0;
for n = 1:length(tspan)
    if mod(n, 10) == 0
        clf
        slice(X, Y, Z, squeeze(T(n,:,:,:)), linspace(0, Ly, Ny), linspace(0, Ly, Ny), linspace(0, Ly, Ny))
        shading interp
        view(3)
        colorbar()
        title(sprintf('Temperature at t = %.2f s', t));
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        
    end
    t = t + dt;
end
