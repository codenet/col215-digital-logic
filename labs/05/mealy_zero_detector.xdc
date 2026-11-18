## Basys3 constraints for mealy_top: showing the Mealy glitch
##
## Each BTNC press (debounced) is one clock edge for the FSM.
## y_out = ~x_in in S1/S2/S3, so flipping SW0 changes LD0 right away,
## with no clock edge: the output moves between clocks.

## Clock: 100 MHz, drives the debouncer
set_property PACKAGE_PIN W5 [get_ports CLK]
set_property IOSTANDARD LVCMOS33 [get_ports CLK]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports CLK]

## The debounced button is the FSM's clock. It comes from a register on CLK
## and can change at most every other CLK cycle, so time it as CLK / 2.
create_generated_clock -name step_clk -source [get_ports CLK] -divide_by 2 [get_pins db/clean_reg/Q]

## Switches, button and LED are not timed: a person flips them and looks at it
set_false_path -from [get_ports {btnC sw0 sw1}]
set_false_path -to [get_ports {led[*] SSEG_CA[*] SSEG_AN[*]}]

## BTNC: FSM clock (one press = one edge)
set_property PACKAGE_PIN U18 [get_ports btnC]
set_property IOSTANDARD LVCMOS33 [get_ports btnC]
## U18 is not a clock pin. Without the debouncer, btnC drives the FSM clock
## directly, and placement fails (Place 30-574) unless this is allowed.
## -quiet: the net btnC_IBUF only exists after synthesis.
set_property -quiet CLOCK_DEDICATED_ROUTE FALSE [get_nets -quiet btnC_IBUF]

## SW0: x_in
set_property PACKAGE_PIN V17 [get_ports sw0]
set_property IOSTANDARD LVCMOS33 [get_ports sw0]

## SW1: reset (active low: down = reset, up = run)
set_property PACKAGE_PIN V16 [get_ports sw1]
set_property IOSTANDARD LVCMOS33 [get_ports sw1]

## LEDs
## LD0: y_out, LD12-LD15: one LED per state
## (LD12 = S0, LD13 = S1, LD14 = S2, LD15 = S3). LD1-LD11 are off.
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
set_property PACKAGE_PIN E19 [get_ports {led[1]}]
set_property PACKAGE_PIN U19 [get_ports {led[2]}]
set_property PACKAGE_PIN V19 [get_ports {led[3]}]
set_property PACKAGE_PIN W18 [get_ports {led[4]}]
set_property PACKAGE_PIN U15 [get_ports {led[5]}]
set_property PACKAGE_PIN U14 [get_ports {led[6]}]
set_property PACKAGE_PIN V14 [get_ports {led[7]}]
set_property PACKAGE_PIN V13 [get_ports {led[8]}]
set_property PACKAGE_PIN V3  [get_ports {led[9]}]
set_property PACKAGE_PIN W3  [get_ports {led[10]}]
set_property PACKAGE_PIN U3  [get_ports {led[11]}]
set_property PACKAGE_PIN P3  [get_ports {led[12]}]
set_property PACKAGE_PIN N3  [get_ports {led[13]}]
set_property PACKAGE_PIN P1  [get_ports {led[14]}]
set_property PACKAGE_PIN L1  [get_ports {led[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

## 7-segment display: number of presses
set_property PACKAGE_PIN W7 [get_ports {SSEG_CA[0]}]
set_property PACKAGE_PIN W6 [get_ports {SSEG_CA[1]}]
set_property PACKAGE_PIN U8 [get_ports {SSEG_CA[2]}]
set_property PACKAGE_PIN V8 [get_ports {SSEG_CA[3]}]
set_property PACKAGE_PIN U5 [get_ports {SSEG_CA[4]}]
set_property PACKAGE_PIN V5 [get_ports {SSEG_CA[5]}]
set_property PACKAGE_PIN U7 [get_ports {SSEG_CA[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SSEG_CA[*]}]

set_property PACKAGE_PIN U2 [get_ports {SSEG_AN[0]}]
set_property PACKAGE_PIN U4 [get_ports {SSEG_AN[1]}]
set_property PACKAGE_PIN V4 [get_ports {SSEG_AN[2]}]
set_property PACKAGE_PIN W4 [get_ports {SSEG_AN[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SSEG_AN[*]}]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
