clc, clear all, close all

% get C from A and B

DATA = xlsread('data.xlsx');
% DATA2 = [1 40 25 
%          2 45 20
%          1 38 30
%          3 50 30
%          2 48 28
%          3 55 30
%          3 53 34
%          4 55 36
%          4 58 32
%          3 40 34
%          5 55 38
%          3 48 28
%          3 45 30
%          2 55 36
%          4 60 34
%          5 60 38
%          5 60 42
%          5 65 38
%          4 50 34
%          3 58 38];

y = DATA(:, 3);
x1 = DATA(:, 1);
x2 = DATA(:, 2);

% [x, fval, exitflag] = fsolve(@(x)[...
%                                     y(1) - x1(1)*x(1) - x2(1)*x(2);
%                                     y(2) - x1(2)*x(1) - x2(2)*x(2)], [0 0])
% 
%                                 
% ys = x(1).*x1 + x(2).*x2;
% 
% X = [x1 x2];
% [b,bint,r,rint,stats] = regress(y,X);

% y = DATA(:, 3);
% x1 = DATA(:, 1);
% x2 = DATA(:, 2);
% 
% N = length(x1);
% 
% sumx1 = sum(x1);
% sumx2 = sum(x2);
% sumy = sum(y);
% 
% sumx1y = sum(x1.*y) - sumx1*sumy/N;
% sumx2y = sum(x2.*y) - sumx2*sumy/N;
% sumx1x2 = sum(x1.*x2) - sumx1*sumx2/N;
% 
% sumx22 = sum(x2.^2) - sum(x2)*sum(x2)/N;
% sumx12 = sum(x1.^2) - sum(x1)*sum(x1)/N;
% 
% b1 = (sumx22.*sumx1y - sumx1x2*sumx2y)./(sumx12*sumx22 - sumx1x2^2);
% b2 = (sumx12.*sumx2y - sumx1x2*sumx1y)./(sumx12*sumx22 - sumx1x2^2);
% 
% My = sumy/N;
% Mx1 = sumx1/N;
% Mx2 = sumx2/N;
% 
% a = My - b1*Mx1 - b2*Mx2;
% 
% ygen = a + b1.*x1 + b2.*x2;

[A, B] = meshgrid(x1, x2);

ft = fittype('a*x1 + b*log(x2)', 'coeff',{'a','b'}, 'dependent',{'c'});
opts = fitoptions('Method','NonlinearLeastSquares', 'StartPoint',[0.5,1]);
[fitresult, gof] = fit([x1(:), x2(:)], y(:), ft, opts);
a = fitresult.x1;
b = fitresult.x2;
ygen = a.*x1 + b./x2;
