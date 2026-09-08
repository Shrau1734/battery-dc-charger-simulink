%% DC Charger Configuration Parameters
% This script defines the configuration parameters for the DC Charger Block
% used in battery equivalent circuit simulation

clear all; clc;

%% Charger Specifications
% Nominal Parameters
ChargerConfig.NominalVoltage = 400;           % Output voltage (V)
ChargerConfig.NominalCurrent = 50;            % Maximum output current (A)
ChargerConfig.NominalPower = 20000;           % Nominal power rating (W)

%% Charger Control Parameters
% Voltage and Current Limits
ChargerConfig.V_max = 420;                    % Maximum output voltage (V)
ChargerConfig.V_min = 350;                    % Minimum output voltage (V)
ChargerConfig.I_max = 60;                     % Maximum charging current (A)
ChargerConfig.I_min = 0;                      % Minimum charging current (A)

%% Charger Efficiency and Losses
ChargerConfig.Efficiency = 0.95;              % Charger efficiency (0-1)
ChargerConfig.StandbyPower = 50;              % Standby power loss (W)
ChargerConfig.InternalResistance = 0.5;       % Internal resistance (Ohm)

%% Charger Response Time Constants
ChargerConfig.tau_voltage = 0.01;             % Voltage response time constant (s)
ChargerConfig.tau_current = 0.005;            % Current response time constant (s)

%% Operating Modes
% Mode 1: OFF (0) - Charger disabled
% Mode 2: CV (1) - Constant Voltage mode
% Mode 3: CC (2) - Constant Current mode
% Mode 4: CC-CV (3) - Constant Current then Constant Voltage mode
ChargerConfig.OperatingMode = 3;              % Default: CC-CV mode

%% CC-CV Charging Strategy Parameters
ChargerConfig.CC_Current = 50;                % Constant current value (A)
ChargerConfig.CV_Voltage = 420;               % Constant voltage target (V)
ChargerConfig.CV_TransitionCurrent = 5;       % Transition current threshold (A)

%% Communication and Control
ChargerConfig.SampleTime = 0.001;             % Simulation sample time (s)
ChargerConfig.EnableControl = true;           % Enable external control signals
ChargerConfig.FaultDetection = true;          % Enable fault detection

%% Faults and Protection
ChargerConfig.OverVoltageLimit = 450;         % Over-voltage protection (V)
ChargerConfig.UnderVoltageLimit = 300;        % Under-voltage protection (V)
ChargerConfig.OverCurrentLimit = 70;          % Over-current protection (A)
ChargerConfig.OverTemperatureLimit = 80;      % Over-temperature limit (°C)

%% Display Configuration
disp('========== DC CHARGER CONFIGURATION ==========');
fprintf('Nominal Voltage: %g V\n', ChargerConfig.NominalVoltage);
fprintf('Nominal Current: %g A\n', ChargerConfig.NominalCurrent);
fprintf('Nominal Power: %g W\n', ChargerConfig.NominalPower);
fprintf('Efficiency: %g %%\n', ChargerConfig.Efficiency * 100);
fprintf('Operating Mode: %g (0=OFF, 1=CV, 2=CC, 3=CC-CV)\n', ChargerConfig.OperatingMode);
fprintf('============================================\n');

%% Save Configuration to workspace
save('ChargerConfig.mat', 'ChargerConfig');
disp('Configuration saved to ChargerConfig.mat');
