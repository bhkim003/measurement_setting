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
        input   wire        sys_clkp,
        input   wire        sys_clkn,
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
        // inout  wire [31:0]  ddr3_dq,
        // output wire [14:0]  ddr3_addr,
        // output wire [2 :0]  ddr3_ba,
        // output wire [0 :0]  ddr3_ck_p,
        // output wire [0 :0]  ddr3_ck_n,
        // output wire [0 :0]  ddr3_cke,
        // // output wire [0 :0]  ddr3_cs_n,
        // output wire         ddr3_cas_n,
        // output wire         ddr3_ras_n,
        // output wire         ddr3_we_n,
        // output wire [0 :0]  ddr3_odt,
        // output wire [3 :0]  ddr3_dm,
        // inout  wire [3 :0]  ddr3_dqs_p,
        // inout  wire [3 :0]  ddr3_dqs_n,
        // output wire         ddr3_reset_n,
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

    reg [32 - 1:0] ep20wireout;
    okWireOut WireOut20(.okHE(okHE), .okEH(okEHx[0]), .ep_addr(8'h20), .ep_datain(ep20wireout));

    wire [32 - 1:0] ep21wireout;
    okWireOut WireOut21(.okHE(okHE), .okEH(okEHx[1]), .ep_addr(8'h21), .ep_datain(ep21wireout));

    wire [32 - 1:0] ep40trigin;
    okTriggerIn TrigIn40 (.okHE(okHE), .ep_addr(8'h40), .ep_clk(okClk), .ep_trigger(ep40trigin));
    
    wire [32 - 1:0] ep60trigout;
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


    // ########################## sys_clk gen instance ########################################################################################
    wire sys_clk;
    IBUFGDS osc_clk(.O(sys_clk), .I(sys_clkp), .IB(sys_clkn));
    // ########################## sys_clk gen instance ########################################################################################


    // ########################## P (okClk 100.8MHz) DOMAIN FSM STATE ########################################################################################
    localparam P_STATE_00_IDLE = 0;
    localparam P_STATE_01_WORKLOAD_CONFIG = 1;
    localparam P_STATE_02_WORKLOAD_CONFIG_DONE = 2;
    localparam P_STATE_03_DRAMFILL_WEIGHT_DATA = 3;
    localparam P_STATE_04_DRAMFILL_WEIGHT_DATA_DONE = 4;
    localparam P_STATE_05_DRAMFILL_INFERENCE_DATA = 5;
    localparam P_STATE_06_DRAMFILL_TRAINING_DATA = 6;
    localparam P_STATE_07_ASIC_CONFIG = 7;
    localparam P_STATE_08_ASIC_CONFIG_DONE = 8;
    localparam P_STATE_09_ASIC_INFERENCE_PROCESSING = 9;
    localparam P_STATE_10_ASIC_TRAINING_PROCESSING = 10;

    reg [7:0] p_state, n_p_state;


    // assign ep20wireout = ep01wirein;
    assign ep21wireout = p_state;
    always @(posedge okClk) begin
        if(!reset_n) begin
            p_state <= 0;
        end
        else begin
            p_state <= n_p_state;
        end
    end

    always @ (*) begin
        n_p_state = p_state;
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
                        n_p_state = P_STATE_02_WORKLOAD_CONFIG_DONE;
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
            end
            P_STATE_04_DRAMFILL_WEIGHT_DATA_DONE: begin
            end
            P_STATE_05_DRAMFILL_INFERENCE_DATA: begin
            end
            P_STATE_06_DRAMFILL_TRAINING_DATA: begin
            end
            P_STATE_07_ASIC_CONFIG: begin
            end
            P_STATE_08_ASIC_CONFIG_DONE: begin
            end
            P_STATE_09_ASIC_INFERENCE_PROCESSING: begin
            end
            P_STATE_10_ASIC_TRAINING_PROCESSING: begin
            end
        endcase
    end
    // ########################## P (okClk 100.8MHz) DOMAIN FSM STATE ########################################################################################



    // ########################## P (okClk 100.8MHz) DOMAIN CONFIG ########################################################################################
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
    reg [25:0] blink_1000ms_cnt;   // 26비트로 변경
    always @(posedge okClk) begin
        if (!reset_n) begin
            blink_1000ms     <= 1'b0;
            blink_1000ms_past     <= 1'b0;
            blink_1000ms_cnt <= 26'd0;
        end
        else begin
            if (blink_1000ms_cnt == 26'd50400000 - 1) begin
                blink_1000ms_cnt <= 26'd0;
                blink_1000ms     <= ~blink_1000ms;   // 0.5초마다 토글
            end
            else begin
                blink_1000ms_cnt <= blink_1000ms_cnt + 1'b1;
            end
            blink_1000ms_past <= blink_1000ms;
        end
    end
    reg blink_500ms, blink_500ms_past;
    reg [25:0] blink_500ms_cnt;   // 26비트로 변경
    always @(posedge okClk) begin
        if (!reset_n) begin
            blink_500ms     <= 1'b0;
            blink_500ms_past     <= 1'b0;
            blink_500ms_cnt <= 26'd0;
        end
        else begin
            if (blink_500ms_cnt == 26'd25200000 - 1) begin
                blink_500ms_cnt <= 26'd0;
                blink_500ms     <= ~blink_500ms;   // 0.05초마다 토글
            end
            else begin
                blink_500ms_cnt <= blink_500ms_cnt + 1'b1;
            end
            blink_500ms_past <= blink_500ms;
        end
    end
    reg blink_100ms, blink_100ms_past;
    reg [25:0] blink_100ms_cnt;   // 26비트로 변경
    always @(posedge okClk) begin
        if (!reset_n) begin
            blink_100ms     <= 1'b0;
            blink_100ms_past     <= 1'b0;
            blink_100ms_cnt <= 26'd0;
        end
        else begin
            if (blink_100ms_cnt == 26'd5040000 - 1) begin
                blink_100ms_cnt <= 26'd0;
                blink_100ms     <= ~blink_100ms;   // 0.05초마다 토글
            end
            else begin
                blink_100ms_cnt <= blink_100ms_cnt + 1'b1;
            end
            blink_100ms_past <= blink_100ms;
        end
    end
    
    reg [2:0] led_pos;   // 0~7
    reg       led_dir;   // 0: left->right, 1: right->left

    always @ (*) begin
        ep20wireout = 0;
        led = xem7310_led(p_state & {8{blink_1000ms}});
        if (p_state == P_STATE_00_IDLE) begin
            led = xem7310_led({8{blink_1000ms}});
        end else if (p_state == P_STATE_01_WORKLOAD_CONFIG || p_state == P_STATE_02_WORKLOAD_CONFIG_DONE) begin
            if (ep01wirein != 0) begin
                if (ep01wirein == 1) begin
                    led = xem7310_led({6'd0, p_config_asic_mode});
                    ep20wireout = p_config_asic_mode;
                end else if (ep01wirein == 2) begin
                    led = xem7310_led(p_config_training_epochs[7:0]);
                    ep20wireout = p_config_training_epochs;
                end else if (ep01wirein == 3) begin
                    led = xem7310_led(p_config_inference_epochs[7:0]);
                    ep20wireout = p_config_inference_epochs;
                end else if (ep01wirein == 4) begin
                    led = xem7310_led({6'd0, p_config_dataset});
                    ep20wireout = p_config_dataset;
                end else if (ep01wirein == 5) begin
                    led = xem7310_led(p_config_timesteps[7:0]);
                    ep20wireout = p_config_timesteps;
                end else if (ep01wirein == 6) begin
                    led = xem7310_led(p_config_input_size_layer1_define[7:0]);
                    ep20wireout = p_config_input_size_layer1_define;
                end else if (ep01wirein == 7) begin
                    led = xem7310_led({7'd0, p_config_long_time_input_streaming_mode});
                    ep20wireout = p_config_long_time_input_streaming_mode;
                end else if (ep01wirein == 8) begin
                    led = xem7310_led({7'd0, p_config_binary_classifier_mode});
                    ep20wireout = p_config_binary_classifier_mode;
                end else if (ep01wirein == 9) begin
                    led = xem7310_led({7'd0, p_config_loser_encourage_mode});
                    ep20wireout = p_config_loser_encourage_mode;
                end else if (ep01wirein == 10) begin
                    led = xem7310_led(p_config_layer1_cut_list[17*p_config_cut_cnt_past +: 8]);
                    ep20wireout = {{15{p_config_layer1_cut_list[17*p_config_cut_cnt_past + 16]}},p_config_layer1_cut_list[17*p_config_cut_cnt_past +: 17]};
                end else if (ep01wirein == 11) begin
                    led = xem7310_led(p_config_layer2_cut_list[16*p_config_cut_cnt_past +: 8]);
                    ep20wireout = {{16{p_config_layer2_cut_list[16*p_config_cut_cnt_past + 15]}},p_config_layer2_cut_list[16*p_config_cut_cnt_past +: 16]};
                end else begin
                    led = xem7310_led(255 & {blink_1000ms, blink_1000ms, blink_1000ms, blink_1000ms, !blink_1000ms, !blink_1000ms, !blink_1000ms, !blink_1000ms});
                    ep20wireout = led;
                end
            end
        end

        if (!reset_n) begin
            led = xem7310_led(255);
        end
    end

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

    always @(posedge okClk) begin
        if(!reset_n) begin
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
        end
        else begin
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
        end
    end
    
    always @ (*) begin
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

        if (p_state == P_STATE_01_WORKLOAD_CONFIG) begin
            if(ep40trigin[1]) begin
                n_p_config_asic_mode = ep01wirein[1:0];
            end
            if(ep40trigin[2]) begin
                n_p_config_training_epochs = ep01wirein[15:0];
            end
            if(ep40trigin[3]) begin
                n_p_config_inference_epochs = ep01wirein[15:0];
            end
            if(ep40trigin[4]) begin
                n_p_config_dataset = ep01wirein[1:0];
            end
            if(ep40trigin[5]) begin
                n_p_config_timesteps = ep01wirein[15:0];
            end
            if(ep40trigin[6]) begin
                n_p_config_input_size_layer1_define = ep01wirein[15:0];
            end
            if(ep40trigin[7]) begin
                n_p_config_long_time_input_streaming_mode = ep01wirein[0];
            end
            if(ep40trigin[8]) begin
                n_p_config_binary_classifier_mode = ep01wirein[0];
            end
            if(ep40trigin[9]) begin
                n_p_config_loser_encourage_mode = ep01wirein[0];
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
            end
        end
    end
    // ########################## P (okClk 100.8MHz) DOMAIN CONFIG ########################################################################################



    // // ########################## P TO F DOMAIN CROSSING FIFO ########################################################################################
    // wire p2f_fifo_wr_en;
    // wire [32 - 1:0] p2f_fifo_din;
    // reg p2f_fifo_rd_en;
    // wire [128 - 1:0] p2f_fifo_dout;
    // wire p2f_fifo_empty;
    // wire p2f_fifo_dout_valid;
    // assign p2f_fifo_wr_en = pipe_in_valid;
    // assign p2f_fifo_din = pipe_in_data;
    // always @(posedge sys_clk) begin
    //     if(!reset_n) begin
    //         p2f_fifo_rd_en <= 1'b0;
    //     end
    //     else begin
    //         if(!p2f_fifo_empty) begin
    //             p2f_fifo_rd_en <= 1'b1;
    //         end
    //         else begin
    //             p2f_fifo_rd_en <= 1'b0;
    //         end
    //     end
    // end
    // fifo_w32_1024_r128_256 P2F_FIFO(
    //     .rst(!reset_n),
    //     // write
    //     .wr_clk(okClk),
    //     .wr_en(p2f_fifo_wr_en),
    //     .din(p2f_fifo_din),
    //     .full(),
    //     // read
    //     .rd_clk(sys_clk),
    //     .rd_en(p2f_fifo_rd_en),
    //     .dout(p2f_fifo_dout),
    //     .empty(),
    //     .valid(p2f_fifo_dout_valid)
    // );
    // // ########################## P TO F DOMAIN CROSSING FIFO ########################################################################################

    // // ########################## F TO P DOMAIN CROSSING FIFO ########################################################################################
    // reg f2p_fifo_wr_en;
    // reg [128 - 1:0] f2p_fifo_din;
    // wire f2p_fifo_rd_en;
    // wire [32 - 1:0] f2p_fifo_dout;
    // assign f2p_fifo_rd_en = pipe_out_read;
    // assign pipe_out_data = f2p_fifo_dout;
    // always @(posedge sys_clk) begin
    //     if(!reset_n) begin
    //         f2p_fifo_wr_en <= 1'b0;
    //         f2p_fifo_din <= 128'b0;
    //     end
    //     else begin
    //         if(p2f_fifo_dout_valid) begin
    //             f2p_fifo_wr_en <= 1'b1;
    //             f2p_fifo_din <= p2f_fifo_dout;
    //         end
    //         else begin
    //             f2p_fifo_wr_en <= 1'b0;
    //             f2p_fifo_din <= 128'b0;
    //         end
    //     end
    // end
    // fifo_w128_256_r32_1024 F2P_FIFO(
    //     .rst(!reset_n),
    //     // write
    //     .wr_clk(sys_clk),
    //     .wr_en(f2p_fifo_wr_en),
    //     .din(f2p_fifo_din),
    //     .full(),
    //     // read
    //     .rd_clk(okClk),
    //     .rd_en(f2p_fifo_rd_en),
    //     .dout(f2p_fifo_dout),
    //     .empty(),
    //     .valid()
    // );
    // // ########################## F TO P DOMAIN CROSSING FIFO ########################################################################################



endmodule