module adder_membrane_set #( 
	parameter       BIT_WIDTH_WEIGHT         = 8,  
    parameter       BIT_WIDTH_MEMBRANE       = 17,
	parameter       NEURON_NUM_IN_SET = 20
    )(
		input [BIT_WIDTH_WEIGHT*NEURON_NUM_IN_SET-1:0] weight_i,
		input [BIT_WIDTH_MEMBRANE*NEURON_NUM_IN_SET-1:0] membrane_i,
		input weight_update_mode_i,

		output [BIT_WIDTH_MEMBRANE*NEURON_NUM_IN_SET-1:0] membrane_update_o
	);

	genvar i;
	generate
        for (i = 0; i < NEURON_NUM_IN_SET; i = i + 1) begin : gen_adder_membrane
			adder_membrane#(
				.BIT_WIDTH_WEIGHT     ( BIT_WIDTH_WEIGHT ),
				.BIT_WIDTH_MEMBRANE   ( BIT_WIDTH_MEMBRANE )
			)u_adder_membrane(
				.weight_i             ( weight_i[BIT_WIDTH_WEIGHT*i +: BIT_WIDTH_WEIGHT]             ),
				.membrane_i           ( membrane_i[BIT_WIDTH_MEMBRANE*i +: BIT_WIDTH_MEMBRANE]           ),
				.weight_update_mode_i ( weight_update_mode_i ),
				.membrane_update_o    ( membrane_update_o[BIT_WIDTH_MEMBRANE*i +: BIT_WIDTH_MEMBRANE]    )
			);
        end
	endgenerate

endmodule


 
// ****************************************
// Report : area
// Design : adder_membrane_set
// Version: W-2024.09-SP4
// Date   : Sat Jul 19 15:21:31 2025
// ****************************************

// Library(s) Used:

//     tcbn28hpcplusbwp30p140tt0p9v25c_ccs (File: /mms/kits/TSMC_muse/CRN28HPC+/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn28hpcplusbwp30p140_180a/tcbn28hpcplusbwp30p140tt0p9v25c_ccs.db)

// Number of ports:                          761
// Number of nets:                          2031
// Number of cells:                         1430
// Number of combinational cells:           1430
// Number of sequential cells:                 0
// Number of macros/black boxes:               0
// Number of buf/inv:                        133
// Number of references:                      21

// Combinational area:               1010.519994
// Buf/Inv area:                       33.768001
// Noncombinational area:               0.000000
// Macro/Black Box area:                0.000000
// Net Interconnect area:      undefined  (Wire load has zero net area)

// Total cell area:                  1010.519994
// Total area:                 undefined
// 1



