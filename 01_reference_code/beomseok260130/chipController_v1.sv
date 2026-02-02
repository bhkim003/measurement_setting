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

    output reg          done_network,     // --> okFP
    input  wire         done_layer,       // <-- chip
    output reg  [30:0]  clk_cnt           // --> okFP
);

    `include "params.vh"

    localparam S_IDLE            = 2'd0;
    localparam S_RUN             = 2'd1;
    localparam S_PREP_NEXT_LAYER = 2'd2;

    reg [1:0] state;
    reg [5:0] layer_cnt;


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
                    if      (done_layer && (layer_cnt == n_layers - 1)) state <= S_IDLE;
                    else if (done_layer)                                state <= S_PREP_NEXT_LAYER;
                    else                                                state <= S_RUN;
                end
                S_PREP_NEXT_LAYER: begin
                    `ifdef LOOPBACK_TEST
                    if (start_layer || start_store_byte4) state <= S_RUN;
                    `else
                    if (start_layer) state <= S_RUN;
                    else             state <= S_PREP_NEXT_LAYER;
                    `endif
                end
                default: begin
                end
            endcase
        end
    end


    // start_layer signal is synchronous to clk_for_chip_in
    always @(posedge clk_for_chip_in or negedge rstn) begin
        if (~rstn) begin
            start_layer  <= 1'b0;
            start_store_byte4 <= 1'b0;
        end
        else begin
            case (state)
                S_IDLE: begin
                    if (start_network) start_layer <= 1'b1;
                    else               start_layer <= 1'b0;

                    start_store_byte4 <= 1'b0;
                end
                S_RUN: begin
                    start_layer <= 1'b0;
                    start_store_byte4 <= 1'b0;
                end
                S_PREP_NEXT_LAYER: begin
                    /* TODO */
                    // Implement octreeManager to regroup/align groups in the octree

                    `ifdef LOOPBACK_TEST
                    if ((n_layers != 1) && (layer_cnt == n_layers - 1)) start_store_byte4 <= 1'b1;
                    else start_layer <= 1'b1;
                    `else
                    if (start_layer) start_layer <= 1'b0;
                    else start_layer <= 1'b1;
                    `endif
                end
            endcase
        end
    end
    
    always @(posedge chip_clk or negedge rstn) begin
        if (~rstn) begin
            done_network <= 1'b0;
            clk_cnt      <= 'd0;
            layer_cnt    <= 'd0;
        end
        else begin
            case (state)
                S_IDLE: begin
                    done_network <= 1'b0;
                    clk_cnt      <= 'd0;
                    layer_cnt    <= 'd0;
                end
                S_RUN: begin
                    clk_cnt     <= clk_cnt + 'd1;
                    if (done_layer) begin
                        if (layer_cnt == n_layers - 1) begin
                            done_network <= 1'b1;
                            layer_cnt    <= 'd0;
                        end
                        else begin
                            layer_cnt <= layer_cnt + 'd1;
                        end
                    end
                end
                S_PREP_NEXT_LAYER: begin
                end
                default: begin
                end
            endcase
        end
    end



endmodule