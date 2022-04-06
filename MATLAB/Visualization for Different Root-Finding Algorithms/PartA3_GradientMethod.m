clc, clear all, close all

%% test gradient method

%% Start gradient method

tol = 1e-6;

syms x y
v(x,y) = 100*(y-x^2)^2 + (1-x)^2;

maxIter = 1000;
tol = 1e-6;

clear x y
x = [-3/4;1];
d(1:2,1) = [1;1];
k = 1;

% Calculate gradient at point k

G = [2*x(1,k) - 400*x(1,k)*(-x(1,k)^2 + x(2,k)) - 2;
    -200*x(1,k)^2 + 200*x(2,k)];

alpha = 0.5;

%% For armijo
gamma = 1e-7;
delta = 0.9;

while norm(G) > tol
    
    d(:, k) = -G;
    j = 1;
    k2 = 1;
    while(j > 0)
        if f(x(1,k)+ alpha*d(1,k),x(2,k) + alpha*d(2,k)) <= f(x(1,k), x(2,k)) + gamma*alpha*G'*d(:,k)
            j = 0;
        else
            alpha= alpha*delta;
        end
        k2 = k2 + 1;
    end
    
    x_new = x(:,k) + alpha*d(:,k);
    x(:,k+1) = x_new;
    
    G = [2*x(1,k+1) - 400*x(1,k+1)*(-x(1,k+1)^2 + x(2,k+1)) - 2;
    -200*x(1,k+1)^2 + 200*x(2,k+1)];

    k = k + 1;
end

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
title('Cost for Gradient Method')

function ret = f(x,y)
    ret = 100*(y-x^2)^2 + (1-x)^2;
end