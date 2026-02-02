//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kim Beomseok
// Contact: kimbss470@snu.ac.kr
// 
// Create Date: 16/07/2024 
// Design Name: OpalKelly for USB3 in Verilog
// Module Name: OpalKelly
// Project Name: 2024TapeOut
// Target Devices: XEM7360-K160T
// Tool versions: 2024.1
// Description: A top module for OpalKelly test platform
//
//////////////////////////////////////////////////////////////////////////////////

`include "params.vh"
`timescale 1ns/1ps
module OpalKelly (
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

    /* Chip interface */
//    `ifdef CLK_EXT
    input  wire         clk_ext,    // from clock generator, synchronized with chip
//    `else
    output wire         chip_clk,  // to chip (not used when clk_ext is used)
//    `endif

    output wire         chip_rstn,
    output wire         single_rate,   // 0: dual-rate , 1: single-rate
    output wire         start,
    output wire         start_store_byte4, // only used for loopback test
    input  wire         done,
    input  wire         load_or_store,   
    input  wire         store_byte4,   
    inout  wire [127:0] data,
    input  wire [ 11:0] axaddr_and_axlen,
    input  wire         axvalid,
    output wire         axready,
    output wire         rvalid_or_wready,
    input  wire         rready_or_wvalid
);


    //************************************************************
    //  Wires & Regs
    //************************************************************

    wire          rstn;
    wire          locked;
    wire          okClk;
    wire          okRstn;

    /*  Chip ctrl */
    wire          clk_for_chip;
    wire          clk_for_chip_in;
    wire          clk_for_chip_out;
    wire          chip_store_byte4;

    wire          start_network;
    wire          done_network;
    wire [  5:0]  n_layers;
    wire          infinite_loop;
    wire [ 15:0]  wait_chip_cnt;
    wire [ 30:0]  clk_cnt;
    wire [ 31:0]  chip_axi_read_delay;


    wire          single_rate_w;   // 0: dual-rate , 1: single-rate
    wire          start_w;
    wire          start_store_byte4_w;
    wire          done_w;          // done from chip
    wire          done_layer_buf;  // buffered for done, synchronized with clk_for_chip_out


    /* DDR3Interface */
    wire          init_calib_done;
    wire          mig_clk;
    wire          mig_rstn;
    wire          mig_abort;
    wire          axi_master;

    wire [ 27:0]  okfp_axi_awaddr;
    wire [  7:0]  okfp_axi_awlen;
    wire          okfp_axi_awvalid;
    wire          okfp_axi_awready;

    wire [255:0]  okfp_axi_wdata;
    wire          okfp_axi_wvalid;
    wire          okfp_axi_wready;

    wire [ 27:0]  okfp_axi_araddr;
    wire [  7:0]  okfp_axi_arlen;
    wire          okfp_axi_arvalid;
    wire          okfp_axi_arready;

    wire [255:0]  okfp_axi_rdata;
    wire          okfp_axi_rvalid;
    wire          okfp_axi_rready;

    wire [ 27:0]  chip_axi_awaddr;
    wire [  7:0]  chip_axi_awlen;
    wire          chip_axi_awvalid;
    wire          chip_axi_awready;

    wire [255:0]  chip_axi_wdata;
    wire          chip_axi_wvalid;
    wire          chip_axi_wready;

    wire [ 27:0]  chip_axi_araddr;
    wire [  7:0]  chip_axi_arlen;
    wire          chip_axi_arvalid;
    wire          chip_axi_arready;

    wire [255:0]  chip_axi_rdata;
    wire          chip_axi_rvalid;
    wire          chip_axi_rvalid_tmp;
    wire          chip_axi_rready;


    /* Debug (ChipInterface) */
    wire          debug_pipe_in_ready;
    wire          debug_pipe_in_valid;
    wire [  3:0]  debug_state;
    wire [ 31:0]  debug_cmd_buf;
    wire          debug_okClk;
 
    wire [  7:0]  start_cnt;
    wire [  7:0]  done_cnt;
    wire [ 31:0]  arvalid_cnt;
    wire [  7:0]  arready_cnt;
    wire [ 31:0]  rvalid_cnt;
    wire [ 31:0]  awvalid_cnt;
    wire [  7:0]  awready_cnt;
    wire [ 31:0]  wvalid_cnt;
    wire [ 27:0]  araddr_hist [0:63];
    wire [  7:0]  arlen_hist  [0:63];
    wire [255:0]  rdata_hist  [0:63];
    wire [ 27:0]  awaddr_hist [0:63];
    wire [  7:0]  awlen_hist  [0:63];
    wire [255:0]  wdata_hist  [0:63];
 
    wire [  3:0]  ttf_axvalid;    // #cycles from start_layer activation to axvalid activation

    wire          debug_fifo_fpga2chip_read;
    wire          debug_fifo_fpga2chip_rd_en;
    wire          pipe_out_ready_debug_fpga2chip;
    wire          pipe_out_valid_debug_fpga2chip;
    wire [ 31:0]  pipe_dout_debug_fpga2chip;
 
    wire          debug_fifo_chip2fpga_read;
    wire          debug_fifo_chip2fpga_rd_en;
    wire          pipe_out_ready_debug_chip2fpga;
    wire          pipe_out_valid_debug_chip2fpga;
    wire [ 31:0]  pipe_dout_debug_chip2fpga;

    wire          debug_fifo_axaddr_read;
    wire          debug_fifo_axaddr_rd_en;
    wire          pipe_out_ready_debug_axaddr;
    wire          pipe_out_valid_debug_axaddr;
    wire [ 31:0]  pipe_dout_debug_axaddr;

 
    wire          debug_fifo_rdata_read;
    wire          debug_fifo_rdata_rd_en;
    wire          pipe_out_ready_debug_rdata;
    wire          pipe_out_valid_debug_rdata;
    wire [ 31:0]  pipe_dout_debug_rdata;

    wire          debug_fifo_wdata_read;
    wire          debug_fifo_wdata_rd_en;
    wire          pipe_out_ready_debug_wdata;
    wire          pipe_out_valid_debug_wdata;
    wire [ 31:0]  pipe_dout_debug_wdata;
 
    wire          araddr_fifo_rd_en_debug;
    wire          araddr_fifo_wr_en_debug;
    wire          araddr_fifo_valid_debug; 
    wire          araddr_fifo_empty_debug; 
    wire          araddr_fifo_full_debug; 
    wire          araddr_fifo_prog_full_debug; 
 
    wire          awaddr_fifo_rd_en_debug;
    wire          awaddr_fifo_wr_en_debug;
    wire          awaddr_fifo_valid_debug; 
    wire          awaddr_fifo_empty_debug; 
    wire          awaddr_fifo_full_debug; 
    wire          awaddr_fifo_prog_full_debug; 
 
    wire          rdata_fifo_rd_en_debug;
    wire          rdata_fifo_wr_en_debug;
    wire          rdata_fifo_valid_debug; 
    wire          rdata_fifo_empty_debug; 
    wire          rdata_fifo_full_debug; 
    wire          rdata_fifo_prog_full_debug; 
 
    wire          wdata_fifo_rd_en_debug;
    wire          wdata_fifo_wr_en_debug;
    wire          wdata_fifo_valid_debug; 
    wire          wdata_fifo_empty_debug; 
    wire          wdata_fifo_full_debug; 
    wire          wdata_fifo_prog_full_debug;

    /* Debug (DDR3Interface) */
    wire          s_axi_wstate_debug;
    wire          s_axi_wready_debug;
    wire          s_axi_arready_debug;
    wire          s_axi_rvalid_debug;
    wire [31:0]   mig_wstate_cnt;
    wire [31:0]   mig_wvalid_cnt;
    wire [31:0]   mig_rstate_cnt;
    wire [31:0]   mig_rvalid_cnt;



    assign single_rate = single_rate_w;
    assign start = start_w;
    assign done_w = done;
    assign rstn = mig_rstn & locked;
    assign chip_rstn = rstn;
    assign led = xem7360_led({debug_state[3], debug_state[2], debug_state[1], debug_state[0]});




    //************************************************************
    // Clock Generation
    //************************************************************
    
    // generate chip_clk with mig_clk or clk_ext
    // clk_wiz_0 u_clk_wiz_0 (
    //     .clk_out1 (clk_for_chip      ),
    //     .clk_out2 (clk_for_chip_in   ),
    //     .clk_out3 (clk_for_chip_out  ),
    //     .resetn   (mig_rstn          ),
    //     .locked   (locked            ),
    //     `ifdef CLK_EXT
    //     .clk_in1  (clk_ext           )
    //     `else
    //     .clk_in1  (mig_clk           )
    //     `endif
    // );

    // assign chip_clk = clk_for_chip;

    clk_wiz_0 u_clk_wiz_0 (
        .clk_out1 (chip_clk      ),
        .clk_out2 (clk_for_chip  ),
        .resetn   (mig_rstn          ),
        .locked   (locked            ),
        // `ifdef CLK_EXT
        .clk_in1  (clk_ext           )
        // `else
        // .clk_in1  (mig_clk           )
        // `endif
    );

    assign clk_for_chip_in = clk_for_chip;
    assign clk_for_chip_out = clk_for_chip;

    // for loopback test
    reg start_store_byte4_buf0;
    reg start_store_byte4_buf1;

    assign start_store_byte4 = start_store_byte4_buf1;
    always @(posedge clk_for_chip or negedge chip_rstn) begin
        if (~chip_rstn) begin
            start_store_byte4_buf0 <= 1'b0;
            start_store_byte4_buf1 <= 1'b0;
        end
        else begin
            start_store_byte4_buf0 <= start_store_byte4_w;
            start_store_byte4_buf1 <= start_store_byte4_buf0;
        end
    end
    


    //************************************************************
    // okFrontPanel
    //************************************************************

    okFrontPanel u_okFrontPanel (
        .init_calib_done                (init_calib_done               ),
        .rstn                           (rstn                          ),   

        .okClk                          (okClk                         ),
        .okUH                           (okUH                          ),
        .okHU                           (okHU                          ),
        .okUHU                          (okUHU                         ),
        .okAA                           (okAA                          ),
        .okRstn                         (okRstn                        ),   // generated by okWireIn

        /* okFP <-> ChipInterface */
        .chip_clk                       (clk_for_chip                  ),
        .chip_network_start             (start_network                 ),
        .chip_single_rate               (single_rate_w                 ),
        .chip_n_layers                  (n_layers                      ),
        .chip_infinite_loop             (infinite_loop                 ),
        .wait_chip_cnt                  (wait_chip_cnt                 ),
        .chip_network_done              (done_network                  ),
        .chip_layer_done                (done_layer_buf                ),
        .chip_clk_cnt                   (clk_cnt                       ),

        /* AXI-interface (okFP <-> MIG ) */
        .mig_clk                        (mig_clk                       ),
        .mig_abort                      (mig_abort                     ),
        .axi_master                     (axi_master                    ),
        .axi_awaddr                     (okfp_axi_awaddr               ),
        .axi_awlen                      (okfp_axi_awlen                ),
        .axi_awvalid                    (okfp_axi_awvalid              ),
        .axi_awready                    (okfp_axi_awready              ),
        .axi_wdata                      (okfp_axi_wdata                ),
        .axi_wvalid                     (okfp_axi_wvalid               ),
        .axi_wready                     (okfp_axi_wready               ),
        .axi_araddr                     (okfp_axi_araddr               ),
        .axi_arlen                      (okfp_axi_arlen                ),
        .axi_arvalid                    (okfp_axi_arvalid              ),
        .axi_arready                    (okfp_axi_arready              ),
        .axi_rdata                      (okfp_axi_rdata                ),
        .axi_rvalid                     (okfp_axi_rvalid               ),
        .axi_rready                     (okfp_axi_rready               ),

        /* Debug (ChipInterface) */
        .start_cnt                      (start_cnt                     ),
        .done_cnt                       (done_cnt                      ), 
        .arvalid_cnt                    (arvalid_cnt                   ),
        .arready_cnt                    (arready_cnt                   ),
        .rvalid_cnt                     (rvalid_cnt                    ),
        .awvalid_cnt                    (awvalid_cnt                   ),
        .awready_cnt                    (awready_cnt                   ),
        .wvalid_cnt                     (wvalid_cnt                    ),
        .araddr_hist                    (araddr_hist                   ),
        .arlen_hist                     (arlen_hist                    ),
        .rdata_hist                     (rdata_hist                    ),
        .awaddr_hist                    (awaddr_hist                   ),
        .awlen_hist                     (awlen_hist                    ),
        // .wdata_hist             (wdata_hist         ),
        .ttf_axvalid                    (ttf_axvalid                   ),

        /* FIFO for cycle level debugging of fpga2chip signals */
        .debug_fifo_fpga2chip_read      (debug_fifo_fpga2chip_read     ),
        .debug_fifo_fpga2chip_rd_en     (debug_fifo_fpga2chip_rd_en    ),
        .pipe_out_ready_debug_fpga2chip (pipe_out_ready_debug_fpga2chip),
        .pipe_out_valid_debug_fpga2chip (pipe_out_valid_debug_fpga2chip),
        .pipe_dout_debug_fpga2chip      (pipe_dout_debug_fpga2chip     ),

        /* FIFO for cycle level debugging of chip2fpga signals */
        .debug_fifo_chip2fpga_read      (debug_fifo_chip2fpga_read     ),
        .debug_fifo_chip2fpga_rd_en     (debug_fifo_chip2fpga_rd_en    ),
        .pipe_out_ready_debug_chip2fpga (pipe_out_ready_debug_chip2fpga),
        .pipe_out_valid_debug_chip2fpga (pipe_out_valid_debug_chip2fpga),
        .pipe_dout_debug_chip2fpga      (pipe_dout_debug_chip2fpga     ),

        /* FIFO for axaddr and axlen handshaking debugging */
        .debug_fifo_axaddr_read         (debug_fifo_axaddr_read         ),
        .debug_fifo_axaddr_rd_en        (debug_fifo_axaddr_rd_en        ),
        .pipe_out_ready_debug_axaddr    (pipe_out_ready_debug_axaddr    ),
        .pipe_out_valid_debug_axaddr    (pipe_out_valid_debug_axaddr    ),
        .pipe_dout_debug_axaddr         (pipe_dout_debug_axaddr         ),


        /* FIFO for rdata transfer debugging */
        .debug_fifo_rdata_read          (debug_fifo_rdata_read          ),
        .debug_fifo_rdata_rd_en         (debug_fifo_rdata_rd_en         ),
        .pipe_out_ready_debug_rdata     (pipe_out_ready_debug_rdata     ),
        .pipe_out_valid_debug_rdata     (pipe_out_valid_debug_rdata     ),
        .pipe_dout_debug_rdata          (pipe_dout_debug_rdata          ),

        /* FIFO for wdata transfer debugging */
        .debug_fifo_wdata_read          (debug_fifo_wdata_read          ),
        .debug_fifo_wdata_rd_en         (debug_fifo_wdata_rd_en         ),
        .pipe_out_ready_debug_wdata     (pipe_out_ready_debug_wdata     ),
        .pipe_out_valid_debug_wdata     (pipe_out_valid_debug_wdata     ),
        .pipe_dout_debug_wdata          (pipe_dout_debug_wdata          ),

        /* Debug of regular FIFOs btw chip <-> MIG */
        .araddr_fifo_rd_en_debug        (araddr_fifo_rd_en_debug       ),
        .araddr_fifo_wr_en_debug        (araddr_fifo_wr_en_debug       ),
        .araddr_fifo_valid_debug        (araddr_fifo_valid_debug       ), 
        .araddr_fifo_empty_debug        (araddr_fifo_empty_debug       ), 
        .araddr_fifo_full_debug         (araddr_fifo_full_debug        ),
        .araddr_fifo_prog_full_debug    (araddr_fifo_prog_full_debug   ), 

        .awaddr_fifo_rd_en_debug        (awaddr_fifo_rd_en_debug       ),
        .awaddr_fifo_wr_en_debug        (awaddr_fifo_wr_en_debug       ),
        .awaddr_fifo_valid_debug        (awaddr_fifo_valid_debug       ), 
        .awaddr_fifo_empty_debug        (awaddr_fifo_empty_debug       ), 
        .awaddr_fifo_full_debug         (awaddr_fifo_full_debug        ), 
        .awaddr_fifo_prog_full_debug    (awaddr_fifo_prog_full_debug   ), 

        .rdata_fifo_rd_en_debug         (rdata_fifo_rd_en_debug        ),
        .rdata_fifo_wr_en_debug         (rdata_fifo_wr_en_debug        ),
        .rdata_fifo_valid_debug         (rdata_fifo_valid_debug        ), 
        .rdata_fifo_empty_debug         (rdata_fifo_empty_debug        ), 
        .rdata_fifo_full_debug          (rdata_fifo_full_debug         ), 
        .rdata_fifo_prog_full_debug     (rdata_fifo_prog_full_debug    ), 

        .wdata_fifo_rd_en_debug         (wdata_fifo_rd_en_debug        ),
        .wdata_fifo_wr_en_debug         (wdata_fifo_wr_en_debug        ),
        .wdata_fifo_valid_debug         (wdata_fifo_valid_debug        ), 
        .wdata_fifo_empty_debug         (wdata_fifo_empty_debug        ), 
        .wdata_fifo_full_debug          (wdata_fifo_full_debug         ), 
        .wdata_fifo_prog_full_debug     (wdata_fifo_prog_full_debug    ),

        /* Debug (DDR3Interface) */
        .s_axi_arready_debug     (s_axi_arready_debug ),
        .s_axi_rvalid_debug      (s_axi_rvalid_debug  ),
        .s_axi_wstate_debug      (s_axi_wstate_debug  ),
        .s_axi_wready_debug      (s_axi_wready_debug  ),
        .mig_rstate_cnt          (mig_rstate_cnt      ),
        .mig_rvalid_cnt          (mig_rvalid_cnt      ),
        .mig_wstate_cnt          (mig_wstate_cnt      ),
        .mig_wvalid_cnt          (mig_wvalid_cnt      )
    );



    //************************************************************
    // ChipInterface
    //************************************************************

    chipInterface u_chipInterface (
        .clk_for_chip                   (clk_for_chip                  ),
        .clk_for_chip_in                (clk_for_chip_in               ),
        .clk_for_chip_out               (clk_for_chip_out              ),
        .mig_clk                        (mig_clk                       ),
        .okClk                          (okClk                         ),
        .rstn                           (rstn                          ),

        /* okFP <-> Chip */
        // chip_clk domain
        .start_network                  (start_network                 ),
        .start_store_byte4              (start_store_byte4_w           ),
        .start_layer                    (start_w                       ),
        .single_rate                    (single_rate_w                 ),  
        .n_layers                       (n_layers                      ),
        .infinite_loop                  (infinite_loop                 ),
        .wait_chip_cnt                  (wait_chip_cnt                 ),
        .done_network                   (done_network                  ),
        .done_layer                     (done_w                        ),
        .done_layer_buf                 (done_layer_buf                ),
        .clk_cnt                        (clk_cnt                       ),
        .chip_axi_read_delay_out        (chip_axi_read_delay           ),

        /* Chip <-> MIG */
        // chip_clk domain
        .load_or_store                  (load_or_store                 ),   
        .store_byte4                    (store_byte4                   ),   
        .data                           (data                          ),
        .axaddr_and_axlen               (axaddr_and_axlen              ),
        .axvalid                        (axvalid                       ),
        .axready                        (axready                       ),
        .rvalid_or_wready               (rvalid_or_wready              ),
        .rready_or_wvalid               (rready_or_wvalid              ),

        // mig_clk domain
        .mig_store_byte4                (chip_store_byte4              ),
        .mig_axi_awaddr                 (chip_axi_awaddr               ),
        .mig_axi_awlen                  (chip_axi_awlen                ),
        .mig_axi_awvalid                (chip_axi_awvalid              ),
        .mig_axi_awready                (chip_axi_awready              ),
        .mig_axi_wdata                  (chip_axi_wdata                ),
        .mig_axi_wvalid                 (chip_axi_wvalid               ),
        .mig_axi_wready                 (chip_axi_wready               ),
        .mig_axi_araddr                 (chip_axi_araddr               ),
        .mig_axi_arlen                  (chip_axi_arlen                ),
        .mig_axi_arvalid                (chip_axi_arvalid              ),
        .mig_axi_arready                (chip_axi_arready              ),
        .mig_axi_rvalid                 (chip_axi_rvalid               ),
        .mig_axi_rvalid_tmp             (chip_axi_rvalid_tmp           ),
        .mig_axi_rready                 (chip_axi_rready               ),
        .mig_axi_rdata                  (chip_axi_rdata                ),

        /* Debug */
        .start_cnt                      (start_cnt                     ),
        .done_cnt                       (done_cnt                      ), 

        .arvalid_cnt                    (arvalid_cnt                   ),
        .arready_cnt                    (arready_cnt                   ),
        .rvalid_cnt                     (rvalid_cnt                    ),

        .awvalid_cnt                    (awvalid_cnt                   ),
        .awready_cnt                    (awready_cnt                   ),
        .wvalid_cnt                     (wvalid_cnt                    ),

        .araddr_hist                    (araddr_hist                   ),
        .arlen_hist                     (arlen_hist                    ),
        .rdata_hist                     (rdata_hist                    ),
        .awaddr_hist                    (awaddr_hist                   ),
        .awlen_hist                     (awlen_hist                    ),
        // .wdata_hist              (wdata_hist                    ),
        .ttf_axvalid                    (ttf_axvalid                   ),

        .debug_fifo_fpga2chip_read      (debug_fifo_fpga2chip_read     ),
        .debug_fifo_fpga2chip_rd_en_out (debug_fifo_fpga2chip_rd_en    ),
        .pipe_out_ready_debug_fpga2chip (pipe_out_ready_debug_fpga2chip),
        .pipe_out_valid_debug_fpga2chip (pipe_out_valid_debug_fpga2chip),
        .pipe_dout_debug_fpga2chip      (pipe_dout_debug_fpga2chip     ),

        .debug_fifo_chip2fpga_read      (debug_fifo_chip2fpga_read     ),
        .debug_fifo_chip2fpga_rd_en_out (debug_fifo_chip2fpga_rd_en    ),
        .pipe_out_ready_debug_chip2fpga (pipe_out_ready_debug_chip2fpga),
        .pipe_out_valid_debug_chip2fpga (pipe_out_valid_debug_chip2fpga),
        .pipe_dout_debug_chip2fpga      (pipe_dout_debug_chip2fpga     ),

        .debug_fifo_axaddr_read         (debug_fifo_axaddr_read        ),
        .debug_fifo_axaddr_rd_en_out    (debug_fifo_axaddr_rd_en       ),
        .pipe_out_ready_debug_axaddr    (pipe_out_ready_debug_axaddr   ),
        .pipe_out_valid_debug_axaddr    (pipe_out_valid_debug_axaddr   ),
        .pipe_dout_debug_axaddr         (pipe_dout_debug_axaddr        ),

        .debug_fifo_rdata_read          (debug_fifo_rdata_read         ),
        .debug_fifo_rdata_rd_en_out     (debug_fifo_rdata_rd_en        ),
        .pipe_out_ready_debug_rdata     (pipe_out_ready_debug_rdata    ),
        .pipe_out_valid_debug_rdata     (pipe_out_valid_debug_rdata    ),
        .pipe_dout_debug_rdata          (pipe_dout_debug_rdata         ),

        .debug_fifo_wdata_read          (debug_fifo_wdata_read         ),
        .debug_fifo_wdata_rd_en_out     (debug_fifo_wdata_rd_en        ),
        .pipe_out_ready_debug_wdata     (pipe_out_ready_debug_wdata    ),
        .pipe_out_valid_debug_wdata     (pipe_out_valid_debug_wdata    ),
        .pipe_dout_debug_wdata          (pipe_dout_debug_wdata         ),

        .araddr_fifo_rd_en_debug        (araddr_fifo_rd_en_debug       ),
        .araddr_fifo_wr_en_debug        (araddr_fifo_wr_en_debug       ),
        .araddr_fifo_valid_debug        (araddr_fifo_valid_debug       ), 
        .araddr_fifo_empty_debug        (araddr_fifo_empty_debug       ), 
        .araddr_fifo_full_debug         (araddr_fifo_full_debug        ),
        .araddr_fifo_prog_full_debug    (araddr_fifo_prog_full_debug   ), 

        .awaddr_fifo_rd_en_debug        (awaddr_fifo_rd_en_debug       ),
        .awaddr_fifo_wr_en_debug        (awaddr_fifo_wr_en_debug       ),
        .awaddr_fifo_valid_debug        (awaddr_fifo_valid_debug       ), 
        .awaddr_fifo_empty_debug        (awaddr_fifo_empty_debug       ), 
        .awaddr_fifo_full_debug         (awaddr_fifo_full_debug        ), 
        .awaddr_fifo_prog_full_debug    (awaddr_fifo_prog_full_debug   ), 

        .rdata_fifo_rd_en_debug         (rdata_fifo_rd_en_debug        ),
        .rdata_fifo_wr_en_debug         (rdata_fifo_wr_en_debug        ),
        .rdata_fifo_valid_debug         (rdata_fifo_valid_debug        ), 
        .rdata_fifo_empty_debug         (rdata_fifo_empty_debug        ), 
        .rdata_fifo_full_debug          (rdata_fifo_full_debug         ), 
        .rdata_fifo_prog_full_debug     (rdata_fifo_prog_full_debug    ), 

        .wdata_fifo_rd_en_debug         (wdata_fifo_rd_en_debug        ),
        .wdata_fifo_wr_en_debug         (wdata_fifo_wr_en_debug        ),
        .wdata_fifo_valid_debug         (wdata_fifo_valid_debug        ), 
        .wdata_fifo_empty_debug         (wdata_fifo_empty_debug        ), 
        .wdata_fifo_full_debug          (wdata_fifo_full_debug         ), 
        .wdata_fifo_prog_full_debug     (wdata_fifo_prog_full_debug    )
    );


    //************************************************************
    // DDR3Interface
    //************************************************************

    DDR3Interface u_DDR3Interface (
        .sys_clk_p               (sys_clk_p          ),
        .sys_clk_n               (sys_clk_n          ),

        .clk                     (mig_clk            ),   // gen by MIG
        .mig_rstn                (mig_rstn           ),   // gen by MIG
        .mig_abort               (mig_abort          ),
        .okRstn                  (okRstn             ),
        .clk_wiz_locked          (locked             ),

        .ddr3_dq                 (ddr3_dq            ),
        .ddr3_dqs_p              (ddr3_dqs_p         ),
        .ddr3_dqs_n              (ddr3_dqs_n         ),
        .ddr3_addr               (ddr3_addr          ),
        .ddr3_ba                 (ddr3_ba            ),
        .ddr3_ras_n              (ddr3_ras_n         ),
        .ddr3_cas_n              (ddr3_cas_n         ),
        .ddr3_we_n               (ddr3_we_n          ),
        .ddr3_reset_n            (ddr3_reset_n       ),  
        .ddr3_ck_p               (ddr3_ck_p          ),
        .ddr3_ck_n               (ddr3_ck_n          ),
        .ddr3_cke                (ddr3_cke           ),
        .ddr3_cs_n               (ddr3_cs_n          ),
        .ddr3_odt                (ddr3_odt           ),
        .ddr3_dm                 (ddr3_dm            ),
        .init_calib_complete     (init_calib_done    ),

        .axi_master              (axi_master         ),
        .chip_store_byte4        (chip_store_byte4   ),    // only write 4byte in the 1st tranfer of the burst
        .chip_single_rate        (single_rate        ),
        .chip_axi_awaddr         (chip_axi_awaddr    ),
        .chip_axi_awlen          (chip_axi_awlen     ),
        .chip_axi_awvalid        (chip_axi_awvalid   ),
        .chip_axi_awready        (chip_axi_awready   ),
        .chip_axi_wdata          (chip_axi_wdata     ),
        .chip_axi_wvalid         (chip_axi_wvalid    ),
        .chip_axi_wready         (chip_axi_wready    ),
        .chip_axi_araddr         (chip_axi_araddr    ),
        .chip_axi_arlen          (chip_axi_arlen     ),
        .chip_axi_arvalid        (chip_axi_arvalid   ),
        .chip_axi_arready        (chip_axi_arready   ),
        .chip_axi_rdata          (chip_axi_rdata     ),     
        .chip_axi_rvalid         (chip_axi_rvalid    ),    // toggled when chip_single_rate == 1'b1
        .chip_axi_rvalid_tmp     (chip_axi_rvalid_tmp),
        .chip_axi_rready         (chip_axi_rready    ),

        .okfp_axi_awaddr         (okfp_axi_awaddr    ),
        .okfp_axi_awlen          (okfp_axi_awlen     ),
        .okfp_axi_awvalid        (okfp_axi_awvalid   ),
        .okfp_axi_awready        (okfp_axi_awready   ),
        .okfp_axi_wdata          (okfp_axi_wdata     ),
        .okfp_axi_wvalid         (okfp_axi_wvalid    ),
        .okfp_axi_wready         (okfp_axi_wready    ),
        .okfp_axi_araddr         (okfp_axi_araddr    ),
        .okfp_axi_arlen          (okfp_axi_arlen     ),
        .okfp_axi_arvalid        (okfp_axi_arvalid   ),
        .okfp_axi_arready        (okfp_axi_arready   ),
        .okfp_axi_rdata          (okfp_axi_rdata     ),
        .okfp_axi_rvalid         (okfp_axi_rvalid    ),
        .okfp_axi_rready         (okfp_axi_rready    ),

        /* Debug */
        .s_axi_arready_debug     (s_axi_arready_debug ),
        .s_axi_rvalid_debug      (s_axi_rvalid_debug  ),
        .s_axi_wstate_debug      (s_axi_wstate_debug  ),
        .s_axi_wready_debug      (s_axi_wready_debug  ),
        .mig_rstate_cnt          (mig_rstate_cnt      ),
        .mig_rvalid_cnt          (mig_rvalid_cnt      ),
        .mig_wstate_cnt          (mig_wstate_cnt      ),
        .mig_wvalid_cnt          (mig_wvalid_cnt      )
    );



    //************************************************************
    // LEDs 
    //************************************************************

    function [3:0] xem7360_led;
        input [3:0] a;
        integer i;
        begin
            for(i=0; i<4; i=i+1) begin: u
                xem7360_led[i] = (a[i]==1'b1) ? (1'b0) : (1'bz);
            end
        end
    endfunction
endmodule