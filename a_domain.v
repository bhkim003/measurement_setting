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


        fifo_a2d_command_wr_en = 0;
        fifo_a2d_command_din = 0;

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


endmodule