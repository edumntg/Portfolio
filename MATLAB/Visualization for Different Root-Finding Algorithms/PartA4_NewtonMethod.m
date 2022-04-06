clc, clear all, close all

%% Without Armijo

syms x y
v(x,y) = 100*(y-x^2)^2 + (1-x)^2;
clear x y

x = [-3/4;1];

k = 1;

tol = 1e-6;
err = Inf;

G = [2*x(1,k) - 400*x(1,k)*(-x(1,k)^2 + x(2,k)) - 2;
    -200*x(1,k)^2 + 200*x(2,k)];

H = [(1200*x(1,k)^2 -400*x(2,k)+2), -400*x(1,k);
    -400*x(1,k), 200];

%% WITHOUT ARMIJO
while err > tol
 
    
    x(:,k+1) = x(:,k) - inv(H)*G;
    
    err = max(abs(x(:,k+1) - x(:,k)));
    
    k = k + 1;

    G = [2*x(1,k) - 400*x(1,k)*(-x(1,k)^2 + x(2,k)) - 2;
        -200*x(1,k)^2 + 200*x(2,k)];

    H = [(1200*x(1,k)^2 -400*x(2,k) + 2), -400*x(1,k);
        -400*x(1,k), 200];
end

sol_noarmijo = x(:, end);
iter_noarmijo = k;

%% PLOT %%
figure
ezcontour(v, [-5 5 -5 5]), axis equal
hold on

% Because some methods gives too many points, we will plot just some points
% and not all of them
span = 2:k;
if k > 100 % To many points!
    span = 2:20:k-1;
end
for i = span
    plot([x(1,i-1), x(1,i)], [x(2,i-1), x(2, i)], 'ko-')
end
% Plot last point
plot([x(1,end-1), x(1,end)], [x(2,end-1), x(2,end)], 'ko-')

% Plot the optimal point
plot(1, 1, 'ro-', 'linewidth', 4);
%% 

%% PLOT COST

figure
plot(1:k, log((x(1,:) - 1).^2 + (x(2,:) - 1).^2))
xlabel('K');
ylabel('Jk');
title('Cost for Newton Method without Armijo')


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% WITH ARMIJO
%% For armijo
gamma = 1e-3;
delta = 0.3;
alpha = 0.01;
d = -G;

k = 1;
x = [-3/4;1]; % initial

G = [2*x(1,k) - 400*x(1,k)*(-x(1,k)^2 + x(2,k)) - 2;
    -200*x(1,k)^2 + 200*x(2,k)];

H = [(1200*x(1,k)^2 -400*x(2,k)+2), -400*x(1,k);
    -400*x(1,k), 200];

err = Inf;
while err > tol
    
    d(:,k) = -G;
    
    j = 1;
    k2 = 1;
    while(j > 0)
        if f(x(1,k)+ alpha*d(1,k),x(2,k) + alpha*d(2,k)) <= f(x(1,k), x(2,k)) + gamma*alpha*G'*d(:,k)
            j = 0;
        else
            alpha = alpha*delta;
        end
        k2 = k2 + 1;
    end
    
    x(:,k+1) = x(:,k) - alpha*inv(H)*G;
    
    err = max(abs(x(:,k+1) - x(:,k)));
    
    k = k + 1;

    G = [2*x(1,k) - 400*x(1,k)*(-x(1,k)^2 + x(2,k)) - 2;
        -200*x(1,k)^2 + 200*x(2,k)];

    H = [(1200*x(1,k)^2 -400*x(2,k) + 2), -400*x(1,k);
        -400*x(1,k), 200];
end

sol_armijo = x(:,end);
iter_armijo = k;

%% PLOT %%
figure
ezcontour(v, [-5 5 -5 5]), axis equal
hold on

% Because some methods gives too many points, we will plot just some points
% and not all of them
span = 2:k;
if k > 100 % To many points!
    span = 2:20:k-1;
end
for i = span
    plot([x(1,i-1), x(1,i)], [x(2,i-1), x(2, i)], 'ko-')
end
% Plot last point
plot([x(1,end-1), x(1,end)], [x(2,end-1), x(2,end)], 'ko-')

% Plot the optimal point
plot(1, 1, 'ro-', 'linewidth', 4);
%% 

%% PLOT COST

figure
plot(1:k, log((x(1,:) - 1).^2 + (x(2,:) - 1).^2))
xlabel('K');
ylabel('Jk');
title('Cost for Newton Method with Armijo')

function ret = f(x,y)
    ret = 100*(y-x^2)^2 + (1-x)^2;
end