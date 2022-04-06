clc, clear all, close all

%% Vincent Optimization Problem

% First, load data

DATA = xlsread('MOL_TOU_inc_Price.xlsx', 'Eduardo');

% Specify some data
Cdem = 6980
ncha = 0.9
ndch = 0.9
Pcha_max = 250
Pdch_max = 250

Ppeak_ini = 5412.15
SOC_max = 0.9
SOC_min = 0.1
SOC_ini = 0.5
SOC_fin = 0.5

%% FIRST, RUN FOR THE FIRST DAY. (26 first rows of data)

% From the Excel file, the data for the first day corresponds to the first
% 26 rows
DATA_TEST = DATA(1:26, :);
Pload_vector = DATA_TEST(:,2);

n = size(DATA_TEST, 1) % how many steps 

% Vars are defined as

SOC_old = SOC_ini;

% Define which variables are integers (binary variables)
IntCon = [4 6];

% Define bounds
lb = [-Inf;-Inf;-Inf;0;-Pdch_max;0;-Pcha_max;SOC_min];
ub = [Inf;Inf;Inf;1;Pdch_max;1;Pcha_max;SOC_max];
options = gaoptimset('Display', 'off', 'TolFun', 1e-10, 'Generations', 40000);
for t = 1:n
    
    [x,fval,exitflag] = ga({@Objective, Cdem}, 8,[],[],[],[],lb, ub, {@NonLin, t, Pload_vector, Ppeak_ini, ndch, ncha, SOC_ini, SOC_fin, SOC_old, n}, IntCon, options);
    
    Ppeak(t) = x(1);
    Psch(t) = x(2);
    Pgrid(t) = x(3);
    udch(t) = x(4);
    Pdch(t) = x(5);
    ucha(t) = x(6);
    Pcha(t) = x(7);
    
    SOC(t) = x(8);
    
    SOC_old = x(8);
    flags(t) = exitflag;
%     exitflag
    t
end

%% Stage 2

Ppeak_val = max(Ppeak);

% Test data
Cene(1:20) = 42;
Cene(21:25) = 85;
Cene(26:29) = 150;
Cene(30:32) = 85;
Cene(33:40) = 150;
Cene(41:46) = 85;
Cene(42:n) = 42;

%% Stage 2
SOC_old2 = SOC_ini;
for t = 1:n
    
    [x,fval,exitflag] = ga({@Objective2, Cene, Pload_vector, t}, 8,[],[],[],[],lb, ub, {@NonLin2, t, Pload_vector, Ppeak_ini, ndch, ncha, SOC_ini, SOC_fin, SOC_old2, n}, IntCon, options);
    
    Ppeak2(t) = x(1);
    Psch2(t) = x(2);
    Pgrid2(t) = x(3);
    udch2(t) = x(4);
    Pdch2(t) = x(5);
    ucha2(t) = x(6);
    Pcha2(t) = x(7);
    
    SOC2(t) = x(8);
    
    SOC_old2 = x(8);
    flags2(t) = exitflag;
%     exitflag
    t
end

figure(1)
subplot(2,1,1)
plot(Ppeak), hold on, plot(Pload_vector)
title('Stage 1');
legend('Stage 1', 'Real Data');
subplot(2,1,2)
plot(Ppeak2), hold on, plot(Pload_vector)
title('Stage 2');
legend('Stage 2', 'Real Data');

figure(2)
subplot(2,1,1)
stairs(SOC), hold on, stairs(SOC2)
legend('SOC Stage 1', 'SOC Stage 2');
subplot(2,1,2)
bar(Pcha-Pdch), hold on, bar(Pcha2-Pdch2);
legend('ESS Stage 1', 'ESS Stage 2');
