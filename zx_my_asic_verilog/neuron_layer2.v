module neuron_layer2 #( 
    parameter       BIT_WIDTH_MEMBRANE       = 16,
	parameter       BIT_WIDTH_SURROGATE       = 3,
	parameter       DEPTH_SURROGATE_BOX       = 1
    )(
		input clk,
		input reset_n,
		
		input signed [BIT_WIDTH_MEMBRANE-1:0] threshold_i,

		input signed [BIT_WIDTH_MEMBRANE-1:0] membrane_update_i,
		input membrane_update_valid_i,

		input post_spiking_now_i,
		input training_state_i,
		input this_sample_done_i,

		input surrogate_compute_time_i,
		input [BIT_WIDTH_SURROGATE-1:0] surrogate_ref_i,
		input surrogate_read_finish_i,

		output signed [BIT_WIDTH_MEMBRANE-1:0] membrane_o,
		output post_spike_o,
		output [BIT_WIDTH_SURROGATE-1:0] surrogate_o
	);

    reg signed [BIT_WIDTH_MEMBRANE-1:0] membrane, n_membrane;
    reg signed [BIT_WIDTH_MEMBRANE-1:0] membrane_past, n_membrane_past;
	reg post_spike, n_post_spike;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            membrane <= 0;
            membrane_past <= 0;
        end else begin
            membrane <= n_membrane;
            membrane_past <= n_membrane_past;
        end
    end


	wire comp_result;
	always @ (*) begin
		n_membrane = membrane; // default assignment
		if (post_spiking_now_i == 1'b1) begin 
			n_membrane = this_sample_done_i ? 0 : comp_result ? 0 : (membrane >>> 1);
		end else if (membrane_update_valid_i == 1'b1) begin
			n_membrane = membrane_update_i; // update membrane if valid
		end
	end

	wire signed [BIT_WIDTH_MEMBRANE-1:0] comparator_variable1;
	assign comparator_variable1 = post_spiking_now_i ? membrane : membrane_past;
	// assign signed comparator_variable1 = surrogate_compute_time_i ? membrane_past : membrane;
	
	comparator#(
		.BIT_WIDTH_MEMBRANE ( BIT_WIDTH_MEMBRANE )
	)u_comparator(
		.variable1_i ( comparator_variable1 ),
		.variable2_i ( threshold_i ),
		.var1_large_equal_than_var2_o  ( comp_result )
	);


	reg [BIT_WIDTH_SURROGATE-1:0] surrogate_box;
	reg [BIT_WIDTH_SURROGATE-1:0] n_surrogate_box;

	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			surrogate_box <= 0;
		end else begin
			surrogate_box <= n_surrogate_box;
		end
	end

	always @ (*) begin
		n_surrogate_box = surrogate_box;
		// if (training_state_i) begin
		if (surrogate_read_finish_i) begin
			n_surrogate_box = 0;
		end else if (surrogate_compute_time_i && comp_result) begin
			n_surrogate_box = surrogate_ref_i;
		end
		// end
	end

	assign membrane_o = membrane;
	assign surrogate_o = surrogate_box;

	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			post_spike <= 0;
		end else begin
			post_spike <= n_post_spike;
		end
	end
	always @ (*) begin
		n_post_spike = post_spike;
		n_membrane_past = membrane_past;
		if (post_spiking_now_i) begin
			n_post_spike = comp_result;
			if (training_state_i) begin
				n_membrane_past = membrane;
			end
		end
	end

	assign post_spike_o = post_spike;
endmodule

