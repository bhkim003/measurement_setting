`timescale 1ps/100fs



module top_dram_mig_sim_tb;


    //***************************************************************************

    // The following parameters refer to width of various ports

    //***************************************************************************

    parameter COL_WIDTH             = 10;

                                    // # of memory Column Address bits.

    parameter CS_WIDTH              = 1;

                                      // # of unique CS outputs to memory.

    parameter DM_WIDTH              = 4;

                                      // # of DM (data mask)

    parameter DQ_WIDTH              = 32;

                                      // # of DQ (data)

    parameter DQS_WIDTH             = 4;

    parameter DQS_CNT_WIDTH         = 2;

                                      // = ceil(log2(DQS_WIDTH))

    parameter DRAM_WIDTH            = 8;

                                      // # of DQ per DQS

    parameter ECC                   = "OFF";

    parameter RANKS                 = 1;

                                      // # of Ranks.

    parameter ODT_WIDTH             = 1;

                                      // # of ODT outputs to memory.

    parameter ROW_WIDTH             = 15;

                                      // # of memory Row Address bits.

    parameter ADDR_WIDTH            = 29;

                                      // # = RANK_WIDTH + BANK_WIDTH

                                      //     + ROW_WIDTH + COL_WIDTH;

                                      // Chip Select is always tied to low for

                                      // single rank devices

    //***************************************************************************

    // The following parameters are mode register settings

    //***************************************************************************

    parameter BURST_MODE            = "8";

                                      // DDR3 SDRAM:

                                      // Burst Length (Mode Register 0).

                                      // # = "8", "4", "OTF".

                                      // DDR2 SDRAM:

                                      // Burst Length (Mode Register).

                                      // # = "8", "4".

    parameter CA_MIRROR             = "OFF";

                                      // C/A mirror opt for DDR3 dual rank

    

    //***************************************************************************

    // The following parameters are multiplier and divisor factors for PLLE2.

    // Based on the selected design frequency these parameters vary.

    //***************************************************************************

    parameter CLKIN_PERIOD          = 5000;

                                      // Input Clock Period





    //***************************************************************************

    // Simulation parameters

    //***************************************************************************

    parameter SIM_BYPASS_INIT_CAL   = "FAST";

                                      // # = "SIM_INIT_CAL_FULL" -  Complete

                                      //              memory init &

                                      //              calibration sequence

                                      // # = "SKIP" - Not supported

                                      // # = "FAST" - Complete memory init & use

                                      //              abbreviated calib sequence



    //***************************************************************************

    // IODELAY and PHY related parameters

    //***************************************************************************

    parameter TCQ                   = 100;

    //***************************************************************************

    // IODELAY and PHY related parameters

    //***************************************************************************

    parameter RST_ACT_LOW           = 0;

                                      // =1 for active low reset,

                                      // =0 for active high.



    //***************************************************************************

    // Referece clock frequency parameters

    //***************************************************************************

    parameter REFCLK_FREQ           = 200.0;

                                      // IODELAYCTRL reference clock frequency

    //***************************************************************************

    // System clock frequency parameters

    //***************************************************************************

    parameter tCK                   = 2500;

                                      // memory tCK paramter.

                      // # = Clock Period in pS.

    parameter nCK_PER_CLK           = 4;

                                      // # of memory CKs per fabric CLK



   



    //***************************************************************************

    // Debug and Internal parameters

    //***************************************************************************

    parameter DEBUG_PORT            = "OFF";

                                      // # = "ON" Enable debug signals/controls.

                                      //   = "OFF" Disable debug signals/controls.

    //***************************************************************************

    // Debug and Internal parameters

    //***************************************************************************

    parameter DRAM_TYPE             = "DDR3";



    



    //**************************************************************************//

    // Local parameters Declarations

    //**************************************************************************//



    localparam real TPROP_DQS          = 0.00;

                                        // Delay for DQS signal during Write Operation

    localparam real TPROP_DQS_RD       = 0.00;

                        // Delay for DQS signal during Read Operation

    localparam real TPROP_PCB_CTRL     = 0.00;

                        // Delay for Address and Ctrl signals

    localparam real TPROP_PCB_DATA     = 0.00;

                        // Delay for data signal during Write operation

    localparam real TPROP_PCB_DATA_RD  = 0.00;

                        // Delay for data signal during Read operation



    localparam MEMORY_WIDTH            = 8;

    localparam NUM_COMP                = DQ_WIDTH/MEMORY_WIDTH;

    localparam ECC_TEST 		   	= "OFF" ;

    localparam ERR_INSERT = (ECC_TEST == "ON") ? "OFF" : ECC ;

    



    localparam real REFCLK_PERIOD = (1000000.0/(2*REFCLK_FREQ));

    // localparam RESET_PERIOD = 200000; //in pSec  
    localparam RESET_PERIOD = 200200000; //in pSec  

    localparam real SYSCLK_PERIOD = tCK;

      

    



    //**************************************************************************//

    // Wire Declarations

    //**************************************************************************//

    reg                                wire_rst_n;

    wire                               wire_rst;





    reg                     sys_clk_i;

    wire                               sys_clk_p;

    wire                               sys_clk_n;

      



    reg clk_ref_i;



    

    wire                               ddr3_reset_n;

    wire [DQ_WIDTH-1:0]                ddr3_dq_fpga;

    wire [DQS_WIDTH-1:0]               ddr3_dqs_p_fpga;

    wire [DQS_WIDTH-1:0]               ddr3_dqs_n_fpga;

    wire [ROW_WIDTH-1:0]               ddr3_addr_fpga;

    wire [3-1:0]              ddr3_ba_fpga;

    wire                               ddr3_ras_n_fpga;

    wire                               ddr3_cas_n_fpga;

    wire                               ddr3_we_n_fpga;

    wire [1-1:0]               ddr3_cke_fpga;

    wire [1-1:0]                ddr3_ck_p_fpga;

    wire [1-1:0]                ddr3_ck_n_fpga;

      

    

    wire                               init_calib_complete;

    wire                               tg_compare_error;

    

    wire [DM_WIDTH-1:0]                ddr3_dm_fpga;

      

    wire [ODT_WIDTH-1:0]               ddr3_odt_fpga;

      

    

    

    reg [DM_WIDTH-1:0]                 ddr3_dm_sdram_tmp;

      

    reg [ODT_WIDTH-1:0]                ddr3_odt_sdram_tmp;

      



    

    wire [DQ_WIDTH-1:0]                ddr3_dq_sdram;

    wire [ROW_WIDTH-1:0]                ddr3_addr_sdram [0:1];

    wire [3-1:0]               ddr3_ba_sdram [0:1];

    wire                                ddr3_ras_n_sdram;

    wire                                ddr3_cas_n_sdram;

    wire                                ddr3_we_n_sdram;

    wire [(CS_WIDTH*1)-1:0] ddr3_cs_n_sdram;

    wire [ODT_WIDTH-1:0]               ddr3_odt_sdram;

    wire [1-1:0]                ddr3_cke_sdram;

    wire [DM_WIDTH-1:0]                ddr3_dm_sdram;

    wire [DQS_WIDTH-1:0]               ddr3_dqs_p_sdram;

    wire [DQS_WIDTH-1:0]               ddr3_dqs_n_sdram;

    wire [1-1:0]                 ddr3_ck_p_sdram;

    wire [1-1:0]                 ddr3_ck_n_sdram;

  

    


    

    //**************************************************************************//

    // Memory Models instantiations

    //**************************************************************************//



    genvar r,ii;

    generate

      for (r = 0; r < CS_WIDTH; r = r + 1) begin: mem_rnk

        for (ii = 0; ii < NUM_COMP; ii = ii + 1) begin: gen_mem

          ddr3_model u_comp_ddr3

            (

            .rst_n   (ddr3_reset_n),

            .ck      (ddr3_ck_p_sdram),

            .ck_n    (ddr3_ck_n_sdram),

            .cke     (ddr3_cke_sdram[r]),

            .cs_n    (ddr3_cs_n_sdram[r]), // 0 tie 

            .ras_n   (ddr3_ras_n_sdram),

            .cas_n   (ddr3_cas_n_sdram),

            .we_n    (ddr3_we_n_sdram),

            .dm_tdqs (ddr3_dm_sdram[ii]), 

            .ba      (ddr3_ba_sdram[r]),

            .addr    (ddr3_addr_sdram[r]),

            .dq      (ddr3_dq_sdram[MEMORY_WIDTH*(ii+1)-1:MEMORY_WIDTH*(ii)]),

            .dqs     (ddr3_dqs_p_sdram[ii]),

            .dqs_n   (ddr3_dqs_n_sdram[ii]),

            .tdqs_n  (),

            .odt     (ddr3_odt_sdram[r])

            );

        end

      end

    endgenerate

    

      




    // ########################## MIG ########################################################################################
    wire          		ui_clk_sync_rst;


    wire	         	app_rdy;
    wire	         	app_en;
    wire	[3 - 1:0] 	app_cmd;
    wire	[29 - 1:0]	app_addr; // 30bit address @ 7360?, 29bit @ 7310? Please Check
    wire	[256 - 1:0] app_rd_data;
    wire	         	app_rd_data_end;
    wire	         	app_rd_data_valid;
    wire	         	app_wdf_rdy;
    wire	         	app_wdf_wren;
    wire	[256 - 1:0] app_wdf_data;
    wire	         	app_wdf_end;
    wire	[32 - 1:0]  app_wdf_mask;

    mig_7series_0 u_mig_7series_0(
        .device_temp                      (                       ),







        // Memory interface ports
          .ddr3_addr                        ( ddr3_addr_sdram[0]                        ),
          .ddr3_ba                          ( ddr3_ba_sdram[0]                          ),
          .ddr3_cas_n                       ( ddr3_cas_n_sdram                       ),
          .ddr3_ck_n                        ( ddr3_ck_n_sdram                        ),
          .ddr3_ck_p                        ( ddr3_ck_p_sdram                        ),
          .ddr3_cke                         ( ddr3_cke_sdram                         ),
          .ddr3_ras_n                       ( ddr3_ras_n_sdram                       ),
          .ddr3_reset_n                     ( ddr3_reset_n                     ),
          .ddr3_we_n                        ( ddr3_we_n_sdram                        ),
          .ddr3_dq                          (   ddr3_dq_sdram                   ),
          .ddr3_dqs_n                       (   ddr3_dqs_n_sdram                ),
          .ddr3_dqs_p                       (   ddr3_dqs_p_sdram                ),

        .init_calib_complete              (   init_calib_complete            ),

        // .ddr3_cs_n                      (ddr3_cs_n),
        .ddr3_odt                         (   ddr3_dm_sdram                ),
        .ddr3_dm                          (   ddr3_odt_sdram                ),










        // Application interface ports
        .app_addr                         ( app_addr                         ),
        .app_cmd                          ( app_cmd                          ),
        .app_en                           ( app_en                           ),
        .app_wdf_data                     ( app_wdf_data                     ),
        .app_wdf_end                      ( app_wdf_end                      ),
        .app_wdf_wren                     ( app_wdf_wren                     ),
        .app_rd_data                      ( app_rd_data                      ),
        .app_rd_data_end                  ( app_rd_data_end                  ),
        .app_rd_data_valid                ( app_rd_data_valid                ),
        .app_rdy                          ( app_rdy                          ),
        .app_wdf_rdy                      ( app_wdf_rdy                      ),
        .app_sr_req                       ( 1'b0                       ),
        .app_sr_active                    (                     ),
        .app_ref_req                      ( 1'b0                      ),
        .app_ref_ack                      (                       ),
        .app_zq_req                       ( 1'b0                       ),
        .app_zq_ack                       (                        ),
        .ui_clk                           ( ui_clk                           ),
        .ui_clk_sync_rst                  ( ui_clk_sync_rst                  ),

        .app_wdf_mask                     ( app_wdf_mask                     ),

        // System Clock Ports
        .sys_clk_p                        ( sys_clk_p                        ),
        .sys_clk_n                        ( sys_clk_n                        ),

        .sys_rst                          ( !wire_rst_n                  )
    );
    // ########################## MIG ########################################################################################











    //**************************************************************************//

    // Reset wire

    //**************************************************************************//


    assign wire_rst = RST_ACT_LOW ? wire_rst_n : ~wire_rst_n;



    //**************************************************************************//

    // Clock Generation

    //**************************************************************************//



    initial
      sys_clk_i = 1'b0;
    always
      sys_clk_i = #(CLKIN_PERIOD/2.0) ~sys_clk_i;

    assign sys_clk_p = sys_clk_i;
    assign sys_clk_n = ~sys_clk_i;



    initial
      clk_ref_i = 1'b0;
    always
      clk_ref_i = #REFCLK_PERIOD ~clk_ref_i;



    initial begin
        wire_rst_n = 1'b0;
        #RESET_PERIOD
        wire_rst_n = 1'b1;


    end


endmodule



