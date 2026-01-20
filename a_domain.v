// `define NO_BUF 1
module a_domain(
        input clk_a_domain,
        input reset_n,

        // d2a command fifo
        output reg fifo_d2a_command_rd_en,
        input [32 - 1:0] fifo_d2a_command_dout,
        input fifo_d2a_command_empty,
        input fifo_d2a_command_valid,


        // d2a data fifo
        output reg fifo_d2a_data_rd_en,
        input [66 - 1:0] fifo_d2a_data_dout,
        input fifo_d2a_data_empty,
        input fifo_d2a_data_valid,


        // a2d command fifo
        output reg fifo_a2d_command_wr_en,
        output reg [32 - 1:0] fifo_a2d_command_din,
        input fifo_a2d_command_full,






        // fpga to asic, asic to fpga
        output reset_n_from_fpga_to_asic,

        output input_streaming_valid_from_fpga_to_asic,
        output [65:0] input_streaming_data_from_fpga_to_asic,
        input input_streaming_ready_from_asic_to_fpga,

        output start_training_signal_from_fpga_to_asic, 
        output start_inference_signal_from_fpga_to_asic, 
        input start_ready_from_asic_to_fpga, 

        input inferenced_label_from_asic_to_fpga 
    );


    // ######### for VERIFICATION ###########################################################################
    // ######### for VERIFICATION ###########################################################################
    // ######### for VERIFICATION ###########################################################################
    reg [31:0] config_stream_cnt, n_config_stream_cnt;
    reg asic_start_ready_for_test, n_asic_start_ready_for_test;
    reg [65:0] config_stream_catch_41421, n_config_stream_catch_41421;
    reg [65:0] config_stream_catch_41418, n_config_stream_catch_41418;
    reg [31:0] data_stream_cnt_for_test, n_data_stream_cnt_for_test;
    // ######### for VERIFICATION ###########################################################################
    // ######### for VERIFICATION ###########################################################################
    // ######### for VERIFICATION ###########################################################################


    // ######### IN OUT ###########################################################################
    // ######### IN OUT ###########################################################################
    // ######### IN OUT ###########################################################################
    reg input_streaming_ready_from_asic_to_fpga_buf;
    reg start_ready_from_asic_to_fpga_buf;
    reg inferenced_label_from_asic_to_fpga_buf;
    always @(posedge clk_a_domain) begin
        if(!reset_n) begin
            input_streaming_ready_from_asic_to_fpga_buf <= 0;
            start_ready_from_asic_to_fpga_buf <= 0;
            inferenced_label_from_asic_to_fpga_buf <= 0;
        end
        else begin
            input_streaming_ready_from_asic_to_fpga_buf <= input_streaming_ready_from_asic_to_fpga;
            start_ready_from_asic_to_fpga_buf <= start_ready_from_asic_to_fpga;
            inferenced_label_from_asic_to_fpga_buf <= inferenced_label_from_asic_to_fpga;
        end
    end
    wire input_streaming_ready;
    wire start_ready;
    wire inferenced_label;
	`ifdef NO_BUF
        assign input_streaming_ready = input_streaming_ready_from_asic_to_fpga;
        // assign start_ready = start_ready_from_asic_to_fpga;
        // assign start_ready = 1'b1;
        assign start_ready = asic_start_ready_for_test;
        assign inferenced_label = inferenced_label_from_asic_to_fpga;
	`else
        assign input_streaming_ready = input_streaming_ready_from_asic_to_fpga_buf;
        // assign start_ready = start_ready_from_asic_to_fpga_buf;
        // assign start_ready = 1'b1;
        assign start_ready = asic_start_ready_for_test;
        assign inferenced_label = inferenced_label_from_asic_to_fpga_buf;
	`endif




    reg input_streaming_valid_from_fpga_to_asic_buf, input_streaming_valid;
    reg [65:0] input_streaming_data_from_fpga_to_asic_buf, input_streaming_data;
    reg start_training_signal_from_fpga_to_asic_buf, start_training_signal; 
    reg start_inference_signal_from_fpga_to_asic_buf, start_inference_signal; 
    always @(posedge clk_a_domain) begin
        if(!reset_n) begin
            input_streaming_valid_from_fpga_to_asic_buf <= 0;
            input_streaming_data_from_fpga_to_asic_buf <= 0;
            start_training_signal_from_fpga_to_asic_buf <= 0;
            start_inference_signal_from_fpga_to_asic_buf <= 0;
        end
        else begin
            input_streaming_valid_from_fpga_to_asic_buf <= input_streaming_valid;
            input_streaming_data_from_fpga_to_asic_buf <= input_streaming_data;
            start_training_signal_from_fpga_to_asic_buf <= start_training_signal;
            start_inference_signal_from_fpga_to_asic_buf <= start_inference_signal;
        end
    end
    assign reset_n_from_fpga_to_asic = reset_n; // RESET SIGNAL NO NEES BUFFER !!!
	`ifdef NO_BUF
        assign input_streaming_valid_from_fpga_to_asic = input_streaming_valid;
        assign input_streaming_data_from_fpga_to_asic = input_streaming_data;
        assign start_training_signal_from_fpga_to_asic = start_training_signal;
        assign start_inference_signal_from_fpga_to_asic = start_inference_signal;
	`else
        assign input_streaming_valid_from_fpga_to_asic = input_streaming_valid_from_fpga_to_asic_buf;
        assign input_streaming_data_from_fpga_to_asic = input_streaming_data_from_fpga_to_asic_buf;
        assign start_training_signal_from_fpga_to_asic = start_training_signal_from_fpga_to_asic_buf;
        assign start_inference_signal_from_fpga_to_asic = start_inference_signal_from_fpga_to_asic_buf;
	`endif
    // ######### IN OUT ###########################################################################
    // ######### IN OUT ###########################################################################
    // ######### IN OUT ###########################################################################


















    reg [15:0] config_a_domain_setting_cnt, n_config_a_domain_setting_cnt;

    reg [1:0] a_config_asic_mode, n_a_config_asic_mode; // 0 training_only, 1 train_inf_sweep, 2 inference_only 
    reg [15:0] a_config_training_epochs, n_a_config_training_epochs;
    reg [15:0] a_config_inference_epochs, n_a_config_inference_epochs;
    reg [1:0] a_config_dataset, n_a_config_dataset; // 0 DVS_GESTURE, 1 N_MNIST, 2 NTIDIGITS
    reg [15:0] a_config_timesteps, n_a_config_timesteps;
    reg [15:0] a_config_input_size_layer1_define, n_a_config_input_size_layer1_define;
    reg a_config_long_time_input_streaming_mode, n_a_config_long_time_input_streaming_mode;
    reg a_config_binary_classifier_mode, n_a_config_binary_classifier_mode;
    reg a_config_loser_encourage_mode, n_a_config_loser_encourage_mode;
    reg [17*15 - 1:0] a_config_layer1_cut_list, n_a_config_layer1_cut_list;
    reg [16*15 - 1:0] a_config_layer2_cut_list, n_a_config_layer2_cut_list;
    reg config_on_real, n_config_on_real;
    reg start_ready_oneclk_past;
    reg [16:0] streaming_wait_cycle, n_streaming_wait_cycle;
    reg queuing_ongoing, n_queuing_ongoing;

    reg start_training_signal_oneclk_delay;
    reg start_inference_signal_oneclk_delay;
    reg training_processing_ongoing, n_training_processing_ongoing;
    reg inference_processing_ongoing, n_inference_processing_ongoing;

    reg [31:0] sample_num, n_sample_num;
    reg [3:0] sample_num_transition_cnt, n_sample_num_transition_cnt;
    reg [31:0] sample_num_executed, n_sample_num_executed;
    reg [7:0] sample_stream_cnt_small, n_sample_stream_cnt_small;
    always @(posedge clk_a_domain) begin
        if(!reset_n) begin
            config_a_domain_setting_cnt <= 0;

            a_config_asic_mode <= 0;
            a_config_training_epochs <= 0;
            a_config_inference_epochs  <= 0;
            a_config_dataset  <= 0;
            a_config_timesteps  <= 0;
            a_config_input_size_layer1_define  <= 0;
            a_config_long_time_input_streaming_mode  <= 0;
            a_config_binary_classifier_mode  <= 0;
            a_config_loser_encourage_mode  <= 0;
            a_config_layer1_cut_list  <= 0;
            a_config_layer2_cut_list  <= 0;
            config_on_real  <= 0;
            start_ready_oneclk_past <= 0;
            streaming_wait_cycle <= 0;
            queuing_ongoing <= 0;

            start_training_signal_oneclk_delay <= 0;
            start_inference_signal_oneclk_delay <= 0;
            training_processing_ongoing <= 0;
            inference_processing_ongoing <= 0;

            sample_num <= 0;
            sample_num_transition_cnt <= 0;
        end
        else begin
            config_a_domain_setting_cnt <= n_config_a_domain_setting_cnt;

            a_config_asic_mode <= n_a_config_asic_mode;
            a_config_training_epochs <= n_a_config_training_epochs;
            a_config_inference_epochs <= n_a_config_inference_epochs;
            a_config_dataset <= n_a_config_dataset;
            a_config_timesteps <= n_a_config_timesteps;
            a_config_input_size_layer1_define <= n_a_config_input_size_layer1_define;
            a_config_long_time_input_streaming_mode <= n_a_config_long_time_input_streaming_mode;
            a_config_binary_classifier_mode <= n_a_config_binary_classifier_mode;
            a_config_loser_encourage_mode <= n_a_config_loser_encourage_mode;
            a_config_layer1_cut_list <= n_a_config_layer1_cut_list;
            a_config_layer2_cut_list <= n_a_config_layer2_cut_list;
            config_on_real <= n_config_on_real;
            start_ready_oneclk_past <= start_ready;
            streaming_wait_cycle <= n_streaming_wait_cycle;
            queuing_ongoing <= n_queuing_ongoing;

            start_training_signal_oneclk_delay <= start_training_signal;
            start_inference_signal_oneclk_delay <= start_inference_signal;
            training_processing_ongoing <= n_training_processing_ongoing;
            inference_processing_ongoing <= n_inference_processing_ongoing;

            sample_num <= n_sample_num;
            sample_num_transition_cnt <= n_sample_num_transition_cnt;
        end
    end

    always @ (*) begin
        n_config_a_domain_setting_cnt = config_a_domain_setting_cnt;

        fifo_d2a_command_rd_en = 0;

        fifo_a2d_command_wr_en = 0;
        fifo_a2d_command_din = 0;
        
        n_a_config_asic_mode = a_config_asic_mode;
        n_a_config_training_epochs = a_config_training_epochs;
        n_a_config_inference_epochs = a_config_inference_epochs;
        n_a_config_dataset = a_config_dataset;
        n_a_config_timesteps = a_config_timesteps;
        n_a_config_input_size_layer1_define = a_config_input_size_layer1_define;
        n_a_config_long_time_input_streaming_mode = a_config_long_time_input_streaming_mode;
        n_a_config_binary_classifier_mode = a_config_binary_classifier_mode;
        n_a_config_loser_encourage_mode = a_config_loser_encourage_mode;
        n_a_config_layer1_cut_list = a_config_layer1_cut_list;
        n_a_config_layer2_cut_list = a_config_layer2_cut_list;
        n_config_on_real = config_on_real;
        n_streaming_wait_cycle = streaming_wait_cycle;
        n_queuing_ongoing = queuing_ongoing;


        start_training_signal = 0;
        start_inference_signal = 0;
        n_training_processing_ongoing = training_processing_ongoing;
        n_inference_processing_ongoing = inference_processing_ongoing;

        n_sample_num = sample_num;
        n_sample_num_transition_cnt = sample_num_transition_cnt;
        



        if (fifo_d2a_command_valid) begin
            if (fifo_d2a_command_dout[14:0] == 1) begin
                fifo_d2a_command_rd_en = 1;
                if (config_a_domain_setting_cnt == 0) begin
                    n_a_config_asic_mode = fifo_d2a_command_dout[15 +: 2];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 1) begin
                    n_a_config_training_epochs = fifo_d2a_command_dout[15 +: 16];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 2) begin
                    n_a_config_inference_epochs = fifo_d2a_command_dout[15 +: 16];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 3) begin
                    n_a_config_dataset = fifo_d2a_command_dout[15 +: 2];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 4) begin
                    n_a_config_timesteps = fifo_d2a_command_dout[15 +: 16];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 5) begin
                    n_a_config_input_size_layer1_define = fifo_d2a_command_dout[15 +: 16];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 6) begin
                    n_a_config_long_time_input_streaming_mode = fifo_d2a_command_dout[15 +: 1];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 7) begin
                    n_a_config_binary_classifier_mode = fifo_d2a_command_dout[15 +: 1];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 8) begin
                    n_a_config_loser_encourage_mode = fifo_d2a_command_dout[15 +: 1];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 9) begin
                    n_a_config_layer1_cut_list[17*0 +: 17] = fifo_d2a_command_dout[15 +: 17];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 10) begin
                    n_a_config_layer1_cut_list[17*1 +: 17] = fifo_d2a_command_dout[15 +: 17];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 11) begin
                    n_a_config_layer1_cut_list[17*2 +: 17] = fifo_d2a_command_dout[15 +: 17];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 12) begin
                    n_a_config_layer1_cut_list[17*3 +: 17] = fifo_d2a_command_dout[15 +: 17];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 13) begin
                    n_a_config_layer1_cut_list[17*4 +: 17] = fifo_d2a_command_dout[15 +: 17];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 14) begin
                    n_a_config_layer1_cut_list[17*5 +: 17] = fifo_d2a_command_dout[15 +: 17];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 15) begin
                    n_a_config_layer1_cut_list[17*6 +: 17] = fifo_d2a_command_dout[15 +: 17];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 16) begin
                    n_a_config_layer1_cut_list[17*7 +: 17] = fifo_d2a_command_dout[15 +: 17];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 17) begin
                    n_a_config_layer1_cut_list[17*8 +: 17] = fifo_d2a_command_dout[15 +: 17];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 18) begin
                    n_a_config_layer1_cut_list[17*9 +: 17] = fifo_d2a_command_dout[15 +: 17];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 19) begin
                    n_a_config_layer1_cut_list[17*10 +: 17] = fifo_d2a_command_dout[15 +: 17];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 20) begin
                    n_a_config_layer1_cut_list[17*11 +: 17] = fifo_d2a_command_dout[15 +: 17];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 21) begin
                    n_a_config_layer1_cut_list[17*12 +: 17] = fifo_d2a_command_dout[15 +: 17];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 22) begin
                    n_a_config_layer1_cut_list[17*13 +: 17] = fifo_d2a_command_dout[15 +: 17];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 23) begin
                    n_a_config_layer1_cut_list[17*14 +: 17] = fifo_d2a_command_dout[15 +: 17];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 24) begin
                    n_a_config_layer2_cut_list[16*0 +: 16] = fifo_d2a_command_dout[15 +: 16];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 25) begin
                    n_a_config_layer2_cut_list[16*1 +: 16] = fifo_d2a_command_dout[15 +: 16];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 26) begin
                    n_a_config_layer2_cut_list[16*2 +: 16] = fifo_d2a_command_dout[15 +: 16];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 27) begin
                    n_a_config_layer2_cut_list[16*3 +: 16] = fifo_d2a_command_dout[15 +: 16];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 28) begin
                    n_a_config_layer2_cut_list[16*4 +: 16] = fifo_d2a_command_dout[15 +: 16];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 29) begin
                    n_a_config_layer2_cut_list[16*5 +: 16] = fifo_d2a_command_dout[15 +: 16];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 30) begin
                    n_a_config_layer2_cut_list[16*6 +: 16] = fifo_d2a_command_dout[15 +: 16];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 31) begin
                    n_a_config_layer2_cut_list[16*7 +: 16] = fifo_d2a_command_dout[15 +: 16];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 32) begin
                    n_a_config_layer2_cut_list[16*8 +: 16] = fifo_d2a_command_dout[15 +: 16];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 33) begin
                    n_a_config_layer2_cut_list[16*9 +: 16] = fifo_d2a_command_dout[15 +: 16];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 34) begin
                    n_a_config_layer2_cut_list[16*10 +: 16] = fifo_d2a_command_dout[15 +: 16];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 35) begin
                    n_a_config_layer2_cut_list[16*11 +: 16] = fifo_d2a_command_dout[15 +: 16];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 36) begin
                    n_a_config_layer2_cut_list[16*12 +: 16] = fifo_d2a_command_dout[15 +: 16];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 37) begin
                    n_a_config_layer2_cut_list[16*13 +: 16] = fifo_d2a_command_dout[15 +: 16];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end else if (config_a_domain_setting_cnt == 38) begin
                    n_a_config_layer2_cut_list[16*14 +: 16] = fifo_d2a_command_dout[15 +: 16];
                    n_config_a_domain_setting_cnt = config_a_domain_setting_cnt + 1;
                end
            end
        end
        if (config_a_domain_setting_cnt == 39) begin
            if (!fifo_a2d_command_full) begin
                n_config_a_domain_setting_cnt = 0;
                fifo_a2d_command_wr_en = 1;
                fifo_a2d_command_din = {{17{1'b0}}, 15'd2};
            end 
        end


        if (fifo_d2a_command_valid) begin
            if (fifo_d2a_command_dout[14:0] == 7) begin
                if (!fifo_a2d_command_full) begin
                    fifo_d2a_command_rd_en = 1; 
                    fifo_a2d_command_wr_en = 1;
                    fifo_a2d_command_din = {{16{1'b0}}, start_ready, 15'd7};
                end
            end
        end

        if (fifo_d2a_command_valid) begin
            if (fifo_d2a_command_dout[14:0] == 8) begin
                if (start_ready) begin
                    if (!fifo_a2d_command_full) begin
                        fifo_d2a_command_rd_en = 1; 
                        fifo_a2d_command_wr_en = 1;
                        fifo_a2d_command_din = {{17{1'b0}}, 15'd8};
                        n_config_on_real = 1;
                    end
                end
            end
        end

        if (config_on_real) begin
            if(start_ready_oneclk_past == 0 && start_ready == 1) begin
                if (!fifo_a2d_command_full) begin
                    fifo_a2d_command_wr_en = 1;
                    fifo_a2d_command_din = {config_stream_cnt[15:0], start_ready, 15'd9};
                    // fifo_a2d_command_din = {config_stream_catch_41418[15:0], start_ready, 15'd9};
                    // fifo_a2d_command_din = {config_stream_catch_41421[15:0], start_ready, 15'd9};
                    n_config_on_real = 0;
                end
            end
        end

        if (fifo_d2a_command_valid) begin
            if (fifo_d2a_command_dout[14:0] == 10) begin
                if (!fifo_a2d_command_full) begin
                    fifo_d2a_command_rd_en = 1; 
                    fifo_a2d_command_wr_en = 1;
                    fifo_a2d_command_din = fifo_d2a_command_dout;
                    n_streaming_wait_cycle = fifo_d2a_command_dout[15 +: 17];
                end
            end
        end

        if (fifo_d2a_command_valid) begin
            if (fifo_d2a_command_dout[14:0] == 11) begin
                if (sample_num_transition_cnt == 0) begin
                    fifo_d2a_command_rd_en = 1;
                    n_sample_num_transition_cnt = sample_num_transition_cnt + 1;
                    n_sample_num[0 +: 16] = fifo_d2a_command_dout[15 +: 16];
                end else if (sample_num_transition_cnt == 1) begin
                    if (!fifo_a2d_command_full) begin
                        fifo_d2a_command_rd_en = 1;
                        n_sample_num_transition_cnt = 0;
                        n_sample_num[16 +: 16] = fifo_d2a_command_dout[15 +: 16];
                        fifo_a2d_command_wr_en = 1;
                        fifo_a2d_command_din = {17'd0, 15'd11};
                    end
                end
            end
        end

        if (fifo_d2a_command_valid) begin
            if (fifo_d2a_command_dout[14:0] == 12) begin // training queuing
                if (!fifo_a2d_command_full) begin
                    fifo_d2a_command_rd_en = 1; 
                    fifo_a2d_command_wr_en = 1;
                    fifo_a2d_command_din = fifo_d2a_command_dout;
                    n_queuing_ongoing = 1;
                end
            end
        end
        if (fifo_d2a_command_valid) begin
            if (fifo_d2a_command_dout[14:0] == 13) begin // inference queuing
                if (!fifo_a2d_command_full) begin
                    fifo_d2a_command_rd_en = 1; 
                    fifo_a2d_command_wr_en = 1;
                    fifo_a2d_command_din = fifo_d2a_command_dout;
                    n_queuing_ongoing = 1;
                end
            end
        end
        if (fifo_d2a_command_valid) begin
            if (fifo_d2a_command_dout[14:0] == 16) begin // training start
                fifo_d2a_command_rd_en = 1; 
                start_training_signal = 1;
                n_training_processing_ongoing = 1;
            end
        end
        if (fifo_d2a_command_valid) begin
            if (fifo_d2a_command_dout[14:0] == 17) begin // inference start
                fifo_d2a_command_rd_en = 1; 
                start_inference_signal = 1;
                n_inference_processing_ongoing = 0;
            end
        end


        if (training_processing_ongoing) begin
            if(start_ready_oneclk_past == 0 && start_ready == 1) begin
                if (!fifo_a2d_command_full) begin
                    fifo_a2d_command_wr_en = 1;
                    fifo_a2d_command_din = {data_stream_cnt_for_test[15:0], start_ready, 15'd14};
                    n_training_processing_ongoing = 0;
                end
            end
        end
        if (inference_processing_ongoing) begin
            if(start_ready_oneclk_past == 0 && start_ready == 1) begin
                if (!fifo_a2d_command_full) begin
                    fifo_a2d_command_wr_en = 1;
                    fifo_a2d_command_din = {data_stream_cnt_for_test[15:0], start_ready, 15'd15};
                    n_inference_processing_ongoing = 0;
                end
            end
        end


        if (sample_num != 0 && sample_num_executed != 0) begin
            if (sample_num_executed % (sample_num>>3) == 0) begin
                if (!fifo_a2d_command_full) begin
                    fifo_a2d_command_wr_en = 1;
                    fifo_a2d_command_din = {sample_num_executed[16:0], 15'd18};
                end
            end
        end

        if (start_training_signal_oneclk_delay || start_inference_signal_oneclk_delay) begin
            n_queuing_ongoing = 0;
        end


    end







    // STREAMING CONTROL
    reg [16:0] streaming_count, n_streaming_count;
    reg [16:0] streaming_wait_count, n_streaming_wait_count;
    always @(posedge clk_a_domain) begin
        if(!reset_n) begin
            streaming_count <= 0;
            streaming_wait_count <= 0;

            sample_num_executed <= 0;
            sample_stream_cnt_small <= 0;
        end
        else begin
            streaming_count <= n_streaming_count;
            streaming_wait_count <= n_streaming_wait_count;

            sample_num_executed <= n_sample_num_executed;
            sample_stream_cnt_small <= n_sample_stream_cnt_small;
        end
    end
    always @ (*) begin
        input_streaming_valid = 0;
        input_streaming_data = 0;
        n_streaming_count = streaming_count;
        n_streaming_wait_count = streaming_wait_count;

        n_sample_num_executed = sample_num_executed;
        n_sample_stream_cnt_small = sample_stream_cnt_small;

        fifo_d2a_data_rd_en = 0;


        if (streaming_count != 7) begin
            if (queuing_ongoing) begin
                fifo_d2a_data_rd_en = 0;
                input_streaming_valid = 0;
                input_streaming_data = 0;
                n_sample_num_executed = 0;
                n_sample_stream_cnt_small = 0;
            end else begin 
                if (1'b1) begin // if (input_streaming_ready) begin
                    if (fifo_d2a_data_valid) begin
                        fifo_d2a_data_rd_en = 1;
                        input_streaming_valid = 1;
                        input_streaming_data = fifo_d2a_data_dout;
                        if (streaming_wait_cycle != 0) begin
                            n_streaming_count = streaming_count + 1;
                        end







                        if (a_config_dataset == 0) begin
                            if (sample_stream_cnt_small == 15 - 1) begin
                                n_sample_num_executed = sample_num_executed + 1;
                                n_sample_stream_cnt_small = 0;
                            end else begin
                                n_sample_stream_cnt_small = sample_num_executed + 1;
                            end
                        end else if (a_config_dataset == 1) begin
                            if (sample_stream_cnt_small == 9 - 1) begin
                                n_sample_num_executed = sample_num_executed + 1;
                                n_sample_stream_cnt_small = 0;
                            end else begin
                                n_sample_stream_cnt_small = sample_num_executed + 1;
                            end
                        end else if (a_config_dataset == 2) begin
                            if (sample_stream_cnt_small == 9 - 1) begin
                                n_sample_num_executed = sample_num_executed + 1;
                                n_sample_stream_cnt_small = 0;
                            end else begin
                                n_sample_stream_cnt_small = sample_num_executed + 1;
                            end
                        end







                    end
                end
            end
        end else begin
            if (streaming_wait_count == streaming_wait_cycle - 1) begin
                n_streaming_count = 0;
                n_streaming_wait_count = 0;
            end else begin
                n_streaming_wait_count = streaming_wait_count + 1;
            end
        end

    end














    wire signed [16:0] a_config_layer1_cut [0:14];
    wire signed [15:0] a_config_layer2_cut [0:14];
    genvar cut_i;
    generate
        for (cut_i = 0; cut_i < 15; cut_i = cut_i + 1) begin : gen_config_cut_list
            assign a_config_layer1_cut[cut_i] = a_config_layer1_cut_list[17*cut_i +: 17];
            assign a_config_layer2_cut[cut_i] = a_config_layer2_cut_list[16*cut_i +: 16];
        end
    endgenerate















    // ######### for VERIFICATION ###########################################################################
    // ######### for VERIFICATION ###########################################################################
    // ######### for VERIFICATION ###########################################################################
    always @(posedge clk_a_domain) begin
        if(!reset_n) begin
            config_stream_cnt <= 0;
            asic_start_ready_for_test <= 1;
            config_stream_catch_41421 <= 0;
            config_stream_catch_41418 <= 0;
            data_stream_cnt_for_test <= 0;
        end
        else begin
            config_stream_cnt <= n_config_stream_cnt;
            asic_start_ready_for_test <= n_asic_start_ready_for_test;
            config_stream_catch_41421 <= n_config_stream_catch_41421;
            config_stream_catch_41418 <= n_config_stream_catch_41418;
            data_stream_cnt_for_test <= n_data_stream_cnt_for_test;
        end
    end
    always @ (*) begin
        n_config_stream_cnt = config_stream_cnt;
        n_asic_start_ready_for_test = asic_start_ready_for_test;
        n_config_stream_catch_41421 = config_stream_catch_41421;
        n_config_stream_catch_41418 = config_stream_catch_41418;
        n_data_stream_cnt_for_test = data_stream_cnt_for_test;


        if (config_stream_cnt == 1) begin 
            n_asic_start_ready_for_test = 0;
        end

        if (fifo_d2a_data_valid && fifo_d2a_data_rd_en) begin
            n_config_stream_cnt = config_stream_cnt + 1;
        end
        if (config_stream_cnt == 41424) begin 
            n_asic_start_ready_for_test = 1;
        end

        
        if (fifo_d2a_data_valid && fifo_d2a_data_rd_en) begin
            if (config_stream_cnt == 41424 - 3 - 3) begin 
                n_config_stream_catch_41418 = fifo_d2a_data_dout;
            end
            if (config_stream_cnt == 41424 - 3) begin 
                n_config_stream_catch_41421 = fifo_d2a_data_dout;
            end
        end





        if (data_stream_cnt_for_test == 1) begin 
            n_asic_start_ready_for_test = 0;
        end

        if (a_config_dataset == 0) begin
            if (data_stream_cnt_for_test == sample_num * a_config_timesteps * 15) begin 
            // if (data_stream_cnt_for_test == 29_370_000) begin 
                n_asic_start_ready_for_test = 1;
            end
        end else if (a_config_dataset == 1) begin
            if (data_stream_cnt_for_test == sample_num * a_config_timesteps * 9) begin 
            // if (data_stream_cnt_for_test == 540_000_000) begin 
                n_asic_start_ready_for_test = 1;
            end
        end else if (a_config_dataset == 2) begin
            if (data_stream_cnt_for_test == sample_num * a_config_timesteps * 9) begin 
            // if (data_stream_cnt_for_test == 58_060_800) begin 
            // if (data_stream_cnt_for_test == 58_032_000) begin 
                n_asic_start_ready_for_test = 1;
            end
        end



    end
    // ######### for VERIFICATION ###########################################################################
    // ######### for VERIFICATION ###########################################################################
    // ######### for VERIFICATION ###########################################################################




// gesture streaming 총 횟수: 29_370_000 =  200epochs * 979samples * 10 timesteps * 15trans
// nmnist streaming 총 횟수: 540_000_000 =  200epochs * 60000samples * 5 timesteps * 9trans
// ntidigits wrod0 streaming 총 횟수: 58_060_800 =  200epochs * 4032samples * 8 timesteps * 9trans
// ntidigits else streaming 총 횟수: 58_032_000 =  200epochs * 4030samples * 8 timesteps * 9trans









endmodule