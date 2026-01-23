module adder_membrane #( 
	parameter       BIT_WIDTH_WEIGHT         = 8,  
    parameter       BIT_WIDTH_MEMBRANE       = 17
    )(
		input signed [BIT_WIDTH_WEIGHT-1:0] weight_i,
		input signed [BIT_WIDTH_MEMBRANE-1:0] membrane_i,
		input weight_update_mode_i,

		output signed [BIT_WIDTH_MEMBRANE-1:0] membrane_update_o
	);

	wire signed [BIT_WIDTH_MEMBRANE-1:0] adder_out;
	reg signed [BIT_WIDTH_MEMBRANE-1:0] membrane_update;

	adder_just#(
		.BIT_WIDTH_WEIGHT  ( BIT_WIDTH_WEIGHT ),
		.BIT_WIDTH_MEMBRANE ( BIT_WIDTH_MEMBRANE )
	)u_adder_just(
		.adder_in_first_i  ( weight_i  ),
		.adder_in_second_i ( membrane_i ),
		.adder_out_o       ( adder_out       )
	);


	always @(*) begin
		// overflow control
		membrane_update = adder_out;
		if (weight_i[BIT_WIDTH_WEIGHT-1] == membrane_i[BIT_WIDTH_MEMBRANE-1]) begin
			if (weight_update_mode_i) begin 
				if (weight_i[BIT_WIDTH_WEIGHT-1] == 1'b0 && adder_out[BIT_WIDTH_WEIGHT-1] == 1'b1) begin
					membrane_update = {{(BIT_WIDTH_MEMBRANE-BIT_WIDTH_WEIGHT){1'b0}}, 1'b0, {(BIT_WIDTH_WEIGHT-1){1'b1}} }; 
				end else if (weight_i[BIT_WIDTH_WEIGHT-1] == 1'b1 && adder_out[BIT_WIDTH_WEIGHT-1] == 1'b0) begin
					membrane_update = {{(BIT_WIDTH_MEMBRANE-BIT_WIDTH_WEIGHT){1'b1}}, 1'b1, {(BIT_WIDTH_WEIGHT-1){1'b0}} }; 
				end
			end else begin
				if (weight_i[BIT_WIDTH_WEIGHT-1] == 1'b0 && adder_out[BIT_WIDTH_MEMBRANE-1] == 1'b1) begin
					membrane_update = {1'b0, {(BIT_WIDTH_MEMBRANE-1){1'b1}}};
				end else if (weight_i[BIT_WIDTH_WEIGHT-1] == 1'b1 && adder_out[BIT_WIDTH_MEMBRANE-1] == 1'b0) begin
					membrane_update = {1'b1, {(BIT_WIDTH_MEMBRANE-1){1'b0}}};
				end
			end
		end
	end

    assign membrane_update_o = membrane_update;

endmodule

 
// ****************************************
// Report : area
// Design : adder_membrane
// Version: W-2024.09-SP4
// Date   : Wed Jul 23 13:42:31 2025
// ****************************************

// Library(s) Used:

//     tcbn28hpcplusbwp30p140tt0p9v25c_ccs (File: /mms/kits/TSMC_muse/CRN28HPC+/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn28hpcplusbwp30p140_180a/tcbn28hpcplusbwp30p140tt0p9v25c_ccs.db)

// Number of ports:                           39
// Number of nets:                           102
// Number of cells:                           71
// Number of combinational cells:             71
// Number of sequential cells:                 0
// Number of macros/black boxes:               0
// Number of buf/inv:                          9
// Number of references:                      19

// Combinational area:                 50.148000
// Buf/Inv area:                        2.268000
// Noncombinational area:               0.000000
// Macro/Black Box area:                0.000000
// Net Interconnect area:      undefined  (Wire load has zero net area)

// Total cell area:                    50.148000
// Total area:                 undefined
// 1
