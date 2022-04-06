clc, clear all, close all

%% PSO Algorithm

grid_size = [-50, -50
              50, 50];

N = 300; % number of particles
x = (rand(N,1)*(grid_size(2,1)-grid_size(1,1)) + grid_size(1,1));
y = (rand(N,1)*(grid_size(2,2)-grid_size(1,2)) + grid_size(1,2));

w = 0.9;
c1 = 2;
c2 = 2;

Gbest_p = rand(1,2); % global best
Gbest_o = Inf;
Pbest_o = Inf*ones(N,2);

Vmax = 0.6;
wMax = 0.9;
wMin = 0.2;

max_iters = 300;

% Initialize particles
for i = 1:N
    particle(i).v = rand(1,2);
    particle(i).pos = [x(i), y(i)];
    particle(i).pbest.pos = rand(1,2)*Vmax;
    particle(i).pbest.f = Inf;
end

Gbest.pos = zeros(1,2);
Gbest.f = Inf;

X = linspace(grid_size(1,1), grid_size(2,1), 100);
Y = linspace(grid_size(1,2), grid_size(2,2), 100);
[X, Y] = meshgrid(X,Y);
Z = 100.*(Y-X.^2).^2 + (1-X).^2;

figure
for t = 1:max_iters
    clf
    hold on
    contour(X,Y,Z,30);
    for i = 1:N
        particle(i).obj = objective(particle(i).pos);
        if particle(i).obj < particle(i).pbest.f
            particle(i).pbest.f = particle(i).obj;
            particle(i).pbest.pos = particle(i).pos;
        end
        if particle(i).obj < Gbest.f
            Gbest.f = particle(i).obj;
            Gbest.pos = particle(i).pos;
        end
    end
    
    % Update inertial
    w = wMax - t*((wMax-wMin)/max_iters);
    
    % Update velocity
    for i = 1:N
        particle(i).v = w*particle(i).v + ... % inertial
            c1 * rand(1,2) .* (particle(i).pbest.pos - particle(i).pos) + ... % cognitive
            c2 * rand(1,2) .* (Gbest.pos - particle(i).pos); % social
        
        if particle(i).v(1) > Vmax
            particle(i).v(1) = rand()*Vmax;
        end
        if particle(i).v(2) > Vmax
            particle(i).v(2) = rand()*Vmax;
        end
        if particle(i).v(1) < -Vmax
            particle(i).v(1) = -Vmax*rand();
        end
        if particle(i).v(2) < -Vmax
            particle(i).v(2) = -Vmax*rand();
        end
        
        % update position
        particle(i).pos = particle(i).pos + particle(i).v;
        
        % Check bound
        if particle(i).pos(1) > grid_size(2,1)
            particle(i).pos(1) = grid_size(2,1);
        end
        if particle(i).pos(2) > grid_size(2,2)
            particle(i).pos(2) = grid_size(2,2);
        end
        if particle(i).pos(1) < grid_size(1,1)
            particle(i).pos(1) = grid_size(1,1);
        end
        if particle(i).pos(2) < grid_size(1,2)
            particle(i).pos(2) = grid_size(1,2);
        end
        
        x(i) = particle(i).pos(1);
        y(i) = particle(i).pos(2);
        z(i) = particle(i).obj;
    end
    plot3(x,y,z, 'r.'), grid on
    xlim([grid_size(1,1), grid_size(2,1)])
    ylim([grid_size(1,2), grid_size(2,2)])
    pause(0.01)
end



function f = objective(pos)
    x = pos(1);
    y = pos(2);
    f = 100.*(y-x.^2).^2 + (1-x).^2;
end