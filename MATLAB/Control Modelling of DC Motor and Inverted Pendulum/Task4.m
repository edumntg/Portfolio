% % clc, clear all, close all

%% Task 4

g = 9.81;
l = 2.5;
m = 0.75;
c = 0.15;

% t = tosimulink.Time;
% step = tosimulink.Data(:, 1);
% response = tosimulink.Data(:, 2);
% 
% plot(t, step, t, response, 'linewidth', 2), grid on
% title('Damped pendulum response to a pulse');
% legend('Pulse', 'Response');

figure(2)
for k = 9:10
    G = tf([1 2], [1 -3 0]);
    Gcl = k*G/(1+k*G);
    step(Gcl, 0:1e-3:2)
    hold on
end
% legend('K = 1', 'K = 2', 'K = 3', 'K = 4', 'K = 5', 'K = 6', 'K = 7'); 
legend('K = 9', 'K = 10'); 
grid minor