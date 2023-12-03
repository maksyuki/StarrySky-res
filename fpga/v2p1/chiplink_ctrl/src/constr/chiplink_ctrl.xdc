set_property -dict {PACKAGE_PIN C20 IOSTANDARD LVCMOS18}  [get_ports {chiplink_tx_data[0]}]
set_property -dict {PACKAGE_PIN H19 IOSTANDARD LVCMOS18}  [get_ports {chiplink_tx_data[1]}]
set_property -dict {PACKAGE_PIN H20 IOSTANDARD LVCMOS18}  [get_ports {chiplink_tx_data[2]}]
set_property -dict {PACKAGE_PIN E19 IOSTANDARD LVCMOS18}  [get_ports {chiplink_tx_data[3]}]
set_property -dict {PACKAGE_PIN E20 IOSTANDARD LVCMOS18}  [get_ports {chiplink_tx_data[4]}]
set_property -dict {PACKAGE_PIN H22 IOSTANDARD LVCMOS18}  [get_ports {chiplink_tx_data[5]}]
set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS18}  [get_ports {chiplink_tx_data[6]}]
set_property -dict {PACKAGE_PIN F21 IOSTANDARD LVCMOS18}  [get_ports {chiplink_tx_data[7]}]
set_property -dict {PACKAGE_PIN F19 IOSTANDARD LVCMOS18}  [get_ports chiplink_tx_rst]
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS18}  [get_ports chiplink_tx_clk]
set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS18}  [get_ports chiplink_tx_send]
set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS18}  [get_ports {chiplink_rx_data[0]}]
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS18}  [get_ports {chiplink_rx_data[1]}]
set_property -dict {PACKAGE_PIN D17 IOSTANDARD LVCMOS18}  [get_ports {chiplink_rx_data[2]}]
set_property -dict {PACKAGE_PIN D16 IOSTANDARD LVCMOS18}  [get_ports {chiplink_rx_data[3]}]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS18}  [get_ports {chiplink_rx_data[4]}]
set_property -dict {PACKAGE_PIN F17 IOSTANDARD LVCMOS18}  [get_ports {chiplink_rx_data[5]}]
set_property -dict {PACKAGE_PIN F18 IOSTANDARD LVCMOS18}  [get_ports {chiplink_rx_data[6]}]
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS18}  [get_ports {chiplink_rx_data[7]}]
set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS18}  [get_ports chiplink_rx_rst]
set_property -dict {PACKAGE_PIN H18 IOSTANDARD LVCMOS18}  [get_ports chiplink_rx_clk]
set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS18}  [get_ports chiplink_rx_send]
set_property -dict {PACKAGE_PIN W8 IOSTANDARD LVCMOS18}  [get_ports chiplink_cpu_int]


set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets chiplink_tx_clk_IBUF]
# create_clock -period 40.000 -name chiplink_tx_clk -waveform {0.000 20.000} [get_ports {chiplink_tx_clk}]
# create_generated_clock -name chiplink_tx_clk -edges {1 2 3} -source [get_pins {design_1_i/processing_system7_0/inst/PS7_i/FCLKCLK[0]}] [get_ports chiplink_tx_clk]
create_generated_clock -name chiplink_tx_clk -source [get_pins design_1_i/chiplink_ctrl_0/clk] -divide_by 1 [get_ports chiplink_tx_clk]
# create_generated_clock -name chiplink_tx_clk -edges {1 2 3} -source [get_clocks clk_fpga_0] [get_ports chiplink_tx_clk]
set_input_delay -clock [get_clocks chiplink_tx_clk] -min -add_delay 0.680 [get_ports {chiplink_tx_data[*]}]
set_input_delay -clock [get_clocks chiplink_tx_clk] -max -add_delay 2.500 [get_ports {chiplink_tx_data[*]}]
set_input_delay -clock [get_clocks chiplink_tx_clk] -min -add_delay 0.680 [get_ports chiplink_tx_rst]
set_input_delay -clock [get_clocks chiplink_tx_clk] -max -add_delay 2.500 [get_ports chiplink_tx_rst]
set_input_delay -clock [get_clocks chiplink_tx_clk] -min -add_delay 0.680 [get_ports chiplink_tx_send]
set_input_delay -clock [get_clocks chiplink_tx_clk] -max -add_delay 2.500 [get_ports chiplink_tx_send]

create_clock -period 40.000 -name chiplink_rx_clk -waveform {0.000 20.000}
set_output_delay -clock [get_clocks chiplink_rx_clk] -min -add_delay 0.680 [get_ports {chiplink_rx_data[*]}]
set_output_delay -clock [get_clocks chiplink_rx_clk] -max -add_delay 2.500 [get_ports {chiplink_rx_data[*]}]
set_output_delay -clock [get_clocks chiplink_rx_clk] -min -add_delay 0.680 [get_ports chiplink_rx_rst]
set_output_delay -clock [get_clocks chiplink_rx_clk] -max -add_delay 2.500 [get_ports chiplink_rx_rst]
set_output_delay -clock [get_clocks chiplink_rx_clk] -min -add_delay 0.680 [get_ports chiplink_rx_send]
set_output_delay -clock [get_clocks chiplink_rx_clk] -max -add_delay 2.500 [get_ports chiplink_rx_send]




