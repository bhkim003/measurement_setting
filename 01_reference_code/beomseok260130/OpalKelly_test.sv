
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kim Beomseok
// Contact: kimbss470@snu.ac.kr
// 
// Create Date: 21/07/2024 
// Design Name: OpalKelly for USB3 in Verilog
// Module Name: OpalKelly_test
// Project Name: 2024TapeOut
// Target Devices: XEM7360-K160T
// Tool versions: 2024.1
// Description: A test top module for OpalKelly toy example
//              This module contains OpalKelly and pseudoChip.
//              Use this module only for loopback test.
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
`include "params.vh"
module OpalKelly_test (
    input  wire         sys_clk_p,
    input  wire         sys_clk_n,


    /* USB3 interface */
    input  wire [  4:0] okUH,
	output wire [  2:0] okHU,
	inout  wire [ 31:0] okUHU,
	inout  wire         okAA,
	output wire [  3:0] led,

    /* DDR3 interface */
    inout  wire [ 31:0] ddr3_dq,
	output wire [ 15:0] ddr3_addr,
	output wire [  2:0] ddr3_ba,
	output wire         ddr3_ck_p,
	output wire         ddr3_ck_n,
	output wire         ddr3_cke,
	output wire         ddr3_cs_n,
	output wire         ddr3_cas_n,
	output wire         ddr3_ras_n,
	output wire         ddr3_we_n,
	output wire         ddr3_odt,
	output wire [  3:0] ddr3_dm,
	inout  wire [  3:0] ddr3_dqs_p,
	inout  wire [  3:0] ddr3_dqs_n,
	output wire         ddr3_reset_n,
	
	/* Chip interface - for debugging */
    input  wire         clk_ext,    // from clock generator, synchronized with chip
    output  wire        chip_clk,  // to chip (not used when clk_ext is used)

    output wire         chip_rstn,
    output wire         single_rate,   // 0: dual-rate , 1: single-rate
    output wire         start,
    output wire         start_store_byte4, // only used for loopback test
    output wire         done,
    output wire         load_or_store,   
    output wire         store_byte4,   
    output wire [127:0] data,
    output wire [ 11:0] axaddr_and_axlen,
    output wire         axvalid,
    output wire         axready,
    output wire         rvalid_or_wready,
    output wire         rready_or_wvalid
	
);

    wire         w_chip_clk;  
    wire         w_chip_rstn;        // gen by okFP
    wire         w_single_rate;
    wire         w_start;
    wire         w_start_store_byte4;
    wire         w_done;
    wire         w_load_or_store;   
    wire         w_store_byte4;   
    wire [127:0] w_data;
    wire [ 11:0] w_axaddr_and_axlen;
    wire         w_axvalid;
    wire         w_axready;
    wire         w_rvalid_or_wready;
    wire         w_rready_or_wvalid;

    //************************************************************
	//  Port Connection
    //************************************************************
     assign chip_clk                = w_chip_clk;
     assign chip_rstn               = w_chip_rstn;
     assign single_rate             = w_single_rate;
     assign start                   = w_start;
     assign start_store_byte4       = w_start_store_byte4;
     assign done                    = w_done;
     assign load_or_store           = w_load_or_store;
     assign store_byte4             = w_store_byte4;
     assign data                    = w_data;
     assign axaddr_and_axlen        = w_axaddr_and_axlen;
     assign axvalid                 = w_axvalid;
     assign axready                 = w_axready;
     assign rvalid_or_wready        = w_rvalid_or_wready;
     assign rready_or_wvalid        = w_rready_or_wvalid;

//    assign chip_clk                = w_chip_clk;
//    assign chip_rstn               = w_chip_rstn;
//    assign single_rate             = 1'b1;
//    assign start                   = 1'b1;
//    assign start_store_byte4       = 1'b1;
//    assign done                    = 1'b1;
//    assign load_or_store           = 1'b1;
//    assign store_byte4             = 1'b1;
//    assign data                    = 128'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff;
//    assign axaddr_and_axlen        = 12'hfff;
//    assign axvalid                 = 1'b1;
//    assign axready                 = 1'b1;
//    assign rvalid_or_wready        = 1'b1;
//    assign rready_or_wvalid        = 1'b1;


    //************************************************************
	//  OpalKelly Instantiations
    //************************************************************

    OpalKelly u_opalkelly (
        .sys_clk_p              (sys_clk_p          ),
        .sys_clk_n              (sys_clk_n          ),
        .okUH                   (okUH               ),
        .okHU                   (okHU               ),
        .okUHU                  (okUHU              ),
        .okAA                   (okAA               ),
        .led                    (led                ),
        .ddr3_dq                (ddr3_dq            ),
        .ddr3_addr              (ddr3_addr          ),
        .ddr3_ba                (ddr3_ba            ),
        .ddr3_ck_p              (ddr3_ck_p          ),
        .ddr3_ck_n              (ddr3_ck_n          ),
        .ddr3_cke               (ddr3_cke           ),
        .ddr3_cs_n              (ddr3_cs_n          ),
        .ddr3_cas_n             (ddr3_cas_n         ),
        .ddr3_ras_n             (ddr3_ras_n         ),
        .ddr3_we_n              (ddr3_we_n          ),
        .ddr3_odt               (ddr3_odt           ),
        .ddr3_dm                (ddr3_dm            ),
        .ddr3_dqs_p             (ddr3_dqs_p         ),
        .ddr3_dqs_n             (ddr3_dqs_n         ),
        .ddr3_reset_n           (ddr3_reset_n       ),

//        `ifdef CLK_EXT
        .clk_ext                (clk_ext            ),
//        `else
        .chip_clk               (w_chip_clk           ),
//        `endif

        .chip_rstn              (w_chip_rstn          ),
        .single_rate            (w_single_rate        ), 
        .start                  (w_start              ),
        .start_store_byte4      (w_start_store_byte4  ),
        .done                   (w_done               ),
        .load_or_store          (w_load_or_store      ), 
        .store_byte4            (w_store_byte4        ), 
        .data                   (w_data               ),
        .axaddr_and_axlen       (w_axaddr_and_axlen   ),
        .axvalid                (w_axvalid            ),
        .axready                (w_axready            ),
        .rvalid_or_wready       (w_rvalid_or_wready   ),
        .rready_or_wvalid       (w_rready_or_wvalid   )
    );
    

    //************************************************************
	// Chip Instantiations
    //************************************************************

    pseudoChip u_chip (
        `ifdef CLK_EXT
        .clk                    (clk_ext              ),
        `else
        .clk                    (w_chip_clk           ),
        `endif
        .rstn                   (w_chip_rstn          ),
        .single_rate            (w_single_rate        ),
        .start                  (w_start              ),
        .start_store_byte4      (w_start_store_byte4  ),
        .done                   (w_done               ),
        .load_or_store          (w_load_or_store      ),   
        .store_byte4            (w_store_byte4        ),   
        .data                   (w_data               ),
        .axaddr_and_axlen       (w_axaddr_and_axlen   ),
        .axvalid                (w_axvalid            ),
        .axready                (w_axready            ),
        .rvalid_or_wready       (w_rvalid_or_wready   ),
        .rready_or_wvalid       (w_rready_or_wvalid   )
    );

endmodule