# Build a bitstream without a Vivado project.
# Usage: vivado -mode batch -source build.tcl -tclargs <out.bit> <top> <xdc> <file.v>...
set out [lindex $argv 0]
set top [lindex $argv 1]
set xdc [lindex $argv 2]

read_verilog [lrange $argv 3 end]
read_xdc $xdc

synth_design -top $top -part xc7a35tcpg236-1
opt_design
place_design
route_design
report_timing_summary -file [file rootname $out]_timing.rpt
write_bitstream -force $out
