// Opalkelly xem7360 75A testbench with DDR3 DRAM model
// 260109 Byeonghoon Kim, MMS Korea
// `timescale 1ps/100fs
`timescale 1ps/1ps



module top_bh_fpga_with_dram_tb;


// ================================ DONT TOUCH BELOW ========================================================================================================
// ================================ DONT TOUCH BELOW ========================================================================================================
// ================================ DONT TOUCH BELOW ========================================================================================================
// ================================ DONT TOUCH BELOW ========================================================================================================
// ================================ DONT TOUCH BELOW ========================================================================================================
// ================================ DONT TOUCH BELOW ========================================================================================================
// ================================ DONT TOUCH BELOW ========================================================================================================
// ================================ DONT TOUCH BELOW ========================================================================================================
// ================================ DONT TOUCH BELOW ========================================================================================================
// ================================ DONT TOUCH BELOW ========================================================================================================
// ================================ DONT TOUCH BELOW ========================================================================================================
// ================================ DONT TOUCH BELOW ========================================================================================================
// ================================ DONT TOUCH BELOW ========================================================================================================
// ================================ DONT TOUCH BELOW ========================================================================================================
// ================================ DONT TOUCH BELOW ========================================================================================================
// ================================ DONT TOUCH BELOW ========================================================================================================
// ================================ DONT TOUCH BELOW ========================================================================================================


   //***************************************************************************

   // Traffic Gen related parameters

   //***************************************************************************

   parameter SIMULATION            = "TRUE";

   parameter PORT_MODE             = "BI_MODE";

   parameter DATA_MODE             = 4'b0010;

   parameter TST_MEM_INSTR_MODE    = "R_W_INSTR_MODE";

   parameter EYE_TEST              = "FALSE";

                                     // set EYE_TEST = "TRUE" to probe memory

                                     // signals. Traffic Generator will only

                                     // write to one single location and no

                                     // read transactions will be generated.

   parameter DATA_PATTERN          = "DGEN_ALL";

                                      // For small devices, choose one only.

                                      // For large device, choose "DGEN_ALL"

                                      // "DGEN_HAMMER", "DGEN_WALKING1",

                                      // "DGEN_WALKING0","DGEN_ADDR","

                                      // "DGEN_NEIGHBOR","DGEN_PRBS","DGEN_ALL"

   parameter CMD_PATTERN           = "CGEN_ALL";

                                      // "CGEN_PRBS","CGEN_FIXED","CGEN_BRAM",

                                      // "CGEN_SEQUENTIAL", "CGEN_ALL"

   parameter BEGIN_ADDRESS         = 32'h00000000;

   parameter END_ADDRESS           = 32'h00000fff;

   parameter PRBS_EADDR_MASK_POS   = 32'hff000000;



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

   parameter ROW_WIDTH             = 16;

                                     // # of memory Row Address bits.

   parameter ADDR_WIDTH            = 30;

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

   parameter tCK                   = 1250;

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

  localparam RESET_PERIOD = 200000; //in pSec  

  localparam real SYSCLK_PERIOD = tCK;

    

    



  //**************************************************************************//

  // Wire Declarations

  //**************************************************************************//

  reg                                sys_rst_n;

  wire                               sys_rst;





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

    

  

  reg                               init_calib_complete_at_top_tb;

  wire                               tg_compare_error;

  
  wire [(CS_WIDTH*1)-1:0] ddr3_cs_n_fpga;

  wire [DM_WIDTH-1:0]                ddr3_dm_fpga;

    

  wire [ODT_WIDTH-1:0]               ddr3_odt_fpga;

    


  reg [(CS_WIDTH*1)-1:0] ddr3_cs_n_sdram_tmp;
  

  

  reg [DM_WIDTH-1:0]                 ddr3_dm_sdram_tmp;

    

  reg [ODT_WIDTH-1:0]                ddr3_odt_sdram_tmp;

    



  

  wire [DQ_WIDTH-1:0]                ddr3_dq_sdram;

  reg [ROW_WIDTH-1:0]                ddr3_addr_sdram [0:1];

  reg [3-1:0]               ddr3_ba_sdram [0:1];

  reg                                ddr3_ras_n_sdram;

  reg                                ddr3_cas_n_sdram;

  reg                                ddr3_we_n_sdram;

  wire [(CS_WIDTH*1)-1:0] ddr3_cs_n_sdram;

  wire [ODT_WIDTH-1:0]               ddr3_odt_sdram;

  reg [1-1:0]                ddr3_cke_sdram;

  wire [DM_WIDTH-1:0]                ddr3_dm_sdram;

  wire [DQS_WIDTH-1:0]               ddr3_dqs_p_sdram;

  wire [DQS_WIDTH-1:0]               ddr3_dqs_n_sdram;

  reg [1-1:0]                 ddr3_ck_p_sdram;

  reg [1-1:0]                 ddr3_ck_n_sdram;

  

    



//**************************************************************************//







  always @( * ) begin

    ddr3_ck_p_sdram      <=  #(TPROP_PCB_CTRL) ddr3_ck_p_fpga;

    ddr3_ck_n_sdram      <=  #(TPROP_PCB_CTRL) ddr3_ck_n_fpga;

    ddr3_addr_sdram[0]   <=  #(TPROP_PCB_CTRL) ddr3_addr_fpga;

    ddr3_addr_sdram[1]   <=  #(TPROP_PCB_CTRL) (CA_MIRROR == "ON") ?

                                                 {ddr3_addr_fpga[ROW_WIDTH-1:9],

                                                  ddr3_addr_fpga[7], ddr3_addr_fpga[8],

                                                  ddr3_addr_fpga[5], ddr3_addr_fpga[6],

                                                  ddr3_addr_fpga[3], ddr3_addr_fpga[4],

                                                  ddr3_addr_fpga[2:0]} :

                                                 ddr3_addr_fpga;

    ddr3_ba_sdram[0]     <=  #(TPROP_PCB_CTRL) ddr3_ba_fpga;

    ddr3_ba_sdram[1]     <=  #(TPROP_PCB_CTRL) (CA_MIRROR == "ON") ?

                                                 {ddr3_ba_fpga[3-1:2],

                                                  ddr3_ba_fpga[0],

                                                  ddr3_ba_fpga[1]} :

                                                 ddr3_ba_fpga;

    ddr3_ras_n_sdram     <=  #(TPROP_PCB_CTRL) ddr3_ras_n_fpga;

    ddr3_cas_n_sdram     <=  #(TPROP_PCB_CTRL) ddr3_cas_n_fpga;

    ddr3_we_n_sdram      <=  #(TPROP_PCB_CTRL) ddr3_we_n_fpga;

    ddr3_cke_sdram       <=  #(TPROP_PCB_CTRL) ddr3_cke_fpga;

  end

    


  always @( * )

    ddr3_cs_n_sdram_tmp   <=  #(TPROP_PCB_CTRL) ddr3_cs_n_fpga;

  assign ddr3_cs_n_sdram =  ddr3_cs_n_sdram_tmp;
    



  always @( * )

    ddr3_dm_sdram_tmp <=  #(TPROP_PCB_DATA) ddr3_dm_fpga;//DM signal generation

  assign ddr3_dm_sdram = ddr3_dm_sdram_tmp;

    



  always @( * )

    ddr3_odt_sdram_tmp  <=  #(TPROP_PCB_CTRL) ddr3_odt_fpga;

  assign ddr3_odt_sdram =  ddr3_odt_sdram_tmp;

    



// Controlling the bi-directional BUS



  genvar dqwd;

  generate

    for (dqwd = 1;dqwd < DQ_WIDTH;dqwd = dqwd+1) begin : dq_delay

      WireDelay #

       (

        .Delay_g    (TPROP_PCB_DATA),

        .Delay_rd   (TPROP_PCB_DATA_RD),

        .ERR_INSERT ("OFF")

       )

      u_delay_dq

       (

        .A             (ddr3_dq_fpga[dqwd]),

        .B             (ddr3_dq_sdram[dqwd]),

        .reset         (sys_rst_n),

        .phy_init_done (init_calib_complete_at_top_tb)

       );

    end

          WireDelay #

       (

        .Delay_g    (TPROP_PCB_DATA),

        .Delay_rd   (TPROP_PCB_DATA_RD),

        .ERR_INSERT ("OFF")

       )

      u_delay_dq_0

       (

        .A             (ddr3_dq_fpga[0]),

        .B             (ddr3_dq_sdram[0]),

        .reset         (sys_rst_n),

        .phy_init_done (init_calib_complete_at_top_tb)

       );

  endgenerate



  genvar dqswd;

  generate

    for (dqswd = 0;dqswd < DQS_WIDTH;dqswd = dqswd+1) begin : dqs_delay

      WireDelay #

       (

        .Delay_g    (TPROP_DQS),

        .Delay_rd   (TPROP_DQS_RD),

        .ERR_INSERT ("OFF")

       )

      u_delay_dqs_p

       (

        .A             (ddr3_dqs_p_fpga[dqswd]),

        .B             (ddr3_dqs_p_sdram[dqswd]),

        .reset         (sys_rst_n),

        .phy_init_done (init_calib_complete_at_top_tb)

       );



      WireDelay #

       (

        .Delay_g    (TPROP_DQS),

        .Delay_rd   (TPROP_DQS_RD),

        .ERR_INSERT ("OFF")

       )

      u_delay_dqs_n

       (

        .A             (ddr3_dqs_n_fpga[dqswd]),

        .B             (ddr3_dqs_n_sdram[dqswd]),

        .reset         (sys_rst_n),

        .phy_init_done (init_calib_complete_at_top_tb)

       );

    end

  endgenerate

    



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

           .cs_n    (ddr3_cs_n_sdram[r]),

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

    

    


// ================================ DONT TOUCH UPPER ========================================================================================================
// ================================ DONT TOUCH UPPER ========================================================================================================
// ================================ DONT TOUCH UPPER ========================================================================================================
// ================================ DONT TOUCH UPPER ========================================================================================================
// ================================ DONT TOUCH UPPER ========================================================================================================
// ================================ DONT TOUCH UPPER ========================================================================================================
// ================================ DONT TOUCH UPPER ========================================================================================================
// ================================ DONT TOUCH UPPER ========================================================================================================
// ================================ DONT TOUCH UPPER ========================================================================================================
// ================================ DONT TOUCH UPPER ========================================================================================================
// ================================ DONT TOUCH UPPER ========================================================================================================
// ================================ DONT TOUCH UPPER ========================================================================================================
// ================================ DONT TOUCH UPPER ========================================================================================================
// ================================ DONT TOUCH UPPER ========================================================================================================
// ================================ DONT TOUCH UPPER ========================================================================================================
// ================================ DONT TOUCH UPPER ========================================================================================================
// ================================ DONT TOUCH UPPER ========================================================================================================






















































    //===========================================================================

    //                         MY DUT

    //===========================================================================


	wire  [4:0]   okUH;
	wire  [2:0]   okHU;
	wire  [31:0]  okUHU;
	wire          okAA;
	wire  [3:0]   led;


		wire clk_port_spare_1_at_testbench;


		wire clk_clock_generator_at_testbench;
		wire reset_at_testbench;

		wire input_streaming_valid_at_testbench;
		wire [65:0] input_streaming_data_at_testbench;
		wire input_streaming_ready_at_testbench;

		wire start_training_signal_at_testbench; 
		wire start_inference_signal_at_testbench; 
		wire start_ready_at_testbench; 

		wire inferenced_label_at_testbench; 


      top_bh_fpga u_top_bh_fpga(
          .okUH                                     ( okUH                                     ),
          .okHU                                     ( okHU                                     ),
          .okUHU                                    ( okUHU                            ),
          .okAA                                     ( okAA                              ),
          .sys_clk_p                                 (  sys_clk_p                                ),
          .sys_clk_n                                 (  sys_clk_n                                ),
          .led                                      ( led                                      ),

          .ddr3_addr                        ( ddr3_addr_fpga                        ),
          .ddr3_ba                          ( ddr3_ba_fpga                          ),
          .ddr3_cas_n                       ( ddr3_cas_n_fpga                       ),
          .ddr3_ck_n                        ( ddr3_ck_n_fpga                        ),
          .ddr3_ck_p                        ( ddr3_ck_p_fpga                        ),
          .ddr3_cke                         ( ddr3_cke_fpga                         ),
          .ddr3_ras_n                       ( ddr3_ras_n_fpga                       ),
          .ddr3_reset_n                     ( ddr3_reset_n                     ),
          .ddr3_we_n                        ( ddr3_we_n_fpga                        ),
          .ddr3_dq                          (   ddr3_dq_fpga                   ),
          .ddr3_dqs_n                       (   ddr3_dqs_n_fpga                ),
          .ddr3_dqs_p                       (   ddr3_dqs_p_fpga                ),
          
          .ddr3_cs_n                         (   ddr3_cs_n_fpga                ),
          .ddr3_odt                         (   ddr3_odt_fpga                ),
          .ddr3_dm                          (   ddr3_dm_fpga                ),

          .clk_clock_generator                      (    clk_clock_generator_at_testbench                   ),
          .clk_port_spare_0                         (                          ),
          .clk_port_spare_1                         (  clk_port_spare_1_at_testbench                        ),

          .margin_pin                         (                          ),

          .reset_n_from_fpga_to_asic                (  reset_at_testbench               ),
          .input_streaming_valid_from_fpga_to_asic  ( input_streaming_valid_at_testbench  ),
          .input_streaming_data_from_fpga_to_asic   ( input_streaming_data_at_testbench   ),
          .input_streaming_ready_from_asic_to_fpga  ( input_streaming_ready_at_testbench  ),
          .start_training_signal_from_fpga_to_asic  (start_training_signal_at_testbench   ),
          .start_inference_signal_from_fpga_to_asic (start_inference_signal_at_testbench  ),
          .start_ready_from_asic_to_fpga            (  start_ready_at_testbench           ),
          .inferenced_label_from_asic_to_fpga       (inferenced_label_at_testbench)
      );



        top_bh u_top_bh(
            .clk                             ( clk_clock_generator_at_testbench                             ),
            .reset_n                         ( reset_at_testbench                         ),
            .input_streaming_valid_i         ( input_streaming_valid_at_testbench         ),
            .input_streaming_data_i          ( input_streaming_data_at_testbench          ),
            .input_streaming_ready_o         ( input_streaming_ready_at_testbench         ),
            .start_training_signal_i         ( start_training_signal_at_testbench         ),
            .start_inference_signal_i        ( start_inference_signal_at_testbench        ),
            .start_ready_o                   ( start_ready_at_testbench                   ),
            .inferenced_label_o              ( inferenced_label_at_testbench              )
        );





















// OPAL KELLY CONFIG. DONT TOUCH BELOW------------------------------------------
// OPAL KELLY CONFIG. DONT TOUCH BELOW------------------------------------------
// OPAL KELLY CONFIG. DONT TOUCH BELOW------------------------------------------
// OPAL KELLY CONFIG. DONT TOUCH BELOW------------------------------------------

    //------------------------------------------------------------------------
    // Begin okHostInterface simulation user configurable global data
    //------------------------------------------------------------------------
    parameter BlockDelayStates = 5;   // REQUIRED: # of clocks between blocks of pipe data
    parameter ReadyCheckDelay = 5;    // REQUIRED: # of clocks before block transfer before
                                      //  host interface checks for ready (0-255)
    parameter PostReadyDelay = 5;     // REQUIRED: # of clocks after ready is asserted and
                                      //  check that the block transfer begins (0-255)
    parameter pipeInSize = 16384;       // REQUIRED: byte (must be even) length of default
    // parameter pipeInSize = 10*1024*1024;       // REQUIRED: byte (must be even) length of default
                                      //  PipeIn; Integer 0-2^32
    parameter pipeOutSize = 16384;      // REQUIRED: byte (must be even) length of default
    // parameter pipeOutSize = 10*1024*1024;      // REQUIRED: byte (must be even) length of default
                                      // PipeOut; Integer 0-2^32
    parameter registerSetSize = 32;   // Size of array for register set commands.

    parameter Tsys_clk = 5;           // 100Mhz
    //-------------------------------------------------------------------------


	// Pipes
	integer k;
	reg  [7:0]  pipeIn [0:(pipeInSize-1)];
	initial for (k=0; k<pipeInSize; k=k+1) pipeIn[k] = 8'h00;

	reg  [7:0]  pipeOut [0:(pipeOutSize-1)];
	initial for (k=0; k<pipeOutSize; k=k+1) pipeOut[k] = 8'h00;

	// Registers
	reg [31:0] u32Address  [0:(registerSetSize-1)];
	reg [31:0] u32Data     [0:(registerSetSize-1)];
	reg [31:0] u32Count;

	//------------------------------------------------------------------------
	//  Available User Task and Function Calls:
	//    FrontPanelReset;                 // Always start routine with FrontPanelReset;
	//    SetWireInValue(ep, val, mask);
	//    UpdateWireIns;
	//    UpdateWireOuts;
	//    GetWireOutValue(ep);
	//    ActivateTriggerIn(ep, bit);      // bit is an integer 0-15
	//    UpdateTriggerOuts;
	//    IsTriggered(ep, mask);           // Returns a 1 or 0
	//    WriteToPipeIn(ep, length);       // passes pipeIn array data
	//    ReadFromPipeOut(ep, length);     // passes data to pipeOut array
	//    WriteToBlockPipeIn(ep, blockSize, length);   // pass pipeIn array data; blockSize and length are integers
	//    ReadFromBlockPipeOut(ep, blockSize, length); // pass data to pipeOut array; blockSize and length are integers
	//		WriteRegister(address, data);
	//		ReadRegister(address, data);
	//		WriteRegisterSet;                // writes all values in u32Data to the addresses in u32Address
	//		ReadRegisterSet;                 // reads all values in the addresses in u32Address to the array u32Data
	//
	//    *Pipes operate by passing arrays of data back and forth to the user's
	//    design.  If you need multiple arrays, you can create a new procedure
	//    above and connect it to a differnet array.  More information is
	//    available in Opal Kelly documentation and online support tutorial.
	//-------





// OPAL KELLY CONFIG. DONT TOUCH UPPER ------------------------------------------------
// OPAL KELLY CONFIG. DONT TOUCH UPPER ------------------------------------------------
// OPAL KELLY CONFIG. DONT TOUCH UPPER ------------------------------------------------
// OPAL KELLY CONFIG. DONT TOUCH UPPER ------------------------------------------------












//------------------------------------------------------------------------
    // Variables & Registers
    //------------------------------------------------------------------------
    wire [31:0] NO_MASK = 32'hffff_ffff;
    integer i;

	wire signed [31:0] l1_cuts [0:14];
	assign l1_cuts[0]=128; 
	assign l1_cuts[1]=-97;
	assign l1_cuts[2]=-97;
	assign l1_cuts[3]=-97;
	assign l1_cuts[4]=-97;
	assign l1_cuts[5]=-97;
	assign l1_cuts[6]=-97;
	assign l1_cuts[7]=-97;
	assign l1_cuts[8]=-97;
	assign l1_cuts[9]=-97;
	assign l1_cuts[10]=-97;
	assign l1_cuts[11]=-97;
	assign l1_cuts[12]=-97;
	assign l1_cuts[13]=-97;
	assign l1_cuts[14]=354;

	wire signed [31:0] l2_cuts [0:14];
	assign l2_cuts[0]=128; 
	assign l2_cuts[1]=-97;
	assign l2_cuts[2]=-97;
	assign l2_cuts[3]=-97;
	assign l2_cuts[4]=-97;
	assign l2_cuts[5]=-97;
	assign l2_cuts[6]=-97;
	assign l2_cuts[7]=-97;
	assign l2_cuts[8]=-97;
	assign l2_cuts[9]=-97;
	assign l2_cuts[10]=-97;
	assign l2_cuts[11]=-97;
	assign l2_cuts[12]=-97;
	assign l2_cuts[13]=-97;
	assign l2_cuts[14]=354;
	
  // task definition

    //------------------------------------------------------------------------
    // Task: Wait_TriggerOut
    // 특정 Endpoint와 Bit Mask에 대해 Trigger가 발생할 때까지 대기합니다.
    // 타임아웃 기능은 없으며, 시뮬레이션 환경에서만 사용해야 합니다.
    //------------------------------------------------------------------------
	task Wait_TriggerOut (
        input [7:0]  ep,
        input [31:0] bit_mask
    );
        time start_time;
        begin
            start_time = $time;
            UpdateTriggerOuts;
            
            // Trigger가 발생했거나 타임아웃이 될 때까지 반복
            while (IsTriggered(ep, bit_mask) == 0) begin
                #10; // 10ns마다 체크 (시뮬레이션 부하 감소)
                UpdateTriggerOuts;
            end
            $display("[SUCCESS] Trigger 0x%h (mask: 0x%h) detected at %0t", ep, bit_mask, $time);
        end
    endtask

//------------------------------------------------------------------------
    // Task: P_CONFIG_SEQUENCE
    // 파이썬의 p_config 주입 과정을 그대로 재현합니다.
    //------------------------------------------------------------------------
    task P_CONFIG_SEQUENCE;
        begin
            $display("######### Starting p_config mode #########");

            // 1. Config Mode On (Python: fpga.SetWireInValue(0x01, 1) -> Trigger(0x40, 0))
            SetWireInValue(8'h01, 32'd1, NO_MASK);
            UpdateWireIns;
            ActivateTriggerIn(8'h40, 0);
            SetWireInValue(8'h01, 32'd0, NO_MASK);
            UpdateWireIns;
            #100;

            // 2. asic_mode (Value: 0, Trigger: 1)
            $display("Configuring asic_mode...");
            SetWireInValue(8'h01, 32'd0, NO_MASK); // value
            UpdateWireIns;
            ActivateTriggerIn(8'h40, 1);           // trigger
            #100;

            // 3. training_epochs (Value: 200, Trigger: 2)
            $display("Configuring training_epochs...");
            SetWireInValue(8'h01, 32'd200, NO_MASK);
            UpdateWireIns;
            ActivateTriggerIn(8'h40, 2);
            #100;

            // 4. inference_epochs (Value: 500, Trigger: 3)
            SetWireInValue(8'h01, 32'd200, NO_MASK);
            UpdateWireIns;
            ActivateTriggerIn(8'h40, 3);
            #100;

            // 5. dataset (Value: 1, Trigger: 4)
            SetWireInValue(8'h01, 32'd1, NO_MASK);
            UpdateWireIns;
            ActivateTriggerIn(8'h40, 4);
            #100;

            // 6. timesteps (Value: 5, Trigger: 5)
            SetWireInValue(8'h01, 32'd5, NO_MASK);
            UpdateWireIns;
            ActivateTriggerIn(8'h40, 5);
            #100;

            // 7. input_size_layer1 (Value: 578, Trigger: 6)
            SetWireInValue(8'h01, 32'd578, NO_MASK);
            UpdateWireIns;
            ActivateTriggerIn(8'h40, 6);
            #100;

            // 8. long_time_input_streaming_mode (Value: 0, Trigger: 7)
            SetWireInValue(8'h01, 32'd0, NO_MASK);
            UpdateWireIns;
            ActivateTriggerIn(8'h40, 7);
            #100;

            // 9. binary_classifier_mode (Value: 0, Trigger: 8)
            SetWireInValue(8'h01, 32'd0, NO_MASK);
            UpdateWireIns;
            ActivateTriggerIn(8'h40, 8);
            #100;

            // 10. loser_encourage_mode (Value: 0, Trigger: 9)
            SetWireInValue(8'h01, 32'd0, NO_MASK);
            UpdateWireIns;
            ActivateTriggerIn(8'h40, 9);
            #100;
			
            // 11. layer1_cut_list (Loop 15 times, Trigger: 10)
            // 파이썬 리스트의 값을 순차적으로 주입
            $display("Configuring layer1_cut_list...");
            begin
                for (i=0; i<15; i=i+1) begin
                    SetWireInValue(8'h01, l1_cuts[i], NO_MASK);
                    UpdateWireIns;
                    ActivateTriggerIn(8'h40, 10);
                    #100;
                end
            end

			
            // 12. layer2_cut_list (Loop 15 times, Trigger: 11)
            // 파이썬 리스트의 값을 순차적으로 주입
            $display("Configuring layer2_cut_list...");
            begin
                for (i=0; i<15; i=i+1) begin
                    SetWireInValue(8'h01, l1_cuts[i], NO_MASK);
                    UpdateWireIns;
                    ActivateTriggerIn(8'h40, 11);
                    #100;
                end
            end

			SetWireInValue(8'h01, 32'd0, NO_MASK);
			UpdateWireIns;


        end
    endtask









    // reg [980 - 1:0] gesture_one_timestep;
    // reg [980 + 4 - 1:0] gesture_one_timestep_front_label;
    // reg [(980 + 4)*10 + 144 - 1:0] gesture_one_sample;

    reg [578 - 1:0] nmnist_one_timestep;
    reg [578 + 4 - 1:0] nmnist_one_timestep_front_label;
    reg [(578 + 4)*10 + 162 - 1:0] nmnist_one_sample;








   assign sys_rst = RST_ACT_LOW ? sys_rst_n : ~sys_rst_n;



  initial

    sys_clk_i = 1'b0;

  always

    sys_clk_i = #(CLKIN_PERIOD/2.0) ~sys_clk_i;

  assign #(CLKIN_PERIOD/6.0) clk_clock_generator_at_testbench = sys_clk_i;

  assign sys_clk_p = sys_clk_i;

  assign sys_clk_n = ~sys_clk_i;



  initial

    clk_ref_i = 1'b0;

  always

    clk_ref_i = #REFCLK_PERIOD ~clk_ref_i;


  integer i_pi;
  integer i_pj;
  integer i_pk;
    // ################################## Main Testbench Process #################################################################
    // ################################## Main Testbench Process #################################################################
    // ################################## Main Testbench Process #################################################################
    // ################################## Main Testbench Process #################################################################
    initial begin
        sys_rst_n = 1'b0;
        init_calib_complete_at_top_tb = 1'b0;
        # (RESET_PERIOD);
        sys_rst_n = 1'b1;


        for (i_pi = 0; i_pi < 72; i_pi = i_pi + 1) begin
            nmnist_one_timestep[i_pi*8 +: 8] = i_pi;
        end
        nmnist_one_timestep[72*8 +: 2] = 2'd0;

        nmnist_one_timestep_front_label = {4'd9, nmnist_one_timestep};
        nmnist_one_sample = {162'd0, nmnist_one_timestep_front_label, nmnist_one_timestep_front_label, nmnist_one_timestep_front_label, nmnist_one_timestep_front_label, nmnist_one_timestep_front_label, nmnist_one_timestep_front_label, nmnist_one_timestep_front_label, nmnist_one_timestep_front_label, nmnist_one_timestep_front_label, nmnist_one_timestep_front_label};
        
        // FrontPanel 초기화
        FrontPanelReset;

        // 1. 하드웨어 리셋 시뮬레이션 (Active Low)
        // Python: fpga.reset(reset_address=0x00, active_low=True)
        SetWireInValue(8'h00, 32'h00_00_00_01, NO_MASK);
        UpdateWireIns;
        # (RESET_PERIOD);
        SetWireInValue(8'h00, 32'h00_00_00_00, NO_MASK);
        UpdateWireIns;
        # (RESET_PERIOD);
        SetWireInValue(8'h00, 32'h00_00_00_01, NO_MASK);
        UpdateWireIns;
        # (RESET_PERIOD);



        $display("Waiting for Calibration to complete...");
        // init_calib_complete가 1이 될 때까지 무한 대기
        // wait(u_top_bh_fpga.u_d_domain.u_mig_7series_0.init_calib_complete === 1'b1); 
        Wait_TriggerOut(8'h60, {31'd0,1'b1});
        $display("Calibration Complete! Starting User Logic...");
        init_calib_complete_at_top_tb = 1'b1;

        // 2. 파이썬 설정 시퀀스 실행
        P_CONFIG_SEQUENCE();

        // 9. Config Done Trigger (Python: fpga.ActivateTriggerIn(0x40, 31))
        $display("All configs sent. Triggering Config Transmission...");
        ActivateTriggerIn(8'h40, 31);
		
        // 10. Wait for TriggerOut 0x60 (Python: CheckTriggered)
        // 시뮬레이션에서는 로직이 완료될 때까지 충분히 대기하거나 TriggerOut을 체크하는 로직을 추가합니다.
        // #1000; 
        // UpdateTriggerOuts;
        // @(IsTriggered(8'h60, 1));
        Wait_TriggerOut(8'h60, {31'd0,1'b1});

        // 11. p_config done mode (Python: SetWireInValue(0x01, 2) -> Trigger(0x40, 0))
        $display("######### P_STATE_02_WORKLOAD_CONFIG_DONE #########");
        $display("######### P_STATE_02_WORKLOAD_CONFIG_DONE #########");
        $display("######### P_STATE_02_WORKLOAD_CONFIG_DONE #########");
        $display("######### P_STATE_02_WORKLOAD_CONFIG_DONE #########");
        SetWireInValue(8'h01, 32'd2, NO_MASK);
        UpdateWireIns;
        ActivateTriggerIn(8'h40, 0);
        SetWireInValue(8'h01, 32'd0, NO_MASK);
        UpdateWireIns;



        $display("STREAMING WAIT CYCLE 설정: 7번 넣고 4번기다리기");
        SetWireInValue(8'h01, 32'd4, NO_MASK);
        UpdateWireIns;
        ActivateTriggerIn(8'h40, 27);
        Wait_TriggerOut(8'h60, {31'd0,1'b1});
        SetWireInValue(8'h01, 32'd0, NO_MASK);
        UpdateWireIns;

        $display("Configuration Finished.");




        // $display("######### P_STATE_03_DRAMFILL_WEIGHT_DATA mode ######################################################################");
        // $display("######### P_STATE_03_DRAMFILL_WEIGHT_DATA mode ######################################################################");
        // $display("######### P_STATE_03_DRAMFILL_WEIGHT_DATA mode ######################################################################");
        // $display("######### P_STATE_03_DRAMFILL_WEIGHT_DATA mode ######################################################################");
        // SetWireInValue(8'h01, 32'd3, NO_MASK);
        // UpdateWireIns;
        // ActivateTriggerIn(8'h40, 0);
        // SetWireInValue(8'h01, 32'd0, NO_MASK);
        // UpdateWireIns;


        // // dram write address setting
        // SetWireInValue(8'h01, 32'd0, NO_MASK); // start address
        // UpdateWireIns;
        // ActivateTriggerIn(8'h40, 30);
        // SetWireInValue(8'h01, 32'd110392, NO_MASK); // last address
        // UpdateWireIns;
        // ActivateTriggerIn(8'h40, 30);
        // SetWireInValue(8'h01, 32'd0, NO_MASK);
        // UpdateWireIns;
        // Wait_TriggerOut(8'h60, {31'd0,1'b1});




        // // dram write
        //                     // 256 bit = 64 byte
        // for (i_pk = 0; i_pk < pipeInSize/32; i_pk = i_pk + 1) begin
        //     for (i_pi = 0; i_pi < 32; i_pi = i_pi + 1) begin
        //         // 파이썬에서랑 다름 여기서 msb쪽이 파이썬에선 LSB로 들어감.
        //         pipeIn[i_pi + i_pk*32] = i_pi+1;
        //     end
        // end

        // // 883200 Byte weight data 넣기
        // // 16384Byte넣기 53번
        //     // WriteToBlockPipeIn(8'h80, 16384, 16384);  
        // for (i_pi = 0; i_pi < 53; i_pi = i_pi + 1) begin
        //     WriteToBlockPipeIn(8'h80, 16384, 16384);  
        // end
        // //꼬다리 14848Byte
        // WriteToBlockPipeIn(8'h80, 512, 14848);  


        // Wait_TriggerOut(8'h60, {31'd0,1'b1});



        // $display("######### P_STATE_04_DRAMFILL_WEIGHT_DATA_DONE mode ######################################################################");
        // $display("######### P_STATE_04_DRAMFILL_WEIGHT_DATA_DONE mode ######################################################################");
        // $display("######### P_STATE_04_DRAMFILL_WEIGHT_DATA_DONE mode ######################################################################");
        // $display("######### P_STATE_04_DRAMFILL_WEIGHT_DATA_DONE mode ######################################################################");

        // // 뭐 따로 안 할 거임.



        $display("######### P_STATE_05_DRAMFILL_INFERENCE_DATA mode ######################################################################");
        $display("######### P_STATE_05_DRAMFILL_INFERENCE_DATA mode ######################################################################");
        $display("######### P_STATE_05_DRAMFILL_INFERENCE_DATA mode ######################################################################");
        $display("######### P_STATE_05_DRAMFILL_INFERENCE_DATA mode ######################################################################");

        SetWireInValue(8'h01, 32'd5, NO_MASK);
        UpdateWireIns;
        ActivateTriggerIn(8'h40, 0);
        SetWireInValue(8'h01, 32'd0, NO_MASK);
        UpdateWireIns;



        // dram write address setting
        SetWireInValue(8'h01, 32'd110400, NO_MASK); // start address
        UpdateWireIns;
        ActivateTriggerIn(8'h40, 30);
        // 샘플 3개만
        SetWireInValue(8'h01, 32'd110680, NO_MASK); // last address
        UpdateWireIns;
        ActivateTriggerIn(8'h40, 30);
        SetWireInValue(8'h01, 32'd0, NO_MASK);
        UpdateWireIns;
        Wait_TriggerOut(8'h60, {31'd0,1'b1});






        // gesture three sample pipe in!!!!! 같은 거 걍 3번 때려박음. 총 29952bit
        for (i_pk = 0; i_pk < 3; i_pk = i_pk + 1) begin
            // gesture one sample pipe in!!!!!
            for (i_pj = 0; i_pj < 12; i_pj = i_pj + 1) begin
                for (i_pi = 0; i_pi < 32; i_pi = i_pi + 1) begin
                    // 파이썬에서랑 다름 여기서 msb쪽이 파이썬에선 LSB로 들어감.
                    pipeIn[31 - (   (((i_pi)/4)   * 4) + (3-(i_pi%4)))] = nmnist_one_sample[8*32*i_pj + i_pi*8 +: 8];
                end
                WriteToBlockPipeIn(8'h80, 32, 32);  
            end
        end





        Wait_TriggerOut(8'h60, {31'd0,1'b1});




        $display("######### P_STATE_06_DRAMFILL_TRAINING_DATA mode ######################################################################");
        $display("######### P_STATE_06_DRAMFILL_TRAINING_DATA mode ######################################################################");
        $display("######### P_STATE_06_DRAMFILL_TRAINING_DATA mode ######################################################################");
        $display("######### P_STATE_06_DRAMFILL_TRAINING_DATA mode ######################################################################");


        SetWireInValue(8'h01, 32'd6, NO_MASK);
        UpdateWireIns;
        ActivateTriggerIn(8'h40, 0);
        SetWireInValue(8'h01, 32'd0, NO_MASK);
        UpdateWireIns;




        // dram write address setting
        SetWireInValue(8'h01, 32'd1070400, NO_MASK); // start address
        UpdateWireIns;
        ActivateTriggerIn(8'h40, 30);
        // 샘플 3개만
        SetWireInValue(8'h01, 32'd1070680, NO_MASK); // last address
        UpdateWireIns;
        ActivateTriggerIn(8'h40, 30);
        SetWireInValue(8'h01, 32'd0, NO_MASK);
        UpdateWireIns;
        Wait_TriggerOut(8'h60, {31'd0,1'b1});






        // gesture three sample pipe in!!!!! 같은 거 걍 3번 때려박음. 총 29952bit
        for (i_pk = 0; i_pk < 3; i_pk = i_pk + 1) begin
            // gesture one sample pipe in!!!!!
            for (i_pj = 0; i_pj < 12; i_pj = i_pj + 1) begin
                for (i_pi = 0; i_pi < 32; i_pi = i_pi + 1) begin
                    // 파이썬에서랑 다름 여기서 msb쪽이 파이썬에선 LSB로 들어감.
                    pipeIn[31 - (   (((i_pi)/4)   * 4) + (3-(i_pi%4)))] = nmnist_one_sample[8*32*i_pj + i_pi*8 +: 8];
                end
                WriteToBlockPipeIn(8'h80, 32, 32);  
            end
        end





        Wait_TriggerOut(8'h60, {31'd0,1'b1});












        // $display("######### P_STATE_07_ASIC_CONFIG mode ######################################################################");
        // $display("######### P_STATE_07_ASIC_CONFIG mode ######################################################################");
        // $display("######### P_STATE_07_ASIC_CONFIG mode ######################################################################");
        // $display("######### P_STATE_07_ASIC_CONFIG mode ######################################################################");




        // SetWireInValue(8'h01, 32'd7, NO_MASK);
        // UpdateWireIns;
        // ActivateTriggerIn(8'h40, 0);
        // SetWireInValue(8'h01, 32'd0, NO_MASK);
        // UpdateWireIns;


        // // dram write address setting
        // SetWireInValue(8'h01, 32'd0, NO_MASK); // start address
        // UpdateWireIns;
        // ActivateTriggerIn(8'h40, 30);
        // SetWireInValue(8'h01, 32'd110392, NO_MASK); // last address
        // UpdateWireIns;
        // ActivateTriggerIn(8'h40, 30);
        // SetWireInValue(8'h01, 32'd0, NO_MASK);
        // UpdateWireIns;
        // Wait_TriggerOut(8'h60, {31'd0,1'b1});




        SetWireInValue(8'h01, 32'd8, NO_MASK);
        UpdateWireIns;
        ActivateTriggerIn(8'h40, 0);
        SetWireInValue(8'h01, 32'd0, NO_MASK);
        UpdateWireIns;







        $display("######### P_STATE_08_ASIC_CONFIG_DONE mode ######################################################################");
        $display("######### P_STATE_08_ASIC_CONFIG_DONE mode ######################################################################");
        $display("######### P_STATE_08_ASIC_CONFIG_DONE mode ######################################################################");
        $display("######### P_STATE_08_ASIC_CONFIG_DONE mode ######################################################################");




        // dram write address setting
        SetWireInValue(8'h01, 32'd1070400, NO_MASK); // start address
        UpdateWireIns;
        ActivateTriggerIn(8'h40, 30);
        // 샘플 3개만
        SetWireInValue(8'h01, 32'd1070680, NO_MASK); // last address
        UpdateWireIns;
        ActivateTriggerIn(8'h40, 30);
        SetWireInValue(8'h01, 32'd0, NO_MASK);
        UpdateWireIns;
        Wait_TriggerOut(8'h60, {31'd0,1'b1});





        // SAMPLE 수 삽입

        // 3개
        SetWireInValue(8'h01, 32'd3, NO_MASK); 
        UpdateWireIns;
        ActivateTriggerIn(8'h40, 26);
        SetWireInValue(8'h01, 32'd0, NO_MASK);
        UpdateWireIns;
        Wait_TriggerOut(8'h60, {31'd0,1'b1});







        $display("######### P_STATE_11_ASIC_TRAINING_QUEUING mode ######################################################################");
        $display("######### P_STATE_11_ASIC_TRAINING_QUEUING mode ######################################################################");
        $display("######### P_STATE_11_ASIC_TRAINING_QUEUING mode ######################################################################");
        $display("######### P_STATE_11_ASIC_TRAINING_QUEUING mode ######################################################################");


        // QUEUING 시작
        ActivateTriggerIn(8'h40, 0);
        Wait_TriggerOut(8'h60, {31'd0,1'b1});


        // ASIC start ready 확인
        ActivateTriggerIn(8'h40, 28);




        $display("######### P_STATE_12_ASIC_TRAINING_PROCESSING mode ######################################################################");
        $display("######### P_STATE_12_ASIC_TRAINING_PROCESSING mode ######################################################################");
        $display("######### P_STATE_12_ASIC_TRAINING_PROCESSING mode ######################################################################");
        $display("######### P_STATE_12_ASIC_TRAINING_PROCESSING mode ######################################################################");


        // PROCESSING 시작
        ActivateTriggerIn(8'h40, 0);
        Wait_TriggerOut(8'h60, {31'd0,1'b1});

        // P_STATE_08_ASIC_CONFIG_DONE
        // PROCESSING TIME 세팅하기
        ActivateTriggerIn(8'h40, 23);












        $display("######### P_STATE_08_ASIC_CONFIG_DONE mode ######################################################################");
        $display("######### P_STATE_08_ASIC_CONFIG_DONE mode ######################################################################");
        $display("######### P_STATE_08_ASIC_CONFIG_DONE mode ######################################################################");
        $display("######### P_STATE_08_ASIC_CONFIG_DONE mode ######################################################################");

        // dram write address setting
        SetWireInValue(8'h01, 32'd110400, NO_MASK); // start address
        UpdateWireIns;
        ActivateTriggerIn(8'h40, 30);
        // 샘플 3개만
        SetWireInValue(8'h01, 32'd110680, NO_MASK); // last address
        UpdateWireIns;
        ActivateTriggerIn(8'h40, 30);
        SetWireInValue(8'h01, 32'd0, NO_MASK);
        UpdateWireIns;
        Wait_TriggerOut(8'h60, {31'd0,1'b1});





        // SAMPLE 수 삽입

        // 3개
        SetWireInValue(8'h01, 32'd3, NO_MASK); // start address
        UpdateWireIns;
        ActivateTriggerIn(8'h40, 26);
        SetWireInValue(8'h01, 32'd0, NO_MASK); // start address
        UpdateWireIns;
        Wait_TriggerOut(8'h60, {31'd0,1'b1});




        $display("######### P_STATE_09_ASIC_INFERENCE_QUEUING mode ######################################################################");
        $display("######### P_STATE_09_ASIC_INFERENCE_QUEUING mode ######################################################################");
        $display("######### P_STATE_09_ASIC_INFERENCE_QUEUING mode ######################################################################");
        $display("######### P_STATE_09_ASIC_INFERENCE_QUEUING mode ######################################################################");



        // QUEUING 시작
        ActivateTriggerIn(8'h40, 1);
        Wait_TriggerOut(8'h60, {31'd0,1'b1});


        // ASIC start ready 확인
        ActivateTriggerIn(8'h40, 28);




        $display("######### P_STATE_10_ASIC_INFERENCE_PROCESSING mode ######################################################################");
        $display("######### P_STATE_10_ASIC_INFERENCE_PROCESSING mode ######################################################################");
        $display("######### P_STATE_10_ASIC_INFERENCE_PROCESSING mode ######################################################################");
        $display("######### P_STATE_10_ASIC_INFERENCE_PROCESSING mode ######################################################################");


        // PROCESSING 시작
        ActivateTriggerIn(8'h40, 0);
        Wait_TriggerOut(8'h60, {31'd0,1'b1});

        // P_STATE_08_ASIC_CONFIG_DONE
        // 결과 세팅 하기
        ActivateTriggerIn(8'h40, 25);

        // P_STATE_08_ASIC_CONFIG_DONE
        // PROCESSING TIME 세팅하기
        ActivateTriggerIn(8'h40, 23);






// $finish;





    end





	`include "okHostCalls.vh"   // Do not remove!  The tasks, functions, and data stored
endmodule
`default_nettype wire



