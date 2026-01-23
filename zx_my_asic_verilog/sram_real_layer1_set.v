module sram_real_layer1_set #( 
	parameter       BIT_WIDTH_WEIGHT         = 8,  

	parameter       BIT_WIDTH_SRAM         = 160,  
	parameter       DEPTH_SRAM             = 980,
	parameter       BIT_WIDTH_ADDRESS      = 10,

	parameter       NEURON_NUM_IN_SET = 20,
	parameter       SET_NUM = 10
    )(
		input clk,

		input [BIT_WIDTH_ADDRESS*SET_NUM-1:0] port1_address_i,
		input [SET_NUM-1:0] port1_enable_i,
		input [SET_NUM-1:0] port1_write_enable_i,
		input [BIT_WIDTH_SRAM*SET_NUM-1:0] port1_write_data_i,

		output [BIT_WIDTH_SRAM*SET_NUM-1:0] port1_read_data_o
	);


	wire [BIT_WIDTH_ADDRESS-1:0] port1_address_array [0:SET_NUM-1];
	wire [BIT_WIDTH_SRAM-1:0] port1_write_data_array [0:SET_NUM-1];
	wire [BIT_WIDTH_SRAM-1:0] port1_read_data_array [0:SET_NUM-1];
    genvar i2;
    generate
        for (i2 = 0; i2 < SET_NUM; i2 = i2 + 1) begin : gen_port1_i2
			assign port1_address_array[i2] = {BIT_WIDTH_ADDRESS{port1_enable_i[i2]}} & port1_address_i[BIT_WIDTH_ADDRESS*i2 +: BIT_WIDTH_ADDRESS];
			assign port1_write_data_array[i2] = {BIT_WIDTH_SRAM{port1_enable_i[i2]}} & port1_write_data_i[BIT_WIDTH_SRAM*i2 +: BIT_WIDTH_SRAM];
			assign port1_read_data_o[BIT_WIDTH_SRAM*i2 +: BIT_WIDTH_SRAM] = port1_read_data_array[i2];
        end
    endgenerate
    genvar k2;
    generate
        for (k2 = 0; k2 < SET_NUM; k2 = k2 + 1) begin : gen_sram_memory_behavioral
			sram_real_layer1#(
				.N   ( BIT_WIDTH_SRAM ),
				.W   ( DEPTH_SRAM )
			)u_sram_real_layer1(
				.clk  ( clk  ),
				.A    ( port1_address_array[k2]    ),
				.D    ( port1_write_data_array[k2]    ),
				.CEB  ( !port1_enable_i[k2]  ),
				.WEB  ( !(port1_write_enable_i[k2] & port1_enable_i[k2])  ),
				.Q    ( port1_read_data_array[k2]    )
			);
		end
	endgenerate

endmodule




