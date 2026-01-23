module neuron_set_layer2 #( 
    parameter       BIT_WIDTH_MEMBRANE       = 16,
	parameter       BIT_WIDTH_SURROGATE       = 3,
	parameter       DEPTH_SURROGATE_BOX       = 1,
	parameter       NEURON_NUM_IN_SET = 20
    )(
		input clk,
		input reset_n,
		
		input signed [BIT_WIDTH_MEMBRANE-1:0] threshold_i,

		input [BIT_WIDTH_MEMBRANE*NEURON_NUM_IN_SET-1:0] membrane_update_i,
		input membrane_update_valid_i,

		input post_spiking_now_i,
		input training_state_i,
		input this_sample_done_i,

		input surrogate_compute_time_i,
		input [BIT_WIDTH_SURROGATE-1:0] surrogate_ref_i,
		input surrogate_read_finish_i,

		output [BIT_WIDTH_MEMBRANE*NEURON_NUM_IN_SET-1:0] membrane_o,
		output [NEURON_NUM_IN_SET-1:0] post_spike_o,
		output [BIT_WIDTH_SURROGATE*NEURON_NUM_IN_SET-1:0] surrogate_o
	);


	genvar i;
	generate
        for (i = 0; i < NEURON_NUM_IN_SET; i = i + 1) begin : gen_neuron
			neuron_layer2 #(
				.BIT_WIDTH_MEMBRANE            ( BIT_WIDTH_MEMBRANE ),
				.BIT_WIDTH_SURROGATE           ( BIT_WIDTH_SURROGATE ),
				.DEPTH_SURROGATE_BOX           ( DEPTH_SURROGATE_BOX )
			)u_neuron_layer2(
				.clk                           ( clk                           ),
				.reset_n                       ( reset_n                       ),
				.threshold_i                   ( threshold_i                   ),
				.membrane_update_i             ( membrane_update_i[BIT_WIDTH_MEMBRANE*i +: BIT_WIDTH_MEMBRANE]),
				.membrane_update_valid_i       ( membrane_update_valid_i       ),
				.post_spiking_now_i         ( post_spiking_now_i         ),
				.training_state_i         ( training_state_i         ),
				.this_sample_done_i         ( this_sample_done_i         ),
				.surrogate_compute_time_i            ( surrogate_compute_time_i            ),
				.surrogate_ref_i            ( surrogate_ref_i            ),
				.surrogate_read_finish_i            ( surrogate_read_finish_i            ),
				.membrane_o                    ( membrane_o[BIT_WIDTH_MEMBRANE*i +: BIT_WIDTH_MEMBRANE]                    ),
				.post_spike_o                  ( post_spike_o[i]                  ),
				.surrogate_o                   ( surrogate_o[BIT_WIDTH_SURROGATE*i +: BIT_WIDTH_SURROGATE]                   )
			);
        end
	endgenerate



endmodule
