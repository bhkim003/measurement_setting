module neuron_set_layer1 #( 
    parameter       BIT_WIDTH_MEMBRANE       = 17,
	parameter       BIT_WIDTH_SURROGATE       = 3,
	parameter       DEPTH_SURROGATE_BOX       = 2,
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
			neuron_layer1 #(
				.BIT_WIDTH_MEMBRANE            ( BIT_WIDTH_MEMBRANE ),
				.BIT_WIDTH_SURROGATE           ( BIT_WIDTH_SURROGATE ),
				.DEPTH_SURROGATE_BOX           ( DEPTH_SURROGATE_BOX )
			)u_neuron_layer1(
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


 
// ****************************************
// Report : area
// Design : neuron_set
// Version: W-2024.09-SP4
// Date   : Mon Jul 21 17:56:19 2025
// ****************************************

// Library(s) Used:

//     tcbn28hpcplusbwp30p140tt0p9v25c_ccs (File: /mms/kits/TSMC_muse/CRN28HPC+/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn28hpcplusbwp30p140_180a/tcbn28hpcplusbwp30p140tt0p9v25c_ccs.db)

// Number of ports:                          704
// Number of nets:                          2382
// Number of cells:                         2058
// Number of combinational cells:           1578
// Number of sequential cells:               480
// Number of macros/black boxes:               0
// Number of buf/inv:                        309
// Number of references:                      21

// Combinational area:                937.439999
// Buf/Inv area:                       85.806000
// Noncombinational area:            1088.639946
// Macro/Black Box area:                0.000000
// Net Interconnect area:      undefined  (Wire load has zero net area)

// Total cell area:                  2026.079945
// Total area:                 undefined
// 1
