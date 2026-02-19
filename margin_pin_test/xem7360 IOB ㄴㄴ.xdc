############################################################################
# XEM7360 - Xilinx constraints file
#
# Pin mappings for the XEM7360.  Use this as a template and comment out 
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
set_property PACKAGE_PIN F23 [get_ports {okHU[0]}]
set_property PACKAGE_PIN H23 [get_ports {okHU[1]}]
set_property PACKAGE_PIN J25 [get_ports {okHU[2]}]
set_property SLEW FAST [get_ports {okHU[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {okHU[*]}]

set_property PACKAGE_PIN F22 [get_ports {okUH[0]}]
set_property PACKAGE_PIN G24 [get_ports {okUH[1]}]
set_property PACKAGE_PIN J26 [get_ports {okUH[2]}]
set_property PACKAGE_PIN G26 [get_ports {okUH[3]}]
set_property PACKAGE_PIN C23 [get_ports {okUH[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {okUH[*]}]

set_property PACKAGE_PIN B21 [get_ports {okUHU[0]}]
set_property PACKAGE_PIN C21 [get_ports {okUHU[1]}]
set_property PACKAGE_PIN E22 [get_ports {okUHU[2]}]
set_property PACKAGE_PIN A20 [get_ports {okUHU[3]}]
set_property PACKAGE_PIN B20 [get_ports {okUHU[4]}]
set_property PACKAGE_PIN C22 [get_ports {okUHU[5]}]
set_property PACKAGE_PIN D21 [get_ports {okUHU[6]}]
set_property PACKAGE_PIN C24 [get_ports {okUHU[7]}]
set_property PACKAGE_PIN C26 [get_ports {okUHU[8]}]
set_property PACKAGE_PIN D26 [get_ports {okUHU[9]}]
set_property PACKAGE_PIN A24 [get_ports {okUHU[10]}]
set_property PACKAGE_PIN A23 [get_ports {okUHU[11]}]
set_property PACKAGE_PIN A22 [get_ports {okUHU[12]}]
set_property PACKAGE_PIN B22 [get_ports {okUHU[13]}]
set_property PACKAGE_PIN A25 [get_ports {okUHU[14]}]
set_property PACKAGE_PIN B24 [get_ports {okUHU[15]}]
set_property PACKAGE_PIN G21 [get_ports {okUHU[16]}]
set_property PACKAGE_PIN E23 [get_ports {okUHU[17]}]
set_property PACKAGE_PIN E21 [get_ports {okUHU[18]}]
set_property PACKAGE_PIN H22 [get_ports {okUHU[19]}]
set_property PACKAGE_PIN D23 [get_ports {okUHU[20]}]
set_property PACKAGE_PIN J21 [get_ports {okUHU[21]}]
set_property PACKAGE_PIN K22 [get_ports {okUHU[22]}]
set_property PACKAGE_PIN D24 [get_ports {okUHU[23]}]
set_property PACKAGE_PIN K23 [get_ports {okUHU[24]}]
set_property PACKAGE_PIN H24 [get_ports {okUHU[25]}]
set_property PACKAGE_PIN F24 [get_ports {okUHU[26]}]
set_property PACKAGE_PIN D25 [get_ports {okUHU[27]}]
set_property PACKAGE_PIN J24 [get_ports {okUHU[28]}]
set_property PACKAGE_PIN B26 [get_ports {okUHU[29]}]
set_property PACKAGE_PIN H26 [get_ports {okUHU[30]}]
set_property PACKAGE_PIN E26 [get_ports {okUHU[31]}]
set_property SLEW FAST [get_ports {okUHU[*]}]
set_property IOSTANDARD LVCMOS18 [get_ports {okUHU[*]}]

set_property PACKAGE_PIN R26 [get_ports {okAA}]
set_property IOSTANDARD LVCMOS33 [get_ports {okAA}]


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
set_property IOSTANDARD LVDS [get_ports {sys_clk_p}]
set_property PACKAGE_PIN AB11 [get_ports {sys_clk_p}]

set_property IOSTANDARD LVDS [get_ports {sys_clk_n}]
set_property PACKAGE_PIN AC11 [get_ports {sys_clk_n}]

# bhkim NEED? This Line?
# 뭐 상관없을 듯. fpga만 돌렸을때 잘 돌아갔잖아. sys_clk_p가지고 asic쪽 돌리는 것도 아니고.
set_property DIFF_TERM FALSE [get_ports {sys_clk_p}]


# bhkim ASIC 5ns에서돌릴거임
create_clock -name clk_clock_generator -period 5.000 [get_ports clk_clock_generator]


# bhkim Note: The system clock is defined by the MIG IP, no need to define it here
# create_clock -name sys_clk -period 5 [get_ports sys_clk_p]
# set_clock_groups -asynchronous -group [get_clocks {sys_clk}] -group [get_clocks {okUH0}]

############################################################################
## User Reset
############################################################################
set_property PACKAGE_PIN G22 [get_ports {reset}]
set_property IOSTANDARD LVCMOS18 [get_ports {reset}]
set_property SLEW FAST [get_ports {reset}]

















































































# Auto-generated XDC Output with Validation
# Checked for FPGA I/O and Clock Capable Pins

# MC1-116
set_property PACKAGE_PIN A9 [get_ports {margin_pin[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[0]}]

# MC1-112
set_property PACKAGE_PIN B9 [get_ports {margin_pin[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[1]}]

# MC1-110
set_property PACKAGE_PIN C9 [get_ports {margin_pin[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[2]}]

# MC1-108
set_property PACKAGE_PIN C14 [get_ports {margin_pin[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[3]}]

# MC1-106
set_property PACKAGE_PIN A10 [get_ports {margin_pin[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[4]}]

# MC1-104
set_property PACKAGE_PIN B10 [get_ports {margin_pin[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[5]}]

# MC1-102
set_property PACKAGE_PIN J14 [get_ports {input_streaming_data_from_fpga_to_asic[29]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[29]}]

# MC1-100
set_property PACKAGE_PIN F10 [get_ports {input_streaming_data_from_fpga_to_asic[32]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[32]}]

# MC1-98
set_property PACKAGE_PIN G11 [get_ports {input_streaming_data_from_fpga_to_asic[34]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[34]}]

# MC1-96
set_property PACKAGE_PIN A15 [get_ports {input_streaming_data_from_fpga_to_asic[36]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[36]}]

# MC1-94
set_property PACKAGE_PIN A14 [get_ports {input_streaming_data_from_fpga_to_asic[38]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[38]}]

# MC1-92
set_property PACKAGE_PIN B14 [get_ports {input_streaming_data_from_fpga_to_asic[30]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[30]}]

# MC1-90
set_property PACKAGE_PIN B15 [get_ports {input_streaming_data_from_fpga_to_asic[28]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[28]}]

# MC1-88
set_property PACKAGE_PIN C11 [get_ports {input_streaming_data_from_fpga_to_asic[20]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[20]}]

# MC1-86
set_property PACKAGE_PIN C12 [get_ports {input_streaming_data_from_fpga_to_asic[22]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[22]}]

# MC1-82
set_property PACKAGE_PIN B11 [get_ports {input_streaming_data_from_fpga_to_asic[24]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[24]}]

# MC1-80
set_property PACKAGE_PIN B12 [get_ports {input_streaming_data_from_fpga_to_asic[26]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[26]}]

# MC1-76
set_property PACKAGE_PIN F13 [get_ports {input_streaming_data_from_fpga_to_asic[27]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[27]}]

# MC1-74
set_property PACKAGE_PIN F14 [get_ports {margin_pin[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[6]}]

# MC1-70
set_property PACKAGE_PIN F12 [get_ports {margin_pin[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[7]}]

# MC1-68
set_property PACKAGE_PIN G12 [get_ports {margin_pin[8]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[8]}]

# MC1-64
set_property PACKAGE_PIN G14 [get_ports {margin_pin[9]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[9]}]

# MC1-62
set_property PACKAGE_PIN H14 [get_ports {margin_pin[10]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[10]}]

# MC1-117
set_property PACKAGE_PIN H8 [get_ports {input_streaming_data_from_fpga_to_asic[31]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[31]}]

# MC1-115
set_property PACKAGE_PIN H9 [get_ports {input_streaming_data_from_fpga_to_asic[33]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[33]}]

# MC1-111
set_property PACKAGE_PIN G9 [get_ports {input_streaming_data_from_fpga_to_asic[35]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[35]}]

# MC1-109
set_property PACKAGE_PIN G10 [get_ports {input_streaming_data_from_fpga_to_asic[37]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[37]}]

# MC1-105
set_property PACKAGE_PIN J10 [get_ports {input_streaming_data_from_fpga_to_asic[39]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[39]}]

# MC1-101
set_property PACKAGE_PIN A12 [get_ports {input_streaming_data_from_fpga_to_asic[41]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[41]}]

# MC1-99
set_property PACKAGE_PIN F8 [get_ports {input_streaming_data_from_fpga_to_asic[43]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[43]}]

# MC1-97
set_property PACKAGE_PIN F9 [get_ports {input_streaming_data_from_fpga_to_asic[45]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[45]}]

# MC1-95
set_property PACKAGE_PIN A13 [get_ports {input_streaming_data_from_fpga_to_asic[44]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[44]}]

# MC1-93
set_property PACKAGE_PIN D8 [get_ports {input_streaming_data_from_fpga_to_asic[42]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[42]}]

# MC1-91
set_property PACKAGE_PIN D9 [get_ports {input_streaming_data_from_fpga_to_asic[40]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[40]}]

# MC1-89
set_property PACKAGE_PIN J8 [get_ports {input_streaming_data_from_fpga_to_asic[18]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[18]}]

# MC1-87
set_property PACKAGE_PIN D10 [get_ports {input_streaming_data_from_fpga_to_asic[16]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[16]}]

# MC1-85
set_property PACKAGE_PIN E10 [get_ports {start_training_signal_from_fpga_to_asic}]
set_property IOSTANDARD LVCMOS18 [get_ports {start_training_signal_from_fpga_to_asic}]

# MC1-81
set_property PACKAGE_PIN E12 [get_ports {reset_n_from_fpga_to_asic}]
set_property IOSTANDARD LVCMOS18 [get_ports {reset_n_from_fpga_to_asic}]

# MC1-79
set_property PACKAGE_PIN E13 [get_ports {start_inference_signal_from_fpga_to_asic}]
set_property IOSTANDARD LVCMOS18 [get_ports {start_inference_signal_from_fpga_to_asic}]

# MC1-75
set_property PACKAGE_PIN D13 [get_ports {input_streaming_valid_from_fpga_to_asic}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_valid_from_fpga_to_asic}]

# MC1-73
set_property PACKAGE_PIN D14 [get_ports {input_streaming_data_from_fpga_to_asic[17]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[17]}]

# MC1-69
set_property PACKAGE_PIN H13 [get_ports {input_streaming_data_from_fpga_to_asic[19]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[19]}]

# MC1-67
set_property PACKAGE_PIN J13 [get_ports {input_streaming_data_from_fpga_to_asic[21]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[21]}]

# MC1-63
set_property PACKAGE_PIN D11 [get_ports {input_streaming_data_from_fpga_to_asic[23]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[23]}]

# MC1-61
set_property PACKAGE_PIN E11 [get_ports {input_streaming_data_from_fpga_to_asic[25]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[25]}]

# MC1-32
set_property PACKAGE_PIN C16 [get_ports {margin_pin[11]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[11]}]

# MC1-30
set_property PACKAGE_PIN D15 [get_ports {margin_pin[12]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[12]}]

# MC1-28
set_property PACKAGE_PIN C18 [get_ports {margin_pin[13]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[13]}]

# MC1-26
set_property PACKAGE_PIN C17 [get_ports {margin_pin[14]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[14]}]

# MC1-25
set_property PACKAGE_PIN F17 [get_ports {clk_clock_generator}]
set_property IOSTANDARD LVCMOS18 [get_ports {clk_clock_generator}]

# MC1-22
set_property PACKAGE_PIN G20 [get_ports {margin_pin[15]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[15]}]

# MC1-20
set_property PACKAGE_PIN H19 [get_ports {margin_pin[16]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[16]}]

# MC1-16
set_property PACKAGE_PIN E16 [get_ports {margin_pin[17]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[17]}]

# MC1-14
set_property PACKAGE_PIN E15 [get_ports {margin_pin[18]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[18]}]

# MC1-10
set_property PACKAGE_PIN A19 [get_ports {margin_pin[19]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[19]}]

# MC1-8
set_property PACKAGE_PIN A18 [get_ports {margin_pin[20]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[20]}]

# MC1-4
set_property PACKAGE_PIN B19 [get_ports {margin_pin[21]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[21]}]

# MC1-2
set_property PACKAGE_PIN C19 [get_ports {margin_pin[22]}]
set_property IOSTANDARD LVCMOS18 [get_ports {margin_pin[22]}]

# MC2-118
set_property PACKAGE_PIN AA20 [get_ports {input_streaming_data_from_fpga_to_asic[63]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[63]}]

# MC2-116
set_property PACKAGE_PIN AA19 [get_ports {input_streaming_data_from_fpga_to_asic[61]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[61]}]

# MC2-112
set_property PACKAGE_PIN AB20 [get_ports {input_streaming_data_from_fpga_to_asic[59]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[59]}]

# MC2-110
set_property PACKAGE_PIN AB19 [get_ports {input_streaming_data_from_fpga_to_asic[57]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[57]}]

# MC2-108
set_property PACKAGE_PIN W15 [get_ports {input_streaming_data_from_fpga_to_asic[55]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[55]}]

# MC2-106
set_property PACKAGE_PIN AD18 [get_ports {input_streaming_data_from_fpga_to_asic[53]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[53]}]

# MC2-104
set_property PACKAGE_PIN AC18 [get_ports {input_streaming_data_from_fpga_to_asic[51]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[51]}]

# MC2-102
set_property PACKAGE_PIN V19 [get_ports {input_streaming_data_from_fpga_to_asic[49]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[49]}]

# MC2-100
set_property PACKAGE_PIN AD19 [get_ports {input_streaming_data_from_fpga_to_asic[47]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[47]}]

# MC2-98
set_property PACKAGE_PIN AC19 [get_ports {input_streaming_data_from_fpga_to_asic[46]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[46]}]

# MC2-96
set_property PACKAGE_PIN W16 [get_ports {input_streaming_data_from_fpga_to_asic[48]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[48]}]

# MC2-94
set_property PACKAGE_PIN AE20 [get_ports {input_streaming_data_from_fpga_to_asic[50]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[50]}]

# MC2-92
set_property PACKAGE_PIN AD20 [get_ports {input_streaming_data_from_fpga_to_asic[52]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[52]}]

# MC2-90
set_property PACKAGE_PIN AD16 [get_ports {input_streaming_data_from_fpga_to_asic[54]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[54]}]

# MC2-88
set_property PACKAGE_PIN AD14 [get_ports {input_streaming_data_from_fpga_to_asic[13]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[13]}]

# MC2-86
set_property PACKAGE_PIN AC14 [get_ports {input_streaming_data_from_fpga_to_asic[15]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[15]}]

# MC2-82
set_property PACKAGE_PIN Y16 [get_ports {input_streaming_data_from_fpga_to_asic[14]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[14]}]

# MC2-80
set_property PACKAGE_PIN Y15 [get_ports {input_streaming_ready_from_asic_to_fpga}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_ready_from_asic_to_fpga}]

# MC2-76
set_property PACKAGE_PIN V17 [get_ports {inferenced_label_from_asic_to_fpga}]
set_property IOSTANDARD LVCMOS18 [get_ports {inferenced_label_from_asic_to_fpga}]

# MC2-74
set_property PACKAGE_PIN V16 [get_ports {input_streaming_data_from_fpga_to_asic[11]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[11]}]

# MC2-70
set_property PACKAGE_PIN Y18 [get_ports {input_streaming_data_from_fpga_to_asic[9]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[9]}]

# MC2-68
set_property PACKAGE_PIN Y17 [get_ports {input_streaming_data_from_fpga_to_asic[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[7]}]

# MC2-64
set_property PACKAGE_PIN W19 [get_ports {input_streaming_data_from_fpga_to_asic[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[5]}]

# MC2-62
set_property PACKAGE_PIN W18 [get_ports {input_streaming_data_from_fpga_to_asic[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[3]}]

# MC2-101
set_property PACKAGE_PIN V18 [get_ports {input_streaming_data_from_fpga_to_asic[65]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[65]}]

# MC2-99
set_property PACKAGE_PIN AC17 [get_ports {input_streaming_data_from_fpga_to_asic[62]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[62]}]

# MC2-97
set_property PACKAGE_PIN AB17 [get_ports {input_streaming_data_from_fpga_to_asic[60]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[60]}]

# MC2-95
set_property PACKAGE_PIN W14 [get_ports {input_streaming_data_from_fpga_to_asic[58]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[58]}]

# MC2-93
set_property PACKAGE_PIN AF18 [get_ports {input_streaming_data_from_fpga_to_asic[56]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[56]}]

# MC2-91
set_property PACKAGE_PIN AE18 [get_ports {input_streaming_data_from_fpga_to_asic[64]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[64]}]

# MC2-87
set_property PACKAGE_PIN AC16 [get_ports {input_streaming_data_from_fpga_to_asic[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[0]}]

# MC2-85
set_property PACKAGE_PIN AB16 [get_ports {start_ready_from_asic_to_fpga}]
set_property IOSTANDARD LVCMOS18 [get_ports {start_ready_from_asic_to_fpga}]

# MC2-81
set_property PACKAGE_PIN AA15 [get_ports {input_streaming_data_from_fpga_to_asic[12]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[12]}]

# MC2-79
set_property PACKAGE_PIN AA14 [get_ports {input_streaming_data_from_fpga_to_asic[10]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[10]}]

# MC2-75
set_property PACKAGE_PIN AA18 [get_ports {input_streaming_data_from_fpga_to_asic[8]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[8]}]

# MC2-73
set_property PACKAGE_PIN AA17 [get_ports {input_streaming_data_from_fpga_to_asic[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[6]}]

# MC2-69
set_property PACKAGE_PIN AF20 [get_ports {input_streaming_data_from_fpga_to_asic[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[4]}]

# MC2-67
set_property PACKAGE_PIN AF19 [get_ports {input_streaming_data_from_fpga_to_asic[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[2]}]

# MC2-63
set_property PACKAGE_PIN AF17 [get_ports {input_streaming_data_from_fpga_to_asic[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {input_streaming_data_from_fpga_to_asic[1]}]

# MC2-38
set_property PACKAGE_PIN AA23 [get_ports {clk_from_fpga}]
set_property IOSTANDARD LVCMOS18 [get_ports {clk_from_fpga}]




















































































































































# LEDs #####################################################################
set_property PACKAGE_PIN T24 [get_ports {led[0]}]
set_property PACKAGE_PIN T25 [get_ports {led[1]}]
set_property PACKAGE_PIN R25 [get_ports {led[2]}]
set_property PACKAGE_PIN P26 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

# Flash ####################################################################
set_property PACKAGE_PIN N17 [get_ports {spi_dq0}]
set_property PACKAGE_PIN N16 [get_ports {spi_c}]
set_property PACKAGE_PIN R16 [get_ports {spi_s}]
set_property PACKAGE_PIN U17 [get_ports {spi_dq1}]
set_property PACKAGE_PIN U16 [get_ports {spi_w_dq2}]
set_property PACKAGE_PIN T17 [get_ports {spi_hold_dq3}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_dq0}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_c}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_s}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_dq1}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_w_dq2}]
set_property IOSTANDARD LVCMOS33 [get_ports {spi_hold_dq3}]

# DRAM #####################################################################
set_property PACKAGE_PIN U7 [get_ports {ddr3_dq[0]}]
set_property PACKAGE_PIN W3 [get_ports {ddr3_dq[1]}]
set_property PACKAGE_PIN U5 [get_ports {ddr3_dq[2]}]
set_property PACKAGE_PIN V4 [get_ports {ddr3_dq[3]}]
set_property PACKAGE_PIN U2 [get_ports {ddr3_dq[4]}]
set_property PACKAGE_PIN V6 [get_ports {ddr3_dq[5]}]
set_property PACKAGE_PIN U1 [get_ports {ddr3_dq[6]}]
set_property PACKAGE_PIN V3 [get_ports {ddr3_dq[7]}]
set_property PACKAGE_PIN W1 [get_ports {ddr3_dq[8]}]
set_property PACKAGE_PIN Y1  [get_ports {ddr3_dq[9]}]
set_property PACKAGE_PIN Y2  [get_ports {ddr3_dq[10]}]
set_property PACKAGE_PIN AA3 [get_ports {ddr3_dq[11]}]
set_property PACKAGE_PIN V1 [get_ports {ddr3_dq[12]}]
set_property PACKAGE_PIN AC2 [get_ports {ddr3_dq[13]}]
set_property PACKAGE_PIN V2 [get_ports {ddr3_dq[14]}]
set_property PACKAGE_PIN AB2 [get_ports {ddr3_dq[15]}]
set_property PACKAGE_PIN AD6 [get_ports {ddr3_dq[16]}]
set_property PACKAGE_PIN AB4 [get_ports {ddr3_dq[17]}]
set_property PACKAGE_PIN AC6 [get_ports {ddr3_dq[18]}]
set_property PACKAGE_PIN Y6 [get_ports {ddr3_dq[19]}]
set_property PACKAGE_PIN AC3 [get_ports {ddr3_dq[20]}]
set_property PACKAGE_PIN Y5 [get_ports {ddr3_dq[21]}]
set_property PACKAGE_PIN AC4 [get_ports {ddr3_dq[22]}]
set_property PACKAGE_PIN AA4 [get_ports {ddr3_dq[23]}]
set_property PACKAGE_PIN AF3 [get_ports {ddr3_dq[24]}]
set_property PACKAGE_PIN AF2  [get_ports {ddr3_dq[25]}]
set_property PACKAGE_PIN AE3  [get_ports {ddr3_dq[26]}]
set_property PACKAGE_PIN AE2 [get_ports {ddr3_dq[27]}]
set_property PACKAGE_PIN AE6 [get_ports {ddr3_dq[28]}]
set_property PACKAGE_PIN AE1 [get_ports {ddr3_dq[29]}]
set_property PACKAGE_PIN AE5 [get_ports {ddr3_dq[30]}]
set_property PACKAGE_PIN AD1 [get_ports {ddr3_dq[31]}]
set_property SLEW FAST [get_ports {ddr3_dq[*]}]
set_property IOSTANDARD SSTL15_T_DCI [get_ports {ddr3_dq[*]}]

set_property PACKAGE_PIN AD8 [get_ports {ddr3_addr[0]}]
set_property PACKAGE_PIN AC8 [get_ports {ddr3_addr[1]}]
set_property PACKAGE_PIN AA7 [get_ports {ddr3_addr[2]}]
set_property PACKAGE_PIN AA8 [get_ports {ddr3_addr[3]}]
set_property PACKAGE_PIN AF7 [get_ports {ddr3_addr[4]}]
set_property PACKAGE_PIN AE7 [get_ports {ddr3_addr[5]}]
set_property PACKAGE_PIN W8 [get_ports {ddr3_addr[6]}]
set_property PACKAGE_PIN V9 [get_ports {ddr3_addr[7]}]
set_property PACKAGE_PIN Y10 [get_ports {ddr3_addr[8]}]
set_property PACKAGE_PIN Y11 [get_ports {ddr3_addr[9]}]
set_property PACKAGE_PIN Y7 [get_ports {ddr3_addr[10]}]
set_property PACKAGE_PIN Y8 [get_ports {ddr3_addr[11]}]
set_property PACKAGE_PIN V7 [get_ports {ddr3_addr[12]}]
set_property PACKAGE_PIN V8 [get_ports {ddr3_addr[13]}]
set_property PACKAGE_PIN W11 [get_ports {ddr3_addr[14]}]
set_property PACKAGE_PIN V11 [get_ports {ddr3_addr[15]}]
set_property SLEW FAST [get_ports {ddr3_addr[*]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_addr[*]}]

set_property PACKAGE_PIN AA9 [get_ports {ddr3_ba[0]}]
set_property PACKAGE_PIN AC7 [get_ports {ddr3_ba[1]}]
set_property PACKAGE_PIN AB7 [get_ports {ddr3_ba[2]}]
set_property SLEW FAST [get_ports {ddr3_ba[*]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_ba[*]}]

set_property PACKAGE_PIN AB9 [get_ports {ddr3_ras_n}]
set_property SLEW FAST [get_ports {ddr3_ras_n}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_ras_n}]

set_property PACKAGE_PIN AC9 [get_ports {ddr3_cas_n}]
set_property SLEW FAST [get_ports {ddr3_cas_n}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_cas_n}]

set_property PACKAGE_PIN AD9 [get_ports {ddr3_we_n}]
set_property SLEW FAST [get_ports {ddr3_we_n}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_we_n}]

set_property PACKAGE_PIN AA2 [get_ports {ddr3_reset_n}]
set_property SLEW FAST [get_ports {ddr3_reset_n}]
set_property IOSTANDARD LVCMOS15 [get_ports {ddr3_reset_n}]

set_property PACKAGE_PIN AC12 [get_ports {ddr3_cke[0]}]
set_property PACKAGE_PIN AA12 [get_ports {ddr3_cke[1]}]
set_property SLEW FAST [get_ports {ddr3_cke[*]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_cke[*]}]

set_property PACKAGE_PIN AA13 [get_ports {ddr3_odt[0]}]
set_property PACKAGE_PIN AD13 [get_ports {ddr3_odt[1]}]
set_property SLEW FAST [get_ports {ddr3_odt[*]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_odt[*]}]

set_property PACKAGE_PIN AB12 [get_ports {ddr3_cs_n[0]}]
# set_property PACKAGE_PIN AC13 [get_ports {ddr3_cs_n[1]}]
set_property SLEW FAST [get_ports {ddr3_cs_n[*]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_cs_n[*]}]

set_property PACKAGE_PIN U6 [get_ports {ddr3_dm[0]}]
set_property PACKAGE_PIN Y3 [get_ports {ddr3_dm[1]}]
set_property PACKAGE_PIN AB6 [get_ports {ddr3_dm[2]}]
set_property PACKAGE_PIN AD4 [get_ports {ddr3_dm[3]}]
set_property SLEW FAST [get_ports {ddr3_dm[*]}]
set_property IOSTANDARD SSTL15 [get_ports {ddr3_dm[*]}]

set_property PACKAGE_PIN W6 [get_ports {ddr3_dqs_p[0]}]
set_property PACKAGE_PIN W5 [get_ports {ddr3_dqs_n[0]}]
set_property PACKAGE_PIN AB1 [get_ports {ddr3_dqs_p[1]}]
set_property PACKAGE_PIN AC1 [get_ports {ddr3_dqs_n[1]}]
set_property PACKAGE_PIN AA5 [get_ports {ddr3_dqs_p[2]}]
set_property PACKAGE_PIN AB5 [get_ports {ddr3_dqs_n[2]}]
set_property PACKAGE_PIN AF5 [get_ports {ddr3_dqs_p[3]}]
set_property PACKAGE_PIN AF4 [get_ports {ddr3_dqs_n[3]}]
set_property SLEW FAST [get_ports {ddr3_dqs*}]
set_property IOSTANDARD DIFF_SSTL15_T_DCI [get_ports {ddr3_dqs*}]

set_property PACKAGE_PIN W10 [get_ports {ddr3_ck_p[0]}]
set_property PACKAGE_PIN W9 [get_ports {ddr3_ck_n[0]}]
set_property SLEW FAST [get_ports {ddr3_ck*}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {ddr3_ck_*}]

# OnBoard 100Mhz MGTREFCLK #################################################
set_property PACKAGE_PIN K6 [get_ports {mgtrefclk_p}]
set_property PACKAGE_PIN K5 [get_ports {mgtrefclk_n}]








# # RESET_N과 마진 핀은 제외
# set_property IOB TRUE [get_ports {input_streaming_ready_from_asic_to_fpga start_ready_from_asic_to_fpga inferenced_label_from_asic_to_fpga}]
# set_property IOB TRUE [get_ports {input_streaming_data_from_fpga_to_asic[*] input_streaming_valid_from_fpga_to_asic start_training_signal_from_fpga_to_asic start_inference_signal_from_fpga_to_asic}]




set_clock_groups -asynchronous -group [get_clocks {clk_out1_clk_wiz_1_100to100MHz_nobuffer}] -group [get_clocks {clk_out1_clk_wiz_1_100to100MHz_nobuffer_2}] -group [get_clocks {clk_out1_clk_wiz_1_1}] -group [get_clocks {clk_out1_clk_wiz_static_200MHzto200MHz}] -group [get_clocks {okUH0 mmcm0_clk0}] -group [get_clocks {sys_clk_p clk_pll_i}] -group [get_clocks {clk_out1_clk_wiz_1}] -group [get_clocks {clk_out1_clk_wiz_1_20MHz_1}] -group [get_clocks {clk_out1_clk_wiz_1_100to20MHz_nobuffer}] -group [get_clocks {clk_out1_clk_wiz_1_100to10MHz_nobuffer}] -group [get_clocks {clk_out2_clk_wiz_0}] -group [get_clocks {clk_clock_generator}]



# ASIC에서 OUTPUT DELAY -MAX 1ns, -MIN -0.5ns
# 3.5ns 간격으로 asic에서 fpga로 신호가 옴. 이걸 잘 받아야됨.
# (fpga의 input delay max값) - (fpga의 input delay min)의 값이 3.5이상이어야하고
# 근데 보니까 asic output hold margin 1.0ns setupmargin 1ns있음. 그럼 
# (fpga의 input delay max값) - (fpga의 input delay min)의 값이 1.5이상이기만 해라.

# input clk_out1_clk_wiz_1
# set_input_delay -clock [get_clocks {clk_out1_clk_wiz_1}] -max 4.250 [get_ports {input_streaming_ready_from_asic_to_fpga start_ready_from_asic_to_fpga inferenced_label_from_asic_to_fpga}]
# set_input_delay -clock [get_clocks {clk_out1_clk_wiz_1}] -min 1.500 [get_ports {input_streaming_ready_from_asic_to_fpga start_ready_from_asic_to_fpga inferenced_label_from_asic_to_fpga}]
set_input_delay -clock [get_clocks {clk_out1_clk_wiz_1_100to100MHz_nobuffer}] -max 4.250 [get_ports {input_streaming_ready_from_asic_to_fpga start_ready_from_asic_to_fpga inferenced_label_from_asic_to_fpga}]
set_input_delay -clock [get_clocks {clk_out1_clk_wiz_1_100to100MHz_nobuffer}] -min 1.500 [get_ports {input_streaming_ready_from_asic_to_fpga start_ready_from_asic_to_fpga inferenced_label_from_asic_to_fpga}]


# ASIC에서 INPUT DELAY -MAX 2ns, -MIN 0.01ns
# 1.99ns 간격안에 fpga에서 나가서 asic에 박아넣어야함.
# 5 - (fpga의 output delay max값) + (fpga의 output delay min)의 값이 1.99ns미만이어야 한다.
# 근데 보니까 asic input hold margin 0.25ns setupmargin 1.23ns있음. 그럼 
# 5 - (fpga의 output delay max값) + (fpga의 output delay min)의 값이 3.47ns미만이어도됨
# 근데 여전히 역부족이네. 나 250MHz로 돌렸었으니까  1ns더 봐줘서 4.47ns미만이어도됨.으로 가자

# # 이게 좋다
# # # output 
# set_output_delay -clock [get_clocks {clk_out1_clk_wiz_1}] -max -1.900 [get_ports {input_streaming_data_from_fpga_to_asic[*] reset_n_from_fpga_to_asic input_streaming_valid_from_fpga_to_asic start_training_signal_from_fpga_to_asic start_inference_signal_from_fpga_to_asic}]
# set_output_delay -clock [get_clocks {clk_out1_clk_wiz_1}] -min -2.750 [get_ports {input_streaming_data_from_fpga_to_asic[*] reset_n_from_fpga_to_asic input_streaming_valid_from_fpga_to_asic start_training_signal_from_fpga_to_asic start_inference_signal_from_fpga_to_asic}]

# # output 클락 다른거 쓸 때 
# set_output_delay -clock [get_clocks {clk_out1_clk_wiz_1_1}] -max -3.000 [get_ports {input_streaming_data_from_fpga_to_asic[*] reset_n_from_fpga_to_asic input_streaming_valid_from_fpga_to_asic start_training_signal_from_fpga_to_asic start_inference_signal_from_fpga_to_asic}]
# set_output_delay -clock [get_clocks {clk_out1_clk_wiz_1_1}] -min -2.650 [get_ports {input_streaming_data_from_fpga_to_asic[*] reset_n_from_fpga_to_asic input_streaming_valid_from_fpga_to_asic start_training_signal_from_fpga_to_asic start_inference_signal_from_fpga_to_asic}]
set_output_delay -clock [get_clocks {clk_out1_clk_wiz_1_100to100MHz_nobuffer_2}] -max 1.000 [get_ports {input_streaming_data_from_fpga_to_asic[*] reset_n_from_fpga_to_asic input_streaming_valid_from_fpga_to_asic start_training_signal_from_fpga_to_asic start_inference_signal_from_fpga_to_asic}]
set_output_delay -clock [get_clocks {clk_out1_clk_wiz_1_100to100MHz_nobuffer_2}] -min -2.650 [get_ports {input_streaming_data_from_fpga_to_asic[*] reset_n_from_fpga_to_asic input_streaming_valid_from_fpga_to_asic start_training_signal_from_fpga_to_asic start_inference_signal_from_fpga_to_asic}]











# set_max_delay -from [get_clocks {clk_out1_clk_wiz_1}] -to [get_ports {input_streaming_data_from_fpga_to_asic[*] reset_n_from_fpga_to_asic input_streaming_valid_from_fpga_to_asic start_training_signal_from_fpga_to_asic start_inference_signal_from_fpga_to_asic}] 6.000
# set_min_delay -from [get_clocks {clk_out1_clk_wiz_1}] -to [get_ports {input_streaming_data_from_fpga_to_asic[*] reset_n_from_fpga_to_asic input_streaming_valid_from_fpga_to_asic start_training_signal_from_fpga_to_asic start_inference_signal_from_fpga_to_asic}] 4.500
# set_output_delay -clock [get_clocks {clk_out1_clk_wiz_1}] -max -2.000 [get_ports {input_streaming_data_from_fpga_to_asic[*] reset_n_from_fpga_to_asic input_streaming_valid_from_fpga_to_asic start_training_signal_from_fpga_to_asic start_inference_signal_from_fpga_to_asic}]




















# set_multicycle_path -setup -to [get_ports {input_streaming_data_from_fpga_to_asic[*] reset_n_from_fpga_to_asic input_streaming_valid_from_fpga_to_asic start_training_signal_from_fpga_to_asic start_inference_signal_from_fpga_to_asic}] 2
# set_multicycle_path -hold -to [get_ports {input_streaming_data_from_fpga_to_asic[*] reset_n_from_fpga_to_asic input_streaming_valid_from_fpga_to_asic start_training_signal_from_fpga_to_asic start_inference_signal_from_fpga_to_asic}] 1


















# set_bus_skew -to [get_ports { \
#     input_streaming_data_from_fpga_to_asic[*] \
#     reset_n_from_fpga_to_asic \
#     input_streaming_valid_from_fpga_to_asic \
#     start_training_signal_from_fpga_to_asic \
#     start_inference_signal_from_fpga_to_asic \
# }] 1.500