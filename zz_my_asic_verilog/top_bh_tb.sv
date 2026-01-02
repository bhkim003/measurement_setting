`timescale 1ns / 1ps
    `define CLK_PERIOD                 50
    `define CLK_PERIOD_HALF            25

    `define TOTAL_ITER                  10
    `define INF_ONLY_ON_SWEEP_MODE     1

    `define TRAINING_ITER_PER_EPOCH 10
    `define INFERENCE_ITER_PER_EPOCH 10
    `define RANDOM_VALID 100 // If this is 10, valid signal is dropped with 1/10 probability. If 0, valid is always on.

	`define DVS_GESTURE_ON 0
	`define N_MNIST_ON 1
	`define N_TIDIGITS_ON 0
	`define TIMESTEPS 8
	`define INPUT_SIZE_LAYER1_DEFINE 578
	`define LONG_TIME_INPUT_STREAMING_MODE 0 
	`define BINARY_CLASSIFIER_MODE 0
	`define LOSER_ENCOURAGE_MODE 0

	`define LAYER1_THRESHOLD 256
	`define LAYER1_SURROGATE_X_CUT_0 17
	`define LAYER1_SURROGATE_X_CUT_1 171
	`define LAYER1_SURROGATE_X_CUT_2 342
	`define LAYER1_SURROGATE_X_CUT_3 342
	`define LAYER1_SURROGATE_X_CUT_4 342
	`define LAYER1_SURROGATE_X_CUT_5 342
	`define LAYER1_SURROGATE_X_CUT_6 342
	`define LAYER1_SURROGATE_X_CUT_7 342
	`define LAYER1_SURROGATE_X_CUT_8 342
	`define LAYER1_SURROGATE_X_CUT_9 342
	`define LAYER1_SURROGATE_X_CUT_10 342
	`define LAYER1_SURROGATE_X_CUT_11 342
	`define LAYER1_SURROGATE_X_CUT_12 342
	`define LAYER1_SURROGATE_X_CUT_13 496

	`define LAYER2_THRESHOLD 256
	`define LAYER2_SURROGATE_X_CUT_0 17
	`define LAYER2_SURROGATE_X_CUT_1 171
	`define LAYER2_SURROGATE_X_CUT_2 342
	`define LAYER2_SURROGATE_X_CUT_3 342
	`define LAYER2_SURROGATE_X_CUT_4 342
	`define LAYER2_SURROGATE_X_CUT_5 342
	`define LAYER2_SURROGATE_X_CUT_6 342
	`define LAYER2_SURROGATE_X_CUT_7 342
	`define LAYER2_SURROGATE_X_CUT_8 342
	`define LAYER2_SURROGATE_X_CUT_9 342
	`define LAYER2_SURROGATE_X_CUT_10 342
	`define LAYER2_SURROGATE_X_CUT_11 342
	`define LAYER2_SURROGATE_X_CUT_12 342
	`define LAYER2_SURROGATE_X_CUT_13 496
    


module top_bh_tb;

	// ########## LAYER 1 PARAMETER ###########################################################
	parameter       LAYER1_BIT_WIDTH_WEIGHT         = 8;  
    parameter       LAYER1_BIT_WIDTH_MEMBRANE       = 17;

	parameter       LAYER1_BIT_WIDTH_SURROGATE       = 3;
	parameter       LAYER1_DEPTH_SURROGATE_BOX       = 2;

	parameter       LAYER1_BIT_WIDTH_SRAM         = 160;  
	parameter       LAYER1_DEPTH_SRAM             = 980;
	parameter       LAYER1_BIT_WIDTH_ADDRESS      = 10;

	parameter       LAYER1_BIT_WIDTH_DELTA_WEIGHT       = 4;

	parameter       LAYER1_NEURON_NUM_IN_SET = 20;
	parameter       LAYER1_SET_NUM = 10;

	parameter       LAYER1_INPUT_SIZE = 980;
	parameter       LAYER1_OUTPUT_SIZE = 200;
	parameter 		LAYER1_SPIKE_BUFFER_PAST_SIZE = 3;

	parameter       LAYER1_BIT_WIDTH_FSM = 2;

	parameter       LAYER1_BIT_WIDTH_CONFIG_COUNTER = 14;
	// ########## LAYER 1 PARAMETER ###########################################################





	// ########## LAYER 2 PARAMETER ###########################################################
	parameter       LAYER2_BIT_WIDTH_WEIGHT         = 8;  
    parameter       LAYER2_BIT_WIDTH_MEMBRANE       = 16;

	parameter       LAYER2_BIT_WIDTH_SURROGATE       = 3;
	parameter       LAYER2_DEPTH_SURROGATE_BOX       = 1;

	parameter       LAYER2_BIT_WIDTH_SRAM         = 160;  
	parameter       LAYER2_DEPTH_SRAM             = 200;
	parameter       LAYER2_BIT_WIDTH_ADDRESS      = 8;

	parameter       LAYER2_BIT_WIDTH_DELTA_WEIGHT       = 4;

	parameter       LAYER2_NEURON_NUM_IN_SET = 20;
	parameter       LAYER2_SET_NUM = 10;

	parameter       LAYER2_INPUT_SIZE = 200;
	parameter       LAYER2_OUTPUT_SIZE = 200;
	parameter 		LAYER2_SPIKE_BUFFER_PAST_SIZE = 2;

	parameter       LAYER2_BIT_WIDTH_FSM = 2;

	parameter       LAYER2_BIT_WIDTH_CONFIG_COUNTER = 11;
	// ########## LAYER 2 PARAMETER ###########################################################




 
	// ########## LAYER 3 PARAMETER ###########################################################
	parameter       LAYER3_BIT_WIDTH_WEIGHT         = 8;  
    parameter       LAYER3_BIT_WIDTH_MEMBRANE       = 16;


	parameter       LAYER3_BIT_WIDTH_SRAM         = 8;  
	parameter       LAYER3_DEPTH_SRAM             = 200;
	parameter       LAYER3_BIT_WIDTH_ADDRESS      = 8;

	parameter       LAYER3_BIT_WIDTH_DELTA_WEIGHT       = 2;


	parameter       LAYER3_NEURON_NUM_IN_SET = 1;
	parameter       LAYER3_SET_NUM = 10;

	parameter       LAYER3_INPUT_SIZE = 200;
	parameter       LAYER3_OUTPUT_SIZE = 10;
	parameter 		LAYER3_SPIKE_BUFFER_PAST_SIZE = 1;

	parameter       LAYER3_BIT_WIDTH_FSM = 2;

	parameter       LAYER3_BIT_WIDTH_CONFIG_COUNTER = 11;

    parameter       LAYER3_BIT_WIDTH_BIG_MEMBRANE       = 16;

	parameter       LAYER3_CLASSIFIER_SIZE = 10;
	// ########## LAYER 3 PARAMETER ###########################################################



	// ########## SNN PARAMETER ###############################################################
	parameter       BIT_WIDTH_INPUT_STREAMING_DATA = 66;

	parameter       INPUT_SPIKE_FIFO_DATA_WIDTH = 986; // 980+6 (sampledone1bit, epochfinish1bit, label4bit) <= BIT_WIDTH_INPUT_STREAMING_DATA*CLOCK_INPUT_SPIKE_COLLECT_LONG

	parameter	    INOUT_BUFFERING_NUM = 3;

	parameter       BIT_WIDTH_SNN_FSM = 2;
	parameter       BIT_WIDTH_CONFIG_COUNTER_MAIN = 14;

	parameter       CLOCK_INPUT_SPIKE_COLLECT_LONG = 15; // 986 <= 66*15 ==990
	parameter       CLOCK_INPUT_SPIKE_COLLECT_SHORT = 9;
	// ########## SNN PARAMETER ###############################################################

	parameter      	FPGA_INPUT_BUFFER_SIZE = 2; // If you want to set this param zero, then define NO_FPGA_INPUT_BUFFER 
	parameter       FPGA_OUTPUT_BUFFER_SIZE  = 1; // If you want to set this param zero, then define NO_FPGA_OUTPUT_BUFFER 
    // `define NO_FPGA_INPUT_BUFFER 1
    // `define NO_FPGA_OUTPUT_BUFFER 1

    // `define VALID_BLOCKING_AT_SUCCESSIVE_REQ 1

	reg clk;
	reg reset_n;

	reg input_streaming_valid_i; 
	reg [BIT_WIDTH_INPUT_STREAMING_DATA-1:0] input_streaming_data_i; 
	wire input_streaming_ready_o; 

	reg start_training_signal_i; 
	reg start_inference_signal_i;  
	wire start_ready_o; 

	wire inferenced_label_o; 


	reg [31:0] total_iter_counter;

	wire [31:0] total_iter_finish_cut; 
	`ifdef FUNC_VERI
		localparam INPUT_SIZE_LAYER1_LOCAL_PARAM  = `INPUT_SIZE_LAYER1_DEFINE;
		// assign total_iter_finish_cut = (`FUNC_VERI); // 10 epochs
		assign total_iter_finish_cut = (`TOTAL_ITER); // 10 epochs
		// always @ (*) begin
		// 	if (total_iter_counter == total_iter_finish_cut) begin
		// 		$display("Test completed  Total Iterations: %d, Expected Iterations: %d", total_iter_counter, total_iter_finish_cut);
		// 		$finish;
		// 	end
		// end
	`else
		localparam INPUT_SIZE_LAYER1_LOCAL_PARAM = `INPUT_SIZE_LAYER1_DEFINE;
		initial begin
			repeat (25000) @(posedge clk); 
			$display("Test completed");
			$finish;
		end
	`endif




	wire input_streaming_valid_i_postbuffer; 
	wire [BIT_WIDTH_INPUT_STREAMING_DATA-1:0] input_streaming_data_i_postbuffer; 
	wire input_streaming_ready_o_prebuffer; 

	wire start_training_signal_i_postbuffer; 
	wire start_inference_signal_i_postbuffer; 
	wire start_ready_o_prebuffer; 

	wire inferenced_label_o_prebuffer; 

	`ifdef APR_WPAD
		initial $write("\n\nUsing synthesized top for simulation...");

		`ifdef SIM_APR_WPAD_TYPICAL
			initial $sdf_annotate("/home/bhkim003/SNN_CHIP_Samsung_FDSOI_28nm/APR_WPAD_backup/2509131439/top_wpad_bh.sdf", u_top_wpad_bh,,"sdf_annotate.log", "TYPICAL");
		`elsif SIM_APR_WPAD_MINIMUM
			initial $sdf_annotate("/home/bhkim003/SNN_CHIP_Samsung_FDSOI_28nm/APR_WPAD_backup/2509131439/top_wpad_bh.sdf", u_top_wpad_bh,,"sdf_annotate.log", "MINIMUM");
		`else
			initial $sdf_annotate("/home/bhkim003/SNN_CHIP_Samsung_FDSOI_28nm/APR_WPAD_backup/2509131439/top_wpad_bh.sdf", u_top_wpad_bh,,"sdf_annotate.log", "MAXIMUM");
		`endif

		top_wpad_bh u_top_wpad_bh(
			.clk                                                    ( clk                                                    ),
			.reset_n                                                ( reset_n                                                ),
			.input_streaming_valid_i                                ( input_streaming_valid_i_postbuffer                                ),
			.input_streaming_data_i                                 ( input_streaming_data_i_postbuffer                                 ),
			.input_streaming_ready_o                                ( input_streaming_ready_o_prebuffer                                ),
			.start_training_signal_i                                ( start_training_signal_i_postbuffer                                ),
			.start_inference_signal_i                               ( start_inference_signal_i_postbuffer                               ),
			.start_ready_o                                          ( start_ready_o_prebuffer                                          ),
			.inferenced_label_o                                     ( inferenced_label_o_prebuffer                                     )
		);
	`elsif APR_BLOCK
		// initial $write("\n\nUsing APRed top for simulation...");
		// initial $sdf_annotate("../apr_block/top.sdf", top1,,, "MAXIMUM");
		// top top1 (.clk(clk), .reset(reset), .signal_in(signal_in_delayed), .digital_in(digital_in), .analog_in1(analog_in1), .analog_in2(analog_in2), .signal_out(signal_out), .digital_out(digital_out), .analog_out1(analog_out1), .analog_out2(analog_out2));
	`elsif SYN
		initial $write("\n\nUsing synthesized top for simulation...");
		initial $sdf_annotate("../APR_WPAD/pre_layout/top_bh.syn.sdf", u_top_bh,,"sdf_annotate.log", "MAXIMUM");
		// initial $sdf_annotate("../APR_WPAD/pre_layout/top_bh.syn.sdf", u_top_bh,,"sdf_annotate.log", "TYPICAL");
		top_bh u_top_bh(
			.clk                                                    ( clk                                                    ),
			.reset_n                                                ( reset_n                                                ),
			.input_streaming_valid_i                                ( input_streaming_valid_i_postbuffer                                ),
			.input_streaming_data_i                                 ( input_streaming_data_i_postbuffer                                 ),
			.input_streaming_ready_o                                ( input_streaming_ready_o_prebuffer                                ),
			.start_training_signal_i                                ( start_training_signal_i_postbuffer                                ),
			.start_inference_signal_i                               ( start_inference_signal_i_postbuffer                               ),
			.start_ready_o                                          ( start_ready_o_prebuffer                                          ),
			.inferenced_label_o                                     ( inferenced_label_o_prebuffer                                     )
		);

	`else
		top_bh#(
			.LAYER1_BIT_WIDTH_WEIGHT                                ( LAYER1_BIT_WIDTH_WEIGHT ),
			.LAYER1_BIT_WIDTH_MEMBRANE                              ( LAYER1_BIT_WIDTH_MEMBRANE ),
			.LAYER1_BIT_WIDTH_SURROGATE                             ( LAYER1_BIT_WIDTH_SURROGATE ),
			.LAYER1_DEPTH_SURROGATE_BOX                             ( LAYER1_DEPTH_SURROGATE_BOX ),
			.LAYER1_BIT_WIDTH_SRAM                                  ( LAYER1_BIT_WIDTH_SRAM ),
			.LAYER1_DEPTH_SRAM                                      ( LAYER1_DEPTH_SRAM ),
			.LAYER1_BIT_WIDTH_ADDRESS                               ( LAYER1_BIT_WIDTH_ADDRESS ),
			.LAYER1_BIT_WIDTH_DELTA_WEIGHT                          ( LAYER1_BIT_WIDTH_DELTA_WEIGHT ),
			.LAYER1_NEURON_NUM_IN_SET                               ( LAYER1_NEURON_NUM_IN_SET ),
			.LAYER1_SET_NUM                                         ( LAYER1_SET_NUM ),
			.LAYER1_INPUT_SIZE                                      ( LAYER1_INPUT_SIZE ),
			.LAYER1_OUTPUT_SIZE                                     ( LAYER1_OUTPUT_SIZE ),
			.LAYER1_SPIKE_BUFFER_PAST_SIZE                          ( LAYER1_SPIKE_BUFFER_PAST_SIZE ),
			.LAYER1_BIT_WIDTH_FSM                                   ( LAYER1_BIT_WIDTH_FSM ),
			.LAYER1_BIT_WIDTH_CONFIG_COUNTER                        ( LAYER1_BIT_WIDTH_CONFIG_COUNTER ),
			.LAYER2_BIT_WIDTH_WEIGHT                                ( LAYER2_BIT_WIDTH_WEIGHT ),
			.LAYER2_BIT_WIDTH_MEMBRANE                              ( LAYER2_BIT_WIDTH_MEMBRANE ),
			.LAYER2_BIT_WIDTH_SURROGATE                             ( LAYER2_BIT_WIDTH_SURROGATE ),
			.LAYER2_DEPTH_SURROGATE_BOX                             ( LAYER2_DEPTH_SURROGATE_BOX ),
			.LAYER2_BIT_WIDTH_SRAM                                  ( LAYER2_BIT_WIDTH_SRAM ),
			.LAYER2_DEPTH_SRAM                                      ( LAYER2_DEPTH_SRAM ),
			.LAYER2_BIT_WIDTH_ADDRESS                               ( LAYER2_BIT_WIDTH_ADDRESS ),
			.LAYER2_BIT_WIDTH_DELTA_WEIGHT                          ( LAYER2_BIT_WIDTH_DELTA_WEIGHT ),
			.LAYER2_NEURON_NUM_IN_SET                               ( LAYER2_NEURON_NUM_IN_SET ),
			.LAYER2_SET_NUM                                         ( LAYER2_SET_NUM ),
			.LAYER2_INPUT_SIZE                                      ( LAYER2_INPUT_SIZE ),
			.LAYER2_OUTPUT_SIZE                                     ( LAYER2_OUTPUT_SIZE ),
			.LAYER2_SPIKE_BUFFER_PAST_SIZE                          ( LAYER2_SPIKE_BUFFER_PAST_SIZE ),
			.LAYER2_BIT_WIDTH_FSM                                   ( LAYER2_BIT_WIDTH_FSM ),
			.LAYER2_BIT_WIDTH_CONFIG_COUNTER                        ( LAYER2_BIT_WIDTH_CONFIG_COUNTER ),
			.LAYER3_BIT_WIDTH_WEIGHT                                ( LAYER3_BIT_WIDTH_WEIGHT ),
			.LAYER3_BIT_WIDTH_MEMBRANE                              ( LAYER3_BIT_WIDTH_MEMBRANE ),
			.LAYER3_BIT_WIDTH_SRAM                                  ( LAYER3_BIT_WIDTH_SRAM ),
			.LAYER3_DEPTH_SRAM                                      ( LAYER3_DEPTH_SRAM ),
			.LAYER3_BIT_WIDTH_ADDRESS                               ( LAYER3_BIT_WIDTH_ADDRESS ),
			.LAYER3_BIT_WIDTH_DELTA_WEIGHT                          ( LAYER3_BIT_WIDTH_DELTA_WEIGHT ),
			.LAYER3_NEURON_NUM_IN_SET                               ( LAYER3_NEURON_NUM_IN_SET ),
			.LAYER3_SET_NUM                                         ( LAYER3_SET_NUM ),
			.LAYER3_INPUT_SIZE                                      ( LAYER3_INPUT_SIZE ),
			.LAYER3_OUTPUT_SIZE                                     ( LAYER3_OUTPUT_SIZE ),
			.LAYER3_SPIKE_BUFFER_PAST_SIZE                          ( LAYER3_SPIKE_BUFFER_PAST_SIZE ),
			.LAYER3_BIT_WIDTH_FSM                                   ( LAYER3_BIT_WIDTH_FSM ),
			.LAYER3_BIT_WIDTH_CONFIG_COUNTER                        ( LAYER3_BIT_WIDTH_CONFIG_COUNTER ),
			.LAYER3_BIT_WIDTH_BIG_MEMBRANE                          ( LAYER3_BIT_WIDTH_BIG_MEMBRANE ),
			.LAYER3_CLASSIFIER_SIZE                                 ( LAYER3_CLASSIFIER_SIZE ),
			.BIT_WIDTH_INPUT_STREAMING_DATA                         ( BIT_WIDTH_INPUT_STREAMING_DATA ),
			.INPUT_SPIKE_FIFO_DATA_WIDTH                            ( INPUT_SPIKE_FIFO_DATA_WIDTH ),
			.INOUT_BUFFERING_NUM                                    ( INOUT_BUFFERING_NUM ),
			.BIT_WIDTH_SNN_FSM                                      ( BIT_WIDTH_SNN_FSM ),
			.BIT_WIDTH_CONFIG_COUNTER_MAIN                          ( BIT_WIDTH_CONFIG_COUNTER_MAIN ),
			.CLOCK_INPUT_SPIKE_COLLECT_LONG                         ( CLOCK_INPUT_SPIKE_COLLECT_LONG ),
			.CLOCK_INPUT_SPIKE_COLLECT_SHORT                        ( CLOCK_INPUT_SPIKE_COLLECT_SHORT ),
			.INPUT_SIZE_LAYER1_LOCAL_PARAM                         ( INPUT_SIZE_LAYER1_LOCAL_PARAM )
		)u_top_bh(
			.clk                                                    ( clk                                                    ),
			.reset_n                                                ( reset_n                                                ),
			.input_streaming_valid_i                                ( input_streaming_valid_i_postbuffer                                ),
			.input_streaming_data_i                                 ( input_streaming_data_i_postbuffer                                 ),
			.input_streaming_ready_o                                ( input_streaming_ready_o_prebuffer                                ),
			.start_training_signal_i                                ( start_training_signal_i_postbuffer                                ),
			.start_inference_signal_i                               ( start_inference_signal_i_postbuffer                               ),
			.start_ready_o                                          ( start_ready_o_prebuffer                                          ),
			.inferenced_label_o                                     ( inferenced_label_o_prebuffer                                     )
		);
	`endif


	// ####### FPGA BUFFERING #######################################################################################################################
	// ####### FPGA BUFFERING #######################################################################################################################
	// ####### FPGA BUFFERING #######################################################################################################################
	// ####### FPGA BUFFERING #######################################################################################################################
	reg [2:0] fpga_input_buffer [0:FPGA_INPUT_BUFFER_SIZE-1];
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			fpga_input_buffer[0] <= 0;
		end else begin
			fpga_input_buffer[0] <= {input_streaming_ready_o_prebuffer, start_ready_o_prebuffer, inferenced_label_o_prebuffer};
		end
	end
	genvar genvar_buffer_idx1;
	generate
		for (genvar_buffer_idx1 = 1; genvar_buffer_idx1 < FPGA_INPUT_BUFFER_SIZE; genvar_buffer_idx1 = genvar_buffer_idx1 + 1) begin : gen_fpga_input_buffer
			always @(posedge clk or negedge reset_n) begin
				if (!reset_n) begin
					fpga_input_buffer[genvar_buffer_idx1] <= 0;
				end else begin
					fpga_input_buffer[genvar_buffer_idx1] <= fpga_input_buffer[genvar_buffer_idx1-1];
				end
			end
		end
	endgenerate
	`ifdef NO_FPGA_INPUT_BUFFER
		assign input_streaming_ready_o = input_streaming_ready_o_prebuffer;
		assign start_ready_o = start_ready_o_prebuffer;
		assign inferenced_label_o = inferenced_label_o_prebuffer;
	`else
		assign input_streaming_ready_o = fpga_input_buffer[FPGA_INPUT_BUFFER_SIZE-1][2];
		assign start_ready_o = fpga_input_buffer[FPGA_INPUT_BUFFER_SIZE-1][1];
		assign inferenced_label_o = fpga_input_buffer[FPGA_INPUT_BUFFER_SIZE-1][0];
	`endif

	reg [68:0] fpga_output_buffer [0:FPGA_OUTPUT_BUFFER_SIZE-1];
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			fpga_output_buffer[0] <= 0;
		end else begin
			fpga_output_buffer[0] <= {input_streaming_valid_i, input_streaming_data_i, start_training_signal_i, start_inference_signal_i};
		end
	end
	genvar genvar_buffer_idx2;
	generate
		for (genvar_buffer_idx2 = 1; genvar_buffer_idx2 < FPGA_OUTPUT_BUFFER_SIZE; genvar_buffer_idx2 = genvar_buffer_idx2 + 1) begin : gen_fpga_output_buffer
			always @(posedge clk or negedge reset_n) begin
				if (!reset_n) begin
					fpga_output_buffer[genvar_buffer_idx2] <= 0;
				end else begin
					fpga_output_buffer[genvar_buffer_idx2] <= fpga_output_buffer[genvar_buffer_idx2-1];
				end
			end
		end
	endgenerate
	`ifdef NO_FPGA_OUTPUT_BUFFER
		assign input_streaming_valid_i_postbuffer = input_streaming_valid_i;
		assign input_streaming_data_i_postbuffer = input_streaming_data_i;
		assign start_training_signal_i_postbuffer = start_training_signal_i;
		assign start_inference_signal_i_postbuffer = start_inference_signal_i;
	`else
		assign input_streaming_valid_i_postbuffer = fpga_output_buffer[FPGA_OUTPUT_BUFFER_SIZE-1][68];
		assign input_streaming_data_i_postbuffer = fpga_output_buffer[FPGA_OUTPUT_BUFFER_SIZE-1][67:2];
		assign start_training_signal_i_postbuffer = fpga_output_buffer[FPGA_OUTPUT_BUFFER_SIZE-1][1];
		assign start_inference_signal_i_postbuffer = fpga_output_buffer[FPGA_OUTPUT_BUFFER_SIZE-1][0];
	`endif
// ####### FPGA BUFFERING #######################################################################################################################
	// ####### FPGA BUFFERING #######################################################################################################################
	// ####### FPGA BUFFERING #######################################################################################################################
	// ####### FPGA BUFFERING #######################################################################################################################






	// initial begin
	// 	repeat (25000) @(posedge clk); 
	// 	$display("Test completed");
	// 	$finish;
	// end




	initial begin
		// $set_gate_level_monitoring("on");
		
		// `ifdef APR_WPAD
		// 	$set_toggle_region(u_top_wpad_bh);
		// `else
		// 	$set_toggle_region(u_top_bh);
		// `endif
		// // initialization of Verilog signals, and then:
		// $toggle_start;
	end


	// reg input_streaming_ready_o_oneclk_delay;


	// always @(posedge clk or negedge reset_n) begin
	// 	if (!reset_n) begin
	// 		input_streaming_ready_o_oneclk_delay <= 0;
	// 	end else begin
	// 		input_streaming_ready_o_oneclk_delay <= input_streaming_ready_o;
	// 	end
	// end




	
    integer i, j, k;
    integer file, r;
	integer file1;
	integer idx1;





    // Clock generation: 10ns period
    always #(`CLK_PERIOD_HALF) clk = ~clk;


	// ##### LAYER1 SETTING #######################################################################################
	// ##### LAYER1 SETTING #######################################################################################
	// ##### LAYER1 SETTING #######################################################################################
	reg signed [LAYER1_BIT_WIDTH_MEMBRANE-1:0] layer1_threshold;
	reg signed [LAYER1_BIT_WIDTH_MEMBRANE-1:0] layer1_surrogate_x_cut [0:14];
    reg signed [LAYER1_BIT_WIDTH_WEIGHT-1:0] layer1_weight [0:LAYER1_DEPTH_SRAM-1][0:LAYER1_OUTPUT_SIZE-1];  
    reg signed [LAYER1_BIT_WIDTH_WEIGHT-1:0] layer1_weight_renewal [0:LAYER1_DEPTH_SRAM-1][0:LAYER1_SET_NUM-1][0:LAYER1_NEURON_NUM_IN_SET-1];  
    reg signed [LAYER1_BIT_WIDTH_SRAM-1:0] layer1_weight_renewal2 [0:LAYER1_DEPTH_SRAM-1][0:LAYER1_SET_NUM-1];  

	initial begin
		layer1_threshold = (`LAYER1_THRESHOLD);
		layer1_surrogate_x_cut[0] = (`LAYER1_SURROGATE_X_CUT_0); 
		layer1_surrogate_x_cut[1] = (`LAYER1_SURROGATE_X_CUT_1);
		layer1_surrogate_x_cut[2] = (`LAYER1_SURROGATE_X_CUT_2);
		layer1_surrogate_x_cut[3] = (`LAYER1_SURROGATE_X_CUT_3);
		layer1_surrogate_x_cut[4] = (`LAYER1_SURROGATE_X_CUT_4);
		layer1_surrogate_x_cut[5] = (`LAYER1_SURROGATE_X_CUT_5);
		layer1_surrogate_x_cut[6] = (`LAYER1_SURROGATE_X_CUT_6);
		layer1_surrogate_x_cut[7] = (`LAYER1_SURROGATE_X_CUT_7); 
		layer1_surrogate_x_cut[8] = (`LAYER1_SURROGATE_X_CUT_8); 
		layer1_surrogate_x_cut[9] = (`LAYER1_SURROGATE_X_CUT_9); 
		layer1_surrogate_x_cut[10] = (`LAYER1_SURROGATE_X_CUT_10); 
		layer1_surrogate_x_cut[11] = (`LAYER1_SURROGATE_X_CUT_11); 
		layer1_surrogate_x_cut[12] = (`LAYER1_SURROGATE_X_CUT_12); 
		layer1_surrogate_x_cut[13] = (`LAYER1_SURROGATE_X_CUT_13);
	end

    initial begin
		file1 = $fopen("../test_vector/sweep_mode/zz_tb_vector_layer1/tb_weight_matrix0.txt", "r");
        for (i = 0; i < LAYER1_INPUT_SIZE; i = i + 1) begin
            for (j = 0; j < LAYER1_OUTPUT_SIZE; j = j + 1) begin
				if (i >= INPUT_SIZE_LAYER1_LOCAL_PARAM)
					layer1_weight[i][j] = 0;
				else
					r = $fscanf(file1, "%d", layer1_weight[i][j]);
            end
        end
        $fclose(file1);
        for (i = 0; i < LAYER1_INPUT_SIZE; i = i + 1) begin
            for (j = 0; j < LAYER1_SET_NUM; j = j + 1) begin
				for (k = 0; k < LAYER1_NEURON_NUM_IN_SET; k = k + 1) begin
					idx1 = j + (i%10);
					if (idx1 >= 10) begin
						idx1 = idx1 - 10;
					end
					layer1_weight_renewal[i][idx1][k] = layer1_weight[i][LAYER1_NEURON_NUM_IN_SET*j+k];
				end
            end
        end
        for (i = 0; i < LAYER1_DEPTH_SRAM; i = i + 1) begin
            for (j = 0; j < LAYER1_SET_NUM; j = j + 1) begin
				layer1_weight_renewal2[i][j] = {layer1_weight_renewal[i][j][19], layer1_weight_renewal[i][j][18], layer1_weight_renewal[i][j][17], layer1_weight_renewal[i][j][16], layer1_weight_renewal[i][j][15], layer1_weight_renewal[i][j][14], layer1_weight_renewal[i][j][13], layer1_weight_renewal[i][j][12], layer1_weight_renewal[i][j][11], layer1_weight_renewal[i][j][10], layer1_weight_renewal[i][j][9], layer1_weight_renewal[i][j][8], layer1_weight_renewal[i][j][7], layer1_weight_renewal[i][j][6], layer1_weight_renewal[i][j][5], layer1_weight_renewal[i][j][4], layer1_weight_renewal[i][j][3], layer1_weight_renewal[i][j][2], layer1_weight_renewal[i][j][1], layer1_weight_renewal[i][j][0]};
            end
        end
    end
	// ##### LAYER1 SETTING #######################################################################################
	// ##### LAYER1 SETTING #######################################################################################
	// ##### LAYER1 SETTING #######################################################################################
	



	
	// ##### LAYER2 SETTING #######################################################################################
	// ##### LAYER2 SETTING #######################################################################################
	// ##### LAYER2 SETTING #######################################################################################
	reg signed [LAYER2_BIT_WIDTH_MEMBRANE-1:0] layer2_threshold;
	reg signed [LAYER2_BIT_WIDTH_MEMBRANE-1:0] layer2_surrogate_x_cut [0:14];
    reg signed [LAYER2_BIT_WIDTH_WEIGHT-1:0] layer2_weight [0:LAYER2_DEPTH_SRAM-1][0:LAYER2_OUTPUT_SIZE-1];  
    reg signed [LAYER2_BIT_WIDTH_WEIGHT-1:0] layer2_weight_renewal [0:LAYER2_DEPTH_SRAM-1][0:LAYER2_SET_NUM-1][0:LAYER2_NEURON_NUM_IN_SET-1];  
    reg signed [LAYER2_BIT_WIDTH_SRAM-1:0] layer2_weight_renewal2 [0:LAYER2_DEPTH_SRAM-1][0:LAYER2_SET_NUM-1];  

	initial begin
		layer2_threshold = (`LAYER2_THRESHOLD);
		layer2_surrogate_x_cut[0] = (`LAYER2_SURROGATE_X_CUT_0); 
		layer2_surrogate_x_cut[1] = (`LAYER2_SURROGATE_X_CUT_1);
		layer2_surrogate_x_cut[2] = (`LAYER2_SURROGATE_X_CUT_2);
		layer2_surrogate_x_cut[3] = (`LAYER2_SURROGATE_X_CUT_3);
		layer2_surrogate_x_cut[4] = (`LAYER2_SURROGATE_X_CUT_4);
		layer2_surrogate_x_cut[5] = (`LAYER2_SURROGATE_X_CUT_5);
		layer2_surrogate_x_cut[6] = (`LAYER2_SURROGATE_X_CUT_6);
		layer2_surrogate_x_cut[7] = (`LAYER2_SURROGATE_X_CUT_7); 
		layer2_surrogate_x_cut[8] = (`LAYER2_SURROGATE_X_CUT_8); 
		layer2_surrogate_x_cut[9] = (`LAYER2_SURROGATE_X_CUT_9); 
		layer2_surrogate_x_cut[10] = (`LAYER2_SURROGATE_X_CUT_10); 
		layer2_surrogate_x_cut[11] = (`LAYER2_SURROGATE_X_CUT_11); 
		layer2_surrogate_x_cut[12] = (`LAYER2_SURROGATE_X_CUT_12); 
		layer2_surrogate_x_cut[13] = (`LAYER2_SURROGATE_X_CUT_13);
	end

    initial begin
		file1 = $fopen("../test_vector/sweep_mode/zz_tb_vector_layer2/tb_weight_matrix0.txt", "r");
        for (i = 0; i < LAYER2_INPUT_SIZE; i = i + 1) begin
            for (j = 0; j < LAYER2_OUTPUT_SIZE; j = j + 1) begin
				r = $fscanf(file1, "%d", layer2_weight[i][j]);
            end
        end
        $fclose(file1);
        for (i = 0; i < LAYER2_INPUT_SIZE; i = i + 1) begin
            for (j = 0; j < LAYER2_SET_NUM; j = j + 1) begin
				for (k = 0; k < LAYER2_NEURON_NUM_IN_SET; k = k + 1) begin
					idx1 = j + (i%10);
					if (idx1 >= 10) begin
						idx1 = idx1 - 10;
					end
					layer2_weight_renewal[i][idx1][k] = layer2_weight[i][LAYER2_NEURON_NUM_IN_SET*j+k];
				end
            end
        end
        for (i = 0; i < LAYER2_DEPTH_SRAM; i = i + 1) begin
            for (j = 0; j < LAYER2_SET_NUM; j = j + 1) begin
				layer2_weight_renewal2[i][j] = {layer2_weight_renewal[i][j][19], layer2_weight_renewal[i][j][18], layer2_weight_renewal[i][j][17], layer2_weight_renewal[i][j][16], layer2_weight_renewal[i][j][15], layer2_weight_renewal[i][j][14], layer2_weight_renewal[i][j][13], layer2_weight_renewal[i][j][12], layer2_weight_renewal[i][j][11], layer2_weight_renewal[i][j][10], layer2_weight_renewal[i][j][9], layer2_weight_renewal[i][j][8], layer2_weight_renewal[i][j][7], layer2_weight_renewal[i][j][6], layer2_weight_renewal[i][j][5], layer2_weight_renewal[i][j][4], layer2_weight_renewal[i][j][3], layer2_weight_renewal[i][j][2], layer2_weight_renewal[i][j][1], layer2_weight_renewal[i][j][0]};
            end
        end
    end
	// ##### LAYER2 SETTING #######################################################################################
	// ##### LAYER2 SETTING #######################################################################################
	// ##### LAYER2 SETTING #######################################################################################
	




	
	// ##### LAYER3 SETTING #######################################################################################
	// ##### LAYER3 SETTING #######################################################################################
	// ##### LAYER3 SETTING #######################################################################################
    reg binary_classifier_mode;
	reg loser_encourage_mode;
	initial begin
		binary_classifier_mode = (`BINARY_CLASSIFIER_MODE);
		loser_encourage_mode = (`LOSER_ENCOURAGE_MODE);
	end

	
	reg signed [LAYER3_BIT_WIDTH_WEIGHT-1:0] layer3_weight [0:LAYER3_DEPTH_SRAM-1][0:LAYER3_OUTPUT_SIZE-1];  
    reg signed [LAYER3_BIT_WIDTH_WEIGHT-1:0] layer3_weight_renewal [0:LAYER3_DEPTH_SRAM-1][0:LAYER3_SET_NUM-1][0:LAYER3_NEURON_NUM_IN_SET-1];  
    reg signed [LAYER3_BIT_WIDTH_SRAM-1:0] layer3_weight_renewal2 [0:LAYER3_DEPTH_SRAM-1][0:LAYER3_SET_NUM-1];  

    initial begin
		file1 = $fopen("../test_vector/sweep_mode/zz_tb_vector_layer3/tb_weight_matrix0.txt", "r");
        if (file1 == 0) begin
            $display("ERROR: File not found!");
            $finish;
        end
        for (i = 0; i < LAYER3_INPUT_SIZE; i = i + 1) begin
            for (j = 0; j < LAYER3_OUTPUT_SIZE; j = j + 1) begin
				r = $fscanf(file1, "%d", layer3_weight[i][j]);
            end
        end
        $fclose(file1);
        for (i = 0; i < LAYER3_INPUT_SIZE; i = i + 1) begin
            for (j = 0; j < LAYER3_SET_NUM; j = j + 1) begin
				for (k = 0; k < LAYER3_NEURON_NUM_IN_SET; k = k + 1) begin
					idx1 = j + (i%10);
					if (idx1 >= 10) begin
						idx1 = idx1 - 10;
					end
					layer3_weight_renewal[i][idx1][k] = layer3_weight[i][LAYER3_NEURON_NUM_IN_SET*j+k];
				end
            end
        end
        for (i = 0; i < LAYER3_DEPTH_SRAM; i = i + 1) begin
            for (j = 0; j < LAYER3_SET_NUM; j = j + 1) begin
				layer3_weight_renewal2[i][j] = {layer3_weight_renewal[i][j][0]};
            end
        end
    end
	// ##### LAYER3 SETTING #######################################################################################
	// ##### LAYER3 SETTING #######################################################################################
	// ##### LAYER3 SETTING #######################################################################################
	



	// ##### SNN SETTING #######################################################################################
	// ##### SNN SETTING #######################################################################################
	// ##### SNN SETTING #######################################################################################
	reg long_time_input_streaming_mode;
	initial begin
		long_time_input_streaming_mode = (`LONG_TIME_INPUT_STREAMING_MODE);
	end
	// ##### SNN SETTING #######################################################################################
	// ##### SNN SETTING #######################################################################################
	// ##### SNN SETTING #######################################################################################
	
 
	reg config_on;

	reg processing_on;
	reg config_on_real, n_config_on_real;
	reg processing_on_real, n_processing_on_real;



	reg first_start;
    initial begin
		// `ifdef SYN
		// 	$fsdbDumpfile("top_bh_syn.fsdb");
		// 	$fsdbDumpvars(0, u_top_bh, "+mda");
		// `endif

		`ifdef APR_WPAD
			`ifdef APR_WPAD_DUMP
				`ifdef SIM_APR_WPAD_TYPICAL
					// $dumpfile("top_bh_wpad_typical.vcd");
					$fsdbDumpfile("top_bh_wpad_typical.fsdb");
					// $fsdbDumpfile("top_bh_wpad_typical_jpersop.fsdb");
				`elsif SIM_APR_WPAD_MINIMUM
					// $dumpfile("top_bh_wpad_minimum.vcd");
					$fsdbDumpfile("top_bh_wpad_minimum.fsdb");
				`else
					// $dumpfile("top_bh_wpad_maximum.vcd");
					$fsdbDumpfile("top_bh_wpad_maximum.fsdb");
				`endif

				// $dumpvars(0, u_top_wpad_bh);
				$fsdbDumpvars(0, u_top_wpad_bh, "+mda");

				// $dumpoff;
				// $fsdbDumpoff;
			`endif
		`endif

        // Initial values
        clk = 0;
        reset_n = 0;

		first_start = 0;

		config_on = 0;
		processing_on = 0;
		// repeat (10) @(posedge clk);

        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
		#(`CLK_PERIOD/10);
        reset_n = 1;
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
		#(`CLK_PERIOD/10);
        reset_n = 0;
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
		#(`CLK_PERIOD/10);
        reset_n = 1;
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
		wait(start_ready_o==1);
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
		// If you're going to redo the config, wait for a long time before doing it. At least wait until "start ready" appears and then another 15 clocks or so.
		// But you’re not going to redo the config anyway, right?
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
		#(`CLK_PERIOD/10);
		config_on = 1; // JUST 1CLOCK
        @(posedge clk); 
		#(`CLK_PERIOD/10);
		config_on = 0;
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
		wait(config_on_real==0);
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
		wait(start_ready_o==1);
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
		#(`CLK_PERIOD/10);
		first_start = 1;
        @(posedge clk); 
		#(`CLK_PERIOD/10);
		first_start = 0;
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
		#(`CLK_PERIOD/10);
		processing_on = 1; // JUST 1CLOCK
        @(posedge clk); 
		#(`CLK_PERIOD/10);
		processing_on = 0;
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 


    end

	reg main_config_now, n_main_config_now;
	reg layer1_config_now, n_layer1_config_now;
	reg layer2_config_now, n_layer2_config_now;
	reg layer3_config_now, n_layer3_config_now;

	reg [15:0] config_counter, n_config_counter;
	reg [1:0] config_counter_one_two_three, n_config_counter_one_two_three;
	reg [15:0] config_counter_sram_row, n_config_counter_sram_row;
	reg [15:0] config_counter_sram_column, n_config_counter_sram_column;
	int random_num;
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
            config_on_real <= 0;
            main_config_now <= 0;
            layer1_config_now <= 0;
            layer2_config_now <= 0;
            layer3_config_now <= 0;

            config_counter <= 0;
            config_counter_one_two_three <= 0;
            config_counter_sram_row <= 0;
            config_counter_sram_column <= 0;

            processing_on_real <= 0;

			random_num <= 0;
		end else begin
            config_on_real <= n_config_on_real;
            main_config_now <= n_main_config_now;
            layer1_config_now <= n_layer1_config_now;
            layer2_config_now <= n_layer2_config_now;
            layer3_config_now <= n_layer3_config_now;

            config_counter <= n_config_counter;
            config_counter_one_two_three <= n_config_counter_one_two_three;
            config_counter_sram_row <= n_config_counter_sram_row;
            config_counter_sram_column <= n_config_counter_sram_column;

            processing_on_real <= n_processing_on_real;

			random_num <= $urandom;
		end
	end

	reg [BIT_WIDTH_INPUT_STREAMING_DATA-1:0] input_streaming_data_for_processing; 
	reg input_streaming_valid_for_processing;

	reg [BIT_WIDTH_INPUT_STREAMING_DATA*3-1:0] config_value;
	reg give_me_next_config_value;


	
	reg blocked_by_random_num1;
	reg blocked_by_random_num2;
	wire blocked_by_random_num_main;
	assign blocked_by_random_num_main = (blocked_by_random_num1 || blocked_by_random_num2);


	reg [6:0] streaming_successive_request_count, n_streaming_successive_request_count;
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			streaming_successive_request_count <= 0;
		end else begin
			streaming_successive_request_count <= n_streaming_successive_request_count;
		end
	end
	reg input_streaming_request_on_now_flag1;
	reg input_streaming_request_on_now_flag2;
	reg input_streaming_valid_blocking_flag;
	always @ (*) begin
		n_streaming_successive_request_count = streaming_successive_request_count;
		input_streaming_valid_blocking_flag = 0;

		if (input_streaming_request_on_now_flag1 || input_streaming_request_on_now_flag2) begin
			n_streaming_successive_request_count = streaming_successive_request_count + 1;
			if (streaming_successive_request_count == 7) begin
				n_streaming_successive_request_count = streaming_successive_request_count + 1;
				input_streaming_valid_blocking_flag = 1;
			end else if (streaming_successive_request_count == 8) begin
				n_streaming_successive_request_count = 0;
				input_streaming_valid_blocking_flag = 1;
			end
		end else begin
			n_streaming_successive_request_count = 0;
		end
	end

	always @ (*) begin	
		input_streaming_valid_i = 0;
		input_streaming_data_i = 0;
		config_value = 0;
		give_me_next_config_value = 0;

		n_config_on_real = config_on_real;
		n_main_config_now = main_config_now;
		n_layer1_config_now = layer1_config_now;
		n_layer2_config_now = layer2_config_now;
		n_layer3_config_now = layer3_config_now;

		n_config_counter = config_counter;
		n_config_counter_one_two_three = config_counter_one_two_three;
		n_config_counter_sram_row = config_counter_sram_row;
		n_config_counter_sram_column = config_counter_sram_column;

		n_processing_on_real = processing_on_real;

		blocked_by_random_num1 = 0;

		input_streaming_request_on_now_flag1 = 0;

		if (config_on) begin
			n_config_on_real = 1;
			n_main_config_now = 1;
			n_layer1_config_now = 0;
			n_layer2_config_now = 0;
			n_layer3_config_now = 0;
		end

		if (config_on_real) begin
			// if (input_streaming_ready_o_oneclk_delay) begin
			if (input_streaming_ready_o) begin
				input_streaming_request_on_now_flag1 = 1;
				`ifdef VALID_BLOCKING_AT_SUCCESSIVE_REQ
					if (input_streaming_valid_blocking_flag == 0) begin
				`endif
				if (random_num % (`RANDOM_VALID) != 0 || (`RANDOM_VALID) == 0) begin
					input_streaming_valid_i = 1;
					if (config_counter_one_two_three != 2) begin
						n_config_counter_one_two_three = config_counter_one_two_three + 1;
					end else begin
						n_config_counter_one_two_three = 0;
						give_me_next_config_value = 1;
					end
				end else begin
					blocked_by_random_num1 = 1;
				end
				`ifdef VALID_BLOCKING_AT_SUCCESSIVE_REQ
					end
				`endif
			end


			if (main_config_now) begin
				if (config_counter < 1) begin
					config_value = {{(BIT_WIDTH_INPUT_STREAMING_DATA*3-1){1'b0}}, long_time_input_streaming_mode};
					if (give_me_next_config_value) begin
						n_config_counter = 0;
						n_config_counter_sram_row = 0;
						n_config_counter_sram_column = 0;

						n_main_config_now = 0;
						n_layer1_config_now = 1;
						n_layer2_config_now = 0;
						n_layer3_config_now = 0;
					end
				end
			end else if (layer1_config_now) begin
				if (give_me_next_config_value) begin
					n_config_counter = config_counter + 1;
				end


				if (config_counter < LAYER1_DEPTH_SRAM*LAYER1_SET_NUM) begin
					config_value = {{(BIT_WIDTH_INPUT_STREAMING_DATA*3-LAYER1_BIT_WIDTH_SRAM){1'b0}}, layer1_weight_renewal2[config_counter_sram_row][config_counter_sram_column]};
					if (give_me_next_config_value) begin
						if (config_counter_sram_column == LAYER1_SET_NUM-1) begin
							n_config_counter_sram_row = config_counter_sram_row + 1;
							n_config_counter_sram_column = 0;
						end else begin
							n_config_counter_sram_column = config_counter_sram_column+1;
						end
					end
				end else if (config_counter < LAYER1_DEPTH_SRAM*LAYER1_SET_NUM+1) begin
					config_value = {{(BIT_WIDTH_INPUT_STREAMING_DATA*3-LAYER1_BIT_WIDTH_MEMBRANE){1'b0}}, layer1_threshold};
				end else if (config_counter < LAYER1_DEPTH_SRAM*LAYER1_SET_NUM+2) begin
					config_value = {{(BIT_WIDTH_INPUT_STREAMING_DATA*3-7*LAYER1_BIT_WIDTH_MEMBRANE){1'b0}}, layer1_surrogate_x_cut[6], layer1_surrogate_x_cut[5], layer1_surrogate_x_cut[4], layer1_surrogate_x_cut[3], layer1_surrogate_x_cut[2], layer1_surrogate_x_cut[1], layer1_surrogate_x_cut[0]};
				end else if (config_counter < LAYER1_DEPTH_SRAM*LAYER1_SET_NUM+2+1) begin
					config_value = {{(BIT_WIDTH_INPUT_STREAMING_DATA*3-7*LAYER1_BIT_WIDTH_MEMBRANE){1'b0}}, layer1_surrogate_x_cut[13], layer1_surrogate_x_cut[12], layer1_surrogate_x_cut[11], layer1_surrogate_x_cut[10], layer1_surrogate_x_cut[9], layer1_surrogate_x_cut[8], layer1_surrogate_x_cut[7]};
					if (give_me_next_config_value) begin
						n_config_counter = 0;
						n_config_counter_sram_row = 0;
						n_config_counter_sram_column = 0;

						n_main_config_now = 0;
						n_layer1_config_now = 0;
						n_layer2_config_now = 1;
						n_layer3_config_now = 0;
					end
				end


			end else if (layer2_config_now) begin

				if (give_me_next_config_value) begin
					n_config_counter = config_counter + 1;
				end


				if (config_counter < LAYER2_DEPTH_SRAM*LAYER2_SET_NUM) begin
					config_value = {{(BIT_WIDTH_INPUT_STREAMING_DATA*3-LAYER2_BIT_WIDTH_SRAM){1'b0}}, layer2_weight_renewal2[config_counter_sram_row][config_counter_sram_column]};
					if (give_me_next_config_value) begin
						if (config_counter_sram_column == LAYER2_SET_NUM-1) begin
							n_config_counter_sram_row = config_counter_sram_row + 1;
							n_config_counter_sram_column = 0;
						end else begin
							n_config_counter_sram_column = config_counter_sram_column+1;
						end
					end
				end else if (config_counter < LAYER2_DEPTH_SRAM*LAYER2_SET_NUM+1) begin
					config_value = {{(BIT_WIDTH_INPUT_STREAMING_DATA*3-LAYER2_BIT_WIDTH_MEMBRANE){1'b0}}, layer2_threshold};
				end else if (config_counter < LAYER2_DEPTH_SRAM*LAYER2_SET_NUM+2) begin
					config_value = {{(BIT_WIDTH_INPUT_STREAMING_DATA*3-7*LAYER2_BIT_WIDTH_MEMBRANE){1'b0}}, layer2_surrogate_x_cut[6], layer2_surrogate_x_cut[5], layer2_surrogate_x_cut[4], layer2_surrogate_x_cut[3], layer2_surrogate_x_cut[2], layer2_surrogate_x_cut[1], layer2_surrogate_x_cut[0]};
				end else if (config_counter < LAYER2_DEPTH_SRAM*LAYER2_SET_NUM+2+1) begin
					config_value = {{(BIT_WIDTH_INPUT_STREAMING_DATA*3-7*LAYER2_BIT_WIDTH_MEMBRANE){1'b0}}, layer2_surrogate_x_cut[13], layer2_surrogate_x_cut[12], layer2_surrogate_x_cut[11], layer2_surrogate_x_cut[10], layer2_surrogate_x_cut[9], layer2_surrogate_x_cut[8], layer2_surrogate_x_cut[7]};
					if (give_me_next_config_value) begin
						n_config_counter = 0;
						n_config_counter_sram_row = 0;
						n_config_counter_sram_column = 0;

						n_main_config_now = 0;
						n_layer1_config_now = 0;
						n_layer2_config_now = 0;
						n_layer3_config_now = 1;
					end
				end


			end else if (layer3_config_now) begin
				if (give_me_next_config_value) begin
					n_config_counter = config_counter + 1;
				end

				if (config_counter < LAYER3_DEPTH_SRAM*LAYER3_SET_NUM) begin
					config_value = {{(BIT_WIDTH_INPUT_STREAMING_DATA*3-LAYER3_BIT_WIDTH_SRAM){1'b0}}, layer3_weight_renewal2[config_counter_sram_row][config_counter_sram_column]};
					if (give_me_next_config_value) begin
						if (config_counter_sram_column == LAYER3_SET_NUM-1) begin
							n_config_counter_sram_row = config_counter_sram_row + 1;
							n_config_counter_sram_column = 0;
						end else begin
							n_config_counter_sram_column = config_counter_sram_column+1;
						end
					end
				end else if (config_counter < LAYER3_DEPTH_SRAM*LAYER3_SET_NUM+1) begin
					config_value = {{(BIT_WIDTH_INPUT_STREAMING_DATA*3-2){1'b0}}, loser_encourage_mode, binary_classifier_mode};
					if (give_me_next_config_value) begin
						n_config_counter_sram_row = 0;
						n_config_counter_sram_column = 0;

						n_main_config_now = 0;
						n_layer1_config_now = 0;
						n_layer2_config_now = 0;
						n_layer3_config_now = 0;

						n_config_on_real = 0;
					end
				end
			end

			input_streaming_data_i = config_value[BIT_WIDTH_INPUT_STREAMING_DATA*config_counter_one_two_three +: BIT_WIDTH_INPUT_STREAMING_DATA];
		end


		if (processing_on) begin
			n_processing_on_real = 1;
		end

		if (processing_on_real) begin
			input_streaming_data_i = input_streaming_data_for_processing;
			input_streaming_valid_i = input_streaming_valid_for_processing;
		end

	end

	
	// #### INPUT & LABEL SETTING ############################################################################################
	// #### INPUT & LABEL SETTING ############################################################################################
	// #### INPUT & LABEL SETTING ############################################################################################
	// #### INPUT & LABEL SETTING ############################################################################################
	// #### INPUT & LABEL SETTING ############################################################################################
	integer file0, file_label;
	reg input_spike_one;
	reg [3:0] this_sample_label_temp;

	wire dvs_gesture;
	wire n_mnist;
	wire n_tidigits;
	wire [9:0] timesteps;
	assign dvs_gesture = (`DVS_GESTURE_ON);
	assign n_mnist = (`N_MNIST_ON);
	assign n_tidigits = (`N_TIDIGITS_ON);
	assign timesteps = (`TIMESTEPS);
	reg [31:0] timestep_counter;
	reg [31:0] timestep_counter_no_reset;
	reg [31:0] timestep_counter_no_reset_for_training;
	reg [31:0] timestep_counter_no_reset_for_inference;
	reg [31:0] training_sample_counter;
	reg [31:0] inference_sample_counter;
	reg [31:0] iter_counter;
	// reg long_time_input_streaming_mode; 1

	reg give_me_next_spike;
	reg [979:0] input_dvs_gesture;
	reg [577:0] input_n_mnist;
	reg [511:0] input_n_tidigits;
	reg this_sample_done;
	reg this_epoch_finish;
	reg [3:0] this_sample_label;
	reg [31:0] label_counter_for_training;
	reg training_zero_inference_one;

	wire stop_signal;
	assign stop_signal = (timestep_counter_no_reset == total_iter_finish_cut * timesteps);
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			input_dvs_gesture <= 0;
			input_n_mnist <= 0;
			input_n_tidigits <= 0;
			timestep_counter <= 0;
			timestep_counter_no_reset <= 0;
			timestep_counter_no_reset_for_training <= 0;
			timestep_counter_no_reset_for_inference <= 0;
			training_sample_counter <= 0;
			inference_sample_counter <= 0;
			total_iter_counter <= 0;
			iter_counter <= 0;
			this_sample_done <= 0;
			this_epoch_finish <= 0;
			this_sample_label <= 0;
			label_counter_for_training <= 0;
			`ifdef INF_ONLY_ON_SWEEP_MODE
				training_zero_inference_one <= 1;
			`else
				training_zero_inference_one <= 0;
			`endif
		end else begin
			if (stop_signal == 0) begin
				if (give_me_next_spike) begin
					if (training_zero_inference_one == 0) begin
						timestep_counter <= (timestep_counter != timesteps - 1) ? timestep_counter + 1 : 0;
						timestep_counter_no_reset <= timestep_counter_no_reset + 1;
						timestep_counter_no_reset_for_training <= timestep_counter_no_reset_for_training + 1;
						training_sample_counter <= (timestep_counter == timesteps - 1) ? training_sample_counter + 1 : training_sample_counter;

						this_sample_done <= (timestep_counter == timesteps - 1) ? 1 : 0; 
						if (timestep_counter == timesteps - 1 && iter_counter == (`TRAINING_ITER_PER_EPOCH) - 1) begin
							iter_counter <= 0;
							this_epoch_finish <= 1;
							total_iter_counter <= (timestep_counter == timesteps - 1) ? total_iter_counter + 1 : total_iter_counter;
							training_zero_inference_one <= ~training_zero_inference_one;
						end else begin
							iter_counter <= (timestep_counter == timesteps - 1) ? iter_counter + 1 : iter_counter;
							this_epoch_finish <= 0;
							total_iter_counter <= (timestep_counter == timesteps - 1) ? total_iter_counter + 1 : total_iter_counter;
						end

						file_label = $fopen($sformatf("../test_vector/sweep_mode/zz_tb_vector_layer3/tb_label%0d.txt", timestep_counter_no_reset_for_training), "r");
						if (file_label == 0) begin
							$display("Failed to open tb_label.txt");
							$finish;
						end
						r = $fscanf(file_label, "%0d", this_sample_label_temp);
						$fclose(file_label);
						this_sample_label <= this_sample_label_temp;

						file0 = $fopen($sformatf("../test_vector/sweep_mode/zz_tb_vector_layer1/tb_input_activation%0d.txt", timestep_counter_no_reset), "r");
						
						if (dvs_gesture) begin
							if (file0 == 0) begin
								$display("Failed to open input_activation.txt");
								$finish;
							end
							for (i = 0; i < 980; i = i + 1) begin
									r = $fscanf(file0, "%b", input_spike_one);
									input_dvs_gesture[i] <= input_spike_one;
							end
							$fclose(file0);
						end else if (n_mnist) begin
							if (file0 == 0) begin
								$display("Failed to open input_activation.txt");
								$finish;
							end
							for (i = 0; i < 578; i = i + 1) begin
									r = $fscanf(file0, "%b", input_spike_one);
									input_n_mnist[i] <= input_spike_one;
							end
							$fclose(file0);
						end else if (n_tidigits) begin
							if (file0 == 0) begin
								$display("Failed to open input_activation.txt");
								$finish;
							end
							for (i = 0; i < 512; i = i + 1) begin
									r = $fscanf(file0, "%b", input_spike_one);
									input_n_tidigits[i] <= input_spike_one;
							end
							$fclose(file0);
						end
					end else begin
						timestep_counter <= (timestep_counter != timesteps - 1) ? timestep_counter + 1 : 0;
						timestep_counter_no_reset <= timestep_counter_no_reset + 1;
						timestep_counter_no_reset_for_inference <= timestep_counter_no_reset_for_inference + 1;
						inference_sample_counter <= (timestep_counter == timesteps - 1) ? inference_sample_counter + 1 : inference_sample_counter;

						this_sample_done <= (timestep_counter == timesteps - 1) ? 1 : 0; 
						if (timestep_counter == timesteps - 1 && iter_counter == (`INFERENCE_ITER_PER_EPOCH) - 1) begin
							iter_counter <= 0;
							training_zero_inference_one <= ~training_zero_inference_one;
							this_epoch_finish <= 1;
							total_iter_counter <= (timestep_counter == timesteps - 1) ? total_iter_counter + 1 : total_iter_counter;
						end else begin
							iter_counter <= (timestep_counter == timesteps - 1) ? iter_counter + 1 : iter_counter;
							this_epoch_finish <= 0;
							total_iter_counter <= (timestep_counter == timesteps - 1) ? total_iter_counter + 1 : total_iter_counter;
						end

						this_sample_label <= 0;

						file0 = $fopen($sformatf("../test_vector/sweep_mode/zz_tb_vector_layer1/tb_input_activation%0d.txt", timestep_counter_no_reset), "r");
						
						if (dvs_gesture) begin
							if (file0 == 0) begin
								$display("Failed to open input_activation.txt");
								$finish;
							end
							for (i = 0; i < 980; i = i + 1) begin
									r = $fscanf(file0, "%b", input_spike_one);
									input_dvs_gesture[i] <= input_spike_one;
							end
							$fclose(file0);
						end else if (n_mnist) begin
							if (file0 == 0) begin
								$display("Failed to open input_activation.txt");
								$finish;
							end
							for (i = 0; i < 578; i = i + 1) begin
									r = $fscanf(file0, "%b", input_spike_one);
									input_n_mnist[i] <= input_spike_one;
							end
							$fclose(file0);
						end else if (n_tidigits) begin
							if (file0 == 0) begin
								$display("Failed to open input_activation.txt");
								$finish;
							end
							for (i = 0; i < 512; i = i + 1) begin
									r = $fscanf(file0, "%b", input_spike_one);
									input_n_tidigits[i] <= input_spike_one;
							end
							$fclose(file0);
						end
					end
				end
			end
		end
	end


	reg [BIT_WIDTH_INPUT_STREAMING_DATA*CLOCK_INPUT_SPIKE_COLLECT_LONG-1:0] input_activation_streaming_format; //990bit
	always @ (*) begin
		input_activation_streaming_format = 0;
		if (dvs_gesture) begin
			input_activation_streaming_format = {{(BIT_WIDTH_INPUT_STREAMING_DATA*CLOCK_INPUT_SPIKE_COLLECT_LONG - INPUT_SPIKE_FIFO_DATA_WIDTH){1'b0}}, this_sample_label, this_epoch_finish, this_sample_done, input_dvs_gesture};
		end else if (n_mnist) begin
			// 580~583 label
			// 579 this_epoch_finish
			// 578 this_sample_done
			// 0~577 input
			input_activation_streaming_format = {{(BIT_WIDTH_INPUT_STREAMING_DATA*CLOCK_INPUT_SPIKE_COLLECT_LONG - 584){1'b0}}, this_sample_label, this_epoch_finish, this_sample_done, input_n_mnist};
		end else if (n_tidigits) begin
			// 580~583 label
			// 579 this_epoch_finish
			// 578 this_sample_done
			// 0~511 input
			input_activation_streaming_format = {{(BIT_WIDTH_INPUT_STREAMING_DATA*CLOCK_INPUT_SPIKE_COLLECT_LONG - 584){1'b0}}, this_sample_label, this_epoch_finish, this_sample_done, {66{1'b0}}, input_n_tidigits};
		end
	end


	reg [4:0] streaming_counter_small, n_streaming_counter_small;

	reg standby_on, n_standby_on;
	reg restart_signal;
	reg before_task_training_zero_inference_one, n_before_task_training_zero_inference_one;

	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			streaming_counter_small <= 0;
			before_task_training_zero_inference_one <= 0;
			standby_on <= 0;
		end else begin
			streaming_counter_small <= n_streaming_counter_small;
			before_task_training_zero_inference_one <= n_before_task_training_zero_inference_one;
			standby_on <= n_standby_on;
		end
	end
	always @ (*) begin
		n_streaming_counter_small = streaming_counter_small;
		input_streaming_data_for_processing = input_activation_streaming_format[BIT_WIDTH_INPUT_STREAMING_DATA*streaming_counter_small +: BIT_WIDTH_INPUT_STREAMING_DATA];
		input_streaming_valid_for_processing = 0;
		n_standby_on = standby_on;

		give_me_next_spike = 0;

		blocked_by_random_num2 = 0;

		input_streaming_request_on_now_flag2 = 0;

		if (processing_on) begin
			give_me_next_spike = 1;
		end


		if (processing_on_real) begin
			if (standby_on == 0) begin
				// if (input_streaming_ready_o_oneclk_delay) begin
				if (input_streaming_ready_o) begin
					input_streaming_request_on_now_flag2 = 1;
					`ifdef VALID_BLOCKING_AT_SUCCESSIVE_REQ
						if (input_streaming_valid_blocking_flag == 0) begin
					`endif
					if (random_num % (`RANDOM_VALID) != 0 || (`RANDOM_VALID) == 0) begin
						input_streaming_valid_for_processing = 1;
						if (long_time_input_streaming_mode) begin
							if (streaming_counter_small != CLOCK_INPUT_SPIKE_COLLECT_LONG-1) begin
								n_streaming_counter_small = streaming_counter_small + 1;
							end else begin
								n_streaming_counter_small = 0;
								give_me_next_spike = 1;
								if (this_epoch_finish) begin
									n_standby_on = 1;
								end
							end
						end else begin
							if (streaming_counter_small != CLOCK_INPUT_SPIKE_COLLECT_SHORT-1) begin
								n_streaming_counter_small = streaming_counter_small + 1;
							end else begin
								n_streaming_counter_small = 0;
								give_me_next_spike = 1;
								if (this_epoch_finish) begin
									n_standby_on = 1;
								end
							end
						end
					end else begin
						blocked_by_random_num2 = 1;
					end
					`ifdef VALID_BLOCKING_AT_SUCCESSIVE_REQ
						end
					`endif
				end
			end
		end

		if (stop_signal && give_me_next_spike) begin
			n_standby_on = 1;
		end


		if (restart_signal) begin
			n_standby_on = 0;
		end
	end

	initial begin
		wait(stop_signal == 1 && standby_on == 1);
		wait(start_ready_o);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		
		// // testbench
		// $toggle_stop;
		// `ifdef APR_WPAD
		// 	$toggle_report("top_wpad_bh_saif_file.saif", 1e-9,u_top_wpad_bh);
		// `else
		// 	$toggle_report("top_bh_saif_file.saif", 1e-9,u_top_bh);
		// `endif

		$display("Test completed  Total Iterations: %d, Expected Iterations: %d", total_iter_counter, total_iter_finish_cut);
		$finish;
	end	

	always @ (*) begin
		n_before_task_training_zero_inference_one = before_task_training_zero_inference_one;
		start_training_signal_i = 0;
		start_inference_signal_i = 0;
		restart_signal = 0;


		if (first_start) begin
			`ifdef INF_ONLY_ON_SWEEP_MODE
				start_training_signal_i = 0;
				start_inference_signal_i = 1;
			`else
				start_training_signal_i = 1;
				start_inference_signal_i = 0;
			`endif
			
			n_before_task_training_zero_inference_one = 0;
		end

		if (stop_signal == 0) begin
			if (processing_on_real) begin
				if (standby_on) begin
					if (start_ready_o) begin
						n_before_task_training_zero_inference_one = ~before_task_training_zero_inference_one;
						start_training_signal_i = (before_task_training_zero_inference_one == 1);
						start_inference_signal_i = (before_task_training_zero_inference_one == 0);
						restart_signal = 1;
					end
				end
			end
		end
	end


	

	// wire inferenced_label_o; 

	reg [1:0] inferenced_label_shooting_cnt, n_inferenced_label_shooting_cnt;
	reg inferenced_label_shooting_ongoing, n_inferenced_label_shooting_ongoing;
	reg [3:0] inferenced_label_final, n_inferenced_label_final;
	reg inferenced_label_collect_complete_flag, n_inferenced_label_collect_complete_flag;

	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			inferenced_label_shooting_cnt <= 0;
			inferenced_label_shooting_ongoing <= 0;
			inferenced_label_final <= 0;
			inferenced_label_collect_complete_flag <= 0;
		end else begin
			inferenced_label_shooting_cnt <= n_inferenced_label_shooting_cnt;
			inferenced_label_shooting_ongoing <= n_inferenced_label_shooting_ongoing;
			inferenced_label_final <= n_inferenced_label_final;
			inferenced_label_collect_complete_flag <= n_inferenced_label_collect_complete_flag;
		end
	end
	always @ (*) begin
		n_inferenced_label_shooting_cnt = inferenced_label_shooting_cnt;
		n_inferenced_label_shooting_ongoing = inferenced_label_shooting_ongoing;
		n_inferenced_label_final = inferenced_label_final;
		n_inferenced_label_collect_complete_flag = 0;

		if (inferenced_label_shooting_ongoing == 0) begin
			if (inferenced_label_o) begin
				n_inferenced_label_shooting_ongoing = 1;
			end
		end else begin
			n_inferenced_label_final[inferenced_label_shooting_cnt] = inferenced_label_o;
			if (inferenced_label_shooting_cnt != 3) begin
				n_inferenced_label_shooting_cnt = inferenced_label_shooting_cnt + 1;
			end else begin
				n_inferenced_label_shooting_cnt = 0;
				n_inferenced_label_shooting_ongoing = 0;
				n_inferenced_label_collect_complete_flag = 1;
			end
		end
	end
	
	integer fd2;
	assign software_hardware_check_final_label = inferenced_label_collect_complete_flag;
	integer timestep_counter_check_final_label;
	initial timestep_counter_check_final_label = 0;
	always @(negedge clk) begin
		if (software_hardware_check_final_label) begin
			if (timestep_counter_check_final_label >= 0) begin
				fd2 = $fopen($sformatf("../test_vector/sweep_mode/zz_tb_vector_layer3_hw/tb_final_label%0d.txt", timestep_counter_check_final_label-0), "w");
				$fwrite(fd2, "%0d", inferenced_label_final);
				$fwrite(fd2, "\n");
				$fclose(fd2);
			end
			timestep_counter_check_final_label <= timestep_counter_check_final_label + 1;
		end
	end




endmodule
