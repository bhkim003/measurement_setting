module comparator_final #( 
    parameter       BIT_WIDTH_BIG_MEMBRANE       = 16
    )(
		input signed [BIT_WIDTH_BIG_MEMBRANE-1:0] variable0_i,
		input signed [BIT_WIDTH_BIG_MEMBRANE-1:0] variable1_i,
		input signed [BIT_WIDTH_BIG_MEMBRANE-1:0] variable2_i,
		input signed [BIT_WIDTH_BIG_MEMBRANE-1:0] variable3_i,
		input signed [BIT_WIDTH_BIG_MEMBRANE-1:0] variable4_i,
		input signed [BIT_WIDTH_BIG_MEMBRANE-1:0] variable5_i,
		input signed [BIT_WIDTH_BIG_MEMBRANE-1:0] variable6_i,
		input signed [BIT_WIDTH_BIG_MEMBRANE-1:0] variable7_i,
		input signed [BIT_WIDTH_BIG_MEMBRANE-1:0] variable8_i,
		input signed [BIT_WIDTH_BIG_MEMBRANE-1:0] variable9_i,

		output [3:0] winner_section1_o,
		output [3:0] winner_section2_o,
		output [3:0] winner_section_all_o,
		output winner_section_all_binary_o
	);

	// ########### section 1 ###################################################################################
	// ########### section 1 ###################################################################################
	// ########### section 1 ###################################################################################
	wire comp_variable0_i_vs_variable1_i;
	assign comp_variable0_i_vs_variable1_i = variable0_i >= variable1_i ? 1'b1 : 1'b0;
	wire [3:0] winner_section1_level1_0;
	wire signed [BIT_WIDTH_BIG_MEMBRANE-1:0] winner_section1_level1_0_variable;
	assign winner_section1_level1_0 = comp_variable0_i_vs_variable1_i ? 4'd0 : 4'd1;
	assign winner_section1_level1_0_variable = comp_variable0_i_vs_variable1_i ? variable0_i : variable1_i;

	wire comp_variable2_i_vs_variable3_i;
	assign comp_variable2_i_vs_variable3_i = variable2_i >= variable3_i ? 1'b1 : 1'b0;
	wire [3:0] winner_section1_level1_1;
	wire signed [BIT_WIDTH_BIG_MEMBRANE-1:0] winner_section1_level1_1_variable;
	assign winner_section1_level1_1 = comp_variable2_i_vs_variable3_i ? 4'd2 : 4'd3;
	assign winner_section1_level1_1_variable = comp_variable2_i_vs_variable3_i ? variable2_i : variable3_i;

	wire comp_winner_section1_level1_1_variable_vs_variable4_i;
	assign comp_winner_section1_level1_1_variable_vs_variable4_i = winner_section1_level1_1_variable >= variable4_i ? 1'b1 : 1'b0;
	wire [3:0] winner_section1_level2_0;
	wire signed [BIT_WIDTH_BIG_MEMBRANE-1:0] winner_section1_level2_0_variable;
	assign winner_section1_level2_0 = comp_winner_section1_level1_1_variable_vs_variable4_i ? winner_section1_level1_1 : 4'd4;
	assign winner_section1_level2_0_variable = comp_winner_section1_level1_1_variable_vs_variable4_i ? winner_section1_level1_1_variable : variable4_i;

	wire comp_winner_section1_level1_0_variable_vs_winner_section1_level2_0_variable;
	assign comp_winner_section1_level1_0_variable_vs_winner_section1_level2_0_variable = winner_section1_level1_0_variable >= winner_section1_level2_0_variable ? 1'b1 : 1'b0;
	wire [3:0] winner_section1_level3_0;
	wire signed [BIT_WIDTH_BIG_MEMBRANE-1:0] winner_section1_level3_0_variable;
	assign winner_section1_level3_0 = comp_winner_section1_level1_0_variable_vs_winner_section1_level2_0_variable ? winner_section1_level1_0 : winner_section1_level2_0;
	assign winner_section1_level3_0_variable = comp_winner_section1_level1_0_variable_vs_winner_section1_level2_0_variable ? winner_section1_level1_0_variable : winner_section1_level2_0_variable;

	wire [3:0] winner_section1;
	wire signed [BIT_WIDTH_BIG_MEMBRANE-1:0] winner_section1_variable;
	assign winner_section1 = winner_section1_level3_0;
	assign winner_section1_variable = winner_section1_level3_0_variable;
	// ########### section 1 ###################################################################################
	// ########### section 1 ###################################################################################
	// ########### section 1 ###################################################################################





	// ########### section 2 ###################################################################################
	// ########### section 2 ###################################################################################
	// ########### section 2 ###################################################################################
	wire comp_variable5_i_vs_variable6_i;
	assign comp_variable5_i_vs_variable6_i = variable5_i >= variable6_i ? 1'b1 : 1'b0;
	wire [3:0] winner_section2_level1_0;
	wire signed [BIT_WIDTH_BIG_MEMBRANE-1:0] winner_section2_level1_0_variable;
	assign winner_section2_level1_0 = comp_variable5_i_vs_variable6_i ? 4'd5 : 4'd6;
	assign winner_section2_level1_0_variable = comp_variable5_i_vs_variable6_i ? variable5_i : variable6_i;

	wire comp_variable7_i_vs_variable8_i;
	assign comp_variable7_i_vs_variable8_i = variable7_i >= variable8_i ? 1'b1 : 1'b0;
	wire [3:0] winner_section2_level1_1;
	wire signed [BIT_WIDTH_BIG_MEMBRANE-1:0] winner_section2_level1_1_variable;
	assign winner_section2_level1_1 = comp_variable7_i_vs_variable8_i ? 4'd7 : 4'd8;
	assign winner_section2_level1_1_variable = comp_variable7_i_vs_variable8_i ? variable7_i : variable8_i;

	wire comp_winner_section2_level1_1_variable_vs_variable9_i;
	assign comp_winner_section2_level1_1_variable_vs_variable9_i = winner_section2_level1_1_variable >= variable9_i ? 1'b1 : 1'b0;
	wire [3:0] winner_section2_level2_0;
	wire signed [BIT_WIDTH_BIG_MEMBRANE-1:0] winner_section2_level2_0_variable;
	assign winner_section2_level2_0 = comp_winner_section2_level1_1_variable_vs_variable9_i ? winner_section2_level1_1 : 4'd9;
	assign winner_section2_level2_0_variable = comp_winner_section2_level1_1_variable_vs_variable9_i ? winner_section2_level1_1_variable : variable9_i;

	wire comp_winner_section2_level1_0_variable_vs_winner_section2_level2_0_variable;
	assign comp_winner_section2_level1_0_variable_vs_winner_section2_level2_0_variable = winner_section2_level1_0_variable >= winner_section2_level2_0_variable ? 1'b1 : 1'b0;
	wire [3:0] winner_section2_level3_0;
	wire signed [BIT_WIDTH_BIG_MEMBRANE-1:0]  winner_section2_level3_0_variable;
	assign winner_section2_level3_0 = comp_winner_section2_level1_0_variable_vs_winner_section2_level2_0_variable ? winner_section2_level1_0 : winner_section2_level2_0;
	assign winner_section2_level3_0_variable = comp_winner_section2_level1_0_variable_vs_winner_section2_level2_0_variable ? winner_section2_level1_0_variable : winner_section2_level2_0_variable;

	wire [3:0] winner_section2;
	wire signed [BIT_WIDTH_BIG_MEMBRANE-1:0] winner_section2_variable;
	assign winner_section2 = winner_section2_level3_0;
	assign winner_section2_variable = winner_section2_level3_0_variable;
	// ########### section 2 ###################################################################################
	// ########### section 2 ###################################################################################
	// ########### section 2 ###################################################################################



	wire comp_winner_section1_variable_vs_winner_section2_variable;
	assign comp_winner_section1_variable_vs_winner_section2_variable = winner_section1_variable >= winner_section2_variable ? 1'b1 : 1'b0;

	assign winner_section1_o = winner_section1;
	assign winner_section2_o = winner_section2;
	assign winner_section_all_o = comp_winner_section1_variable_vs_winner_section2_variable ? winner_section1 : winner_section2;
	assign winner_section_all_binary_o = comp_winner_section1_variable_vs_winner_section2_variable ? 1'd0 : 1'd1;
	
endmodule
// 227.283206