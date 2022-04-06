function [TerminalVoltage_Optimization,...
    SOC_Optimization] = Combined_Optimization(Current, param, SOC_init)
%% Combined Model simulation using parameter guess from GA 

% Author   : Ryan Ahmed
%            Sessional Professor
%            McMaster University - Mechanical Engineering Departement.
%            E-mail : ryan.ahmed@mcmaster.ca
%
% Version  : 1.0
%
% HISTORY
% _________________________________________________________________________
%   VERSION |	 DATE    | AUTHOR           |	EVOLUTION
% _________________________________________________________________________
% 1.0       | 04/11/2013 | Ryan Ahmed       | Creation.
%___________________________________________________

%% Define Combined Model Parameters (7 Parameters)

R0_plus       = param(1);
R0_minus      = param(2);
K0            = param(3);
K1            = param(4);
K2            = param(5);
K3            = param(6);
K4            = param(7);

%% Define Model Fixed/known Parameteres
DeltaT      = 0.1;
Cn          = 5.4 * 3600;
X           = SOC_init;
eta         = 1;
%% Start Simulating the Model
SOC_Optimization               = [];
TerminalVoltage_Optimization   = [];

%% Combined Model Simulation
iCurrent   = length(Current);
SOC        = X;

for k      = 1 : 1 : iCurrent
    
  

    %% Run the Model
    % SOC Update
    U           = Current(k);
    CoffB3      = -(eta * DeltaT / Cn);
    SOC         = SOC + (CoffB3 * U);  
    
    %% Run Updated Model
    if Current(k) >= 0
        TerminalVoltage  = K0                         ...
                         - (R0_plus  * Current(k))     ...
                         - K1/SOC                     ...
                         - K2*SOC                     ...
                         + K3*log(SOC)                ...
                         + K4*log(1-SOC)              ;
    else
        TerminalVoltage  = K0                         ...
                         - (R0_minus  * Current(k))    ...
                         - K1/SOC                     ...
                         - K2*SOC                     ...
                         + K3*log(SOC)                ...
                         + K4*log(1-SOC)              ;
    
    end
    
    if ~isnan(TerminalVoltage) && isreal(TerminalVoltage)
        TerminalVoltage_Optimization = [TerminalVoltage_Optimization; TerminalVoltage];
    else
        TerminalVoltage_Optimization = [TerminalVoltage_Optimization; 10000000000000];
    end
    SOC_Optimization               = [SOC_Optimization; SOC];
    
end



