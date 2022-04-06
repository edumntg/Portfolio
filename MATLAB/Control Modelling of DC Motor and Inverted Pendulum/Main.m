% clc, clear all, close all

% Kay Ben Lab

%% Task 2: 

t = fromsimulink.Time;
in_signal = fromsimulink.Data(:, 1);
response = fromsimulink.Data(:, 2);

% figure(1)
% plot(t, in_signal, t, response, 'linewidth', 1.5);
% title('Ramp Response with K = 8');
% legend('Step', 'TF Response');
% grid on

for k = 1:10
end