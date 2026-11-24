## Basys3 constraints for top.v (the Hack computer)

## 100 MHz clock
set_property PACKAGE_PIN W5 [get_ports CLK]
set_property IOSTANDARD LVCMOS33 [get_ports CLK]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports CLK]

## The computer's slow clock: bit 23 of the divider, 100 MHz / 2^24
create_generated_clock -name cpu_clk -source [get_ports CLK] -divide_by 16777216 [get_pins {div_reg[23]/Q}]

## The display (100 MHz) reads the shown value (cpu_clk) asynchronously
set_clock_groups -asynchronous -group sys_clk_pin -group cpu_clk

set_false_path -from [get_ports btnC]
set_false_path -to [get_ports {led[*] SSEG_CA[*] SSEG_AN[*]}]

## Reset button
set_property PACKAGE_PIN U18 [get_ports btnC]
set_property IOSTANDARD LVCMOS33 [get_ports btnC]

## LEDs
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

## 7-segment display
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
