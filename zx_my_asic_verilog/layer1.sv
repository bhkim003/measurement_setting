module layer1 #( 
	parameter       BIT_WIDTH_WEIGHT         = 8,  
    parameter       BIT_WIDTH_MEMBRANE       = 17,

	parameter       BIT_WIDTH_SURROGATE       = 3,
	parameter       DEPTH_SURROGATE_BOX       = 2,

	parameter       BIT_WIDTH_SRAM         = 160,  
	parameter       DEPTH_SRAM             = 980,
	parameter       BIT_WIDTH_ADDRESS      = 10,

	parameter       BIT_WIDTH_DELTA_WEIGHT       = 4,

	parameter       NEURON_NUM_IN_SET = 20,
	parameter       SET_NUM = 10,

	parameter       INPUT_SIZE = 980,
	parameter       OUTPUT_SIZE = 200,
	parameter 		SPIKE_BUFFER_PAST_SIZE = 3,

	parameter       BIT_WIDTH_FSM = 2,

	parameter       BIT_WIDTH_CONFIG_COUNTER = 14
    )(
		input clk,
		input reset_n,

		input config_valid_i,
		output do_not_config_now_o,
		
		input [INPUT_SIZE-1:0] input_spike_i,
		input input_setting_done_i,
		input error_setting_done_i,
		input this_sample_done_i,
		input this_epoch_finish_i,
		
		output reg input_setting_catch_ready_o,
		output reg error_setting_catch_ready_o,

		output start_ready_o,
		input training_start_flag_i,
		input inference_start_flag_i,

		input weight_update_skip_i,
		input [3:0] error_class_first_i,
		input [3:0] error_class_second_i,
		
		input post_spike_catch_done_i,
		output [OUTPUT_SIZE-1:0] post_spike_o,
		output post_spike_valid_o,


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
	assign config_value = input_spike_i[BIT_WIDTH_SRAM-1:0];
	reg config_done_flag, n_config_done_flag;
	reg sram_initialize;
	reg [BIT_WIDTH_CONFIG_COUNTER-1:0] config_counter, n_config_counter;
	reg [3:0] config_counter_modulo_ten, n_config_counter_modulo_ten;
	reg [9:0] config_counter_divide_ten, n_config_counter_divide_ten;

	reg go_to_config_state;
	reg epoch_first_step, n_epoch_first_step;

	// ######### FSM #############################################################################
	// ######### FSM #############################################################################
	// ######### FSM #############################################################################
	reg [BIT_WIDTH_FSM-1:0] fsm_state, n_fsm_state;
	reg training_fsm_state_oneclk_delay;
	assign start_ready_o = (fsm_state == STATE_CONFIG) && (config_counter == 0);
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			fsm_state <= STATE_CONFIG;
            training_fsm_state_oneclk_delay <= 0;
            config_done_flag <= 0;
            config_counter <= 0;
            config_counter_modulo_ten <= 0;
            config_counter_divide_ten <= 0;
		end else begin
			fsm_state <= n_fsm_state;
            training_fsm_state_oneclk_delay <= (fsm_state == STATE_PROCESSING_TRAINING);
            config_done_flag <= n_config_done_flag;
            config_counter <= n_config_counter;
            config_counter_modulo_ten <= n_config_counter_modulo_ten;
            config_counter_divide_ten <= n_config_counter_divide_ten;
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
					if (config_counter != DEPTH_SRAM*SET_NUM + 2) begin
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
 
	wire signed [BIT_WIDTH_MEMBRANE-1:0] neuron_threshold;
	reg [BIT_WIDTH_MEMBRANE*NEURON_NUM_IN_SET-1:0] neuron_membrane_update [0:SET_NUM-1];
	reg [SET_NUM-1:0] neuron_membrane_update_valid;
	reg neuron_this_sample_done, n_neuron_this_sample_done;
	reg neuron_this_sample_done_oneclk_delay;
	reg this_epoch_finish, n_this_epoch_finish;
	reg neuron_surrogate_compute_time, n_neuron_surrogate_compute_time;
	wire [BIT_WIDTH_SURROGATE-1:0] neuron_surrogate_ref;
	wire [BIT_WIDTH_MEMBRANE*NEURON_NUM_IN_SET-1:0] neuron_membrane [0:SET_NUM-1];
	wire [SET_NUM*NEURON_NUM_IN_SET-1:0] neuron_post_spike;
	wire [BIT_WIDTH_SURROGATE*NEURON_NUM_IN_SET-1:0] neuron_surrogate [0:SET_NUM-1];
	reg [BIT_WIDTH_SURROGATE-1:0] neuron_surrogate_ref_reg [0:14];
	reg [BIT_WIDTH_SURROGATE-1:0] n_neuron_surrogate_ref_reg [0:14];

	reg [BIT_WIDTH_WEIGHT*NEURON_NUM_IN_SET-1:0] adder_membrane_weight [0:SET_NUM-1];
	reg [BIT_WIDTH_MEMBRANE*NEURON_NUM_IN_SET-1:0] adder_membrane_membrane [0:SET_NUM-1];
	reg [SET_NUM-1:0] adder_membrane_weight_update_mode;
	wire [BIT_WIDTH_MEMBRANE*NEURON_NUM_IN_SET-1:0] adder_membrane_membrane_update [0:SET_NUM-1];
	wire [BIT_WIDTH_MEMBRANE*NEURON_NUM_IN_SET-1:0] adder_membrane_membrane_update_shifted [0:SET_NUM-1];

	reg signed [BIT_WIDTH_DELTA_WEIGHT-1:0] adder_weight_update_delta_weight_array [0:NEURON_NUM_IN_SET-1];
	reg [BIT_WIDTH_SURROGATE-1:0] adder_weight_update_delta_weight_array_second [0:NEURON_NUM_IN_SET-1];
	wire signed [BIT_WIDTH_DELTA_WEIGHT-1:0] adder_weight_update_delta_weight_array_before_negate [0:NEURON_NUM_IN_SET-1];
	
	reg [INPUT_SIZE-1:0] spike_buffer_past [0:SPIKE_BUFFER_PAST_SIZE-1];
	reg [INPUT_SIZE-1:0] n_spike_buffer_past [0:SPIKE_BUFFER_PAST_SIZE-1];
	reg spike_buffer_move_flag;

	reg signed [BIT_WIDTH_MEMBRANE-1:0] surrogate_x_cut [0:14];
	reg signed [BIT_WIDTH_MEMBRANE-1:0] n_surrogate_x_cut [0:14];

	reg [3:0] surrogate_cnt, n_surrogate_cnt;

	reg neuron_surrogate_read_finish;
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

	reg surrogate_change_to_second;


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
	reg post_spiking_now_oneclk_fast;
	
	reg post_spike_valid, n_post_spike_valid;
	wire surrogate_cnt_zero;
	assign surrogate_cnt_zero = (surrogate_cnt == 0);
	wire surrogate_cnt_fourteen;
	assign surrogate_cnt_fourteen = (surrogate_cnt == 14);

	reg need_to_catch_spike_at_wu, n_need_to_catch_spike_at_wu;

	reg [BIT_WIDTH_ADDRESS-1:0] write_group0_last_address, n_write_group0_last_address;
	reg write_group0_last_address_valid, n_write_group0_last_address_valid;


	wire input_setting_done;
	wire error_setting_done;
	assign input_setting_done = input_setting_done_i && (input_setting_catch_ready_o == 0);
	assign error_setting_done = error_setting_done_i && (error_setting_catch_ready_o == 0);
	// assign input_setting_done = input_setting_done_i;
	// assign error_setting_done = error_setting_done_i;

	reg input_setting_catch_ready_oneclk_fast;
	reg error_setting_catch_ready_oneclk_fast;
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			input_setting_catch_ready_o <= 0;
			error_setting_catch_ready_o <= 0;
		end else begin
            input_setting_catch_ready_o <= input_setting_catch_ready_oneclk_fast;
            error_setting_catch_ready_o <= error_setting_catch_ready_oneclk_fast;
		end
	end

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
		error_setting_catch_ready_oneclk_fast = 0;

		neuron_surrogate_read_finish = 0;
		spike_buffer_move_flag = 0;
		n_read_zero_write_one = read_zero_write_one;

		aer_sliced_encoder_start = 0;
		aer_sliced_encoding_on = 10'b0;
		aer_sliced_hot_vector = spike_buffer_past[0];

		aer_sliced_encoding_on_read_timing_for_wu = 0;

		n_spike_buffer_past[0] = spike_buffer_past[0];

		n_weight_update_time = weight_update_time;
		n_first_error_propagation_done = first_error_propagation_done;

		aer_sliced_error_class = 0;

		surrogate_change_to_second = 0;

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
						n_this_epoch_finish = this_epoch_finish_i;
						n_need_to_catch_spike_at_wu = 0;
						spike_buffer_move_flag = 1;
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

								surrogate_change_to_second = 1;

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
								n_this_epoch_finish = this_epoch_finish_i;
								n_need_to_catch_spike_at_wu = 0;
								spike_buffer_move_flag = 1;
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
								if ((post_spike_valid == 0 && (neuron_surrogate_compute_time == 0)) || neuron_surrogate_read_finish_have_been2) begin

									if (neuron_surrogate_read_finish_have_been2 == 0) begin
										post_spiking_now_oneclk_fast = 1; 
									end

									if (error_setting_done) begin
										if (neuron_surrogate_read_finish_have_been == 0) begin
											neuron_surrogate_read_finish = 1; 
										end
										
										if (this_epoch_finish) begin
											go_to_config_state = 1;
											n_epoch_first_step = 1;

											n_need_to_catch_spike_at_wu = (weight_update_skip_i == 0);
											error_setting_catch_ready_oneclk_fast = 1;

											// n_neuron_surrogate_read_finish_have_been = 0; 
											n_neuron_surrogate_read_finish_have_been2 = 0;
											n_group_cnt = 0;
											n_read_wait_done = 0;

											// aer_sliced_hot_vector = spike_buffer_past[SPIKE_BUFFER_PAST_SIZE-1];
											// aer_sliced_encoder_start = 1;
											// aer_sliced_error_class = error_class_first_i; 
											
											n_error_class_first_save = error_class_first_i;
											n_error_class_second_save = error_class_second_i;
											n_weight_update_time = 0; 
											// spike_buffer_move_flag = 0;
											
										end else begin
											n_epoch_first_step = 0;

											if (weight_update_skip_i) begin
												if (input_setting_done) begin
													input_setting_catch_ready_oneclk_fast = 1;
													error_setting_catch_ready_oneclk_fast = 1;
													n_spike_buffer_past[0] = input_spike_i;
													n_neuron_surrogate_read_finish_have_been = 0;
													n_neuron_surrogate_read_finish_have_been2 = 0;
													n_group_cnt = 0;
													n_read_wait_done = 0;

													aer_sliced_hot_vector = input_spike_i;
													aer_sliced_encoder_start = 1;
													aer_sliced_error_class = 0;
													n_neuron_this_sample_done = this_sample_done_i;
													n_this_epoch_finish = this_epoch_finish_i;

													// n_error_class_first_save = error_class_first_i;
													// n_error_class_second_save = error_class_second_i;
													n_weight_update_time = 0;
													spike_buffer_move_flag = 1;

												end else begin
													n_neuron_surrogate_read_finish_have_been = 1;
													n_neuron_surrogate_read_finish_have_been2 = 1;
												end
											end else begin
												n_need_to_catch_spike_at_wu = 1;
												error_setting_catch_ready_oneclk_fast = 1;

												// n_neuron_surrogate_read_finish_have_been = 0; 
												n_neuron_surrogate_read_finish_have_been2 = 0;
												n_group_cnt = 0;
												n_read_wait_done = 0;

												aer_sliced_hot_vector = spike_buffer_past[SPIKE_BUFFER_PAST_SIZE-1];
												aer_sliced_encoder_start = 1;
												aer_sliced_error_class = error_class_first_i;

												n_error_class_first_save = error_class_first_i;
												n_error_class_second_save = error_class_second_i;
												n_weight_update_time = 1;
												// spike_buffer_move_flag = 0; 
											end
										end
									end else begin
										n_neuron_surrogate_read_finish_have_been2 = 1;
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
					// spike_buffer_move_flag = 1; 
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
						if (post_spike_valid == 0 || neuron_surrogate_read_finish_have_been2) begin

							if (neuron_surrogate_read_finish_have_been2 == 0) begin
								post_spiking_now_oneclk_fast = 1; 
							end
							
							if (this_epoch_finish) begin
								go_to_config_state = 1;
								n_epoch_first_step = 1;

								// n_neuron_surrogate_read_finish_have_been = 0;
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
								end else begin
									n_neuron_surrogate_read_finish_have_been2 = 1;
								end
							end
						end
					end
				end
			end
		end
    end

	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			surrogate_cnt <= 0;
			neuron_surrogate_compute_time <= 0;
			post_spike_valid <= 0;
			post_spiking_now <= 0;
		end else begin
			surrogate_cnt <= n_surrogate_cnt;
			neuron_surrogate_compute_time <= n_neuron_surrogate_compute_time;
			post_spike_valid <= n_post_spike_valid;
			post_spiking_now <= post_spiking_now_oneclk_fast;
		end
	end
	always @ (*) begin
		n_surrogate_cnt = surrogate_cnt;
		n_neuron_surrogate_compute_time = neuron_surrogate_compute_time;
		if (neuron_surrogate_compute_time == 0) begin
			if (neuron_surrogate_read_finish) begin
				n_neuron_surrogate_compute_time = 1;
			end
		end else begin
			if (surrogate_cnt_fourteen == 0) begin
				n_surrogate_cnt = surrogate_cnt + 1;
			end else begin
				n_surrogate_cnt = 0;
				n_neuron_surrogate_compute_time = 0;
			end
		end 
	end
	always @ (*) begin
		n_post_spike_valid = post_spike_valid;
		if (post_spiking_now) begin
			n_post_spike_valid = 1;
		end
		if (post_spike_catch_done_i && post_spike_valid) begin 
			n_post_spike_valid = 0;
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
				sram_port1_write_data[gen_idx2] = {adder_membrane_membrane_update[gen_idx2][BIT_WIDTH_MEMBRANE*19 +: BIT_WIDTH_WEIGHT], 
													adder_membrane_membrane_update[gen_idx2][BIT_WIDTH_MEMBRANE*18 +: BIT_WIDTH_WEIGHT], 
													adder_membrane_membrane_update[gen_idx2][BIT_WIDTH_MEMBRANE*17 +: BIT_WIDTH_WEIGHT], 
													adder_membrane_membrane_update[gen_idx2][BIT_WIDTH_MEMBRANE*16 +: BIT_WIDTH_WEIGHT], 
													adder_membrane_membrane_update[gen_idx2][BIT_WIDTH_MEMBRANE*15 +: BIT_WIDTH_WEIGHT], 
													adder_membrane_membrane_update[gen_idx2][BIT_WIDTH_MEMBRANE*14 +: BIT_WIDTH_WEIGHT], 
													adder_membrane_membrane_update[gen_idx2][BIT_WIDTH_MEMBRANE*13 +: BIT_WIDTH_WEIGHT], 
													adder_membrane_membrane_update[gen_idx2][BIT_WIDTH_MEMBRANE*12 +: BIT_WIDTH_WEIGHT], 
													adder_membrane_membrane_update[gen_idx2][BIT_WIDTH_MEMBRANE*11 +: BIT_WIDTH_WEIGHT], 
													adder_membrane_membrane_update[gen_idx2][BIT_WIDTH_MEMBRANE*10 +: BIT_WIDTH_WEIGHT], 
													adder_membrane_membrane_update[gen_idx2][BIT_WIDTH_MEMBRANE*9 +: BIT_WIDTH_WEIGHT],
													adder_membrane_membrane_update[gen_idx2][BIT_WIDTH_MEMBRANE*8 +: BIT_WIDTH_WEIGHT],
													adder_membrane_membrane_update[gen_idx2][BIT_WIDTH_MEMBRANE*7 +: BIT_WIDTH_WEIGHT],
													adder_membrane_membrane_update[gen_idx2][BIT_WIDTH_MEMBRANE*6 +: BIT_WIDTH_WEIGHT],
													adder_membrane_membrane_update[gen_idx2][BIT_WIDTH_MEMBRANE*5 +: BIT_WIDTH_WEIGHT],
													adder_membrane_membrane_update[gen_idx2][BIT_WIDTH_MEMBRANE*4 +: BIT_WIDTH_WEIGHT],
													adder_membrane_membrane_update[gen_idx2][BIT_WIDTH_MEMBRANE*3 +: BIT_WIDTH_WEIGHT],
													adder_membrane_membrane_update[gen_idx2][BIT_WIDTH_MEMBRANE*2 +: BIT_WIDTH_WEIGHT],
													adder_membrane_membrane_update[gen_idx2][BIT_WIDTH_MEMBRANE*1 +: BIT_WIDTH_WEIGHT],
													adder_membrane_membrane_update[gen_idx2][BIT_WIDTH_MEMBRANE*0 +: BIT_WIDTH_WEIGHT]};

				adder_membrane_weight[gen_idx2] = sram_port1_read_data[gen_idx2];
				adder_membrane_membrane[gen_idx2] = neuron_membrane[gen_idx2];
				adder_membrane_weight_update_mode[gen_idx2] = 0;
				neuron_membrane_update[gen_idx2] = adder_membrane_membrane_update[gen_idx2];
				neuron_membrane_update_valid[gen_idx2] = 0;

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
					if (weight_update_time_twoclk_delay == 0 && aer_sliced_encoding_on_twoclk_delay[group_cnt_twoclk_delay] && last_spike_this_group_twoclk_delay == 0) begin //ff
						adder_membrane_weight[gen_idx2] = sram_port1_read_data[gen_idx2];
						// adder_membrane_weight[gen_idx2] = sram_port1_read_data_shaked[gen_idx2];
						adder_membrane_weight_update_mode[gen_idx2] = 0;
						neuron_membrane_update[gen_idx2] = adder_membrane_membrane_update[gen_idx2];
						neuron_membrane_update_valid[gen_idx2] = 1;
					end else if (weight_update_time_twoclk_delay == 0 && aer_sliced_encoding_on_twoclk_delay[group_cnt_twoclk_delay] && last_spike_this_group_twoclk_delay == 1) begin //ff
						adder_membrane_weight[gen_idx2] = sram_port1_read_data[gen_idx2];
						adder_membrane_weight_update_mode[gen_idx2] = 0;
						neuron_membrane_update[gen_idx2] = adder_membrane_membrane_update_shifted[gen_idx2];
						neuron_membrane_update_valid[gen_idx2] = 1;
					end else if (weight_update_time_twoclk_delay == 0 && aer_sliced_encoding_on_twoclk_delay[group_cnt_twoclk_delay] == 0 && last_spike_this_group_twoclk_delay == 1) begin //ff
						adder_membrane_weight[gen_idx2] = 0;
						adder_membrane_weight_update_mode[gen_idx2] = 0;
						neuron_membrane_update[gen_idx2] = adder_membrane_membrane_update_shifted[gen_idx2];
						neuron_membrane_update_valid[gen_idx2] = 1;
					end else if (weight_update_time_twoclk_delay == 1 && aer_sliced_encoding_on_twoclk_delay != 0) begin //wu
						adder_membrane_weight[gen_idx2] = sram_port1_read_data[gen_idx2];
						adder_membrane_weight_update_mode[gen_idx2] = 1;
						neuron_membrane_update[gen_idx2] = 0;
						neuron_membrane_update_valid[gen_idx2] = 0;
					end

					if (weight_update_time_twoclk_delay) begin 
						adder_membrane_membrane[gen_idx2] =   {{(BIT_WIDTH_MEMBRANE-BIT_WIDTH_DELTA_WEIGHT){adder_weight_update_delta_weight_array[19][BIT_WIDTH_DELTA_WEIGHT-1]}}, adder_weight_update_delta_weight_array[19],
															   {(BIT_WIDTH_MEMBRANE-BIT_WIDTH_DELTA_WEIGHT){adder_weight_update_delta_weight_array[18][BIT_WIDTH_DELTA_WEIGHT-1]}}, adder_weight_update_delta_weight_array[18],
															   {(BIT_WIDTH_MEMBRANE-BIT_WIDTH_DELTA_WEIGHT){adder_weight_update_delta_weight_array[17][BIT_WIDTH_DELTA_WEIGHT-1]}}, adder_weight_update_delta_weight_array[17],
															   {(BIT_WIDTH_MEMBRANE-BIT_WIDTH_DELTA_WEIGHT){adder_weight_update_delta_weight_array[16][BIT_WIDTH_DELTA_WEIGHT-1]}}, adder_weight_update_delta_weight_array[16],
															   {(BIT_WIDTH_MEMBRANE-BIT_WIDTH_DELTA_WEIGHT){adder_weight_update_delta_weight_array[15][BIT_WIDTH_DELTA_WEIGHT-1]}}, adder_weight_update_delta_weight_array[15],
															   {(BIT_WIDTH_MEMBRANE-BIT_WIDTH_DELTA_WEIGHT){adder_weight_update_delta_weight_array[14][BIT_WIDTH_DELTA_WEIGHT-1]}}, adder_weight_update_delta_weight_array[14],
															   {(BIT_WIDTH_MEMBRANE-BIT_WIDTH_DELTA_WEIGHT){adder_weight_update_delta_weight_array[13][BIT_WIDTH_DELTA_WEIGHT-1]}}, adder_weight_update_delta_weight_array[13],
															   {(BIT_WIDTH_MEMBRANE-BIT_WIDTH_DELTA_WEIGHT){adder_weight_update_delta_weight_array[12][BIT_WIDTH_DELTA_WEIGHT-1]}}, adder_weight_update_delta_weight_array[12],
															   {(BIT_WIDTH_MEMBRANE-BIT_WIDTH_DELTA_WEIGHT){adder_weight_update_delta_weight_array[11][BIT_WIDTH_DELTA_WEIGHT-1]}}, adder_weight_update_delta_weight_array[11],
															   {(BIT_WIDTH_MEMBRANE-BIT_WIDTH_DELTA_WEIGHT){adder_weight_update_delta_weight_array[10][BIT_WIDTH_DELTA_WEIGHT-1]}}, adder_weight_update_delta_weight_array[10],
															   {(BIT_WIDTH_MEMBRANE-BIT_WIDTH_DELTA_WEIGHT){adder_weight_update_delta_weight_array[9][BIT_WIDTH_DELTA_WEIGHT-1]}}, adder_weight_update_delta_weight_array[9],
															   {(BIT_WIDTH_MEMBRANE-BIT_WIDTH_DELTA_WEIGHT){adder_weight_update_delta_weight_array[8][BIT_WIDTH_DELTA_WEIGHT-1]}}, adder_weight_update_delta_weight_array[8],
															   {(BIT_WIDTH_MEMBRANE-BIT_WIDTH_DELTA_WEIGHT){adder_weight_update_delta_weight_array[7][BIT_WIDTH_DELTA_WEIGHT-1]}}, adder_weight_update_delta_weight_array[7],
															   {(BIT_WIDTH_MEMBRANE-BIT_WIDTH_DELTA_WEIGHT){adder_weight_update_delta_weight_array[6][BIT_WIDTH_DELTA_WEIGHT-1]}}, adder_weight_update_delta_weight_array[6],
															   {(BIT_WIDTH_MEMBRANE-BIT_WIDTH_DELTA_WEIGHT){adder_weight_update_delta_weight_array[5][BIT_WIDTH_DELTA_WEIGHT-1]}}, adder_weight_update_delta_weight_array[5],
															   {(BIT_WIDTH_MEMBRANE-BIT_WIDTH_DELTA_WEIGHT){adder_weight_update_delta_weight_array[4][BIT_WIDTH_DELTA_WEIGHT-1]}}, adder_weight_update_delta_weight_array[4],
															   {(BIT_WIDTH_MEMBRANE-BIT_WIDTH_DELTA_WEIGHT){adder_weight_update_delta_weight_array[3][BIT_WIDTH_DELTA_WEIGHT-1]}}, adder_weight_update_delta_weight_array[3],
															   {(BIT_WIDTH_MEMBRANE-BIT_WIDTH_DELTA_WEIGHT){adder_weight_update_delta_weight_array[2][BIT_WIDTH_DELTA_WEIGHT-1]}}, adder_weight_update_delta_weight_array[2],
															   {(BIT_WIDTH_MEMBRANE-BIT_WIDTH_DELTA_WEIGHT){adder_weight_update_delta_weight_array[1][BIT_WIDTH_DELTA_WEIGHT-1]}}, adder_weight_update_delta_weight_array[1],
															   {(BIT_WIDTH_MEMBRANE-BIT_WIDTH_DELTA_WEIGHT){adder_weight_update_delta_weight_array[0][BIT_WIDTH_DELTA_WEIGHT-1]}}, adder_weight_update_delta_weight_array[0]};
					end



				end else begin
					if (config_valid_i) begin
						// port1으로 sram 초기화
						sram_port1_address[gen_idx2] = config_counter_divide_ten;
						if (gen_idx2 == config_counter_modulo_ten) begin 
							sram_port1_enable[gen_idx2] = 1;
						end else begin
							sram_port1_enable[gen_idx2] = 0;
						end
						sram_port1_write_enable[gen_idx2] = 1;
						sram_port1_write_data[gen_idx2] = config_value;
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




	
	// ######### DELTA WEIGHT FETCH #############################################################################
	// ######### DELTA WEIGHT FETCH #############################################################################
	// ######### DELTA WEIGHT FETCH #############################################################################
	genvar gen_idx4;
	generate
        for (gen_idx4 = 0; gen_idx4 < NEURON_NUM_IN_SET; gen_idx4 = gen_idx4 + 1) begin : gen_adder_weight_update_delta_weight_array_error_class_first
			always @(posedge clk or negedge reset_n) begin
				if (!reset_n) begin
					adder_weight_update_delta_weight_array[gen_idx4] <= 0;
					adder_weight_update_delta_weight_array_second[gen_idx4] <= 0;
				end else begin
					if (neuron_surrogate_read_finish) begin
						adder_weight_update_delta_weight_array[gen_idx4] <= {1'b0, neuron_surrogate[error_class_first_i][gen_idx4*BIT_WIDTH_SURROGATE +: BIT_WIDTH_SURROGATE]};
					end else if (surrogate_change_to_second) begin
						adder_weight_update_delta_weight_array[gen_idx4] <= -adder_weight_update_delta_weight_array_before_negate[gen_idx4];
					end

					if (neuron_surrogate_read_finish) begin
						adder_weight_update_delta_weight_array_second[gen_idx4] <= neuron_surrogate[error_class_second_i][gen_idx4*BIT_WIDTH_SURROGATE +: BIT_WIDTH_SURROGATE];
					end
				end
			end
		end
	endgenerate
	genvar gen_idx5;
	generate
        for (gen_idx5 = 0; gen_idx5 < NEURON_NUM_IN_SET; gen_idx5 = gen_idx5 + 1) begin : gen_adder_weight_update_delta_weight_array_error_class_second_before_negate
			assign adder_weight_update_delta_weight_array_before_negate[gen_idx5] = {1'b0, adder_weight_update_delta_weight_array_second[gen_idx5]};
		end
	endgenerate
	// ######### DELTA WEIGHT FETCH #############################################################################
	// ######### DELTA WEIGHT FETCH #############################################################################
	// ######### DELTA WEIGHT FETCH #############################################################################






	// ############################## CONFIG ##########################################################################################
	// ############################## CONFIG ##########################################################################################
	// ############################## CONFIG ##########################################################################################
	genvar gen_idx3;
	generate
		for (gen_idx3 = 0; gen_idx3 < 15; gen_idx3 = gen_idx3 + 1) begin : gen_surrogate_x_cut_in_layer1
			always @(posedge clk or negedge reset_n) begin
				if (!reset_n) begin
					surrogate_x_cut[gen_idx3] <= 0;
					neuron_surrogate_ref_reg[gen_idx3] <= 0;
				end else begin
					surrogate_x_cut[gen_idx3] <= n_surrogate_x_cut[gen_idx3];
					neuron_surrogate_ref_reg[gen_idx3] <= n_neuron_surrogate_ref_reg[gen_idx3];
				end
			end
		end
	endgenerate

	assign do_not_config_now_o = (fsm_state != STATE_CONFIG) || (neuron_surrogate_compute_time == 1);
	always @ (*) begin
		sram_initialize = 0;
		n_surrogate_x_cut[0] = surrogate_x_cut[0];
		n_surrogate_x_cut[1] = surrogate_x_cut[1];
		n_surrogate_x_cut[2] = surrogate_x_cut[2];
		n_surrogate_x_cut[3] = surrogate_x_cut[3];
		n_surrogate_x_cut[4] = surrogate_x_cut[4];
		n_surrogate_x_cut[5] = surrogate_x_cut[5];
		n_surrogate_x_cut[6] = surrogate_x_cut[6];
		n_surrogate_x_cut[7] = surrogate_x_cut[7];
		n_surrogate_x_cut[8] = surrogate_x_cut[8];
		n_surrogate_x_cut[9] = surrogate_x_cut[9];
		n_surrogate_x_cut[10] = surrogate_x_cut[10];
		n_surrogate_x_cut[11] = surrogate_x_cut[11];
		n_surrogate_x_cut[12] = surrogate_x_cut[12];
		n_surrogate_x_cut[13] = surrogate_x_cut[13];
		n_surrogate_x_cut[14] = surrogate_x_cut[14];
		n_neuron_surrogate_ref_reg[0] = neuron_surrogate_ref_reg[0];
		n_neuron_surrogate_ref_reg[1] = neuron_surrogate_ref_reg[1];
		n_neuron_surrogate_ref_reg[2] = neuron_surrogate_ref_reg[2];
		n_neuron_surrogate_ref_reg[3] = neuron_surrogate_ref_reg[3];
		n_neuron_surrogate_ref_reg[4] = neuron_surrogate_ref_reg[4];
		n_neuron_surrogate_ref_reg[5] = neuron_surrogate_ref_reg[5];
		n_neuron_surrogate_ref_reg[6] = neuron_surrogate_ref_reg[6];
		n_neuron_surrogate_ref_reg[7] = neuron_surrogate_ref_reg[7];
		n_neuron_surrogate_ref_reg[8] = neuron_surrogate_ref_reg[8];
		n_neuron_surrogate_ref_reg[9] = neuron_surrogate_ref_reg[9];
		n_neuron_surrogate_ref_reg[10] = neuron_surrogate_ref_reg[10];
		n_neuron_surrogate_ref_reg[11] = neuron_surrogate_ref_reg[11];
		n_neuron_surrogate_ref_reg[12] = neuron_surrogate_ref_reg[12];
		n_neuron_surrogate_ref_reg[13] = neuron_surrogate_ref_reg[13];
		n_neuron_surrogate_ref_reg[14] = neuron_surrogate_ref_reg[14];

		if (neuron_surrogate_compute_time) begin
			n_surrogate_x_cut[0] = surrogate_x_cut[1];
			n_surrogate_x_cut[1] = surrogate_x_cut[2];
			n_surrogate_x_cut[2] = surrogate_x_cut[3];
			n_surrogate_x_cut[3] = surrogate_x_cut[4];
			n_surrogate_x_cut[4] = surrogate_x_cut[5];
			n_surrogate_x_cut[5] = surrogate_x_cut[6];
			n_surrogate_x_cut[6] = surrogate_x_cut[7];
			n_surrogate_x_cut[7] = surrogate_x_cut[8];
			n_surrogate_x_cut[8] = surrogate_x_cut[9];
			n_surrogate_x_cut[9] = surrogate_x_cut[10];
			n_surrogate_x_cut[10] = surrogate_x_cut[11];
			n_surrogate_x_cut[11] = surrogate_x_cut[12];
			n_surrogate_x_cut[12] = surrogate_x_cut[13];
			n_surrogate_x_cut[13] = surrogate_x_cut[14];
			n_surrogate_x_cut[14] = surrogate_x_cut[0];
			n_neuron_surrogate_ref_reg[0] = neuron_surrogate_ref_reg[1];
			n_neuron_surrogate_ref_reg[1] = neuron_surrogate_ref_reg[2];
			n_neuron_surrogate_ref_reg[2] = neuron_surrogate_ref_reg[3];
			n_neuron_surrogate_ref_reg[3] = neuron_surrogate_ref_reg[4];
			n_neuron_surrogate_ref_reg[4] = neuron_surrogate_ref_reg[5];
			n_neuron_surrogate_ref_reg[5] = neuron_surrogate_ref_reg[6];
			n_neuron_surrogate_ref_reg[6] = neuron_surrogate_ref_reg[7];
			n_neuron_surrogate_ref_reg[7] = neuron_surrogate_ref_reg[8];
			n_neuron_surrogate_ref_reg[8] = neuron_surrogate_ref_reg[9];
			n_neuron_surrogate_ref_reg[9] = neuron_surrogate_ref_reg[10];
			n_neuron_surrogate_ref_reg[10] = neuron_surrogate_ref_reg[11];
			n_neuron_surrogate_ref_reg[11] = neuron_surrogate_ref_reg[12];
			n_neuron_surrogate_ref_reg[12] = neuron_surrogate_ref_reg[13];
			n_neuron_surrogate_ref_reg[13] = neuron_surrogate_ref_reg[14];
			n_neuron_surrogate_ref_reg[14] = neuron_surrogate_ref_reg[0];
		end else if (config_valid_i == 1 && config_done_flag == 0) begin
			n_neuron_surrogate_ref_reg[0] = 0;
			n_neuron_surrogate_ref_reg[1] = 1;
			n_neuron_surrogate_ref_reg[2] = 2;
			n_neuron_surrogate_ref_reg[3] = 3;
			n_neuron_surrogate_ref_reg[4] = 4;
			n_neuron_surrogate_ref_reg[5] = 5;
			n_neuron_surrogate_ref_reg[6] = 6;
			n_neuron_surrogate_ref_reg[7] = 7;
			n_neuron_surrogate_ref_reg[8] = 6;
			n_neuron_surrogate_ref_reg[9] = 5;
			n_neuron_surrogate_ref_reg[10] = 4;
			n_neuron_surrogate_ref_reg[11] = 3;
			n_neuron_surrogate_ref_reg[12] = 2;
			n_neuron_surrogate_ref_reg[13] = 1;
			n_neuron_surrogate_ref_reg[14] = 0;
			if (config_counter == DEPTH_SRAM*SET_NUM + 2) begin
				n_surrogate_x_cut[8] = config_value[0*BIT_WIDTH_MEMBRANE +: BIT_WIDTH_MEMBRANE];
				n_surrogate_x_cut[9] = config_value[1*BIT_WIDTH_MEMBRANE +: BIT_WIDTH_MEMBRANE];
				n_surrogate_x_cut[10] = config_value[2*BIT_WIDTH_MEMBRANE +: BIT_WIDTH_MEMBRANE];
				n_surrogate_x_cut[11] = config_value[3*BIT_WIDTH_MEMBRANE +: BIT_WIDTH_MEMBRANE];
				n_surrogate_x_cut[12] = config_value[4*BIT_WIDTH_MEMBRANE +: BIT_WIDTH_MEMBRANE];
				n_surrogate_x_cut[13] = config_value[5*BIT_WIDTH_MEMBRANE +: BIT_WIDTH_MEMBRANE];
				n_surrogate_x_cut[14] = config_value[6*BIT_WIDTH_MEMBRANE +: BIT_WIDTH_MEMBRANE];
			end else if (config_counter == DEPTH_SRAM*SET_NUM + 1) begin
				n_surrogate_x_cut[1] = config_value[0*BIT_WIDTH_MEMBRANE +: BIT_WIDTH_MEMBRANE];
				n_surrogate_x_cut[2] = config_value[1*BIT_WIDTH_MEMBRANE +: BIT_WIDTH_MEMBRANE];
				n_surrogate_x_cut[3] = config_value[2*BIT_WIDTH_MEMBRANE +: BIT_WIDTH_MEMBRANE];
				n_surrogate_x_cut[4] = config_value[3*BIT_WIDTH_MEMBRANE +: BIT_WIDTH_MEMBRANE];
				n_surrogate_x_cut[5] = config_value[4*BIT_WIDTH_MEMBRANE +: BIT_WIDTH_MEMBRANE];
				n_surrogate_x_cut[6] = config_value[5*BIT_WIDTH_MEMBRANE +: BIT_WIDTH_MEMBRANE];
				n_surrogate_x_cut[7] = config_value[6*BIT_WIDTH_MEMBRANE +: BIT_WIDTH_MEMBRANE];
			end else if (config_counter == DEPTH_SRAM*SET_NUM) begin
				n_surrogate_x_cut[0] = config_value[BIT_WIDTH_MEMBRANE-1:0];
			end else begin
				sram_initialize = 1;
			end 
		end 
	end
	assign neuron_surrogate_ref = neuron_surrogate_ref_reg[0];
	assign neuron_threshold = surrogate_x_cut[0];
	// ############################## CONFIG ##########################################################################################
	// ############################## CONFIG ##########################################################################################
	// ############################## CONFIG ##########################################################################################

	





	// ############################## SPIKE_BUFFER ##########################################################################################
	// ############################## SPIKE_BUFFER ##########################################################################################
	// ############################## SPIKE_BUFFER ##########################################################################################
	genvar gen_idx0;
	generate
		for (gen_idx0 = 0; gen_idx0 < SPIKE_BUFFER_PAST_SIZE; gen_idx0 = gen_idx0 + 1) begin : gen_spike_buffer_past
			always @(posedge clk or negedge reset_n) begin
				if (!reset_n) begin
					spike_buffer_past[gen_idx0] <= 0;
				end else begin
					spike_buffer_past[gen_idx0] <= n_spike_buffer_past[gen_idx0];
				end
			end
		end
	endgenerate
	genvar gen_idx1;
	generate
		for (gen_idx1 = 0 + 1; gen_idx1 < SPIKE_BUFFER_PAST_SIZE; gen_idx1 = gen_idx1 + 1) begin : gen_spike_buffer_past_move
			always @ (*) begin
				n_spike_buffer_past[gen_idx1] = spike_buffer_past[gen_idx1];
				if (spike_buffer_move_flag) begin
					n_spike_buffer_past[gen_idx1] = spike_buffer_past[gen_idx1-1];
				end
			end
		end
	endgenerate
	// ############################## SPIKE_BUFFER ##########################################################################################
	// ############################## SPIKE_BUFFER ##########################################################################################
	// ############################## SPIKE_BUFFER ##########################################################################################
	



	// ############################## AER_ENCODER ##########################################################################################
	// ############################## AER_ENCODER ##########################################################################################
	// ############################## AER_ENCODER ##########################################################################################
	aer_encoder_layer1_slice10_dual_mode u_aer_encoder_layer1_slice10_dual_mode(
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
	genvar j;
	generate
        for (j = 0; j < SET_NUM; j = j + 1) begin : gen_neuron_set
			neuron_set_layer1 #(
				.BIT_WIDTH_MEMBRANE              ( BIT_WIDTH_MEMBRANE ),
				.BIT_WIDTH_SURROGATE             ( BIT_WIDTH_SURROGATE ),
				.DEPTH_SURROGATE_BOX             ( DEPTH_SURROGATE_BOX ),
				.NEURON_NUM_IN_SET                         ( NEURON_NUM_IN_SET )
			)u_neuron_set_layer1(
				.clk                             ( clk                             ),
				.reset_n                         ( reset_n                         ),
				.threshold_i                     ( neuron_threshold                 ),
				.membrane_update_i               ( neuron_membrane_update[j]               ),
				.membrane_update_valid_i         ( neuron_membrane_update_valid[j]         ),
				.post_spiking_now_i           ( post_spiking_now           ),
				.training_state_i           ( training_fsm_state_oneclk_delay            ),
				.this_sample_done_i              ( neuron_this_sample_done_oneclk_delay    ),
				.surrogate_compute_time_i              ( neuron_surrogate_compute_time              ),
				.surrogate_ref_i              ( neuron_surrogate_ref              ),
				.surrogate_read_finish_i            ( neuron_surrogate_read_finish            ),
				.membrane_o                      ( neuron_membrane[j]                   ),
				.post_spike_o                    ( neuron_post_spike[j*NEURON_NUM_IN_SET +: NEURON_NUM_IN_SET]                   ),
				.surrogate_o                     ( neuron_surrogate[j]                     )
			);
		end
	endgenerate
	// ############################## NEURON ##########################################################################################
	// ############################## NEURON ##########################################################################################
	// ############################## NEURON ##########################################################################################







	// ############################## ADDER ##########################################################################################
	// ############################## ADDER ##########################################################################################
	// ############################## ADDER ##########################################################################################
	genvar k;
	generate
        for (k = 0; k < SET_NUM; k = k + 1) begin : gen_adder_membrane_set
			adder_membrane_set#(
				.BIT_WIDTH_WEIGHT     ( BIT_WIDTH_WEIGHT ),
				.BIT_WIDTH_MEMBRANE   ( BIT_WIDTH_MEMBRANE ),
				.NEURON_NUM_IN_SET              ( NEURON_NUM_IN_SET )
			)u_adder_membrane_set(
				.weight_i             (     adder_membrane_weight[k]                 ),
				.membrane_i           (     adder_membrane_membrane[k]                 ),
				.weight_update_mode_i (  adder_membrane_weight_update_mode[k]                    ),
				.membrane_update_o    (   adder_membrane_membrane_update[k]                   )
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
	
	




	assign adder_membrane_membrane_update_shifted[0] = adder_membrane_membrane_update[9];
	assign adder_membrane_membrane_update_shifted[1] = adder_membrane_membrane_update[0];
	assign adder_membrane_membrane_update_shifted[2] = adder_membrane_membrane_update[1];
	assign adder_membrane_membrane_update_shifted[3] = adder_membrane_membrane_update[2];
	assign adder_membrane_membrane_update_shifted[4] = adder_membrane_membrane_update[3];
	assign adder_membrane_membrane_update_shifted[5] = adder_membrane_membrane_update[4];
	assign adder_membrane_membrane_update_shifted[6] = adder_membrane_membrane_update[5];
	assign adder_membrane_membrane_update_shifted[7] = adder_membrane_membrane_update[6];
	assign adder_membrane_membrane_update_shifted[8] = adder_membrane_membrane_update[7];
	assign adder_membrane_membrane_update_shifted[9] = adder_membrane_membrane_update[8];


	assign post_spike_o = neuron_post_spike;
	assign post_spike_valid_o = post_spike_valid;





	// ########################## FOR TEST ########################################################################################
	// ########################## FOR TEST ########################################################################################
	// ########################## FOR TEST ########################################################################################
	// ########################## FOR TEST ########################################################################################
	// ########################## FOR TEST ########################################################################################
	`ifdef FUNC_VERI
		reg post_spiking_now_oneclk_delay_for_tb;

		// assign software_hardware_check_weight = neuron_surrogate_read_finish;
		assign software_hardware_check_weight = post_spiking_now_oneclk_delay_for_tb;

		// wire [SET_NUM*NEURON_NUM_IN_SET-1:0] neuron_post_spike;
		integer txt_idx0;
		integer fd0;
		wire software_hardware_check_post_spike;
		// assign software_hardware_check_post_spike = post_spike_valid && (surrogate_cnt == 1);
		// assign software_hardware_check_post_spike = post_spiking_now;
		assign software_hardware_check_post_spike = post_spiking_now_oneclk_delay_for_tb;
		integer timestep_counter_check_post_spike;
		initial timestep_counter_check_post_spike = 0;
		always @(negedge clk) begin
			if (software_hardware_check_post_spike) begin
				if (timestep_counter_check_post_spike >= 0) begin

					fd0 = $fopen($sformatf("../test_vector/sweep_mode/zz_tb_vector_layer1_hw/tb_output_activation%0d.txt", timestep_counter_check_post_spike-0), "w");




					for (txt_idx0 = 0; txt_idx0 < SET_NUM*NEURON_NUM_IN_SET; txt_idx0 = txt_idx0 + 1) begin
						$fwrite(fd0, "%b", neuron_post_spike[txt_idx0]);
						$fwrite(fd0, "\n");
					end
					$fclose(fd0);
				end
				timestep_counter_check_post_spike <= timestep_counter_check_post_spike + 1;
			end

			// if (timestep_counter_check_post_spike >= (`FUNC_VERI)) $finish;
		end

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


					
					fd1 = $fopen($sformatf("../test_vector/sweep_mode/zz_tb_vector_layer1_hw/tb_membrane%0d.txt", timestep_counter_check_membrane-0), "w");




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

		
		// wire [BIT_WIDTH_MEMBRANE*NEURON_NUM_IN_SET-1:0] neuron_membrane [0:SET_NUM-1];

		integer txt_idx2_0, txt_idx2_1;
		integer fd2;
		reg signed [BIT_WIDTH_MEMBRANE-1:0] value2;
		wire software_hardware_check_membrane_reset;
		// assign software_hardware_check_membrane_reset = post_spike_valid && (surrogate_cnt == 1);
		assign software_hardware_check_membrane_reset = post_spiking_now_oneclk_delay_for_tb;
		integer timestep_counter_check_membrane_reset;
		initial timestep_counter_check_membrane_reset = 0;
		always @(negedge clk) begin
			if (software_hardware_check_membrane_reset) begin
				if (timestep_counter_check_membrane_reset >= 0) begin


					
					fd2 = $fopen($sformatf("../test_vector/sweep_mode/zz_tb_vector_layer1_hw/tb_membrane_reset%0d.txt", timestep_counter_check_membrane_reset-0), "w");




					for (txt_idx2_0 = 0; txt_idx2_0 < SET_NUM; txt_idx2_0 = txt_idx2_0 + 1) begin
						for (txt_idx2_1 = 0; txt_idx2_1 < NEURON_NUM_IN_SET; txt_idx2_1 = txt_idx2_1 + 1) begin
							value2 = neuron_membrane[txt_idx2_0][BIT_WIDTH_MEMBRANE*txt_idx2_1 +: BIT_WIDTH_MEMBRANE];
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

		
		always @(posedge clk or negedge reset_n) begin
			if (!reset_n) begin
				post_spiking_now_oneclk_delay_for_tb <= 0;
			end else begin
				post_spiking_now_oneclk_delay_for_tb <= post_spiking_now;
			end
		end

	// ########################## FOR TEST ########################################################################################
	// ########################## FOR TEST ########################################################################################
	// ########################## FOR TEST ########################################################################################
	// ########################## FOR TEST ########################################################################################
	// ########################## FOR TEST ########################################################################################

	`else
		assign software_hardware_check_weight = 0;
	`endif

endmodule



