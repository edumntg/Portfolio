clc, clear all, close all


% Circle Radius
R = 1;

pi_val = 0;
N = 1e6;

thetas = 0:1e-3:2*pi;

xc = R.*cos(thetas);
yc = R.*sin(thetas);

figure
plot(xc, yc, 'r', 'linewidth', 2);
hold on

n = 0;
n_inside = 0;
for i = 1:N
    x = -R + rand()*2*R;
    y = -R + rand()*2*R;
    
    color = 'b.';
    
    % Check if it is inside circle
    if x^2 + y^2 <= R^2
        n_inside = n_inside + 1;
        color = 'r.';
    end
    
    plot(x, y, color)
    pause(1e-6)
    n = n + 1;
    title(sprintf("pi = %.4f", 4*n_inside/n));

end



