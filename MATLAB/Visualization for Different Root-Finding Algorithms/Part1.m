clc, clear all, close all

syms x y

v(x,y) = 100*(y-x^2)^2 + (1-x)^2;

dvdx(x,y) = diff(v,x);
dvdy(x,y) = diff(v,y);

sol = solve([dvdx;dvdy], [x,y])

dvdx2(x,y) = diff(v,x,2);
dvdy2(x,y) = diff(v,y,2);

dvdxdy(x,y) = diff(dvdx,y);

D = subs(dvdx2, [x,y], [sol.x, sol.y])*subs(dvdy2, [x,y], [sol.x, sol.y]) - (subs(dvdxdy, [x,y], [sol.x, sol.y]))^2

(subs(dvdxdy, [x,y], [sol.x, sol.y]))^2

% A.2
ezcontour(v, [-5 5 -5 5])

% A.3
