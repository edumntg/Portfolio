function [OBJ] = Main_Combined_Optimization(Opt_Param)
%% Code Description: PhD Contribution - R01
% Lithium Polymer Battery Combined Model Simulation
% Main Optimization Function
% Author   : Ryan Ahmed
%            Sessional Professor
%            McMaster University - Mechanical Engineering Departement.
%            E-mail : ryan.ahmed@mcmaster.ca
% Version  : 1.0
% HISTORY
% _________________________________________________________________________
%   VERSION |	 DATE    | AUTHOR           |	EVOLUTION
% _________________________________________________________________________
% 1.0       | 11/04/2013 | Ryan Ahmed       | Creation.
% 2.0       | 28/11/2013 | Ryan Ahmed       | SOC-OCV Sections.
% ______________________________________________
%% Run Model with Optimization Parameters
% global RecordingTime BattI SOC_Actual V_Actual
global Batt t BattI SOC_Actual V_Actual;
format long

% if ~exist('t')
%     t   = RecordingTime; 
% end
% I   = BattI;
% SOC = SOC_Actual;
% V   = V_Actual; 
I = load('BattI.mat');
I = I.BattI;
SOC = load('SOC_Actual.mat');
SOC = SOC.SOC_Actual;
V = load('V_Actual.mat');
V = V.V_Actual;

% t = Batt.RecordingTime;
% I = Batt.I;
% SOC = Batt.SOC_Actual;
% V = Batt.V_Actual;

%% Call the Optimizer 
SOCinit = 0.9;

[TerminalVoltage_Optimization,...
 SOC_Optimization] = Combined_Optimization(I,...
                                           Opt_Param,...
                                           SOCinit);

t_ = load('RecordingTime.mat');
t_ = t_.RecordingTime;
error_VT      = (V - TerminalVoltage_Optimization);

OBJ_VT        = sum(trapz(t_, error_VT.^2));
OBJ           = OBJ_VT;
%% Plot Functions (Problem 3 Part 4)

% figure
% plot(V);
% grid on
% 
% hold all
% plot(TerminalVoltage_Optimization(1:length(TerminalVoltage_Optimization)));
% ylabel('Terminal Voltage (V)')
% xlabel('Time (sec)')
% legend('Experimental Battery', 'Optimized Model')
% grid on
% magnifyOnFigure
% 
% 
%% Calculate the Terminal Voltage RMSE
RMSE_VT  = sqrt((sum((V(1:end)) - TerminalVoltage_Optimization(1:length(TerminalVoltage_Optimization))).^2))...
    /((length(V)-1));

RMSE_SOC = sqrt((sum((SOC(1:end) - SOC_Optimization).^2))...
    /((length(SOC)-1)));

end

