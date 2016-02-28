create_project loopback_zedboard ./project-loopback_zedboard -part xc7z020clg484-1
set_property board_part em.avnet.com:zed:part0:1.0 [current_project]

create_bd_design "system"

set_property  ip_repo_paths  ./ip_repo [current_project]
update_ip_catalog

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
endgroup

set_property name ps7 [get_bd_cells processing_system7_0]

startgroup
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells ps7]
endgroup

startgroup
set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {142}] [get_bd_cells ps7]
endgroup

startgroup
set_property -dict [list CONFIG.PCW_USE_S_AXI_HP0 {1}] [get_bd_cells ps7]
endgroup

startgroup
create_bd_cell -type ip -vlnv zynq-axis:user:axis_loopback:1.0 axis_loopback_0
endgroup

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/ps7/M_AXI_GP0" Clk "/ps7/FCLK_CLK0 (142 MHz)" }  [get_bd_intf_pins axis_loopback_0/s00_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/axis_loopback_0/m00_axi" Clk "/ps7/FCLK_CLK0 (142 MHz)" }  [get_bd_intf_pins ps7/S_AXI_HP0]

connect_bd_net [get_bd_pins axis_loopback_0/rst_n] [get_bd_pins rst_ps7_142M/peripheral_aresetn]

make_wrapper -files [get_files ./project-loopback_zedboard/loopback_zedboard.srcs/sources_1/bd/system/system.bd] -top
add_files -norecurse ./project-loopback_zedboard/loopback_zedboard.srcs/sources_1/bd/system/hdl/system_wrapper.v

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

save_bd_design

launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

exit
