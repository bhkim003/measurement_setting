`timescale 1ns/1ps
`default_nettype none

module top_bh_fpga_tb;

	wire  [4:0]   okUH;
	wire  [2:0]   okHU;
	wire  [31:0]  okUHU;
	wire          okAA;
	wire  [7:0]   led;




	reg sys_clk_p;
    initial sys_clk_p = 0;
    always #(2.5) sys_clk_p = ~sys_clk_p;


	reg sys_clk_n;
    initial sys_clk_n = 1;
    always #(2.5) sys_clk_n = ~sys_clk_n;



    top_bh_fpga u_top_bh_fpga(
        .okUH                                     ( okUH                                     ),
        .okHU                                     ( okHU                                     ),
        .okUHU                                    ( okUHU                            ),
        .okAA                                     ( okAA                              ),
        .sys_clk_p                                 (  sys_clk_p                                ),
        .sys_clk_n                                 (  sys_clk_n                                ),
        .led                                      ( led                                      ),
        // .ddr3_addr                        ( ddr3_addr                        ),
        // .ddr3_ba                          ( ddr3_ba                          ),
        // .ddr3_cas_n                       ( ddr3_cas_n                       ),
        // .ddr3_ck_n                        ( ddr3_ck_n                        ),
        // .ddr3_ck_p                        ( ddr3_ck_p                        ),
        // .ddr3_cke                         ( ddr3_cke                         ),
        // .ddr3_ras_n                       ( ddr3_ras_n                       ),
        // .ddr3_reset_n                     ( ddr3_reset_n                     ),
        // .ddr3_we_n                        ( ddr3_we_n                        ),
        // .ddr3_dq                          (   ddr3_dq                   ),
        // .ddr3_dqs_n                       (   ddr3_dqs_n                ),
        // .ddr3_dqs_p                       (   ddr3_dqs_p                ),
        // .ddr3_odt                       (   ddr3_odt                ),
        // .ddr3_dm                       (   ddr3_dm                ),
        .clk_clock_generator                      (                       ),
        .clk_port_spare_0                         (                          ),
        .clk_port_spare_1                         (                          ),
        .reset_n_from_fpga_to_asic                (                 ),
        .input_streaming_valid_from_fpga_to_asic  (   ),
        .input_streaming_data_from_fpga_to_asic   (    ),
        .input_streaming_ready_from_asic_to_fpga  (   ),
        .start_training_signal_from_fpga_to_asic  (   ),
        .start_inference_signal_from_fpga_to_asic (  ),
        .start_ready_from_asic_to_fpga            (             ),
        .inferenced_label_from_asic_to_fpga       (        )
    );

	//------------------------------------------------------------------------
	// Begin okHostInterface simulation user configurable global data
	//------------------------------------------------------------------------
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
	//------------------------------------------------------------------------


//------------------------------------------------------------------------
    // Variables & Registers
    //------------------------------------------------------------------------
    wire [31:0] NO_MASK = 32'hffff_ffff;
    integer i;

	wire signed [31:0] l1_cuts [0:14];
	assign l1_cuts[0]=256; 
	assign l1_cuts[1]=17;
	assign l1_cuts[2]=171;
	assign l1_cuts[3]=342;
	assign l1_cuts[4]=342;
	assign l1_cuts[5]=342;
	assign l1_cuts[6]=342;
	assign l1_cuts[7]=342;
	assign l1_cuts[8]=342;
	assign l1_cuts[9]=342;
	assign l1_cuts[10]=342;
	assign l1_cuts[11]=342;
	assign l1_cuts[12]=342;
	assign l1_cuts[13]=342;
	assign l1_cuts[14]=496;

	wire signed [31:0] l2_cuts [0:14];
	assign l2_cuts[0]=256; 
	assign l2_cuts[1]=17;
	assign l2_cuts[2]=171;
	assign l2_cuts[3]=342;
	assign l2_cuts[4]=342;
	assign l2_cuts[5]=342;
	assign l2_cuts[6]=342;
	assign l2_cuts[7]=342;
	assign l2_cuts[8]=342;
	assign l2_cuts[9]=342;
	assign l2_cuts[10]=342;
	assign l2_cuts[11]=342;
	assign l2_cuts[12]=342;
	assign l2_cuts[13]=342;
	assign l2_cuts[14]=496;
	
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
            SetWireInValue(8'h01, 32'd500, NO_MASK);
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


//------------------------------------------------------------------------
    // Main Simulation Process
    //------------------------------------------------------------------------
    initial begin
        // FrontPanel 초기화
        FrontPanelReset;

        // 1. 하드웨어 리셋 시뮬레이션 (Active Low)
        // Python: fpga.reset(reset_address=0x00, active_low=True)
        SetWireInValue(8'h00, 32'h00_00_00_01, NO_MASK);
        UpdateWireIns;
        #500;
        SetWireInValue(8'h00, 32'h00_00_00_00, NO_MASK);
        UpdateWireIns;
        #1000;
        SetWireInValue(8'h00, 32'h00_00_00_01, NO_MASK);
        UpdateWireIns;
        #1000;
        
		Wait_TriggerOut(8'h60, 32'd1);

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
		Wait_TriggerOut(8'h60, 32'd1);

		// 11. p_config done mode (Python: SetWireInValue(0x01, 2) -> Trigger(0x40, 0))
		$display("######### p_config done mode #########");
		SetWireInValue(8'h01, 32'd2, NO_MASK);
		UpdateWireIns;
		ActivateTriggerIn(8'h40, 0);
		SetWireInValue(8'h01, 32'd0, NO_MASK);
		UpdateWireIns;


        $display("Simulation Configuration Finished.");
        #5000;
        $finish;
    end

    // // Opal Kelly 시뮬레이션 태스크 포함. vivado에 추가해놨음 (김병현).
    // `include "okHostCalls.vh"
	// `include "C:\Users\User\measurement_setting\01_reference_code\Opalkelly_Frontpanel\Simulation\oksim\okHostCalls.vh"
	`include "okHostCalls.vh"   // Do not remove!  The tasks, functions, and data stored

endmodule
`default_nettype wire

