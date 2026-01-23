module comparator_final_loser #( 
    parameter       BIT_WIDTH_BIG_MEMBRANE       = 16
    )(
		input signed [BIT_WIDTH_BIG_MEMBRANE-1:0] variable0_i,
		input signed [BIT_WIDTH_BIG_MEMBRANE-1:0] variable1_i,
		input signed [BIT_WIDTH_BIG_MEMBRANE-1:0] variable2_i,
		input signed [BIT_WIDTH_BIG_MEMBRANE-1:0] variable3_i,
		input signed [BIT_WIDTH_BIG_MEMBRANE-1:0] variable4_i,

		output [2:0] loser_o
	);

	wire comp_variable0_i_vs_variable1_i;
	assign comp_variable0_i_vs_variable1_i = variable0_i <= variable1_i ? 1'b1 : 1'b0;
	wire [2:0] loser_level1_0;
	wire signed [BIT_WIDTH_BIG_MEMBRANE-1:0] loser_level1_0_variable;
	assign loser_level1_0 = comp_variable0_i_vs_variable1_i ? 4'd0 : 4'd1;
	assign loser_level1_0_variable = comp_variable0_i_vs_variable1_i ? variable0_i : variable1_i;

	wire comp_variable2_i_vs_variable3_i;
	assign comp_variable2_i_vs_variable3_i = variable2_i <= variable3_i ? 1'b1 : 1'b0;
	wire [2:0] loser_level1_1;
	wire signed [BIT_WIDTH_BIG_MEMBRANE-1:0] loser_level1_1_variable;
	assign loser_level1_1 = comp_variable2_i_vs_variable3_i ? 4'd2 : 4'd3;
	assign loser_level1_1_variable = comp_variable2_i_vs_variable3_i ? variable2_i : variable3_i;

	wire comp_loser_level1_1_variable_vs_variable4_i;
	assign comp_loser_level1_1_variable_vs_variable4_i = loser_level1_1_variable <= variable4_i ? 1'b1 : 1'b0;
	wire [2:0] loser_level2_0;
	wire signed [BIT_WIDTH_BIG_MEMBRANE-1:0] loser_level2_0_variable;
	assign loser_level2_0 = comp_loser_level1_1_variable_vs_variable4_i ? loser_level1_1 : 4'd4;
	assign loser_level2_0_variable = comp_loser_level1_1_variable_vs_variable4_i ? loser_level1_1_variable : variable4_i;

	wire comp_loser_level1_0_variable_vs_loser_level2_0_variable;
	assign comp_loser_level1_0_variable_vs_loser_level2_0_variable = loser_level1_0_variable <= loser_level2_0_variable ? 1'b1 : 1'b0;
	wire [2:0] loser_level3_0;
	assign loser_level3_0 = comp_loser_level1_0_variable_vs_loser_level2_0_variable ? loser_level1_0 : loser_level2_0;

	wire [2:0] loser;
	assign loser = loser_level3_0;

	assign loser_o = loser;
endmodule