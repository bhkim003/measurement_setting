module comparator #( 
    parameter       BIT_WIDTH_MEMBRANE       = 17
    )(
		input signed [BIT_WIDTH_MEMBRANE-1:0] variable1_i,
		input signed [BIT_WIDTH_MEMBRANE-1:0] variable2_i,

		output var1_large_equal_than_var2_o
	);
	assign var1_large_equal_than_var2_o = variable1_i >= variable2_i ? 1'b1 : 1'b0;
endmodule