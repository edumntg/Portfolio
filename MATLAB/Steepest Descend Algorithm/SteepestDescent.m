clc, clear all, close all

%% Steepest Descent algorithm
% syms x1 x2
% f(x1,x2) = (5*x1^2 + x2^2 + 4*x1*x2 - 14*x1 - 6*x2 + 20);

tol = 1e-6;

n = 1;
err = Inf;

x1 = 3;
x2 = 5;
options = optimset('display', 'off');
while err > tol
    dk = -Gf(x1(n), x2(n));
    alpha_f = @(alpha)(f(x1(n) + alpha*dk(1), x2(n) + alpha*dk(2)));
    alpha = fminunc(alpha_f, 1e-3, options);
    x1(n+1) = x1(n) + alpha*dk(1);
    x2(n+1) = x2(n) + alpha*dk(2);
    

    err = max(abs([x1(n+1);x2(n+1)] - [x1(n);x2(n)]));
    n = n + 1;
    fprintf("Iteration %d, error = %.8f\n", n, err);
end
fprintf("x1 = %.4f, x2 = %.4f\n", x1(end), x2(end));

%% Contour
[X,Y] = meshgrid(linspace(-5,5, 50), linspace(-5,5, 50));
Z = f(X,Y);
contour(X,Y,Z, 100)
hold on
scatter(x1, x2)
plot(x1, x2)

function ret = f(x1, x2)
    ret = 5.*x1.^2 + x2.^2 + 4.*x1.*x2 - 14.*x1 - 6.*x2 + 20;
end

function ret = Gf(x1,x2) % gradient
    ret = [10*x1 + 4*x2 - 14;2*x2 + 4*x1 - 6];
end