module snn_sram_inserted #( 
	// ########## LAYER 1 PARAMETER ###########################################################
	parameter       LAYER1_BIT_WIDTH_WEIGHT         = 8,  
    parameter       LAYER1_BIT_WIDTH_MEMBRANE       = 17,

	parameter       LAYER1_BIT_WIDTH_SURROGATE       = 3,
	parameter       LAYER1_DEPTH_SURROGATE_BOX       = 2,

	parameter       LAYER1_BIT_WIDTH_SRAM         = 160,  
	parameter       LAYER1_DEPTH_SRAM             = 980,
	parameter       LAYER1_BIT_WIDTH_ADDRESS      = 10,

	parameter       LAYER1_BIT_WIDTH_DELTA_WEIGHT       = 4,

	parameter       LAYER1_NEURON_NUM_IN_SET = 20,
	parameter       LAYER1_SET_NUM = 10,

	parameter       LAYER1_INPUT_SIZE = 980,
	parameter       LAYER1_OUTPUT_SIZE = 200,
	parameter 		LAYER1_SPIKE_BUFFER_PAST_SIZE = 3,

	parameter       LAYER1_BIT_WIDTH_FSM = 2,

	parameter       LAYER1_BIT_WIDTH_CONFIG_COUNTER = 14,
	// ########## LAYER 1 PARAMETER ###########################################################





	// ########## LAYER 2 PARAMETER ###########################################################
	parameter       LAYER2_BIT_WIDTH_WEIGHT         = 8,  
    parameter       LAYER2_BIT_WIDTH_MEMBRANE       = 16,

	parameter       LAYER2_BIT_WIDTH_SURROGATE       = 3,
	parameter       LAYER2_DEPTH_SURROGATE_BOX       = 1,

	parameter       LAYER2_BIT_WIDTH_SRAM         = 160,  
	parameter       LAYER2_DEPTH_SRAM             = 200,
	parameter       LAYER2_BIT_WIDTH_ADDRESS      = 8,

	parameter       LAYER2_BIT_WIDTH_DELTA_WEIGHT       = 4,

	parameter       LAYER2_NEURON_NUM_IN_SET = 20,
	parameter       LAYER2_SET_NUM = 10,

	parameter       LAYER2_INPUT_SIZE = 200,
	parameter       LAYER2_OUTPUT_SIZE = 200,
	parameter 		LAYER2_SPIKE_BUFFER_PAST_SIZE = 2,

	parameter       LAYER2_BIT_WIDTH_FSM = 2,

	parameter       LAYER2_BIT_WIDTH_CONFIG_COUNTER = 11,
	// ########## LAYER 2 PARAMETER ###########################################################




 
	// ########## LAYER 3 PARAMETER ###########################################################
	parameter       LAYER3_BIT_WIDTH_WEIGHT         = 8,  
    parameter       LAYER3_BIT_WIDTH_MEMBRANE       = 16,


	parameter       LAYER3_BIT_WIDTH_SRAM         = 8,  
	parameter       LAYER3_DEPTH_SRAM             = 200,
	parameter       LAYER3_BIT_WIDTH_ADDRESS      = 8,

	parameter       LAYER3_BIT_WIDTH_DELTA_WEIGHT       = 2,


	parameter       LAYER3_NEURON_NUM_IN_SET = 1,
	parameter       LAYER3_SET_NUM = 10,

	parameter       LAYER3_INPUT_SIZE = 200,
	parameter       LAYER3_OUTPUT_SIZE = 10,
	parameter 		LAYER3_SPIKE_BUFFER_PAST_SIZE = 1,

	parameter       LAYER3_BIT_WIDTH_FSM = 2,

	parameter       LAYER3_BIT_WIDTH_CONFIG_COUNTER = 11,

    parameter       LAYER3_BIT_WIDTH_BIG_MEMBRANE       = 16,

	parameter       LAYER3_CLASSIFIER_SIZE = 10,
	// ########## LAYER 3 PARAMETER ###########################################################



	// ########## SNN PARAMETER ###############################################################
	parameter       BIT_WIDTH_INPUT_STREAMING_DATA = 66,

	parameter       INPUT_SPIKE_FIFO_DATA_WIDTH = 986, // 980+6 (sampledone1bit, epochfinish1bit, label4bit) <= BIT_WIDTH_INPUT_STREAMING_DATA*CLOCK_INPUT_SPIKE_COLLECT_LONG

	parameter	    INOUT_BUFFERING_NUM = 3, 

	parameter       BIT_WIDTH_SNN_FSM = 2,
	parameter       BIT_WIDTH_CONFIG_COUNTER_MAIN = 14,

	parameter       CLOCK_INPUT_SPIKE_COLLECT_LONG = 15, // 986 <= 66*15 ==990
	parameter       CLOCK_INPUT_SPIKE_COLLECT_SHORT = 9,
	// ########## SNN PARAMETER ###############################################################

	parameter       INPUT_SIZE_LAYER1_LOCAL_PARAM = 980

    )(
		input clk,
		input reset_n,

		input input_streaming_valid_i,
		input [BIT_WIDTH_INPUT_STREAMING_DATA-1:0] input_streaming_data_i,
		output input_streaming_ready_o,

		input start_training_signal_i, 
		input start_inference_signal_i, 
		output start_ready_o, 

		output inferenced_label_o 
	);


	// ######## SRAM PORT ###########################################################################
	// ######## SRAM PORT ###########################################################################
	// ######## SRAM PORT ###########################################################################
	// layer1
	wire [LAYER1_BIT_WIDTH_ADDRESS*LAYER1_SET_NUM-1:0] layer1_port_sram_sram_port1_address_o;
	wire [LAYER1_SET_NUM-1:0] layer1_port_sram_sram_port1_enable_o;
	wire [LAYER1_SET_NUM-1:0] layer1_port_sram_sram_port1_write_enable_o;
	wire [LAYER1_BIT_WIDTH_SRAM*LAYER1_SET_NUM-1:0] layer1_port_sram_sram_port1_write_data_o;

	wire layer1_port_sram_sram_software_hardware_check_weight_o;

	wire [LAYER1_BIT_WIDTH_SRAM*LAYER1_SET_NUM-1:0] layer1_port_sram_sram_port1_read_data_i;

	// layer2
	wire [LAYER2_BIT_WIDTH_ADDRESS*LAYER2_SET_NUM-1:0] layer2_port_sram_sram_port1_address_o;
	wire [LAYER2_SET_NUM-1:0] layer2_port_sram_sram_port1_enable_o;
	wire [LAYER2_SET_NUM-1:0] layer2_port_sram_sram_port1_write_enable_o;
	wire [LAYER2_BIT_WIDTH_SRAM*LAYER2_SET_NUM-1:0] layer2_port_sram_sram_port1_write_data_o;

	wire layer2_port_sram_sram_software_hardware_check_weight_o;

	wire [LAYER2_BIT_WIDTH_SRAM*LAYER2_SET_NUM-1:0] layer2_port_sram_sram_port1_read_data_i;

	// layer3
	wire [LAYER3_BIT_WIDTH_ADDRESS*LAYER3_SET_NUM-1:0] layer3_port_sram_sram_port1_address_o;
	wire [LAYER3_SET_NUM-1:0] layer3_port_sram_sram_port1_enable_o;
	wire [LAYER3_SET_NUM-1:0] layer3_port_sram_sram_port1_write_enable_o;
	wire [LAYER3_BIT_WIDTH_SRAM*LAYER3_SET_NUM-1:0] layer3_port_sram_sram_port1_write_data_o;

	wire layer3_port_sram_sram_software_hardware_check_weight_o;

	wire [LAYER3_BIT_WIDTH_SRAM*LAYER3_SET_NUM-1:0] layer3_port_sram_sram_port1_read_data_i;
	// ######## SRAM PORT ###########################################################################
	// ######## SRAM PORT ###########################################################################
	// ######## SRAM PORT ###########################################################################






	// // ########## SRAM_SIM INST ###########################################################################
	// // ########## SRAM_SIM INST ###########################################################################
	// // ########## SRAM_SIM INST ###########################################################################
	// sram_set_layer1_for_sim#(
	// 	.BIT_WIDTH_WEIGHT                  ( LAYER1_BIT_WIDTH_WEIGHT ),
	// 	.BIT_WIDTH_SRAM                  ( LAYER1_BIT_WIDTH_SRAM ),
	// 	.DEPTH_SRAM                      ( LAYER1_DEPTH_SRAM ),
	// 	.BIT_WIDTH_ADDRESS               ( LAYER1_BIT_WIDTH_ADDRESS ),
	// 	.NEURON_NUM_IN_SET               ( LAYER1_NEURON_NUM_IN_SET ),
	// 	.SET_NUM                         ( LAYER1_SET_NUM ),
	// 	.THIS_DATA_INPUT_SIZE                         ( INPUT_SIZE_LAYER1_LOCAL_PARAM )
	// )u_sram_set_layer1_for_sim(
	// 	.clk                             ( clk                             ),
	// 	.reset_n                         ( reset_n                         ),
	// 	.port1_address_i                 ( layer1_port_sram_sram_port1_address_o ),
	// 	.port1_enable_i                  ( layer1_port_sram_sram_port1_enable_o             ),
	// 	.port1_write_enable_i            ( layer1_port_sram_sram_port1_write_enable_o         ),
	// 	.port1_write_data_i              ( layer1_port_sram_sram_port1_write_data_o      ),
	// 	.software_hardware_check_weight_i ( layer1_port_sram_sram_software_hardware_check_weight_o ),
	// 	.port1_read_data_o               ( layer1_port_sram_sram_port1_read_data_i    )
	// );
	// sram_set_layer2_for_sim#(
	// 	.BIT_WIDTH_WEIGHT                  ( LAYER2_BIT_WIDTH_WEIGHT ),
	// 	.BIT_WIDTH_SRAM                  ( LAYER2_BIT_WIDTH_SRAM ),
	// 	.DEPTH_SRAM                      ( LAYER2_DEPTH_SRAM ),
	// 	.BIT_WIDTH_ADDRESS               ( LAYER2_BIT_WIDTH_ADDRESS ),
	// 	.NEURON_NUM_IN_SET               ( LAYER2_NEURON_NUM_IN_SET ),
	// 	.SET_NUM                         ( LAYER2_SET_NUM )
	// )u_sram_set_layer2_for_sim(
	// 	.clk                             ( clk                             ),
	// 	.reset_n                         ( reset_n                         ),
	// 	.port1_address_i                 ( layer2_port_sram_sram_port1_address_o ),
	// 	.port1_enable_i                  ( layer2_port_sram_sram_port1_enable_o             ),
	// 	.port1_write_enable_i            ( layer2_port_sram_sram_port1_write_enable_o         ),
	// 	.port1_write_data_i              ( layer2_port_sram_sram_port1_write_data_o      ),
	// 	.software_hardware_check_weight_i ( layer2_port_sram_sram_software_hardware_check_weight_o ),
	// 	.port1_read_data_o               ( layer2_port_sram_sram_port1_read_data_i    )
	// );
	// sram_set_layer3_for_sim#(
	// 	.BIT_WIDTH_WEIGHT                  ( LAYER3_BIT_WIDTH_WEIGHT ),
	// 	.BIT_WIDTH_SRAM                  ( LAYER3_BIT_WIDTH_SRAM ),
	// 	.DEPTH_SRAM                      ( LAYER3_DEPTH_SRAM ),
	// 	.BIT_WIDTH_ADDRESS               ( LAYER3_BIT_WIDTH_ADDRESS ),
	// 	.NEURON_NUM_IN_SET               ( LAYER3_NEURON_NUM_IN_SET ),
	// 	.SET_NUM                         ( LAYER3_SET_NUM )
	// )u_sram_set_layer3_for_sim(
	// 	.clk                             ( clk                             ),
	// 	.reset_n                         ( reset_n                         ),
	// 	.port1_address_i                 ( layer3_port_sram_sram_port1_address_o ),
	// 	.port1_enable_i                  ( layer3_port_sram_sram_port1_enable_o             ),
	// 	.port1_write_enable_i            ( layer3_port_sram_sram_port1_write_enable_o         ),
	// 	.port1_write_data_i              ( layer3_port_sram_sram_port1_write_data_o      ),
	// 	.software_hardware_check_weight_i ( layer3_port_sram_sram_software_hardware_check_weight_o ),
	// 	.port1_read_data_o               ( layer3_port_sram_sram_port1_read_data_i    )
	// );
	// // ########## SRAM_SIM INST ###########################################################################
	// // ########## SRAM_SIM INST ###########################################################################
	// // ########## SRAM_SIM INST ###########################################################################





	// ########## SRAM_REAL INST ###########################################################################
	// ########## SRAM_REAL INST ###########################################################################
	// ########## SRAM_REAL INST ###########################################################################
	sram_real_layer1_set#(
		.BIT_WIDTH_WEIGHT                  ( LAYER1_BIT_WIDTH_WEIGHT ),
		.BIT_WIDTH_SRAM                  ( LAYER1_BIT_WIDTH_SRAM ),
		.DEPTH_SRAM                      ( LAYER1_DEPTH_SRAM ),
		.BIT_WIDTH_ADDRESS               ( LAYER1_BIT_WIDTH_ADDRESS ),
		.NEURON_NUM_IN_SET               ( LAYER1_NEURON_NUM_IN_SET ),
		.SET_NUM                         ( LAYER1_SET_NUM )
	)u_sram_real_layer1_set(
		.clk                              ( clk                              ),
		.port1_address_i                 ( layer1_port_sram_sram_port1_address_o ),
		.port1_enable_i                  ( layer1_port_sram_sram_port1_enable_o             ),
		.port1_write_enable_i            ( layer1_port_sram_sram_port1_write_enable_o         ),
		.port1_write_data_i              ( layer1_port_sram_sram_port1_write_data_o      ),
		.port1_read_data_o               ( layer1_port_sram_sram_port1_read_data_i    )
	);
	sram_real_layer2_set#(
		.BIT_WIDTH_WEIGHT                  ( LAYER2_BIT_WIDTH_WEIGHT ),
		.BIT_WIDTH_SRAM                  ( LAYER2_BIT_WIDTH_SRAM ),
		.DEPTH_SRAM                      ( LAYER2_DEPTH_SRAM ),
		.BIT_WIDTH_ADDRESS               ( LAYER2_BIT_WIDTH_ADDRESS ),
		.NEURON_NUM_IN_SET               ( LAYER2_NEURON_NUM_IN_SET ),
		.SET_NUM                         ( LAYER2_SET_NUM )
	)u_sram_real_layer2_set(
		.clk                             ( clk                             ),
		.port1_address_i                 ( layer2_port_sram_sram_port1_address_o ),
		.port1_enable_i                  ( layer2_port_sram_sram_port1_enable_o             ),
		.port1_write_enable_i            ( layer2_port_sram_sram_port1_write_enable_o         ),
		.port1_write_data_i              ( layer2_port_sram_sram_port1_write_data_o      ),
		.port1_read_data_o               ( layer2_port_sram_sram_port1_read_data_i    )
	);
	sram_real_layer3_set#(
		.BIT_WIDTH_WEIGHT                  ( LAYER3_BIT_WIDTH_WEIGHT ),
		.BIT_WIDTH_SRAM                  ( LAYER3_BIT_WIDTH_SRAM ),
		.DEPTH_SRAM                      ( LAYER3_DEPTH_SRAM ),
		.BIT_WIDTH_ADDRESS               ( LAYER3_BIT_WIDTH_ADDRESS ),
		.NEURON_NUM_IN_SET               ( LAYER3_NEURON_NUM_IN_SET ),
		.SET_NUM                         ( LAYER3_SET_NUM )
	)u_sram_real_layer3_set(
		.clk                             ( clk                             ),
		.port1_address_i                 ( layer3_port_sram_sram_port1_address_o ),
		.port1_enable_i                  ( layer3_port_sram_sram_port1_enable_o             ),
		.port1_write_enable_i            ( layer3_port_sram_sram_port1_write_enable_o         ),
		.port1_write_data_i              ( layer3_port_sram_sram_port1_write_data_o      ),
		.port1_read_data_o               ( layer3_port_sram_sram_port1_read_data_i    )
	);
	// ########## SRAM_REAL INST ###########################################################################
	// ########## SRAM_REAL INST ###########################################################################
	// ########## SRAM_REAL INST ###########################################################################









	reg [BIT_WIDTH_SNN_FSM-1:0] fsm_state, n_fsm_state;


    // FSM local param
    localparam STATE_CONFIG                    = 0;
    localparam STATE_PROCESSING_TRAINING       = 1;
    localparam STATE_PROCESSING_INFERENCE      = 2;






	// ########## LAYER 1 PORT ###########################################################################
	// ########## LAYER 1 PORT ###########################################################################
	// ########## LAYER 1 PORT ###########################################################################
	reg layer1_port_config_valid;
	wire layer1_port_do_not_config_now;
	
	reg [LAYER1_INPUT_SIZE-1:0] layer1_port_input_spike;
	reg layer1_port_input_setting_done;
	reg layer1_port_error_setting_done;
	reg layer1_port_this_sample_done;
	reg layer1_port_this_epoch_finish;
	
	wire layer1_port_input_setting_catch_ready;
	wire layer1_port_error_setting_catch_ready;

	wire layer1_port_start_ready;
	reg layer1_port_training_start_flag;
	reg layer1_port_inference_start_flag;

	reg layer1_port_weight_update_skip;
	reg [3:0] layer1_port_error_class_first;
	reg [3:0] layer1_port_error_class_second;
	
	reg layer1_port_post_spike_catch_done;
	wire [LAYER1_OUTPUT_SIZE-1:0] layer1_port_post_spike;
	wire layer1_port_post_spike_valid;
	// ########## LAYER 1 PORT ###########################################################################
	// ########## LAYER 1 PORT ###########################################################################
	// ########## LAYER 1 PORT ###########################################################################





	// ########## LAYER 2 PORT ###########################################################################
	// ########## LAYER 2 PORT ###########################################################################
	// ########## LAYER 2 PORT ###########################################################################
	reg layer2_port_config_valid;
	wire layer2_port_do_not_config_now;
	
	reg [LAYER2_INPUT_SIZE-1:0] layer2_port_input_spike;
	reg layer2_port_input_setting_done;
	reg layer2_port_error_setting_done;
	reg layer2_port_this_sample_done;
	reg layer2_port_this_epoch_finish;
	
	wire layer2_port_input_setting_catch_ready;
	wire layer2_port_error_setting_catch_ready;

	wire layer2_port_start_ready;
	reg layer2_port_training_start_flag;
	reg layer2_port_inference_start_flag;

	reg layer2_port_weight_update_skip;
	reg [3:0] layer2_port_error_class_first;
	reg [3:0] layer2_port_error_class_second;
	
	reg layer2_port_post_spike_catch_done;
	wire [LAYER2_OUTPUT_SIZE-1:0] layer2_port_post_spike;
	wire layer2_port_post_spike_valid;
	// ########## LAYER 2 PORT ###########################################################################
	// ########## LAYER 2 PORT ###########################################################################
	// ########## LAYER 2 PORT ###########################################################################




	// ########## LAYER 3 PORT ###########################################################################
	// ########## LAYER 3 PORT ###########################################################################
	// ########## LAYER 3 PORT ###########################################################################
	reg layer3_port_config_valid;
	wire layer3_port_do_not_config_now;
	
	reg [LAYER3_INPUT_SIZE-1:0] layer3_port_input_spike;
	reg layer3_port_input_setting_done;
	reg [3:0] layer3_port_this_sample_label;
	reg layer3_port_this_sample_done;
	reg layer3_port_this_epoch_finish;
	
	wire layer3_port_input_setting_catch_ready;

	wire layer3_port_start_ready;
	reg layer3_port_training_start_flag;
	reg layer3_port_inference_start_flag;

	wire layer3_port_weight_update_skip;
	wire [3:0] layer3_port_error_class_first;
	wire [3:0] layer3_port_error_class_second;
	
	reg layer3_port_error_class_catch_done;
	wire layer3_port_error_class_valid;

	reg layer3_port_inferenced_class_catch_done;
	wire [3:0] layer3_port_inferenced_class;
	wire layer3_port_inferenced_class_valid;
	// ########## LAYER 3 PORT ###########################################################################
	// ########## LAYER 3 PORT ###########################################################################
	// ########## LAYER 3 PORT ###########################################################################







	// ##### INOUT NAIVE BUFFERING #############################################################################################
	// ##### INOUT NAIVE BUFFERING #############################################################################################
	// ##### INOUT NAIVE BUFFERING #############################################################################################
	wire start_training_signal;
	wire start_inference_signal;
	reg start_ready;
	
	reg inferenced_label;

	// `ifdef SNN_BUFFERING_ON
	// 	reg start_training_signal_buffering [0:INOUT_BUFFERING_NUM-1];
	// 	reg start_inference_signal_buffering [0:INOUT_BUFFERING_NUM-1];
	// 	reg start_ready_buffering [0:INOUT_BUFFERING_NUM-1];

	// 	reg inferenced_label_buffering [0:INOUT_BUFFERING_NUM-1];

	// 	assign start_training_signal = start_training_signal_buffering[INOUT_BUFFERING_NUM-1];
	// 	assign start_inference_signal = start_inference_signal_buffering[INOUT_BUFFERING_NUM-1];
	// 	assign start_ready_o = start_ready_buffering[INOUT_BUFFERING_NUM-1];

	// 	assign inferenced_label_o = inferenced_label_buffering[INOUT_BUFFERING_NUM-1];

	// 	always @(posedge clk or negedge reset_n) begin
	// 		if (!reset_n) begin
	// 			start_training_signal_buffering[0] <= 0;
	// 			start_inference_signal_buffering[0] <= 0;
	// 			start_ready_buffering[0] <= 0;

	// 			inferenced_label_buffering[0] <= 0;
	// 		end else begin

	// 			start_training_signal_buffering[0] <= start_training_signal_i;
	// 			start_inference_signal_buffering[0] <= start_inference_signal_i;
	// 			start_ready_buffering[0] <= start_ready;

	// 			inferenced_label_buffering[0] <= inferenced_label;
	// 		end
	// 	end
	// 	genvar gen_idx_buf;
	// 	generate
	// 		for (gen_idx_buf = 0 + 1; gen_idx_buf < INOUT_BUFFERING_NUM; gen_idx_buf = gen_idx_buf + 1) begin : gen_buf
	// 			always @(posedge clk or negedge reset_n) begin
	// 				if (!reset_n) begin
	// 					start_training_signal_buffering[gen_idx_buf] <= 0;
	// 					start_inference_signal_buffering[gen_idx_buf] <= 0;
	// 					start_ready_buffering[gen_idx_buf] <= 0;

	// 					inferenced_label_buffering[gen_idx_buf] <= 0;
	// 				end else begin
	// 					start_training_signal_buffering[gen_idx_buf] <= start_training_signal_buffering[gen_idx_buf-1];
	// 					start_inference_signal_buffering[gen_idx_buf] <= start_inference_signal_buffering[gen_idx_buf-1];
	// 					start_ready_buffering[gen_idx_buf] <= start_ready_buffering[gen_idx_buf-1];

	// 					inferenced_label_buffering[gen_idx_buf] <= inferenced_label_buffering[gen_idx_buf-1];
	// 				end
	// 			end
	// 		end
	// 	endgenerate
	// `else
	// 	assign start_training_signal = start_training_signal_i;
	// 	assign start_inference_signal = start_inference_signal_i;
	// 	assign start_ready_o = start_ready;

	// 	assign inferenced_label_o = inferenced_label;
	// `endif

	assign start_training_signal = start_training_signal_i;
	assign start_inference_signal = start_inference_signal_i;
	assign start_ready_o = start_ready;

	assign inferenced_label_o = inferenced_label;
	// ##### INOUT NAIVE BUFFERING #############################################################################################
	// ##### INOUT NAIVE BUFFERING #############################################################################################
	// ##### INOUT NAIVE BUFFERING #############################################################################################










	// ##### INOUT FIFO BUFFERING FOR STREAMING INPUT #############################################################################################
	// ##### INOUT FIFO BUFFERING FOR STREAMING INPUT #############################################################################################
	// ##### INOUT FIFO BUFFERING FOR STREAMING INPUT #############################################################################################
	wire [BIT_WIDTH_INPUT_STREAMING_DATA-1:0] input_streaming_data; 
	wire input_streaming_valid;
	reg input_streaming_ready;

	wire input_streaming_fifo_wren;
	wire input_streaming_fifo_rden;
	wire [BIT_WIDTH_INPUT_STREAMING_DATA-1:0] input_streaming_fifo_wdata;
	wire [BIT_WIDTH_INPUT_STREAMING_DATA-1:0] input_streaming_fifo_rdata;
	wire input_streaming_fifo_almost_full;
	wire input_streaming_fifo_empty;


	fifo_bh_almost_full#(
		.FIFO_DATA_WIDTH ( BIT_WIDTH_INPUT_STREAMING_DATA ),
		.FIFO_DEPTH      ( 14 ),
		.FIFO_DEPTH_LG2  ( $clog2(14) ),
		.FIFO_MINIMUM_SPACE_TO_READ_REQUEST ( 7 )
	)u_fifo_for_streaming(
		.clk             ( clk             ),
		.reset_n         ( reset_n         ),
		.wren_i          ( input_streaming_fifo_wren          ),
		.rden_i          ( input_streaming_fifo_rden          ),
		.wdata_i         ( input_streaming_fifo_wdata         ),
		.rdata_o         ( input_streaming_fifo_rdata         ),
		.almost_full_o   ( input_streaming_fifo_almost_full   ),
		.empty_o         ( input_streaming_fifo_empty         )
	);

	assign input_streaming_data = input_streaming_fifo_rdata;
	assign input_streaming_valid = !input_streaming_fifo_empty;
	assign input_streaming_fifo_rden = input_streaming_ready && input_streaming_valid;

	// `ifdef SNN_BUFFERING_ON
	// 	reg [BIT_WIDTH_INPUT_STREAMING_DATA-1:0] input_streaming_data_buffering [0:INOUT_BUFFERING_NUM-1]; 
	// 	reg input_streaming_valid_buffering [0:INOUT_BUFFERING_NUM-1];
	// 	reg input_streaming_read_buffering [0:INOUT_BUFFERING_NUM-1];

	// 	always @(posedge clk or negedge reset_n) begin
	// 		if (!reset_n) begin
	// 			input_streaming_data_buffering[0] <= 0;
	// 			input_streaming_valid_buffering[0] <= 0;
	// 			input_streaming_read_buffering[0] <= 0;
	// 		end else begin
	// 			input_streaming_data_buffering[0] <= input_streaming_data_i;
	// 			input_streaming_valid_buffering[0] <= input_streaming_valid_i;
	// 			input_streaming_read_buffering[0] <= !input_streaming_fifo_almost_full;
	// 		end
	// 	end
	// 	genvar gen_idx_buf_streaming;
	// 	generate
	// 		for (gen_idx_buf_streaming = 0 + 1; gen_idx_buf_streaming < INOUT_BUFFERING_NUM; gen_idx_buf_streaming = gen_idx_buf_streaming + 1) begin : gen_buf_streaming
	// 			always @(posedge clk or negedge reset_n) begin
	// 				if (!reset_n) begin
	// 					input_streaming_data_buffering[gen_idx_buf_streaming] <= 0;
	// 					input_streaming_valid_buffering[gen_idx_buf_streaming] <= 0;
	// 					input_streaming_read_buffering[gen_idx_buf_streaming] <= 0;
	// 				end else begin
	// 					input_streaming_data_buffering[gen_idx_buf_streaming] <= input_streaming_data_buffering[gen_idx_buf_streaming-1];
	// 					input_streaming_valid_buffering[gen_idx_buf_streaming] <= input_streaming_valid_buffering[gen_idx_buf_streaming-1];
	// 					input_streaming_read_buffering[gen_idx_buf_streaming] <= input_streaming_read_buffering[gen_idx_buf_streaming-1];
	// 				end
	// 			end
	// 		end
	// 	endgenerate
	// 	assign input_streaming_fifo_wdata = input_streaming_data_buffering[INOUT_BUFFERING_NUM-1];
	// 	assign input_streaming_fifo_wren = input_streaming_valid_buffering[INOUT_BUFFERING_NUM-1];
	// 	assign input_streaming_ready_o = input_streaming_read_buffering[INOUT_BUFFERING_NUM-1];
	// `else
	// 	// assign input_streaming_data = input_streaming_data_i;
	// 	// assign input_streaming_valid = input_streaming_valid_i;
	// 	// assign input_streaming_ready_o = input_streaming_ready;

	// 	assign input_streaming_fifo_wdata = input_streaming_data_i;
	// 	assign input_streaming_fifo_wren = input_streaming_valid_i;
	// 	assign input_streaming_ready_o = !input_streaming_fifo_almost_full;
	// `endif

	assign input_streaming_fifo_wdata = input_streaming_data_i;
	assign input_streaming_fifo_wren = input_streaming_valid_i;
	assign input_streaming_ready_o = !input_streaming_fifo_almost_full;
	// ##### INOUT FIFO BUFFERING FOR STREAMING INPUT #############################################################################################
	// ##### INOUT FIFO BUFFERING FOR STREAMING INPUT #############################################################################################
	// ##### INOUT FIFO BUFFERING FOR STREAMING INPUT #############################################################################################















	// ##### INPUT SPIKE FIFO 986bit #############################################################################################
	// ##### INPUT SPIKE FIFO 986bit #############################################################################################
	// ##### INPUT SPIKE FIFO 986bit #############################################################################################
	// ##### INPUT SPIKE FIFO 986bit #############################################################################################
	reg input_spike_fifo_wren, input_spike_fifo_wren_oneclk_fast;
	reg input_spike_fifo_rden;
	reg [INPUT_SPIKE_FIFO_DATA_WIDTH-1:0] input_spike_fifo_wdata;

	wire [INPUT_SPIKE_FIFO_DATA_WIDTH-1:0] input_spike_fifo_rdata;
	wire input_spike_fifo_full;
	wire input_spike_fifo_empty;

	// fifo_bh#(
	// 	.FIFO_DATA_WIDTH ( INPUT_SPIKE_FIFO_DATA_WIDTH ),
	// 	.FIFO_DEPTH      ( 2 ),
	// 	.FIFO_DEPTH_LG2  ( $clog2(2) )
	// )u_fifo_input_spike_fifo(
	// 	.clk             ( clk             ),
	// 	.reset_n         ( reset_n         ),
	// 	.wren_i          ( input_spike_fifo_wren          ),
	// 	.rden_i          ( input_spike_fifo_rden          ),
	// 	.wdata_i         ( input_spike_fifo_wdata         ),
	// 	.rdata_o         ( input_spike_fifo_rdata         ),
	// 	.full_o          ( input_spike_fifo_full          ),
	// 	.empty_o         ( input_spike_fifo_empty         )
	// );
	fifo_bh_one_depth#(
		.FIFO_DATA_WIDTH ( INPUT_SPIKE_FIFO_DATA_WIDTH )
	)u_fifo_bh_one_depth(
		.clk     ( clk     ),
		.reset_n ( reset_n ),
		.wren_i  ( input_spike_fifo_wren  ),
		.rden_i  ( input_spike_fifo_rden  ),
		.wdata_i ( input_spike_fifo_wdata ),
		.rdata_o ( input_spike_fifo_rdata ),
		.full_o  ( input_spike_fifo_full  ),
		.empty_o  ( input_spike_fifo_empty  )
	);
	// ##### INPUT SPIKE FIFO 986bit #############################################################################################
	// ##### INPUT SPIKE FIFO 986bit #############################################################################################
	// ##### INPUT SPIKE FIFO 986bit #############################################################################################
	// ##### INPUT SPIKE FIFO 986bit #############################################################################################




	// ##### LABEL FIFO #############################################################################################
	// ##### LABEL FIFO #############################################################################################
	// ##### LABEL FIFO #############################################################################################
	reg label_fifo_wren;
	reg label_fifo_rden;
	reg [3:0] label_fifo_wdata;

	wire [3:0] label_fifo_rdata;
	wire label_fifo_full;
	wire label_fifo_empty;
	fifo_bh#(
		.FIFO_DATA_WIDTH ( 4 ),
		.FIFO_DEPTH      ( 8 ),
		.FIFO_DEPTH_LG2  ( $clog2(8) )
	)u_fifo_label(
		.clk             ( clk             ),
		.reset_n         ( reset_n         ),
		.wren_i          ( label_fifo_wren          ),
		.rden_i          ( label_fifo_rden          ),
		.wdata_i         ( label_fifo_wdata         ),
		.rdata_o         ( label_fifo_rdata         ),
		.full_o          ( label_fifo_full          ),
		.empty_o         ( label_fifo_empty         )
	);
	// ##### LABEL FIFO #############################################################################################
	// ##### LABEL FIFO #############################################################################################
	// ##### LABEL FIFO #############################################################################################




	// ##### LAYER2 FINISH FLAG FIFO #############################################################################################
	// ##### LAYER2 FINISH FLAG FIFO #############################################################################################
	// ##### LAYER2 FINISH FLAG FIFO #############################################################################################
	reg layer2_finish_flag_fifo_wren;
	reg layer2_finish_flag_fifo_rden;
	reg [1:0] layer2_finish_flag_fifo_wdata;

	wire [1:0] layer2_finish_flag_fifo_rdata;
	wire layer2_finish_flag_fifo_full;
	wire layer2_finish_flag_fifo_empty;
	fifo_bh#(
		.FIFO_DATA_WIDTH ( 2 ),
		.FIFO_DEPTH      ( 8 ),
		.FIFO_DEPTH_LG2  ( $clog2(8) )
	)u_fifo_finish_flag_layer2_fifo(
		.clk             ( clk             ),
		.reset_n         ( reset_n         ),
		.wren_i          ( layer2_finish_flag_fifo_wren          ),
		.rden_i          ( layer2_finish_flag_fifo_rden          ),
		.wdata_i         ( layer2_finish_flag_fifo_wdata         ),
		.rdata_o         ( layer2_finish_flag_fifo_rdata         ),
		.full_o          ( layer2_finish_flag_fifo_full          ),
		.empty_o         ( layer2_finish_flag_fifo_empty         )
	);
	// ##### LAYER2 FINISH FLAG FIFO #############################################################################################
	// ##### LAYER2 FINISH FLAG FIFO #############################################################################################
	// ##### LAYER2 FINISH FLAG FIFO #############################################################################################






	// ##### LAYER3 FINISH FLAG FIFO #############################################################################################
	// ##### LAYER3 FINISH FLAG FIFO #############################################################################################
	// ##### LAYER3 FINISH FLAG FIFO #############################################################################################
	reg layer3_finish_flag_fifo_wren;
	reg layer3_finish_flag_fifo_rden;
	reg [1:0] layer3_finish_flag_fifo_wdata;

	wire [1:0] layer3_finish_flag_fifo_rdata;
	wire layer3_finish_flag_fifo_full;
	wire layer3_finish_flag_fifo_empty;
	fifo_bh#(
		.FIFO_DATA_WIDTH ( 2 ),
		.FIFO_DEPTH      ( 8 ),
		.FIFO_DEPTH_LG2  ( $clog2(8) )
	)u_fifo_finish_flag_layer3_fifo(
		.clk             ( clk             ),
		.reset_n         ( reset_n         ),
		.wren_i          ( layer3_finish_flag_fifo_wren          ),
		.rden_i          ( layer3_finish_flag_fifo_rden          ),
		.wdata_i         ( layer3_finish_flag_fifo_wdata         ),
		.rdata_o         ( layer3_finish_flag_fifo_rdata         ),
		.full_o          ( layer3_finish_flag_fifo_full          ),
		.empty_o         ( layer3_finish_flag_fifo_empty         )
	);
	// ##### LAYER3 FINISH FLAG FIFO #############################################################################################
	// ##### LAYER3 FINISH FLAG FIFO #############################################################################################
	// ##### LAYER3 FINISH FLAG FIFO #############################################################################################






	// ##### CONNECTION BETWEEN LAYER PORTS #############################################################################################
	// ##### CONNECTION BETWEEN LAYER PORTS #############################################################################################
	// ##### CONNECTION BETWEEN LAYER PORTS #############################################################################################
	reg n_layer1_port_config_valid;
	reg layer1_port_config_valid_copy, n_layer1_port_config_valid_copy;
	reg [LAYER1_BIT_WIDTH_SRAM-1:0] layer1_config_value, n_layer1_config_value;

	reg n_layer2_port_config_valid;
	reg layer2_port_config_valid_copy, n_layer2_port_config_valid_copy;
	reg [LAYER2_BIT_WIDTH_SRAM-1:0] layer2_config_value, n_layer2_config_value;
	
	reg n_layer3_port_config_valid;
	reg layer3_port_config_valid_copy, n_layer3_port_config_valid_copy;
	reg [LAYER3_BIT_WIDTH_SRAM-1:0] layer3_config_value, n_layer3_config_value;
	always @ (*) begin
		input_spike_fifo_rden = 0;
		layer1_port_input_setting_done = 0;
		layer1_port_input_spike = input_spike_fifo_rdata[0 +: LAYER1_INPUT_SIZE];
		layer1_port_this_sample_done = input_spike_fifo_rdata[LAYER1_INPUT_SIZE];
		layer1_port_this_epoch_finish = input_spike_fifo_rdata[LAYER1_INPUT_SIZE+1];

		layer2_finish_flag_fifo_wdata[0] = input_spike_fifo_rdata[LAYER1_INPUT_SIZE];
		layer3_finish_flag_fifo_wdata[0] = input_spike_fifo_rdata[LAYER1_INPUT_SIZE];
		layer2_finish_flag_fifo_wdata[1] = input_spike_fifo_rdata[LAYER1_INPUT_SIZE+1];
		layer3_finish_flag_fifo_wdata[1] = input_spike_fifo_rdata[LAYER1_INPUT_SIZE+1];
		label_fifo_wdata = input_spike_fifo_rdata[LAYER1_INPUT_SIZE+2 +: 4];
		layer2_finish_flag_fifo_wren = 0;
		layer3_finish_flag_fifo_wren = 0;
		label_fifo_wren = 0;
		
		if (fsm_state == STATE_PROCESSING_TRAINING) begin
			if (input_spike_fifo_empty == 0 && layer2_finish_flag_fifo_full == 0 && layer3_finish_flag_fifo_full == 0 && label_fifo_full == 0) begin
				layer1_port_input_setting_done = 1;
				if (layer1_port_input_setting_catch_ready) begin
					input_spike_fifo_rden = 1;
					layer2_finish_flag_fifo_wren = 1;
					layer3_finish_flag_fifo_wren = 1;
					label_fifo_wren = 1;
				end
			end
		end else begin
			if (input_spike_fifo_empty == 0 && layer2_finish_flag_fifo_full == 0 && layer3_finish_flag_fifo_full == 0) begin
				layer1_port_input_setting_done = 1;
				if (layer1_port_input_setting_catch_ready) begin
					input_spike_fifo_rden = 1;
					layer2_finish_flag_fifo_wren = 1;
					layer3_finish_flag_fifo_wren = 1;
				end
			end
		end

		if (layer1_port_config_valid) begin
			layer1_port_input_spike = {{(LAYER1_INPUT_SIZE-LAYER1_BIT_WIDTH_SRAM){1'b0}}, layer1_config_value};
		end 
	end
	// ##### CONNECTION BETWEEN LAYER PORTS #############################################################################################
	// ##### CONNECTION BETWEEN LAYER PORTS #############################################################################################
	// ##### CONNECTION BETWEEN LAYER PORTS #############################################################################################







	// ##### LAYER2 INPUT SPIKE FIFO #############################################################################################
	// ##### LAYER2 INPUT SPIKE FIFO #############################################################################################
	// ##### LAYER2 INPUT SPIKE FIFO #############################################################################################
	reg layer2_input_spike_fifo_wren;
	reg layer2_input_spike_fifo_rden;
	wire [LAYER2_INPUT_SIZE-1:0] layer2_input_spike_fifo_wdata;

	wire [LAYER2_INPUT_SIZE-1:0] layer2_input_spike_fifo_rdata;
	wire layer2_input_spike_fifo_full;
	wire layer2_input_spike_fifo_empty;
	fifo_bh#(
		.FIFO_DATA_WIDTH ( LAYER2_INPUT_SIZE ),
		.FIFO_DEPTH      ( 2 ),
		.FIFO_DEPTH_LG2  ( $clog2(2) )
	)u_fifo_layer2_input_spike_fifo(
		.clk             ( clk             ),
		.reset_n         ( reset_n         ),
		.wren_i          ( layer2_input_spike_fifo_wren          ),
		.rden_i          ( layer2_input_spike_fifo_rden          ),
		.wdata_i         ( layer2_input_spike_fifo_wdata         ),
		.rdata_o         ( layer2_input_spike_fifo_rdata         ),
		.full_o          ( layer2_input_spike_fifo_full          ),
		.empty_o         ( layer2_input_spike_fifo_empty         )
	);

	assign layer2_input_spike_fifo_wdata = layer1_port_post_spike;
	always @ (*) begin
		layer2_port_input_spike = layer2_input_spike_fifo_rdata;
		if (layer2_port_config_valid) begin
			layer2_port_input_spike = {{(LAYER2_INPUT_SIZE-LAYER2_BIT_WIDTH_SRAM){1'b0}}, layer2_config_value};
		end 

		layer2_port_input_setting_done = 0;
		layer2_input_spike_fifo_rden = 0;
		layer2_finish_flag_fifo_rden = 0;
		layer2_port_this_sample_done = layer2_finish_flag_fifo_rdata[0];
		layer2_port_this_epoch_finish = layer2_finish_flag_fifo_rdata[1];
		if (layer2_input_spike_fifo_empty == 0 && layer2_finish_flag_fifo_empty == 0) begin
			layer2_port_input_setting_done = 1;
			if (layer2_port_input_setting_catch_ready) begin
				layer2_input_spike_fifo_rden = 1;
				layer2_finish_flag_fifo_rden = 1;
			end
		end

		layer1_port_post_spike_catch_done = 0;
		layer2_input_spike_fifo_wren = 0;
		if (layer2_input_spike_fifo_full == 0) begin
			layer1_port_post_spike_catch_done = 1;
			if (layer1_port_post_spike_valid) begin
				layer2_input_spike_fifo_wren = 1;
			end
		end
	end
	// ##### LAYER2 INPUT SPIKE FIFO #############################################################################################
	// ##### LAYER2 INPUT SPIKE FIFO #############################################################################################
	// ##### LAYER2 INPUT SPIKE FIFO #############################################################################################







	// ##### LAYER3 INPUT SPIKE FIFO #############################################################################################
	// ##### LAYER3 INPUT SPIKE FIFO #############################################################################################
	// ##### LAYER3 INPUT SPIKE FIFO #############################################################################################
	reg layer3_input_spike_fifo_wren;
	reg layer3_input_spike_fifo_rden;
	wire [LAYER3_INPUT_SIZE-1:0] layer3_input_spike_fifo_wdata;

	wire [LAYER3_INPUT_SIZE-1:0] layer3_input_spike_fifo_rdata;
	wire layer3_input_spike_fifo_full;
	wire layer3_input_spike_fifo_empty;
	fifo_bh#(
		.FIFO_DATA_WIDTH ( LAYER3_INPUT_SIZE ),
		.FIFO_DEPTH      ( 2 ),
		.FIFO_DEPTH_LG2  ( $clog2(2) )
	)u_fifo_layer3_input_spike_fifo(
		.clk             ( clk             ),
		.reset_n         ( reset_n         ),
		.wren_i          ( layer3_input_spike_fifo_wren          ),
		.rden_i          ( layer3_input_spike_fifo_rden          ),
		.wdata_i         ( layer3_input_spike_fifo_wdata         ),
		.rdata_o         ( layer3_input_spike_fifo_rdata         ),
		.full_o          ( layer3_input_spike_fifo_full          ),
		.empty_o         ( layer3_input_spike_fifo_empty         )
	);

	assign layer3_input_spike_fifo_wdata = layer2_port_post_spike;
	always @ (*) begin
		layer3_port_input_spike = layer3_input_spike_fifo_rdata;
		if (layer3_port_config_valid) begin
			layer3_port_input_spike = {{(LAYER3_INPUT_SIZE-LAYER3_BIT_WIDTH_SRAM){1'b0}}, layer3_config_value};
		end 

		layer3_port_input_setting_done = 0;
		layer3_input_spike_fifo_rden = 0;
		layer3_finish_flag_fifo_rden = 0;
		layer3_port_this_sample_done = layer3_finish_flag_fifo_rdata[0];
		layer3_port_this_epoch_finish = layer3_finish_flag_fifo_rdata[1];

		label_fifo_rden = 0;
		layer3_port_this_sample_label = label_fifo_rdata;
		if (fsm_state == STATE_PROCESSING_TRAINING) begin
			if (layer3_input_spike_fifo_empty == 0 && layer3_finish_flag_fifo_empty == 0 && label_fifo_empty == 0) begin
				layer3_port_input_setting_done = 1;
				if (layer3_port_input_setting_catch_ready) begin
					layer3_input_spike_fifo_rden = 1;
					layer3_finish_flag_fifo_rden = 1;
					label_fifo_rden = 1;
				end
			end
		end else begin
			if (layer3_input_spike_fifo_empty == 0 && layer3_finish_flag_fifo_empty == 0) begin
				layer3_port_input_setting_done = 1;
				if (layer3_port_input_setting_catch_ready) begin
					layer3_input_spike_fifo_rden = 1;
					layer3_finish_flag_fifo_rden = 1;
				end
			end
		end

		layer2_port_post_spike_catch_done = 0;
		layer3_input_spike_fifo_wren = 0;
		if (layer3_input_spike_fifo_full == 0) begin
			layer2_port_post_spike_catch_done = 1;
			if (layer2_port_post_spike_valid) begin
				layer3_input_spike_fifo_wren = 1;
			end
		end
	end
	// ##### LAYER3 INPUT SPIKE FIFO #############################################################################################
	// ##### LAYER3 INPUT SPIKE FIFO #############################################################################################
	// ##### LAYER3 INPUT SPIKE FIFO #############################################################################################









	// ### ERROR VALUE SCHEDULING #############################################################################################
	// ### ERROR VALUE SCHEDULING #############################################################################################
	// ### ERROR VALUE SCHEDULING #############################################################################################
	// LAYER1 ERROR VALUE FIFO
	reg [1:0] layer1_error_stay_counter, n_layer1_error_stay_counter;
	reg layer1_error_fifo_wren;
	reg layer1_error_fifo_rden;
	wire [8:0] layer1_error_fifo_wdata;

	wire [8:0] layer1_error_fifo_rdata;
	wire layer1_error_fifo_full;
	wire layer1_error_fifo_empty;
	fifo_bh#(
		.FIFO_DATA_WIDTH ( 9 ),
		.FIFO_DEPTH      ( 4 ),
		.FIFO_DEPTH_LG2  ( $clog2(4) )
	)u_fifo_error_layer1(
		.clk             ( clk             ),
		.reset_n         ( reset_n         ),
		.wren_i          ( layer1_error_fifo_wren          ),
		.rden_i          ( layer1_error_fifo_rden          ),
		.wdata_i         ( layer1_error_fifo_wdata         ),
		.rdata_o         ( layer1_error_fifo_rdata         ),
		.full_o          ( layer1_error_fifo_full          ),
		.empty_o         ( layer1_error_fifo_empty         )
	);

	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			layer1_error_stay_counter <= 0;
		end else begin
			layer1_error_stay_counter <= n_layer1_error_stay_counter;
		end
	end

	always @ (*) begin
		layer1_port_error_setting_done = 0;
		n_layer1_error_stay_counter = layer1_error_stay_counter;
		layer1_port_weight_update_skip = layer1_error_fifo_rdata[0];
		layer1_port_error_class_first = layer1_error_fifo_rdata[1 +: 4];
		layer1_port_error_class_second = layer1_error_fifo_rdata[5 +: 4];
		layer1_error_fifo_rden = 0;
		if (layer1_error_stay_counter != 2) begin
			layer1_port_error_setting_done = 1;
			layer1_port_weight_update_skip = 1;
			if (layer1_port_error_setting_catch_ready) begin
				n_layer1_error_stay_counter = layer1_error_stay_counter + 1;
			end
		end else begin
			if (layer1_error_fifo_empty == 0) begin
				layer1_port_error_setting_done = 1;
				if (layer1_port_error_setting_catch_ready) begin
					layer1_error_fifo_rden = 1;
				end
			end
		end
	end

	// LAYER2 ERROR VALUE FIFO
	reg [1:0] layer2_error_stay_counter, n_layer2_error_stay_counter;
	reg layer2_error_fifo_wren;
	reg layer2_error_fifo_rden;
	wire [8:0] layer2_error_fifo_wdata;

	wire [8:0] layer2_error_fifo_rdata;
	wire layer2_error_fifo_full;
	wire layer2_error_fifo_empty;
	fifo_bh#(
		.FIFO_DATA_WIDTH ( 9 ),
		.FIFO_DEPTH      ( 4 ),
		.FIFO_DEPTH_LG2  ( $clog2(4) )
	)u_fifo_error_layer2(
		.clk             ( clk             ),
		.reset_n         ( reset_n         ),
		.wren_i          ( layer2_error_fifo_wren          ),
		.rden_i          ( layer2_error_fifo_rden          ),
		.wdata_i         ( layer2_error_fifo_wdata         ),
		.rdata_o         ( layer2_error_fifo_rdata         ),
		.full_o          ( layer2_error_fifo_full          ),
		.empty_o         ( layer2_error_fifo_empty         )
	);

	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			layer2_error_stay_counter <= 0;
		end else begin
			layer2_error_stay_counter <= n_layer2_error_stay_counter;
		end
	end

	always @ (*) begin
		layer2_port_error_setting_done = 0;
		n_layer2_error_stay_counter = layer2_error_stay_counter;
		layer2_port_weight_update_skip = layer2_error_fifo_rdata[0];
		layer2_port_error_class_first = layer2_error_fifo_rdata[1 +: 4];
		layer2_port_error_class_second = layer2_error_fifo_rdata[5 +: 4];
		layer2_error_fifo_rden = 0;
		if (layer2_error_stay_counter != 1) begin
			layer2_port_error_setting_done = 1;
			layer2_port_weight_update_skip = 1;
			if (layer2_port_error_setting_catch_ready) begin
				n_layer2_error_stay_counter = layer2_error_stay_counter + 1;
			end
		end else begin
			if (layer2_error_fifo_empty == 0) begin
				layer2_port_error_setting_done = 1;
				if (layer2_port_error_setting_catch_ready) begin
					layer2_error_fifo_rden = 1;
				end
			end
		end
	end
 
	assign layer1_error_fifo_wdata = {layer3_port_error_class_second, layer3_port_error_class_first, layer3_port_weight_update_skip};
	assign layer2_error_fifo_wdata = {layer3_port_error_class_second, layer3_port_error_class_first, layer3_port_weight_update_skip};
	always @ (*) begin
		layer3_port_error_class_catch_done = 0; 
		layer1_error_fifo_wren = 0;
		layer2_error_fifo_wren = 0;
		if ((layer1_error_fifo_full == 0) && (layer2_error_fifo_full == 0)) begin
			if (layer3_port_error_class_valid) begin
				layer3_port_error_class_catch_done = 1; 
				layer1_error_fifo_wren = 1;
				layer2_error_fifo_wren = 1;
			end
		end
	end
	// ### ERROR VALUE SCHEDULING #############################################################################################
	// ### ERROR VALUE SCHEDULING #############################################################################################
	// ### ERROR VALUE SCHEDULING #############################################################################################




	// ### INFERENCED LABEL #############################################################################################
	// ### INFERENCED LABEL #############################################################################################
	// ### INFERENCED LABEL #############################################################################################

	reg [1:0] inferenced_label_shooting_cnt, n_inferenced_label_shooting_cnt;
	reg inferenced_label_shooting_ongoing, n_inferenced_label_shooting_ongoing;

	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			inferenced_label_shooting_cnt <= 0;
			inferenced_label_shooting_ongoing <= 0;
		end else begin
			inferenced_label_shooting_cnt <= n_inferenced_label_shooting_cnt;
			inferenced_label_shooting_ongoing <= n_inferenced_label_shooting_ongoing;
		end
	end

	always @ (*) begin
		n_inferenced_label_shooting_cnt = inferenced_label_shooting_cnt;
		n_inferenced_label_shooting_ongoing = inferenced_label_shooting_ongoing;
		inferenced_label = 0;
		layer3_port_inferenced_class_catch_done = 0;

		if (inferenced_label_shooting_ongoing == 0) begin
			if (layer3_port_inferenced_class_valid) begin
				inferenced_label = 1;
				n_inferenced_label_shooting_ongoing = 1;
			end
		end else begin
			inferenced_label = layer3_port_inferenced_class[inferenced_label_shooting_cnt];
			if (inferenced_label_shooting_cnt != 3) begin
				n_inferenced_label_shooting_cnt = inferenced_label_shooting_cnt + 1;
			end else begin
				n_inferenced_label_shooting_cnt = 0;
				n_inferenced_label_shooting_ongoing = 0;
				layer3_port_inferenced_class_catch_done = 1;
			end
		end
	end
	// ### INFERENCED LABEL #############################################################################################
	// ### INFERENCED LABEL #############################################################################################
	// ### INFERENCED LABEL #############################################################################################







	wire layers_all_start_ready;

	reg config_ongoing, n_config_ongoing;

	reg [BIT_WIDTH_CONFIG_COUNTER_MAIN-1:0] config_counter_main, n_config_counter_main;
	reg [1:0] config_counter_one_two_three, n_config_counter_one_two_three;
	reg [BIT_WIDTH_INPUT_STREAMING_DATA*3-1:0] config_value_collector, n_config_value_collector;
	reg config_collect_done_main, n_config_collect_done_main;
	reg config_collect_done_layer1, n_config_collect_done_layer1;
	reg config_collect_done_layer2, n_config_collect_done_layer2;
	reg config_collect_done_layer3, n_config_collect_done_layer3;
	reg main_config_now, n_main_config_now;
	reg layer1_config_now, n_layer1_config_now;
	reg layer2_config_now, n_layer2_config_now;
	reg layer3_config_now, n_layer3_config_now;

	
	reg start_training_signal_oneclk_delay;
	reg start_training_signal_twoclk_delay;
	reg start_training_signal_threeclk_delay;
	
	reg start_inference_signal_oneclk_delay;
	reg start_inference_signal_twoclk_delay;
	reg start_inference_signal_threeclk_delay;

	reg input_spike_collector_update_now;
	reg [3:0] input_spike_collector_counter, n_input_spike_collector_counter;

	reg [BIT_WIDTH_INPUT_STREAMING_DATA-1:0] input_spike_collector [0:CLOCK_INPUT_SPIKE_COLLECT_LONG-1];
	reg [BIT_WIDTH_INPUT_STREAMING_DATA-1:0] n_input_spike_collector [0:CLOCK_INPUT_SPIKE_COLLECT_LONG-1];
	wire [BIT_WIDTH_INPUT_STREAMING_DATA*CLOCK_INPUT_SPIKE_COLLECT_LONG-1:0] input_spike_collector_vector;



	// // ### INPUT SPIKE COLLECTOR (ROUTING METHOD) #############################################################################################
	// // ### INPUT SPIKE COLLECTOR (ROUTING METHOD) #############################################################################################
	// // ### INPUT SPIKE COLLECTOR (ROUTING METHOD) #############################################################################################
	// genvar gen_idx0;
	// generate
	// 	for (gen_idx0 = 0; gen_idx0 < CLOCK_INPUT_SPIKE_COLLECT_LONG; gen_idx0 = gen_idx0 + 1) begin : gen_input_spike_collector
	// 		always @(posedge clk or negedge reset_n) begin
	// 			if (!reset_n) begin
	// 				input_spike_collector[gen_idx0] <= 0;
	// 			end else begin
	// 				input_spike_collector[gen_idx0] <= n_input_spike_collector[gen_idx0];
	// 			end
	// 		end
	// 		always @ (*) begin 
	// 			n_input_spike_collector[gen_idx0] = input_spike_collector[gen_idx0];
	// 			if (input_spike_collector_update_now) begin
	// 				if (gen_idx0 == input_spike_collector_counter) begin
	// 					n_input_spike_collector[gen_idx0] = input_streaming_data;
	// 				end
	// 			end
	// 		end
	// 		assign input_spike_collector_vector[gen_idx0*BIT_WIDTH_INPUT_STREAMING_DATA +: BIT_WIDTH_INPUT_STREAMING_DATA] = input_spike_collector[gen_idx0];
	// 	end
	// endgenerate

	// reg long_time_input_streaming_mode, n_long_time_input_streaming_mode;
	// always @ (*) begin
	// 	input_spike_fifo_wdata = input_spike_collector_vector[INPUT_SPIKE_FIFO_DATA_WIDTH-1:0];
	// 	if (long_time_input_streaming_mode == 0) begin
	// 		input_spike_fifo_wdata = {input_spike_collector_vector[578 +: 6],{(INPUT_SPIKE_FIFO_DATA_WIDTH - 6 - 578){1'b0}} ,input_spike_collector_vector[577:0]};
	// 	end
	// end
	// // ### INPUT SPIKE COLLECTOR (ROUTING METHOD) #############################################################################################
	// // ### INPUT SPIKE COLLECTOR (ROUTING METHOD) #############################################################################################
	// // ### INPUT SPIKE COLLECTOR (ROUTING METHOD) #############################################################################################

	// ### INPUT SPIKE COLLECTOR (SHIFT REGISTER METHOD) #############################################################################################
	// ### INPUT SPIKE COLLECTOR (SHIFT REGISTER METHOD) #############################################################################################
	// ### INPUT SPIKE COLLECTOR (SHIFT REGISTER METHOD) #############################################################################################
	reg long_time_input_streaming_mode, n_long_time_input_streaming_mode;

	genvar gen_idx0;
	generate
		for (gen_idx0 = 0; gen_idx0 < CLOCK_INPUT_SPIKE_COLLECT_LONG; gen_idx0 = gen_idx0 + 1) begin : gen_input_spike_collector
			always @(posedge clk or negedge reset_n) begin
				if (!reset_n) begin
					input_spike_collector[gen_idx0] <= 0;
				end else begin
					input_spike_collector[gen_idx0] <= n_input_spike_collector[gen_idx0];
				end
			end
			assign input_spike_collector_vector[gen_idx0*BIT_WIDTH_INPUT_STREAMING_DATA +: BIT_WIDTH_INPUT_STREAMING_DATA] = input_spike_collector[gen_idx0];
		end
	endgenerate


	always @ (*) begin 
		n_input_spike_collector[CLOCK_INPUT_SPIKE_COLLECT_LONG-1] = input_spike_collector[CLOCK_INPUT_SPIKE_COLLECT_LONG-1];
		if (long_time_input_streaming_mode) begin
			if (input_spike_collector_update_now) begin
				n_input_spike_collector[CLOCK_INPUT_SPIKE_COLLECT_LONG-1] = input_streaming_data;
			end
		end
	end
	genvar gen_idx_collect;
	generate
		for (gen_idx_collect = CLOCK_INPUT_SPIKE_COLLECT_SHORT; gen_idx_collect < CLOCK_INPUT_SPIKE_COLLECT_LONG-1; gen_idx_collect = gen_idx_collect + 1) begin : gen_input_spike_collector_long
			always @ (*) begin 
				n_input_spike_collector[gen_idx_collect] = input_spike_collector[gen_idx_collect];
				if (input_spike_collector_update_now) begin
					n_input_spike_collector[gen_idx_collect] = input_spike_collector[gen_idx_collect+1];
				end
			end
		end
	endgenerate
	always @ (*) begin 
		n_input_spike_collector[CLOCK_INPUT_SPIKE_COLLECT_SHORT-1] = input_spike_collector[CLOCK_INPUT_SPIKE_COLLECT_SHORT-1];
		if (long_time_input_streaming_mode) begin
			if (input_spike_collector_update_now) begin
				n_input_spike_collector[CLOCK_INPUT_SPIKE_COLLECT_SHORT-1] = input_spike_collector[CLOCK_INPUT_SPIKE_COLLECT_SHORT];
			end
		end else begin
			if (input_spike_collector_update_now) begin
				n_input_spike_collector[CLOCK_INPUT_SPIKE_COLLECT_SHORT-1] = input_streaming_data;
			end
		end
	end
	genvar gen_idx_collect2;
	generate
		for (gen_idx_collect2 = 0; gen_idx_collect2 < CLOCK_INPUT_SPIKE_COLLECT_SHORT-1; gen_idx_collect2 = gen_idx_collect2 + 1) begin : gen_input_spike_collector_short
			always @ (*) begin 
				n_input_spike_collector[gen_idx_collect2] = input_spike_collector[gen_idx_collect2];
				if (input_spike_collector_update_now) begin
					n_input_spike_collector[gen_idx_collect2] = input_spike_collector[gen_idx_collect2+1];
				end
			end
		end
	endgenerate


	always @ (*) begin
		input_spike_fifo_wdata = input_spike_collector_vector[INPUT_SPIKE_FIFO_DATA_WIDTH-1:0];
		if (long_time_input_streaming_mode == 0) begin
			input_spike_fifo_wdata = {input_spike_collector_vector[578 +: 6],{(INPUT_SPIKE_FIFO_DATA_WIDTH - 6 - 578){1'b0}} ,input_spike_collector_vector[577:0]};
		end
	end
	// ### INPUT SPIKE COLLECTOR (SHIFT REGISTER METHOD) #############################################################################################
	// ### INPUT SPIKE COLLECTOR (SHIFT REGISTER METHOD) #############################################################################################
	// ### INPUT SPIKE COLLECTOR (SHIFT REGISTER METHOD) #############################################################################################





	// ##### MAIN FSM ################################################################################################################################################################
	// ##### MAIN FSM ################################################################################################################################################################
	// ##### MAIN FSM ################################################################################################################################################################
	// ##### MAIN FSM ################################################################################################################################################################
	// ##### MAIN FSM ################################################################################################################################################################
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			fsm_state <= STATE_CONFIG;
			config_ongoing <= 0;
			config_counter_main <= 0;
			config_counter_one_two_three <= 0;
			config_value_collector <= 0;
			config_collect_done_main <= 0;
			config_collect_done_layer1 <= 0;
			config_collect_done_layer2 <= 0;
			config_collect_done_layer3 <= 0;
			main_config_now <= 0;
			layer1_config_now <= 0;
			layer2_config_now <= 0;
			layer3_config_now <= 0;
			input_spike_collector_counter <= 0;
			input_spike_fifo_wren <= 0;
		end else begin
			fsm_state <= n_fsm_state;
			config_ongoing <= n_config_ongoing;
			config_counter_main <= n_config_counter_main;
			config_counter_one_two_three <= n_config_counter_one_two_three;
			config_value_collector <= n_config_value_collector;
			config_collect_done_main <= n_config_collect_done_main;
			config_collect_done_layer1 <= n_config_collect_done_layer1;
			config_collect_done_layer2 <= n_config_collect_done_layer2;
			config_collect_done_layer3 <= n_config_collect_done_layer3;
			main_config_now <= n_main_config_now;
			layer1_config_now <= n_layer1_config_now;
			layer2_config_now <= n_layer2_config_now;
			layer3_config_now <= n_layer3_config_now;
			input_spike_collector_counter <= n_input_spike_collector_counter;
			input_spike_fifo_wren <= input_spike_fifo_wren_oneclk_fast;
		end
	end
    always @ (*) begin 
		n_fsm_state = fsm_state;
		n_config_ongoing = config_ongoing;
		start_ready = 0;
		input_streaming_ready = 0;
		n_config_counter_main = config_counter_main;
		n_config_counter_one_two_three = config_counter_one_two_three;
		n_config_value_collector = config_value_collector;
		n_config_collect_done_main = 0;
		n_config_collect_done_layer1 = 0;
		n_config_collect_done_layer2 = 0;
		n_config_collect_done_layer3 = 0;
		n_main_config_now = main_config_now;
		n_layer1_config_now = layer1_config_now;
		n_layer2_config_now = layer2_config_now;
		n_layer3_config_now = layer3_config_now;
		input_spike_collector_update_now = 0;
		n_input_spike_collector_counter = input_spike_collector_counter;
		input_spike_fifo_wren_oneclk_fast = 0;
        case(fsm_state)
            STATE_CONFIG: begin
				if (config_ongoing == 0) begin
					start_ready = 1;
					if (input_streaming_valid && (layer1_port_do_not_config_now == 0) && (layer2_port_do_not_config_now == 0) && (layer3_port_do_not_config_now == 0)) begin
						n_config_ongoing = 1;
						n_main_config_now = 1;
						n_layer1_config_now = 0;
						n_layer2_config_now = 0;
						n_layer3_config_now = 0;
					end

					if (start_training_signal) begin
						n_fsm_state = STATE_PROCESSING_TRAINING;
					end	else if (start_inference_signal) begin
						n_fsm_state = STATE_PROCESSING_INFERENCE;
					end

				end else begin
					input_streaming_ready = 1;
					if (input_streaming_valid) begin

						if (config_counter_one_two_three != 2) begin
							n_config_counter_one_two_three = config_counter_one_two_three + 1;
						end else begin
							n_config_counter_one_two_three = 0;
							n_config_collect_done_main = main_config_now;
							n_config_collect_done_layer1 = layer1_config_now;
							n_config_collect_done_layer2 = layer2_config_now;
							n_config_collect_done_layer3 = layer3_config_now;

							if (main_config_now && config_counter_main == 0) begin
								n_config_counter_main = 0;
								n_main_config_now = 0;
								n_layer1_config_now = 1;
								n_layer2_config_now = 0;
								n_layer3_config_now = 0;
							end else if (layer1_config_now && config_counter_main == LAYER1_DEPTH_SRAM*LAYER1_SET_NUM+2) begin
								n_config_counter_main = 0;
								n_main_config_now = 0;
								n_layer1_config_now = 0;
								n_layer2_config_now = 1;
								n_layer3_config_now = 0;
							end else if (layer2_config_now && config_counter_main == LAYER2_DEPTH_SRAM*LAYER2_SET_NUM+2) begin
								n_config_counter_main = 0;
								n_main_config_now = 0;
								n_layer1_config_now = 0;
								n_layer2_config_now = 0;
								n_layer3_config_now = 1;
							end else if (layer3_config_now && config_counter_main == LAYER3_DEPTH_SRAM*LAYER3_SET_NUM) begin
								n_config_counter_main = 0;
								n_main_config_now = 0;
								n_layer1_config_now = 0;
								n_layer2_config_now = 0;
								n_layer3_config_now = 0;
							end else begin
								n_config_counter_main = config_counter_main + 1;
							end
						end

						// #####################################################################################################
						// // ROUTING METHOD
						// if (config_counter_one_two_three == 0) begin
						// 	n_config_value_collector[0*BIT_WIDTH_INPUT_STREAMING_DATA +: BIT_WIDTH_INPUT_STREAMING_DATA] = input_streaming_data;
						// end else if (config_counter_one_two_three == 1) begin
						// 	n_config_value_collector[1*BIT_WIDTH_INPUT_STREAMING_DATA +: BIT_WIDTH_INPUT_STREAMING_DATA] = input_streaming_data;
						// end else begin
						// 	n_config_value_collector[2*BIT_WIDTH_INPUT_STREAMING_DATA +: BIT_WIDTH_INPUT_STREAMING_DATA] = input_streaming_data;
						// end

						// SHIFT REGISTER METHOD
						n_config_value_collector[0*BIT_WIDTH_INPUT_STREAMING_DATA +: BIT_WIDTH_INPUT_STREAMING_DATA] = config_value_collector[1*BIT_WIDTH_INPUT_STREAMING_DATA +: BIT_WIDTH_INPUT_STREAMING_DATA];
						n_config_value_collector[1*BIT_WIDTH_INPUT_STREAMING_DATA +: BIT_WIDTH_INPUT_STREAMING_DATA] = config_value_collector[2*BIT_WIDTH_INPUT_STREAMING_DATA +: BIT_WIDTH_INPUT_STREAMING_DATA];
						n_config_value_collector[2*BIT_WIDTH_INPUT_STREAMING_DATA +: BIT_WIDTH_INPUT_STREAMING_DATA] = input_streaming_data;
						// #####################################################################################################
					end

					if (layers_all_start_ready && (main_config_now == 0) && (layer1_config_now == 0) && (layer2_config_now == 0) && (layer3_config_now == 0)) begin
						n_config_ongoing = 0;
						n_config_counter_main = 0;
						n_config_counter_one_two_three = 0;
					end
				end
			end
			STATE_PROCESSING_TRAINING: begin
				if (long_time_input_streaming_mode) begin
					if (input_spike_collector_counter != CLOCK_INPUT_SPIKE_COLLECT_LONG-1) begin
						input_streaming_ready = 1;
						if (input_streaming_valid) begin
							n_input_spike_collector_counter = input_spike_collector_counter + 1;
							input_spike_collector_update_now = 1;
						end
					end else begin
						if (input_spike_fifo_full == 0) begin
							input_streaming_ready = 1;
							if (input_streaming_valid) begin
								n_input_spike_collector_counter = 0;
								input_spike_collector_update_now = 1;
								input_spike_fifo_wren_oneclk_fast = 1;
							end
						end
					end
				end else begin
					if (input_spike_collector_counter != CLOCK_INPUT_SPIKE_COLLECT_SHORT-1) begin
						input_streaming_ready = 1;
						if (input_streaming_valid) begin
							n_input_spike_collector_counter = input_spike_collector_counter + 1;
							input_spike_collector_update_now = 1;
						end
					end else begin
						if (input_spike_fifo_full == 0) begin
							input_streaming_ready = 1;
							if (input_streaming_valid) begin
								n_input_spike_collector_counter = 0;
								input_spike_collector_update_now = 1;
								input_spike_fifo_wren_oneclk_fast = 1;
							end
						end
					end
				end


				if (layers_all_start_ready) begin
					if ((start_training_signal==0) && (start_training_signal_oneclk_delay==0) && (start_training_signal_twoclk_delay==0) && (start_training_signal_threeclk_delay==0)) begin
						n_fsm_state = STATE_CONFIG;
					end
				end
			end
			STATE_PROCESSING_INFERENCE: begin
				if (long_time_input_streaming_mode) begin
					if (input_spike_collector_counter != CLOCK_INPUT_SPIKE_COLLECT_LONG-1) begin
						input_streaming_ready = 1;
						if (input_streaming_valid) begin
							n_input_spike_collector_counter = input_spike_collector_counter + 1;
							input_spike_collector_update_now = 1;
						end
					end else begin
						if (input_spike_fifo_full == 0) begin
							input_streaming_ready = 1;
							if (input_streaming_valid) begin
								n_input_spike_collector_counter = 0;
								input_spike_collector_update_now = 1;
								input_spike_fifo_wren_oneclk_fast = 1;
							end
						end
					end
				end else begin
					if (input_spike_collector_counter != CLOCK_INPUT_SPIKE_COLLECT_SHORT-1) begin
						input_streaming_ready = 1;
						if (input_streaming_valid) begin
							n_input_spike_collector_counter = input_spike_collector_counter + 1;
							input_spike_collector_update_now = 1;
						end
					end else begin
						if (input_spike_fifo_full == 0) begin
							input_streaming_ready = 1;
							if (input_streaming_valid) begin
								n_input_spike_collector_counter = 0;
								input_spike_collector_update_now = 1;
								input_spike_fifo_wren_oneclk_fast = 1;
							end
						end
					end
				end
				
				if (layers_all_start_ready) begin
					if ((start_inference_signal==0) && (start_inference_signal_oneclk_delay==0) && (start_inference_signal_twoclk_delay==0) && (start_inference_signal_threeclk_delay==0)) begin
						n_fsm_state = STATE_CONFIG;
					end
				end
			end
		endcase
	end

	assign layers_all_start_ready = layer1_port_start_ready && layer2_port_start_ready && layer3_port_start_ready && (layer1_port_config_valid_copy == 0) && (layer2_port_config_valid_copy == 0) && (layer3_port_config_valid_copy == 0);
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			long_time_input_streaming_mode <= 0;

			layer1_port_config_valid <= 0;
			layer1_port_config_valid_copy <= 0;
			layer1_config_value <= 0;

			layer2_port_config_valid <= 0;
			layer2_port_config_valid_copy <= 0;
			layer2_config_value <= 0;

			layer3_port_config_valid <= 0;
			layer3_port_config_valid_copy <= 0;
			layer3_config_value <= 0;
		end else begin
			long_time_input_streaming_mode <= n_long_time_input_streaming_mode;
			
			layer1_port_config_valid <= n_layer1_port_config_valid;
			layer1_port_config_valid_copy <= n_layer1_port_config_valid_copy;
			layer1_config_value <= n_layer1_config_value;

			layer2_port_config_valid <= n_layer2_port_config_valid;
			layer2_port_config_valid_copy <= n_layer2_port_config_valid_copy;
			layer2_config_value <= n_layer2_config_value;

			layer3_port_config_valid <= n_layer3_port_config_valid;
			layer3_port_config_valid_copy <= n_layer3_port_config_valid_copy;
			layer3_config_value <= n_layer3_config_value;
		end
	end
	always @ (*) begin
		n_long_time_input_streaming_mode = long_time_input_streaming_mode;

		n_layer1_port_config_valid = 0;
		n_layer1_port_config_valid_copy = 0;
		n_layer1_config_value = layer1_config_value;

		n_layer2_port_config_valid = 0;
		n_layer2_port_config_valid_copy = 0;
		n_layer2_config_value = layer2_config_value;

		n_layer3_port_config_valid = 0;
		n_layer3_port_config_valid_copy = 0;
		n_layer3_config_value = layer3_config_value;

		if (config_collect_done_main) begin
			n_long_time_input_streaming_mode = config_value_collector[0];
		end else if (config_collect_done_layer1) begin
			n_layer1_port_config_valid = 1;
			n_layer1_port_config_valid_copy = 1;
			n_layer1_config_value = config_value_collector[LAYER1_BIT_WIDTH_SRAM-1:0];
		end else if (config_collect_done_layer2) begin
			n_layer2_port_config_valid = 1;
			n_layer2_port_config_valid_copy = 1;
			n_layer2_config_value = config_value_collector[LAYER2_BIT_WIDTH_SRAM-1:0];
		end else if (config_collect_done_layer3) begin
			n_layer3_port_config_valid = 1;
			n_layer3_port_config_valid_copy = 1;
			n_layer3_config_value = config_value_collector[LAYER3_BIT_WIDTH_SRAM-1:0];
		end
	end
	// ##### MAIN FSM ################################################################################################################################################################
	// ##### MAIN FSM ################################################################################################################################################################
	// ##### MAIN FSM ################################################################################################################################################################
	// ##### MAIN FSM ################################################################################################################################################################
	// ##### MAIN FSM ################################################################################################################################################################
















	// ### START SINGAL REGISTERING ################################################################################################################################################################
	// ### START SINGAL REGISTERING ################################################################################################################################################################
	// ### START SINGAL REGISTERING ################################################################################################################################################################
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			start_training_signal_oneclk_delay <= 0;
			start_training_signal_twoclk_delay <= 0;
			start_training_signal_threeclk_delay <= 0;

			layer1_port_training_start_flag <= 0;
			layer2_port_training_start_flag <= 0;
			layer3_port_training_start_flag <= 0;

			start_inference_signal_oneclk_delay <= 0;
			start_inference_signal_twoclk_delay <= 0;
			start_inference_signal_threeclk_delay <= 0;

			layer1_port_inference_start_flag <= 0;
			layer2_port_inference_start_flag <= 0;
			layer3_port_inference_start_flag <= 0;
		end else begin
			start_training_signal_oneclk_delay <= start_training_signal;
			start_training_signal_twoclk_delay <= start_training_signal_oneclk_delay;
			start_training_signal_threeclk_delay <= start_training_signal_twoclk_delay;

			layer1_port_training_start_flag <= start_training_signal;
			layer2_port_training_start_flag <= start_training_signal;
			layer3_port_training_start_flag <= start_training_signal;

			start_inference_signal_oneclk_delay <= start_inference_signal;
			start_inference_signal_twoclk_delay <= start_inference_signal_oneclk_delay;
			start_inference_signal_threeclk_delay <= start_inference_signal_twoclk_delay;

			layer1_port_inference_start_flag <= start_inference_signal;
			layer2_port_inference_start_flag <= start_inference_signal;
			layer3_port_inference_start_flag <= start_inference_signal;
		end
	end
	// ### START SINGAL REGISTERING ################################################################################################################################################################
	// ### START SINGAL REGISTERING ################################################################################################################################################################
	// ### START SINGAL REGISTERING ################################################################################################################################################################















	// ### LAYER1, LAYER2, LAYER3 INST ################################################################################################################################################################
	// ### LAYER1, LAYER2, LAYER3 INST ################################################################################################################################################################
	// ### LAYER1, LAYER2, LAYER3 INST ################################################################################################################################################################
	layer1#(
		.BIT_WIDTH_WEIGHT                           ( LAYER1_BIT_WIDTH_WEIGHT ),
		.BIT_WIDTH_MEMBRANE                         ( LAYER1_BIT_WIDTH_MEMBRANE ),
		.BIT_WIDTH_SURROGATE                        ( LAYER1_BIT_WIDTH_SURROGATE ),
		.DEPTH_SURROGATE_BOX                        ( LAYER1_DEPTH_SURROGATE_BOX ),
		.BIT_WIDTH_SRAM                             ( LAYER1_BIT_WIDTH_SRAM ),
		.DEPTH_SRAM                                 ( LAYER1_DEPTH_SRAM ),
		.BIT_WIDTH_ADDRESS                          ( LAYER1_BIT_WIDTH_ADDRESS ),
		.BIT_WIDTH_DELTA_WEIGHT                     ( LAYER1_BIT_WIDTH_DELTA_WEIGHT ),
		.NEURON_NUM_IN_SET                          ( LAYER1_NEURON_NUM_IN_SET ),
		.SET_NUM                                    ( LAYER1_SET_NUM ),
		.INPUT_SIZE                                 ( LAYER1_INPUT_SIZE ),
		.OUTPUT_SIZE                                ( LAYER1_OUTPUT_SIZE ),
		.SPIKE_BUFFER_PAST_SIZE                     ( LAYER1_SPIKE_BUFFER_PAST_SIZE ),
		.BIT_WIDTH_FSM                              ( LAYER1_BIT_WIDTH_FSM ),
		.BIT_WIDTH_CONFIG_COUNTER                   ( LAYER1_BIT_WIDTH_CONFIG_COUNTER )
	)u_layer1( 
		.clk                                        ( clk                                        ),
		.reset_n                                    ( reset_n                                    ),
		.config_valid_i                             ( layer1_port_config_valid                             ),
		.do_not_config_now_o                        ( layer1_port_do_not_config_now                        ),
		.input_spike_i                              ( layer1_port_input_spike                              ),
		.input_setting_done_i                       ( layer1_port_input_setting_done                       ),
		.error_setting_done_i                       ( layer1_port_error_setting_done                       ),
		.this_sample_done_i                         ( layer1_port_this_sample_done                         ),
		.this_epoch_finish_i                        ( layer1_port_this_epoch_finish                        ),
		.input_setting_catch_ready_o                ( layer1_port_input_setting_catch_ready                ),
		.error_setting_catch_ready_o                ( layer1_port_error_setting_catch_ready               ),
		.start_ready_o                              ( layer1_port_start_ready                            ),
		.training_start_flag_i                      ( layer1_port_training_start_flag                      ),
		.inference_start_flag_i                     ( layer1_port_inference_start_flag                     ),
		.weight_update_skip_i                       ( layer1_port_weight_update_skip                       ),
		.error_class_first_i                        ( layer1_port_error_class_first                        ),
		.error_class_second_i                       ( layer1_port_error_class_second                       ),
		.post_spike_catch_done_i                    ( layer1_port_post_spike_catch_done                    ),
		.post_spike_o                               ( layer1_port_post_spike                               ),
		.post_spike_valid_o                         ( layer1_port_post_spike_valid                         ),
		.sram_sram_port1_address_o                  ( layer1_port_sram_sram_port1_address_o                  ),
		.sram_sram_port1_enable_o                   ( layer1_port_sram_sram_port1_enable_o                   ),
		.sram_sram_port1_write_enable_o             ( layer1_port_sram_sram_port1_write_enable_o             ),
		.sram_sram_port1_write_data_o               ( layer1_port_sram_sram_port1_write_data_o               ),
		.sram_sram_software_hardware_check_weight_o ( layer1_port_sram_sram_software_hardware_check_weight_o ),
		.sram_sram_port1_read_data_i                ( layer1_port_sram_sram_port1_read_data_i                )
	);
	layer2#(
		.BIT_WIDTH_WEIGHT                           ( LAYER2_BIT_WIDTH_WEIGHT ),
		.BIT_WIDTH_MEMBRANE                         ( LAYER2_BIT_WIDTH_MEMBRANE ),
		.BIT_WIDTH_SURROGATE                        ( LAYER2_BIT_WIDTH_SURROGATE ),
		.DEPTH_SURROGATE_BOX                        ( LAYER2_DEPTH_SURROGATE_BOX ),
		.BIT_WIDTH_SRAM                             ( LAYER2_BIT_WIDTH_SRAM ),
		.DEPTH_SRAM                                 ( LAYER2_DEPTH_SRAM ),
		.BIT_WIDTH_ADDRESS                          ( LAYER2_BIT_WIDTH_ADDRESS ),
		.BIT_WIDTH_DELTA_WEIGHT                     ( LAYER2_BIT_WIDTH_DELTA_WEIGHT ),
		.NEURON_NUM_IN_SET                          ( LAYER2_NEURON_NUM_IN_SET ),
		.SET_NUM                                    ( LAYER2_SET_NUM ),
		.INPUT_SIZE                                 ( LAYER2_INPUT_SIZE ),
		.OUTPUT_SIZE                                ( LAYER2_OUTPUT_SIZE ),
		.SPIKE_BUFFER_PAST_SIZE                     ( LAYER2_SPIKE_BUFFER_PAST_SIZE ),
		.BIT_WIDTH_FSM                              ( LAYER2_BIT_WIDTH_FSM ),
		.BIT_WIDTH_CONFIG_COUNTER                   ( LAYER2_BIT_WIDTH_CONFIG_COUNTER )
	)u_layer2(
		.clk                                        ( clk                                        ),
		.reset_n                                    ( reset_n                                    ),
		.config_valid_i                             ( layer2_port_config_valid                             ),
		.do_not_config_now_o                        ( layer2_port_do_not_config_now                        ),
		.input_spike_i                              ( layer2_port_input_spike                              ),
		.input_setting_done_i                       ( layer2_port_input_setting_done                       ),
		.error_setting_done_i                       ( layer2_port_error_setting_done                       ),
		.this_sample_done_i                         ( layer2_port_this_sample_done                         ),
		.this_epoch_finish_i                        ( layer2_port_this_epoch_finish                        ),
		.input_setting_catch_ready_o                ( layer2_port_input_setting_catch_ready                ),
		.error_setting_catch_ready_o                ( layer2_port_error_setting_catch_ready                ),
		.start_ready_o                              ( layer2_port_start_ready                              ),
		.training_start_flag_i                      ( layer2_port_training_start_flag                      ),
		.inference_start_flag_i                     ( layer2_port_inference_start_flag                     ),
		.weight_update_skip_i                       ( layer2_port_weight_update_skip                       ),
		.error_class_first_i                        ( layer2_port_error_class_first                        ),
		.error_class_second_i                       ( layer2_port_error_class_second                       ),
		.post_spike_catch_done_i                    ( layer2_port_post_spike_catch_done                    ),
		.post_spike_o                               ( layer2_port_post_spike                               ),
		.post_spike_valid_o                         ( layer2_port_post_spike_valid                         ),
		.sram_sram_port1_address_o                  ( layer2_port_sram_sram_port1_address_o                  ),
		.sram_sram_port1_enable_o                   ( layer2_port_sram_sram_port1_enable_o                   ),
		.sram_sram_port1_write_enable_o             ( layer2_port_sram_sram_port1_write_enable_o             ),
		.sram_sram_port1_write_data_o               ( layer2_port_sram_sram_port1_write_data_o               ),
		.sram_sram_software_hardware_check_weight_o ( layer2_port_sram_sram_software_hardware_check_weight_o ),
		.sram_sram_port1_read_data_i                ( layer2_port_sram_sram_port1_read_data_i                )
	);
	layer3#(
		.BIT_WIDTH_WEIGHT                           ( LAYER3_BIT_WIDTH_WEIGHT ),
		.BIT_WIDTH_MEMBRANE                         ( LAYER3_BIT_WIDTH_MEMBRANE ),
		.BIT_WIDTH_SRAM                             ( LAYER3_BIT_WIDTH_SRAM ),
		.DEPTH_SRAM                                 ( LAYER3_DEPTH_SRAM ),
		.BIT_WIDTH_ADDRESS                          ( LAYER3_BIT_WIDTH_ADDRESS ),
		.BIT_WIDTH_DELTA_WEIGHT                     ( LAYER3_BIT_WIDTH_DELTA_WEIGHT ),
		.NEURON_NUM_IN_SET                          ( LAYER3_NEURON_NUM_IN_SET ),
		.SET_NUM                                    ( LAYER3_SET_NUM ),
		.INPUT_SIZE                                 ( LAYER3_INPUT_SIZE ),
		.OUTPUT_SIZE                                ( LAYER3_OUTPUT_SIZE ),
		.SPIKE_BUFFER_PAST_SIZE                     ( LAYER3_SPIKE_BUFFER_PAST_SIZE ),
		.BIT_WIDTH_FSM                              ( LAYER3_BIT_WIDTH_FSM ),
		.BIT_WIDTH_CONFIG_COUNTER                   ( LAYER3_BIT_WIDTH_CONFIG_COUNTER ),
		.BIT_WIDTH_BIG_MEMBRANE                     ( LAYER3_BIT_WIDTH_BIG_MEMBRANE ),
		.CLASSIFIER_SIZE                            ( LAYER3_CLASSIFIER_SIZE )
	)u_layer3(
		.clk                                        ( clk                                        ),
		.reset_n                                    ( reset_n                                    ),
		.config_valid_i                             ( layer3_port_config_valid                             ),
		.do_not_config_now_o                        ( layer3_port_do_not_config_now                        ),
		.input_spike_i                              ( layer3_port_input_spike                              ),
		.input_setting_done_i                       ( layer3_port_input_setting_done                       ),
		.this_sample_label_i                        ( layer3_port_this_sample_label                        ),
		.this_sample_done_i                         ( layer3_port_this_sample_done                         ),
		.this_epoch_finish_i                        ( layer3_port_this_epoch_finish                        ),
		.input_setting_catch_ready_o                ( layer3_port_input_setting_catch_ready                ),
		.start_ready_o                              ( layer3_port_start_ready                              ),
		.training_start_flag_i                      ( layer3_port_training_start_flag                      ),
		.inference_start_flag_i                     ( layer3_port_inference_start_flag                     ),
		.weight_update_skip_o                       ( layer3_port_weight_update_skip                       ),
		.error_class_first_o                        ( layer3_port_error_class_first                        ),
		.error_class_second_o                       ( layer3_port_error_class_second                       ),
		.error_class_catch_done_i                   ( layer3_port_error_class_catch_done                   ),
		.error_class_valid_o                        ( layer3_port_error_class_valid                        ),
		.inferenced_class_catch_done_i              ( layer3_port_inferenced_class_catch_done              ),
		.inferenced_class_o                         ( layer3_port_inferenced_class                         ),
		.inferenced_class_valid_o                   ( layer3_port_inferenced_class_valid                   ),
		.sram_sram_port1_address_o                  ( layer3_port_sram_sram_port1_address_o                  ),
		.sram_sram_port1_enable_o                   ( layer3_port_sram_sram_port1_enable_o                   ),
		.sram_sram_port1_write_enable_o             ( layer3_port_sram_sram_port1_write_enable_o             ),
		.sram_sram_port1_write_data_o               ( layer3_port_sram_sram_port1_write_data_o               ),
		.sram_sram_software_hardware_check_weight_o ( layer3_port_sram_sram_software_hardware_check_weight_o ),
		.sram_sram_port1_read_data_i                ( layer3_port_sram_sram_port1_read_data_i                )
	);
	// ### LAYER1, LAYER2, LAYER3 INST ################################################################################################################################################################
	// ### LAYER1, LAYER2, LAYER3 INST ################################################################################################################################################################
	// ### LAYER1, LAYER2, LAYER3 INST ################################################################################################################################################################


endmodule


