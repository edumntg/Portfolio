%% Motor DC

f = 60;
w = 2*pi*f;

Jr = 3.5e-4;
Ji = 1.5e-3;
L = 3e-5;
R = 8;
Br = 3e-4;
Bi = 2.5e-3;
Kt = 0.2;
Ke = 0.021 *60/w; % to V/rad/sec

%% No Load

J = Ji;
B = Bi;
Tx = 0.05; % some load torque

t = MotorData.Time;
i = MotorData.Data(:, 1);
ws = MotorData.Data(:, 2);
theta = MotorData.Data(:, 3);
T = MotorData.Data(:, 4);

figure(1)
plot(t, i, 'linewidth', 2), grid on
title('Motor Current');
figure(2)
plot(t, ws, 'linewidth', 2), grid on
title('Motor Speed');
figure(3)
plot(t, T), grid on
title('Motor Torque');