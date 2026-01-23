module adder_membrane_layer3 #( 
	parameter       BIT_WIDTH_WEIGHT         = 8,  
    parameter       BIT_WIDTH_MEMBRANE       = 16,
    parameter       BIT_WIDTH_BIG_MEMBRANE       = 16
    )(
		input signed [BIT_WIDTH_BIG_MEMBRANE-1:0] weight_i,
		input signed [BIT_WIDTH_MEMBRANE-1:0] membrane_i,
		input weight_update_mode_i,
		input small_membrane_update_mode_i,

		output signed [BIT_WIDTH_BIG_MEMBRANE-1:0] membrane_update_o
	);

	wire signed [BIT_WIDTH_BIG_MEMBRANE-1:0] adder_out;
	reg signed [BIT_WIDTH_BIG_MEMBRANE-1:0] membrane_update;

	adder_just_layer3#(
		.BIT_WIDTH_BIG_MEMBRANE  ( BIT_WIDTH_BIG_MEMBRANE ),
		.BIT_WIDTH_MEMBRANE ( BIT_WIDTH_MEMBRANE )
	)u_adder_just_layer3(
		.adder_in_first_i  ( weight_i  ),
		.adder_in_second_i ( membrane_i ),
		.adder_out_o       ( adder_out       )
	);

	always @(*) begin
		// overflow control
		membrane_update = adder_out;
		if (weight_i[BIT_WIDTH_BIG_MEMBRANE-1] == membrane_i[BIT_WIDTH_MEMBRANE-1]) begin
			if (weight_update_mode_i) begin 
				if (weight_i[BIT_WIDTH_WEIGHT-1] == 1'b0 && adder_out[BIT_WIDTH_WEIGHT-1] == 1'b1) begin
					membrane_update = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_WEIGHT){1'b0}}, 1'b0, {(BIT_WIDTH_WEIGHT-1){1'b1}} }; 
				end else if (weight_i[BIT_WIDTH_WEIGHT-1] == 1'b1 && adder_out[BIT_WIDTH_WEIGHT-1] == 1'b0) begin
					membrane_update = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_WEIGHT){1'b1}}, 1'b1, {(BIT_WIDTH_WEIGHT-1){1'b0}} }; 
				end
			end else if (small_membrane_update_mode_i) begin
				if (weight_i[BIT_WIDTH_WEIGHT-1] == 1'b0 && adder_out[BIT_WIDTH_MEMBRANE-1] == 1'b1) begin
					membrane_update = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_MEMBRANE){1'b0}}, 1'b0, {(BIT_WIDTH_MEMBRANE-1){1'b1}} }; 
				end else if (weight_i[BIT_WIDTH_WEIGHT-1] == 1'b1 && adder_out[BIT_WIDTH_MEMBRANE-1] == 1'b0) begin
					membrane_update = {{(BIT_WIDTH_BIG_MEMBRANE-BIT_WIDTH_MEMBRANE){1'b1}}, 1'b1, {(BIT_WIDTH_MEMBRANE-1){1'b0}} }; 
				end
			end else begin
				if (weight_i[BIT_WIDTH_BIG_MEMBRANE-1] == 1'b0 && adder_out[BIT_WIDTH_BIG_MEMBRANE-1] == 1'b1) begin
					membrane_update = {1'b0, {(BIT_WIDTH_BIG_MEMBRANE-1){1'b1}}};
				end else if (weight_i[BIT_WIDTH_BIG_MEMBRANE-1] == 1'b1 && adder_out[BIT_WIDTH_BIG_MEMBRANE-1] == 1'b0) begin
					membrane_update = {1'b1, {(BIT_WIDTH_BIG_MEMBRANE-1){1'b0}}};
				end
			end
		end
	end

    assign membrane_update_o = membrane_update;

endmodule