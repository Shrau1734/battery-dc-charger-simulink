function [V_out, I_out, P_out, Status, Fault] = DC_Charger_Block(V_bat, I_bat, Mode, T_charger)
% DC_Charger_Block - DC Charger Block for Battery Equivalent Circuit Simulation
%
% This MATLAB Function block implements a configurable DC charger for use in
% Simulink battery simulation models. It supports multiple charging modes
% (OFF, CV, CC, CC-CV) with fault detection and protection.
%
% INPUTS:
%   V_bat       - Battery voltage (V) [scalar]
%   I_bat       - Battery current (A) [scalar]  
%   Mode        - Charging mode command [0=OFF, 1=CV, 2=CC, 3=CC-CV]
%   T_charger   - Charger temperature (°C) [scalar]
%
% OUTPUTS:
%   V_out       - Charger output voltage (V)
%   I_out       - Charger output current (A)
%   P_out       - Charger output power (W)
%   Status      - Charger status [0=OFF, 1=ACTIVE, 2=FAULT]
%   Fault       - Fault code [0=OK, 1=OV, 2=UV, 3=OC, 4=OT]
%
% Usage in Simulink: Add this as a MATLAB Function block and connect signals

    % Persistent variables to store configuration (loaded once)
    persistent ChargerConfig
    
    % Initialize configuration on first call
    if isempty(ChargerConfig)
        % Default Configuration Parameters
        ChargerConfig.NominalVoltage = 400;
        ChargerConfig.NominalCurrent = 50;
        ChargerConfig.NominalPower = 20000;
        ChargerConfig.V_max = 420;
        ChargerConfig.V_min = 350;
        ChargerConfig.I_max = 60;
        ChargerConfig.I_min = 0;
        ChargerConfig.Efficiency = 0.95;
        ChargerConfig.StandbyPower = 50;
        ChargerConfig.InternalResistance = 0.5;
        ChargerConfig.tau_voltage = 0.01;
        ChargerConfig.tau_current = 0.005;
        ChargerConfig.OperatingMode = 3;
        ChargerConfig.CC_Current = 50;
        ChargerConfig.CV_Voltage = 420;
        ChargerConfig.CV_TransitionCurrent = 5;
        ChargerConfig.SampleTime = 0.001;
        ChargerConfig.OverVoltageLimit = 450;
        ChargerConfig.UnderVoltageLimit = 300;
        ChargerConfig.OverCurrentLimit = 70;
        ChargerConfig.OverTemperatureLimit = 80;
    end

    % Initialize outputs
    V_out = 0;
    I_out = 0;
    P_out = 0;
    Status = 0;  % OFF
    Fault = 0;   % OK

    % =====================================================================
    % SECTION 1: FAULT DETECTION AND PROTECTION
    % =====================================================================
    
    % Check battery voltage limits
    if V_bat > ChargerConfig.OverVoltageLimit
        Fault = 1;  % Over-voltage fault
        Status = 2; % FAULT state
        return;
    end
    
    if V_bat < ChargerConfig.UnderVoltageLimit
        Fault = 2;  % Under-voltage fault
        Status = 2; % FAULT state
        return;
    end
    
    % Check charger temperature
    if T_charger > ChargerConfig.OverTemperatureLimit
        Fault = 4;  % Over-temperature fault
        Status = 2; % FAULT state
        return;
    end

    % =====================================================================
    % SECTION 2: OPERATING MODES
    % =====================================================================
    
    switch Mode
        
        case 0  % OFF Mode - Charger disabled
            V_out = 0;
            I_out = 0;
            Status = 0;  % OFF
            Fault = 0;   % No fault
            
        case 1  % CV Mode - Constant Voltage (Bulk Charging Complete)
            V_out = ChargerConfig.CV_Voltage;
            % Calculate current based on battery voltage and charger impedance
            I_out = (V_out - V_bat) / ChargerConfig.InternalResistance;
            % Limit current to safe operating range
            I_out = max(0, min(I_out, ChargerConfig.I_max));
            Status = 1;  % ACTIVE
            
        case 2  % CC Mode - Constant Current (Bulk Charging)
            I_out = ChargerConfig.CC_Current;
            % Calculate voltage needed to deliver desired current
            V_out = V_bat + I_out * ChargerConfig.InternalResistance;
            % Respect maximum voltage limit
            V_out = min(V_out, ChargerConfig.V_max);
            Status = 1;  % ACTIVE
            
        case 3  % CC-CV Mode - Constant Current then Constant Voltage (Recommended)
            % Transition from CC to CV when current drops below threshold
            if I_bat < ChargerConfig.CV_TransitionCurrent
                % Phase 2: Constant Voltage (Absorption/Float)
                V_out = ChargerConfig.CV_Voltage;
                I_out = (V_out - V_bat) / ChargerConfig.InternalResistance;
                I_out = max(0, min(I_out, ChargerConfig.I_max));
            else
                % Phase 1: Constant Current (Bulk)
                I_out = ChargerConfig.CC_Current;
                V_out = V_bat + I_out * ChargerConfig.InternalResistance;
                V_out = min(V_out, ChargerConfig.V_max);
            end
            Status = 1;  % ACTIVE
            
        otherwise  % Unknown mode - default to OFF
            V_out = 0;
            I_out = 0;
            Status = 0;
            Fault = 0;
    end

    % =====================================================================
    % SECTION 3: OVER-CURRENT PROTECTION
    % =====================================================================
    
    if I_out > ChargerConfig.OverCurrentLimit
        Fault = 3;  % Over-current fault
        I_out = 0;  % Disable output
        V_out = 0;
        Status = 2; % FAULT state
        return;
    end

    % =====================================================================
    % SECTION 4: POWER CALCULATION
    % =====================================================================
    
    % Calculate actual power delivered to battery (including losses)
    P_out = V_out * I_out * ChargerConfig.Efficiency;
    
    % Add standby losses when off
    if Status == 0
        P_out = ChargerConfig.StandbyPower;
    end

end
