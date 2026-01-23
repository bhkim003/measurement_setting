module fifo_bh #(
    parameter FIFO_DATA_WIDTH = 986,
    parameter FIFO_DEPTH = 2,  
    parameter FIFO_DEPTH_LG2 = 1
    )(
		input                       clk,
		input                       reset_n,

		input                       wren_i,
		input                       rden_i,
		input   [FIFO_DATA_WIDTH-1:0]    wdata_i,

		output  [FIFO_DATA_WIDTH-1:0]    rdata_o,
		output                      full_o,
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
    
    // Full & empty check
    assign empty_o  =   (wrptr == rdptr);
    assign full_o   =   (wrptr[FIFO_DEPTH_LG2-1:0] == rdptr[FIFO_DEPTH_LG2-1:0]) &&
                        (wrptr[FIFO_DEPTH_LG2] != rdptr[FIFO_DEPTH_LG2]);
endmodule