set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS18} [get_ports clk]
set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVCMOS18} [get_ports rst_n]
set_property -dict {PACKAGE_PIN AA8 IOSTANDARD LVCMOS18} [get_ports led]
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS18} [get_ports i2c_scl]
set_property -dict {PACKAGE_PIN Y15 IOSTANDARD LVCMOS18} [get_ports i2c_sda]

create_clock -period 20.000 -name clk -waveform {0.000 10.000} [get_ports clk]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk_IBUF_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {u_e2prom_ctrl/i2c_addr[0]} {u_e2prom_ctrl/i2c_addr[1]} {u_e2prom_ctrl/i2c_addr[2]} {u_e2prom_ctrl/i2c_addr[3]} {u_e2prom_ctrl/i2c_addr[4]} {u_e2prom_ctrl/i2c_addr[5]} {u_e2prom_ctrl/i2c_addr[6]} {u_e2prom_ctrl/i2c_addr[7]} {u_e2prom_ctrl/i2c_addr[8]} {u_e2prom_ctrl/i2c_addr[9]} {u_e2prom_ctrl/i2c_addr[10]} {u_e2prom_ctrl/i2c_addr[11]} {u_e2prom_ctrl/i2c_addr[12]} {u_e2prom_ctrl/i2c_addr[13]} {u_e2prom_ctrl/i2c_addr[14]} {u_e2prom_ctrl/i2c_addr[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 2 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {u_e2prom_ctrl/flow_cnt[0]} {u_e2prom_ctrl/flow_cnt[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 8 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {u_e2prom_ctrl/i2c_data_r[0]} {u_e2prom_ctrl/i2c_data_r[1]} {u_e2prom_ctrl/i2c_data_r[2]} {u_e2prom_ctrl/i2c_data_r[3]} {u_e2prom_ctrl/i2c_data_r[4]} {u_e2prom_ctrl/i2c_data_r[5]} {u_e2prom_ctrl/i2c_data_r[6]} {u_e2prom_ctrl/i2c_data_r[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 8 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {u_e2prom_ctrl/i2c_data_w[0]} {u_e2prom_ctrl/i2c_data_w[1]} {u_e2prom_ctrl/i2c_data_w[2]} {u_e2prom_ctrl/i2c_data_w[3]} {u_e2prom_ctrl/i2c_data_w[4]} {u_e2prom_ctrl/i2c_data_w[5]} {u_e2prom_ctrl/i2c_data_w[6]} {u_e2prom_ctrl/i2c_data_w[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list drv_clk]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list u_e2prom_ctrl/i2c_ack]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list u_e2prom_ctrl/i2c_done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list u_e2prom_ctrl/i2c_exec]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list u_e2prom_ctrl/i2c_rh_wl]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list u_e2prom_ctrl/rw_done]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list u_e2prom_ctrl/rw_res]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_IBUF_BUFG]
