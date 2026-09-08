%% DC Charger Block Implementation Guide
% This guide explains how to create and use the DC Charger Block in Simulink
% based on the configuration parameters

%% Step 1: Load the Configuration
% Run the DC_Charger_Config.m file to load ChargerConfig into workspace
DC_Charger_Config;  % This loads ChargerConfig.mat with all parameters

%% Step 2: Creating the Charger Block in Simulink
% 
% METHOD A: Using Simulink's Subsystem Block
% =============================================
% 1. Open Simulink
% 2. Create a new model or open existing battery model
% 3. Add a "Subsystem" block from Simulink > Ports & Subsystems
% 4. Double-click to enter the subsystem
% 5. Create the internal structure (see METHOD C below)
%
% METHOD B: Using MATLAB Function Block
% ======================================
% 1. Add "MATLAB Function" block from Simulink > User-Defined Functions
% 2. Double-click and implement the charger logic (see Section 3)
% 3. Connect battery voltage input and charging mode signal
%
% METHOD C: Using S-Function (Advanced)
% ======================================
% Create a C-MEX or MATLAB S-Function for detailed control
% (Template provided in DC_Charger_SFunction.m)

%% Step 3: Charger Block Inputs/Outputs
%
% INPUTS:
% -------
% 1. V_battery    - Battery voltage (V)          [scalar]
% 2. I_battery    - Battery current (A)          [scalar]
% 3. Mode_cmd     - Charging mode command        [scalar: 0=OFF, 1=CV, 2=CC, 3=CC-CV]
% 4. T_charger    - Charger temperature (°C)    [scalar]
%
% OUTPUTS:
% --------
% 1. V_charger    - Charger output voltage (V)   [scalar]
% 2. I_charger    - Charger output current (A)   [scalar]
% 3. P_charger    - Charger output power (W)     [scalar]
% 4. Status       - Charger status flag          [0=OFF, 1=ACTIVE, 2=FAULT]
% 5. Fault_code   - Fault diagnostic code        [0=OK, 1=OV, 2=UV, 3=OC, 4=OT]

%% Step 4: Quick Implementation - MATLAB Function Block Code
%
% Copy the following code into a MATLAB Function block:
%
% function [V_out, I_out, P_out, Status, Fault] = DC_Charger(V_bat, I_bat, Mode, T_charger)
%
%     % Load charger configuration
%     load('ChargerConfig.mat');
%     
%     % Initialize outputs
%     V_out = 0;
%     I_out = 0;
%     P_out = 0;
%     Status = 0;
%     Fault = 0;
%
%     % Fault checking
%     if V_bat > ChargerConfig.OverVoltageLimit || V_bat < ChargerConfig.UnderVoltageLimit
%         Fault = 1;  % Voltage fault
%         Status = 2; % Fault state
%         return;
%     end
%
%     if T_charger > ChargerConfig.OverTemperatureLimit
%         Fault = 4;  % Temperature fault
%         Status = 2; % Fault state
%         return;
%     end
%
%     % Operating modes
%     switch Mode
%         case 0  % OFF mode
%             V_out = 0;
%             I_out = 0;
%             Status = 0;
%
%         case 1  % Constant Voltage (CV) mode
%             V_out = ChargerConfig.CV_Voltage;
%             I_out = (V_out - V_bat) / ChargerConfig.InternalResistance;
%             I_out = max(0, min(I_out, ChargerConfig.I_max));
%             Status = 1;
%
%         case 2  % Constant Current (CC) mode
%             I_out = ChargerConfig.CC_Current;
%             V_out = V_bat + I_out * ChargerConfig.InternalResistance;
%             V_out = min(V_out, ChargerConfig.V_max);
%             Status = 1;
%
%         case 3  % CC-CV mode (Recommended)
%             if I_bat < ChargerConfig.CV_TransitionCurrent
%                 % Switch to CV mode
%                 V_out = ChargerConfig.CV_Voltage;
%                 I_out = (V_out - V_bat) / ChargerConfig.InternalResistance;
%                 I_out = max(0, min(I_out, ChargerConfig.I_max));
%             else
%                 % Stay in CC mode
%                 I_out = ChargerConfig.CC_Current;
%                 V_out = V_bat + I_out * ChargerConfig.InternalResistance;
%                 V_out = min(V_out, ChargerConfig.V_max);
%             end
%             Status = 1;
%     end
%
%     % Over-current protection
%     if I_out > ChargerConfig.OverCurrentLimit
%         Fault = 3;  % Over-current fault
%         I_out = 0;
%         Status = 2;
%         return;
%     end
%
%     % Calculate power with efficiency loss
%     P_out = V_out * I_out * ChargerConfig.Efficiency;
%
% end

%% Step 5: Creating the Simulink Block Diagram
%
% Block Diagram Structure:
% ========================
%
%     [V_battery] --|
%                   |
%     [I_battery] --|
%                   |-- [DC_Charger Block] --> [V_charger] --> [Battery Equivalent Circuit]
%                   |                       --> [I_charger]
%     [Mode_cmd]  --|                       --> [P_charger]
%                   |                       --> [Status]
%     [T_charger] --|                       --> [Fault_code]

%% Step 6: Step-by-Step Simulink Setup
%
% 1. Open Simulink
% 2. Create New Model: File > New > Model
% 3. Add the following blocks:
%    - From Simulink > Sources: Constant, Pulse Generator (for mode switching)
%    - From Simulink > Sinks: Scope (to view outputs)
%    - From Simulink > Math Operations: Add, Product, Fcn
%    - User-Defined Function (MATLAB Function block with charger logic)
%
% 4. Connect the blocks as per the diagram above
% 5. Set simulation parameters: Simulation > Model Configuration Parameters
%    - Set "Stop time" to desired simulation length (e.g., 100 seconds)
%    - Solver: ode45 (Runge-Kutta)
%
% 6. Run simulation: Click the "Run" button or press Ctrl+T

%% Step 7: Interfacing with Battery Equivalent Circuit
%
% The charger output currents should be connected to:
%  - Voltage source model of battery
%  - Internal resistance
%  - State of charge (SOC) estimator
%
% Example connection:
%
%   [DC_Charger] --I_charger--> [Battery Equivalent Circuit]
%                 --V_charger--> [Voltage Measurement]
%

%% Step 8: Configurable Parameters
%
% To change charger behavior, modify DC_Charger_Config.m:
%
% - ChargerConfig.NominalVoltage = XXX;  % Change output voltage
% - ChargerConfig.NominalCurrent = XXX;  % Change max current
% - ChargerConfig.Efficiency = XXX;      % Change efficiency
% - ChargerConfig.OperatingMode = X;     % Change default mode
%
% After editing, run DC_Charger_Config.m again before simulation

disp('DC Charger Block Implementation Guide loaded.');
disp('Follow the steps above to create your charger block in Simulink.');
