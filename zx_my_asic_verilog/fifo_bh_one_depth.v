module fifo_bh_one_depth #(
    parameter FIFO_DATA_WIDTH = 986
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
    
    reg [FIFO_DATA_WIDTH-1:0] mem;
    

    // Write
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            mem <= {(FIFO_DATA_WIDTH){1'b0}};
        end else if (wren_i) begin
            mem <= wdata_i;
        end
    end

    reg full;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            full <= 0;
        end else begin 
            if (wren_i) begin
                full <= 1;
            end else if (rden_i) begin
                full <= 0;
            end
        end
    end

    wire empty;
    assign empty = !full;




    assign rdata_o = mem;
    
    // Full & empty check
    assign empty_o  =   empty;
    assign full_o   =   full;
endmodule