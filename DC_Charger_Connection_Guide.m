%% DC Charger Block - Connection Guide
% This document explains all the connections needed for the DC_Charger_Block
% in your Simulink model

%% =========================================================================
% CHARGER BLOCK SIGNAL CONNECTIONS
% =========================================================================

%% INPUT SIGNALS (What you connect TO the charger block)
% =========================================================================
%
% 1. V_bat (Battery Voltage Input)
%    ├─ Source: Battery Equivalent Circuit model
%    ├─ Type: Scalar signal
%    ├─ Units: Volts (V)
%    ├─ Range: 300V - 450V (based on protection limits)
%    ├─ Connection: Voltage measurement node from your battery circuit
%    └─ Purpose: Charger uses this to calculate appropriate output current
%
% 2. I_bat (Battery Current Input)
%    ├─ Source: Battery Equivalent Circuit model
%    ├─ Type: Scalar signal
%    ├─ Units: Amperes (A)
%    ├─ Range: 0A to ±70A
%    ├─ Connection: Current measurement from battery discharge/charge branch
%    └─ Purpose: Used to detect charging phase and decide CC-to-CV transition
%
% 3. Mode (Charging Mode Command)
%    ├─ Source: External command signal or logic controller
%    ├─ Type: Scalar integer signal
%    ├─ Units: Mode index (dimensionless)
%    ├─ Values: 
%    │   0 = OFF mode (charger disabled)
%    │   1 = CV mode (Constant Voltage)
%    │   2 = CC mode (Constant Current)
%    │   3 = CC-CV mode (Recommended - auto-switches between CC and CV)
%    ├─ Connection: Constant block, Switch block, or Logic controller
%    └─ Purpose: Selects the charging strategy
%
% 4. T_charger (Charger Temperature)
%    ├─ Source: Temperature sensor or thermal model
%    ├─ Type: Scalar signal
%    ├─ Units: Degrees Celsius (°C)
%    ├─ Range: 20°C to 80°C (typical operating range)
%    ├─ Connection: Temperature measurement from charger thermal model
%    └─ Purpose: Triggers over-temperature protection (limit: 80°C)
%

%% OUTPUT SIGNALS (What the charger block sends OUT)
% =========================================================================
%
% 1. V_out (Charger Output Voltage)
%    ├─ Sink: Battery equivalent circuit voltage reference
%    ├─ Type: Scalar signal
%    ├─ Units: Volts (V)
%    ├─ Range: 0V to 420V
%    ├─ Connection: To battery voltage source block (Controlled Voltage Source)
%    └─ Purpose: Drives charging voltage into battery circuit
%
% 2. I_out (Charger Output Current)
%    ├─ Sink: Battery equivalent circuit current source
%    ├─ Type: Scalar signal
%    ├─ Units: Amperes (A)
%    ├─ Range: 0A to 60A
%    ├─ Connection: To battery current source block (Controlled Current Source)
%    └─ Purpose: Defines charging current into battery
%
% 3. P_out (Charger Output Power)
%    ├─ Sink: Power monitoring/logging scope
%    ├─ Type: Scalar signal
%    ├─ Units: Watts (W)
%    ├─ Range: 0W to 20,000W
%    ├─ Connection: To Scope or To Workspace block for monitoring
%    └─ Purpose: Real-time power delivery monitoring
%
% 4. Status (Charger Status Flag)
%    ├─ Sink: Logic controller, indicator lights, or recording
%    ├─ Type: Scalar integer signal
%    ├─ Units: Status code (dimensionless)
%    ├─ Values:
%    │   0 = OFF (charger not operating)
%    │   1 = ACTIVE (charger delivering power)
%    │   2 = FAULT (protection triggered, charger disabled)
%    ├─ Connection: Display block, Logic block, or Scope
%    └─ Purpose: Indicates charger operational state
%
% 5. Fault (Fault Code)
%    ├─ Sink: Fault logging, LED indicators, or shutdown logic
%    ├─ Type: Scalar integer signal
%    ├─ Units: Fault code (dimensionless)
%    ├─ Values:
%    │   0 = OK (No fault)
%    │   1 = Over-Voltage (V_bat > 450V)
%    │   2 = Under-Voltage (V_bat < 300V)
%    │   3 = Over-Current (I_out > 70A)
%    │   4 = Over-Temperature (T_charger > 80°C)
%    ├─ Connection: Display block, Fault handler logic, or Scope
%    └─ Purpose: Detailed fault diagnostics and troubleshooting
%

%% =========================================================================
% TYPICAL SIMULINK CONNECTION DIAGRAM
% =========================================================================
%
% INPUT SOURCES:
% ==============
%
%   ┌─────────────────────────────────────────────────────┐
%   │          BATTERY EQUIVALENT CIRCUIT                 │
%   │  ┌─────────────────────────────────────────────┐   │
%   │  │                                             │   │
%   │  │  [V_battery] ──────┬─────────> VOLTAGE      │   │
%   │  │                    │          MEASUREMENT  │   │
%   │  │                    │          (V_bat)      │   │
%   │  │  [I_battery] ──────┴────┐                  │   │
%   │  │                         │                  │   │
%   │  │  [Internal Resistance]  │                  │   │
%   │  │                         │                  │   │
%   │  │  [SOC Model]            │                  │   │
%   │  │                         └──> CURRENT       │   │
%   │  │                             MEASUREMENT   │   │
%   │  │                             (I_bat)       │   │
%   │  └─────────────────────────────────────────────┘   │
%   └─────────────────────────────────────────────────────┘
%                            │
%                            ↓
%   ┌─────────────────────────────────────────────────────┐
%   │         CHARGER INPUT SIGNAL SOURCES               │
%   │                                                     │
%   │  [Constant "0"]          [V_bat measurement]       │
%   │  (for OFF mode)          (Battery voltage)         │
%   │         │                       │                  │
%   │         ↓                       ↓                  │
%   │  ┌─────────────┐        ┌──────────────┐          │
%   │  │   Mode      │        │   V_bat      │          │
%   │  │   Selector  │        │   (input 1)  │          │
%   │  └─────────────┘        └──────────────┘          │
%   │         │                                          │
%   │  [Constant "3"]          [I_bat measurement]      │
%   │  (for CC-CV mode)        (Battery current)        │
%   │         │                       │                  │
%   │         ├───────┬───────────────┤                 │
%   │         │       │               │                  │
%   │         ↓       ↓               ↓                  │
%   │  ┌──────────────────────────────────────┐         │
%   │  │  Mode | V_bat | I_bat | T_charger   │         │
%   │  │    ↓     ↓        ↓         ↓        │         │
%   │  │                                      │         │
%   │  │   DC_CHARGER_BLOCK (MATLAB Function)│         │
%   │  │                                      │         │
%   │  │    ↓        ↓         ↓       ↓       ↓       │
%   │  │  V_out | I_out | P_out | Status | Fault    │
%   │  └──────────────────────────────────────┘         │
%   │         │        │        │       │       │       │
%   └─────────┼────────┼────────┼───────┼───────┘       │
%             │        │        │       │       │       │
%             ↓        ↓        ↓       ↓       ↓       │
%   ┌────────────────────────────────────────────────┐  │
%   │      OUTPUT SIGNAL DESTINATIONS                │  │
%   │                                                 │  │
%   │  [V_out] ──> Controlled Voltage Source          │  │
%   │              (Battery charger voltage)         │  │
%   │                                                 │  │
%   │  [I_out] ──> Controlled Current Source          │  │
%   │              (Charging current into battery)   │  │
%   │                                                 │  │
%   │  [P_out] ──> Scope (Power monitoring)          │  │
%   │              To Workspace (data logging)       │  │
%   │                                                 │  │
%   │  [Status] ──> Display Block                    │  │
%   │              Logic Block (state machine)       │  │
%   │                                                 │  │
%   │  [Fault] ──> Display Block                     │  │
%   │              Fault Handler Logic               │  │
%   │              Emergency Shutdown Logic          │  │
%   │                                                 │  │
%   └────────────────────────────────────────────────┘  │
%

%% =========================================================================
% STEP-BY-STEP SIMULINK CONNECTION PROCEDURE
% =========================================================================
%
% STEP 1: Add DC_Charger_Block to Simulink Model
% ──────────────────────────────────────────────
%   a. Open your Simulink model
%   b. From Simulink Library: User-Defined Functions > MATLAB Function
%   c. Add the block to your model
%   d. Double-click and paste DC_Charger_Block.m code
%   e. Click OK (This creates input/output ports automatically)
%
% STEP 2: Connect Input 1 - Battery Voltage (V_bat)
% ──────────────────────
%   a. From Battery Equivalent Circuit voltage measurement output
%   b. Connect line to charger block "V_bat" input port (top-left)
%   c. Verify signal units: Volts
%   d. Typical range: 300-450V
%
% STEP 3: Connect Input 2 - Battery Current (I_bat)
% ───────────────────────
%   a. From Battery Equivalent Circuit current measurement output
%   b. Connect line to charger block "I_bat" input port
%   c. Verify signal units: Amperes
%   d. Typical range: -70A to +70A (positive = charging)
%
% STEP 4: Connect Input 3 - Charging Mode (Mode)
% ───────────────────────────
%   a. Add a Constant block from Simulink > Sources
%   b. Set value to desired mode:
%      • 0 = OFF
%      • 1 = CV (Constant Voltage)
%      • 2 = CC (Constant Current)
%      • 3 = CC-CV (Recommended)
%   c. Connect to charger block "Mode" input port
%   d. To switch modes dynamically:
%      - Use a Switch block or Stateflow chart
%      - Connect mode selector logic
%
% STEP 5: Connect Input 4 - Charger Temperature (T_charger)
% ──────────────────────────────────
%   a. If you have a thermal model: Connect temperature output
%   b. If not available: Use Constant block with typical value (e.g., 25°C)
%   c. Connect to charger block "T_charger" input port
%   d. Over-temperature fault triggers at 80°C
%
% STEP 6: Connect Output 1 - Charger Voltage (V_out)
% ──────────────────────────
%   a. To Battery Equivalent Circuit:
%      - Add "Controlled Voltage Source" block (Simulink > Power Systems)
%      - Connect charger V_out to voltage reference input
%      - Or use a dependent voltage source in circuit simulator
%   b. Alternative: Connect to Scope for monitoring
%   c. Typical range: 0-420V
%
% STEP 7: Connect Output 2 - Charger Current (I_out)
% ──────────────────────────
%   a. To Battery Equivalent Circuit:
%      - Add "Controlled Current Source" block
%      - Connect charger I_out to current reference input
%      - This current flows INTO the battery
%   b. Alternative: Connect to Scope for monitoring
%   c. Typical range: 0-60A
%
% STEP 8: Connect Output 3 - Power (P_out) [Optional]
% ────────────────────────────────
%   a. Add Scope block (Simulink > Sinks > Scope)
%   b. Connect charger P_out signal
%   c. Useful for monitoring power delivery
%   d. Typical range: 0-20,000W
%
% STEP 9: Connect Output 4 - Status (Status) [Optional]
% ────────────────────────────────
%   a. Add Display block to see status in real-time
%   b. Or add to Scope with other signals
%   c. Values: 0 (OFF), 1 (ACTIVE), 2 (FAULT)
%   d. Use in logic controller for state transitions
%
% STEP 10: Connect Output 5 - Fault Code (Fault) [Optional]
% ──────────────────────────
%   a. Add Display block for fault diagnostics
%   b. Connect to fault handling logic
%   c. Fault values:
%      - 0: OK
%      - 1: Over-Voltage
%      - 2: Under-Voltage
%      - 3: Over-Current
%      - 4: Over-Temperature
%

%% =========================================================================
% EXAMPLE CONNECTION FOR BATTERY CHARGING SIMULATION
% =========================================================================
%
% Model Structure:
% ────────────────
%
%   ┌──────────────────────┐
%   │  Mode Command        │
%   │  (Constant = 3)      │  ← Set to mode 3 for CC-CV charging
%   └──────┬───────────────┘
%          │
%   ┌──────────────────────┐
%   │  Temperature Source  │
%   │  (Constant = 25°C)   │  ← Assume room temperature
%   └──────┬───────────────┘
%          │
%   ┌──────────────────────────────────────────────┐
%   │       BATTERY CIRCUIT                        │
%   │  ┌────────────────────────────────────────┐ │
%   │  │ Voltage Source │ Internal R │ Capacity │ │
%   │  │                │            │          │ │
%   │  │ +──────────────┬────────────┴──────┬─ │ │
%   │  │ │ Vmeas        │ Imeas             │  │ │
%   │  │ ↓              ↓                   │  │ │
%   │  └────────────────────────────────────┘  │
%   └─────────────────────────────────────────┘
%         │        │
%         │        └──── [I_bat] ──→ DC_CHARGER_BLOCK Input 2
%         │
%         └──────────── [V_bat] ──→ DC_CHARGER_BLOCK Input 1
%
%                        ↓
%
%   ┌──────────────────────────────────────────────┐
%   │      DC_CHARGER_BLOCK                        │
%   │  (MATLAB Function in Simulink)               │
%   │  [Mode] ──────→ │                            │
%   │  [V_bat] ──────→│  DC_Charger_Block  ──→ [V_out]
%   │  [I_bat] ──────→│                    ──→ [I_out]
%   │  [T_charger] ──→│                    ──→ [P_out]
%   │                 │                    ──→ [Status]
%   │                 └────────────────────→ [Fault]
%   └──────────────────────────────────────────────┘
%         │         │         │       │       │
%         │         │         │       │       │
%         ↓         ↓         ↓       ↓       ↓
%   [Voltage] [Current]  [Scope] [Display] [Display]
%    Source    Source   (Power)  (Status)  (Fault)
%

%% =========================================================================
% KEY CONNECTION PARAMETERS SUMMARY
% =========================================================================
%
% Input Connections:
% ──────────────────
%   Signal          │ Source                    │ Min   │ Max   │ Unit
%   ────────────────┼──────────────────────────┼───────┼───────┼─────
%   V_bat (Input 1) │ Battery voltage sensor   │ 300   │ 450   │ V
%   I_bat (Input 2) │ Battery current sensor   │ -70   │ +70   │ A
%   Mode (Input 3)  │ Control command/constant │ 0     │ 3     │ -
%   T_charger (I4)  │ Temperature sensor       │ 20    │ 80    │ °C
%
% Output Connections:
% ───────────────────
%   Signal          │ Destination               │ Min   │ Max   │ Unit
%   ────────────────┼──────────────────────────┼───────┼───────┼─────
%   V_out (Out 1)   │ Battery voltage source   │ 0     │ 420   │ V
%   I_out (Out 2)   │ Battery current source   │ 0     │ 60    │ A
%   P_out (Out 3)   │ Scope/Workspace          │ 0     │ 20000 │ W
%   Status (Out 4)  │ Logic/Display            │ 0     │ 2     │ -
%   Fault (Out 5)   │ Logic/Display            │ 0     │ 4     │ -
%

disp('DC Charger Block Connection Guide loaded successfully!');
disp('Review the connection diagrams above to properly wire your Simulink model.');
