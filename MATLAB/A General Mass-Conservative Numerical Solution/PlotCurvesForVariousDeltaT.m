clc, clear all, close all

%% In order to see the 4 curves for each time-step, you must
%% disbale lines 1, 5-13 in MainImplicit.m


nsim = 1;
for dt = [1, 10, 30, 120]
    fprintf("Running for dt = %d...\n", dt);
    z = 40;
    dz = 1; % step in grid
    if dt  == 120
        dz = 2;
    end
    % Define the time window
    tf = 360; % 360 seconds

    % Compute number of values
    Nz = z/dz+1; % number of nodes in the grid
    Nt = tf/dt;
    
    MainImplicit;
    save(sprintf("sims%d", nsim), 'H', 'Z', 'iters');
    nsim = nsim + 1;
end
close all
figure
hold on

load sims1
plot(Z, H(:,end))

load sims2
plot(Z, H(:, end))

load sims3
plot(Z, H(:, end))

load sims4
plot(Z, H(:, end))

grid on
xlabel('DEPTH (CM)')
ylabel('PRESSURE HEAD (CM)')
legend("{\Deltat = 1}", "{\Deltat = 10}", "{\Deltat = 30}", "{\Deltat = 120}")

