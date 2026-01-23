module neuron_allset_layer3 #( 
    parameter       BIT_WIDTH_MEMBRANE       = 16,
    parameter       BIT_WIDTH_BIG_MEMBRANE       = 16,

	parameter       CLASSIFIER_SIZE = 10
    )(
		input clk,
		input reset_n,
		
		input post_spiking_now_i,

		input [BIT_WIDTH_MEMBRANE*CLASSIFIER_SIZE-1:0] membrane_update_i,
		input [CLASSIFIER_SIZE-1:0] membrane_update_valid_i,
		output [BIT_WIDTH_MEMBRANE*CLASSIFIER_SIZE-1:0] membrane_o,

		input [BIT_WIDTH_BIG_MEMBRANE*CLASSIFIER_SIZE-1:0] big_membrane_update_i,
		input [CLASSIFIER_SIZE-1:0] big_membrane_update_valid_i,
		output [BIT_WIDTH_BIG_MEMBRANE*CLASSIFIER_SIZE-1:0] big_membrane_o
	);
	genvar i;
	generate
        for (i = 0; i < CLASSIFIER_SIZE; i = i + 1) begin : gen_neuron
			neuron_layer3#(
				.BIT_WIDTH_MEMBRANE          ( BIT_WIDTH_MEMBRANE ),
				.BIT_WIDTH_BIG_MEMBRANE      ( BIT_WIDTH_BIG_MEMBRANE )
			)u_neuron_layer3(
				.clk                         ( clk                         ),
				.reset_n                     ( reset_n                     ),
				.post_spiking_now_i          ( post_spiking_now_i          ),
				.membrane_update_i           ( membrane_update_i[BIT_WIDTH_MEMBRANE*i +: BIT_WIDTH_MEMBRANE]           ),
				.membrane_update_valid_i     ( membrane_update_valid_i[i]     ),
				.membrane_o                  ( membrane_o[BIT_WIDTH_MEMBRANE*i +: BIT_WIDTH_MEMBRANE]                  ),
				.big_membrane_update_i       ( big_membrane_update_i[BIT_WIDTH_BIG_MEMBRANE*i +: BIT_WIDTH_BIG_MEMBRANE]       ),
				.big_membrane_update_valid_i ( big_membrane_update_valid_i[i] ),
				.big_membrane_o              ( big_membrane_o[BIT_WIDTH_BIG_MEMBRANE*i +: BIT_WIDTH_BIG_MEMBRANE]              )
			);
        end
	endgenerate
endmodule

