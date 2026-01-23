module d_domain(
        input sys_clk_p,
        input sys_clk_n,
        input reset_n,

        // p2d command fifo
        output reg fifo_p2d_command_rd_en,
        input [32 - 1:0] fifo_p2d_command_dout,
        input fifo_p2d_command_empty,
        input fifo_p2d_command_valid,


        // p2d data fifo
        output reg fifo_p2d_data_rd_en,
        input [256 - 1:0] fifo_p2d_data_dout,
        input fifo_p2d_data_empty,
        input fifo_p2d_data_valid,


        // d2p command fifo
        output reg fifo_d2p_command_wr_en,
        output reg [32 - 1:0] fifo_d2p_command_din,
        input fifo_d2p_command_full,


        // d2a command fifo
        output reg fifo_d2a_command_wr_en,
        output reg [32 - 1:0] fifo_d2a_command_din,
        input fifo_d2a_command_full,

    
        // d2a data fifo
        output reg fifo_d2a_data_wr_en,
        output reg [66 - 1:0] fifo_d2a_data_din,
        input fifo_d2a_data_full,

    
        // a2d_command fifo
        output reg fifo_a2d_command_rd_en,
        input [32 - 1:0] fifo_a2d_command_dout,
        input fifo_a2d_command_empty,
        input fifo_a2d_command_valid,




        // DRAM Interface
        output                 ui_clk,
        output                ui_clk_sync_rst,

        output wire [12 - 1:0]    device_temp,

        output wire [15:0]  ddr3_addr,
        output wire [2 :0]  ddr3_ba,
        output wire         ddr3_cas_n,
        output wire [0 :0]  ddr3_ck_n,
        output wire [0 :0]  ddr3_ck_p,
        output wire [0 :0]  ddr3_cke,
        output wire         ddr3_ras_n,
        output wire         ddr3_reset_n,

        output wire         ddr3_we_n,
        inout  wire [31:0]  ddr3_dq,
        inout  wire [3 :0]  ddr3_dqs_n,
        inout  wire [3 :0]  ddr3_dqs_p,
        output wire         init_calib_complete,

        output wire [0 :0]  ddr3_cs_n,
        output wire [3 :0]  ddr3_dm,
        output wire [0 :0]  ddr3_odt
    );

localparam  DRAM_READ       = 3'b001,
            DRAM_WRITE      = 3'b000;
localparam DVS_GESTURE_BITS_PER_SAMPLE = 9984;
localparam DVS_GESTURE_READ_REQUEST_PER_SAMPLE = 39; // 9984 / 256 = 39
localparam DVS_GESTURE_BITS_PER_TIME_IN_DRAM = 984;
localparam N_MNIST_BITS_PER_SAMPLE = 3072;
localparam N_MNIST_READ_REQUEST_PER_SAMPLE = 12; // 3072 / 256 = 12
localparam N_MNIST_BITS_PER_TIME_IN_DRAM = 582;
localparam NTIDIGITS_BITS_PER_SAMPLE = 4352;
localparam NTIDIGITS_READ_REQUEST_PER_SAMPLE = 17; // 4352 / 256 = 17
localparam NTIDIGITS_BITS_PER_TIME_IN_DRAM = 516;
localparam CLOCK_INPUT_SPIKE_COLLECT_LONG = 15; // 986 <= 66*15 ==990
localparam CLOCK_INPUT_SPIKE_COLLECT_SHORT = 9;

	localparam       BIT_WIDTH_INPUT_STREAMING_DATA = 66;

	localparam       LAYER1_DEPTH_SRAM             = 980;
	localparam       LAYER1_SET_NUM                = 10;
	localparam       LAYER1_BIT_WIDTH_SRAM         = 160;  
    localparam       LAYER1_BIT_WIDTH_MEMBRANE      = 17;
	localparam       LAYER2_DEPTH_SRAM             = 200;
	localparam       LAYER2_SET_NUM                = 10;
	localparam       LAYER2_BIT_WIDTH_SRAM         = 160;  
    localparam       LAYER2_BIT_WIDTH_MEMBRANE      = 16;
	localparam       LAYER3_DEPTH_SRAM             = 200;
	localparam       LAYER3_SET_NUM                = 10;
	localparam       LAYER3_BIT_WIDTH_SRAM         = 160;  
    localparam       LAYER3_BIT_WIDTH_MEMBRANE      = 16;


    reg [15:0] config_d_domain_setting_cnt, n_config_d_domain_setting_cnt;

    reg [1:0] d_config_asic_mode, n_d_config_asic_mode; // 0 training_only, 1 train_inf_sweep, 2 inference_only 
    reg [15:0] d_config_training_epochs, n_d_config_training_epochs;
    reg [15:0] d_config_inference_epochs, n_d_config_inference_epochs;
    reg [1:0] d_config_dataset, n_d_config_dataset; // 0 DVS_GESTURE, 1 N_MNIST, 2 NTIDIGITS
    reg [15:0] d_config_timesteps, n_d_config_timesteps;
    reg [15:0] d_config_input_size_layer1_define, n_d_config_input_size_layer1_define;
    reg d_config_long_time_input_streaming_mode, n_d_config_long_time_input_streaming_mode;
    reg d_config_binary_classifier_mode, n_d_config_binary_classifier_mode;
    reg d_config_loser_encourage_mode, n_d_config_loser_encourage_mode;
    reg [17*15 - 1:0] d_config_layer1_cut_list, n_d_config_layer1_cut_list;
    reg [16*15 - 1:0] d_config_layer2_cut_list, n_d_config_layer2_cut_list;

    reg dram_reset_complete_trg_have_been_sent, n_dram_reset_complete_trg_have_been_sent;

    reg [31:0] dram_address, n_dram_address;
    reg [31:0] dram_address_last, n_dram_address_last;
    reg [3:0] dram_address_transition_cnt, n_dram_address_transition_cnt;
    
    reg [31:0] write_count, n_write_count;
    reg dram_writing_finish_flag, n_dram_writing_finish_flag;
    reg dram_writing_check_read_flag, n_dram_writing_check_read_flag;
    reg dram_writing_check_read_catch_flag, n_dram_writing_check_read_catch_flag;
    reg [17 - 1:0] app_rd_data_check, n_app_rd_data_check;

    reg streaming_wait_cycle_send_have_been, n_streaming_wait_cycle_send_have_been;
    reg config_on_broadcasting_send_have_been, n_config_on_broadcasting_send_have_been;
    reg config_on_real, n_config_on_real;
	reg main_config_now, n_main_config_now;
	reg layer1_config_now, n_layer1_config_now;
	reg [3:0] layer1_config_phase, n_layer1_config_phase;
	reg layer2_config_now, n_layer2_config_now;
	reg [3:0] layer2_config_phase, n_layer2_config_phase;
	reg layer3_config_now, n_layer3_config_now;
	reg [3:0] layer3_config_phase, n_layer3_config_phase;





	reg [15:0] config_counter, n_config_counter;
	reg [1:0] config_counter_one_two_three, n_config_counter_one_two_three;
	reg [31:0] config_dram_read_address, n_config_dram_read_address;
    reg [255:0] config_dram_word, n_config_dram_word;
    reg config_dram_word_ready, n_config_dram_word_ready;
    reg config_dram_word_request_have_been, n_config_dram_word_request_have_been;

    reg [31:0] sample_num, n_sample_num;
    reg [3:0] sample_num_transition_cnt, n_sample_num_transition_cnt;

    reg queuing_request_send_have_been, n_queuing_request_send_have_been;

    reg training_streaming_ongoing, n_training_streaming_ongoing;
    reg inference_streaming_ongoing, n_inference_streaming_ongoing;
    reg queuing_first_time, n_queuing_first_time;
    reg [31:0] read_address_for_data, n_read_address_for_data;

    reg [DVS_GESTURE_BITS_PER_SAMPLE-1:0] sample_data_buffer, n_sample_data_buffer;
    reg [31:0] sample_data_buffer_num, n_sample_data_buffer_num;
    reg [7:0] sample_data_buffer_read_request_cnt, n_sample_data_buffer_read_request_cnt;
    reg [7:0] sample_data_buffer_cnt, n_sample_data_buffer_cnt;
    reg sample_data_buffer_stop_read_request, n_sample_data_buffer_stop_read_request;

    // reg [DVS_GESTURE_BITS_PER_SAMPLE-1:0] sample_data_buffer2, n_sample_data_buffer2;
    reg [DVS_GESTURE_BITS_PER_SAMPLE-1:0] sample_data_buffer2_gesture, n_sample_data_buffer2_gesture;
    reg [N_MNIST_BITS_PER_SAMPLE-1:0] sample_data_buffer2_nmnist, n_sample_data_buffer2_nmnist;
    reg [NTIDIGITS_BITS_PER_SAMPLE-1:0] sample_data_buffer2_ntidigits, n_sample_data_buffer2_ntidigits;
    reg [3:0] sample_data_buffer2_cnt_small, n_sample_data_buffer2_cnt_small;
    reg sample_data_buffer2_busy, n_sample_data_buffer2_busy;
    reg [7:0] sample_data_buffer2_time_cnt, n_sample_data_buffer2_time_cnt;
    reg [DVS_GESTURE_BITS_PER_TIME_IN_DRAM-1:0] gesture_label_and_data_one_timestep, n_gesture_label_and_data_one_timestep;
    reg [N_MNIST_BITS_PER_TIME_IN_DRAM-1:0] nmnist_label_and_data_one_timestep, n_nmnist_label_and_data_one_timestep;
    reg [N_MNIST_BITS_PER_TIME_IN_DRAM-1:0] ntidigits_label_and_data_one_timestep, n_ntidigits_label_and_data_one_timestep; // nmnist bit width per time also used for ntidigits
    reg dataset_label_and_data_one_timestep_ready, n_dataset_label_and_data_one_timestep_ready;
    // assign gesture_label_and_data_one_timestep = sample_data_buffer2[0 * DVS_GESTURE_BITS_PER_TIME_IN_DRAM +: DVS_GESTURE_BITS_PER_TIME_IN_DRAM];
    // assign nmnist_label_and_data_one_timestep = sample_data_buffer2[0 * N_MNIST_BITS_PER_TIME_IN_DRAM +: N_MNIST_BITS_PER_TIME_IN_DRAM];
    // assign ntidigits_label_and_data_one_timestep = {sample_data_buffer2[0 * NTIDIGITS_BITS_PER_TIME_IN_DRAM + NTIDIGITS_BITS_PER_TIME_IN_DRAM - 4 +: 4], 66'd0, sample_data_buffer2[0 * NTIDIGITS_BITS_PER_TIME_IN_DRAM +: NTIDIGITS_BITS_PER_TIME_IN_DRAM - 4]};
    reg [3:0] this_sample_label, n_this_sample_label;
    reg this_epoch_finish, n_this_epoch_finish;
    reg this_sample_done, n_this_sample_done;

    reg [31:0] sample_num_executed, n_sample_num_executed;


    // reg [BIT_WIDTH_INPUT_STREAMING_DATA*3-1:0] config_value;
    reg [BIT_WIDTH_INPUT_STREAMING_DATA*3-1:0] config_value_main, n_config_value_main;
    reg [BIT_WIDTH_INPUT_STREAMING_DATA*3-1:0] config_value_layer1, n_config_value_layer1;
    reg [BIT_WIDTH_INPUT_STREAMING_DATA*3-1:0] config_value_layer2, n_config_value_layer2;
    reg [BIT_WIDTH_INPUT_STREAMING_DATA*3-1:0] config_value_layer3, n_config_value_layer3;
    reg config_value_ready, n_config_value_ready;

        reg	         	app_en;
        reg	[3 - 1:0] 	app_cmd;
        reg	[30 - 1:0]	app_addr; // 29bit address @ 7310,  30bit address @ 7360
        reg	         	app_wdf_wren;
        reg	[256 - 1:0] app_wdf_data;
        reg	         	app_wdf_end;
        reg	[32 - 1:0]  app_wdf_mask;

        wire	         	app_rdy;
        wire	[256 - 1:0] app_rd_data;
        wire	         	app_rd_data_end;
        wire	         	app_rd_data_valid;
        wire	         	app_wdf_rdy;



    always @(posedge ui_clk) begin
        if(reset_n == 0 || ui_clk_sync_rst) begin
            config_d_domain_setting_cnt <= 0;

            d_config_asic_mode <= 0;
            d_config_training_epochs <= 0;
            d_config_inference_epochs  <= 0;
            d_config_dataset  <= 0;
            d_config_timesteps  <= 0;
            d_config_input_size_layer1_define  <= 0;
            d_config_long_time_input_streaming_mode  <= 0;
            d_config_binary_classifier_mode  <= 0;
            d_config_loser_encourage_mode  <= 0;
            d_config_layer1_cut_list  <= 0;
            d_config_layer2_cut_list  <= 0;

            dram_reset_complete_trg_have_been_sent  <= 0;

            dram_address <= 0;
            dram_address_last <= 0;
            dram_address_transition_cnt <= 0;

            write_count <= 0;
            dram_writing_finish_flag <= 0;
            dram_writing_check_read_flag <= 0;
            dram_writing_check_read_catch_flag <= 0;
            app_rd_data_check <= 0;

            streaming_wait_cycle_send_have_been <= 0;
            config_on_broadcasting_send_have_been <= 0;
            config_on_real <= 0;
            main_config_now <= 0;
            layer1_config_now <= 0;
            layer1_config_phase <= 0;
            layer2_config_now <= 0;
            layer2_config_phase <= 0;
            layer3_config_now <= 0;
            layer3_config_phase <= 0;
            config_counter <= 0;
            config_counter_one_two_three <= 0;
            config_dram_read_address <= 0;
            config_dram_word <= 0;
            config_dram_word_ready <= 0;
            config_dram_word_request_have_been <= 0;

            sample_num <= 0;
            sample_num_transition_cnt <= 0;

            queuing_request_send_have_been <= 0;

            training_streaming_ongoing <= 0;
            inference_streaming_ongoing <= 0;
            queuing_first_time <= 0;
            read_address_for_data <= 0;

            sample_data_buffer <= 0;
            sample_data_buffer_num <= 0;
            sample_data_buffer_read_request_cnt <= 0;
            sample_data_buffer_cnt <= 0;
            sample_data_buffer_stop_read_request <= 0;

            // sample_data_buffer2 <= 0;
            sample_data_buffer2_gesture <= 0;
            sample_data_buffer2_nmnist <= 0;
            sample_data_buffer2_ntidigits <= 0;
            sample_data_buffer2_cnt_small <= 0;
            sample_data_buffer2_busy <= 0;
            sample_data_buffer2_time_cnt <= 0;

            this_sample_label <= 0;
            this_epoch_finish <= 0;
            this_sample_done <= 0;

            gesture_label_and_data_one_timestep <= 0;
            nmnist_label_and_data_one_timestep <= 0;
            ntidigits_label_and_data_one_timestep <= 0;
            dataset_label_and_data_one_timestep_ready <= 0;

            sample_num_executed <= 0;

            config_value_main <= 0;
            config_value_layer1 <= 0;
            config_value_layer2 <= 0;
            config_value_layer3 <= 0;
            config_value_ready <= 0;
        end else begin
            config_d_domain_setting_cnt <= n_config_d_domain_setting_cnt;

            d_config_asic_mode <= n_d_config_asic_mode;
            d_config_training_epochs <= n_d_config_training_epochs;
            d_config_inference_epochs <= n_d_config_inference_epochs;
            d_config_dataset <= n_d_config_dataset;
            d_config_timesteps <= n_d_config_timesteps;
            d_config_input_size_layer1_define <= n_d_config_input_size_layer1_define;
            d_config_long_time_input_streaming_mode <= n_d_config_long_time_input_streaming_mode;
            d_config_binary_classifier_mode <= n_d_config_binary_classifier_mode;
            d_config_loser_encourage_mode <= n_d_config_loser_encourage_mode;
            d_config_layer1_cut_list  <= n_d_config_layer1_cut_list;
            d_config_layer2_cut_list  <= n_d_config_layer2_cut_list;

            dram_reset_complete_trg_have_been_sent <= n_dram_reset_complete_trg_have_been_sent;

            dram_address <= n_dram_address;
            dram_address_last <= n_dram_address_last;
            dram_address_transition_cnt <= n_dram_address_transition_cnt;

            write_count <= n_write_count;
            dram_writing_finish_flag <= n_dram_writing_finish_flag;
            dram_writing_check_read_flag <= n_dram_writing_check_read_flag;
            dram_writing_check_read_catch_flag <= n_dram_writing_check_read_catch_flag;
            app_rd_data_check <= n_app_rd_data_check;

            streaming_wait_cycle_send_have_been <= n_streaming_wait_cycle_send_have_been;
            config_on_broadcasting_send_have_been <= n_config_on_broadcasting_send_have_been;
            config_on_real <= n_config_on_real;
            main_config_now <= n_main_config_now;
            layer1_config_now <= n_layer1_config_now;
            layer1_config_phase <= n_layer1_config_phase;
            layer2_config_now <= n_layer2_config_now;
            layer2_config_phase <= n_layer2_config_phase;
            layer3_config_now <= n_layer3_config_now;
            layer3_config_phase <= n_layer3_config_phase;
            config_counter <= n_config_counter;
            config_counter_one_two_three <= n_config_counter_one_two_three;
            config_dram_read_address <= n_config_dram_read_address;
            config_dram_word <= n_config_dram_word;
            config_dram_word_ready <= n_config_dram_word_ready;
            config_dram_word_request_have_been <= n_config_dram_word_request_have_been;

            sample_num <= n_sample_num;
            sample_num_transition_cnt <= n_sample_num_transition_cnt;

            queuing_request_send_have_been <= n_queuing_request_send_have_been;

            training_streaming_ongoing <= n_training_streaming_ongoing;
            inference_streaming_ongoing <= n_inference_streaming_ongoing;
            queuing_first_time <= n_queuing_first_time;
            read_address_for_data <= n_read_address_for_data;

            sample_data_buffer <= n_sample_data_buffer;
            sample_data_buffer_num <= n_sample_data_buffer_num;
            sample_data_buffer_read_request_cnt <= n_sample_data_buffer_read_request_cnt;
            sample_data_buffer_cnt <= n_sample_data_buffer_cnt;
            sample_data_buffer_stop_read_request <= n_sample_data_buffer_stop_read_request;

            // sample_data_buffer2 <= n_sample_data_buffer2;
            sample_data_buffer2_gesture <= n_sample_data_buffer2_gesture;
            sample_data_buffer2_nmnist <= n_sample_data_buffer2_nmnist;
            sample_data_buffer2_ntidigits <= n_sample_data_buffer2_ntidigits;
            sample_data_buffer2_cnt_small <= n_sample_data_buffer2_cnt_small;
            sample_data_buffer2_busy <= n_sample_data_buffer2_busy;
            sample_data_buffer2_time_cnt <= n_sample_data_buffer2_time_cnt;

            this_sample_label <= n_this_sample_label;
            this_epoch_finish <= n_this_epoch_finish;
            this_sample_done <= n_this_sample_done;

            gesture_label_and_data_one_timestep <= n_gesture_label_and_data_one_timestep;
            nmnist_label_and_data_one_timestep <= n_nmnist_label_and_data_one_timestep;
            ntidigits_label_and_data_one_timestep <= n_ntidigits_label_and_data_one_timestep;
            dataset_label_and_data_one_timestep_ready <= n_dataset_label_and_data_one_timestep_ready;
           
            sample_num_executed <= n_sample_num_executed;

            config_value_main <= n_config_value_main;
            config_value_layer1 <= n_config_value_layer1;
            config_value_layer2 <= n_config_value_layer2;
            config_value_layer3 <= n_config_value_layer3;
            config_value_ready <= n_config_value_ready;
        end
    end


    
    wire [256 - 1:0] fifo_p2d_data_dout_align;
    assign fifo_p2d_data_dout_align = {fifo_p2d_data_dout[32*0 +: 32], fifo_p2d_data_dout[32*1 +: 32], fifo_p2d_data_dout[32*2 +: 32], fifo_p2d_data_dout[32*3 +: 32], fifo_p2d_data_dout[32*4 +: 32], fifo_p2d_data_dout[32*5 +: 32], fifo_p2d_data_dout[32*6 +: 32], fifo_p2d_data_dout[32*7 +: 32]};


    always @ (*) begin
        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt;

        fifo_p2d_command_rd_en = 0;

        fifo_d2a_command_wr_en = 0;
        fifo_d2a_command_din = 0;

        fifo_d2a_data_wr_en = 0;
        fifo_d2a_data_din = 0;
        
        n_d_config_asic_mode = d_config_asic_mode;
        n_d_config_training_epochs = d_config_training_epochs;
        n_d_config_inference_epochs = d_config_inference_epochs;
        n_d_config_dataset = d_config_dataset;
        n_d_config_timesteps = d_config_timesteps;
        n_d_config_input_size_layer1_define = d_config_input_size_layer1_define;
        n_d_config_long_time_input_streaming_mode = d_config_long_time_input_streaming_mode;
        n_d_config_binary_classifier_mode = d_config_binary_classifier_mode;
        n_d_config_loser_encourage_mode = d_config_loser_encourage_mode;
        n_d_config_layer1_cut_list = d_config_layer1_cut_list;
        n_d_config_layer2_cut_list = d_config_layer2_cut_list;
        
        n_dram_reset_complete_trg_have_been_sent = dram_reset_complete_trg_have_been_sent;




        fifo_a2d_command_rd_en = 0;

        fifo_d2p_command_wr_en = 0;
        fifo_d2p_command_din = 0;



        n_dram_address = dram_address;
        n_dram_address_last = dram_address_last;
        n_dram_address_transition_cnt = dram_address_transition_cnt;


        n_write_count = write_count;
        n_dram_writing_finish_flag = dram_writing_finish_flag;
        n_dram_writing_check_read_flag = dram_writing_check_read_flag;
        n_dram_writing_check_read_catch_flag = dram_writing_check_read_catch_flag;
        n_app_rd_data_check = app_rd_data_check;

        n_streaming_wait_cycle_send_have_been = streaming_wait_cycle_send_have_been;
        n_config_on_broadcasting_send_have_been = config_on_broadcasting_send_have_been;
        n_config_on_real = config_on_real;
        n_main_config_now = main_config_now;
        n_layer1_config_now = layer1_config_now;
        n_layer1_config_phase = layer1_config_phase;
        n_layer2_config_now = layer2_config_now;
        n_layer2_config_phase = layer2_config_phase;
        n_layer3_config_now = layer3_config_now;
        n_layer3_config_phase = layer3_config_phase;
        n_config_counter = config_counter;
        n_config_counter_one_two_three = config_counter_one_two_three;
        n_config_dram_read_address = config_dram_read_address;
        n_config_dram_word = config_dram_word;
        n_config_dram_word_ready = config_dram_word_ready;
        n_config_dram_word_request_have_been = config_dram_word_request_have_been;

        n_sample_num = sample_num;
        n_sample_num_transition_cnt = sample_num_transition_cnt;

        n_queuing_request_send_have_been = queuing_request_send_have_been;

        n_training_streaming_ongoing = training_streaming_ongoing;
        n_inference_streaming_ongoing = inference_streaming_ongoing;
        n_queuing_first_time = queuing_first_time;
        n_read_address_for_data = read_address_for_data;

        n_sample_data_buffer = sample_data_buffer;
        n_sample_data_buffer_num = sample_data_buffer_num;
        n_sample_data_buffer_read_request_cnt = sample_data_buffer_read_request_cnt;
        n_sample_data_buffer_cnt = sample_data_buffer_cnt;
        n_sample_data_buffer_stop_read_request = sample_data_buffer_stop_read_request;

        // n_sample_data_buffer2 = sample_data_buffer2;
        n_sample_data_buffer2_gesture = sample_data_buffer2_gesture;
        n_sample_data_buffer2_nmnist = sample_data_buffer2_nmnist;
        n_sample_data_buffer2_ntidigits = sample_data_buffer2_ntidigits;
        n_sample_data_buffer2_cnt_small = sample_data_buffer2_cnt_small;
        n_sample_data_buffer2_busy = sample_data_buffer2_busy;
        n_sample_data_buffer2_time_cnt = sample_data_buffer2_time_cnt;

        n_this_sample_label = this_sample_label;
        n_this_epoch_finish = this_epoch_finish;
        n_this_sample_done = this_sample_done;

        n_gesture_label_and_data_one_timestep = gesture_label_and_data_one_timestep;
        n_nmnist_label_and_data_one_timestep = nmnist_label_and_data_one_timestep;
        n_ntidigits_label_and_data_one_timestep = ntidigits_label_and_data_one_timestep;
        n_dataset_label_and_data_one_timestep_ready = dataset_label_and_data_one_timestep_ready;

        n_sample_num_executed = sample_num_executed;

        // config_value = 0;
        n_config_value_main = config_value_main;
        n_config_value_layer1 = config_value_layer1;
        n_config_value_layer2 = config_value_layer2;
        n_config_value_layer3 = config_value_layer3;
        n_config_value_ready = config_value_ready;






        app_en = 0;
        app_cmd = 0;
        app_addr = 0;
        app_wdf_wren = 0;
        app_wdf_data = 0;
        app_wdf_end = 0;
        app_wdf_mask = 0;
        
        fifo_p2d_data_rd_en = 0;










        if (!fifo_d2p_command_full) begin
            if (dram_reset_complete_trg_have_been_sent == 0 && init_calib_complete) begin
                fifo_d2p_command_wr_en = 1;
                fifo_d2p_command_din = {{17{1'b0}}, 15'd3};
                n_dram_reset_complete_trg_have_been_sent = 1;
            end 
        end

        if (fifo_p2d_command_valid) begin
            if (fifo_p2d_command_dout[14:0] == 1) begin
                if (!fifo_d2a_command_full) begin
                    fifo_p2d_command_rd_en = 1;
                    fifo_d2a_command_wr_en = 1;
                    fifo_d2a_command_din = fifo_p2d_command_dout;
                    if (config_d_domain_setting_cnt == 0) begin
                        n_d_config_asic_mode = fifo_p2d_command_dout[15 +: 2];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 1) begin
                        n_d_config_training_epochs = fifo_p2d_command_dout[15 +: 16];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 2) begin
                        n_d_config_inference_epochs = fifo_p2d_command_dout[15 +: 16];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 3) begin
                        n_d_config_dataset = fifo_p2d_command_dout[15 +: 2];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 4) begin
                        n_d_config_timesteps = fifo_p2d_command_dout[15 +: 16];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 5) begin
                        n_d_config_input_size_layer1_define = fifo_p2d_command_dout[15 +: 16];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 6) begin
                        n_d_config_long_time_input_streaming_mode = fifo_p2d_command_dout[15 +: 1];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 7) begin
                        n_d_config_binary_classifier_mode = fifo_p2d_command_dout[15 +: 1];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 8) begin
                        n_d_config_loser_encourage_mode = fifo_p2d_command_dout[15 +: 1];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    // end else if (config_d_domain_setting_cnt >= 9 && config_d_domain_setting_cnt <= 38) begin
                    //     n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    // end 
                    end else if (config_d_domain_setting_cnt == 9) begin
                        n_d_config_layer1_cut_list[17*0 +: 17] = fifo_p2d_command_dout[15 +: 17];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 10) begin
                        n_d_config_layer1_cut_list[17*1 +: 17] = fifo_p2d_command_dout[15 +: 17];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 11) begin
                        n_d_config_layer1_cut_list[17*2 +: 17] = fifo_p2d_command_dout[15 +: 17];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 12) begin
                        n_d_config_layer1_cut_list[17*3 +: 17] = fifo_p2d_command_dout[15 +: 17];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 13) begin
                        n_d_config_layer1_cut_list[17*4 +: 17] = fifo_p2d_command_dout[15 +: 17];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 14) begin
                        n_d_config_layer1_cut_list[17*5 +: 17] = fifo_p2d_command_dout[15 +: 17];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 15) begin
                        n_d_config_layer1_cut_list[17*6 +: 17] = fifo_p2d_command_dout[15 +: 17];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 16) begin
                        n_d_config_layer1_cut_list[17*7 +: 17] = fifo_p2d_command_dout[15 +: 17];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 17) begin
                        n_d_config_layer1_cut_list[17*8 +: 17] = fifo_p2d_command_dout[15 +: 17];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 18) begin
                        n_d_config_layer1_cut_list[17*9 +: 17] = fifo_p2d_command_dout[15 +: 17];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 19) begin
                        n_d_config_layer1_cut_list[17*10 +: 17] = fifo_p2d_command_dout[15 +: 17];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 20) begin
                        n_d_config_layer1_cut_list[17*11 +: 17] = fifo_p2d_command_dout[15 +: 17];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 21) begin
                        n_d_config_layer1_cut_list[17*12 +: 17] = fifo_p2d_command_dout[15 +: 17];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 22) begin
                        n_d_config_layer1_cut_list[17*13 +: 17] = fifo_p2d_command_dout[15 +: 17];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 23) begin
                        n_d_config_layer1_cut_list[17*14 +: 17] = fifo_p2d_command_dout[15 +: 17];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 24) begin
                        n_d_config_layer2_cut_list[16*0 +: 16] = fifo_p2d_command_dout[15 +: 16];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 25) begin
                        n_d_config_layer2_cut_list[16*1 +: 16] = fifo_p2d_command_dout[15 +: 16];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 26) begin
                        n_d_config_layer2_cut_list[16*2 +: 16] = fifo_p2d_command_dout[15 +: 16];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 27) begin
                        n_d_config_layer2_cut_list[16*3 +: 16] = fifo_p2d_command_dout[15 +: 16];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 28) begin
                        n_d_config_layer2_cut_list[16*4 +: 16] = fifo_p2d_command_dout[15 +: 16];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 29) begin
                        n_d_config_layer2_cut_list[16*5 +: 16] = fifo_p2d_command_dout[15 +: 16];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 30) begin
                        n_d_config_layer2_cut_list[16*6 +: 16] = fifo_p2d_command_dout[15 +: 16];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 31) begin
                        n_d_config_layer2_cut_list[16*7 +: 16] = fifo_p2d_command_dout[15 +: 16];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 32) begin
                        n_d_config_layer2_cut_list[16*8 +: 16] = fifo_p2d_command_dout[15 +: 16];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 33) begin
                        n_d_config_layer2_cut_list[16*9 +: 16] = fifo_p2d_command_dout[15 +: 16];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 34) begin
                        n_d_config_layer2_cut_list[16*10 +: 16] = fifo_p2d_command_dout[15 +: 16];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 35) begin
                        n_d_config_layer2_cut_list[16*11 +: 16] = fifo_p2d_command_dout[15 +: 16];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 36) begin
                        n_d_config_layer2_cut_list[16*12 +: 16] = fifo_p2d_command_dout[15 +: 16];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 37) begin
                        n_d_config_layer2_cut_list[16*13 +: 16] = fifo_p2d_command_dout[15 +: 16];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end else if (config_d_domain_setting_cnt == 38) begin
                        n_d_config_layer2_cut_list[16*14 +: 16] = fifo_p2d_command_dout[15 +: 16];
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end
                    // else if (config_d_domain_setting_cnt == 39) begin
                        // @ last no cnt increment
                    // end
                end
            end else if (fifo_p2d_command_dout[14:0] == 4) begin
                if (dram_address_transition_cnt == 0) begin
                    n_write_count = 0;
                    fifo_p2d_command_rd_en = 1;
                    n_dram_address_transition_cnt = dram_address_transition_cnt + 1;
                    n_dram_address[0 +: 16] = fifo_p2d_command_dout[15 +: 16];
                end else if (dram_address_transition_cnt == 1) begin
                    fifo_p2d_command_rd_en = 1;
                    n_dram_address_transition_cnt = dram_address_transition_cnt + 1;
                    n_dram_address[16 +: 16] = fifo_p2d_command_dout[15 +: 16];
                end else if (dram_address_transition_cnt == 2) begin
                    fifo_p2d_command_rd_en = 1;
                    n_dram_address_transition_cnt = dram_address_transition_cnt + 1;
                    n_dram_address_last[0 +: 16] = fifo_p2d_command_dout[15 +: 16];
                end else if (dram_address_transition_cnt == 3) begin
                    if (!fifo_d2p_command_full) begin
                        fifo_p2d_command_rd_en = 1;
                        n_dram_address_transition_cnt = 0;
                        n_dram_address_last[16 +: 16] = fifo_p2d_command_dout[15 +: 16];
                        fifo_d2p_command_wr_en = 1;
                        fifo_d2p_command_din = {17'd0, 15'd4};
                    end
                end            
            end else if (fifo_p2d_command_dout[14:0] == 11) begin
                if (sample_num_transition_cnt == 0) begin
                    if (!fifo_d2a_command_full) begin
                        fifo_d2a_command_wr_en = 1;
                        fifo_d2a_command_din = fifo_p2d_command_dout;

                        fifo_p2d_command_rd_en = 1;
                        n_sample_num_transition_cnt = sample_num_transition_cnt + 1;
                        n_sample_num[0 +: 16] = fifo_p2d_command_dout[15 +: 16];
                    end
                end else if (sample_num_transition_cnt == 1) begin
                    if (!fifo_d2a_command_full) begin
                        fifo_d2a_command_wr_en = 1;
                        fifo_d2a_command_din = fifo_p2d_command_dout;

                        fifo_p2d_command_rd_en = 1;
                        n_sample_num_transition_cnt = 0;
                        n_sample_num[16 +: 16] = fifo_p2d_command_dout[15 +: 16];
                    end
                end
            end else if (fifo_p2d_command_dout[14:0] == 6) begin
                if (!fifo_d2p_command_full) begin
                    fifo_p2d_command_rd_en = 1;
                    fifo_d2p_command_wr_en = 1;
                    fifo_d2p_command_din = {write_count[16:0], 15'd6};
                end
            end else if (fifo_p2d_command_dout[14:0] == 7) begin
                if (!fifo_d2a_command_full) begin
                    fifo_p2d_command_rd_en = 1;
                    fifo_d2a_command_wr_en = 1;
                    fifo_d2a_command_din = fifo_p2d_command_dout;
                end
            end else if (fifo_p2d_command_dout[14:0] == 8) begin
                if (config_on_broadcasting_send_have_been == 0) begin
                    if (!fifo_d2a_command_full) begin
                        fifo_d2a_command_wr_en = 1;
                        fifo_d2a_command_din = fifo_p2d_command_dout;

                        n_config_on_broadcasting_send_have_been = 1;
                    end
                end else begin
                    if (fifo_a2d_command_valid && fifo_a2d_command_dout[14:0] == 8) begin
                        fifo_p2d_command_rd_en = 1;
                        fifo_a2d_command_rd_en = 1;
                        n_config_on_real = 1;
                        n_main_config_now = 1;
                        n_layer1_config_now = 0;
                        n_layer2_config_now = 0;
                        n_layer3_config_now = 0;
                        
                        n_config_on_broadcasting_send_have_been = 0;
                    end
                end
            end else if (fifo_p2d_command_dout[14:0] == 10) begin
                if (streaming_wait_cycle_send_have_been == 0) begin
                    if (!fifo_d2a_command_full) begin
                        fifo_d2a_command_wr_en = 1;
                        fifo_d2a_command_din = fifo_p2d_command_dout;

                        n_streaming_wait_cycle_send_have_been = 1;
                    end
                end else begin
                    if (fifo_a2d_command_valid && fifo_a2d_command_dout[14:0] == 10) begin
                        if (!fifo_d2p_command_full) begin
                            fifo_p2d_command_rd_en = 1;

                            fifo_a2d_command_rd_en = 1;

                            fifo_d2p_command_wr_en = 1;
                            fifo_d2p_command_din = fifo_a2d_command_dout;

                            n_streaming_wait_cycle_send_have_been = 0;
                        end
                    end
                end
            end else if (fifo_p2d_command_dout[14:0] == 12) begin
                if (queuing_request_send_have_been == 0) begin
                    if (!fifo_d2a_command_full) begin
                        fifo_d2a_command_wr_en = 1;
                        fifo_d2a_command_din = fifo_p2d_command_dout;

                        n_queuing_request_send_have_been = 1;
                    end
                end else begin
                    if (fifo_a2d_command_valid && fifo_a2d_command_dout[14:0] == 12) begin
                        fifo_p2d_command_rd_en = 1;
                        fifo_a2d_command_rd_en = 1;

                        n_training_streaming_ongoing = 1;
                        n_queuing_request_send_have_been = 0;
                        n_queuing_first_time = 1;

                        n_read_address_for_data = dram_address;
                    end
                end
            end else if (fifo_p2d_command_dout[14:0] == 13) begin
                if (queuing_request_send_have_been == 0) begin
                    if (!fifo_d2a_command_full) begin
                        fifo_d2a_command_wr_en = 1;
                        fifo_d2a_command_din = fifo_p2d_command_dout;

                        n_queuing_request_send_have_been = 1;
                    end
                end else begin
                    if (fifo_a2d_command_valid && fifo_a2d_command_dout[14:0] == 13) begin
                        fifo_p2d_command_rd_en = 1;
                        fifo_a2d_command_rd_en = 1;

                        n_inference_streaming_ongoing = 1;
                        n_queuing_request_send_have_been = 0;
                        n_queuing_first_time = 1;

                        n_read_address_for_data = dram_address;
                    end
                end
            end else if (fifo_p2d_command_dout[14:0] == 16) begin
                if (!fifo_d2a_command_full) begin
                    fifo_p2d_command_rd_en = 1;
                    fifo_d2a_command_wr_en = 1;
                    fifo_d2a_command_din = fifo_p2d_command_dout;
                end
            end else if (fifo_p2d_command_dout[14:0] == 17) begin
                if (!fifo_d2a_command_full) begin
                    fifo_p2d_command_rd_en = 1;
                    fifo_d2a_command_wr_en = 1;
                    fifo_d2a_command_din = fifo_p2d_command_dout;
                end
            end else if (fifo_p2d_command_dout[14:0] == 19) begin
                if (!fifo_d2a_command_full) begin
                    fifo_p2d_command_rd_en = 1;
                    fifo_d2a_command_wr_en = 1;
                    fifo_d2a_command_din = fifo_p2d_command_dout;
                end
            end else if (fifo_p2d_command_dout[14:0] == 20) begin
                if (!fifo_d2a_command_full) begin
                    fifo_p2d_command_rd_en = 1;
                    fifo_d2a_command_wr_en = 1;
                    fifo_d2a_command_din = fifo_p2d_command_dout;
                end
            end else if (fifo_p2d_command_dout[14:0] == 21) begin
                if (!fifo_d2a_command_full) begin
                    fifo_p2d_command_rd_en = 1;
                    fifo_d2a_command_wr_en = 1;
                    fifo_d2a_command_din = fifo_p2d_command_dout;
                end
            end
        end



        if (training_streaming_ongoing || inference_streaming_ongoing) begin
            if (queuing_first_time) begin   
                if (fifo_d2a_data_full || sample_data_buffer_stop_read_request) begin
                    if (!fifo_d2p_command_full) begin
                        fifo_d2p_command_wr_en = 1;
                        if (training_streaming_ongoing) begin
                            fifo_d2p_command_din = {17'd0, 15'd12};
                        end else if (inference_streaming_ongoing) begin
                            fifo_d2p_command_din = {17'd0, 15'd13};
                        end
                        n_queuing_first_time = 0;
                    end
                end
            end
        end



        if (training_streaming_ongoing || inference_streaming_ongoing) begin
            if (d_config_dataset == 0) begin
                if (sample_data_buffer_stop_read_request == 0) begin
                    if (sample_data_buffer_read_request_cnt != DVS_GESTURE_READ_REQUEST_PER_SAMPLE) begin
                        if (app_rdy) begin
                            app_en = 1;
                            app_cmd = DRAM_READ;
                            app_addr = read_address_for_data;
                            n_sample_data_buffer_read_request_cnt = sample_data_buffer_read_request_cnt + 1;
                            if (read_address_for_data == dram_address_last) begin
                                if (sample_data_buffer_num == sample_num - 1) begin
                                    n_sample_data_buffer_stop_read_request = 1;
                                end else begin
                                    n_read_address_for_data = dram_address;
                                end
                            end else begin
                                n_read_address_for_data = read_address_for_data + 8;
                            end
                        end
                    end
                end

                if (sample_data_buffer_cnt != DVS_GESTURE_READ_REQUEST_PER_SAMPLE) begin
                    if (app_rd_data_valid) begin
                        n_sample_data_buffer = {app_rd_data, sample_data_buffer[256 +: DVS_GESTURE_BITS_PER_SAMPLE-256]};
                        n_sample_data_buffer_cnt = sample_data_buffer_cnt + 1;
                    end
                end else begin
                    if (!sample_data_buffer2_busy) begin
                        n_sample_data_buffer2_busy = 1;
                        n_sample_data_buffer2_gesture = sample_data_buffer[0 +: DVS_GESTURE_BITS_PER_SAMPLE];
                        n_sample_data_buffer_read_request_cnt = 0;
                        n_sample_data_buffer_cnt = 0;
                        if (sample_data_buffer_num != sample_num - 1) begin
                            n_sample_data_buffer_num = sample_data_buffer_num + 1;
                        end else begin
                            n_sample_data_buffer_num = 0;
                        end
                    end
                end

                if (sample_data_buffer2_busy) begin
                    if (dataset_label_and_data_one_timestep_ready == 0) begin
                        n_dataset_label_and_data_one_timestep_ready = 1;
                        n_gesture_label_and_data_one_timestep = sample_data_buffer2_gesture[0 * DVS_GESTURE_BITS_PER_TIME_IN_DRAM +: DVS_GESTURE_BITS_PER_TIME_IN_DRAM];
                    end else begin
                        if (!fifo_d2a_data_full) begin
                            fifo_d2a_data_wr_en = 1;
                            // fixme
                            // gesture_label_and_data_one_timestep = sample_data_buffer2[sample_data_buffer2_time_cnt * DVS_GESTURE_BITS_PER_TIME_IN_DRAM +: DVS_GESTURE_BITS_PER_TIME_IN_DRAM];
                            // gesture_label_and_data_one_timestep = sample_data_buffer2[0 * DVS_GESTURE_BITS_PER_TIME_IN_DRAM +: DVS_GESTURE_BITS_PER_TIME_IN_DRAM];
                            if (sample_data_buffer2_cnt_small == 0) begin
                                n_this_sample_label = gesture_label_and_data_one_timestep[(CLOCK_INPUT_SPIKE_COLLECT_LONG-1) * BIT_WIDTH_INPUT_STREAMING_DATA + 56 +: 4];
                                n_this_epoch_finish = (sample_num_executed == sample_num - 1) && (sample_data_buffer2_time_cnt == d_config_timesteps - 1);
                                n_this_sample_done = (sample_data_buffer2_time_cnt == d_config_timesteps - 1);
                            end

                            if (sample_data_buffer2_cnt_small != CLOCK_INPUT_SPIKE_COLLECT_LONG - 1) begin
                                n_sample_data_buffer2_cnt_small = sample_data_buffer2_cnt_small + 1;
                                n_gesture_label_and_data_one_timestep = gesture_label_and_data_one_timestep >> BIT_WIDTH_INPUT_STREAMING_DATA;
                                fifo_d2a_data_din = gesture_label_and_data_one_timestep[0 * BIT_WIDTH_INPUT_STREAMING_DATA +: BIT_WIDTH_INPUT_STREAMING_DATA];
                            end else begin
                                if (sample_data_buffer2_time_cnt != d_config_timesteps - 1) begin
                                    n_sample_data_buffer2_cnt_small = 0;
                                    n_gesture_label_and_data_one_timestep = gesture_label_and_data_one_timestep >> BIT_WIDTH_INPUT_STREAMING_DATA;
                                    fifo_d2a_data_din = {4'd0, this_sample_label, this_epoch_finish, this_sample_done, gesture_label_and_data_one_timestep[0 * BIT_WIDTH_INPUT_STREAMING_DATA +: 56]};
                                    n_sample_data_buffer2_time_cnt = sample_data_buffer2_time_cnt + 1;
                                    n_sample_data_buffer2_gesture = sample_data_buffer2_gesture >> DVS_GESTURE_BITS_PER_TIME_IN_DRAM;
                                    
                                    n_dataset_label_and_data_one_timestep_ready = 0;
                                end else begin
                                    n_sample_data_buffer2_cnt_small = 0;
                                    n_gesture_label_and_data_one_timestep = gesture_label_and_data_one_timestep >> BIT_WIDTH_INPUT_STREAMING_DATA;
                                    fifo_d2a_data_din = {4'd0, this_sample_label, this_epoch_finish, this_sample_done, gesture_label_and_data_one_timestep[0 * BIT_WIDTH_INPUT_STREAMING_DATA +: 56]};
                                    n_sample_data_buffer2_time_cnt = 0;
                                    n_sample_data_buffer2_gesture = sample_data_buffer2_gesture >> DVS_GESTURE_BITS_PER_TIME_IN_DRAM;

                                    n_dataset_label_and_data_one_timestep_ready = 0;
                                    n_sample_num_executed = sample_num_executed + 1;
                                    n_sample_data_buffer2_busy = 0;
                                end
                            end
                        end
                    end
                end
            end else if (d_config_dataset == 1) begin
                if (sample_data_buffer_stop_read_request == 0) begin
                    if (sample_data_buffer_read_request_cnt != N_MNIST_READ_REQUEST_PER_SAMPLE) begin
                        if (app_rdy) begin
                            app_en = 1;
                            app_cmd = DRAM_READ;
                            app_addr = read_address_for_data;
                            n_sample_data_buffer_read_request_cnt = sample_data_buffer_read_request_cnt + 1;
                            if (read_address_for_data == dram_address_last) begin
                                if (sample_data_buffer_num == sample_num - 1) begin
                                    n_sample_data_buffer_stop_read_request = 1;
                                end else begin
                                    n_read_address_for_data = dram_address;
                                end
                            end else begin
                                n_read_address_for_data = read_address_for_data + 8;
                            end
                        end
                    end
                end

                if (sample_data_buffer_cnt != N_MNIST_READ_REQUEST_PER_SAMPLE) begin
                    if (app_rd_data_valid) begin
                        n_sample_data_buffer = {app_rd_data, sample_data_buffer[256 +: DVS_GESTURE_BITS_PER_SAMPLE-256]};
                        n_sample_data_buffer_cnt = sample_data_buffer_cnt + 1;
                    end
                end else begin
                    if (!sample_data_buffer2_busy) begin
                        n_sample_data_buffer2_busy = 1;
                        n_sample_data_buffer2_nmnist = sample_data_buffer[0 + (DVS_GESTURE_BITS_PER_SAMPLE-N_MNIST_BITS_PER_SAMPLE) +: N_MNIST_BITS_PER_SAMPLE];
                        n_sample_data_buffer_read_request_cnt = 0;
                        n_sample_data_buffer_cnt = 0;
                        if (sample_data_buffer_num != sample_num - 1) begin
                            n_sample_data_buffer_num = sample_data_buffer_num + 1;
                        end else begin
                            n_sample_data_buffer_num = 0;
                        end
                    end
                end

                if (sample_data_buffer2_busy) begin
                    if (dataset_label_and_data_one_timestep_ready == 0) begin
                        n_dataset_label_and_data_one_timestep_ready = 1;
                        n_nmnist_label_and_data_one_timestep = sample_data_buffer2_nmnist[0 * N_MNIST_BITS_PER_TIME_IN_DRAM +: N_MNIST_BITS_PER_TIME_IN_DRAM];
                    end else begin
                        if (!fifo_d2a_data_full) begin
                            fifo_d2a_data_wr_en = 1;
                            // fixme
                            // nmnist_label_and_data_one_timestep = sample_data_buffer2[sample_data_buffer2_time_cnt * N_MNIST_BITS_PER_TIME_IN_DRAM +: N_MNIST_BITS_PER_TIME_IN_DRAM];
                            // nmnist_label_and_data_one_timestep = sample_data_buffer2[0 * N_MNIST_BITS_PER_TIME_IN_DRAM +: N_MNIST_BITS_PER_TIME_IN_DRAM];
                            if (sample_data_buffer2_cnt_small == 0) begin
                                n_this_sample_label = nmnist_label_and_data_one_timestep[(CLOCK_INPUT_SPIKE_COLLECT_SHORT-1) * BIT_WIDTH_INPUT_STREAMING_DATA + 50 +: 4];
                                n_this_epoch_finish = (sample_num_executed == sample_num - 1) && (sample_data_buffer2_time_cnt == d_config_timesteps - 1);
                                n_this_sample_done = (sample_data_buffer2_time_cnt == d_config_timesteps - 1);
                            end
                            
                            if (sample_data_buffer2_cnt_small != CLOCK_INPUT_SPIKE_COLLECT_SHORT - 1) begin
                                n_sample_data_buffer2_cnt_small = sample_data_buffer2_cnt_small + 1;
                                n_nmnist_label_and_data_one_timestep = nmnist_label_and_data_one_timestep >> BIT_WIDTH_INPUT_STREAMING_DATA;
                                fifo_d2a_data_din = nmnist_label_and_data_one_timestep[0 * BIT_WIDTH_INPUT_STREAMING_DATA +: BIT_WIDTH_INPUT_STREAMING_DATA];
                            end else begin
                                if (sample_data_buffer2_time_cnt != d_config_timesteps - 1) begin
                                    n_sample_data_buffer2_cnt_small = 0;
                                    n_nmnist_label_and_data_one_timestep = nmnist_label_and_data_one_timestep >> BIT_WIDTH_INPUT_STREAMING_DATA;
                                    fifo_d2a_data_din = {10'd0, this_sample_label, this_epoch_finish, this_sample_done, nmnist_label_and_data_one_timestep[0 * BIT_WIDTH_INPUT_STREAMING_DATA +: 50]};
                                    n_sample_data_buffer2_time_cnt = sample_data_buffer2_time_cnt + 1;
                                    n_sample_data_buffer2_nmnist = sample_data_buffer2_nmnist >> N_MNIST_BITS_PER_TIME_IN_DRAM;
                                    
                                    n_dataset_label_and_data_one_timestep_ready = 0;
                                end else begin
                                    n_sample_data_buffer2_cnt_small = 0;
                                    n_nmnist_label_and_data_one_timestep = nmnist_label_and_data_one_timestep >> BIT_WIDTH_INPUT_STREAMING_DATA;
                                    fifo_d2a_data_din = {10'd0, this_sample_label, this_epoch_finish, this_sample_done, nmnist_label_and_data_one_timestep[0 * BIT_WIDTH_INPUT_STREAMING_DATA +: 50]};
                                    n_sample_data_buffer2_time_cnt = 0;
                                    n_sample_data_buffer2_nmnist = sample_data_buffer2_nmnist >> N_MNIST_BITS_PER_TIME_IN_DRAM;

                                    n_dataset_label_and_data_one_timestep_ready = 0;
                                    n_sample_num_executed = sample_num_executed + 1;
                                    n_sample_data_buffer2_busy = 0;
                                end
                            end
                        end
                    end
                end
            end else if (d_config_dataset == 2) begin
                if (sample_data_buffer_stop_read_request == 0) begin
                    if (sample_data_buffer_read_request_cnt != NTIDIGITS_READ_REQUEST_PER_SAMPLE) begin
                        if (app_rdy) begin
                            app_en = 1;
                            app_cmd = DRAM_READ;
                            app_addr = read_address_for_data;
                            n_sample_data_buffer_read_request_cnt = sample_data_buffer_read_request_cnt + 1;
                            if (read_address_for_data == dram_address_last) begin
                                if (sample_data_buffer_num == sample_num - 1) begin
                                    n_sample_data_buffer_stop_read_request = 1;
                                end else begin
                                    n_read_address_for_data = dram_address;
                                end
                            end else begin
                                n_read_address_for_data = read_address_for_data + 8;
                            end
                        end
                    end
                end

                if (sample_data_buffer_cnt != NTIDIGITS_READ_REQUEST_PER_SAMPLE) begin
                    if (app_rd_data_valid) begin
                        n_sample_data_buffer = {app_rd_data, sample_data_buffer[256 +: DVS_GESTURE_BITS_PER_SAMPLE-256]};
                        n_sample_data_buffer_cnt = sample_data_buffer_cnt + 1;
                    end
                end else begin
                    if (!sample_data_buffer2_busy) begin
                        n_sample_data_buffer2_busy = 1;
                        n_sample_data_buffer2_nmnist = sample_data_buffer[0 + (DVS_GESTURE_BITS_PER_SAMPLE-NTIDIGITS_BITS_PER_SAMPLE) +: NTIDIGITS_BITS_PER_SAMPLE];
                        n_sample_data_buffer_read_request_cnt = 0;
                        n_sample_data_buffer_cnt = 0;
                        if (sample_data_buffer_num != sample_num - 1) begin
                            n_sample_data_buffer_num = sample_data_buffer_num + 1;
                        end else begin
                            n_sample_data_buffer_num = 0;
                        end
                    end
                end

                if (sample_data_buffer2_busy) begin
                    if (dataset_label_and_data_one_timestep_ready == 0) begin
                        n_dataset_label_and_data_one_timestep_ready = 1;
                        n_ntidigits_label_and_data_one_timestep = {sample_data_buffer2_ntidigits[0 * NTIDIGITS_BITS_PER_TIME_IN_DRAM + NTIDIGITS_BITS_PER_TIME_IN_DRAM - 4 +: 4], 66'd0, sample_data_buffer2_ntidigits[0 * NTIDIGITS_BITS_PER_TIME_IN_DRAM +: NTIDIGITS_BITS_PER_TIME_IN_DRAM - 4]};
                    end else begin
                        if (!fifo_d2a_data_full) begin
                            fifo_d2a_data_wr_en = 1;
                            // fixme
                            // ntidigits_label_and_data_one_timestep = {sample_data_buffer2[sample_data_buffer2_time_cnt * NTIDIGITS_BITS_PER_TIME_IN_DRAM - 4 +: 4], 66'd0, sample_data_buffer2[sample_data_buffer2_time_cnt * NTIDIGITS_BITS_PER_TIME_IN_DRAM +: NTIDIGITS_BITS_PER_TIME_IN_DRAM - 4]};
                            // ntidigits_label_and_data_one_timestep = {sample_data_buffer2[0 * NTIDIGITS_BITS_PER_TIME_IN_DRAM + NTIDIGITS_BITS_PER_TIME_IN_DRAM - 4 +: 4], 66'd0, sample_data_buffer2[0 * NTIDIGITS_BITS_PER_TIME_IN_DRAM +: NTIDIGITS_BITS_PER_TIME_IN_DRAM - 4]};
                            if (sample_data_buffer2_cnt_small == 0) begin
                                n_this_sample_label = ntidigits_label_and_data_one_timestep[(CLOCK_INPUT_SPIKE_COLLECT_SHORT-1) * BIT_WIDTH_INPUT_STREAMING_DATA + 50 +: 4];
                                n_this_epoch_finish = (sample_num_executed == sample_num - 1) && (sample_data_buffer2_time_cnt == d_config_timesteps - 1);
                                n_this_sample_done = (sample_data_buffer2_time_cnt == d_config_timesteps - 1);
                            end

                            if (sample_data_buffer2_cnt_small != CLOCK_INPUT_SPIKE_COLLECT_SHORT - 1) begin
                                n_sample_data_buffer2_cnt_small = sample_data_buffer2_cnt_small + 1;
                                n_ntidigits_label_and_data_one_timestep = ntidigits_label_and_data_one_timestep >> BIT_WIDTH_INPUT_STREAMING_DATA;
                                fifo_d2a_data_din = ntidigits_label_and_data_one_timestep[0 * BIT_WIDTH_INPUT_STREAMING_DATA +: BIT_WIDTH_INPUT_STREAMING_DATA];
                            end else begin
                                if (sample_data_buffer2_time_cnt != d_config_timesteps - 1) begin
                                    n_sample_data_buffer2_cnt_small = 0;
                                    n_ntidigits_label_and_data_one_timestep = ntidigits_label_and_data_one_timestep >> BIT_WIDTH_INPUT_STREAMING_DATA;
                                    fifo_d2a_data_din = {10'd0, this_sample_label, this_epoch_finish, this_sample_done, ntidigits_label_and_data_one_timestep[0 * BIT_WIDTH_INPUT_STREAMING_DATA +: 50]};
                                    n_sample_data_buffer2_time_cnt = sample_data_buffer2_time_cnt + 1;
                                    n_sample_data_buffer2_ntidigits = sample_data_buffer2_ntidigits >> NTIDIGITS_BITS_PER_TIME_IN_DRAM;
                                    
                                    n_dataset_label_and_data_one_timestep_ready = 0;
                                end else begin
                                    n_sample_data_buffer2_cnt_small = 0;
                                    n_ntidigits_label_and_data_one_timestep = ntidigits_label_and_data_one_timestep >> BIT_WIDTH_INPUT_STREAMING_DATA;
                                    fifo_d2a_data_din = {10'd0, this_sample_label, this_epoch_finish, this_sample_done, ntidigits_label_and_data_one_timestep[0 * BIT_WIDTH_INPUT_STREAMING_DATA +: 50]};
                                    n_sample_data_buffer2_time_cnt = 0;
                                    n_sample_data_buffer2_ntidigits = sample_data_buffer2_ntidigits >> NTIDIGITS_BITS_PER_TIME_IN_DRAM;

                                    n_dataset_label_and_data_one_timestep_ready = 0;
                                    n_sample_num_executed = sample_num_executed + 1;
                                    n_sample_data_buffer2_busy = 0;
                                end
                            end
                        end
                    end
                end
            end
        end
        


        if (fifo_a2d_command_valid) begin
            if (fifo_a2d_command_dout[14:0] == 2) begin
                if (config_d_domain_setting_cnt == 39) begin
                    if (!fifo_d2p_command_full) begin
                        fifo_a2d_command_rd_en = 1;
                        fifo_d2p_command_wr_en = 1;
                        fifo_d2p_command_din = fifo_a2d_command_dout;
                        n_config_d_domain_setting_cnt = 0;
                    end
                end
            end else if (fifo_a2d_command_dout[14:0] == 7) begin
                if (!fifo_d2p_command_full) begin
                    fifo_a2d_command_rd_en = 1;
                    fifo_d2p_command_wr_en = 1;
                    fifo_d2p_command_din = fifo_a2d_command_dout;
                end
            end else if (fifo_a2d_command_dout[14:0] == 9) begin
                if (!fifo_d2p_command_full) begin
                    fifo_a2d_command_rd_en = 1;
                    fifo_d2p_command_wr_en = 1;
                    fifo_d2p_command_din = fifo_a2d_command_dout;
                end
            end else if (fifo_a2d_command_dout[14:0] == 11) begin
                if (!fifo_d2p_command_full) begin
                    fifo_a2d_command_rd_en = 1;
                    fifo_d2p_command_wr_en = 1;
                    fifo_d2p_command_din = fifo_a2d_command_dout;
                end
            end else if (fifo_a2d_command_dout[14:0] == 14) begin // training complete
                if (!fifo_d2p_command_full) begin
                    fifo_a2d_command_rd_en = 1;
                    fifo_d2p_command_wr_en = 1;
                    fifo_d2p_command_din = {sample_num_executed[16:0], 15'd14};
                    n_sample_num_executed = 0;
                    n_sample_data_buffer_stop_read_request = 0;
                    n_training_streaming_ongoing = 0;
                    // n_read_address_for_data = 0; // no needs reset
                end
            end else if (fifo_a2d_command_dout[14:0] == 15) begin // inference complete
                if (!fifo_d2p_command_full) begin
                    fifo_a2d_command_rd_en = 1;
                    fifo_d2p_command_wr_en = 1;
                    fifo_d2p_command_din = {sample_num_executed[16:0], 15'd15};
                    n_sample_num_executed = 0;
                    n_sample_data_buffer_stop_read_request = 0;
                    n_inference_streaming_ongoing = 0;
                    // n_read_address_for_data = 0; // no needs reset
                end
            end else if (fifo_a2d_command_dout[14:0] == 18) begin
                if (!fifo_d2p_command_full) begin
                    fifo_a2d_command_rd_en = 1;
                    fifo_d2p_command_wr_en = 1;
                    fifo_d2p_command_din = fifo_a2d_command_dout;
                end
            end else if (fifo_a2d_command_dout[14:0] == 19) begin
                if (!fifo_d2p_command_full) begin
                    fifo_a2d_command_rd_en = 1;
                    fifo_d2p_command_wr_en = 1;
                    fifo_d2p_command_din = fifo_a2d_command_dout;
                end
            end else if (fifo_a2d_command_dout[14:0] == 21) begin
                if (!fifo_d2p_command_full) begin
                    fifo_a2d_command_rd_en = 1;
                    fifo_d2p_command_wr_en = 1;
                    fifo_d2p_command_din = fifo_a2d_command_dout;
                end
            end
        end




        if (fifo_p2d_data_valid) begin
            if (app_rdy && app_wdf_rdy) begin
                fifo_p2d_data_rd_en = 1;
                app_en = 1;
                app_cmd = DRAM_WRITE;
                app_addr = dram_address + write_count;
                app_wdf_wren = 1;
                app_wdf_data = fifo_p2d_data_dout;
                // app_wdf_data = fifo_p2d_data_dout_align;
                app_wdf_end = 1;
                app_wdf_mask = 0;
                n_write_count = write_count + 8; // 256bit / 32byte = 8
                if (dram_address_last == dram_address + write_count) begin
                    n_dram_writing_finish_flag = 1;
                end
            end
        end
        if (dram_writing_finish_flag) begin
            if (dram_writing_check_read_flag == 0) begin
                if (app_rdy) begin
                    n_dram_writing_check_read_flag = 1;
                    app_en = 1;
                    app_cmd = DRAM_READ;
                    app_addr = dram_address_last;
                end
            end else begin
                if (dram_writing_check_read_catch_flag == 0) begin
                    if (app_rd_data_valid) begin
                        n_dram_writing_check_read_catch_flag = 1;
                        n_app_rd_data_check = app_rd_data[16:0];
                        // n_app_rd_data_check = app_rd_data[16+128:128];
                    end
                end else begin
                    if (!fifo_d2p_command_full) begin
                        fifo_d2p_command_wr_en = 1;
                        fifo_d2p_command_din = {1'b0, app_rd_data_check[15:0], 15'd5};
                        n_dram_writing_finish_flag = 0;
                        n_dram_writing_check_read_flag = 0;
                        n_dram_writing_check_read_catch_flag = 0;
                    end
                end
            end
        end
        



        if (config_on_real) begin
                

            if (main_config_now) begin
                if (config_value_ready == 0) begin
                    n_config_value_main = {{(BIT_WIDTH_INPUT_STREAMING_DATA*3-1){1'b0}}, d_config_long_time_input_streaming_mode};
                    n_config_value_ready = 1;
                end else begin
                    if (!fifo_d2a_data_full) begin
                        fifo_d2a_data_wr_en = 1;
                        n_config_value_main = config_value_main >> BIT_WIDTH_INPUT_STREAMING_DATA;
                        if (config_counter_one_two_three != 2) begin
                            n_config_counter_one_two_three = config_counter_one_two_three + 1;
                        end else begin
                            n_config_counter_one_two_three = 0;
                            n_config_counter = 0;
                            n_main_config_now = 0;
                            n_layer1_config_now = 1;
                            n_layer1_config_phase[0] = 1;
                            n_layer2_config_now = 0;
                            n_layer3_config_now = 0;
                            n_config_value_ready = 0;
                        end
                    end
                end



            end else if (layer1_config_now) begin


                // if (config_counter  LAYER1_DEPTH_SRAM*LAYER1_SET_NUM) begin
                // end

                if (layer1_config_phase[0]) begin
                    if (config_dram_word_ready == 0) begin
                        if (config_dram_word_request_have_been == 0) begin
                            if (app_rdy) begin
                                app_en = 1;
                                app_cmd = DRAM_READ;
                                app_addr = config_dram_read_address;
                                n_config_dram_word_request_have_been = 1;
                                n_config_dram_read_address = config_dram_read_address + 8;
                            end
                        end else begin 
                            if (app_rd_data_valid) begin
                                n_config_dram_word = app_rd_data;
                                n_config_dram_word_request_have_been = 0;
                                n_config_dram_word_ready = 1;
                            end
                        end
                    end else begin
                        if (config_value_ready == 0) begin
                            n_config_value_layer1 = {{(BIT_WIDTH_INPUT_STREAMING_DATA*3-LAYER1_BIT_WIDTH_SRAM){1'b0}}, config_dram_word[0 +: LAYER1_BIT_WIDTH_SRAM]};
                            n_config_value_ready = 1;
                        end else begin
                            if (!fifo_d2a_data_full) begin
                                fifo_d2a_data_wr_en = 1;
                                n_config_value_layer1 = config_value_layer1 >> BIT_WIDTH_INPUT_STREAMING_DATA;
                                if (config_counter_one_two_three != 2) begin
                                    n_config_counter_one_two_three = config_counter_one_two_three + 1;
                                end else begin
                                    n_config_counter_one_two_three = 0;
                                    n_config_counter = config_counter + 1;
                                    
                                    if (config_counter == LAYER1_DEPTH_SRAM*LAYER1_SET_NUM - 1) begin
                                        n_layer1_config_phase[0] = 0;
                                        n_layer1_config_phase[1] = 1;
                                    end
                    
                                    n_config_dram_word_ready = 0;
                                    n_config_value_ready = 0;
                                end
                            end
                        end
                    end                        
                // end else if (config_counter < LAYER1_DEPTH_SRAM*LAYER1_SET_NUM+1) begin
                end else if (layer1_config_phase[1]) begin
                    if (config_value_ready == 0) begin
                        n_config_value_layer1 = {{(BIT_WIDTH_INPUT_STREAMING_DATA*3-LAYER1_BIT_WIDTH_MEMBRANE){1'b0}}, d_config_layer1_cut_list[LAYER1_BIT_WIDTH_MEMBRANE*0 +: LAYER1_BIT_WIDTH_MEMBRANE]};
                        n_config_value_ready = 1;
                    end else begin
                        if (!fifo_d2a_data_full) begin
                            fifo_d2a_data_wr_en = 1;
                            n_config_value_layer1 = config_value_layer1 >> BIT_WIDTH_INPUT_STREAMING_DATA;
                            if (config_counter_one_two_three != 2) begin
                                n_config_counter_one_two_three = config_counter_one_two_three + 1;
                            end else begin
                                n_config_counter_one_two_three = 0;
                                n_config_counter = config_counter + 1;
                                
                                if (config_counter == LAYER1_DEPTH_SRAM*LAYER1_SET_NUM+1 - 1) begin
                                    n_layer1_config_phase[1] = 0;
                                    n_layer1_config_phase[2] = 1;
                                end
                    
                                n_config_value_ready = 0;
                            end
                        end
                    end
                // end else if (config_counter < LAYER1_DEPTH_SRAM*LAYER1_SET_NUM+2) begin
                end else if (layer1_config_phase[2]) begin
                    if (config_value_ready == 0) begin
                        n_config_value_layer1 = {{(BIT_WIDTH_INPUT_STREAMING_DATA*3-7*LAYER1_BIT_WIDTH_MEMBRANE){1'b0}}, d_config_layer1_cut_list[LAYER1_BIT_WIDTH_MEMBRANE*7 +: LAYER1_BIT_WIDTH_MEMBRANE], d_config_layer1_cut_list[LAYER1_BIT_WIDTH_MEMBRANE*6 +: LAYER1_BIT_WIDTH_MEMBRANE], d_config_layer1_cut_list[LAYER1_BIT_WIDTH_MEMBRANE*5 +: LAYER1_BIT_WIDTH_MEMBRANE], d_config_layer1_cut_list[LAYER1_BIT_WIDTH_MEMBRANE*4 +: LAYER1_BIT_WIDTH_MEMBRANE], d_config_layer1_cut_list[LAYER1_BIT_WIDTH_MEMBRANE*3 +: LAYER1_BIT_WIDTH_MEMBRANE], d_config_layer1_cut_list[LAYER1_BIT_WIDTH_MEMBRANE*2 +: LAYER1_BIT_WIDTH_MEMBRANE], d_config_layer1_cut_list[LAYER1_BIT_WIDTH_MEMBRANE*1 +: LAYER1_BIT_WIDTH_MEMBRANE]};
                        n_config_value_ready = 1;
                    end else begin
                        if (!fifo_d2a_data_full) begin
                            fifo_d2a_data_wr_en = 1;
                            n_config_value_layer1 = config_value_layer1 >> BIT_WIDTH_INPUT_STREAMING_DATA;
                            if (config_counter_one_two_three != 2) begin
                                n_config_counter_one_two_three = config_counter_one_two_three + 1;
                            end else begin
                                n_config_counter_one_two_three = 0;
                                n_config_counter = config_counter + 1;
                                
                                if (config_counter == LAYER1_DEPTH_SRAM*LAYER1_SET_NUM+2 - 1) begin
                                    n_layer1_config_phase[2] = 0;
                                    n_layer1_config_phase[3] = 1;
                                end
                    
                                n_config_value_ready = 0;
                            end
                        end
                    end
                // end else if (config_counter < LAYER1_DEPTH_SRAM*LAYER1_SET_NUM+2+1) begin
                end else if (layer1_config_phase[3]) begin
                    if (config_value_ready == 0) begin
                        n_config_value_layer1 = {{(BIT_WIDTH_INPUT_STREAMING_DATA*3-7*LAYER1_BIT_WIDTH_MEMBRANE){1'b0}}, d_config_layer1_cut_list[LAYER1_BIT_WIDTH_MEMBRANE*14 +: LAYER1_BIT_WIDTH_MEMBRANE], d_config_layer1_cut_list[LAYER1_BIT_WIDTH_MEMBRANE*13 +: LAYER1_BIT_WIDTH_MEMBRANE], d_config_layer1_cut_list[LAYER1_BIT_WIDTH_MEMBRANE*12 +: LAYER1_BIT_WIDTH_MEMBRANE], d_config_layer1_cut_list[LAYER1_BIT_WIDTH_MEMBRANE*11 +: LAYER1_BIT_WIDTH_MEMBRANE], d_config_layer1_cut_list[LAYER1_BIT_WIDTH_MEMBRANE*10 +: LAYER1_BIT_WIDTH_MEMBRANE], d_config_layer1_cut_list[LAYER1_BIT_WIDTH_MEMBRANE*9 +: LAYER1_BIT_WIDTH_MEMBRANE], d_config_layer1_cut_list[LAYER1_BIT_WIDTH_MEMBRANE*8 +: LAYER1_BIT_WIDTH_MEMBRANE]};
                        n_config_value_ready = 1;
                    end else begin
                        if (!fifo_d2a_data_full) begin
                            fifo_d2a_data_wr_en = 1;
                            n_config_value_layer1 = config_value_layer1 >> BIT_WIDTH_INPUT_STREAMING_DATA;
                            if (config_counter_one_two_three != 2) begin
                                n_config_counter_one_two_three = config_counter_one_two_three + 1;
                            end else begin
                                n_config_counter_one_two_three = 0;
                                n_config_counter = 0;
                                n_main_config_now = 0;
                                n_layer1_config_now = 0;
                                n_layer1_config_phase[3] = 0;
                                n_layer2_config_now = 1;
                                n_layer2_config_phase[0] = 1;
                                n_layer3_config_now = 0;
                                n_config_value_ready = 0;
                            end
                        end
                    end
                end










            end else if (layer2_config_now) begin
                // if (config_counter < LAYER2_DEPTH_SRAM*LAYER2_SET_NUM) begin
                if (layer2_config_phase[0]) begin
                    if (config_dram_word_ready == 0) begin
                        if (config_dram_word_request_have_been == 0) begin
                            if (app_rdy) begin
                                app_en = 1;
                                app_cmd = DRAM_READ;
                                app_addr = config_dram_read_address;
                                n_config_dram_word_request_have_been = 1;
                                n_config_dram_read_address = config_dram_read_address + 8;
                            end
                        end else begin 
                            if (app_rd_data_valid) begin
                                n_config_dram_word = app_rd_data;
                                n_config_dram_word_request_have_been = 0;
                                n_config_dram_word_ready = 1;
                            end
                        end
                    end else begin
                        if (config_value_ready == 0) begin
                            n_config_value_layer2 = {{(BIT_WIDTH_INPUT_STREAMING_DATA*3-LAYER2_BIT_WIDTH_SRAM){1'b0}}, config_dram_word[0 +: LAYER2_BIT_WIDTH_SRAM]};
                            n_config_value_ready = 1;
                        end else begin
                            if (!fifo_d2a_data_full) begin
                                fifo_d2a_data_wr_en = 1;
                                n_config_value_layer2 = config_value_layer2 >> BIT_WIDTH_INPUT_STREAMING_DATA;
                                if (config_counter_one_two_three != 2) begin
                                    n_config_counter_one_two_three = config_counter_one_two_three + 1;
                                end else begin
                                    n_config_counter_one_two_three = 0;
                                    n_config_counter = config_counter + 1;
                                
                                    if (config_counter == LAYER2_DEPTH_SRAM*LAYER2_SET_NUM - 1) begin
                                        n_layer2_config_phase[0] = 0;
                                        n_layer2_config_phase[1] = 1;
                                    end
                    
                                    n_config_dram_word_ready = 0;
                                    n_config_value_ready = 0;
                                end
                            end
                        end
                    end                        
                // end else if (config_counter < LAYER2_DEPTH_SRAM*LAYER2_SET_NUM+1) begin
                end else if (layer2_config_phase[1]) begin
                    if (config_value_ready == 0) begin
                        n_config_value_layer2 = {{(BIT_WIDTH_INPUT_STREAMING_DATA*3-LAYER2_BIT_WIDTH_MEMBRANE){1'b0}}, d_config_layer2_cut_list[LAYER2_BIT_WIDTH_MEMBRANE*0 +: LAYER2_BIT_WIDTH_MEMBRANE]};
                        n_config_value_ready = 1;
                    end else begin
                        if (!fifo_d2a_data_full) begin
                            fifo_d2a_data_wr_en = 1;
                            n_config_value_layer2 = config_value_layer2 >> BIT_WIDTH_INPUT_STREAMING_DATA;
                            if (config_counter_one_two_three != 2) begin
                                n_config_counter_one_two_three = config_counter_one_two_three + 1;
                            end else begin
                                n_config_counter_one_two_three = 0;
                                n_config_counter = config_counter + 1;
                                
                                if (config_counter == LAYER2_DEPTH_SRAM*LAYER2_SET_NUM+1 - 1) begin
                                    n_layer2_config_phase[1] = 0;
                                    n_layer2_config_phase[2] = 1;
                                end
                    
                                n_config_value_ready = 0;
                            end
                        end
                    end
                // end else if (config_counter < LAYER2_DEPTH_SRAM*LAYER2_SET_NUM+2) begin
                end else if (layer2_config_phase[2]) begin
                    if (config_value_ready == 0) begin
                        n_config_value_layer2 = {{(BIT_WIDTH_INPUT_STREAMING_DATA*3-7*LAYER2_BIT_WIDTH_MEMBRANE){1'b0}}, d_config_layer2_cut_list[LAYER2_BIT_WIDTH_MEMBRANE*7 +: LAYER2_BIT_WIDTH_MEMBRANE], d_config_layer2_cut_list[LAYER2_BIT_WIDTH_MEMBRANE*6 +: LAYER2_BIT_WIDTH_MEMBRANE], d_config_layer2_cut_list[LAYER2_BIT_WIDTH_MEMBRANE*5 +: LAYER2_BIT_WIDTH_MEMBRANE], d_config_layer2_cut_list[LAYER2_BIT_WIDTH_MEMBRANE*4 +: LAYER2_BIT_WIDTH_MEMBRANE], d_config_layer2_cut_list[LAYER2_BIT_WIDTH_MEMBRANE*3 +: LAYER2_BIT_WIDTH_MEMBRANE], d_config_layer2_cut_list[LAYER2_BIT_WIDTH_MEMBRANE*2 +: LAYER2_BIT_WIDTH_MEMBRANE], d_config_layer2_cut_list[LAYER2_BIT_WIDTH_MEMBRANE*1 +: LAYER2_BIT_WIDTH_MEMBRANE]};
                        n_config_value_ready = 1;
                    end else begin
                        if (!fifo_d2a_data_full) begin
                            fifo_d2a_data_wr_en = 1;
                            n_config_value_layer2 = config_value_layer2 >> BIT_WIDTH_INPUT_STREAMING_DATA;
                            if (config_counter_one_two_three != 2) begin
                                n_config_counter_one_two_three = config_counter_one_two_three + 1;
                            end else begin
                                n_config_counter_one_two_three = 0;
                                n_config_counter = config_counter + 1;
                                
                                if (config_counter == LAYER2_DEPTH_SRAM*LAYER2_SET_NUM+2 - 1) begin
                                    n_layer2_config_phase[2] = 0;
                                    n_layer2_config_phase[3] = 1;
                                end
                    
                                n_config_value_ready = 0;
                            end
                        end
                    end
                // end else if (config_counter < LAYER2_DEPTH_SRAM*LAYER2_SET_NUM+2+1) begin
                end else if (layer2_config_phase[3]) begin
                    if (config_value_ready == 0) begin
                        n_config_value_layer2 = {{(BIT_WIDTH_INPUT_STREAMING_DATA*3-7*LAYER2_BIT_WIDTH_MEMBRANE){1'b0}}, d_config_layer2_cut_list[LAYER2_BIT_WIDTH_MEMBRANE*14 +: LAYER2_BIT_WIDTH_MEMBRANE], d_config_layer2_cut_list[LAYER2_BIT_WIDTH_MEMBRANE*13 +: LAYER2_BIT_WIDTH_MEMBRANE], d_config_layer2_cut_list[LAYER2_BIT_WIDTH_MEMBRANE*12 +: LAYER2_BIT_WIDTH_MEMBRANE], d_config_layer2_cut_list[LAYER2_BIT_WIDTH_MEMBRANE*11 +: LAYER2_BIT_WIDTH_MEMBRANE], d_config_layer2_cut_list[LAYER2_BIT_WIDTH_MEMBRANE*10 +: LAYER2_BIT_WIDTH_MEMBRANE], d_config_layer2_cut_list[LAYER2_BIT_WIDTH_MEMBRANE*9 +: LAYER2_BIT_WIDTH_MEMBRANE], d_config_layer2_cut_list[LAYER2_BIT_WIDTH_MEMBRANE*8 +: LAYER2_BIT_WIDTH_MEMBRANE]};
                        n_config_value_ready = 1;
                    end else begin
                        if (!fifo_d2a_data_full) begin
                            fifo_d2a_data_wr_en = 1;
                            n_config_value_layer2 = config_value_layer2 >> BIT_WIDTH_INPUT_STREAMING_DATA;
                            if (config_counter_one_two_three != 2) begin
                                n_config_counter_one_two_three = config_counter_one_two_three + 1;
                            end else begin
                                n_config_counter_one_two_three = 0;
                                n_config_counter = 0;
                                n_main_config_now = 0;
                                n_layer1_config_now = 0;
                                n_layer2_config_now = 0;
                                n_layer2_config_phase[3] = 0;
                                n_layer3_config_now = 1;
                                n_layer3_config_phase[0] = 1;
                                n_config_value_ready = 0;
                            end
                        end
                    end
                end














            end else if (layer3_config_now) begin
                // if (config_counter < LAYER3_DEPTH_SRAM*LAYER3_SET_NUM) begin
                if (layer3_config_phase[0]) begin
                    if (config_dram_word_ready == 0) begin
                        if (config_dram_word_request_have_been == 0) begin
                            if (app_rdy) begin
                                app_en = 1;
                                app_cmd = DRAM_READ;
                                app_addr = config_dram_read_address;
                                n_config_dram_word_request_have_been = 1;
                                n_config_dram_read_address = config_dram_read_address + 8;
                            end
                        end else begin 
                            if (app_rd_data_valid) begin
                                n_config_dram_word = app_rd_data;
                                n_config_dram_word_request_have_been = 0;
                                n_config_dram_word_ready = 1;
                            end
                        end
                    end else begin
                        if (config_value_ready == 0) begin
                            n_config_value_layer3 = {{(BIT_WIDTH_INPUT_STREAMING_DATA*3-LAYER3_BIT_WIDTH_SRAM){1'b0}}, config_dram_word[0 +: LAYER3_BIT_WIDTH_SRAM]};
                            n_config_value_ready = 1;
                        end else begin
                            if (!fifo_d2a_data_full) begin
                                fifo_d2a_data_wr_en = 1;
                                n_config_value_layer3 = config_value_layer3 >> BIT_WIDTH_INPUT_STREAMING_DATA;
                                if (config_counter_one_two_three != 2) begin
                                    n_config_counter_one_two_three = config_counter_one_two_three + 1;
                                end else begin
                                    n_config_counter_one_two_three = 0;
                                    n_config_counter = config_counter + 1;
                                
                                    if (config_counter == LAYER3_DEPTH_SRAM*LAYER3_SET_NUM - 1) begin
                                        n_layer3_config_phase[0] = 0;
                                        n_layer3_config_phase[1] = 1;
                                    end
                    
                                    n_config_dram_word_ready = 0;
                                    n_config_value_ready = 0;
                                end
                            end
                        end
                    end                        
                end else if (layer3_config_phase[1]) begin
                    if (config_value_ready == 0) begin
                        n_config_value_layer3 = {{(BIT_WIDTH_INPUT_STREAMING_DATA*3-2){1'b0}}, d_config_loser_encourage_mode, d_config_binary_classifier_mode};
                        n_config_value_ready = 1;
                    end else begin
                        if (!fifo_d2a_data_full) begin
                            fifo_d2a_data_wr_en = 1;
                            n_config_value_layer3 = config_value_layer3 >> BIT_WIDTH_INPUT_STREAMING_DATA;
                            if (config_counter_one_two_three != 2) begin
                                n_config_counter_one_two_three = config_counter_one_two_three + 1;
                            end else begin
                                n_config_counter_one_two_three = 0;
                                n_config_counter = 0;
                                n_main_config_now = 0;
                                n_layer1_config_now = 0;
                                n_layer2_config_now = 0;
                                n_layer3_config_now = 0;
                                n_layer3_config_phase[1] = 0;

                                n_config_on_real = 0;
                                n_config_dram_read_address = 0;
                                n_config_value_ready = 0;
                            end
                        end
                    end
                end




            end


            // fifo_d2a_data_din = config_value[BIT_WIDTH_INPUT_STREAMING_DATA*config_counter_one_two_three +: BIT_WIDTH_INPUT_STREAMING_DATA];
            if (main_config_now) begin
                fifo_d2a_data_din = config_value_main[BIT_WIDTH_INPUT_STREAMING_DATA*0 +: BIT_WIDTH_INPUT_STREAMING_DATA];
            end else if (layer1_config_now) begin
                fifo_d2a_data_din = config_value_layer1[BIT_WIDTH_INPUT_STREAMING_DATA*0 +: BIT_WIDTH_INPUT_STREAMING_DATA];
            end else if (layer2_config_now) begin
                fifo_d2a_data_din = config_value_layer2[BIT_WIDTH_INPUT_STREAMING_DATA*0 +: BIT_WIDTH_INPUT_STREAMING_DATA];
            end else if (layer3_config_now) begin
                fifo_d2a_data_din = config_value_layer3[BIT_WIDTH_INPUT_STREAMING_DATA*0 +: BIT_WIDTH_INPUT_STREAMING_DATA];
            end


        end









    end










        // MIG 


        mig_7series_0 u_mig_7series_0(
            .device_temp                      ( device_temp                      ),

            // Memory interface ports
            .ddr3_addr                        ( ddr3_addr                        ),
            .ddr3_ba                          ( ddr3_ba                          ),
            .ddr3_cas_n                       ( ddr3_cas_n                       ),
            .ddr3_ck_n                        ( ddr3_ck_n                        ),
            .ddr3_ck_p                        ( ddr3_ck_p                        ),
            .ddr3_cke                         ( ddr3_cke                         ),
            .ddr3_ras_n                       ( ddr3_ras_n                       ),
            .ddr3_reset_n                     ( ddr3_reset_n                     ),
            .ddr3_we_n                        ( ddr3_we_n                        ),
            .ddr3_dq                          (   ddr3_dq                   ),
            .ddr3_dqs_n                       (   ddr3_dqs_n                ),
            .ddr3_dqs_p                       (   ddr3_dqs_p                ),
            .init_calib_complete              (   init_calib_complete            ),

            .ddr3_cs_n                      (ddr3_cs_n),
            .ddr3_dm                          ( ddr3_dm                          ),
            .ddr3_odt                         ( ddr3_odt                         ),


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

            .sys_rst                          ( !reset_n                  )
        );
        // ########################## MIG ########################################################################################




endmodule
