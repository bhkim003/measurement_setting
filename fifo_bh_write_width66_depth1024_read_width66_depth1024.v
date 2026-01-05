

module fifo_bh_write_width66_depth1024_read_width66_depth1024 (
        input rst,
        // write
        input wr_clk,
        input wr_en,
        input [66 - 1:0] din,
        output full,
        // read
        input rd_clk,
        input rd_en,
        output [66 - 1:0] dout,
        output empty,

        output valid
    );

    wire vivado_fifo_empty;

    // read_side fifo
    wire read_side_wren;
    wire [66-1:0] read_side_wdata;
    wire read_side_almost_full;

    fifo_write_width66_depth1024_read_width66_depth1024 u_fifo_write_width66_depth1024_read_width66_depth1024(
        .rst(rst),
        // write
        .wr_clk(wr_clk),
        .wr_en(wr_en),
        .din(din),
        .full(full),
        // read
        .rd_clk(rd_clk),
        .rd_en(read_side_almost_full == 0),
        .dout(read_side_wdata),
        .empty(vivado_fifo_empty),

        .valid(read_side_wren)
    );

    fifo_bh_almost_full_two_power#(
        .FIFO_DATA_WIDTH ( 66 ),
        .FIFO_DEPTH      ( 4 ),
        .FIFO_DEPTH_LG2  ( 2 ),
        .FIFO_MINIMUM_SPACE_TO_READ_REQUEST ( 2 )
    )u_fifo_bh_almost_full_two_power(
        .clk             ( rd_clk             ),
        .reset_n         ( !rst            ),
        .wren_i          ( read_side_wren          ),
        .rden_i          ( rd_en          ),
        .wdata_i         ( read_side_wdata         ),
        .rdata_o         ( dout         ),
        .almost_full_o   ( read_side_almost_full   ),
        .empty_o         ( empty         )
    );
    
    assign valid = !empty;

endmodule