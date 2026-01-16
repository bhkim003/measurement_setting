############################################################################
# XEM7310 - Xilinx constraints file
#
# Pin mappings for the XEM7310.  Use this as a template and comment out 
# the pins that are not used in your design.  (By default, map will fail
# if this file contains constraints for signals not in your design).
#
# Copyright (c) 2004-2016 Opal Kelly Incorporated
############################################################################

set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS True [current_design]

############################################################################
## FrontPanel Host Interface
############################################################################
set_property PACKAGE_PIN Y19 [get_ports {okHU[0]}]
set_property PACKAGE_PIN R18 [get_ports {okHU[1]}]
set_property PACKAGE_PIN R16 [get_ports {okHU[2]}]
set_property SLEW FAST [get_ports {okHU[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {okHU[*]}]

set_property PACKAGE_PIN W19 [get_ports {okUH[0]}]
set_property PACKAGE_PIN V18 [get_ports {okUH[1]}]
set_property PACKAGE_PIN U17 [get_ports {okUH[2]}]
set_property PACKAGE_PIN W17 [get_ports {okUH[3]}]
set_property PACKAGE_PIN T19 [get_ports {okUH[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {okUH[*]}]

set_property PACKAGE_PIN AB22 [get_ports {okUHU[0]}]
set_property PACKAGE_PIN AB21 [get_ports {okUHU[1]}]
set_property PACKAGE_PIN Y22 [get_ports {okUHU[2]}]
set_property PACKAGE_PIN AA21 [get_ports {okUHU[3]}]
set_property PACKAGE_PIN AA20 [get_ports {okUHU[4]}]
set_property PACKAGE_PIN W22 [get_ports {okUHU[5]}]
set_property PACKAGE_PIN W21 [get_ports {okUHU[6]}]
set_property PACKAGE_PIN T20 [get_ports {okUHU[7]}]
set_property PACKAGE_PIN R19 [get_ports {okUHU[8]}]
set_property PACKAGE_PIN P19 [get_ports {okUHU[9]}]
set_property PACKAGE_PIN U21 [get_ports {okUHU[10]}]
set_property PACKAGE_PIN T21 [get_ports {okUHU[11]}]
set_property PACKAGE_PIN R21 [get_ports {okUHU[12]}]
set_property PACKAGE_PIN P21 [get_ports {okUHU[13]}]
set_property PACKAGE_PIN R22 [get_ports {okUHU[14]}]
set_property PACKAGE_PIN P22 [get_ports {okUHU[15]}]
set_property PACKAGE_PIN R14 [get_ports {okUHU[16]}]
set_property PACKAGE_PIN W20 [get_ports {okUHU[17]}]
set_property PACKAGE_PIN Y21 [get_ports {okUHU[18]}]
set_property PACKAGE_PIN P17 [get_ports {okUHU[19]}]
set_property PACKAGE_PIN U20 [get_ports {okUHU[20]}]
set_property PACKAGE_PIN N17 [get_ports {okUHU[21]}]
set_property PACKAGE_PIN N14 [get_ports {okUHU[22]}]
set_property PACKAGE_PIN V20 [get_ports {okUHU[23]}]
set_property PACKAGE_PIN P16 [get_ports {okUHU[24]}]
set_property PACKAGE_PIN T18 [get_ports {okUHU[25]}]
set_property PACKAGE_PIN V19 [get_ports {okUHU[26]}]
set_property PACKAGE_PIN AB20 [get_ports {okUHU[27]}]
set_property PACKAGE_PIN P15 [get_ports {okUHU[28]}]
set_property PACKAGE_PIN V22 [get_ports {okUHU[29]}]
set_property PACKAGE_PIN U18 [get_ports {okUHU[30]}]
set_property PACKAGE_PIN AB18 [get_ports {okUHU[31]}]
set_property SLEW FAST [get_ports {okUHU[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {okUHU[*]}]

set_property PACKAGE_PIN N13 [get_ports {okAA}]
set_property IOSTANDARD LVCMOS18 [get_ports {okAA}]


create_clock -name okUH0 -period 9.920 [get_ports {okUH[0]}]

set_input_delay -add_delay -max -clock [get_clocks {okUH0}]  8.000 [get_ports {okUH[*]}]
set_input_delay -add_delay -min -clock [get_clocks {okUH0}] 10.000 [get_ports {okUH[*]}]
set_multicycle_path -setup -from [get_ports {okUH[*]}] 2

set_input_delay -add_delay -max -clock [get_clocks {okUH0}]  8.000 [get_ports {okUHU[*]}]
set_input_delay -add_delay -min -clock [get_clocks {okUH0}]  2.000 [get_ports {okUHU[*]}]
set_multicycle_path -setup -from [get_ports {okUHU[*]}] 2

set_output_delay -add_delay -max -clock [get_clocks {okUH0}]  2.000 [get_ports {okHU[*]}]
set_output_delay -add_delay -min -clock [get_clocks {okUH0}]  -0.500 [get_ports {okHU[*]}]

set_output_delay -add_delay -max -clock [get_clocks {okUH0}]  2.000 [get_ports {okUHU[*]}]
set_output_delay -add_delay -min -clock [get_clocks {okUH0}]  -0.500 [get_ports {okUHU[*]}]


############################################################################
## System Clock
############################################################################
set_property IOSTANDARD LVDS_25 [get_ports {sys_clk_p}]
set_property PACKAGE_PIN W11 [get_ports {sys_clk_p}]

set_property IOSTANDARD LVDS_25 [get_ports {sys_clk_n}]
set_property PACKAGE_PIN W12 [get_ports {sys_clk_n}]

set_property DIFF_TERM FALSE [get_ports {sys_clk_p}]

# create_clock -name sys_clk -period 5 [get_ports sys_clk_p]
# set_clock_groups -asynchronous -group [get_clocks {sys_clk}] -group [get_clocks {mmcm0_clk0 okUH0}]

############################################################################
## User Reset
############################################################################
set_property PACKAGE_PIN Y18 [get_ports {reset}]
set_property IOSTANDARD LVCMOS18 [get_ports {reset}]
set_property SLEW FAST [get_ports {reset}]


set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS18 [get_ports {}]
set_property IOSTANDARD LVCMOS18 [get_ports {}]
# MC1-17 
set_property PACKAGE_PIN Y9 [get_ports {input_streaming_data_from_fpga_to_asic[29]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[29]}]
# MC1-18 
set_property PACKAGE_PIN V8 [get_ports {input_streaming_data_from_fpga_to_asic[30]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[30]}]
# MC1-19 
set_property PACKAGE_PIN R6 [get_ports {input_streaming_data_from_fpga_to_asic[31]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[31]}]
# MC1-20 
set_property PACKAGE_PIN V7 [get_ports {input_streaming_data_from_fpga_to_asic[32]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[32]}]
# MC1-21 
set_property PACKAGE_PIN T6 [get_ports {input_streaming_data_from_fpga_to_asic[33]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[33]}]
# MC1-22 
set_property PACKAGE_PIN W7 [get_ports {input_streaming_data_from_fpga_to_asic[34]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[34]}]
# MC1-23 
set_property PACKAGE_PIN U6 [get_ports {input_streaming_data_from_fpga_to_asic[35]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[35]}]
# MC1-24 
set_property PACKAGE_PIN Y8 [get_ports {input_streaming_data_from_fpga_to_asic[36]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[36]}]
# MC1-25 
set_property PACKAGE_PIN V5 [get_ports {input_streaming_data_from_fpga_to_asic[37]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[37]}]
# MC1-26 
set_property PACKAGE_PIN Y7 [get_ports {input_streaming_data_from_fpga_to_asic[38]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[38]}]
# MC1-27 
set_property PACKAGE_PIN T5 [get_ports {input_streaming_data_from_fpga_to_asic[39]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[39]}]
# MC1-28 
set_property PACKAGE_PIN W6 [get_ports {input_streaming_data_from_fpga_to_asic[40]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[40]}]
# MC1-29 
set_property PACKAGE_PIN U5 [get_ports {input_streaming_data_from_fpga_to_asic[41]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[41]}]
set_property IOSTANDARD LVCMOS18 [get_ports {}]
# MC1-31 
set_property PACKAGE_PIN AA5 [get_ports {input_streaming_data_from_fpga_to_asic[42]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[42]}]
set_property IOSTANDARD LVCMOS18 [get_ports {}]
# MC1-33 
set_property PACKAGE_PIN AB5 [get_ports {input_streaming_data_from_fpga_to_asic[43]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[43]}]
# MC1-34 
set_property PACKAGE_PIN T4 [get_ports {input_streaming_data_from_fpga_to_asic[44]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[44]}]
# MC1-37 
set_property PACKAGE_PIN AB7 [get_ports {input_streaming_data_from_fpga_to_asic[45]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[45]}]
# MC1-38 
set_property PACKAGE_PIN Y4 [get_ports {input_streaming_data_from_fpga_to_asic[46]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[46]}]
set_property IOSTANDARD LVCMOS18 [get_ports {}]
# MC1-40 
set_property PACKAGE_PIN AA4 [get_ports {input_streaming_data_from_fpga_to_asic[47]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[47]}]
set_property IOSTANDARD LVCMOS18 [get_ports {}]
set_property IOSTANDARD LVCMOS18 [get_ports {}]
set_property IOSTANDARD LVCMOS18 [get_ports {}]
set_property IOSTANDARD LVCMOS18 [get_ports {}]
# MC1-45 
set_property PACKAGE_PIN Y3 [get_ports {input_streaming_data_from_fpga_to_asic[48]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[48]}]
# MC1-46 
set_property PACKAGE_PIN AA8 [get_ports {input_streaming_data_from_fpga_to_asic[49]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[49]}]
# MC1-47 
set_property PACKAGE_PIN AA3 [get_ports {input_streaming_data_from_fpga_to_asic[50]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[50]}]
# MC1-48 
set_property PACKAGE_PIN AB8 [get_ports {input_streaming_data_from_fpga_to_asic[51]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[51]}]
# MC1-49 
set_property PACKAGE_PIN U2 [get_ports {input_streaming_data_from_fpga_to_asic[52]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[52]}]
# MC1-50 
set_property PACKAGE_PIN U3 [get_ports {input_streaming_data_from_fpga_to_asic[53]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[53]}]
# MC1-51 
set_property PACKAGE_PIN V2 [get_ports {input_streaming_data_from_fpga_to_asic[54]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[54]}]
# MC1-52 
set_property PACKAGE_PIN V3 [get_ports {input_streaming_data_from_fpga_to_asic[55]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[55]}]
# MC1-53 
set_property PACKAGE_PIN W2 [get_ports {input_streaming_data_from_fpga_to_asic[56]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[56]}]
# MC1-54 
set_property PACKAGE_PIN W1 [get_ports {input_streaming_data_from_fpga_to_asic[57]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[57]}]
# MC1-57 
set_property PACKAGE_PIN Y2 [get_ports {input_streaming_data_from_fpga_to_asic[58]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[58]}]
# MC1-58 
set_property PACKAGE_PIN Y1 [get_ports {input_streaming_data_from_fpga_to_asic[59]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[59]}]
# MC1-59 
set_property PACKAGE_PIN T1 [get_ports {input_streaming_data_from_fpga_to_asic[60]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[60]}]
# MC1-60 
set_property PACKAGE_PIN AB3 [get_ports {input_streaming_data_from_fpga_to_asic[61]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[61]}]
# MC1-61 
set_property PACKAGE_PIN U1 [get_ports {input_streaming_data_from_fpga_to_asic[62]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[62]}]
# MC1-62 
set_property PACKAGE_PIN AB2 [get_ports {input_streaming_data_from_fpga_to_asic[63]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[63]}]
# MC1-63 
set_property PACKAGE_PIN AA1 [get_ports {input_streaming_data_from_fpga_to_asic[64]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[64]}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
# MC1-65 
set_property PACKAGE_PIN AB1 [get_ports {input_streaming_data_from_fpga_to_asic[65]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[65]}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS18 [get_ports {}]
set_property IOSTANDARD LVCMOS18 [get_ports {}]
set_property IOSTANDARD LVCMOS18 [get_ports {}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS18 [get_ports {}]
set_property IOSTANDARD LVCMOS18 [get_ports {}]
set_property IOSTANDARD LVCMOS18 [get_ports {}]
# MC2-17 
set_property PACKAGE_PIN P4 [get_ports {input_streaming_data_from_fpga_to_asic[28]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[28]}]
# MC2-18 
set_property PACKAGE_PIN N5 [get_ports {input_streaming_data_from_fpga_to_asic[27]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[27]}]
# MC2-19 
set_property PACKAGE_PIN N4 [get_ports {input_streaming_data_from_fpga_to_asic[26]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[26]}]
# MC2-20 
set_property PACKAGE_PIN P2 [get_ports {input_streaming_data_from_fpga_to_asic[25]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[25]}]
# MC2-21 
set_property PACKAGE_PIN N3 [get_ports {input_streaming_data_from_fpga_to_asic[24]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[24]}]
# MC2-22 
set_property PACKAGE_PIN N2 [get_ports {input_streaming_data_from_fpga_to_asic[23]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[23]}]
# MC2-23 
set_property PACKAGE_PIN L5 [get_ports {input_streaming_data_from_fpga_to_asic[22]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[22]}]
# MC2-24 
set_property PACKAGE_PIN R1 [get_ports {input_streaming_data_from_fpga_to_asic[21]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[21]}]
# MC2-25 
set_property PACKAGE_PIN L4 [get_ports {input_streaming_data_from_fpga_to_asic[20]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[20]}]
# MC2-26 
set_property PACKAGE_PIN P1 [get_ports {input_streaming_data_from_fpga_to_asic[19]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[19]}]
# MC2-27 
set_property PACKAGE_PIN M6 [get_ports {input_streaming_data_from_fpga_to_asic[18]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[18]}]
# MC2-28 
set_property PACKAGE_PIN M3 [get_ports {input_streaming_data_from_fpga_to_asic[17]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[17]}]
# MC2-29 
set_property PACKAGE_PIN M5 [get_ports {input_streaming_data_from_fpga_to_asic[16]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[16]}]
set_property IOSTANDARD LVCMOS18 [get_ports {}]
# MC2-31 
set_property PACKAGE_PIN M1 [get_ports {input_streaming_valid_from_fpga_to_asic}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_valid_from_fpga_to_asic}]
set_property IOSTANDARD LVCMOS18 [get_ports {}]
# MC2-33 
set_property PACKAGE_PIN L1 [get_ports {start_training_signal_from_fpga_to_asic}]
set_property IOSTANDARD LVCMOS18 [get_ports {start_training_signal_from_fpga_to_asic}]
# MC2-34 
set_property PACKAGE_PIN J6 [get_ports {start_inference_signal_from_fpga_to_asic}]
set_property IOSTANDARD LVCMOS18 [get_ports {start_inference_signal_from_fpga_to_asic}]
# MC2-37 
set_property PACKAGE_PIN K2 [get_ports {reset_n_from_fpga_to_asic}]
set_property IOSTANDARD LVCMOS18 [get_ports {reset_n_from_fpga_to_asic}]
# MC2-38 
set_property PACKAGE_PIN L3 [get_ports {clk_clock_generator}]
set_property IOSTANDARD LVCMOS18 [get_ports {clk_clock_generator}]
set_property IOSTANDARD LVCMOS18 [get_ports {}]
# MC2-40 
set_property PACKAGE_PIN K3 [get_ports {clk_port_spare_0}]
set_property IOSTANDARD LVCMOS18 [get_ports {clk_port_spare_0}]
set_property IOSTANDARD LVCMOS18 [get_ports {}]
set_property IOSTANDARD LVCMOS18 [get_ports {}]
set_property IOSTANDARD LVCMOS18 [get_ports {}]
set_property IOSTANDARD LVCMOS18 [get_ports {}]
# MC2-45 
set_property PACKAGE_PIN H3 [get_ports {clk_port_spare_1}]
set_property IOSTANDARD LVCMOS18 [get_ports {clk_port_spare_1}]
# MC2-46 
set_property PACKAGE_PIN H2 [get_ports {input_streaming_data_from_fpga_to_asic[15]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[15]}]
# MC2-47 
set_property PACKAGE_PIN G3 [get_ports {input_streaming_data_from_fpga_to_asic[14]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[14]}]
# MC2-48 
set_property PACKAGE_PIN G2 [get_ports {input_streaming_data_from_fpga_to_asic[13]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[13]}]
# MC2-49 
set_property PACKAGE_PIN E2 [get_ports {input_streaming_ready_from_asic_to_fpga}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_ready_from_asic_to_fpga}]
# MC2-50 
set_property PACKAGE_PIN G1 [get_ports {start_ready_from_asic_to_fpga}]
set_property IOSTANDARD LVCMOS18 [get_ports {start_ready_from_asic_to_fpga}]
# MC2-51 
set_property PACKAGE_PIN D2 [get_ports {inferenced_label_from_asic_to_fpga}]
set_property IOSTANDARD LVCMOS18 [get_ports {inferenced_label_from_asic_to_fpga}]
# MC2-52 
set_property PACKAGE_PIN F1 [get_ports {input_streaming_data_from_fpga_to_asic[12]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[12]}]
# MC2-53 
set_property PACKAGE_PIN F3 [get_ports {input_streaming_data_from_fpga_to_asic[11]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[11]}]
# MC2-54 
set_property PACKAGE_PIN E1 [get_ports {input_streaming_data_from_fpga_to_asic[10]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[10]}]
# MC2-57 
set_property PACKAGE_PIN E3 [get_ports {input_streaming_data_from_fpga_to_asic[9]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[9]}]
# MC2-58 
set_property PACKAGE_PIN D1 [get_ports {input_streaming_data_from_fpga_to_asic[8]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[8]}]
# MC2-59 
set_property PACKAGE_PIN B1 [get_ports {input_streaming_data_from_fpga_to_asic[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[7]}]
# MC2-60 
set_property PACKAGE_PIN C2 [get_ports {input_streaming_data_from_fpga_to_asic[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[6]}]
# MC2-61 
set_property PACKAGE_PIN A1 [get_ports {input_streaming_data_from_fpga_to_asic[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[5]}]
# MC2-62 
set_property PACKAGE_PIN B2 [get_ports {input_streaming_data_from_fpga_to_asic[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[4]}]
# MC2-63 
set_property PACKAGE_PIN K4 [get_ports {input_streaming_data_from_fpga_to_asic[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
# MC2-65 
set_property PACKAGE_PIN J4 [get_ports {input_streaming_data_from_fpga_to_asic[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
set_property IOSTANDARD LVCMOS33 [get_ports {}]
# MC2-77 
set_property PACKAGE_PIN H4 [get_ports {input_streaming_data_from_fpga_to_asic[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[1]}]
# MC2-79 
set_property PACKAGE_PIN G4 [get_ports {input_streaming_data_from_fpga_to_asic[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[0]}]

# LEDs #####################################################################
set_property PACKAGE_PIN A13 [get_ports {led[0]}]
set_property PACKAGE_PIN B13 [get_ports {led[1]}]
set_property PACKAGE_PIN A14 [get_ports {led[2]}]
set_property PACKAGE_PIN A15 [get_ports {led[3]}]
set_property PACKAGE_PIN B15 [get_ports {led[4]}]
set_property PACKAGE_PIN A16 [get_ports {led[5]}]
set_property PACKAGE_PIN B16 [get_ports {led[6]}]
set_property PACKAGE_PIN B17 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS15 [get_ports {led[*]}]

# Flash ####################################################################
set_property PACKAGE_PIN AA9 [get_ports {spi_dq0}]
set_property PACKAGE_PIN V10 [get_ports {spi_c}]
set_property PACKAGE_PIN W10 [get_ports {spi_s}]
set_property PACKAGE_PIN AB10 [get_ports {spi_dq1}]
set_property PACKAGE_PIN AA10 [get_ports {spi_w_dq2}]
set_property PACKAGE_PIN AA11 [get_ports {spi_hold_dq3}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_dq0}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_c}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_s}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_dq1}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_w_dq2}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_hold_dq3}]

# DRAM #####################################################################
set_property PACKAGE_PIN N18 [get_ports {ddr3_dq[0]}]
set_property PACKAGE_PIN L20 [get_ports {ddr3_dq[1]}]
set_property PACKAGE_PIN N20 [get_ports {ddr3_dq[2]}]
set_property PACKAGE_PIN K18 [get_ports {ddr3_dq[3]}]
set_property PACKAGE_PIN M18 [get_ports {ddr3_dq[4]}]
set_property PACKAGE_PIN K19 [get_ports {ddr3_dq[5]}]
set_property PACKAGE_PIN N19 [get_ports {ddr3_dq[6]}]
set_property PACKAGE_PIN L18 [get_ports {ddr3_dq[7]}]
set_property PACKAGE_PIN L16 [get_ports {ddr3_dq[8]}]
set_property PACKAGE_PIN L14 [get_ports {ddr3_dq[9]}]
set_property PACKAGE_PIN K14 [get_ports {ddr3_dq[10]}]
set_property PACKAGE_PIN M15 [get_ports {ddr3_dq[11]}]
set_property PACKAGE_PIN K16 [get_ports {ddr3_dq[12]}]
set_property PACKAGE_PIN M13 [get_ports {ddr3_dq[13]}]
set_property PACKAGE_PIN K13 [get_ports {ddr3_dq[14]}]
set_property PACKAGE_PIN L13 [get_ports {ddr3_dq[15]}]
set_property PACKAGE_PIN D22 [get_ports {ddr3_dq[16]}]
set_property PACKAGE_PIN C20 [get_ports {ddr3_dq[17]}]
set_property PACKAGE_PIN E21 [get_ports {ddr3_dq[18]}]
set_property PACKAGE_PIN D21 [get_ports {ddr3_dq[19]}]
set_property PACKAGE_PIN G21 [get_ports {ddr3_dq[20]}]
set_property PACKAGE_PIN C22 [get_ports {ddr3_dq[21]}]
set_property PACKAGE_PIN E22 [get_ports {ddr3_dq[22]}]
set_property PACKAGE_PIN B22 [get_ports {ddr3_dq[23]}]
set_property PACKAGE_PIN A20 [get_ports {ddr3_dq[24]}]
set_property PACKAGE_PIN D19 [get_ports {ddr3_dq[25]}]
set_property PACKAGE_PIN A19 [get_ports {ddr3_dq[26]}]
set_property PACKAGE_PIN F19 [get_ports {ddr3_dq[27]}]
set_property PACKAGE_PIN C18 [get_ports {ddr3_dq[28]}]
set_property PACKAGE_PIN E19 [get_ports {ddr3_dq[29]}]
set_property PACKAGE_PIN A18 [get_ports {ddr3_dq[30]}]
set_property PACKAGE_PIN C19 [get_ports {ddr3_dq[31]}]
set_property SLEW FAST [get_ports {ddr3_dq[*]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dq[*]}]

set_property PACKAGE_PIN J21 [get_ports {ddr3_addr[0]}]
set_property PACKAGE_PIN J22 [get_ports {ddr3_addr[1]}]
set_property PACKAGE_PIN K21 [get_ports {ddr3_addr[2]}]
set_property PACKAGE_PIN H22 [get_ports {ddr3_addr[3]}]
set_property PACKAGE_PIN G13 [get_ports {ddr3_addr[4]}]
set_property PACKAGE_PIN G17 [get_ports {ddr3_addr[5]}]
set_property PACKAGE_PIN H15 [get_ports {ddr3_addr[6]}]
set_property PACKAGE_PIN G16 [get_ports {ddr3_addr[7]}]
set_property PACKAGE_PIN G20 [get_ports {ddr3_addr[8]}]
set_property PACKAGE_PIN M21 [get_ports {ddr3_addr[9]}]
set_property PACKAGE_PIN J15 [get_ports {ddr3_addr[10]}]
set_property PACKAGE_PIN G15 [get_ports {ddr3_addr[11]}]
set_property PACKAGE_PIN H13 [get_ports {ddr3_addr[12]}]
set_property PACKAGE_PIN K22 [get_ports {ddr3_addr[13]}]
set_property PACKAGE_PIN L21 [get_ports {ddr3_addr[14]}]
set_property SLEW FAST [get_ports {ddr3_addr[*]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_addr[*]}]

set_property PACKAGE_PIN H18 [get_ports {ddr3_ba[0]}]
set_property PACKAGE_PIN J19 [get_ports {ddr3_ba[1]}]
set_property PACKAGE_PIN H19 [get_ports {ddr3_ba[2]}]
set_property SLEW FAST [get_ports {ddr3_ba[*]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_ba[*]}]

set_property PACKAGE_PIN J16 [get_ports {ddr3_ras_n}]
set_property SLEW FAST [get_ports {ddr3_ras_n}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_ras_n}]

set_property PACKAGE_PIN H17 [get_ports {ddr3_cas_n}]
set_property SLEW FAST [get_ports {ddr3_cas_n}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_cas_n}]

set_property PACKAGE_PIN J20 [get_ports {ddr3_we_n}]
set_property SLEW FAST [get_ports {ddr3_we_n}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_we_n}]

set_property PACKAGE_PIN F21 [get_ports {ddr3_reset_n}]
set_property SLEW FAST [get_ports {ddr3_reset_n}]
set_property IOSTANDARD LVCMOS15 [get_ports {ddr3_reset_n}]

set_property PACKAGE_PIN G18 [get_ports {ddr3_cke[0]}]
set_property SLEW FAST [get_ports {ddr3_cke[*]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_cke[*]}]

set_property PACKAGE_PIN H20 [get_ports {ddr3_odt[0]}]
set_property SLEW FAST [get_ports {ddr3_odt[*]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_odt[*]}]

set_property PACKAGE_PIN L19 [get_ports {ddr3_dm[0]}]
set_property PACKAGE_PIN L15 [get_ports {ddr3_dm[1]}]
set_property PACKAGE_PIN D20 [get_ports {ddr3_dm[2]}]
set_property PACKAGE_PIN B20 [get_ports {ddr3_dm[3]}]
set_property SLEW FAST [get_ports {ddr3_dm[*]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dm[*]}]

set_property PACKAGE_PIN N22 [get_ports {ddr3_dqs_p[0]}]
set_property PACKAGE_PIN M22 [get_ports {ddr3_dqs_n[0]}]
set_property PACKAGE_PIN K17 [get_ports {ddr3_dqs_p[1]}]
set_property PACKAGE_PIN J17 [get_ports {ddr3_dqs_n[1]}]
set_property PACKAGE_PIN B21 [get_ports {ddr3_dqs_p[2]}]
set_property PACKAGE_PIN A21 [get_ports {ddr3_dqs_n[2]}]
set_property PACKAGE_PIN F18 [get_ports {ddr3_dqs_p[3]}]
set_property PACKAGE_PIN E18 [get_ports {ddr3_dqs_n[3]}]
set_property SLEW FAST [get_ports {ddr3_dqs*}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {ddr3_dqs*}]

set_property PACKAGE_PIN J14 [get_ports {ddr3_ck_p[0]}]
set_property PACKAGE_PIN H14 [get_ports {ddr3_ck_n[0]}]
set_property SLEW FAST [get_ports {ddr3_ck*}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {ddr3_ck_*}]

# #set_clock_groups -asynchronous -group [get_clocks {mmcm0_clk0 okUH0}] -group [get_clocks {sys_clk_p clk_pll_i}] -group [get_clocks clk_ref_mmcm_300] -group [get_clocks mmcm_ps_clk_bufg_in]
# # set_clock_groups -asynchronous -group [get_clocks {mmcm0_clk0 okUH0}] -group [get_clocks {sys_clk_p clk_pll_i}] -group [get_clocks clk_ref_mmcm_300] -group [get_clocks mmcm_ps_clk_bufg_in] -group [get_clocks IN_clk] -group [get_clocks CLK_FPGA]
# # set_clock_groups -asynchronous -group [get_clocks {sys_clk}] -group [get_clocks {okUH0}]
# set_clock_groups -asynchronous -group [get_clocks {mmcm0_clk0 okUH0}] -group [get_clocks {sys_clk_p clk_pll_i}] -group [get_clocks clk_ref_mmcm_300] -group [get_clocks mmcm_ps_clk_bufg_in] -group [get_clocks -of_objects [get_pins u_clk_wiz_0/clk_out1]] -group [get_clocks IN_clk]
set_clock_groups -asynchronous -group [get_clocks {mmcm0_clk0 okUH0}] -group [get_clocks {sys_clk_p clk_pll_i}]
