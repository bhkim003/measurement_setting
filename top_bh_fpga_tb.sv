// `timescale 1ns / 1ps
//     `define CLK_PERIOD                 5
//     `define CLK_PERIOD_HALF            2.5


// module top_bh_fpga_tb;


// 	reg clk;
// 	reg reset_n;

//     reg wr_en;
//     reg [32 - 1:0] din;
//     wire full;
//     reg rd_en;
//     wire [32 - 1:0] dout;
//     wire empty;

//     wire valid;

//     fifo_bh_write_width32_depth16_read_width32_depth16 u_fifo_bh_write_width32_depth16_read_width32_depth16(
//         .rst    ( !reset_n    ),
//         .wr_clk ( clk ),
//         .wr_en  ( wr_en  ),
//         .din    ( din    ),
//         .full   ( full   ),
//         .rd_clk ( clk ),
//         .rd_en  ( rd_en  ),
//         .dout   ( dout   ),
//         .empty  ( empty  ),
//         .valid  ( valid  )
//     );




//     initial clk = 0;
//     always #(`CLK_PERIOD_HALF) clk = ~clk;
//     integer i;
//     initial begin


//         #(`CLK_PERIOD/10);
//         // Initial values
//         reset_n = 1;

// 		wr_en = 0;
// 		// rd_en = 0;
// 		din = 10;
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         #(`CLK_PERIOD/10);
//         reset_n = 0;

//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         #(`CLK_PERIOD/10);
//         reset_n = 1;
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         for (i = 0; i < 16; i = i + 1) begin
//             @(posedge clk); 
//             #(`CLK_PERIOD/10);
//             wr_en = 1;
//             din = i+10;
//         end
//         @(posedge clk); 
//         #(`CLK_PERIOD/10);
//         wr_en = 0;
//         for (i = 0; i < 16; i = i + 1) begin
//             @(posedge clk); 
//             #(`CLK_PERIOD/10);
//             // rd_en = 1;
//         end
//         @(posedge clk); 
//         #(`CLK_PERIOD/10);
//         // rd_en = 0;
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 
//         @(posedge clk); 

//     end

//     reg [7:0] cnt;
//     always @ (*) begin
//         rd_en = !empty;
//         // rd_en = !empty && (cnt == 0);
//     end

//     always @ (posedge clk or negedge reset_n) begin
//         if (!reset_n) begin
//             cnt <= 0;
//         end else begin
//             if (cnt == 4) begin
//                 cnt <= 0;
//             end else begin
//                 cnt <= cnt + 1;
//             end
//         end
//     end

// endmodule







`timescale 1ns / 1ps
    `define CLK_PERIOD                 5
    `define CLK_PERIOD_HALF            2.5


module top_bh_fpga_tb;


	reg clk;
	reg reset_n;

    reg wr_en;
    reg [32 - 1:0] din;
    wire full;
    reg rd_en;
    wire [32 - 1:0] dout;
    wire empty;

    wire valid;

    fifo_bh_write_width32_depth16_read_width32_depth16 u_fifo_bh_write_width32_depth16_read_width32_depth16(
        .rst    ( !reset_n    ),
        .wr_clk ( clk ),
        .wr_en  ( wr_en  ),
        .din    ( din    ),
        .full   ( full   ),
        .rd_clk ( clk ),
        .rd_en  ( rd_en  ),
        .dout   ( dout   ),
        .empty  ( empty  ),
        .valid  ( valid  )
    );


    initial clk = 0;
    always #(`CLK_PERIOD_HALF) clk = ~clk;
    integer i;
    initial begin


        @(negedge clk); 
        // Initial values
        reset_n = 1;

		wr_en = 0;
		rd_en = 0;
		din = 10;
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        #(`CLK_PERIOD/10);
        @(negedge clk); 
        reset_n = 0;

        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        #(`CLK_PERIOD/10);
        @(negedge clk); 
        reset_n = 1;
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        for (i = 0; i < 16; i = i + 1) begin
            @(posedge clk); 
            @(negedge clk); 
            wr_en = 1;
            din = i+10;
        end
        @(posedge clk); 
        @(negedge clk); 
        #(`CLK_PERIOD/10);
        wr_en = 0;
        for (i = 0; i < 16; i = i + 1) begin
            @(posedge clk); 
            #(`CLK_PERIOD/10);
            @(negedge clk); 
            rd_en = !empty;
        end
        @(posedge clk); 
        #(`CLK_PERIOD/10);
        @(negedge clk); 
        rd_en = 0;
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 

    end

    // always @ (*) begin
    //     rd_en = !empty;
    // end

endmodule
