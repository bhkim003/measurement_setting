module d_domain(
        input sys_clk_p,
        input sys_clk_n,
        input reset_n,

        // p2d command fifo
        output reg fifo_p2d_command_rd_en,
        input [32 - 1:0] fifo_p2d_command_dout,
        input fifo_p2d_command_empty,


        // p2d data fifo
        output reg fifo_p2d_data_rd_en,
        input [256 - 1:0] fifo_p2d_data_dout,
        input fifo_p2d_data_empty,


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




        // DRAM Interface
        output                 ui_clk,

        output wire [12 - 1:0]    device_temp,

        output wire [14:0]  ddr3_addr,
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

        // output wire [0 :0]  ddr3_cs_n,
        output wire [3 :0]  ddr3_dm,
        output wire [0 :0]  ddr3_odt
    );

localparam  DRAM_READ       = 3'b001,
            DRAM_WRITE      = 3'b000;

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
    // reg [17*15 - 1:0] d_config_layer1_cut_list, n_d_config_layer1_cut_list;
    // reg [16*15 - 1:0] d_config_layer2_cut_list, n_d_config_layer2_cut_list;

    reg dram_reset_complete_trg_have_been_sent, n_dram_reset_complete_trg_have_been_sent;

    reg [31:0] dram_write_address, n_dram_write_address;
    reg [31:0] dram_write_address_last, n_dram_write_address_last;
    reg [3:0] dram_write_address_transition_cnt, n_dram_write_address_transition_cnt;
    
    reg [31:0] write_count, n_write_count;
    reg dram_writing_phase, n_dram_writing_phase;





        reg	         	app_en, n_app_en;
        reg	[3 - 1:0] 	app_cmd, n_app_cmd;
        reg	[29 - 1:0]	app_addr, n_app_addr; // 29bit address @ 7310,  30bit address @ 7360?, 29bit @ 7310? Please Check
        reg	         	app_wdf_wren, n_app_wdf_wren;
        reg	[256 - 1:0] app_wdf_data, n_app_wdf_data;
        reg	         	app_wdf_end, n_app_wdf_end;
        reg	[32 - 1:0]  app_wdf_mask, n_app_wdf_mask;

        wire	         	app_rdy;
        wire	[256 - 1:0] app_rd_data;
        wire	         	app_rd_data_end;
        wire	         	app_rd_data_valid;
        wire	         	app_wdf_rdy;
        wire          		ui_clk_sync_rst;


    always @(posedge ui_clk) begin
        if(reset_n == 0 || ddr3_reset_n == 0) begin
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

            dram_reset_complete_trg_have_been_sent  <= 0;

            dram_write_address <= 0;
            dram_write_address_last <= 0;
            dram_write_address_transition_cnt <= 0;

            write_count <= 0;
            dram_writing_phase <= 0;

            
                app_en <= 0;
                app_cmd <= 0;
                app_addr <= 0;
                app_wdf_wren <= 0;
                app_wdf_data <= 0;
                app_wdf_end <= 0;
                app_wdf_mask <= 0;

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

            dram_reset_complete_trg_have_been_sent <= n_dram_reset_complete_trg_have_been_sent;

            dram_write_address <= n_dram_write_address;
            dram_write_address_last <= n_dram_write_address_last;
            dram_write_address_transition_cnt <= n_dram_write_address_transition_cnt;

            write_count <= n_write_count;
            dram_writing_phase <= n_dram_writing_phase;

            
                app_en <= n_app_en;
                app_cmd <= n_app_cmd;
                app_addr <= n_app_addr;
                app_wdf_wren <= n_app_wdf_wren;
                app_wdf_data <= n_app_wdf_data;
                app_wdf_end <= n_app_wdf_end;
                app_wdf_mask <= n_app_wdf_mask;
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
        
        n_dram_reset_complete_trg_have_been_sent = dram_reset_complete_trg_have_been_sent;




        fifo_a2d_command_rd_en = 0;

        fifo_d2p_command_wr_en = 0;
        fifo_d2p_command_din = 0;



        n_dram_write_address = dram_write_address;
        n_dram_write_address_last = dram_write_address_last;
        n_dram_write_address_transition_cnt = dram_write_address_transition_cnt;


        n_write_count = write_count;
        n_dram_writing_phase = dram_writing_phase;

        n_app_en = 0;
        n_app_cmd = 0;
        n_app_addr = 0;
        n_app_wdf_wren = 0;
        n_app_wdf_data = 0;
        n_app_wdf_end = 0;
        n_app_wdf_mask = 0;
        
        fifo_p2d_data_rd_en = 0;

        if (!fifo_d2p_command_full) begin
            if (dram_reset_complete_trg_have_been_sent == 0 && init_calib_complete) begin
                fifo_d2p_command_wr_en = 1;
                fifo_d2p_command_din = {{17{1'b0}}, 15'd3};
                n_dram_reset_complete_trg_have_been_sent = 1;
            end 
        end

        if (!fifo_p2d_command_empty) begin
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
                    end else if (config_d_domain_setting_cnt >= 9 && config_d_domain_setting_cnt <= 38) begin
                        n_config_d_domain_setting_cnt = config_d_domain_setting_cnt + 1;
                    end 
                    // else if (config_d_domain_setting_cnt == 39) begin
                        // @ last no cnt increment
                    // end
                end
            end else if (fifo_p2d_command_dout[14:0] == 4) begin
                n_write_count = 0;
                fifo_p2d_command_rd_en = 1;
                if (dram_write_address_transition_cnt == 0) begin
                    n_dram_write_address_transition_cnt = dram_write_address_transition_cnt + 1;
                    n_dram_write_address[0 +: 16] = fifo_p2d_command_dout[15 +: 16];
                end else if (dram_write_address_transition_cnt == 1) begin
                    n_dram_write_address_transition_cnt = dram_write_address_transition_cnt + 1;
                    n_dram_write_address[16 +: 16] = fifo_p2d_command_dout[15 +: 16];
                end else if (dram_write_address_transition_cnt == 2) begin
                    n_dram_write_address_transition_cnt = dram_write_address_transition_cnt + 1;
                    n_dram_write_address_last[0 +: 16] = fifo_p2d_command_dout[15 +: 16];
                end else if (dram_write_address_transition_cnt == 3) begin
                    n_dram_write_address_transition_cnt = 0;
                    n_dram_write_address_last[16 +: 16] = fifo_p2d_command_dout[15 +: 16];
                end
            end
        end


        if (!fifo_a2d_command_empty) begin
            if (fifo_a2d_command_dout[14:0] == 2) begin
                if (config_d_domain_setting_cnt == 39) begin
                    if (!fifo_d2p_command_full) begin
                        fifo_a2d_command_rd_en = 1;
                        fifo_d2p_command_wr_en = 1;
                        fifo_d2p_command_din = fifo_a2d_command_dout;
                        n_config_d_domain_setting_cnt = 0;
                    end
                end
            end
        end








        
            
        if (!fifo_p2d_data_empty) begin
            if (app_rdy && app_wdf_rdy) begin
                fifo_p2d_data_rd_en = 1;
                n_app_en = 1;
                n_app_cmd = DRAM_WRITE;
                n_app_addr = dram_write_address[0 +:29] + write_count;
                n_app_wdf_wren = 1;
                n_app_wdf_data = fifo_p2d_data_dout_align;
                n_app_wdf_end = 1;
                n_app_wdf_mask = 0;
                n_write_count = write_count + 8; // 256bit / 32byte = 8
                n_dram_writing_phase = 1;
            end
        end

        // if (dram_writing_phase) begin
        //     if (dram_write_address_last + 8 == dram_write_address[0 +:29] + write_count) begin
        //         if (!fifo_d2p_command_full) begin
        //             fifo_d2p_command_wr_en = 1;
        //             fifo_d2p_command_din = {17'd0, 15'd5};
        //             n_write_count = write_count - 8; // 256bit / 32byte = 8
        //             n_dram_writing_phase = 0;
        //         end
        //     end
        // end
        if (dram_writing_phase) begin
            if (dram_write_address_last + 8 == dram_write_address[0 +:29] + write_count) begin
                if (!fifo_d2p_command_full) begin
                    if (app_rdy) begin
                        fifo_d2p_command_wr_en = 1;
                        fifo_d2p_command_din = {17'd0, 15'd5};
                        n_write_count = write_count - 8; // 256bit / 32byte = 8
                        n_dram_writing_phase = 0;

                        n_app_en = 0;
                        n_app_cmd = DRAM_READ;
                        n_app_addr = dram_write_address[0 +:29];
                    end
                end
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

            // .ddr3_cs_n                      (ddr3_cs_n),
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
