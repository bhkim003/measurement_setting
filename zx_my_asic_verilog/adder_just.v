module adder_just #( 
	parameter       BIT_WIDTH_WEIGHT         = 8,  
    parameter       BIT_WIDTH_MEMBRANE       = 17
    )(
		input signed [BIT_WIDTH_WEIGHT-1:0] adder_in_first_i,
		input signed [BIT_WIDTH_MEMBRANE-1:0] adder_in_second_i,

		output signed [BIT_WIDTH_MEMBRANE-1:0] adder_out_o
	);
    assign adder_out_o = adder_in_first_i + adder_in_second_i;
endmodule