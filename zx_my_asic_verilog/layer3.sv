module layer3 #( 
	parameter       BIT_WIDTH_WEIGHT         = 8,  
    parameter       BIT_WIDTH_MEMBRANE       = 16,


	parameter       BIT_WIDTH_SRAM         = 8,  
	parameter       DEPTH_SRAM             = 200,
	parameter       BIT_WIDTH_ADDRESS      = 8,

	parameter       BIT_WIDTH_DELTA_WEIGHT       = 2,


	parameter       NEURON_NUM_IN_SET = 1,
	parameter       SET_NUM = 10,

	parameter       INPUT_SIZE = 200,
	parameter       OUTPUT_SIZE = 10,
	parameter 		SPIKE_BUFFER_PAST_SIZE = 1,

	parameter       BIT_WIDTH_FSM = 2,

	parameter       BIT_WIDTH_CONFIG_COUNTER = 11,

    parameter       BIT_WIDTH_BIG_MEMBRANE       = 16,

	parameter       CLASSIFIER_SIZE = 10
    )(
		input clk,
		input reset_n,

		input config_valid_i,
		output do_not_config_now_o,
		
		input [INPUT_SIZE-1:0] input_spike_i,
		input input_setting_done_i,
		input [3:0] this_sample_label_i,
		input this_sample_done_i,
		input this_epoch_finish_i,
		
		output reg input_setting_catch_ready_o,

		output start_ready_o,
		input training_start_flag_i,
		input inference_start_flag_i,

		output weight_update_skip_o,
		output [3:0] error_class_first_o,
		output [3:0] error_class_second_o,
		
		input error_class_catch_done_i,
		output error_class_valid_o,

		input inferenced_class_catch_done_i,
		output [3:0] inferenced_class_o,
		output inferenced_class_valid_o,

		// ######## sram port ###########################################################################
		output [BIT_WIDTH_ADDRESS*SET_NUM-1:0] sram_sram_port1_address_o,
		output [SET_NUM-1:0] sram_sram_port1_enable_o,
		output [SET_NUM-1:0] sram_sram_port1_write_enable_o,
		output [BIT_WIDTH_SRAM*SET_NUM-1:0] sram_sram_port1_write_data_o,

		output sram_sram_software_hardware_check_weight_o,

		input [BIT_WIDTH_SRAM*SET_NUM-1:0] sram_sram_port1_read_data_i
		// ######## sram port ###########################################################################
	);


    // FSM local param
    localparam STATE_CONFIG                    = 0;
    localparam STATE_PROCESSING_TRAINING       = 1;
    localparam STATE_PROCESSING_INFERENCE      = 2;
	
	wire [BIT_WIDTH_SRAM-1:0] config_value;
	// assign config_value = input_spike_i[BIT_WIDTH_SRAM-1:0];
	assign config_value = input_spike_i;
	reg config_done_flag, n_config_done_flag;
	reg sram_initialize;
	reg [BIT_WIDTH_CONFIG_COUNTER-1:0] config_counter, n_config_counter;
	reg [3:0] config_counter_modulo_ten, n_config_counter_modulo_ten;
	reg [9:0] config_counter_divide_ten, n_config_counter_divide_ten;
	reg binary_classifier_mode, n_binary_classifier_mode;
	reg loser_encourage_mode, n_loser_encourage_mode;

	reg go_to_config_state;
	reg epoch_first_step, n_epoch_first_step;

	// ######### FSM #############################################################################
	// ######### FSM #############################################################################
	// ######### FSM #############################################################################
	reg [BIT_WIDTH_FSM-1:0] fsm_state, n_fsm_state;
	reg inference_fsm_state_oneclk_delay;
	assign start_ready_o = (fsm_state == STATE_CONFIG) && (config_counter == 0);
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			fsm_state <= STATE_CONFIG;
            inference_fsm_state_oneclk_delay <= 0;
            config_done_flag <= 0;
            config_counter <= 0;
            config_counter_modulo_ten <= 0;
            config_counter_divide_ten <= 0;
            binary_classifier_mode <= 0;
            loser_encourage_mode <= 0;
		end else begin
			fsm_state <= n_fsm_state;
            inference_fsm_state_oneclk_delay <= (fsm_state == STATE_PROCESSING_INFERENCE);
            config_done_flag <= n_config_done_flag;
            config_counter <= n_config_counter;
            config_counter_modulo_ten <= n_config_counter_modulo_ten;
            config_counter_divide_ten <= n_config_counter_divide_ten;
            binary_classifier_mode <= n_binary_classifier_mode;
            loser_encourage_mode <= n_loser_encourage_mode;
		end
	end
    always @ (*) begin 
		n_fsm_state = fsm_state;
		n_config_done_flag = config_done_flag;
		n_config_counter = config_counter;
		n_config_counter_modulo_ten = config_counter_modulo_ten;
		n_config_counter_divide_ten = config_counter_divide_ten;
        case(fsm_state)
            STATE_CONFIG: begin
				if (config_valid_i == 1 && config_done_flag == 0) begin
					if (config_counter != DEPTH_SRAM*SET_NUM) begin
						n_config_counter = config_counter+1;
						if (config_counter_modulo_ten != 9) begin
							n_config_counter_modulo_ten = config_counter_modulo_ten+1;
						end else begin
							n_config_counter_modulo_ten = 0;
							n_config_counter_divide_ten = config_counter_divide_ten+1;
						end
					end else begin
						n_config_done_flag = 1;
						n_config_counter = 0;
						n_config_counter_modulo_ten = 0;
						n_config_counter_divide_ten = 0;
					end
				end else if (training_start_flag_i && config_counter == 0) begin
					n_fsm_state = STATE_PROCESSING_TRAINING;
					n_config_done_flag = 0;
				end else if (inference_start_flag_i && config_counter == 0) begin
					n_fsm_state = STATE_PROCESSING_INFERENCE;
					n_config_done_flag = 0;
				end
            end
            STATE_PROCESSING_TRAINING: begin
				if(go_to_config_state) begin
					n_fsm_state = STATE_CONFIG;
				end
            end
            STATE_PROCESSING_INFERENCE: begin
				if(go_to_config_state) begin
					n_fsm_state = STATE_CONFIG;
				end
            end
        endcase 
    end
	// ######### FSM #############################################################################
	// ######### FSM #############################################################################
	// ######### FSM #############################################################################
 
	reg [BIT_WIDTH_MEMBRANE*NEURON_NUM_IN_SET-1:0] neuron_membrane_update [0:SET_NUM-1];
	reg [SET_NUM-1:0] neuron_membrane_update_valid;
	wire [BIT_WIDTH_MEMBRANE*NEURON_NUM_IN_SET-1:0] neuron_membrane [0:SET_NUM-1];

	reg [BIT_WIDTH_BIG_MEMBRANE*NEURON_NUM_IN_SET-1:0] neuron_big_membrane_update [0:SET_NUM-1];
	reg [SET_NUM-1:0] neuron_big_membrane_update_valid;
	wire [BIT_WIDTH_BIG_MEMBRANE*NEURON_NUM_IN_SET-1:0] neuron_big_membrane [0:SET_NUM-1];


	reg neuron_this_sample_done, n_neuron_this_sample_done;
	reg neuron_this_sample_done_oneclk_delay;
	reg this_epoch_finish, n_this_epoch_finish;

	reg [3:0] this_sample_label, n_this_sample_label;

	reg [BIT_WIDTH_BIG_MEMBRANE*NEURON_NUM_IN_SET-1:0] adder_membrane_weight [0:SET_NUM-1];
	reg [BIT_WIDTH_MEMBRANE*NEURON_NUM_IN_SET-1:0] adder_membrane_membrane [0:SET_NUM-1];
	reg [SET_NUM-1:0] adder_membrane_weight_update_mode;
	reg [SET_NUM-1:0] adder_membrane_small_membrane_update_mode;
	wire [BIT_WIDTH_BIG_MEMBRANE*NEURON_NUM_IN_SET-1:0] adder_membrane_membrane_update [0:SET_NUM-1];
	wire [BIT_WIDTH_MEMBRANE*NEURON_NUM_IN_SET-1:0] adder_membrane_membrane_update_shifted [0:SET_NUM-1];
	
	reg [INPUT_SIZE-1:0] spike_buffer_past [0:SPIKE_BUFFER_PAST_SIZE-1];
	reg [INPUT_SIZE-1:0] n_spike_buffer_past [0:SPIKE_BUFFER_PAST_SIZE-1];

	reg neuron_surrogate_read_finish_have_been, n_neuron_surrogate_read_finish_have_been;
	reg neuron_surrogate_read_finish_have_been2, n_neuron_surrogate_read_finish_have_been2;
	
	reg read_zero_write_one, n_read_zero_write_one;

	reg aer_sliced_encoder_start;
	reg [SET_NUM-1:0] aer_sliced_encoding_on;
	reg [INPUT_SIZE-1:0] aer_sliced_hot_vector;
	reg [3:0] aer_sliced_error_class;

	wire [BIT_WIDTH_ADDRESS*SET_NUM-1:0] aer_sliced_aer;
	wire [SET_NUM-1:0] aer_sliced_valid;
	wire [BIT_WIDTH_ADDRESS-1:0] aer_sliced_aer_array [0:SET_NUM-1];

	wire aer_sliced_valid_ffmode;
	wire [SET_NUM-1:0] aer_sliced_priority_encoder_valid;

	wire [BIT_WIDTH_ADDRESS-1:0] aer_sliced_group0_aer;
	wire aer_sliced_group0_valid;


	reg [SET_NUM-1:0] aer_sliced_encoding_on_read_timing_for_wu;

	reg [SET_NUM-1:0] aer_sliced_encoding_on_oneclk_delay;
	reg [BIT_WIDTH_ADDRESS*SET_NUM-1:0] aer_sliced_aer_oneclk_delay;

	reg [SET_NUM-1:0] aer_sliced_encoding_on_twoclk_delay;
	reg [BIT_WIDTH_ADDRESS*SET_NUM-1:0] aer_sliced_aer_twoclk_delay;
	wire [BIT_WIDTH_ADDRESS-1:0] aer_sliced_aer_twoclk_delay_array [0:SET_NUM-1];

	reg weight_update_time, n_weight_update_time;
	reg weight_update_time_oneclk_delay;
	reg weight_update_time_twoclk_delay;

	reg first_error_propagation_done, n_first_error_propagation_done;

	

	// sram port & membrane update control
	reg [BIT_WIDTH_ADDRESS-1:0] sram_port1_address [0:SET_NUM-1];
	reg [SET_NUM-1:0] sram_port1_enable;
	reg [SET_NUM-1:0] sram_port1_write_enable;
	reg [BIT_WIDTH_SRAM-1:0] sram_port1_write_data [0:SET_NUM-1];
	reg [BIT_WIDTH_SRAM-1:0] sram_port1_read_data [0:SET_NUM-1];
	wire [BIT_WIDTH_SRAM-1:0] n_sram_port1_read_data [0:SET_NUM-1];
	// wire [BIT_WIDTH_SRAM-1:0] sram_port1_read_data_shaked [0:SET_NUM-1];

	reg [SET_NUM-1:0] sram_port1_read_data_registering_singal;

	reg [3:0] error_class_first_save, n_error_class_first_save;
	reg [3:0] error_class_second_save, n_error_class_second_save;
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			error_class_first_save <= 0;
			error_class_second_save <= 0;
		end else begin
			error_class_first_save <= n_error_class_first_save;
			error_class_second_save <= n_error_class_second_save;
		end
	end

	reg [3:0] group_cnt, n_group_cnt;
	reg [3:0] group_cnt_oneclk_delay;
	reg [3:0] group_cnt_twoclk_delay;
	reg last_spike_this_group;
	reg last_spike_this_group_oneclk_delay;
	reg last_spike_this_group_twoclk_delay;

	wire group_cnt_equals_set_num;
	assign group_cnt_equals_set_num = (group_cnt == SET_NUM);
	
	reg [BIT_WIDTH_ADDRESS-1:0] aer_sliced_aer_array_selected;
	reg aer_sliced_valid_selected;
	reg aer_sliced_priority_encoder_valid_selected;

	reg read_wait_done, n_read_wait_done;
	reg write_wait_done, n_write_wait_done;

	reg post_spiking_now;
	reg post_spiking_now_oneclk_delay;
	reg post_spiking_now_oneclk_fast;
	
	reg inferenced_class_valid, n_inferenced_class_valid;
	reg error_class_valid, n_error_class_valid;


	reg need_to_catch_spike_at_wu, n_need_to_catch_spike_at_wu;

	reg [BIT_WIDTH_ADDRESS-1:0] write_group0_last_address, n_write_group0_last_address;
	reg write_group0_last_address_valid, n_write_group0_last_address_valid;


	wire input_setting_done;
	assign input_setting_done = input_setting_done_i && (input_setting_catch_ready_o == 0);

	reg input_setting_catch_ready_oneclk_fast;
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			input_setting_catch_ready_o <= 0;
		end else begin
            input_setting_catch_ready_o <= input_setting_catch_ready_oneclk_fast;
		end
	end




	reg signed [BIT_WIDTH_BIG_MEMBRANE-1:0] comparator_final_variable0;
	reg signed [BIT_WIDTH_BIG_MEMBRANE-1:0] comparator_final_variable1;
	reg signed [BIT_WIDTH_BIG_MEMBRANE-1:0] comparator_final_variable2;
	reg signed [BIT_WIDTH_BIG_MEMBRANE-1:0] comparator_final_variable3;
	reg signed [BIT_WIDTH_BIG_MEMBRANE-1:0] comparator_final_variable4;
	reg signed [BIT_WIDTH_BIG_MEMBRANE-1:0] comparator_final_variable5;
	reg signed [BIT_WIDTH_BIG_MEMBRANE-1:0] comparator_final_variable6;
	reg signed [BIT_WIDTH_BIG_MEMBRANE-1:0] comparator_final_variable7;
	reg signed [BIT_WIDTH_BIG_MEMBRANE-1:0] comparator_final_variable8;
	reg signed [BIT_WIDTH_BIG_MEMBRANE-1:0] comparator_final_variable9;

	wire [3:0] winner_section1;
	wire [3:0] winner_section2;
	wire [3:0] winner_section_all;	
	wire winner_section_all_binary;

	reg signed [BIT_WIDTH_BIG_MEMBRANE-1:0] comparator_final_loser_variable0;
	reg signed [BIT_WIDTH_BIG_MEMBRANE-1:0] comparator_final_loser_variable1;
	reg signed [BIT_WIDTH_BIG_MEMBRANE-1:0] comparator_final_loser_variable2;
	reg signed [BIT_WIDTH_BIG_MEMBRANE-1:0] comparator_final_loser_variable3;
	reg signed [BIT_WIDTH_BIG_MEMBRANE-1:0] comparator_final_loser_variable4;

	wire [2:0] comparator_final_loser;
	reg [3:0] loser_in_label_section;

	wire sames_winner_section_all_binary_vs_this_sample_label;
	assign sames_winner_section_all_binary_vs_this_sample_label = (winner_section_all_binary == this_sample_label);

	wire sames_winner_section_all_vs_this_sample_label;
	assign sames_winner_section_all_vs_this_sample_label = (winner_section_all == this_sample_label);

	reg group0_barrier_flag;

	// ######### MAIN CONTROL #############################################################################
	// ######### MAIN CONTROL #############################################################################
	// ######### MAIN CONTROL #############################################################################
	// ######### MAIN CONTROL #############################################################################
	// ######### MAIN CONTROL #############################################################################
	// ######### MAIN CONTROL #############################################################################
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
            read_zero_write_one <= 0;
            weight_update_time <= 0;
            weight_update_time_oneclk_delay <= 0;
            weight_update_time_twoclk_delay <= 0;
            first_error_propagation_done <= 0;
            group_cnt <= 0;
            read_wait_done <= 0;
            write_wait_done <= 0;
			neuron_this_sample_done <= 0;
			this_sample_label <= 0;
			this_epoch_finish <= 0;
			neuron_surrogate_read_finish_have_been <= 0;
			neuron_surrogate_read_finish_have_been2 <= 0;
			need_to_catch_spike_at_wu <= 0;
            write_group0_last_address <= 0;
            write_group0_last_address_valid <= 0;
            epoch_first_step <= 1; // one!!!
		end else begin
            read_zero_write_one <= n_read_zero_write_one;
            weight_update_time <= n_weight_update_time;
            weight_update_time_oneclk_delay <= weight_update_time;
            weight_update_time_twoclk_delay <= weight_update_time_oneclk_delay;
            first_error_propagation_done <= n_first_error_propagation_done;
            group_cnt <= n_group_cnt;
            read_wait_done <= n_read_wait_done;
            write_wait_done <= n_write_wait_done;
            neuron_this_sample_done <= n_neuron_this_sample_done;
            this_sample_label <= n_this_sample_label;
            this_epoch_finish <= n_this_epoch_finish;
            neuron_surrogate_read_finish_have_been <= n_neuron_surrogate_read_finish_have_been;
            neuron_surrogate_read_finish_have_been2 <= n_neuron_surrogate_read_finish_have_been2;
            need_to_catch_spike_at_wu <= n_need_to_catch_spike_at_wu;
            write_group0_last_address <= n_write_group0_last_address;
            write_group0_last_address_valid <= n_write_group0_last_address_valid;
            epoch_first_step <= n_epoch_first_step;
		end
	end
    always @ (*) begin 
		input_setting_catch_ready_oneclk_fast = 0;

		n_read_zero_write_one = read_zero_write_one;

		aer_sliced_encoder_start = 0;
		aer_sliced_encoding_on = 10'b0;
		aer_sliced_hot_vector = spike_buffer_past[0];

		aer_sliced_encoding_on_read_timing_for_wu = 0;

		n_spike_buffer_past[0] = spike_buffer_past[0];

		n_weight_update_time = weight_update_time;
		n_first_error_propagation_done = first_error_propagation_done;

		aer_sliced_error_class = 0;

		n_group_cnt = group_cnt;
		last_spike_this_group = 0;

		n_error_class_first_save = error_class_first_save;
		n_error_class_second_save = error_class_second_save;


		n_read_wait_done = read_wait_done;
		n_write_wait_done = write_wait_done;

		n_neuron_this_sample_done = neuron_this_sample_done;
		n_this_epoch_finish = this_epoch_finish;

		n_neuron_surrogate_read_finish_have_been = neuron_surrogate_read_finish_have_been;
		n_neuron_surrogate_read_finish_have_been2 = neuron_surrogate_read_finish_have_been2;

		n_need_to_catch_spike_at_wu = need_to_catch_spike_at_wu;

		post_spiking_now_oneclk_fast = 0;

		n_write_group0_last_address = write_group0_last_address;
		n_write_group0_last_address_valid = write_group0_last_address_valid;
		
		go_to_config_state = 0;
		n_epoch_first_step = epoch_first_step;

		// n_neuron_this_sample_done = neuron_this_sample_done;

		n_this_sample_label = this_sample_label;

		group0_barrier_flag = 0;

		if (fsm_state == STATE_PROCESSING_TRAINING) begin
			if (epoch_first_step) begin
				n_weight_update_time = need_to_catch_spike_at_wu;
				if (need_to_catch_spike_at_wu == 0) begin
					if (input_setting_done) begin
						input_setting_catch_ready_oneclk_fast = 1;
						n_epoch_first_step = 0;

						n_spike_buffer_past[0] = input_spike_i;
						aer_sliced_hot_vector = input_spike_i;
						aer_sliced_encoder_start = 1;
						aer_sliced_error_class = 0;
						n_neuron_this_sample_done = this_sample_done_i;
						n_this_sample_label = this_sample_label_i;
						n_this_epoch_finish = this_epoch_finish_i;
						n_need_to_catch_spike_at_wu = 0;
					end
				end else begin
					n_epoch_first_step = 0;
						
					aer_sliced_hot_vector = spike_buffer_past[SPIKE_BUFFER_PAST_SIZE-1];
					aer_sliced_encoder_start = 1;
					aer_sliced_error_class = error_class_first_save;
				end
			end else begin
				if (weight_update_time) begin
					if (first_error_propagation_done == 0) begin
						if (aer_sliced_valid_ffmode == 1) begin
							if (read_zero_write_one == 0) begin // read
								n_read_zero_write_one = 1;
								aer_sliced_encoding_on_read_timing_for_wu = aer_sliced_valid;
							end else begin //write
								n_read_zero_write_one = 0;
								aer_sliced_encoding_on = aer_sliced_valid;
							end
						end else begin
							if (read_zero_write_one == 0) begin
								n_read_zero_write_one = 1;
							end else begin 
								n_read_zero_write_one = 0;

								// n_weight_update_time = 1;
								n_first_error_propagation_done = 1;

								aer_sliced_hot_vector = spike_buffer_past[SPIKE_BUFFER_PAST_SIZE-1];
								aer_sliced_encoder_start = 1;
								aer_sliced_error_class = error_class_second_save;
							end
						end
					end else begin 
						if (need_to_catch_spike_at_wu) begin
							if (input_setting_done) begin
								input_setting_catch_ready_oneclk_fast = 1;
								n_spike_buffer_past[0] = input_spike_i;
								n_neuron_this_sample_done = this_sample_done_i;
								n_this_sample_label = this_sample_label_i;
								n_this_epoch_finish = this_epoch_finish_i;
								n_need_to_catch_spike_at_wu = 0;
							end
						end

						if (aer_sliced_valid_ffmode == 1) begin
							if (read_zero_write_one == 0) begin // read
								n_read_zero_write_one = 1;
								aer_sliced_encoding_on_read_timing_for_wu = aer_sliced_valid;
							end else begin //write
								n_read_zero_write_one = 0;
								aer_sliced_encoding_on = aer_sliced_valid;
								n_write_group0_last_address = aer_sliced_group0_aer;
								n_write_group0_last_address_valid = aer_sliced_group0_valid;
							end
						end else begin
							n_write_wait_done = 1;
							if (write_wait_done) begin
								if (need_to_catch_spike_at_wu == 0) begin
									n_first_error_propagation_done = 0;

									n_write_wait_done = 0;
									n_weight_update_time = 0;

									aer_sliced_hot_vector = spike_buffer_past[0];
									aer_sliced_encoder_start = 1;
									aer_sliced_error_class = 0;
								end else begin
									n_write_group0_last_address_valid = 0;
								end
							end
						end
					end
				end else begin
					n_write_group0_last_address_valid = 0;
					if (write_group0_last_address_valid == 0 || aer_sliced_group0_valid == 0 || write_group0_last_address != aer_sliced_group0_aer) begin 
						if (!group_cnt_equals_set_num) begin 
							if (aer_sliced_valid_selected == 1) begin
								case(group_cnt)
									1: aer_sliced_encoding_on[1] = 1;
									2: aer_sliced_encoding_on[2] = 1;
									3: aer_sliced_encoding_on[3] = 1;
									4: aer_sliced_encoding_on[4] = 1;
									5: aer_sliced_encoding_on[5] = 1;
									6: aer_sliced_encoding_on[6] = 1;
									7: aer_sliced_encoding_on[7] = 1;
									8: aer_sliced_encoding_on[8] = 1;
									9: aer_sliced_encoding_on[9] = 1;
									default: aer_sliced_encoding_on[0] = 1;
								endcase
								if (aer_sliced_priority_encoder_valid_selected == 0) begin
									last_spike_this_group = 1;
									n_group_cnt = group_cnt + 1;
								end
							end else begin
								last_spike_this_group = 1;
								n_group_cnt = group_cnt + 1;
							end
						end else begin
							n_read_wait_done = 1;
							if (read_wait_done) begin 
								if ((error_class_valid == 0) || neuron_surrogate_read_finish_have_been2) begin
									n_neuron_surrogate_read_finish_have_been2 = 1;
									if (neuron_surrogate_read_finish_have_been2 == 0) begin
										post_spiking_now_oneclk_fast = 1; 
									end else begin
										if (this_epoch_finish) begin
											go_to_config_state = 1;
											n_epoch_first_step = 1;

											if (binary_classifier_mode == 0) begin
												if (sames_winner_section_all_vs_this_sample_label) begin 
													n_need_to_catch_spike_at_wu = 0;
												end else begin  
													n_need_to_catch_spike_at_wu = 1;
													n_error_class_first_save = this_sample_label;
													n_error_class_second_save = winner_section_all;
												end
											end else begin
												if (sames_winner_section_all_binary_vs_this_sample_label) begin
													n_need_to_catch_spike_at_wu = 0;
												end else begin
													n_need_to_catch_spike_at_wu = 1;
													if (this_sample_label == 1) begin
														n_error_class_first_save = loser_encourage_mode ? loser_in_label_section : winner_section2;
														n_error_class_second_save = winner_section1;
													end else begin
														n_error_class_first_save = loser_encourage_mode ? loser_in_label_section : winner_section1;
														n_error_class_second_save = winner_section2;
													end
												end
											end

											n_neuron_surrogate_read_finish_have_been2 = 0;
											n_group_cnt = 0;
											n_read_wait_done = 0;

											// aer_sliced_hot_vector = spike_buffer_past[SPIKE_BUFFER_PAST_SIZE-1];
											// aer_sliced_encoder_start = 1;
											// aer_sliced_error_class = error_class_first_i;
											
											n_weight_update_time = 0; 
										end else begin
											n_epoch_first_step = 0;

											// if (weight_update_skip_i) begin
											if (neuron_surrogate_read_finish_have_been || (binary_classifier_mode == 0 && sames_winner_section_all_vs_this_sample_label == 1) || (binary_classifier_mode == 1 && sames_winner_section_all_binary_vs_this_sample_label == 1)) begin
												if (input_setting_done) begin
													input_setting_catch_ready_oneclk_fast = 1;
													n_spike_buffer_past[0] = input_spike_i;
													n_neuron_surrogate_read_finish_have_been = 0;
													n_neuron_surrogate_read_finish_have_been2 = 0;
													n_group_cnt = 0;
													n_read_wait_done = 0;

													aer_sliced_hot_vector = input_spike_i;
													aer_sliced_encoder_start = 1;
													aer_sliced_error_class = 0;
													n_neuron_this_sample_done = this_sample_done_i;
													n_this_sample_label = this_sample_label_i;
													n_this_epoch_finish = this_epoch_finish_i;

													// n_error_class_first_save = error_class_first_i;
													// n_error_class_second_save = error_class_second_i; 
													n_weight_update_time = 0;
												end else begin
													n_neuron_surrogate_read_finish_have_been = 1;
												end
											end else begin
												n_need_to_catch_spike_at_wu = 1;

												n_neuron_surrogate_read_finish_have_been2 = 0;
												n_group_cnt = 0;
												n_read_wait_done = 0;

												aer_sliced_hot_vector = spike_buffer_past[SPIKE_BUFFER_PAST_SIZE-1];
												aer_sliced_encoder_start = 1;

												if (binary_classifier_mode == 0) begin
													aer_sliced_error_class = this_sample_label;
													n_error_class_first_save = this_sample_label;
													n_error_class_second_save = winner_section_all;
												end else begin
													if (this_sample_label == 1) begin
														aer_sliced_error_class = loser_encourage_mode ? loser_in_label_section : winner_section2;
														n_error_class_first_save = loser_encourage_mode ? loser_in_label_section : winner_section2;
														n_error_class_second_save = winner_section1;
													end else begin
														aer_sliced_error_class = loser_encourage_mode ? loser_in_label_section : winner_section1;
														n_error_class_first_save = loser_encourage_mode ? loser_in_label_section : winner_section1;
														n_error_class_second_save = winner_section2;
													end
												end
												n_weight_update_time = 1;
											end
										end
									end
								end
							end
						end
					end else begin
						group0_barrier_flag = 1;
					end
				end
			end
		end else if (fsm_state == STATE_PROCESSING_INFERENCE) begin // inference
			if (epoch_first_step) begin
				n_weight_update_time = 0;
				if (input_setting_done) begin
					input_setting_catch_ready_oneclk_fast = 1;
					n_epoch_first_step = 0;

					// n_spike_buffer_past[0] = input_spike_i; 
					aer_sliced_hot_vector = input_spike_i;
					aer_sliced_encoder_start = 1;
					aer_sliced_error_class = 0;
					n_neuron_this_sample_done = this_sample_done_i;
					n_this_epoch_finish = this_epoch_finish_i;
					// n_need_to_catch_spike_at_wu = 0; 
				end
			end else begin
				if (!group_cnt_equals_set_num) begin 
					if (aer_sliced_valid_selected == 1) begin
						case(group_cnt)
							1: aer_sliced_encoding_on[1] = 1;
							2: aer_sliced_encoding_on[2] = 1;
							3: aer_sliced_encoding_on[3] = 1;
							4: aer_sliced_encoding_on[4] = 1;
							5: aer_sliced_encoding_on[5] = 1;
							6: aer_sliced_encoding_on[6] = 1;
							7: aer_sliced_encoding_on[7] = 1;
							8: aer_sliced_encoding_on[8] = 1;
							9: aer_sliced_encoding_on[9] = 1;
							default: aer_sliced_encoding_on[0] = 1;
						endcase
						if (aer_sliced_priority_encoder_valid_selected == 0) begin
							last_spike_this_group = 1;
							n_group_cnt = group_cnt + 1;
						end
					end else begin
						last_spike_this_group = 1;
						n_group_cnt = group_cnt + 1;
					end
				end else begin
					n_read_wait_done = 1;
					if (read_wait_done) begin 
						if ((inferenced_class_valid == 0) || neuron_surrogate_read_finish_have_been2) begin
							n_neuron_surrogate_read_finish_have_been2 = 1;
							if (neuron_surrogate_read_finish_have_been2 == 0) begin
								post_spiking_now_oneclk_fast = 1; 
							end else begin
								if (this_epoch_finish) begin
									go_to_config_state = 1;
									n_epoch_first_step = 1;

									n_neuron_surrogate_read_finish_have_been2 = 0;
									n_group_cnt = 0;
									n_read_wait_done = 0;
								end else begin
									n_epoch_first_step = 0;

									if (input_setting_done) begin
										input_setting_catch_ready_oneclk_fast = 1;
										n_neuron_surrogate_read_finish_have_been2 = 0;
										n_group_cnt = 0;
										n_read_wait_done = 0;

										aer_sliced_hot_vector = input_spike_i;
										aer_sliced_encoder_start = 1;
										aer_sliced_error_class = 0;
										n_neuron_this_sample_done = this_sample_done_i;
										n_this_epoch_finish = this_epoch_finish_i;
									end
								end
							end
						end
					end
				end
			end
		end
    end

	reg weight_update_skip, n_weight_update_skip;
	reg [3:0] error_class_first, n_error_class_first;
	reg [3:0] error_class_second, n_error_class_second;

	reg [3:0] inferenced_class, n_inferenced_class;
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			inferenced_class_valid <= 0;
			error_class_valid <= 0;
			post_spiking_now <= 0;
			post_spiking_now_oneclk_delay <= 0;
			weight_update_skip <= 0;
			error_class_first <= 0;
			error_class_second <= 0;
			inferenced_class <= 0;
		end else begin
			inferenced_class_valid <= n_inferenced_class_valid;
			error_class_valid <= n_error_class_valid;
			post_spiking_now <= post_spiking_now_oneclk_fast;
			post_spiking_now_oneclk_delay <= post_spiking_now;
			weight_update_skip <= n_weight_update_skip;
			error_class_first <= n_error_class_first;
			error_class_second <= n_error_class_second;
			inferenced_class <= n_inferenced_class;
		end
	end
	always @ (*) begin
		n_weight_update_skip = weight_update_skip;
		n_error_class_first = error_class_first;
		n_error_class_second = error_class_second;
		n_error_class_valid = error_class_valid;
		if (post_spiking_now && fsm_state == STATE_PROCESSING_TRAINING) begin
			n_weight_update_skip = ((binary_classifier_mode == 0 && sames_winner_section_all_vs_this_sample_label == 1) || (binary_classifier_mode == 1 && sames_winner_section_all_binary_vs_this_sample_label == 1));
			n_error_class_first = (binary_classifier_mode == 0) ? this_sample_label : loser_encourage_mode ? loser_in_label_section : (this_sample_label == 1) ? winner_section2 : winner_section1;
			n_error_class_second = (binary_classifier_mode == 0) ? winner_section_all : (this_sample_label == 1) ? winner_section1 : winner_section2;
			n_error_class_valid = 1;
		end
		if (error_class_catch_done_i && error_class_valid) begin 
			n_error_class_valid = 0;
		end
	end
	always @ (*) begin
		n_inferenced_class_valid = inferenced_class_valid;
		n_inferenced_class = inferenced_class;
		if (post_spiking_now_oneclk_delay && inference_fsm_state_oneclk_delay && neuron_this_sample_done_oneclk_delay) begin
			n_inferenced_class_valid = 1;
			n_inferenced_class = (binary_classifier_mode == 0) ? winner_section_all : winner_section_all_binary;
		end
		if (inferenced_class_catch_done_i && inferenced_class_valid) begin 
			n_inferenced_class_valid = 0;
		end
	end
	always @ (*) begin
		case (group_cnt)
			1: begin aer_sliced_aer_array_selected = aer_sliced_aer_array[1];
				aer_sliced_valid_selected = aer_sliced_valid[1];
				aer_sliced_priority_encoder_valid_selected = aer_sliced_priority_encoder_valid[1];
			end
			2: begin aer_sliced_aer_array_selected = aer_sliced_aer_array[2];
				aer_sliced_valid_selected = aer_sliced_valid[2];
				aer_sliced_priority_encoder_valid_selected = aer_sliced_priority_encoder_valid[2];
			end
			3: begin aer_sliced_aer_array_selected = aer_sliced_aer_array[3];
				aer_sliced_valid_selected = aer_sliced_valid[3];
				aer_sliced_priority_encoder_valid_selected = aer_sliced_priority_encoder_valid[3];
			end
			4: begin aer_sliced_aer_array_selected = aer_sliced_aer_array[4];
				aer_sliced_valid_selected = aer_sliced_valid[4];
				aer_sliced_priority_encoder_valid_selected = aer_sliced_priority_encoder_valid[4];
			end
			5: begin aer_sliced_aer_array_selected = aer_sliced_aer_array[5];
				aer_sliced_valid_selected = aer_sliced_valid[5];
				aer_sliced_priority_encoder_valid_selected = aer_sliced_priority_encoder_valid[5];
			end
			6: begin aer_sliced_aer_array_selected = aer_sliced_aer_array[6];
				aer_sliced_valid_selected = aer_sliced_valid[6];
				aer_sliced_priority_encoder_valid_selected = aer_sliced_priority_encoder_valid[6];
			end
			7: begin aer_sliced_aer_array_selected = aer_sliced_aer_array[7];
				aer_sliced_valid_selected = aer_sliced_valid[7];
				aer_sliced_priority_encoder_valid_selected = aer_sliced_priority_encoder_valid[7];
			end
			8: begin aer_sliced_aer_array_selected = aer_sliced_aer_array[8];
				aer_sliced_valid_selected = aer_sliced_valid[8];
				aer_sliced_priority_encoder_valid_selected = aer_sliced_priority_encoder_valid[8];
			end
			9: begin aer_sliced_aer_array_selected = aer_sliced_aer_array[9];
				aer_sliced_valid_selected = aer_sliced_valid[9];
				aer_sliced_priority_encoder_valid_selected = aer_sliced_priority_encoder_valid[9];
			end
			default: begin aer_sliced_aer_array_selected = aer_sliced_aer_array[0];
				aer_sliced_valid_selected = aer_sliced_valid[0];
				aer_sliced_priority_encoder_valid_selected = aer_sliced_priority_encoder_valid[0];
			end
		endcase
	end

	genvar gen_idx2;
	generate
        for (gen_idx2 = 0; gen_idx2 < SET_NUM; gen_idx2 = gen_idx2 + 1) begin : gen_sram_port
			always @ (*) begin
				sram_port1_address[gen_idx2] = aer_sliced_aer_array_selected;
				sram_port1_enable[gen_idx2] = 0;
				sram_port1_write_enable[gen_idx2] = 0;
				sram_port1_write_data[gen_idx2] = {adder_membrane_membrane_update[gen_idx2][0 +: BIT_WIDTH_WEIGHT], 
													adder_membrane_membrane_update[gen_idx2][0 +: BIT_WIDTH_WEIGHT], 
													adder_membrane_membrane_update[gen_idx2][0 +: BIT_WIDTH_WEIGHT], 
													adder_membrane_membrane_update[gen_idx2][0 +: BIT_WIDTH_WEIGHT], 
													adder_membrane_membrane_update[gen_idx2][0 +: BIT_WIDTH_WEIGHT], 
													adder_membrane_membrane_update[gen_idx2][0 +: BIT_WIDTH_WEIGHT], 
													adder_membrane_membrane_update[gen_idx2][0 +: BIT_WIDTH_WEIGHT], 
													adder_membrane_membrane_update[gen_idx2][0 +: BIT_WIDTH_WEIGHT], 
													adder_membrane_membrane_update[gen_idx2][0 +: BIT_WIDTH_WEIGHT], 
													adder_membrane_membrane_update[gen_idx2][0 +: BIT_WIDTH_WEIGHT], 
													adder_membrane_membrane_update[gen_idx2][0 +: BIT_WIDTH_WEIGHT],
													adder_membrane_membrane_update[gen_idx2][0 +: BIT_WIDTH_WEIGHT],
													adder_membrane_membrane_update[gen_idx2][0 +: BIT_WIDTH_WEIGHT],
													adder_membrane_membrane_update[gen_idx2][0 +: BIT_WIDTH_WEIGHT],
													adder_membrane_membrane_update[gen_idx2][0 +: BIT_WIDTH_WEIGHT],
													adder_membrane_membrane_update[gen_idx2][0 +: BIT_WIDTH_WEIGHT],
													adder_membrane_membrane_update[gen_idx2][0 +: BIT_WIDTH_WEIGHT],
													adder_membrane_membrane_update[gen_idx2][0 +: BIT_WIDTH_WEIGHT],
													adder_membrane_membrane_update[gen_idx2][0 +: BIT_WIDTH_WEIGHT],
													adder_membrane_membrane_update[gen_idx2][0 +: BIT_WIDTH_WEIGHT]};

				adder_membrane_weight[gen_idx2] = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_WEIGHT){sram_port1_read_data[gen_idx2][BIT_WIDTH_WEIGHT-1]}}, sram_port1_read_data[gen_idx2]};
				adder_membrane_membrane[gen_idx2] = neuron_membrane[gen_idx2];
				adder_membrane_weight_update_mode[gen_idx2] = 0;
				adder_membrane_small_membrane_update_mode[gen_idx2] = 1;
				neuron_membrane_update[gen_idx2] = adder_membrane_membrane_update[gen_idx2][BIT_WIDTH_MEMBRANE-1:0];
				neuron_membrane_update_valid[gen_idx2] = 0;
				neuron_big_membrane_update[gen_idx2] = adder_membrane_membrane_update[gen_idx2];
				neuron_big_membrane_update_valid[gen_idx2] = 0;

				if (sram_initialize == 0) begin
					if (weight_update_time == 0 && aer_sliced_valid_selected) begin //ff
						sram_port1_address[gen_idx2] = aer_sliced_aer_array_selected;
						sram_port1_enable[gen_idx2] = 1;
						sram_port1_write_enable[gen_idx2] = 0;
					end else if (weight_update_time == 1 && aer_sliced_encoding_on_read_timing_for_wu != 0) begin //wu
						sram_port1_address[gen_idx2] = aer_sliced_aer_array[gen_idx2];
						sram_port1_enable[gen_idx2] = aer_sliced_encoding_on_read_timing_for_wu[gen_idx2];
						sram_port1_write_enable[gen_idx2] = 0;
					end else if (weight_update_time_twoclk_delay == 1 && aer_sliced_encoding_on_twoclk_delay != 0) begin //wu
						sram_port1_address[gen_idx2] = aer_sliced_aer_twoclk_delay_array[gen_idx2];
						sram_port1_enable[gen_idx2] = aer_sliced_encoding_on_twoclk_delay[gen_idx2];
						sram_port1_write_enable[gen_idx2] = 1;
					end

					// membrane update control
					if (post_spiking_now_oneclk_delay && inference_fsm_state_oneclk_delay && neuron_this_sample_done_oneclk_delay) begin
					// if (post_spiking_now_oneclk_delay && neuron_this_sample_done_oneclk_delay) begin
						neuron_big_membrane_update[gen_idx2] = 0;
						neuron_big_membrane_update_valid[gen_idx2] = 1;
					end else if (post_spiking_now && fsm_state == STATE_PROCESSING_INFERENCE) begin
					// end else if (post_spiking_now) begin
						adder_membrane_weight[gen_idx2] = neuron_big_membrane[gen_idx2];
						adder_membrane_weight_update_mode[gen_idx2] = 0;
						adder_membrane_small_membrane_update_mode[gen_idx2] = 0;
						neuron_big_membrane_update[gen_idx2] = adder_membrane_membrane_update[gen_idx2];
						neuron_big_membrane_update_valid[gen_idx2] = 1;
					end else if (weight_update_time_twoclk_delay == 0 && aer_sliced_encoding_on_twoclk_delay[group_cnt_twoclk_delay] && last_spike_this_group_twoclk_delay == 0) begin //ff
						adder_membrane_weight[gen_idx2] = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_WEIGHT){sram_port1_read_data[gen_idx2][BIT_WIDTH_WEIGHT-1]}}, sram_port1_read_data[gen_idx2]};
						adder_membrane_weight_update_mode[gen_idx2] = 0;
						adder_membrane_small_membrane_update_mode[gen_idx2] = 1;
						neuron_membrane_update[gen_idx2] = adder_membrane_membrane_update[gen_idx2][BIT_WIDTH_MEMBRANE-1:0];
						neuron_membrane_update_valid[gen_idx2] = 1;
					end else if (weight_update_time_twoclk_delay == 0 && aer_sliced_encoding_on_twoclk_delay[group_cnt_twoclk_delay] && last_spike_this_group_twoclk_delay == 1) begin //ff
						adder_membrane_weight[gen_idx2] = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_WEIGHT){sram_port1_read_data[gen_idx2][BIT_WIDTH_WEIGHT-1]}}, sram_port1_read_data[gen_idx2]};
						adder_membrane_weight_update_mode[gen_idx2] = 0;
						adder_membrane_small_membrane_update_mode[gen_idx2] = 1;
						neuron_membrane_update[gen_idx2] = adder_membrane_membrane_update_shifted[gen_idx2];
						neuron_membrane_update_valid[gen_idx2] = 1;
					end else if (weight_update_time_twoclk_delay == 0 && aer_sliced_encoding_on_twoclk_delay[group_cnt_twoclk_delay] == 0 && last_spike_this_group_twoclk_delay == 1) begin //ff
						adder_membrane_weight[gen_idx2] = 0;
						adder_membrane_weight_update_mode[gen_idx2] = 0;
						adder_membrane_small_membrane_update_mode[gen_idx2] = 1;
						neuron_membrane_update[gen_idx2] = adder_membrane_membrane_update_shifted[gen_idx2];
						neuron_membrane_update_valid[gen_idx2] = 1;
					end else if (weight_update_time_twoclk_delay == 1 && aer_sliced_encoding_on_twoclk_delay != 0) begin //wu
						adder_membrane_weight[gen_idx2] = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_WEIGHT){sram_port1_read_data[gen_idx2][BIT_WIDTH_WEIGHT-1]}}, sram_port1_read_data[gen_idx2]};
						adder_membrane_weight_update_mode[gen_idx2] = 1;
						adder_membrane_small_membrane_update_mode[gen_idx2] = 0;
						neuron_membrane_update[gen_idx2] = 0;
						neuron_membrane_update_valid[gen_idx2] = 0;
					end

					if (weight_update_time_twoclk_delay) begin 
						if (first_error_propagation_done == 0) begin
							adder_membrane_membrane[gen_idx2] = {{(BIT_WIDTH_MEMBRANE-1){1'b0}}, 1'b1};
						end else begin
							adder_membrane_membrane[gen_idx2] = {{(BIT_WIDTH_MEMBRANE-1){1'b1}}, 1'b1};
						end
					end

				end else begin
					if (config_valid_i) begin
						sram_port1_address[gen_idx2] = config_counter_divide_ten;
						if (gen_idx2 == config_counter_modulo_ten) begin 
							sram_port1_enable[gen_idx2] = 1;
						end else begin
							sram_port1_enable[gen_idx2] = 0;
						end
						sram_port1_write_enable[gen_idx2] = 1;
						sram_port1_write_data[gen_idx2] = config_value[0 +: BIT_WIDTH_SRAM];
					end
				end
			end
		end
	endgenerate
	// ######### MAIN CONTROL #############################################################################
	// ######### MAIN CONTROL #############################################################################
	// ######### MAIN CONTROL #############################################################################
	// ######### MAIN CONTROL #############################################################################
	// ######### MAIN CONTROL #############################################################################
	// ######### MAIN CONTROL #############################################################################





	// ######### COMPARATOR FINAL #############################################################################
	// ######### COMPARATOR FINAL #############################################################################
	// ######### COMPARATOR FINAL #############################################################################
	always @ (*) begin
		comparator_final_variable0 = 0;
		comparator_final_variable1 = 0;
		comparator_final_variable2 = 0;
		comparator_final_variable3 = 0;
		comparator_final_variable4 = 0;
		comparator_final_variable5 = 0;
		comparator_final_variable6 = 0;
		comparator_final_variable7 = 0;
		comparator_final_variable8 = 0;
		comparator_final_variable9 = 0;
		if (post_spiking_now && fsm_state == STATE_PROCESSING_TRAINING) begin
			comparator_final_variable0 = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_MEMBRANE){neuron_membrane[0][BIT_WIDTH_MEMBRANE-1]}}, neuron_membrane[0]};
			comparator_final_variable1 = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_MEMBRANE){neuron_membrane[1][BIT_WIDTH_MEMBRANE-1]}}, neuron_membrane[1]};
			comparator_final_variable2 = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_MEMBRANE){neuron_membrane[2][BIT_WIDTH_MEMBRANE-1]}}, neuron_membrane[2]};
			comparator_final_variable3 = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_MEMBRANE){neuron_membrane[3][BIT_WIDTH_MEMBRANE-1]}}, neuron_membrane[3]};
			comparator_final_variable4 = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_MEMBRANE){neuron_membrane[4][BIT_WIDTH_MEMBRANE-1]}}, neuron_membrane[4]};
			comparator_final_variable5 = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_MEMBRANE){neuron_membrane[5][BIT_WIDTH_MEMBRANE-1]}}, neuron_membrane[5]};
			comparator_final_variable6 = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_MEMBRANE){neuron_membrane[6][BIT_WIDTH_MEMBRANE-1]}}, neuron_membrane[6]};
			comparator_final_variable7 = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_MEMBRANE){neuron_membrane[7][BIT_WIDTH_MEMBRANE-1]}}, neuron_membrane[7]};
			comparator_final_variable8 = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_MEMBRANE){neuron_membrane[8][BIT_WIDTH_MEMBRANE-1]}}, neuron_membrane[8]};
			comparator_final_variable9 = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_MEMBRANE){neuron_membrane[9][BIT_WIDTH_MEMBRANE-1]}}, neuron_membrane[9]};
		end else if (post_spiking_now_oneclk_delay && inference_fsm_state_oneclk_delay && neuron_this_sample_done_oneclk_delay) begin
			comparator_final_variable0 = neuron_big_membrane[0];
			comparator_final_variable1 = neuron_big_membrane[1];
			comparator_final_variable2 = neuron_big_membrane[2];
			comparator_final_variable3 = neuron_big_membrane[3];
			comparator_final_variable4 = neuron_big_membrane[4];
			comparator_final_variable5 = neuron_big_membrane[5];
			comparator_final_variable6 = neuron_big_membrane[6];
			comparator_final_variable7 = neuron_big_membrane[7];
			comparator_final_variable8 = neuron_big_membrane[8];
			comparator_final_variable9 = neuron_big_membrane[9];
		end
	end
	comparator_final#(
		.BIT_WIDTH_BIG_MEMBRANE ( BIT_WIDTH_BIG_MEMBRANE )
	)u_comparator_final(
		.variable0_i        ( comparator_final_variable0        ),
		.variable1_i        ( comparator_final_variable1        ),
		.variable2_i        ( comparator_final_variable2        ),
		.variable3_i        ( comparator_final_variable3        ),
		.variable4_i        ( comparator_final_variable4        ),
		.variable5_i        ( comparator_final_variable5        ),
		.variable6_i        ( comparator_final_variable6        ),
		.variable7_i        ( comparator_final_variable7        ),
		.variable8_i        ( comparator_final_variable8        ),
		.variable9_i        ( comparator_final_variable9        ),
		.winner_section1_o  ( winner_section1  ),
		.winner_section2_o  ( winner_section2  ),
		.winner_section_all_o  ( winner_section_all  ),
		.winner_section_all_binary_o  ( winner_section_all_binary  )
	);
	// ######### COMPARATOR FINAL #############################################################################
	// ######### COMPARATOR FINAL #############################################################################
	// ######### COMPARATOR FINAL #############################################################################




	// ######### COMPARATOR FINAL LOSER #############################################################################
	// ######### COMPARATOR FINAL LOSER #############################################################################
	// ######### COMPARATOR FINAL LOSER #############################################################################
	always @ (*) begin
		comparator_final_loser_variable0 = 0;
		comparator_final_loser_variable1 = 0;
		comparator_final_loser_variable2 = 0;
		comparator_final_loser_variable3 = 0;
		comparator_final_loser_variable4 = 0;
		loser_in_label_section = comparator_final_loser;

		if (loser_encourage_mode) begin
			if (post_spiking_now && fsm_state == STATE_PROCESSING_TRAINING) begin
				if (this_sample_label == 0) begin
					comparator_final_loser_variable0 = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_MEMBRANE){neuron_membrane[0][BIT_WIDTH_MEMBRANE-1]}}, neuron_membrane[0]};
					comparator_final_loser_variable1 = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_MEMBRANE){neuron_membrane[1][BIT_WIDTH_MEMBRANE-1]}}, neuron_membrane[1]};
					comparator_final_loser_variable2 = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_MEMBRANE){neuron_membrane[2][BIT_WIDTH_MEMBRANE-1]}}, neuron_membrane[2]};
					comparator_final_loser_variable3 = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_MEMBRANE){neuron_membrane[3][BIT_WIDTH_MEMBRANE-1]}}, neuron_membrane[3]};
					comparator_final_loser_variable4 = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_MEMBRANE){neuron_membrane[4][BIT_WIDTH_MEMBRANE-1]}}, neuron_membrane[4]};
				end else begin
					comparator_final_loser_variable0 = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_MEMBRANE){neuron_membrane[5][BIT_WIDTH_MEMBRANE-1]}}, neuron_membrane[5]};
					comparator_final_loser_variable1 = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_MEMBRANE){neuron_membrane[6][BIT_WIDTH_MEMBRANE-1]}}, neuron_membrane[6]};
					comparator_final_loser_variable2 = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_MEMBRANE){neuron_membrane[7][BIT_WIDTH_MEMBRANE-1]}}, neuron_membrane[7]};
					comparator_final_loser_variable3 = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_MEMBRANE){neuron_membrane[8][BIT_WIDTH_MEMBRANE-1]}}, neuron_membrane[8]};
					comparator_final_loser_variable4 = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_MEMBRANE){neuron_membrane[9][BIT_WIDTH_MEMBRANE-1]}}, neuron_membrane[9]};
					loser_in_label_section = comparator_final_loser + 5;
				end
			end
		end
	end
	comparator_final_loser#(
		.BIT_WIDTH_BIG_MEMBRANE ( BIT_WIDTH_BIG_MEMBRANE )
	)u_comparator_final_loser(
		.variable0_i ( comparator_final_loser_variable0 ),
		.variable1_i ( comparator_final_loser_variable1 ),
		.variable2_i ( comparator_final_loser_variable2 ),
		.variable3_i ( comparator_final_loser_variable3 ),
		.variable4_i ( comparator_final_loser_variable4 ),
		.loser_o     ( comparator_final_loser     )
	);
	// ######### COMPARATOR FINAL LOSER #############################################################################
	// ######### COMPARATOR FINAL LOSER #############################################################################
	// ######### COMPARATOR FINAL LOSER #############################################################################





	// ############################## CONFIG ##########################################################################################
	// ############################## CONFIG ##########################################################################################
	// ############################## CONFIG ##########################################################################################
	assign do_not_config_now_o = (fsm_state != STATE_CONFIG);
	always @ (*) begin
		sram_initialize = 0;
		n_binary_classifier_mode = binary_classifier_mode;
		n_loser_encourage_mode = loser_encourage_mode;

		if (config_valid_i == 1 && config_done_flag == 0) begin
			if (config_counter == DEPTH_SRAM*SET_NUM) begin
				n_binary_classifier_mode = config_value[0];
				n_loser_encourage_mode = config_value[1];
			end else begin
				sram_initialize = 1;
			end 
		end 
	end
	// ############################## CONFIG ##########################################################################################
	// ############################## CONFIG ##########################################################################################
	// ############################## CONFIG ##########################################################################################

	





	// ############################## SPIKE_BUFFER ##########################################################################################
	// ############################## SPIKE_BUFFER ##########################################################################################
	// ############################## SPIKE_BUFFER ##########################################################################################
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			spike_buffer_past[0] <= 0;
		end else begin
			spike_buffer_past[0] <= n_spike_buffer_past[0];
		end
	end
	// ############################## SPIKE_BUFFER ##########################################################################################
	// ############################## SPIKE_BUFFER ##########################################################################################
	// ############################## SPIKE_BUFFER ##########################################################################################
	



	// ############################## AER_ENCODER ##########################################################################################
	// ############################## AER_ENCODER ##########################################################################################
	// ############################## AER_ENCODER ##########################################################################################
	aer_encoder_layer3_slice10_dual_mode u_aer_encoder_layer3_slice10_dual_mode(
		.clk                     ( clk                     ),
		.reset_n                 ( reset_n                 ),
		.start_i                 ( aer_sliced_encoder_start                 ),
		.encoding_on_i           ( aer_sliced_encoding_on           ),
		.hot_vector_i            ( aer_sliced_hot_vector            ),
		.error_class_i            ( aer_sliced_error_class            ),
		.aer_o                   ( aer_sliced_aer                   ),
		.valid_o                 ( aer_sliced_valid                 ),
		.valid_ffmode_o          ( aer_sliced_valid_ffmode          ),
		.priority_encoder_valid_o          ( aer_sliced_priority_encoder_valid          ),
		.group0_aer_o          ( aer_sliced_group0_aer          ),
		.group0_valid_o          ( aer_sliced_group0_valid          )
	);
	// ############################## AER_ENCODER ##########################################################################################
	// ############################## AER_ENCODER ##########################################################################################
	// ############################## AER_ENCODER ##########################################################################################






	// ############################## SRAM ##########################################################################################
	// ############################## SRAM ##########################################################################################
	// ############################## SRAM ##########################################################################################
	wire software_hardware_check_weight;
	assign sram_sram_port1_address_o = {sram_port1_address[9], sram_port1_address[8], sram_port1_address[7], sram_port1_address[6], sram_port1_address[5], sram_port1_address[4], sram_port1_address[3], sram_port1_address[2], sram_port1_address[1], sram_port1_address[0]};
	assign sram_sram_port1_enable_o = {sram_port1_enable[9], sram_port1_enable[8], sram_port1_enable[7], sram_port1_enable[6], sram_port1_enable[5], sram_port1_enable[4], sram_port1_enable[3], sram_port1_enable[2], sram_port1_enable[1], sram_port1_enable[0]};
	assign sram_sram_port1_write_enable_o = {sram_port1_write_enable[9], sram_port1_write_enable[8], sram_port1_write_enable[7], sram_port1_write_enable[6], sram_port1_write_enable[5], sram_port1_write_enable[4], sram_port1_write_enable[3], sram_port1_write_enable[2], sram_port1_write_enable[1], sram_port1_write_enable[0]};
	assign sram_sram_port1_write_data_o = {sram_port1_write_data[9], sram_port1_write_data[8], sram_port1_write_data[7], sram_port1_write_data[6], sram_port1_write_data[5], sram_port1_write_data[4], sram_port1_write_data[3], sram_port1_write_data[2], sram_port1_write_data[1], sram_port1_write_data[0]};
	assign sram_sram_software_hardware_check_weight_o = software_hardware_check_weight;
	assign n_sram_port1_read_data[9] = sram_sram_port1_read_data_i[BIT_WIDTH_SRAM*9 +: BIT_WIDTH_SRAM];
	assign n_sram_port1_read_data[8] = sram_sram_port1_read_data_i[BIT_WIDTH_SRAM*8 +: BIT_WIDTH_SRAM];
	assign n_sram_port1_read_data[7] = sram_sram_port1_read_data_i[BIT_WIDTH_SRAM*7 +: BIT_WIDTH_SRAM];
	assign n_sram_port1_read_data[6] = sram_sram_port1_read_data_i[BIT_WIDTH_SRAM*6 +: BIT_WIDTH_SRAM];
	assign n_sram_port1_read_data[5] = sram_sram_port1_read_data_i[BIT_WIDTH_SRAM*5 +: BIT_WIDTH_SRAM];
	assign n_sram_port1_read_data[4] = sram_sram_port1_read_data_i[BIT_WIDTH_SRAM*4 +: BIT_WIDTH_SRAM];
	assign n_sram_port1_read_data[3] = sram_sram_port1_read_data_i[BIT_WIDTH_SRAM*3 +: BIT_WIDTH_SRAM];
	assign n_sram_port1_read_data[2] = sram_sram_port1_read_data_i[BIT_WIDTH_SRAM*2 +: BIT_WIDTH_SRAM];
	assign n_sram_port1_read_data[1] = sram_sram_port1_read_data_i[BIT_WIDTH_SRAM*1 +: BIT_WIDTH_SRAM];
	assign n_sram_port1_read_data[0] = sram_sram_port1_read_data_i[BIT_WIDTH_SRAM*0 +: BIT_WIDTH_SRAM];
	// ############################## SRAM ##########################################################################################
	// ############################## SRAM ##########################################################################################
	// ############################## SRAM ##########################################################################################







	// ############################## SRAM REGISTERNG ##########################################################################################
	// ############################## SRAM REGISTERNG ##########################################################################################
	// ############################## SRAM REGISTERNG ##########################################################################################
	genvar gen_idx7;
	generate
        for (gen_idx7 = 0; gen_idx7 < SET_NUM; gen_idx7 = gen_idx7 + 1) begin : gen_sram_registering
			always @(posedge clk or negedge reset_n) begin
				if (!reset_n) begin
					sram_port1_read_data[gen_idx7] <= 0;
				end else if (sram_port1_read_data_registering_singal[gen_idx7]) begin
					sram_port1_read_data[gen_idx7] <= n_sram_port1_read_data[gen_idx7];
				end
			end
			always @(posedge clk or negedge reset_n) begin
				if (!reset_n) begin
					sram_port1_read_data_registering_singal[gen_idx7] <= 0;
				end else begin
					sram_port1_read_data_registering_singal[gen_idx7] <= (sram_port1_enable[gen_idx7] == 1) && (sram_port1_write_enable[gen_idx7] == 0);
				end
			end
		end
	endgenerate
	// ############################## SRAM REGISTERNG ##########################################################################################
	// ############################## SRAM REGISTERNG ##########################################################################################
	// ############################## SRAM REGISTERNG ##########################################################################################






	// ############################## NEURON ##########################################################################################
	// ############################## NEURON ##########################################################################################
	// ############################## NEURON ##########################################################################################
	neuron_allset_layer3#(
		.BIT_WIDTH_MEMBRANE          ( BIT_WIDTH_MEMBRANE ),
		.BIT_WIDTH_BIG_MEMBRANE      ( BIT_WIDTH_BIG_MEMBRANE ),
		.CLASSIFIER_SIZE             ( CLASSIFIER_SIZE )
	)u_neuron_allset_layer3(
		.clk                         ( clk                         ),
		.reset_n                     ( reset_n                     ),
		.post_spiking_now_i          ( post_spiking_now          ),
		.membrane_update_i           ( {neuron_membrane_update[9], neuron_membrane_update[8], neuron_membrane_update[7], neuron_membrane_update[6], neuron_membrane_update[5], neuron_membrane_update[4], neuron_membrane_update[3], neuron_membrane_update[2], neuron_membrane_update[1], neuron_membrane_update[0]}           ),
		.membrane_update_valid_i     ( {neuron_membrane_update_valid[9], neuron_membrane_update_valid[8], neuron_membrane_update_valid[7], neuron_membrane_update_valid[6], neuron_membrane_update_valid[5], neuron_membrane_update_valid[4], neuron_membrane_update_valid[3], neuron_membrane_update_valid[2], neuron_membrane_update_valid[1], neuron_membrane_update_valid[0]}     ),
		.membrane_o                  ( {neuron_membrane[9], neuron_membrane[8], neuron_membrane[7], neuron_membrane[6], neuron_membrane[5], neuron_membrane[4], neuron_membrane[3], neuron_membrane[2], neuron_membrane[1], neuron_membrane[0]}    ),
		.big_membrane_update_i       ( {neuron_big_membrane_update[9], neuron_big_membrane_update[8], neuron_big_membrane_update[7], neuron_big_membrane_update[6], neuron_big_membrane_update[5], neuron_big_membrane_update[4], neuron_big_membrane_update[3], neuron_big_membrane_update[2], neuron_big_membrane_update[1], neuron_big_membrane_update[0]}       ),
		.big_membrane_update_valid_i ( {neuron_big_membrane_update_valid[9], neuron_big_membrane_update_valid[8], neuron_big_membrane_update_valid[7], neuron_big_membrane_update_valid[6], neuron_big_membrane_update_valid[5], neuron_big_membrane_update_valid[4], neuron_big_membrane_update_valid[3], neuron_big_membrane_update_valid[2], neuron_big_membrane_update_valid[1], neuron_big_membrane_update_valid[0]} ),
		.big_membrane_o              ( {neuron_big_membrane[9], neuron_big_membrane[8], neuron_big_membrane[7], neuron_big_membrane[6], neuron_big_membrane[5], neuron_big_membrane[4], neuron_big_membrane[3], neuron_big_membrane[2], neuron_big_membrane[1], neuron_big_membrane[0]}              )
	);
	// ############################## NEURON ##########################################################################################
	// ############################## NEURON ##########################################################################################
	// ############################## NEURON ##########################################################################################







	// ############################## ADDER ##########################################################################################
	// ############################## ADDER ##########################################################################################
	// ############################## ADDER ##########################################################################################
	genvar k;
	generate
        for (k = 0; k < SET_NUM; k = k + 1) begin : gen_adder_membrane_set
			adder_membrane_layer3#(
				.BIT_WIDTH_WEIGHT             ( BIT_WIDTH_WEIGHT ),
				.BIT_WIDTH_MEMBRANE           ( BIT_WIDTH_MEMBRANE ),
				.BIT_WIDTH_BIG_MEMBRANE       ( BIT_WIDTH_BIG_MEMBRANE )
			)u_adder_membrane_layer3(
				.weight_i                     ( adder_membrane_weight[k]                     ),
				.membrane_i                   ( adder_membrane_membrane[k]                   ),
				.weight_update_mode_i         ( adder_membrane_weight_update_mode[k]         ),
				.small_membrane_update_mode_i ( adder_membrane_small_membrane_update_mode[k] ),
				.membrane_update_o            ( adder_membrane_membrane_update[k]            )
			);
		end
	endgenerate
	// ############################## ADDER ##########################################################################################
	// ############################## ADDER ##########################################################################################
	// ############################## ADDER ##########################################################################################




	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			aer_sliced_encoding_on_oneclk_delay <= 0;
			aer_sliced_aer_oneclk_delay <= 0;
			last_spike_this_group_oneclk_delay <= 0;
			group_cnt_oneclk_delay <= 0;

			aer_sliced_encoding_on_twoclk_delay <= 0;
			aer_sliced_aer_twoclk_delay <= 0;
			last_spike_this_group_twoclk_delay <= 0;
			group_cnt_twoclk_delay <= 0;

			neuron_this_sample_done_oneclk_delay <= 0;
		end else begin
			aer_sliced_encoding_on_oneclk_delay <= aer_sliced_encoding_on;
			aer_sliced_aer_oneclk_delay <= aer_sliced_aer;
			last_spike_this_group_oneclk_delay <= last_spike_this_group;
			group_cnt_oneclk_delay <= group_cnt;
			
			aer_sliced_encoding_on_twoclk_delay <= aer_sliced_encoding_on_oneclk_delay;
			aer_sliced_aer_twoclk_delay <= aer_sliced_aer_oneclk_delay;
			last_spike_this_group_twoclk_delay <= last_spike_this_group_oneclk_delay;
			group_cnt_twoclk_delay <= group_cnt_oneclk_delay;

			neuron_this_sample_done_oneclk_delay <= neuron_this_sample_done;
		end
	end
	genvar gen_idx9;
	generate
        for (gen_idx9 = 0; gen_idx9 < SET_NUM; gen_idx9 = gen_idx9 + 1) begin : gen_aer_sliced_aer_array
			assign aer_sliced_aer_array[gen_idx9] = aer_sliced_aer[gen_idx9*BIT_WIDTH_ADDRESS +: BIT_WIDTH_ADDRESS];
			assign aer_sliced_aer_twoclk_delay_array[gen_idx9] = aer_sliced_aer_twoclk_delay[gen_idx9*BIT_WIDTH_ADDRESS +: BIT_WIDTH_ADDRESS];
		end
	endgenerate





	// ########### COLUMN HANDLER (DEPRECATED) #########################################################################################
	// ########### COLUMN HANDLER (DEPRECATED) #########################################################################################
	// ########### COLUMN HANDLER (DEPRECATED) #########################################################################################
	// // column_handler O
	// column_handler #( // 5151.257976
	// 	.BIT_WIDTH_SRAM         ( BIT_WIDTH_SRAM ),
	// 	.SET_NUM                ( SET_NUM )
	// )u_column_handler(
	// 	.sram_port1_read_data_i ( {sram_port1_read_data[9], sram_port1_read_data[8], sram_port1_read_data[7], sram_port1_read_data[6], sram_port1_read_data[5], sram_port1_read_data[4], sram_port1_read_data[3], sram_port1_read_data[2], sram_port1_read_data[1], sram_port1_read_data[0]} ),
	// 	.select_i               ( error_class_first_i              ),
	// 	.sram_port1_read_data_shaked_o  ( {sram_port1_read_data_shaked[9], sram_port1_read_data_shaked[8], sram_port1_read_data_shaked[7], sram_port1_read_data_shaked[6], sram_port1_read_data_shaked[5], sram_port1_read_data_shaked[4], sram_port1_read_data_shaked[3], sram_port1_read_data_shaked[2], sram_port1_read_data_shaked[1], sram_port1_read_data_shaked[0]} )
	// );

	// // column_handler X
	// assign sram_port1_read_data_shaked[0] = sram_port1_read_data[0];
	// assign sram_port1_read_data_shaked[1] = sram_port1_read_data[1];
	// assign sram_port1_read_data_shaked[2] = sram_port1_read_data[2];
	// assign sram_port1_read_data_shaked[3] = sram_port1_read_data[3];
	// assign sram_port1_read_data_shaked[4] = sram_port1_read_data[4];
	// assign sram_port1_read_data_shaked[5] = sram_port1_read_data[5];
	// assign sram_port1_read_data_shaked[6] = sram_port1_read_data[6];
	// assign sram_port1_read_data_shaked[7] = sram_port1_read_data[7];
	// assign sram_port1_read_data_shaked[8] = sram_port1_read_data[8];
	// assign sram_port1_read_data_shaked[9] = sram_port1_read_data[9];
	// ########### COLUMN HANDLER (DEPRECATED) #########################################################################################
	// ########### COLUMN HANDLER (DEPRECATED) #########################################################################################
	// ########### COLUMN HANDLER (DEPRECATED) #########################################################################################
	
	




	assign adder_membrane_membrane_update_shifted[0] = adder_membrane_membrane_update[9][BIT_WIDTH_MEMBRANE-1:0];
	assign adder_membrane_membrane_update_shifted[1] = adder_membrane_membrane_update[0][BIT_WIDTH_MEMBRANE-1:0];
	assign adder_membrane_membrane_update_shifted[2] = adder_membrane_membrane_update[1][BIT_WIDTH_MEMBRANE-1:0];
	assign adder_membrane_membrane_update_shifted[3] = adder_membrane_membrane_update[2][BIT_WIDTH_MEMBRANE-1:0];
	assign adder_membrane_membrane_update_shifted[4] = adder_membrane_membrane_update[3][BIT_WIDTH_MEMBRANE-1:0];
	assign adder_membrane_membrane_update_shifted[5] = adder_membrane_membrane_update[4][BIT_WIDTH_MEMBRANE-1:0];
	assign adder_membrane_membrane_update_shifted[6] = adder_membrane_membrane_update[5][BIT_WIDTH_MEMBRANE-1:0];
	assign adder_membrane_membrane_update_shifted[7] = adder_membrane_membrane_update[6][BIT_WIDTH_MEMBRANE-1:0];
	assign adder_membrane_membrane_update_shifted[8] = adder_membrane_membrane_update[7][BIT_WIDTH_MEMBRANE-1:0];
	assign adder_membrane_membrane_update_shifted[9] = adder_membrane_membrane_update[8][BIT_WIDTH_MEMBRANE-1:0];



	assign weight_update_skip_o = weight_update_skip;
	assign error_class_first_o = error_class_first;
	assign error_class_second_o = error_class_second;
	assign error_class_valid_o = error_class_valid;

	assign inferenced_class_o = inferenced_class;
	assign inferenced_class_valid_o = inferenced_class_valid;



	// ########################## FOR TEST ########################################################################################
	// ########################## FOR TEST ########################################################################################
	// ########################## FOR TEST ########################################################################################
	// ########################## FOR TEST ########################################################################################
	// ########################## FOR TEST ########################################################################################
	`ifdef FUNC_VERI
		wire post_spiking_now_oneclk_delay_for_tb;
		assign post_spiking_now_oneclk_delay_for_tb = post_spiking_now_oneclk_delay;

		reg [BIT_WIDTH_FSM-1:0] fsm_state_oneclk_delay_for_tb;
		always @(posedge clk or negedge reset_n) begin
			if (!reset_n) begin
				fsm_state_oneclk_delay_for_tb <= 0;
			end else begin
				fsm_state_oneclk_delay_for_tb <= fsm_state;
			end
		end

		// assign software_hardware_check_weight = neuron_surrogate_read_finish;
		assign software_hardware_check_weight = post_spiking_now_oneclk_delay_for_tb;


		integer txt_idx1_0, txt_idx1_1;
		integer fd1;
		reg signed [BIT_WIDTH_MEMBRANE-1:0] value1;
		wire software_hardware_check_membrane;
		assign software_hardware_check_membrane = post_spiking_now;
		integer timestep_counter_check_membrane;
		initial timestep_counter_check_membrane = 0;
		always @(negedge clk) begin
			if (software_hardware_check_membrane) begin
				if (timestep_counter_check_membrane >= 0) begin

					
					fd1 = $fopen($sformatf("../test_vector/sweep_mode/zz_tb_vector_layer3_hw/tb_output_activation%0d.txt", timestep_counter_check_membrane-0), "w");



					for (txt_idx1_0 = 0; txt_idx1_0 < SET_NUM; txt_idx1_0 = txt_idx1_0 + 1) begin
						for (txt_idx1_1 = 0; txt_idx1_1 < NEURON_NUM_IN_SET; txt_idx1_1 = txt_idx1_1 + 1) begin
							value1 = neuron_membrane[txt_idx1_0][BIT_WIDTH_MEMBRANE*txt_idx1_1 +: BIT_WIDTH_MEMBRANE];
							$fwrite(fd1, "%0d", value1);
							$fwrite(fd1, "\n");
						end
					end
					$fclose(fd1);
				end
				timestep_counter_check_membrane <= timestep_counter_check_membrane + 1;
			end
			// if (timestep_counter_check_membrane >= (`FUNC_VERI)) $finish;

		end


		integer txt_idx2_0, txt_idx2_1;
		integer fd2;
		reg signed [BIT_WIDTH_BIG_MEMBRANE-1:0] value2;
		wire software_hardware_check_membrane_reset;
		assign software_hardware_check_membrane_reset = post_spiking_now_oneclk_delay_for_tb && inference_fsm_state_oneclk_delay;
		integer timestep_counter_check_membrane_reset;
		initial timestep_counter_check_membrane_reset = 0;
		always @(negedge clk) begin
			if (software_hardware_check_membrane_reset) begin
				if (timestep_counter_check_membrane_reset >= 0) begin

					fd2 = $fopen($sformatf("../test_vector/sweep_mode/zz_tb_vector_layer3_hw/tb_output_activation_accumul%0d.txt", timestep_counter_check_membrane_reset-0), "w");


					for (txt_idx2_0 = 0; txt_idx2_0 < SET_NUM; txt_idx2_0 = txt_idx2_0 + 1) begin
						for (txt_idx2_1 = 0; txt_idx2_1 < NEURON_NUM_IN_SET; txt_idx2_1 = txt_idx2_1 + 1) begin
							value2 = neuron_big_membrane[txt_idx2_0][BIT_WIDTH_BIG_MEMBRANE*txt_idx2_1 +: BIT_WIDTH_BIG_MEMBRANE];
							$fwrite(fd2, "%0d", value2);
							$fwrite(fd2, "\n");
						end
					end
					$fclose(fd2);
				end
				timestep_counter_check_membrane_reset <= timestep_counter_check_membrane_reset + 1;
			end
				// if (timestep_counter_check_membrane_reset >= (`FUNC_VERI)) $finish;

		end


		`ifdef INFERENCE_ONLY
		`else
			integer txt_idx_err_0;
			integer fd_error;
			reg [1:0] value_error;
			wire software_hardware_check_error;
			assign software_hardware_check_error = post_spiking_now_oneclk_delay_for_tb  && fsm_state_oneclk_delay_for_tb == STATE_PROCESSING_TRAINING;
			integer timestep_counter_check_error;
			initial timestep_counter_check_error = 0;
			always @(negedge clk) begin
				if (software_hardware_check_error) begin
					if (timestep_counter_check_error >= 0) begin

						

						fd_error = $fopen($sformatf("../test_vector/sweep_mode/zz_tb_vector_layer3_hw/tb_error%0d.txt", timestep_counter_check_error-0), "w");


						for (txt_idx_err_0 = 0; txt_idx_err_0 < SET_NUM; txt_idx_err_0 = txt_idx_err_0 + 1) begin
							if (weight_update_skip == 1) begin
								value_error = 0;
							end else begin
								if (txt_idx_err_0 == error_class_first) begin
									value_error = 1;
								end else if (txt_idx_err_0 == error_class_second) begin
									value_error = 2;
								end else begin
									value_error = 0;
								end
							end
							$fwrite(fd_error, "%0d", value_error);
							$fwrite(fd_error, " ");
						end
						$fwrite(fd_error, "\n");
						$fclose(fd_error);
					end
					timestep_counter_check_error <= timestep_counter_check_error + 1;
				end
				// if (timestep_counter_check_error >= (`FUNC_VERI)) $finish;

			end
		`endif



		`ifdef INFERENCE_ONLY
			integer txt_idx_inf_label;
			integer fd_inf_label;
			wire software_hardware_check_label;
			assign software_hardware_check_label = inferenced_class_valid_o && inferenced_class_catch_done_i;
			integer timestep_counter_check_label;
			initial timestep_counter_check_label = 0;
			always @(negedge clk) begin
				if (software_hardware_check_label) begin
					if (timestep_counter_check_label >= 0) begin
						

						fd_inf_label = $fopen($sformatf("../test_vector/inference_only/zz_tb_vector_layer3_hw/tb_label%0d.txt", timestep_counter_check_label-0), "w");

						$fwrite(fd_inf_label, "%0d", inferenced_class_o);
						$fwrite(fd_inf_label, "\n");
						$fclose(fd_inf_label);
					end
					timestep_counter_check_label <= timestep_counter_check_label + 1;
				end
				// if (timestep_counter_check_label >= (`FUNC_VERI)) $finish;

			end
		`else
			`ifdef SWEEP_MODE
				integer txt_idx_inf_label;
				integer fd_inf_label;
				wire software_hardware_check_label;
				assign software_hardware_check_label = inferenced_class_valid_o && inferenced_class_catch_done_i;
				integer timestep_counter_check_label;
				initial timestep_counter_check_label = 0;
				always @(negedge clk) begin
					if (software_hardware_check_label) begin
						if (timestep_counter_check_label >= 0) begin

							fd_inf_label = $fopen($sformatf("../test_vector/sweep_mode/zz_tb_vector_layer3_hw/tb_inferenced_label%0d.txt", timestep_counter_check_label-0), "w");

							$fwrite(fd_inf_label, "%0d", inferenced_class_o);
							$fwrite(fd_inf_label, "\n");
							$fclose(fd_inf_label);
						end
						timestep_counter_check_label <= timestep_counter_check_label + 1;
					end
					// if (timestep_counter_check_label >= (`FUNC_VERI)) $finish;
				end

			`else

			`endif
		`endif

		

	// ########################## FOR TEST ########################################################################################
	// ########################## FOR TEST ########################################################################################
	// ########################## FOR TEST ########################################################################################
	// ########################## FOR TEST ########################################################################################
	// ########################## FOR TEST ########################################################################################

	`else
		assign software_hardware_check_weight = 0;
	`endif

endmodule




// 5589.056182