
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kim Beomseok
// Contact: kimbss470@snu.ac.kr
// 
// Create Date: 21/07/2024 
// Design Name: OpalKelly for USB3 in Verilog
// Module Name: tb_OpalKelly_test
// Project Name: 2024TapeOut
// Target Devices: XEM7360-K160T
// Tool versions: 2024.1
// Description: A tesbench for OpalKelly test platform
//              - Scenario
//                1. (Host) Store the values 0 to 127 in the DRAM addresses from 0x1000 to 0x107F.
//                2. (Chip) Read the data from the DRAM addresses from 0x1000 to 0x107F.
//                3. (Chip) Add +1 to each data value and write it back to the same addresses.
//                4. (Host) Read the data from the addresses 0x1000 to 0x107F and perform a correctness check.
//////////////////////////////////////////////////////////////////////////////////


//************************************************************************
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
//	  WriteRegister(address, data);
//	  ReadRegister(address, data);
//	  WriteRegisterSet;                // writes all values in u32Data to the addresses in u32Address
//	  ReadRegisterSet;                 // reads all values in the addresses in u32Address to the array u32Data
//
//    *Pipes operate by passing arrays of data back and forth to the user's
//    design.  If you need multiple arrays, you can create a new procedure
//    above and connect it to a differnet array.  More information is
//    available in Opal Kelly documentation and online support tutorial.
//************************************************************************

`include "params.vh"
`timescale 1ns/1ps

module tb_OpalKelly_test ();


    //************************************************************************
    // Begin okHostInterface simulation user configurable global data
    //************************************************************************
    parameter BlockDelayStates = 5;   // REQUIRED: # of clocks between blocks of pipe data
    parameter ReadyCheckDelay = 5;    // REQUIRED: # of clocks before block transfer before
                                      //  host interface checks for ready (0-255)
    parameter PostReadyDelay = 5;     // REQUIRED: # of clocks after ready is asserted and
                                      //  check that the block transfer begins (0-255)
    parameter pipeInSize = 128;       // REQUIRED: byte (must be even) length of default
                                      //  PipeIn; Integer 0-2^32
    parameter pipeOutSize = 128;      // REQUIRED: byte (must be even) length of default
                                      // PipeOut; Integer 0-2^32
    parameter registerSetSize = 32;   // Size of array for register set commands.
    parameter blockSize = 32;
    // parameter Tsys_clk = 2.5;         // 200Mhz

    // Registers
    reg [31:0] u32Address  [0:(registerSetSize-1)];
    reg [31:0] u32Data     [0:(registerSetSize-1)];
    reg [31:0] u32Count;

    wire [4:0]   okUH;
    wire [2:0]   okHU;
    wire [31:0]  okUHU;
    wire         okAA;
    wire [7:0]   led;



    //************************************************************************
    // okFP 
    //************************************************************************
    parameter CMD_DRAM_WRITE  = 32'h0000;  // 0th bit
    parameter CMD_DRAM_READ   = 32'h0001;  // 1th bit 
    parameter CMD_EXECUTE_NET = 32'h0002;  // 2th bit
    parameter CMD_FIFO_FPGA2CHIP_READ = 32'h0003;  // 3th bit
    parameter CMD_FIFO_CHIP2FPGA_READ = 32'h0004;  // 4th bit
    parameter CMD_FIFO_AXADDR_READ = 32'h0005;  // 5th bit
    parameter CMD_FIFO_RDATA_READ = 32'h0006;  // 6th bit
    parameter CMD_FIFO_WDATA_READ = 32'h0007;  // 7th bit
    parameter CMD_ABORT = 32'h0008;  // 8th bit


    /* Pipes */
    integer k;
    reg  [7:0]  pipeIn [0:(pipeInSize-1)];
    reg  [7:0]  pipeOut [0:(pipeOutSize-1)];
    wire [31:0] NO_MASK = 32'hffff_ffff;

    initial for (k=0; k<pipeInSize; k=k+1) pipeIn[k] = 8'h00;
    initial for (k=0; k<pipeOutSize; k=k+1) pipeOut[k] = 8'h00;
    


    //************************************************************
    // Chip-releted Wires 
    //************************************************************
    wire         single_rate;
    wire         start;
    wire         done;
    wire         load_or_store;   
    wire         store_byte4;   
    wire [127:0] data;
    wire [ 11:0] axaddr_and_axlen;
    wire         axvalid;
    wire         axready;
    wire         rvalid_or_wready;
    wire         rready_or_wvalid;


    //************************************************************************
    // DDR3 
    //************************************************************************

    localparam CS_WIDTH     = 1;
    localparam DQ_WIDTH     = 32;
    localparam MEMORY_WIDTH = 16;
    localparam NUM_COMP     = DQ_WIDTH/MEMORY_WIDTH;

    wire                    ddr3_reset_n;
    wire [31:0]             ddr3_dq;
    wire [3:0]              ddr3_dqs_p;
    wire [3:0]              ddr3_dqs_n;
    wire [15:0]             ddr3_addr;
    wire [2:0]              ddr3_ba;
    wire                    ddr3_ras_n;
    wire                    ddr3_cas_n;
    wire                    ddr3_we_n;
    wire [1-1:0]            ddr3_cke;
    wire [1-1:0]            ddr3_ck_p;
    wire [1-1:0]            ddr3_ck_n;
    wire [3:0]              ddr3_dm;
    wire                    ddr3_odt;


    //************************************************************************
    // Clock Generation
    //************************************************************************

    localparam HALF_SYS_CLK_PERIOD = 2.5;                   // MIG clk
    localparam SYS_CLK_PERIOD = 2 * HALF_SYS_CLK_PERIOD;    // 200 MHz

    localparam HALF_CHIP_CLK_PERIOD = 2;                    // Chip clk
    localparam CHIP_CLK_PERIOD = 2 * HALF_CHIP_CLK_PERIOD;  // 250 MHz

    reg  sys_clk_p;
    wire sys_clk_n;
    reg  chip_clk;

    initial begin
        sys_clk_p <= 1'b0;
        while(1) #(HALF_SYS_CLK_PERIOD) sys_clk_p <= ~sys_clk_p;
    end
    assign sys_clk_n = ~sys_clk_p;

    initial begin
        chip_clk <= 1'b0;
        while(1) #(HALF_CHIP_CLK_PERIOD) chip_clk <= ~chip_clk;
    end



    //************************************************************************
    // Main 
    //************************************************************************

    localparam TARGET_ADDR = 28'h000_1000;
    localparam S_IDLE = 2'd0;


    integer      i_layer;
    integer      i_run;
    reg  [27:0]  addr;   // DRAM address, byte-addressing
    reg  [12:0]  len;    // bytes - 1
    reg  [255:0] tmp;
    reg  [5:0]   n_layers;    
    reg          infinite_loop;    
    reg  [15:0]  wait_chip_cnt;
    reg          ep_single_rate;
    reg          correct;
    reg  [63:0]  clk_cnt;
    reg  [31:0]  raw_clk_cnt;
    reg  [31:0]  network_done_cnt;
    reg  [7:0]   answer [0:(pipeInSize-1)];

    /* Debug */
    reg          ep_read_or_write;   // 0 for read, 1 for write
    reg  [5:0]   ep_hist_idx;        
    reg  [31:0]  wireOut22;
    reg  [7:0]   start_cnt;
    reg  [7:0]   arvalid_cnt;
    reg  [7:0]   arready_cnt;
    reg  [7:0]   rvalid_cnt;
    reg  [7:0]   awvalid_cnt;
    reg  [7:0]   awready_cnt;
    reg  [7:0]   wvalid_cnt;
    reg  [255:0] debug_rdata;
    reg          ok_network_start;
    reg          chip_network_start;
    reg          ok2chip_fifo_wr_en;
    reg          ok2chip_fifo_valid;
    reg  [31:0]  chip_clk_toggle_cnt;
    reg  [31:0]  wireOut34;
    reg  [3:0]   ttf_axvalid;    // time to first axvalid activation (from start_layer activation)
    reg  [8:0]   tracking_cycles;   // #cycles to track CHIP<->FPGA communication


    initial for (k=0; k<pipeInSize; k=k+1) answer[k] = pipeIn[k] + 128*n_layers;
    initial begin
        addr             = 28'd0;
        len              = 14'd0;
        ep_single_rate   = 1'b0;
        n_layers         = 6'd0;
        infinite_loop    = 1'b0;
        wait_chip_cnt    = 16'd0;
        correct          = 1'b0;
        clk_cnt          = 64'd0;
        raw_clk_cnt      = 32'd0;
        network_done_cnt = 32'd0;
        ep_read_or_write = 1'b0;
        ep_hist_idx      = 8'd0;
        ttf_axvalid      = 4'd0;
        tracking_cycles  = 9'd0;
 
        // Reset FP
        $display("=========================================================");
        $display("kimbss: Reset FrontPanel...");
        $display("=========================================================");
        FrontPanelReset;
        repeat(200) @(posedge sys_clk_p);
        

        // Reset (ep00wire: 0->1->0, okRstn: 1->0->1)
        SetWireInValue(8'h00, 32'h0000_0000, NO_MASK);
        UpdateWireIns;
        repeat(20) @(posedge sys_clk_p);

        SetWireInValue(8'h00, 32'h0000_0001, NO_MASK);
        UpdateWireIns;
        repeat(20) @(posedge sys_clk_p);

        SetWireInValue(8'h00, 32'h0000_0000, NO_MASK);
        UpdateWireIns;


        // Wait init_calib_done==1
        while (!IsTriggered(8'h60, NO_MASK)) begin
            UpdateTriggerOuts;
            @(posedge sys_clk_p);
        end
        $display("=========================================================");
        $display("kimbss: Init_calib is completed!");
        $display("=========================================================");


        // DRAM Write
        addr = TARGET_ADDR;
        len  = 14'd128;    // in bytes (128 == 4 axi-transfers)
        SetWireInValue(8'h01, {4'd0, addr}, NO_MASK);    // Set addr
        SetWireInValue(8'h02, {18'd0, len}, NO_MASK);    // Set len
        UpdateWireIns;
        ActivateTriggerIn(8'h40, CMD_DRAM_WRITE);        // cmd == DRAM_WRITE
        for (k = 0; k < pipeInSize; k = k + 1) begin
            // Set pipeIn registers //
            pipeIn[k] = k;   // write 0x00 ~ 0x7F
        end
        WriteToBlockPipeIn(8'h80, blockSize, len);

        // Wait for the state of okFP to become IDLE
        while (GetWireOutValue(8'h20) != S_IDLE) begin
            UpdateWireOuts;
            @(posedge sys_clk_p);
        end
        // UpdateWireOuts;
        // $display("Last axi_wdata:%08h", GetWireOutValue(8'h22));
        // $display("Last axi_wdata:%08h", GetWireOutValue(8'h23));
        // $display("Last axi_wdata:%08h", GetWireOutValue(8'h24));
        // $display("Last axi_wdata:%08h", GetWireOutValue(8'h25));
        // $display("Last axi_wdata:%08h", GetWireOutValue(8'h26));
        // $display("Last axi_wdata:%08h", GetWireOutValue(8'h27));
        // $display("Last axi_wdata:%08h", GetWireOutValue(8'h28));
        // $display("Last axi_wdata:%08h", GetWireOutValue(8'h29));

        $display("=========================================================");
        $display("kimbss: DRAM write is completed!");
        $display("=========================================================");
        

        // Execute Network
        ep_single_rate = 1'b1;
        n_layers = 4;
        infinite_loop    = 1'b1;    // test infinite loop mode
        if (n_layers <= 1) $finish; // n_layers should > 1
        SetWireInValue(8'h03, {31'd0, ep_single_rate}, NO_MASK);    // Set addr
        SetWireInValue(8'h04, {26'd0, n_layers}, NO_MASK);          // Set len
        SetWireInValue(8'h07, {31'd0, infinite_loop}, NO_MASK);     // Set infinite_loop
        UpdateWireIns;
        ActivateTriggerIn(8'h40, CMD_EXECUTE_NET);                  // cmd == EXECUTE

        for (i_layer = 0; i_layer < n_layers; i_layer = i_layer + 1) begin
            while (!IsTriggered(8'h62, NO_MASK)) begin              // Wait for done_layer
                UpdateTriggerOuts;
                @(posedge sys_clk_p);
            end
            $display("kimbss: Layer %d done..", i_layer);
        end

        while (!IsTriggered(8'h61, NO_MASK)) begin                  // Wait for the chip to finish writing data to DDR
            UpdateTriggerOuts;
            @(posedge sys_clk_p);
        end

        UpdateWireOuts;
        clk_cnt = GetWireOutValue(8'h21);                           // get clk_cnt
        $display("kimbss: CLK_CNT: %32d", clk_cnt);
        repeat(10)   @(posedge sys_clk_p);


 

        // Execute Network
        ep_single_rate = 1'b1;
        n_layers = 4;
        infinite_loop    = 1'b1;    // test infinite loop mode
        wait_chip_cnt = 16'd100;
        if (n_layers <= 1) $finish; // n_layers should > 1
        SetWireInValue(8'h03, {31'd0, ep_single_rate}, NO_MASK);    // Set addr
        SetWireInValue(8'h04, {26'd0, n_layers}, NO_MASK);          // Set len
        SetWireInValue(8'h07, {31'd0, infinite_loop}, NO_MASK);     // Set infinite_loop
        SetWireInValue(8'h08, {16'd0, wait_chip_cnt}, NO_MASK);     // Set wait_chip_cnt
        UpdateWireIns;
        ActivateTriggerIn(8'h40, CMD_EXECUTE_NET);                  // cmd == EXECUTE
        
        UpdateWireOuts;
        raw_clk_cnt = GetWireOutValue(8'h22);                           // get clk_cnt
        network_done_cnt = GetWireOutValue(8'h23);
        $display("kimbss: RAW_CLK_CNT: %32d", raw_clk_cnt);
        $display("kimbss: NETWORK_DONE_CNT: %32d", network_done_cnt);
        
        for (i_layer = 0; i_layer < n_layers; i_layer = i_layer + 1) begin
            while (!IsTriggered(8'h62, NO_MASK)) begin              // Wait for done_layer
                UpdateTriggerOuts;
                @(posedge sys_clk_p);
            end
            $display("kimbss: Layer %d done..", i_layer);
        end

        while (!IsTriggered(8'h61, NO_MASK)) begin                  // Wait for the chip to finish writing data to DDR
            UpdateTriggerOuts;
            @(posedge sys_clk_p);
        end

        UpdateWireOuts;
        clk_cnt = GetWireOutValue(8'h21);                           // get clk_cnt
        $display("kimbss: CLK_CNT: %32d", clk_cnt);
        repeat(10)   @(posedge sys_clk_p);
        
        
    
        
        
//        // Check correctness 
//        addr = TARGET_ADDR;
//        len  = 14'd128;    // bytes
//        correct = 1'b1;
//        SetWireInValue(8'h01, {4'd0, addr}, NO_MASK);
//        SetWireInValue(8'h02, {18'd0, len}, NO_MASK);
//        UpdateWireIns;
//        ActivateTriggerIn(8'h40, CMD_DRAM_READ);                    // cmd == DRAM_READ
//        ReadFromBlockPipeOut(8'ha0, blockSize, len);                // write to pipeOut reg

//        UpdateWireOuts;
//        $display("kimbss: mig_axi_read_delay:%d", GetWireOutValue(8'h38));
//        $display("kimbss: chip_axi_read_delay:%d", GetWireOutValue(8'h39));
//        $display("First axi_wdata:%08h", GetWireOutValue(8'h22));
//        $display("First axi_wdata:%08h", GetWireOutValue(8'h23));
//        $display("First axi_wdata:%08h", GetWireOutValue(8'h24));
//        $display("First axi_wdata:%08h", GetWireOutValue(8'h25));
//        $display("First axi_wdata:%08h", GetWireOutValue(8'h26));
//        $display("First axi_wdata:%08h", GetWireOutValue(8'h27));
//        $display("First axi_wdata:%08h", GetWireOutValue(8'h28));
//        $display("First axi_wdata:%08h", GetWireOutValue(8'h29));
        
//        $display("First axi_rdata:%08h", GetWireOutValue(8'h30));
//        $display("First axi_rdata:%08h", GetWireOutValue(8'h31));
//        $display("First axi_rdata:%08h", GetWireOutValue(8'h32));
//        $display("First axi_rdata:%08h", GetWireOutValue(8'h33));
//        $display("First axi_rdata:%08h", GetWireOutValue(8'h34));
//        $display("First axi_rdata:%08h", GetWireOutValue(8'h35));
//        $display("First axi_rdata:%08h", GetWireOutValue(8'h36));
//        $display("First axi_rdata:%08h", GetWireOutValue(8'h37));

//        $display("=========================================================");
//        for (k=0; k<len; k=k+1) begin
//            // store_byte4 test
//            if  (  (k ==  0 +  0)
//                || (k ==  0 +  1) 
//                || (k ==  0 +  2) 
//                || (k ==  0 +  3) 
//                || (k == 32 +  4) 
//                || (k == 32 +  5) 
//                || (k == 32 +  6) 
//                || (k == 32 +  7) 
//                || (k == 64 +  8) 
//                || (k == 64 +  9) 
//                || (k == 64 + 10) 
//                || (k == 64 + 11) 
//                || (k == 96 + 12) 
//                || (k == 96 + 13) 
//                || (k == 96 + 14) 
//                || (k == 96 + 15)) begin

//                if (pipeOut[k] != 0) begin 
//                    correct = 1'b0;
//                    $display("kimbss: Wrong,,, data%d should be 0, but %d! (store_byte4 test)",k, pipeOut[k]);
//                end
//            end
//            else if ((pipeIn[k] + (1*(n_layers-1))) != pipeOut[k]) begin
//                correct = 1'b0;
//                $display("kimbss: Wrong,,, %3d+%d*1 != %3d",pipeIn[k],n_layers-1, pipeOut[k]);
                
//            end
//            else begin
//                $display("kimbss: Correct! %3d+%d*1 == %3d",pipeIn[k],n_layers-1, pipeOut[k]);
//            end
            
//        end

//        if (correct) $display("kimbss: Congratulation! All results are correct.");
//        else $display("kimbss: Wrong... Try hard to debug...");
//        $display("=========================================================");
        
        $finish;
        
    end


    `include "C:/Xilinx/Vivado/2024TapeOut_opalkelly_sim/oksim/okHostCalls.vh"   // Do not remove!  The tasks, functions, and data stored
                                        // in okHostCalls.vh must be included here.
    //************************************************************************
    // Force Quit
    //************************************************************************
    initial begin
        repeat(18000) @(posedge sys_clk_p);
        $finish;
    end


    //************************************************************
    //  OpalKelly Instantiations
    //************************************************************
    OpalKelly_test u_opalkelly (
        .sys_clk_p              (sys_clk_p          ),
        .sys_clk_n              (sys_clk_n          ),
        .clk_ext                (sys_clk_p          ),
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
        .ddr3_reset_n           (ddr3_reset_n       )
      
    );
    
     
    //************************************************************
    // Memory Models Instantiations
    //************************************************************

    genvar i;
    generate
        for (i = 0; i < NUM_COMP; i = i + 1) begin: gen_mem
            ddr3_model u_comp_ddr3
            (
            .rst_n   (ddr3_reset_n                 ),
            .ck      (ddr3_ck_p                    ),
            .ck_n    (ddr3_ck_n                    ),
            .cke     (ddr3_cke                     ),
            .cs_n    (ddr3_cs_n                    ),
            .ras_n   (ddr3_ras_n                   ),
            .cas_n   (ddr3_cas_n                   ),
            .we_n    (ddr3_we_n                    ),
            .dm_tdqs (ddr3_dm[(2*(i+1)-1):(2*i)]   ),
            .ba      (ddr3_ba                      ),
            .addr    (ddr3_addr                    ),
            .dq      (ddr3_dq[16*(i+1)-1:16*(i)]   ),
            .dqs     (ddr3_dqs_p[(2*(i+1)-1):(2*i)]),
            .dqs_n   (ddr3_dqs_n[(2*(i+1)-1):(2*i)]),
            .tdqs_n  (                             ),
            .odt     (ddr3_odt                     )
            );
        end
    endgenerate

endmodule