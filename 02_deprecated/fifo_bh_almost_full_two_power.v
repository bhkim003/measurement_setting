// ################ TWO-POWER-FIFO #############################################
// ################ TWO-POWER-FIFO #############################################
// ################ TWO-POWER-FIFO #############################################
module fifo_bh_almost_full_two_power #(
    parameter FIFO_DATA_WIDTH = 32,
    parameter FIFO_DEPTH = 4,
    parameter FIFO_DEPTH_LG2 = 2,
    parameter FIFO_MINIMUM_SPACE_TO_READ_REQUEST = 2
    )(
		input                       clk,
		input                       reset_n,

		input                       wren_i,
		input                       rden_i,
		input   [FIFO_DATA_WIDTH-1:0]    wdata_i,

		output  [FIFO_DATA_WIDTH-1:0]    rdata_o,
		output                      almost_full_o,
		output                      empty_o
    );
    
    // localparam FIFO_DEPTH_LG2 = $clog2(FIFO_DEPTH);
    
    reg [FIFO_DEPTH_LG2:0] wrptr;
    reg [FIFO_DEPTH_LG2:0] rdptr;
    
    // Write pointer counter seq logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            wrptr <= {(FIFO_DEPTH_LG2+1){1'b0}};
        end else if (wren_i) begin
            wrptr <= wrptr + 'd1;
        end
    end
    
    // Read pointer counter seq logic   
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rdptr <= {(FIFO_DEPTH_LG2+1){1'b0}};
        end else if (rden_i) begin
            rdptr <= rdptr + 1;
        end
    end
    
    reg [FIFO_DEPTH*FIFO_DATA_WIDTH-1:0] mem;
    
    // Write
    genvar i;
    generate
        for (i = 0; i < FIFO_DEPTH; i = i + 1) begin : gen_fifo_mem
            always @(posedge clk or negedge reset_n) begin
                if (!reset_n) begin
                    mem[i*FIFO_DATA_WIDTH +: FIFO_DATA_WIDTH] <= {(FIFO_DATA_WIDTH){1'b0}};
                end else if (wren_i && wrptr[FIFO_DEPTH_LG2-1:0] == i) begin
                    mem[i*FIFO_DATA_WIDTH +: FIFO_DATA_WIDTH] <= wdata_i;
                end
            end
        end
    endgenerate

    assign rdata_o = mem[rdptr[FIFO_DEPTH_LG2-1:0]*FIFO_DATA_WIDTH +: FIFO_DATA_WIDTH];
    
    // almost_Full & empty check
    assign empty_o  = (wrptr == rdptr);
    wire [FIFO_DEPTH_LG2:0] fifo_count;
    assign fifo_count = wrptr - rdptr;
    assign almost_full_o = (fifo_count > (FIFO_DEPTH - FIFO_MINIMUM_SPACE_TO_READ_REQUEST));

endmodule
// ################ TWO-POWER-FIFO #############################################
// ################ TWO-POWER-FIFO #############################################
// ################ TWO-POWER-FIFO #############################################






// // ################ NON-TWO-POWER-FIFO #############################################
// // ################ NON-TWO-POWER-FIFO #############################################
// // ################ NON-TWO-POWER-FIFO #############################################
// module fifo_bh_almost_full #(
//     parameter FIFO_DATA_WIDTH = 32,
//     parameter FIFO_DEPTH = 3,  
//     parameter FIFO_DEPTH_LG2 = 2,
//     parameter FIFO_MINIMUM_SPACE_TO_READ_REQUEST = 2
//     )(
// 		input                       clk,
// 		input                       reset_n,

// 		input                       wren_i,
// 		input                       rden_i,
// 		input   [FIFO_DATA_WIDTH-1:0]    wdata_i,

// 		output  [FIFO_DATA_WIDTH-1:0]    rdata_o,
// 		output                      almost_full_o,
// 		output                      empty_o
//     );
    
//     // localparam FIFO_DEPTH_LG2 = $clog2(FIFO_DEPTH);
    
//     reg [FIFO_DEPTH_LG2-1:0] wrptr;
//     reg [FIFO_DEPTH_LG2-1:0] rdptr;
    
//     // Write pointer counter seq logic
//     always @(posedge clk or negedge reset_n) begin
//         if (!reset_n) begin
//             wrptr <= {(FIFO_DEPTH_LG2){1'b0}};
//         end else if (wren_i) begin
//             if (wrptr == (FIFO_DEPTH - 1)) begin
//                 wrptr <= {(FIFO_DEPTH_LG2){1'b0}}; // wrap around
//             end else begin
//                 wrptr <= wrptr + 'd1;
//             end
//         end
//     end
    
//     // Read pointer counter seq logic   
//     always @(posedge clk or negedge reset_n) begin
//         if (!reset_n) begin
//             rdptr <= {(FIFO_DEPTH_LG2){1'b0}};
//         end else if (rden_i) begin
//             if (rdptr == (FIFO_DEPTH - 1)) begin
//                 rdptr <= {(FIFO_DEPTH_LG2){1'b0}}; // wrap around
//             end else begin
//                 rdptr <= rdptr + 'd1;
//             end
//         end
//     end
    
//     reg [FIFO_DEPTH*FIFO_DATA_WIDTH-1:0] mem;
    
//     // Write
//     genvar i;
//     generate
//         for (i = 0; i < FIFO_DEPTH; i = i + 1) begin : gen_fifo_mem
//             always @(posedge clk or negedge reset_n) begin
//                 if (!reset_n) begin
//                     mem[i*FIFO_DATA_WIDTH +: FIFO_DATA_WIDTH] <= {(FIFO_DATA_WIDTH){1'b0}};
//                 end else if (wren_i && wrptr == i) begin
//                     mem[i*FIFO_DATA_WIDTH +: FIFO_DATA_WIDTH] <= wdata_i;
//                 end
//             end
//         end
//     endgenerate

//     assign rdata_o = mem[rdptr*FIFO_DATA_WIDTH +: FIFO_DATA_WIDTH];

//     reg [FIFO_DEPTH_LG2:0] fifo_count;
//     always @(posedge clk or negedge reset_n) begin
//         if (!reset_n) begin
//             fifo_count <= {(FIFO_DEPTH_LG2){1'b0}};
//         end else if (wren_i && rden_i == 0) begin
//             fifo_count <= fifo_count + 1;
//         end else if (rden_i && wren_i == 0) begin
//             fifo_count <= fifo_count - 1;
//         end
//     end

//     assign empty_o  = (fifo_count == 0);
//     assign almost_full_o = (fifo_count > (FIFO_DEPTH - FIFO_MINIMUM_SPACE_TO_READ_REQUEST));

// endmodule
// // ################ NON-TWO-POWER-FIFO #############################################
// // ################ NON-TWO-POWER-FIFO #############################################
// // ################ NON-TWO-POWER-FIFO #############################################
