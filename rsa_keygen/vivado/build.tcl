# build.tcl - tong hop + hien thuc + bitstream KHONG can tao project
# Chay tu thu muc rsa_keygen:   vivado -mode batch -source vivado/build.tcl
# Arty Z7-10: doi PART thanh xc7z010clg400-1
set PART xc7z020clg400-1
set OUT  vivado/out
file mkdir $OUT

read_verilog [glob rtl/*.v]
read_xdc constr/arty_z7.xdc
synth_design -top board_top -part $PART
report_utilization -hierarchical -file $OUT/util_synth_hier.rpt
opt_design
place_design
route_design
report_utilization -hierarchical -file $OUT/util_hier.rpt
report_timing_summary -file $OUT/timing.rpt
report_power -file $OUT/power.rpt
write_bitstream -force $OUT/board_top.bit
puts "XONG: $OUT/board_top.bit"
