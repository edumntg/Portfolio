clc, clear all, close all

% 0.5 1 2 4 6 10
% Ki = 0;
% % 0.125 0.25 0.5 2.5 6.5
% Kp = 0.5;
% 
% sim('Model.slx');
% 
% t = y.Time;
% y = y.Data;
% e = e.Data;
% u = u.Data;
% r = r.Data;
% d = d.Data;
% 
% figure(1)
% subplot(3,1,1);
% plot(t, y), hold on
% plot(t, r), hold on
% plot(t, d), hold off
% grid minor
% xlabel('Time (s)');
% ylabel('Response Value');
% title('Plant Response');
% legend('Plant Response', 'System Input', 'System Disturbance');
% 
% subplot(3,1,2);
% plot(t, e), grid minor
% xlabel('Time (s)');
% ylabel('Error Response');
% title('Error Response');
% 
% subplot(3,1,3);
% plot(t, u), grid minor
% xlabel('Time (s)');
% ylabel('Plant Input');
% title('Plant Input');

%% By Hand

% Kpv = [6.5];
Kiv = [50];
plegend = cell(length(Kiv), 1);
for i = 1:length(Kiv)
    plegend{i} = strcat('Kp = Ki = ', num2str(Kiv(i)));
end

s = tf('s');
G = 2/(s^2 + 4*s + 3);
u = 0; % step input

tspan = 0:1e-4:60;

figure(2)
for i = 1:length(Kiv)
    Ki = Kiv(i);
    Kp = Ki;
    Gc = Kp + Ki/s;
    Gsys = feedback(Gc*G, 1);
    Gdr = feedback(G, Gc);
    
    [y,t] = step(Gsys, tspan);
    error = u - y;
    
    [y2,t2] = step(Gdr, tspan);
    
    subplot(3,1,1)
    plot(t, y), hold on
    grid minor
    legend(plegend)
    title('System Response')
    subplot(3,1,2)
    plot(t, error), hold on
    grid minor
    title('Measured Error')
    legend(plegend)
    subplot(3,1,3)
    plot(t2, y2), hold on
    title('Diturbance Rejection')
    legend(plegend)
    grid minor
end
stepinfo(Gsys)
%% Each plot separately
