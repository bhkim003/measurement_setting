module top_bh_fpga(
        // ########################## okHost interface ########################################################################################
        // ########################## okHost interface ########################################################################################
        // ########################## okHost interface ########################################################################################
        input   wire [4:0]  okUH,
        output  wire [2:0]  okHU,
        inout   wire [31:0] okUHU,
        inout   wire        okAA,
        // ########################## okHost interface ########################################################################################
        // ########################## okHost interface ########################################################################################
        // ########################## okHost interface ########################################################################################




        // ########################## sys_clk ########################################################################################
        // ########################## sys_clk ########################################################################################
        // ########################## sys_clk ########################################################################################
        // input   wire        sys_clk,
        input   wire        sys_clk_p,
        input   wire        sys_clk_n,
        // ########################## sys_clk ########################################################################################
        // ########################## sys_clk ########################################################################################
        // ########################## sys_clk ########################################################################################





        // ########################## led ########################################################################################
        // ########################## led ########################################################################################
        // ########################## led ########################################################################################
        output  reg [7:0]  led,
        // ########################## led ########################################################################################
        // ########################## led ########################################################################################
        // ########################## led ########################################################################################
        



        // // ########################## dram interface ########################################################################################
        // // ########################## dram interface ########################################################################################
        // // ########################## dram interface ########################################################################################
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

        // output wire [0 :0]  ddr3_cs_n,
        output wire [0 :0]  ddr3_odt,
        output wire [3 :0]  ddr3_dm,
        // // ########################## dram interface ########################################################################################
        // // ########################## dram interface ########################################################################################
        // // ########################## dram interface ########################################################################################




        // @@@@@@@@ YOU MUST WRITE TO PORT BELOW AT XDC FILE !!!!!!!!!!!!!!! @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        // @@@@@@@@ YOU MUST WRITE TO PORT BELOW AT XDC FILE !!!!!!!!!!!!!!! @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        // @@@@@@@@ YOU MUST WRITE TO PORT BELOW AT XDC FILE !!!!!!!!!!!!!!! @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        // @@@@@@@@ YOU MUST WRITE TO PORT BELOW AT XDC FILE !!!!!!!!!!!!!!! @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        // @@@@@@@@ YOU MUST WRITE TO PORT BELOW AT XDC FILE !!!!!!!!!!!!!!! @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        // @@@@@@@@ YOU MUST WRITE TO PORT BELOW AT XDC FILE !!!!!!!!!!!!!!! @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        // @@@@@@@@ YOU MUST WRITE TO PORT BELOW AT XDC FILE !!!!!!!!!!!!!!! @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        // @@@@@@@@ YOU MUST WRITE TO PORT BELOW AT XDC FILE !!!!!!!!!!!!!!! @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        // @@@@@@@@ YOU MUST WRITE TO PORT BELOW AT XDC FILE !!!!!!!!!!!!!!! @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        // @@@@@@@@ YOU MUST WRITE TO PORT BELOW AT XDC FILE !!!!!!!!!!!!!!! @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        // @@@@@@@@ YOU MUST WRITE TO PORT BELOW AT XDC FILE !!!!!!!!!!!!!!! @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@




        // ########################## clk generated from clock generator ########################################################################################
        // ########################## clk generated from clock generator ########################################################################################
        // ########################## clk generated from clock generator ########################################################################################
        input clk_clock_generator,
        input clk_port_spare_0,
        output clk_port_spare_1,
        // ########################## clk generated from clock generator ########################################################################################
        // ########################## clk generated from clock generator ########################################################################################
        // ########################## clk generated from clock generator ########################################################################################





        // ########################## fpga to asic, asic to fpga ########################################################################################
        // ########################## fpga to asic, asic to fpga ########################################################################################
        // ########################## fpga to asic, asic to fpga ########################################################################################
        output reset_n_from_fpga_to_asic,

        output input_streaming_valid_from_fpga_to_asic,
        output [65:0] input_streaming_data_from_fpga_to_asic,
        input input_streaming_ready_from_asic_to_fpga,

        output start_training_signal_from_fpga_to_asic, 
        output start_inference_signal_from_fpga_to_asic, 
        input start_ready_from_asic_to_fpga, 

        input inferenced_label_from_asic_to_fpga 
        // ########################## fpga to asic, asic to fpga ########################################################################################
        // ########################## fpga to asic, asic to fpga ########################################################################################
        // ########################## fpga to asic, asic to fpga ########################################################################################
    );



	// ########################## End Point Connet ########################################################################################
    wire            okClk;
    wire [112:0]    okHE;
    wire [64:0]     okEH;
    okHost okHI(
        .okUH(okUH),
        .okHU(okHU),
        .okUHU(okUHU),
        .okAA(okAA),
        .okClk(okClk),
        .okHE(okHE), 
        .okEH(okEH)
    );

    localparam N = 5;
    wire [65 - 1:0] okEHx [0:N-1];
    wire [65 * N - 1:0] okEHx_flat;
    genvar okEHx_idx;
    generate
        for(okEHx_idx = 0; okEHx_idx < N; okEHx_idx = okEHx_idx + 1) begin : gen_okEHx_flat
            assign okEHx_flat[okEHx_idx*65 +: 65] = okEHx[okEHx_idx];
        end
    endgenerate
    okWireOR #(.N(N)) wireOR (okEH, okEHx_flat);
 

    wire [32 - 1:0] ep00wirein;  // reset_n
    okWireIn WireIn00       (.okHE(okHE), .ep_addr(8'h00), .ep_dataout(ep00wirein));
    wire reset_n;
    assign reset_n = ep00wirein[0];

    wire [32 - 1:0] ep01wirein;
    okWireIn WireIn01       (.okHE(okHE), .ep_addr(8'h01), .ep_dataout(ep01wirein));

    reg [32 - 1:0] ep20wireout, n_ep20wireout;
    okWireOut WireOut20(.okHE(okHE), .okEH(okEHx[0]), .ep_addr(8'h20), .ep_datain(ep20wireout));

    reg [32 - 1:0] ep21wireout, n_ep21wireout;
    okWireOut WireOut21(.okHE(okHE), .okEH(okEHx[1]), .ep_addr(8'h21), .ep_datain(ep21wireout));

    wire [32 - 1:0] ep40trigin;
    okTriggerIn TrigIn40 (.okHE(okHE), .ep_addr(8'h40), .ep_clk(okClk), .ep_trigger(ep40trigin));
    
    reg [32 - 1:0] ep60trigout;
    okTriggerOut TrigOut60(.okHE(okHE), .okEH(okEHx[2]), .ep_addr(8'h60), .ep_clk(okClk), .ep_trigger(ep60trigout));

    wire [32 - 1:0] pipe_in_data; 
    wire pipe_in_valid;
    reg	pipe_in_ready;
    okBTPipeIn  BTPipeIn80  (.okHE(okHE), .okEH(okEHx[3]), .ep_addr(8'h80), .ep_dataout(pipe_in_data), .ep_write(pipe_in_valid), .ep_blockstrobe(), .ep_ready(pipe_in_ready));
    
    wire pipe_out_read;
    wire [32 - 1:0] pipe_out_data;
    reg	pipe_out_ready;
    okBTPipeOut BTPipeOutA0 (.okHE(okHE), .okEH(okEHx[4]), .ep_addr(8'hA0), .ep_datain(pipe_out_data), .ep_read(pipe_out_read), .ep_blockstrobe(), .ep_ready(pipe_out_ready));
	// ########################## End Point Connet ########################################################################################


    // ########################## LED Function ########################################################################################
    function [7:0] xem7310_led;
    input [7:0] a;
    integer i_led;
    begin
        for(i_led = 0; i_led < 8; i_led = i_led + 1) begin
            xem7310_led[i_led] = (a[i_led] == 1'b1) ? 1'b0 : 1'bz;
        end
    end
    endfunction
    // ########################## LED Function ########################################################################################



    // ########################## MIG ########################################################################################
    wire          		ui_clk;
    wire          		ui_clk_sync_rst;
    wire [12 - 1:0]    device_temp;
    wire          init_calib_complete;
    // ########################## MIG ########################################################################################



    // ########################## sys_clk gen instance ########################################################################################
    wire sys_clk;
    // // IBUFGDS osc_clk(.O(sys_clk), .I(sys_clk_p), .IB(sys_clk_n));
    assign sys_clk = ui_clk;
    wire sys_clk2;
    assign sys_clk2 = okClk;
    // ########################## sys_clk gen instance ########################################################################################



    localparam P_STATE_00_IDLE = 0;
    localparam P_STATE_01_WORKLOAD_CONFIG = 1;
    localparam P_STATE_02_WORKLOAD_CONFIG_DONE = 2;
    localparam P_STATE_03_DRAMFILL_WEIGHT_DATA = 3;
    localparam P_STATE_04_DRAMFILL_WEIGHT_DATA_DONE = 4;
    localparam P_STATE_05_DRAMFILL_INFERENCE_DATA = 5; // When DRAMFILL finish, go to P_STATE_04_DRAMFILL_WEIGHT_DATA_DONE
    localparam P_STATE_06_DRAMFILL_TRAINING_DATA = 6; // When DRAMFILL finish, go to P_STATE_04_DRAMFILL_WEIGHT_DATA_DONE
    localparam P_STATE_07_ASIC_CONFIG = 7;
    localparam P_STATE_08_ASIC_CONFIG_DONE = 8;
    localparam P_STATE_09_ASIC_INFERENCE_QUEUING = 9;
    localparam P_STATE_10_ASIC_INFERENCE_PROCESSING = 10;
    localparam P_STATE_11_ASIC_TRAINING_QUEUING = 11;
    localparam P_STATE_12_ASIC_TRAINING_PROCESSING = 12;

    reg [7:0] p_state, n_p_state;

    reg config_all_domain_setting_complete, n_config_all_domain_setting_complete;


    reg fifo_p2d_command_wr_en;
    reg [32 - 1:0] fifo_p2d_command_din;
    wire fifo_p2d_command_full;
    wire fifo_p2d_command_rd_en;
    wire [32 - 1:0] fifo_p2d_command_dout;
    wire fifo_p2d_command_empty;
    wire fifo_p2d_command_valid;


    reg fifo_p2d_data_wr_en;
    reg [32 - 1:0] fifo_p2d_data_din;
    wire fifo_p2d_data_full;
    wire fifo_p2d_data_rd_en;
    wire [256 - 1:0] fifo_p2d_data_dout;
    wire fifo_p2d_data_empty;
    wire fifo_p2d_data_valid;
    reg [32 - 1:0] fifo_p2d_data_wr_cnt;
    reg [32 - 1:0] dram_write_cnt, n_dram_write_cnt;

    wire fifo_d2p_command_wr_en;
    wire [32 - 1:0] fifo_d2p_command_din;
    wire fifo_d2p_command_full;
    reg fifo_d2p_command_rd_en;
    wire [32 - 1:0] fifo_d2p_command_dout;
    wire fifo_d2p_command_empty;
    wire fifo_d2p_command_valid;

    wire fifo_d2a_command_wr_en;
    wire [32 - 1:0] fifo_d2a_command_din;
    wire fifo_d2a_command_full;
    wire fifo_d2a_command_rd_en;
    wire [32 - 1:0] fifo_d2a_command_dout;
    wire fifo_d2a_command_empty;
    wire fifo_d2a_command_valid;

    wire fifo_d2a_data_wr_en;
    wire [66 - 1:0] fifo_d2a_data_din;
    wire fifo_d2a_data_full;
    wire fifo_d2a_data_rd_en;
    wire [66 - 1:0] fifo_d2a_data_dout;
    wire fifo_d2a_data_empty;
    wire fifo_d2a_data_valid;


    wire fifo_a2d_command_wr_en;
    wire [32 - 1:0] fifo_a2d_command_din;
    wire fifo_a2d_command_full;
    wire fifo_a2d_command_rd_en;
    wire [32 - 1:0] fifo_a2d_command_dout;
    wire fifo_a2d_command_empty;
    wire fifo_a2d_command_valid;


    always @(posedge okClk) begin
        if (!reset_n) begin
            dram_write_cnt <= 0;
            fifo_p2d_data_wr_cnt <= 0;
        end else begin
            dram_write_cnt <= n_dram_write_cnt;

            if (ep40trigin[30]) begin
                fifo_p2d_data_wr_cnt <= 0;
            end else if (fifo_p2d_data_wr_en) begin
                fifo_p2d_data_wr_cnt <= fifo_p2d_data_wr_cnt + 1;
            end
        end
    end


    // ########################## P TO D DOMAIN CROSSING FIFO ########################################################################################
    fifo_bh_ww32d16_rw32d16 u_fifo_p2d_command(
        .rst(reset_n == 0 || ui_clk_sync_rst),
        // write
        .wr_clk(okClk),
        .wr_en(fifo_p2d_command_wr_en),
        .din(fifo_p2d_command_din),
        .full(fifo_p2d_command_full),
        // read
        .rd_clk(sys_clk),
        .rd_en(fifo_p2d_command_rd_en),
        .dout(fifo_p2d_command_dout),
        .empty(fifo_p2d_command_empty),
        .valid(fifo_p2d_command_valid)
    );


    fifo_bh_ww32d4096_rw256d512 u_fifo_p2d_data(
        .rst(reset_n == 0 || ui_clk_sync_rst),
        // write
        .wr_clk(okClk),
        .wr_en(fifo_p2d_data_wr_en),
        .din(fifo_p2d_data_din),
        .full(fifo_p2d_data_full),
        // read
        .rd_clk(sys_clk),
        .rd_en(fifo_p2d_data_rd_en),
        .dout(fifo_p2d_data_dout),
        .empty(fifo_p2d_data_empty),
        .valid(fifo_p2d_data_valid)
    );
    // ########################## P TO D DOMAIN CROSSING FIFO ########################################################################################

    // ########################## D TO P DOMAIN CROSSING FIFO ########################################################################################
    fifo_bh_ww32d16_rw32d16 u_fifo_d2p_command(
        .rst(reset_n == 0 || ui_clk_sync_rst),
        // write
        .wr_clk(sys_clk),
        .wr_en(fifo_d2p_command_wr_en),
        .din(fifo_d2p_command_din),
        .full(fifo_d2p_command_full),
        // read
        .rd_clk(okClk),
        .rd_en(fifo_d2p_command_rd_en),
        .dout(fifo_d2p_command_dout),
        .empty(fifo_d2p_command_empty),
        .valid(fifo_d2p_command_valid)
    );
    // ########################## D TO P DOMAIN CROSSING FIFO ########################################################################################
 
    // ########################## D TO A DOMAIN CROSSING FIFO ########################################################################################

    fifo_bh_ww32d16_rw32d16 u_fifo_d2a_command(
        .rst(reset_n == 0 || ui_clk_sync_rst),
        // write
        .wr_clk(sys_clk),
        .wr_en(fifo_d2a_command_wr_en),
        .din(fifo_d2a_command_din),
        .full(fifo_d2a_command_full),
        // read
        .rd_clk(sys_clk2),
        .rd_en(fifo_d2a_command_rd_en),
        .dout(fifo_d2a_command_dout),
        .empty(fifo_d2a_command_empty),
        .valid(fifo_d2a_command_valid)
    );

    fifo_bh_ww66d1024_rw66d1024 u_fifo_d2a_data(
        .rst(reset_n == 0 || ui_clk_sync_rst),
        // write
        .wr_clk(sys_clk),
        .wr_en(fifo_d2a_data_wr_en),
        .din(fifo_d2a_data_din),
        .full(fifo_d2a_data_full),
        // read
        .rd_clk(sys_clk2),
        .rd_en(fifo_d2a_data_rd_en),
        .dout(fifo_d2a_data_dout),
        .empty(fifo_d2a_data_empty),
        .valid(fifo_d2a_data_valid)
    );
    // ########################## D TO A DOMAIN CROSSING FIFO ########################################################################################

    // ########################## A TO D DOMAIN CROSSING FIFO ########################################################################################
    fifo_bh_ww32d16_rw32d16 u_fifo_a2d_command(
        .rst(reset_n == 0 || ui_clk_sync_rst),
        // write
        .wr_clk(sys_clk2),
        .wr_en(fifo_a2d_command_wr_en),
        .din(fifo_a2d_command_din),
        .full(fifo_a2d_command_full),
        // read
        .rd_clk(sys_clk),
        .rd_en(fifo_a2d_command_rd_en),
        .dout(fifo_a2d_command_dout),
        .empty(fifo_a2d_command_empty),
        .valid(fifo_a2d_command_valid)
    );
    // ########################## A TO D DOMAIN CROSSING FIFO ########################################################################################
    
    
    // ########################## D DOMAIN ########################################################################################
    d_domain u_d_domain(
        .sys_clk_p                    ( sys_clk_p                    ),
        .sys_clk_n                    ( sys_clk_n                    ),
        .reset_n                ( reset_n                ),

        .fifo_p2d_command_rd_en ( fifo_p2d_command_rd_en ),
        .fifo_p2d_command_dout  ( fifo_p2d_command_dout  ),
        .fifo_p2d_command_empty ( fifo_p2d_command_empty ),
        .fifo_p2d_command_valid ( fifo_p2d_command_valid ),

        .fifo_p2d_data_rd_en    ( fifo_p2d_data_rd_en    ),
        .fifo_p2d_data_dout     ( fifo_p2d_data_dout     ),
        .fifo_p2d_data_empty    ( fifo_p2d_data_empty    ),
        .fifo_p2d_data_valid    ( fifo_p2d_data_valid    ),

        .fifo_d2p_command_wr_en ( fifo_d2p_command_wr_en ),
        .fifo_d2p_command_din   ( fifo_d2p_command_din   ),
        .fifo_d2p_command_full  ( fifo_d2p_command_full  ),

        .fifo_d2a_command_wr_en ( fifo_d2a_command_wr_en ),
        .fifo_d2a_command_din   ( fifo_d2a_command_din   ),
        .fifo_d2a_command_full  ( fifo_d2a_command_full  ),

        .fifo_d2a_data_wr_en ( fifo_d2a_data_wr_en ),
        .fifo_d2a_data_din   ( fifo_d2a_data_din   ),
        .fifo_d2a_data_full  ( fifo_d2a_data_full  ),

        .fifo_a2d_command_rd_en    ( fifo_a2d_command_rd_en    ),
        .fifo_a2d_command_dout     ( fifo_a2d_command_dout     ),
        .fifo_a2d_command_empty    ( fifo_a2d_command_empty    ),
        .fifo_a2d_command_valid    ( fifo_a2d_command_valid    ),


        // Memory interface ports
        .ui_clk                          ( ui_clk                          ),
        .ui_clk_sync_rst                          ( ui_clk_sync_rst                          ),

        .device_temp                      ( device_temp                      ),

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
        .ddr3_odt                         ( ddr3_odt                         )
    );
    // ########################## D DOMAIN ########################################################################################



    // ########################## A DOMAIN ########################################################################################
    a_domain u_a_domain(
        .clk_a_domain                    ( sys_clk2                    ),
        .reset_n                ( reset_n                ),

        .fifo_d2a_command_rd_en ( fifo_d2a_command_rd_en ),
        .fifo_d2a_command_dout  ( fifo_d2a_command_dout  ),
        .fifo_d2a_command_empty ( fifo_d2a_command_empty ),
        .fifo_d2a_command_valid ( fifo_d2a_command_valid ),

        .fifo_d2a_data_rd_en    ( fifo_d2a_data_rd_en    ),
        .fifo_d2a_data_dout     ( fifo_d2a_data_dout     ),
        .fifo_d2a_data_empty    ( fifo_d2a_data_empty    ),
        .fifo_d2a_data_valid    ( fifo_d2a_data_valid    ),

        .fifo_a2d_command_wr_en ( fifo_a2d_command_wr_en ),
        .fifo_a2d_command_din   ( fifo_a2d_command_din   ),
        .fifo_a2d_command_full  ( fifo_a2d_command_full  ),



        .reset_n_from_fpga_to_asic ( reset_n_from_fpga_to_asic ),

        .input_streaming_valid_from_fpga_to_asic   ( input_streaming_valid_from_fpga_to_asic   ),
        .input_streaming_data_from_fpga_to_asic  ( input_streaming_data_from_fpga_to_asic  ),
        .input_streaming_ready_from_asic_to_fpga  ( input_streaming_ready_from_asic_to_fpga  ),

        .start_training_signal_from_fpga_to_asic  ( start_training_signal_from_fpga_to_asic  ),
        .start_inference_signal_from_fpga_to_asic  ( start_inference_signal_from_fpga_to_asic  ),
        .start_ready_from_asic_to_fpga  ( start_ready_from_asic_to_fpga  ),

        .inferenced_label_from_asic_to_fpga  ( inferenced_label_from_asic_to_fpga  )
    );
    // ########################## A DOMAIN ########################################################################################




    // ########################## P (okClk 100.8MHz) DOMAIN CONTROL ########################################################################################
    reg [1:0] p_config_asic_mode, n_p_config_asic_mode; // 0 training_only, 1 train_inf_sweep, 2 inference_only 
    reg [15:0] p_config_training_epochs, n_p_config_training_epochs;
    reg [15:0] p_config_inference_epochs, n_p_config_inference_epochs;
    reg [1:0] p_config_dataset, n_p_config_dataset; // 0 DVS_GESTURE, 1 N_MNIST, 2 NTIDIGITS
    reg [15:0] p_config_timesteps, n_p_config_timesteps;
    reg [15:0] p_config_input_size_layer1_define, n_p_config_input_size_layer1_define;
    reg p_config_long_time_input_streaming_mode, n_p_config_long_time_input_streaming_mode;
    reg p_config_binary_classifier_mode, n_p_config_binary_classifier_mode;
    reg p_config_loser_encourage_mode, n_p_config_loser_encourage_mode;
    reg [17*15 - 1:0] p_config_layer1_cut_list, n_p_config_layer1_cut_list;
    reg [16*15 - 1:0] p_config_layer2_cut_list, n_p_config_layer2_cut_list;

    reg [3:0] p_config_cut_cnt, n_p_config_cut_cnt;
    reg [3:0] p_config_cut_cnt_past, n_p_config_cut_cnt_past;

    reg blink_1000ms, blink_1000ms_past;
    reg [25:0] blink_1000ms_cnt;
    reg blink_500ms, blink_500ms_past;
    reg [25:0] blink_500ms_cnt;
    reg blink_100ms, blink_100ms_past;
    reg [25:0] blink_100ms_cnt;
    
    reg [2:0] led_pos;   // 0~7
    reg       led_dir;   // 0: left->right, 1: right->left
    reg config_all_domain_setting_ongoing, n_config_all_domain_setting_ongoing;
    reg [15:0] config_all_domain_setting_cnt, n_config_all_domain_setting_cnt;

        
    reg [31:0] dram_address, n_dram_address;
    reg [31:0] dram_address_last, n_dram_address_last;
    reg [3:0] dram_address_transition_cnt, n_dram_address_transition_cnt;

    reg [15:0] config_stream_cnt, n_config_stream_cnt;

    reg [31:0] sample_num, n_sample_num;
    reg [3:0] sample_num_transition_cnt, n_sample_num_transition_cnt;

    always @(posedge okClk) begin
        if (!reset_n) begin
            ep20wireout <= 0;
            ep21wireout <= 0;
        end else begin
            ep20wireout <= n_ep20wireout;
            ep21wireout <= n_ep21wireout;
        end
    end


    reg [17 - 1:0] app_rd_data_check, n_app_rd_data_check;
    reg asic_start_ready, n_asic_start_ready;
    reg asic_config_ongoing, n_asic_config_ongoing;
    always @ (*) begin
        n_ep20wireout = ep01wirein;
        n_ep21wireout = p_state;
        led = xem7310_led(p_state & {8{blink_1000ms}});
        // led = xem7310_led(8'b00000001 << led_pos);

        if (p_state == P_STATE_00_IDLE) begin
            led = xem7310_led({8{blink_1000ms}});
        end else if (p_state == P_STATE_01_WORKLOAD_CONFIG) begin
            if (ep01wirein == 0) begin
                if (config_all_domain_setting_complete) begin
                    led = xem7310_led({8{blink_100ms}});
                    n_ep20wireout = 42; 
                end
            end else begin
                if (ep01wirein == 1) begin
                    led = xem7310_led({6'd0, p_config_asic_mode});
                    n_ep20wireout = p_config_asic_mode;
                end else if (ep01wirein == 2) begin
                    led = xem7310_led(p_config_training_epochs[7:0]);
                    n_ep20wireout = p_config_training_epochs;
                end else if (ep01wirein == 3) begin
                    led = xem7310_led(p_config_inference_epochs[7:0]);
                    n_ep20wireout = p_config_inference_epochs;
                end else if (ep01wirein == 4) begin
                    led = xem7310_led({6'd0, p_config_dataset});
                    n_ep20wireout = p_config_dataset;
                end else if (ep01wirein == 5) begin
                    led = xem7310_led(p_config_timesteps[7:0]);
                    n_ep20wireout = p_config_timesteps;
                end else if (ep01wirein == 6) begin
                    led = xem7310_led(p_config_input_size_layer1_define[7:0]);
                    n_ep20wireout = p_config_input_size_layer1_define;
                end else if (ep01wirein == 7) begin
                    led = xem7310_led({7'd0, p_config_long_time_input_streaming_mode});
                    n_ep20wireout = p_config_long_time_input_streaming_mode;
                end else if (ep01wirein == 8) begin
                    led = xem7310_led({7'd0, p_config_binary_classifier_mode});
                    n_ep20wireout = p_config_binary_classifier_mode;
                end else if (ep01wirein == 9) begin
                    led = xem7310_led({7'd0, p_config_loser_encourage_mode});
                    n_ep20wireout = p_config_loser_encourage_mode;
                end else if (ep01wirein == 10) begin
                    led = xem7310_led(p_config_layer1_cut_list[17*p_config_cut_cnt_past +: 8]);
                    n_ep20wireout = {{15{p_config_layer1_cut_list[17*p_config_cut_cnt_past + 16]}},p_config_layer1_cut_list[17*p_config_cut_cnt_past +: 17]};
                end else if (ep01wirein == 11) begin
                    led = xem7310_led(p_config_layer2_cut_list[16*p_config_cut_cnt_past +: 8]);
                    n_ep20wireout = {{16{p_config_layer2_cut_list[16*p_config_cut_cnt_past + 15]}},p_config_layer2_cut_list[16*p_config_cut_cnt_past +: 16]};
                end else begin
                    led = xem7310_led(255 & {blink_1000ms, blink_1000ms, blink_1000ms, blink_1000ms, !blink_1000ms, !blink_1000ms, !blink_1000ms, !blink_1000ms});
                    n_ep20wireout = 0;
                end
            end
            if (config_all_domain_setting_ongoing) begin
                // configure value update ongoing
                led = xem7310_led((8'b00000001 << led_pos) | p_state);
                n_ep20wireout = 0;
            end 
        end else if (p_state == P_STATE_03_DRAMFILL_WEIGHT_DATA || p_state == P_STATE_04_DRAMFILL_WEIGHT_DATA_DONE ||
                     p_state == P_STATE_05_DRAMFILL_INFERENCE_DATA || p_state == P_STATE_06_DRAMFILL_TRAINING_DATA) begin
            if (ep01wirein != 0) begin
                // led = xem7310_led(fifo_p2d_data_dout[7:0]);
                // n_ep20wireout = fifo_p2d_data_dout[32*(ep01wirein-1) +: 32];
                
                if (ep01wirein == 10) begin
                    led = xem7310_led(dram_address[7:0]);
                    n_ep20wireout = dram_address;
                end else if (ep01wirein == 11) begin
                    led = xem7310_led(dram_address_last[7:0]);
                    n_ep20wireout = dram_address_last;
                end else if (ep01wirein == 12) begin
                    led = xem7310_led(fifo_p2d_data_wr_cnt[7:0]);
                    n_ep20wireout = fifo_p2d_data_wr_cnt;
                end else if (ep01wirein == 13) begin
                    led = xem7310_led(dram_write_cnt[7:0]);
                    n_ep20wireout = dram_write_cnt;
                end else if (ep01wirein == 14) begin
                    led = xem7310_led(app_rd_data_check[7:0]);
                    n_ep20wireout = app_rd_data_check;
                end
            end
        end else if (p_state == P_STATE_07_ASIC_CONFIG || p_state == P_STATE_08_ASIC_CONFIG_DONE) begin
            if (ep01wirein == 0) begin
                if (asic_config_ongoing) begin
                    led = xem7310_led(p_state & {8{blink_100ms}});
                end else if (asic_start_ready == 1) begin
                    led = xem7310_led(p_state & {8{blink_500ms}});
                    n_ep20wireout = 1;
                end else begin
                    led = xem7310_led(p_state & {8{blink_1000ms}});
                    n_ep20wireout = 0;
                end
            end else if (ep01wirein == 1) begin
                led = xem7310_led(config_stream_cnt[7:0]);
                n_ep20wireout = {16'd0, config_stream_cnt};
            end else if (ep01wirein == 2) begin
                led = xem7310_led(sample_num[7:0]);
                n_ep20wireout = sample_num;
            end else if (ep01wirein == 10) begin
                led = xem7310_led(dram_address[7:0]);
                n_ep20wireout = dram_address;
            end else if (ep01wirein == 11) begin
                led = xem7310_led(dram_address_last[7:0]);
                n_ep20wireout = dram_address_last;
            end
        end else if (p_state == P_STATE_09_ASIC_INFERENCE_QUEUING || p_state == P_STATE_11_ASIC_TRAINING_QUEUING) begin
            if (ep01wirein == 0) begin
                if (asic_config_ongoing) begin
                    led = xem7310_led(p_state & {8{blink_100ms}});
                end else if (asic_start_ready == 1) begin
                    led = xem7310_led(p_state & {8{blink_500ms}});
                    n_ep20wireout = 1;
                end else begin
                    led = xem7310_led(p_state & {8{blink_1000ms}});
                    n_ep20wireout = 0;
                end
            end else if (ep01wirein == 1) begin
                led = xem7310_led(config_stream_cnt[7:0]);
                n_ep20wireout = {16'd0, config_stream_cnt};
            end else if (ep01wirein == 2) begin
                led = xem7310_led(sample_num[7:0]);
                n_ep20wireout = sample_num;
            end else if (ep01wirein == 10) begin
                led = xem7310_led(dram_address[7:0]);
                n_ep20wireout = dram_address;
            end else if (ep01wirein == 11) begin
                led = xem7310_led(dram_address_last[7:0]);
                n_ep20wireout = dram_address_last;
            end
        end

        if (!reset_n) begin
            led = xem7310_led(255);
        end
    end


    reg dram_reset_complete_trg_have_been_sent, n_dram_reset_complete_trg_have_been_sent;

    always @(posedge okClk) begin
        if(!reset_n) begin
            p_state <= 0;

            p_config_asic_mode <= 0;
            p_config_training_epochs <= 0;
            p_config_inference_epochs  <= 0;
            p_config_dataset  <= 0;
            p_config_timesteps  <= 0;
            p_config_input_size_layer1_define  <= 0;
            p_config_long_time_input_streaming_mode  <= 0;
            p_config_binary_classifier_mode  <= 0;
            p_config_loser_encourage_mode  <= 0;
            p_config_layer1_cut_list  <= 0;
            p_config_layer2_cut_list  <= 0;

            p_config_cut_cnt  <= 0;
            p_config_cut_cnt_past <= 0;

            dram_reset_complete_trg_have_been_sent  <= 0;

            config_all_domain_setting_ongoing <= 0;
            config_all_domain_setting_complete <= 0;
            config_all_domain_setting_cnt <= 0;

            dram_address <= 0;
            dram_address_last <= 0;
            dram_address_transition_cnt <= 0;

            app_rd_data_check <= 0;
            asic_start_ready <= 0;
            asic_config_ongoing <= 0;

            config_stream_cnt <= 0;

            sample_num <= 0;
            sample_num_transition_cnt <= 0;
        end else begin
            p_state <= n_p_state;

            p_config_asic_mode <= n_p_config_asic_mode;
            p_config_training_epochs <= n_p_config_training_epochs;
            p_config_inference_epochs <= n_p_config_inference_epochs;
            p_config_dataset <= n_p_config_dataset;
            p_config_timesteps <= n_p_config_timesteps;
            p_config_input_size_layer1_define <= n_p_config_input_size_layer1_define;
            p_config_long_time_input_streaming_mode <= n_p_config_long_time_input_streaming_mode;
            p_config_binary_classifier_mode <= n_p_config_binary_classifier_mode;
            p_config_loser_encourage_mode <= n_p_config_loser_encourage_mode;
            p_config_layer1_cut_list <= n_p_config_layer1_cut_list;
            p_config_layer2_cut_list <= n_p_config_layer2_cut_list;

            p_config_cut_cnt <= n_p_config_cut_cnt;
            p_config_cut_cnt_past <= n_p_config_cut_cnt_past;

            dram_reset_complete_trg_have_been_sent <= n_dram_reset_complete_trg_have_been_sent;

            config_all_domain_setting_ongoing <= n_config_all_domain_setting_ongoing;
            config_all_domain_setting_complete <= n_config_all_domain_setting_complete;
            config_all_domain_setting_cnt <= n_config_all_domain_setting_cnt;

            dram_address <= n_dram_address;
            dram_address_last <= n_dram_address_last;
            dram_address_transition_cnt <= n_dram_address_transition_cnt;

            app_rd_data_check <= n_app_rd_data_check;
            asic_start_ready <= n_asic_start_ready;
            asic_config_ongoing <= n_asic_config_ongoing;

            config_stream_cnt <= n_config_stream_cnt;

            sample_num <= n_sample_num;
            sample_num_transition_cnt <= n_sample_num_transition_cnt;
        end
    end

    reg [17 - 1:0] config_value;
    always @ (*) begin
        n_p_state = p_state;

        n_p_config_asic_mode = p_config_asic_mode;
        n_p_config_training_epochs = p_config_training_epochs;
        n_p_config_inference_epochs = p_config_inference_epochs;
        n_p_config_dataset = p_config_dataset;
        n_p_config_timesteps = p_config_timesteps;
        n_p_config_input_size_layer1_define = p_config_input_size_layer1_define;
        n_p_config_long_time_input_streaming_mode = p_config_long_time_input_streaming_mode;
        n_p_config_binary_classifier_mode = p_config_binary_classifier_mode;
        n_p_config_loser_encourage_mode = p_config_loser_encourage_mode;
        n_p_config_layer1_cut_list = p_config_layer1_cut_list;
        n_p_config_layer2_cut_list = p_config_layer2_cut_list;

        n_p_config_cut_cnt = p_config_cut_cnt;
        n_p_config_cut_cnt_past = p_config_cut_cnt_past;

        n_dram_reset_complete_trg_have_been_sent = dram_reset_complete_trg_have_been_sent;
        
        n_config_all_domain_setting_ongoing = config_all_domain_setting_ongoing;
        n_config_all_domain_setting_complete = config_all_domain_setting_complete;

        // ep60trigout = {31'b0, fsm_done};
        ep60trigout = 32'd0;




        fifo_p2d_command_wr_en = 0;
        fifo_p2d_command_din = 0;

        config_value = 0;
        n_config_all_domain_setting_cnt = config_all_domain_setting_cnt;
        fifo_d2p_command_rd_en = 0;


        n_dram_address = dram_address;
        n_dram_address_last = dram_address_last;
        n_dram_address_transition_cnt = dram_address_transition_cnt;



        fifo_p2d_data_wr_en = 0;
        fifo_p2d_data_din = 0;
        pipe_in_ready = 0;


        n_dram_write_cnt = dram_write_cnt;
        n_app_rd_data_check = app_rd_data_check;
        n_asic_start_ready = asic_start_ready;
        n_asic_config_ongoing = asic_config_ongoing;

        n_config_stream_cnt = config_stream_cnt;

        n_sample_num = sample_num;
        n_sample_num_transition_cnt = sample_num_transition_cnt;

        
        if(ep40trigin[29]) begin
            if (!fifo_p2d_data_full) begin
                fifo_p2d_command_wr_en = 1;
                fifo_p2d_command_din = {17'd0, 15'd6};
            end
        end
        if (fifo_d2p_command_valid && fifo_d2p_command_dout[14:0] == 6) begin
            fifo_d2p_command_rd_en = 1;
            // n_dram_write_cnt = dram_write_cnt + 1;
            n_dram_write_cnt = fifo_d2p_command_dout[15 +: 17];
        end


        case(p_state)
            P_STATE_00_IDLE: begin
                if(ep40trigin[0]) begin
                    if(ep01wirein == 1) begin
                        n_p_state = P_STATE_01_WORKLOAD_CONFIG;
                    end
                end
            end
            P_STATE_01_WORKLOAD_CONFIG: begin
                if(ep40trigin[0]) begin
                    if(ep01wirein == 2) begin
                        if (config_all_domain_setting_complete) begin
                            n_p_state = P_STATE_02_WORKLOAD_CONFIG_DONE;
                        end
                    end
                end
            end
            P_STATE_02_WORKLOAD_CONFIG_DONE: begin
                if(ep40trigin[0]) begin
                    if(ep01wirein == 3) begin
                        n_p_state = P_STATE_03_DRAMFILL_WEIGHT_DATA;
                    end else if(ep01wirein == 7) begin
                        n_p_state = P_STATE_07_ASIC_CONFIG;
                    end 
                end
            end
            P_STATE_03_DRAMFILL_WEIGHT_DATA: begin
                if (!fifo_p2d_data_full) begin
                    pipe_in_ready = 1;
                    if (pipe_in_valid) begin
                        fifo_p2d_data_wr_en = 1;
                        fifo_p2d_data_din = pipe_in_data;
                    end
                end
                // dram weight write complete
                if (fifo_d2p_command_valid && fifo_d2p_command_dout[14:0] == 5) begin
                    fifo_d2p_command_rd_en = 1;
                    ep60trigout = {31'd0, 1'b1};
                    n_p_state = P_STATE_04_DRAMFILL_WEIGHT_DATA_DONE;
                    n_app_rd_data_check = fifo_d2p_command_dout[15 +: 17];
                end
            end
            P_STATE_04_DRAMFILL_WEIGHT_DATA_DONE: begin
                if(ep40trigin[0]) begin
                    if(ep01wirein == 5) begin
                        n_p_state = P_STATE_05_DRAMFILL_INFERENCE_DATA;
                    end else if (ep01wirein == 6) begin
                        n_p_state = P_STATE_06_DRAMFILL_TRAINING_DATA;
                    end else if (ep01wirein == 7) begin
                        n_p_state = P_STATE_07_ASIC_CONFIG;
                    end else if (ep01wirein == 8) begin
                        n_p_state = P_STATE_08_ASIC_CONFIG_DONE;
                    end 
                end
            end
            P_STATE_05_DRAMFILL_INFERENCE_DATA: begin
                if (!fifo_p2d_data_full) begin
                    pipe_in_ready = 1;
                    if (pipe_in_valid) begin
                        fifo_p2d_data_wr_en = 1;
                        fifo_p2d_data_din = pipe_in_data;
                    end
                end
                // dram INFERENCE_DATA write complete
                if (fifo_d2p_command_valid && fifo_d2p_command_dout[14:0] == 5) begin
                    fifo_d2p_command_rd_en = 1;
                    ep60trigout = {31'd0, 1'b1};
                    n_p_state = P_STATE_04_DRAMFILL_WEIGHT_DATA_DONE;
                    n_app_rd_data_check = fifo_d2p_command_dout[15 +: 17];
                end
            end
            P_STATE_06_DRAMFILL_TRAINING_DATA: begin
                if (!fifo_p2d_data_full) begin
                    pipe_in_ready = 1;
                    if (pipe_in_valid) begin
                        fifo_p2d_data_wr_en = 1;
                        fifo_p2d_data_din = pipe_in_data;
                    end
                end
                // dram TRAINING_DATA write complete
                if (fifo_d2p_command_valid && fifo_d2p_command_dout[14:0] == 5) begin
                    fifo_d2p_command_rd_en = 1;
                    ep60trigout = {31'd0, 1'b1};
                    n_p_state = P_STATE_04_DRAMFILL_WEIGHT_DATA_DONE;
                    n_app_rd_data_check = fifo_d2p_command_dout[15 +: 17];
                end
            end
            P_STATE_07_ASIC_CONFIG: begin
                if(ep40trigin[0]) begin
                    if (!fifo_p2d_data_full) begin
                        fifo_p2d_command_wr_en = 1;
                        fifo_p2d_command_din = {17'd0, 15'd8};
                        n_asic_start_ready = 0;
                        n_config_stream_cnt = 0;
                        n_asic_config_ongoing = 1;
                    end
                end
                if (fifo_d2p_command_valid && fifo_d2p_command_dout[14:0] == 9) begin
                    fifo_d2p_command_rd_en = 1;
                    ep60trigout = {31'd0, 1'b1};
                    n_p_state = P_STATE_08_ASIC_CONFIG_DONE;
                    n_asic_start_ready = fifo_d2p_command_dout[15];
                    n_config_stream_cnt = fifo_d2p_command_dout[31:16];
                    n_asic_config_ongoing = 0;
                end
            end
            P_STATE_08_ASIC_CONFIG_DONE: begin
                if(ep40trigin[0]) begin
                    if (!fifo_p2d_data_full) begin
                        fifo_p2d_command_wr_en = 1;
                        fifo_p2d_command_din = {17'd0, 15'd8};
                        n_asic_start_ready = 0;
                        n_config_stream_cnt = 0;
                        n_asic_config_ongoing = 1;
                    end
                end
                if (fifo_d2p_command_valid && fifo_d2p_command_dout[14:0] == 9) begin
                    fifo_d2p_command_rd_en = 1;
                    ep60trigout = {31'd0, 1'b1};
                    n_p_state = P_STATE_08_ASIC_CONFIG_DONE;
                    n_asic_start_ready = fifo_d2p_command_dout[15];
                    n_config_stream_cnt = fifo_d2p_command_dout[31:16];
                    n_asic_config_ongoing = 0;
                end
            end
            P_STATE_09_ASIC_INFERENCE_QUEUING: begin
            end
            P_STATE_10_ASIC_INFERENCE_PROCESSING: begin
            end
            P_STATE_11_ASIC_TRAINING_QUEUING: begin
            end
            P_STATE_12_ASIC_TRAINING_PROCESSING: begin
            end
        endcase











        if (p_state == P_STATE_00_IDLE) begin
            if (fifo_d2p_command_valid && fifo_d2p_command_dout[14:0] == 3) begin
                if (dram_reset_complete_trg_have_been_sent == 0) begin
                    ep60trigout = {31'd0, 1'b1};
                    n_dram_reset_complete_trg_have_been_sent = 1;
                    fifo_d2p_command_rd_en = 1;
                end
            end
        end else if (p_state == P_STATE_01_WORKLOAD_CONFIG) begin
            if(ep40trigin[1]) begin
                n_p_config_asic_mode = ep01wirein[1:0];
                n_config_all_domain_setting_complete = 0;
            end
            if(ep40trigin[2]) begin
                n_p_config_training_epochs = ep01wirein[15:0];
                n_config_all_domain_setting_complete = 0;
            end
            if(ep40trigin[3]) begin
                n_p_config_inference_epochs = ep01wirein[15:0];
                n_config_all_domain_setting_complete = 0;
            end
            if(ep40trigin[4]) begin
                n_p_config_dataset = ep01wirein[1:0];
                n_config_all_domain_setting_complete = 0;
            end
            if(ep40trigin[5]) begin
                n_p_config_timesteps = ep01wirein[15:0];
                n_config_all_domain_setting_complete = 0;
            end
            if(ep40trigin[6]) begin
                n_p_config_input_size_layer1_define = ep01wirein[15:0];
                n_config_all_domain_setting_complete = 0;
            end
            if(ep40trigin[7]) begin
                n_p_config_long_time_input_streaming_mode = ep01wirein[0];
                n_config_all_domain_setting_complete = 0;
            end
            if(ep40trigin[8]) begin
                n_p_config_binary_classifier_mode = ep01wirein[0];
                n_config_all_domain_setting_complete = 0;
            end
            if(ep40trigin[9]) begin
                n_p_config_loser_encourage_mode = ep01wirein[0];
                n_config_all_domain_setting_complete = 0;
            end
            if(ep40trigin[10]) begin
                n_p_config_layer1_cut_list[17*p_config_cut_cnt +: 17] = ep01wirein[16:0];

                if (p_config_cut_cnt == 14) begin
                    n_p_config_cut_cnt = 0;
                end
                else begin
                    n_p_config_cut_cnt = p_config_cut_cnt+1;
                end
                n_p_config_cut_cnt_past = p_config_cut_cnt;
                n_config_all_domain_setting_complete = 0;
            end
            if(ep40trigin[11]) begin
                n_p_config_layer2_cut_list[16*p_config_cut_cnt +: 16] = ep01wirein[15:0];

                if (p_config_cut_cnt == 14) begin
                    n_p_config_cut_cnt = 0;
                end
                else begin
                    n_p_config_cut_cnt = p_config_cut_cnt+1;
                end
                n_p_config_cut_cnt_past = p_config_cut_cnt;
                n_config_all_domain_setting_complete = 0;
            end
            if(ep40trigin[31]) begin
                n_config_all_domain_setting_ongoing = 1;
                n_config_all_domain_setting_complete = 0;
            end
        end









        // dram address setting
        if(dram_address_transition_cnt == 0) begin
            if(ep40trigin[30]) begin
                n_dram_address = ep01wirein;
                n_dram_address_transition_cnt = dram_address_transition_cnt + 1;
            end
        end else if (dram_address_transition_cnt == 1) begin
            if(ep40trigin[30]) begin
                n_dram_address_last = ep01wirein;
                n_dram_address_transition_cnt = dram_address_transition_cnt + 1;
            end
        end else if (dram_address_transition_cnt == 2) begin
            if(!fifo_p2d_command_full) begin
                n_dram_address_transition_cnt = dram_address_transition_cnt + 1;
                fifo_p2d_command_wr_en = 1;
                fifo_p2d_command_din = {1'b0, dram_address[0 +: 16], 15'd4};
            end
        end else if (dram_address_transition_cnt == 3) begin
            if(!fifo_p2d_command_full) begin
                n_dram_address_transition_cnt = dram_address_transition_cnt + 1;
                fifo_p2d_command_wr_en = 1;
                fifo_p2d_command_din = {1'b0, dram_address[16 +: 16], 15'd4};
            end
        end else if (dram_address_transition_cnt == 4) begin
            if(!fifo_p2d_command_full) begin
                n_dram_address_transition_cnt = dram_address_transition_cnt + 1;
                fifo_p2d_command_wr_en = 1;
                fifo_p2d_command_din = {1'b0, dram_address_last[0 +: 16], 15'd4};
            end
        end else if (dram_address_transition_cnt == 5) begin
            if(!fifo_p2d_command_full) begin
                n_dram_address_transition_cnt = dram_address_transition_cnt + 1;
                fifo_p2d_command_wr_en = 1;
                fifo_p2d_command_din = {1'b0, dram_address_last[16 +: 16], 15'd4};
            end
        end else if (dram_address_transition_cnt == 6) begin
            if(fifo_d2p_command_valid && fifo_d2p_command_dout[14:0] == 4) begin
                fifo_d2p_command_rd_en = 1;
                n_dram_address_transition_cnt = 0;
                ep60trigout = {31'd0, 1'b1};
            end
        end




        // sample num setting
        if(sample_num_transition_cnt == 0) begin
            if(ep40trigin[26]) begin
                n_sample_num = ep01wirein;
                n_sample_num_transition_cnt = sample_num_transition_cnt + 1;
            end
        end else if (sample_num_transition_cnt == 1) begin
            if(!fifo_p2d_command_full) begin
                n_sample_num_transition_cnt = sample_num_transition_cnt + 1;
                fifo_p2d_command_wr_en = 1;
                fifo_p2d_command_din = {1'b0, sample_num[0 +: 16], 15'd11};
            end
        end else if (sample_num_transition_cnt == 2) begin
            if(!fifo_p2d_command_full) begin
                n_sample_num_transition_cnt = sample_num_transition_cnt + 1;
                fifo_p2d_command_wr_en = 1;
                fifo_p2d_command_din = {1'b0, sample_num[16 +: 16], 15'd11};
            end
        end else if (sample_num_transition_cnt == 3) begin
            if(fifo_d2p_command_valid && fifo_d2p_command_dout[14:0] == 11) begin
                fifo_d2p_command_rd_en = 1;
                n_sample_num_transition_cnt = 0;
                ep60trigout = {31'd0, 1'b1};
            end
        end








        // Check ASIC start ready == 1
        if(ep40trigin[28]) begin
            if (!fifo_p2d_command_full) begin
                fifo_p2d_command_wr_en = 1;
                fifo_p2d_command_din = {17'd0, 15'd7};
                n_asic_start_ready = 0;
            end
        end
        if (fifo_d2p_command_valid && fifo_d2p_command_dout[14:0] == 7) begin
            fifo_d2p_command_rd_en = 1;
            n_asic_start_ready = fifo_d2p_command_dout[15];
        end


        // STEAMING N번 WAIT
        if(ep40trigin[27]) begin
            if (!fifo_p2d_command_full) begin
                fifo_p2d_command_wr_en = 1;
                fifo_p2d_command_din = {ep01wirein[16:0], 15'd10};
            end
        end
        if (fifo_d2p_command_valid && fifo_d2p_command_dout[14:0] == 10) begin
            fifo_d2p_command_rd_en = 1;
            ep60trigout = {31'd0, 1'b1};
        end
















































































        if (config_all_domain_setting_ongoing) begin
            if (config_all_domain_setting_cnt == 0) begin
                config_value = {15'd0, p_config_asic_mode};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 1) begin
                config_value = {1'd0, p_config_training_epochs};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 2) begin
                config_value = {1'd0, p_config_inference_epochs};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 3) begin
                config_value = {15'd0, p_config_dataset};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 4) begin
                config_value = {1'd0, p_config_timesteps};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 5) begin
                config_value = {1'd0, p_config_input_size_layer1_define};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 6) begin
                config_value = {16'd0, p_config_long_time_input_streaming_mode};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 7) begin
                config_value = {16'd0, p_config_binary_classifier_mode};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 8) begin
                config_value = {16'd0, p_config_loser_encourage_mode};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 9) begin
                config_value = {p_config_layer1_cut_list[17*0 +: 17]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 10) begin
                config_value = {p_config_layer1_cut_list[17*1 +: 17]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 11) begin
                config_value = {p_config_layer1_cut_list[17*2 +: 17]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 12) begin
                config_value = {p_config_layer1_cut_list[17*3 +: 17]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 13) begin
                config_value = {p_config_layer1_cut_list[17*4 +: 17]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 14) begin
                config_value = {p_config_layer1_cut_list[17*5 +: 17]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 15) begin
                config_value = {p_config_layer1_cut_list[17*6 +: 17]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 16) begin
                config_value = {p_config_layer1_cut_list[17*7 +: 17]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 17) begin
                config_value = {p_config_layer1_cut_list[17*8 +: 17]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 18) begin
                config_value = {p_config_layer1_cut_list[17*9 +: 17]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 19) begin
                config_value = {p_config_layer1_cut_list[17*10 +: 17]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 20) begin
                config_value = {p_config_layer1_cut_list[17*11 +: 17]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 21) begin
                config_value = {p_config_layer1_cut_list[17*12 +: 17]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 22) begin
                config_value = {p_config_layer1_cut_list[17*13 +: 17]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 23) begin
                config_value = {p_config_layer1_cut_list[17*14 +: 17]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 24) begin
                config_value = {1'd0, p_config_layer2_cut_list[16*0 +: 16]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 25) begin
                config_value = {1'd0, p_config_layer2_cut_list[16*1 +: 16]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 26) begin
                config_value = {1'd0, p_config_layer2_cut_list[16*2 +: 16]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 27) begin
                config_value = {1'd0, p_config_layer2_cut_list[16*3 +: 16]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 28) begin
                config_value = {1'd0, p_config_layer2_cut_list[16*4 +: 16]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 29) begin
                config_value = {1'd0, p_config_layer2_cut_list[16*5 +: 16]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 30) begin
                config_value = {1'd0, p_config_layer2_cut_list[16*6 +: 16]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 31) begin
                config_value = {1'd0, p_config_layer2_cut_list[16*7 +: 16]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 32) begin
                config_value = {1'd0, p_config_layer2_cut_list[16*8 +: 16]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 33) begin
                config_value = {1'd0, p_config_layer2_cut_list[16*9 +: 16]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 34) begin
                config_value = {1'd0, p_config_layer2_cut_list[16*10 +: 16]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 35) begin
                config_value = {1'd0, p_config_layer2_cut_list[16*11 +: 16]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 36) begin
                config_value = {1'd0, p_config_layer2_cut_list[16*12 +: 16]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 37) begin
                config_value = {1'd0, p_config_layer2_cut_list[16*13 +: 16]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 38) begin
                config_value = {1'd0, p_config_layer2_cut_list[16*14 +: 16]};
                if (!fifo_p2d_command_full) begin
                    n_config_all_domain_setting_cnt = config_all_domain_setting_cnt + 1;
                    fifo_p2d_command_wr_en = 1;
                    fifo_p2d_command_din = {config_value, {14{1'b0}}, 1'b1};
                end
            end else if (config_all_domain_setting_cnt == 39) begin
                if (fifo_d2p_command_valid) begin
                    if (fifo_d2p_command_dout[14:0] == 2) begin
                        fifo_d2p_command_rd_en = 1;
                        n_config_all_domain_setting_cnt = 0;
                        n_config_all_domain_setting_ongoing = 0;
                        n_config_all_domain_setting_complete = 1;
                        ep60trigout = {31'd0, 1'b1};
                    end
                end
            end
        end


        
    end
    // ########################## P (okClk 100.8MHz) DOMAIN CONTROL ########################################################################################












    // ########################## LED BLINK ########################################################################################
    always @(posedge okClk) begin
        if (!reset_n) begin
            led_pos <= 3'd0;
            led_dir <= 1'b0;
        end
        else if (blink_100ms & !blink_100ms_past) begin
            if (!led_dir) begin
                // left -> right
                if (led_pos == 3'd7) begin
                    led_dir <= 1'b1;
                    led_pos <= 3'd6;
                end
                else begin
                    led_pos <= led_pos + 1'b1;
                end
            end
            else begin
                // right -> left
                if (led_pos == 3'd0) begin
                    led_dir <= 1'b0;
                    led_pos <= 3'd1;
                end
                else begin
                    led_pos <= led_pos - 1'b1;
                end
            end
        end
    end
    always @(posedge okClk) begin // 9.92ns 100.806MHz
        if (!reset_n) begin
            blink_1000ms     <= 1'b0;
            blink_1000ms_past     <= 1'b0;
            blink_1000ms_cnt <= 26'd0;
        end
        else begin
            if (blink_1000ms_cnt == 26'd50505050 - 1) begin
                blink_1000ms_cnt <= 26'd0;
                blink_1000ms     <= ~blink_1000ms;   // 0.5초마다 토글
            end
            else begin
                blink_1000ms_cnt <= blink_1000ms_cnt + 1'b1;
            end
            blink_1000ms_past <= blink_1000ms;
        end
    end
    always @(posedge okClk) begin
        if (!reset_n) begin
            blink_500ms     <= 1'b0;
            blink_500ms_past     <= 1'b0;
            blink_500ms_cnt <= 26'd0;
        end
        else begin
            if (blink_500ms_cnt == 26'd25252525 - 1) begin
                blink_500ms_cnt <= 26'd0;
                blink_500ms     <= ~blink_500ms;   // 0.05초마다 토글
            end
            else begin
                blink_500ms_cnt <= blink_500ms_cnt + 1'b1;
            end
            blink_500ms_past <= blink_500ms;
        end
    end
    always @(posedge okClk) begin
        if (!reset_n) begin
            blink_100ms     <= 1'b0;
            blink_100ms_past     <= 1'b0;
            blink_100ms_cnt <= 26'd0;
        end
        else begin
            if (blink_100ms_cnt == 26'd5050505 - 1) begin
                blink_100ms_cnt <= 26'd0;
                blink_100ms     <= ~blink_100ms;   // 0.05초마다 토글
            end
            else begin
                blink_100ms_cnt <= blink_100ms_cnt + 1'b1;
            end
            blink_100ms_past <= blink_100ms;
        end
    end
    // ########################## LED BLINK ########################################################################################



endmodule