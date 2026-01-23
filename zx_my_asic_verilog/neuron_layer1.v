module neuron_layer1 #( 
    parameter       BIT_WIDTH_MEMBRANE       = 17,
	parameter       BIT_WIDTH_SURROGATE       = 3,
	parameter       DEPTH_SURROGATE_BOX       = 2
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
	// assign comparator_variable1 = surrogate_compute_time_i ? membrane_past : membrane;
	
	comparator#(
		.BIT_WIDTH_MEMBRANE ( BIT_WIDTH_MEMBRANE )
	)u_comparator(
		.variable1_i ( comparator_variable1 ),
		.variable2_i ( threshold_i ),
		.var1_large_equal_than_var2_o  ( comp_result )
	);


	reg [BIT_WIDTH_SURROGATE-1:0] surrogate_box [0:DEPTH_SURROGATE_BOX-1];
	reg [BIT_WIDTH_SURROGATE-1:0] n_surrogate_box [0:DEPTH_SURROGATE_BOX-1];

    genvar i;
    generate
        for (i = 0; i < DEPTH_SURROGATE_BOX; i = i + 1) begin : gen_surrogate_box_reg_sequential
            always @(posedge clk or negedge reset_n) begin
                if (!reset_n) begin
                    surrogate_box[i] <= 0;
                end else begin
                    surrogate_box[i] <= n_surrogate_box[i];
                end
            end
        end
    endgenerate

	always @ (*) begin
		n_surrogate_box[0] = surrogate_box[0];
		// if (training_state_i) begin
		if (surrogate_read_finish_i) begin
			n_surrogate_box[0] = 0;
		end else if (surrogate_compute_time_i && comp_result) begin
			n_surrogate_box[0] = surrogate_ref_i;
		end
		// end
	end
    genvar j;
    generate
        for (j = 1; j < DEPTH_SURROGATE_BOX; j = j + 1) begin : gen_surrogate_box_reg_combinational
			always @ (*) begin
				n_surrogate_box[j] = surrogate_box[j];
				// if (training_state_i) begin
				if (surrogate_read_finish_i) begin
					n_surrogate_box[j] = surrogate_box[j-1];
				end
				// end
			end
		end
	endgenerate

	assign membrane_o = membrane;
	assign surrogate_o = surrogate_box[DEPTH_SURROGATE_BOX-1];

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


 
// ****************************************
// Report : area
// Design : neuron
// Version: W-2024.09-SP4
// Date   : Mon Jul 21 17:49:58 2025
// ****************************************

// Library(s) Used:

//     tcbn28hpcplusbwp30p140tt0p9v25c_ccs (File: /mms/kits/TSMC_muse/CRN28HPC+/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn28hpcplusbwp30p140_180a/tcbn28hpcplusbwp30p140tt0p9v25c_ccs.db)

// Number of ports:                           58
// Number of nets:                           126
// Number of cells:                           87
// Number of combinational cells:             63
// Number of sequential cells:                24
// Number of macros/black boxes:               0
// Number of buf/inv:                         17
// Number of references:                      15

// Combinational area:                 34.146000
// Buf/Inv area:                        4.284000
// Noncombinational area:              67.662000
// Macro/Black Box area:                0.000000
// Net Interconnect area:      undefined  (Wire load has zero net area)

// Total cell area:                   101.807999
// Total area:                 undefined
// 1
