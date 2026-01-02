module top_bh #( 
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

	parameter	    INOUT_BUFFERING_NUM = 3, // 최소 2이상

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
		input [65:0] input_streaming_data_i,
		output input_streaming_ready_o,

		input start_training_signal_i, 
		input start_inference_signal_i, 
		output start_ready_o, 

		output inferenced_label_o 
	);

    wire wire_input_streaming_valid_i;
    wire [65:0] wire_input_streaming_data_i;
    wire wire_input_streaming_ready_o;

    wire wire_start_training_signal_i; 
    wire wire_start_inference_signal_i; 
    wire wire_start_ready_o; 

    wire wire_inferenced_label_o;
    
	snn_sram_inserted#(
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
	)u_snn_sram_inserted(
        .clk                      ( clk                      ),
        .reset_n                  ( reset_n                  ),
        .input_streaming_valid_i  ( wire_input_streaming_valid_i  ),
        .input_streaming_data_i   ( wire_input_streaming_data_i   ),
        .input_streaming_ready_o  ( wire_input_streaming_ready_o  ),
        .start_training_signal_i  ( wire_start_training_signal_i  ),
        .start_inference_signal_i ( wire_start_inference_signal_i ),
        .start_ready_o            ( wire_start_ready_o            ),
        .inferenced_label_o       ( wire_inferenced_label_o       )
    );




    // ############ INPUT BUFFER (2 STAGE) ###############################################
    // ############ INPUT BUFFER (2 STAGE) ###############################################
    // ############ INPUT BUFFER (2 STAGE) ###############################################
    reg buf0_input_streaming_valid_i;
    reg [65:0] buf0_input_streaming_data_i;
    reg buf0_start_training_signal_i; 
    reg buf0_start_inference_signal_i; 
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            buf0_input_streaming_valid_i <= 0;
            buf0_input_streaming_data_i <= 0;
            buf0_start_training_signal_i <= 0;
            buf0_start_inference_signal_i <= 0;
        end else begin
            buf0_input_streaming_valid_i <= input_streaming_valid_i;
            buf0_input_streaming_data_i <= input_streaming_data_i;
            buf0_start_training_signal_i <= start_training_signal_i;
            buf0_start_inference_signal_i <= start_inference_signal_i;
        end
    end

    reg buf1_input_streaming_valid_i;
    reg [65:0] buf1_input_streaming_data_i;
    reg buf1_start_training_signal_i; 
    reg buf1_start_inference_signal_i; 
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            buf1_input_streaming_valid_i <= 0;
            buf1_input_streaming_data_i <= 0;
            buf1_start_training_signal_i <= 0;
            buf1_start_inference_signal_i <= 0;
        end else begin
            buf1_input_streaming_valid_i <= buf0_input_streaming_valid_i;
            buf1_input_streaming_data_i <= buf0_input_streaming_data_i;
            buf1_start_training_signal_i <= buf0_start_training_signal_i;
            buf1_start_inference_signal_i <= buf0_start_inference_signal_i;
        end
    end

    assign wire_input_streaming_valid_i = buf1_input_streaming_valid_i;
    assign wire_input_streaming_data_i = buf1_input_streaming_data_i;
    assign wire_start_training_signal_i = buf1_start_training_signal_i;
    assign wire_start_inference_signal_i = buf1_start_inference_signal_i;
    // ############ INPUT BUFFER (2 STAGE) ###############################################
    // ############ INPUT BUFFER (2 STAGE) ###############################################
    // ############ INPUT BUFFER (2 STAGE) ###############################################




    // ############ OUTPUT BUFFER (1 STAGE) ###############################################
    // ############ OUTPUT BUFFER (1 STAGE) ###############################################
    // ############ OUTPUT BUFFER (1 STAGE) ###############################################
    reg buf0_input_streaming_ready_o;
    reg buf0_start_ready_o; 
    reg buf0_inferenced_label_o;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            buf0_input_streaming_ready_o <= 0;
            buf0_start_ready_o <= 0;
            buf0_inferenced_label_o <= 0;
        end else begin
            buf0_input_streaming_ready_o <= wire_input_streaming_ready_o;
            buf0_start_ready_o <= wire_start_ready_o;
            buf0_inferenced_label_o <= wire_inferenced_label_o;
        end
    end

    assign input_streaming_ready_o = buf0_input_streaming_ready_o;
    assign start_ready_o = buf0_start_ready_o;
    assign inferenced_label_o = buf0_inferenced_label_o;
    // ############ OUTPUT BUFFER (1 STAGE) ###############################################
    // ############ OUTPUT BUFFER (1 STAGE) ###############################################
    // ############ OUTPUT BUFFER (1 STAGE) ###############################################
    
endmodule




