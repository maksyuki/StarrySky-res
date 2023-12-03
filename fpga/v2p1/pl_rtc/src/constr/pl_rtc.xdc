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
set_property port_width 4 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {u_rtc_ctrl/state_0[0]} {u_rtc_ctrl/state_0[1]} {u_rtc_ctrl/state_0[2]} {u_rtc_ctrl/state_0[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 8 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {u_rtc_ctrl/second[0]} {u_rtc_ctrl/second[1]} {u_rtc_ctrl/second[2]} {u_rtc_ctrl/second[3]} {u_rtc_ctrl/second[4]} {u_rtc_ctrl/second[5]} {u_rtc_ctrl/second[6]} {u_rtc_ctrl/second[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 8 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {u_rtc_ctrl/minute[0]} {u_rtc_ctrl/minute[1]} {u_rtc_ctrl/minute[2]} {u_rtc_ctrl/minute[3]} {u_rtc_ctrl/minute[4]} {u_rtc_ctrl/minute[5]} {u_rtc_ctrl/minute[6]} {u_rtc_ctrl/minute[7]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 13 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {u_rtc_ctrl/cnt_wait[0]} {u_rtc_ctrl/cnt_wait[1]} {u_rtc_ctrl/cnt_wait[2]} {u_rtc_ctrl/cnt_wait[3]} {u_rtc_ctrl/cnt_wait[4]} {u_rtc_ctrl/cnt_wait[5]} {u_rtc_ctrl/cnt_wait[6]} {u_rtc_ctrl/cnt_wait[7]} {u_rtc_ctrl/cnt_wait[8]} {u_rtc_ctrl/cnt_wait[9]} {u_rtc_ctrl/cnt_wait[10]} {u_rtc_ctrl/cnt_wait[11]} {u_rtc_ctrl/cnt_wait[12]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 8 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {u_rtc_ctrl/hour[0]} {u_rtc_ctrl/hour[1]} {u_rtc_ctrl/hour[2]} {u_rtc_ctrl/hour[3]} {u_rtc_ctrl/hour[4]} {u_rtc_ctrl/hour[5]} {u_rtc_ctrl/hour[6]} {u_rtc_ctrl/hour[7]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_IBUF_BUFG]
