
clc, clear all

%% Run the experimental battery section
% global Batt RecordingTime BattI SOC_Actual V_Actual;
global Batt t BattI SOC_Actual V_Actual;

Data = xlsread('UDDS.csv', 'A5:B13707');

Batt.RecordingTime          = Data(:,1);
Batt.I                      = -Data(:,2);
BattI = -Data(:,2);
t = Batt.RecordingTime
RecordingTime = Batt.RecordingTime;


%% Simulate the Experimental Battery
[Batt.SOC_Actual,...
 Batt.V_Actual]     = Experimental_BatteryModel(Batt.I, Batt.RecordingTime);

SOC_Actual = Batt.SOC_Actual;
V_Actual = Batt.V_Actual;


%% Call the GA Optimization Function 
nvars            = 7;

R0_plus_est_lb   = 0;
R0_plus_est_ub   = 0.2;

R0_minus_est_lb  = 0;
R0_minus_est_ub  = 0.2;

K0_lb            = 0;
K0_ub            = 5;

K1_lb            = 0;
K1_ub            = 1;

K2_lb            = 0;
K2_ub            = 1;

K3_lb            = 0;
K3_ub            = 1;

K4_lb            = 0;
K4_ub            = 1;

lb = [R0_plus_est_lb,...
      R0_minus_est_lb,...
      K0_lb,...
      K1_lb,...
      K2_lb,...
      K3_lb,...
      K4_lb];
   
ub = [R0_plus_est_ub,...
      R0_minus_est_ub,...
      K0_ub,...
      K1_ub,...
      K2_ub,...
      K3_ub,...
      K4_ub];
  
PopInitRange_Data      = [lb; ub];

PopulationSize_Datav = [500 1000 2000];


for pv = 1:length(PopulationSize_Datav)

	PopulationSize_Data    = PopulationSize_Datav(pv);
	Generations_Data       = 10;

	%% Variables Initialization 
	R0_plus_init         = 0.0006408;
	R0_minus_init        = 0.009884;
	K0_init              = 0.001;             
	K1_init              = 0.001;             
	K2_init              = 0.001;             
	K3_init              = 0.001;             
	K4_init              = 0.001;             

	InitialPopulation_Data  = [R0_plus_init,...
							   R0_minus_init,...
							   K0_init,...   
							   K1_init,...
							   K2_init,...
							   K3_init,...
							   K4_init];
					   
	[x,fval,exitflag,output,population,score] = Run_GA(nvars,...
													   lb,...
													   ub,...
													   PopInitRange_Data,...
													   PopulationSize_Data,...
													   Generations_Data,...
													   InitialPopulation_Data);

	%% Plot Section
	%% Main_Combined_Optimization(x);
	R_plusActual  = x(1);
	R_minusActual = x(2);
	K0            = x(3);
	K1            = x(4);
	K2            = x(5);
	K3            = x(6);
	K4            = x(7);

	[Batt.SOC_Actual_,...
	 Batt.V_Actual_]     = Experimental_BatteryModel_Optimized(Batt.I, R_plusActual, R_minusActual, K0, K1, K2, K3, K4);
    Vvector(pv, 1:length(Batt.V_Actual_)) = Batt.V_Actual_(1:end);
	% figure
	% plot(Batt.V_Actual)
	% hold on
	% plot(Batt.V_Actual2)

	% figure

end
figure
for i = 1:length(PopulationSize_Datav)
    plot(Vvector(i, 1:end));
    hold on
end
plot(Batt.V_Actual)
ylabel('Terminal Vgoltage (V)')
xlabel('Time (sec)')
legend('Optimized Model p = 500', 'Optimized Model p = 1000', 'Optimized Model p = 2000', 'Experimental Battery')
grid on
magnifyOnFigure
