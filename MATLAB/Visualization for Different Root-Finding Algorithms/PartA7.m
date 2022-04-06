clc, clear all, close all
%% test Polak-Ribiere algorithm

%% Start algorithm

tol = 1e-6;

syms x y
v(x,y) = 100*(y-x^2)^2 + (1-x)^2;

maxIter = 1000;
tol = 1e-6;

clear x y
x = [-3/4;1];
d(1:2,1) = [-1;1];
k = 1;

% Calculate gradient at point k

G = [2*x(1,k) - 400*x(1,k)*(-x(1,k)^2 + x(2,k)) - 2;
    -200*x(1,k)^2 + 200*x(2,k)];

H = [1,0;0,1];


alpha = 0.01;

%% For armijo
gamma = 1e-10;
delta = 0.1;

while norm(G) > tol
    
    d(:, k) = -H*G;
    
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
    
    delta_k = x(:,k+1)-x(:,k);
    
    G = [2*x(1,k+1) - 400*x(1,k+1)*(-x(1,k+1)^2 + x(2,k+1)) - 2;
    -200*x(1,k+1)^2 + 200*x(2,k+1)];
    G_old = [2*x(1,k) - 400*x(1,k)*(-x(1,k)^2 + x(2,k)) - 2;
        -200*x(1,k)^2 + 200*x(2,k)];
    
    gamma_k = G - G_old;
    
    vk = (gamma_k'*H*gamma_k)^(1/2) *(delta_k/(delta_k'*gamma_k) - H*gamma_k/(gamma_k'*H*gamma_k));
    
    H = H + (delta_k*delta_k')/(delta_k'*gamma_k) - H*(gamma_k*gamma_k')*H/(gamma_k'*H*gamma_k) + vk*vk';
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
title('Cost for A7 Method')

function ret = f(x,y)
    ret = 100*(y-x^2)^2 + (1-x)^2;
end