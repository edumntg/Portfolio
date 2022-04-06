clc, clear all, close all

%% Question 3: Response By TF

Kiv = [0.125 0.25 0.5 2.5 6.5];
plegend = cell(length(Kiv), 1);
for i = 1:length(Kiv)
    plegend{i} = strcat('Kp = Ki = ', num2str(Kiv(i)));
end

s = tf('s');
G = 2/(s^2 + 4*s + 3);

u = 1; % step input. Set to zero for the case where there is only disturbance

tspan = 0:1e-3:60; % we will show the response for 60 seconds

figure(1)
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