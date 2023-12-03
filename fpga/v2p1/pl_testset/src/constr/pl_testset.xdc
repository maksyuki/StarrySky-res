set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS18} [get_ports clk]
set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVCMOS18} [get_ports rst_n]
set_property -dict {PACKAGE_PIN AB4 IOSTANDARD LVCMOS18} [get_ports ps2_clk]
set_property -dict {PACKAGE_PIN AB5 IOSTANDARD LVCMOS18} [get_ports ps2_data]
set_property -dict {PACKAGE_PIN Y4 IOSTANDARD LVCMOS18} [get_ports hsync]
set_property -dict {PACKAGE_PIN AA4 IOSTANDARD LVCMOS18} [get_ports vsync]
set_property -dict {PACKAGE_PIN R7 IOSTANDARD LVCMOS18} [get_ports rgb[0]]
set_property -dict {PACKAGE_PIN AB1 IOSTANDARD LVCMOS18} [get_ports rgb[1]]
set_property -dict {PACKAGE_PIN AB2 IOSTANDARD LVCMOS18} [get_ports rgb[2]]
set_property -dict {PACKAGE_PIN Y5 IOSTANDARD LVCMOS18} [get_ports rgb[3]]
set_property -dict {PACKAGE_PIN Y6 IOSTANDARD LVCMOS18} [get_ports rgb[4]]
set_property -dict {PACKAGE_PIN AB6 IOSTANDARD LVCMOS18} [get_ports rgb[5]]
set_property -dict {PACKAGE_PIN AB7 IOSTANDARD LVCMOS18} [get_ports rgb[6]]
set_property -dict {PACKAGE_PIN AA6 IOSTANDARD LVCMOS18} [get_ports rgb[7]]
set_property -dict {PACKAGE_PIN AA7 IOSTANDARD LVCMOS18} [get_ports rgb[8]]
set_property -dict {PACKAGE_PIN AB9 IOSTANDARD LVCMOS18} [get_ports rgb[9]]
set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS18} [get_ports rgb[10]]
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS18} [get_ports rgb[11]]
set_property -dict {PACKAGE_PIN AA8 IOSTANDARD LVCMOS18} [get_ports led]
set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS18} [get_ports ws2812]
set_property -dict {PACKAGE_PIN AB20 IOSTANDARD LVCMOS18}  [get_ports lcd_clk]
set_property -dict {PACKAGE_PIN AA21 IOSTANDARD LVCMOS18}  [get_ports lcd_cs]
set_property -dict {PACKAGE_PIN AB21 IOSTANDARD LVCMOS18}  [get_ports lcd_rs]
set_property -dict {PACKAGE_PIN AB19 IOSTANDARD LVCMOS18}  [get_ports lcd_data]
set_property -dict {PACKAGE_PIN AB16 IOSTANDARD LVCMOS18}  [get_ports uart_rxd]
set_property -dict {PACKAGE_PIN AA16 IOSTANDARD LVCMOS18}  [get_ports uart_txd]
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS18} [get_ports aud_scl]
set_property -dict {PACKAGE_PIN Y15 IOSTANDARD LVCMOS18} [get_ports aud_sda]
set_property -dict {PACKAGE_PIN AB12 IOSTANDARD LVCMOS18} [get_ports aud_lrc]
set_property -dict {PACKAGE_PIN Y11 IOSTANDARD LVCMOS18} [get_ports aud_bclk]
set_property -dict {PACKAGE_PIN W12 IOSTANDARD LVCMOS18} [get_ports aud_adcdat]
set_property -dict {PACKAGE_PIN Y10 IOSTANDARD LVCMOS18} [get_ports aud_mclk]
set_property -dict {PACKAGE_PIN AA12 IOSTANDARD LVCMOS18} [get_ports aud_dacdat]

create_clock -period 20.000 -name clk -waveform {0.000 10.000} [get_ports clk]