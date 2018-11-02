set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports { w_btnu }];
set_property -dict { PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports { w_btnd }];
set_property -dict { PACKAGE_PIN E3  IOSTANDARD LVCMOS33} [get_ports { w_clk }];
create_clock -add -name sys_clk -period 10.00 -waveform {0 5} [get_ports {w_clk}];

set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports { w_led[0] }];
set_property -dict { PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports { w_led[1] }];
set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS33} [get_ports { w_led[2] }];
set_property -dict { PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports { w_led[3] }];
set_property -dict { PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports { w_led[4] }];
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports { w_led[5] }];
set_property -dict { PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports { w_led[6] }];
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports { w_led[7] }];
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports { w_led[8] }];
set_property -dict { PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports { w_led[9] }];
set_property -dict { PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports { w_led[10] }];
set_property -dict { PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports { w_led[11] }];
set_property -dict { PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports { w_led[12] }];
set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports { w_led[13] }];
set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports { w_led[14] }];
set_property -dict { PACKAGE_PIN V11 IOSTANDARD LVCMOS33} [get_ports { w_led[15] }];

#set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports { r_sg[6] }]; # segment a
#set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33} [get_ports { r_sg[5] }]; # segment b
#set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports { r_sg[4] }]; # segment c
#set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports { r_sg[3] }]; # segment d
#set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports { r_sg[2] }]; # segment e
#set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports { r_sg[1] }]; # segment f
#set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports { r_sg[0] }]; # segment g

#set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports { r_an[0] }];
#set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports { r_an[1] }];
#set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33} [get_ports { r_an[2] }];
#set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports { r_an[3] }];
#set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports { r_an[4] }];
#set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports { r_an[5] }];
#set_property -dict { PACKAGE_PIN K2  IOSTANDARD LVCMOS33} [get_ports { r_an[6] }];
#set_property -dict { PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports { r_an[7] }];


##VGA Connector

set_property -dict { PACKAGE_PIN A3    IOSTANDARD LVCMOS33 } [get_ports { vga_red[0] }]; #IO_L8N_T1_AD14N_35 Sch=vga_r[0]
set_property -dict { PACKAGE_PIN B4    IOSTANDARD LVCMOS33 } [get_ports { vga_red[1] }]; #IO_L7N_T1_AD6N_35 Sch=vga_r[1]
set_property -dict { PACKAGE_PIN C5    IOSTANDARD LVCMOS33 } [get_ports { vga_red[2] }]; #IO_L1N_T0_AD4N_35 Sch=vga_r[2]
set_property -dict { PACKAGE_PIN A4    IOSTANDARD LVCMOS33 } [get_ports { vga_red[3] }]; #IO_L8P_T1_AD14P_35 Sch=vga_r[3]

set_property -dict { PACKAGE_PIN C6    IOSTANDARD LVCMOS33 } [get_ports { vga_green[0] }]; #IO_L1P_T0_AD4P_35 Sch=vga_g[0]
set_property -dict { PACKAGE_PIN A5    IOSTANDARD LVCMOS33 } [get_ports { vga_green[1] }]; #IO_L3N_T0_DQS_AD5N_35 Sch=vga_g[1]
set_property -dict { PACKAGE_PIN B6    IOSTANDARD LVCMOS33 } [get_ports { vga_green[2] }]; #IO_L2N_T0_AD12N_35 Sch=vga_g[2]
set_property -dict { PACKAGE_PIN A6    IOSTANDARD LVCMOS33 } [get_ports { vga_green[3] }]; #IO_L3P_T0_DQS_AD5P_35 Sch=vga_g[3]

set_property -dict { PACKAGE_PIN B7    IOSTANDARD LVCMOS33 } [get_ports { vga_blue[0] }]; #IO_L2P_T0_AD12P_35 Sch=vga_b[0]
set_property -dict { PACKAGE_PIN C7    IOSTANDARD LVCMOS33 } [get_ports { vga_blue[1] }]; #IO_L4N_T0_35 Sch=vga_b[1]
set_property -dict { PACKAGE_PIN D7    IOSTANDARD LVCMOS33 } [get_ports { vga_blue[2] }]; #IO_L6N_T0_VREF_35 Sch=vga_b[2]
set_property -dict { PACKAGE_PIN D8    IOSTANDARD LVCMOS33 } [get_ports { vga_blue[3] }]; #IO_L4P_T0_35 Sch=vga_b[3]

set_property -dict { PACKAGE_PIN B11   IOSTANDARD LVCMOS33 } [get_ports { hsync }]; #IO_L4P_T0_15 Sch=vga_hs
set_property -dict { PACKAGE_PIN B12   IOSTANDARD LVCMOS33 } [get_ports { vsync }]; #IO_L3N_T0_DQS_AD1N_15 Sch=vga_vs


## Switches
# Switches
set_property  -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports {sw[0]}]					
set_property  -dict { PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports {sw[1]}]					
set_property  -dict { PACKAGE_PIN M13 IOSTANDARD LVCMOS33 } [get_ports {sw[2]}]					
set_property  -dict { PACKAGE_PIN R15 IOSTANDARD LVCMOS33 } [get_ports {sw[3]}]					
set_property -dict { PACKAGE_PIN R17 IOSTANDARD LVCMOS33 } [get_ports {sw[4]}]					
set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS33 } [get_ports {sw[5]}]					
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports {sw[6]}]					
set_property -dict { PACKAGE_PIN R13 IOSTANDARD LVCMOS33 } [get_ports {sw[7]}]					
set_property -dict { PACKAGE_PIN T8 IOSTANDARD LVCMOS33 } [get_ports {sw[8]}]					
set_property -dict { PACKAGE_PIN U8 IOSTANDARD LVCMOS33 } [get_ports {sw[9]}]					
set_property -dict { PACKAGE_PIN R16 IOSTANDARD LVCMOS33 } [get_ports {sw[10]}]					
set_property -dict { PACKAGE_PIN T13 IOSTANDARD LVCMOS33 } [get_ports {sw[11]}]					
