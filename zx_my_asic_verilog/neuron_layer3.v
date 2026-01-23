module neuron_layer3 #( 
    parameter       BIT_WIDTH_MEMBRANE       = 16,
    parameter       BIT_WIDTH_BIG_MEMBRANE       = 16
    )(
		input clk,
		input reset_n,

		input post_spiking_now_i,

		input signed [BIT_WIDTH_MEMBRANE-1:0] membrane_update_i,
		input membrane_update_valid_i,
		output signed [BIT_WIDTH_MEMBRANE-1:0] membrane_o,

		input signed [BIT_WIDTH_BIG_MEMBRANE-1:0] big_membrane_update_i,
		input big_membrane_update_valid_i,
		output signed [BIT_WIDTH_BIG_MEMBRANE-1:0] big_membrane_o
	);

    reg signed [BIT_WIDTH_MEMBRANE-1:0] membrane, n_membrane;
    reg signed [BIT_WIDTH_BIG_MEMBRANE-1:0] big_membrane, n_big_membrane;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            membrane <= 0;
            big_membrane <= 0;
        end else begin
            membrane <= n_membrane;
            big_membrane <= n_big_membrane;
        end
    end

	always @ (*) begin
		n_membrane = membrane;
		if (post_spiking_now_i == 1'b1) begin 
			n_membrane = 0;
		end else if (membrane_update_valid_i == 1'b1) begin
			n_membrane = membrane_update_i;
		end
	end

	always @ (*) begin
		n_big_membrane = big_membrane;
		if (big_membrane_update_valid_i == 1'b1) begin
			n_big_membrane = big_membrane_update_i;
		end
	end

	assign membrane_o = membrane;
	assign big_membrane_o = big_membrane;

endmodule
