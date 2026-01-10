//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kim Beomseok
// Contact: kimbss470@snu.ac.kr
// 
// Create Date: 19/07/2024 
// Design Name: OpalKelly frontpanel for USB3 in Verilog
// Module Name: chipController
// Project Name: 2024TapeOut
// Target Devices: XEM7360-K160T
// Tool versions: 2024.1
// Description: Control start&done signals and count clk cycle
//
//////////////////////////////////////////////////////////////////////////////////
module chipController (
    input  wire         chip_clk,
    input  wire         clk_for_chip_in,
    input  wire         rstn,

    input  wire         start_network,    // <-- okFP

    output reg          start_layer,      // --> chip
    output reg          start_store_byte4,// --> chip, only used for loopback test
    
    input  wire [ 5:0]  n_layers,         // <-- okFP, # of layers of the network
    input  wire         infinite_loop,    // <-- okFP, infinite loop mode for power measure
    input  wire [15:0]  wait_chip_cnt,    // <-- okFP, wait for chip ready for multi cycles

    output reg          done_network,     // --> okFP
    output reg  [31:0]  done_network_cnt, // --> okFP, # of done_network
    input  wire         done_layer,       // <-- chip
    output reg  [30:0]  clk_cnt           // --> okFP
);

    `include "params.vh"

    localparam S_IDLE            = 2'd0;
    localparam S_RUN             = 2'd1;
    localparam S_PREP_NEXT_LAYER = 2'd2;
    localparam S_READY_TO_E2E    = 2'd3;
  
    reg [ 5:0] n_layers_buf;
    reg        infinite_loop_buf;
    reg [15:0] wait_chip_cnt_buf;

    reg [1:0]  state;
    reg [5:0]  layer_cnt;
    reg [15:0] wait_for_chip_ready;   // for infinit loop mode, wait for chip ready for 'wait_chip_cnt' cycles


    always @(posedge chip_clk or negedge rstn) begin
        if (~rstn) begin
            state <= S_IDLE;
        end
        else begin
            case (state)
                S_IDLE: begin
                    if (start_network) state <= S_RUN;
                    else               state <= S_IDLE;
                end
                S_RUN: begin
                    if      ((!infinite_loop_buf) && done_layer && (layer_cnt == n_layers_buf - 1)) state <= S_IDLE;
                    else if (( infinite_loop_buf) && done_layer && (layer_cnt == n_layers_buf - 1)) state <= S_READY_TO_E2E;
                    else if (done_layer)                                                            state <= S_PREP_NEXT_LAYER;
                    else                                                                            state <= S_RUN;
                end
                S_PREP_NEXT_LAYER: begin
                    `ifdef LOOPBACK_TEST
                    if (start_layer || start_store_byte4) state <= S_RUN;
                    `else
                    if (start_layer) state <= S_RUN;
                    else             state <= S_PREP_NEXT_LAYER;
                    `endif
                end
                S_READY_TO_E2E: begin
                    if (wait_for_chip_ready==wait_chip_cnt_buf) state <= S_RUN;
                    else                                        state <= S_READY_TO_E2E;
                end
            endcase
        end
    end


    
    always @(posedge chip_clk or negedge rstn) begin
        if (~rstn) begin
            start_layer         <= 1'b0;
            start_store_byte4   <= 1'b0;  // only used for loopback test

            n_layers_buf        <= 'd0;
            infinite_loop_buf   <= 1'b0;
            wait_chip_cnt_buf   <= 'd0;

            done_network        <= 1'b0;
            done_network_cnt    <= 'd0;
            clk_cnt             <= 'd0;
            layer_cnt           <= 'd0;
            wait_for_chip_ready <= 'd0;
        end
        else begin
            case (state)
                S_IDLE: begin
                    if (start_network) begin
                        start_layer         <= 1'b1;
                        n_layers_buf        <= n_layers;
                        infinite_loop_buf   <= infinite_loop;
                        wait_chip_cnt_buf   <= wait_chip_cnt;
                    end
                    else begin 
                        start_layer         <= 1'b0;
                        n_layers_buf        <= 'd0;
                        infinite_loop_buf   <= 1'b0;
                        wait_chip_cnt_buf   <= 'd0;
                    end            

                    start_store_byte4   <= 1'b0;  // only used for loopback test
                    done_network        <= 1'b0;
                    done_network_cnt    <= 'd0;
                    clk_cnt             <= 'd0;
                    layer_cnt           <= 'd0;
                    wait_for_chip_ready <= 'd0;
                end
                S_RUN: begin
                    start_layer       <= 1'b0;
                    start_store_byte4 <= 1'b0;
                    clk_cnt           <= clk_cnt + 'd1;

                    if (done_layer) begin
                        if (layer_cnt == n_layers_buf - 1) begin
                            if (!infinite_loop_buf) done_network <= 1'b1;
                            layer_cnt <= 'd0;
                            done_network_cnt <= done_network_cnt + 'd1;
                        end
                        else begin
                            done_network <= 1'b0;
                            layer_cnt <= layer_cnt + 'd1;
                        end
                    end
                end
                S_PREP_NEXT_LAYER: begin
                    /* TODO */
                    // Implement octreeManager to regroup/align groups in the octree

                    `ifdef LOOPBACK_TEST
                    if ((n_layers_buf != 1) && (layer_cnt == n_layers_buf - 1)) start_store_byte4 <= 1'b1;
                    else start_layer <= 1'b1;
                    `else
                    if (start_layer) start_layer <= 1'b0;
                    else start_layer <= 1'b1;
                    `endif

                    done_network <= 1'b0;
                end
                S_READY_TO_E2E: begin
                    done_network <= 1'b0;

                    if (wait_for_chip_ready == wait_chip_cnt_buf) begin
                        start_layer         <= 1'b1;
                        wait_for_chip_ready <= 'd0;
                    end
                    else begin
                        start_layer         <= 1'b0;
                        wait_for_chip_ready <= wait_for_chip_ready + 'd1;
                    end
                end
            endcase
        end
    end



endmodule