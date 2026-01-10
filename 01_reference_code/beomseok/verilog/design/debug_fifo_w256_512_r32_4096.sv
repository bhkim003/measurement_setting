//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kim Beomseok
// Contact: kimbss470@snu.ac.kr
// 
// Create Date: 22/12/2024 
// Design Name: OpalKelly frontpanel for USB3 in Verilog
// Module Name: fifo_w256_512_r32_4096 
// Project Name: 2024TapeOut
// Target Devices: XEM7360-K160T
// Tool versions: 2024.1
// Description: - Emulate 256-bit write / 32-bit read FIFO with 256-bit write/read FIFO
//////////////////////////////////////////////////////////////////////////////////


module debug_fifo_w256_512_r32_4096(
    input          rstn,
    input          wr_clk,
    input          rd_clk,
    input  [255:0] din,
    input          wr_en,
    input          rd_en,
    output [ 31:0] dout,
    output         full,
    output         empty,
    output         valid,
    output         prog_full
);

    wire         w_rst;
    wire [255:0] w_din;
    wire         w_wr_en;
    wire         w_rd_en;
    wire [255:0] w_dout;
    wire         w_full;
    wire         w_empty;
    wire         w_valid;
    wire         w_prog_full;

    reg  [  2:0] r_cnt;
    reg  [255:0] dout_buf;

    assign w_rst     = ~rstn;    // active-high
    assign w_din     = din;
    assign w_wr_en   = wr_en;
    assign w_rd_en   = rd_en && (r_cnt == 3'd0);
    assign full      = w_full;
    assign empty     = w_empty && (r_cnt == 3'd0);
    assign valid     = w_valid || (r_cnt != 3'd0);
    assign prog_full = w_prog_full;
    assign dout      = (r_cnt == 3'd0) ? w_dout[255 -:32] : dout_buf[255 - r_cnt*32 -: 32];


    // Split 256-bit dout into 32-bit data
    always @(posedge rd_clk or negedge rstn) begin
        if (~rstn) begin
            r_cnt    <= 3'd0;
            dout_buf <= 256'd0;
        end
        else if (rd_en) begin
            if (r_cnt == 3'd7) r_cnt <= 3'd0;
            else               r_cnt <= r_cnt + 3'd1;

            if (r_cnt == 3'd0) dout_buf <= w_dout;
        end
    end

    builtin_fifo_256_512 u_fifo (
        .rst                (w_rst      ),    // active-high
        .wr_clk             (wr_clk     ),
        .rd_clk             (rd_clk     ),
        .din                (w_din      ),
        .wr_en              (w_wr_en    ),
        .rd_en              (w_rd_en    ),
        .dout               (w_dout     ),
        .full               (w_full     ),
        .empty              (w_empty    ),
        .valid              (w_valid    ),
        .prog_full          (w_prog_full)
    );

endmodule
