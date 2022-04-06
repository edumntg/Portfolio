%% Load Input Current Data for a UDDS Cycle
global Batt;
Data = xlsread('UDDS.csv', 'A05:B13707');
Batt.RecordingTime          = Data(:,1);
Batt.I                      = -Data(:,2);

%% Simulate the Experimental Battery
[Batt.SOC_Actual,...
 Batt.V_Actual]     = Experimental_BatteryModel(Batt.I, Batt.RecordingTime);
 
%% Define Battery Model Parameters
Current     = Batt.I;
DeltaT      = 0.1;
Cn          = 5.4 * 3600;
eta         = 1;
SOC         = 0.9;

%% Initalize Actual Model Parameters

R_plusActual    = 0.1;
R_minusActual   = 0.1;
K0              = 3;
K1              = 0.01;
K2              = 0.01;
K3              = 0.01;
K4              = 0.01;

%% Run Battery MActualodel
Batt.SOC_Actual               = [];
Batt.TerminalVoltageActual   = [];

ik = length(Current);

for k = 1 : 1 : ik
    % SOC Update
    U           = Current(k);
    CoffB3      = -(eta * DeltaT / Cn);
    SOC         = SOC + (CoffB3 * U);
    
    %% Run Updated Model
    if Current(k) >= 0
        TerminalVoltage  = K0                           ...
                         - (R_plusActual * Current (k)) ...
                         - K1/SOC                       ...
                         - K2*SOC                       ...
                         + K3*log(SOC)                  ...
                         + K4*log(1-SOC)                ;
    else 
        TerminalVoltage  = K0                           ...
                         - (R_minusActual * Current(k)) ...
                         - K1/SOC                       ...
                         - K2*SOC                       ...
                         + K3*log(SOC)                  ...
                         + K4*log(1-SOC)                ; 
    end
    Batt.TerminalVoltageActual   = [Batt.TerminalVoltageActual; TerminalVoltage];
    Batt.SOC_Actual              = [Batt.SOC_Actual; SOC];
end


%% Ploting
figure
subplot(3,1,1)
plot(Batt.RecordingTime/60, Batt.SOC_Actual * 100);
xlabel('Time [min]')
ylabel('SOC [%]')
grid minor

subplot(3,1,2)
plot(Batt.RecordingTime/60, Batt.V_Actual)
xlabel ('Time')
ylabel('TerminalVoltage [V]')


subplot(3,1,3)
plot(Batt.RecordingTime/60, Batt.V_Actual)
xlabel('Time [min]')
ylabel('Current [I]')
grid minor