module aer_encoder_layer2_slice10_dual_mode (
		input clk,
		input reset_n,
		
		input start_i,
		input [9:0] encoding_on_i,
		input [199:0] hot_vector_i,
		input [3:0] error_class_i,

		output reg [10*8-1:0] aer_o,
		output reg [9:0] valid_o,

		output valid_ffmode_o,
		output reg [9:0] priority_encoder_valid_o,

		output [7:0] group0_aer_o,
		output group0_valid_o
	);

	reg [9:0] encoding_on;

	wire [199:0] hot_vector_200bit;
	assign hot_vector_200bit = hot_vector_i;

	reg [19:0] hot_vector_slice10 [0:9];
	genvar j,k;
	generate
		for (j = 0; j < 10; j = j + 1) begin : gen_hot_vector_slice10
			for (k = 0; k < 20; k = k + 1) begin : gen_hot_vector_slice10_inside
				always @ (*) begin
					hot_vector_slice10[j][k] = hot_vector_200bit[k*10 + j];
				end
			end
		end
	endgenerate

    reg [19:0] hot_vector [0:9];
    reg [19:0] n_hot_vector [0:9];
	reg [19:0] hot_vector_maked [0:9];

	reg [7:0] aer [0:9];
	wire [7:0] n_aer [0:9];
	reg [4:0] aer_divide_ten [0:9];
	wire [4:0] n_aer_divide_ten [0:9];
	reg [9:0] valid;
	wire [9:0] n_valid;

    wire [4:0] priority_encoder_idx [0:9];
    wire [9:0] priority_encoder_valid;

	reg [3:0] error_class_save;
	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			error_class_save <= 0;
		end else begin
			if (start_i) begin
				error_class_save <= error_class_i;
			end
		end
	end


	genvar q;
	generate
		for (q = 0; q < 10; q = q + 1) begin : gen_aer_slice_control
			always @(posedge clk or negedge reset_n) begin
				if (!reset_n) begin
					hot_vector[q] <= 0;
					aer[q] <= 0;
					aer_divide_ten[q] <= 0;
					valid[q] <= 0;
				end else begin
					hot_vector[q] <= n_hot_vector[q];
					aer[q] <= n_aer[q];
					aer_divide_ten[q] <= n_aer_divide_ten[q];
					valid[q] <= n_valid[q];
				end
			end
			always @ (*) begin
				n_hot_vector[q] = hot_vector[q];
				if (start_i) begin
					n_hot_vector[q] = hot_vector_slice10[q];
				end else if (encoding_on[q]) begin
					if (valid[q]) begin
						n_hot_vector[q] = hot_vector_maked[q];
					end
				end
			end
			assign n_aer[q] = 10*priority_encoder_idx[q] + q;
			assign n_aer_divide_ten[q] = priority_encoder_idx[q];
			assign n_valid[q] = priority_encoder_valid[q];
		end
	endgenerate



	genvar i,w;
	generate
		for (w = 0; w < 10; w = w + 1) begin : gen_hot_vector_maked_all_slice
			for (i = 0; i < 20; i = i + 1) begin : gen_hot_vector_maked
				always @ (*) begin
					if (i == aer_divide_ten[w] && valid[w]) begin 
						hot_vector_maked[w][i] = 1'b0;
					end else begin
						hot_vector_maked[w][i] = hot_vector[w][i];
					end
				end
			end
		end
	endgenerate
	
	genvar l;
	generate
		for (l = 0; l < 10; l = l + 1) begin : gen_priority_encoder_20bit
			priority_encoder_20bit u_priority_encoder_20bit (
				.hot_vector_i (n_hot_vector[l]),
				.idx_o    (priority_encoder_idx[l]),
				.valid_o  (priority_encoder_valid[l])
			);
		end
	endgenerate

	always @ (*) begin
		aer_o = {aer[9], aer[8], aer[7], aer[6], aer[5], aer[4], aer[3], aer[2], aer[1], aer[0]};
		valid_o = {valid[9], valid[8], valid[7], valid[6], valid[5], valid[4], valid[3], valid[2], valid[1], valid[0]};
		encoding_on = {encoding_on_i[9], encoding_on_i[8], encoding_on_i[7], encoding_on_i[6], encoding_on_i[5], encoding_on_i[4], encoding_on_i[3], encoding_on_i[2], encoding_on_i[1], encoding_on_i[0]};
		priority_encoder_valid_o = {priority_encoder_valid[9], priority_encoder_valid[8], priority_encoder_valid[7], priority_encoder_valid[6], priority_encoder_valid[5], priority_encoder_valid[4], priority_encoder_valid[3], priority_encoder_valid[2], priority_encoder_valid[1], priority_encoder_valid[0]};
		case (error_class_save)
			1: begin
				aer_o = {aer[8], aer[7], aer[6], aer[5], aer[4], aer[3], aer[2], aer[1], aer[0], aer[9]};
				valid_o = {valid[8], valid[7], valid[6], valid[5], valid[4], valid[3], valid[2], valid[1], valid[0], valid[9]};
				encoding_on = {encoding_on_i[0], encoding_on_i[9], encoding_on_i[8], encoding_on_i[7], encoding_on_i[6], encoding_on_i[5], encoding_on_i[4], encoding_on_i[3], encoding_on_i[2], encoding_on_i[1]};
				priority_encoder_valid_o = {priority_encoder_valid[8], priority_encoder_valid[7], priority_encoder_valid[6], priority_encoder_valid[5], priority_encoder_valid[4], priority_encoder_valid[3], priority_encoder_valid[2], priority_encoder_valid[1], priority_encoder_valid[0], priority_encoder_valid[9]};
			end
			2: begin
				aer_o = {aer[7], aer[6], aer[5], aer[4], aer[3], aer[2], aer[1], aer[0], aer[9], aer[8]};
				valid_o = {valid[7], valid[6], valid[5], valid[4], valid[3], valid[2], valid[1], valid[0], valid[9], valid[8]};
				encoding_on = {encoding_on_i[1], encoding_on_i[0], encoding_on_i[9], encoding_on_i[8], encoding_on_i[7], encoding_on_i[6], encoding_on_i[5], encoding_on_i[4], encoding_on_i[3], encoding_on_i[2]};
				priority_encoder_valid_o = {priority_encoder_valid[7], priority_encoder_valid[6], priority_encoder_valid[5], priority_encoder_valid[4], priority_encoder_valid[3], priority_encoder_valid[2], priority_encoder_valid[1], priority_encoder_valid[0], priority_encoder_valid[9], priority_encoder_valid[8]};
			end
			3: begin
				aer_o = {aer[6], aer[5], aer[4], aer[3], aer[2], aer[1], aer[0], aer[9], aer[8], aer[7]};
				valid_o = {valid[6], valid[5], valid[4], valid[3], valid[2], valid[1], valid[0], valid[9], valid[8], valid[7]};
				encoding_on = {encoding_on_i[2], encoding_on_i[1], encoding_on_i[0], encoding_on_i[9], encoding_on_i[8], encoding_on_i[7], encoding_on_i[6], encoding_on_i[5], encoding_on_i[4], encoding_on_i[3]};
				priority_encoder_valid_o = {priority_encoder_valid[6], priority_encoder_valid[5], priority_encoder_valid[4], priority_encoder_valid[3], priority_encoder_valid[2], priority_encoder_valid[1], priority_encoder_valid[0], priority_encoder_valid[9], priority_encoder_valid[8], priority_encoder_valid[7]};
			end
			4: begin
				aer_o = {aer[5], aer[4], aer[3], aer[2], aer[1], aer[0], aer[9], aer[8], aer[7], aer[6]};
				valid_o = {valid[5], valid[4], valid[3], valid[2], valid[1], valid[0], valid[9], valid[8], valid[7], valid[6]};
				encoding_on = {encoding_on_i[3], encoding_on_i[2], encoding_on_i[1], encoding_on_i[0], encoding_on_i[9], encoding_on_i[8], encoding_on_i[7], encoding_on_i[6], encoding_on_i[5], encoding_on_i[4]};
				priority_encoder_valid_o = {priority_encoder_valid[5], priority_encoder_valid[4], priority_encoder_valid[3], priority_encoder_valid[2], priority_encoder_valid[1], priority_encoder_valid[0], priority_encoder_valid[9], priority_encoder_valid[8], priority_encoder_valid[7], priority_encoder_valid[6]};
			end
			5: begin
				aer_o = {aer[4], aer[3], aer[2], aer[1], aer[0], aer[9], aer[8], aer[7], aer[6], aer[5]};
				valid_o = {valid[4], valid[3], valid[2], valid[1], valid[0], valid[9], valid[8], valid[7], valid[6], valid[5]};
				encoding_on = {encoding_on_i[4], encoding_on_i[3], encoding_on_i[2], encoding_on_i[1], encoding_on_i[0], encoding_on_i[9], encoding_on_i[8], encoding_on_i[7], encoding_on_i[6], encoding_on_i[5]};
				priority_encoder_valid_o = {priority_encoder_valid[4], priority_encoder_valid[3], priority_encoder_valid[2], priority_encoder_valid[1], priority_encoder_valid[0], priority_encoder_valid[9], priority_encoder_valid[8], priority_encoder_valid[7], priority_encoder_valid[6], priority_encoder_valid[5]};
			end
			6: begin
				aer_o = {aer[3], aer[2], aer[1], aer[0], aer[9], aer[8], aer[7], aer[6], aer[5], aer[4]};
				valid_o = {valid[3], valid[2], valid[1], valid[0], valid[9], valid[8], valid[7], valid[6], valid[5], valid[4]};
				encoding_on = {encoding_on_i[5], encoding_on_i[4], encoding_on_i[3], encoding_on_i[2], encoding_on_i[1], encoding_on_i[0], encoding_on_i[9], encoding_on_i[8], encoding_on_i[7], encoding_on_i[6]};
				priority_encoder_valid_o = {priority_encoder_valid[3], priority_encoder_valid[2], priority_encoder_valid[1], priority_encoder_valid[0], priority_encoder_valid[9], priority_encoder_valid[8], priority_encoder_valid[7], priority_encoder_valid[6], priority_encoder_valid[5], priority_encoder_valid[4]};
			end
			7: begin
				aer_o = {aer[2], aer[1], aer[0], aer[9], aer[8], aer[7], aer[6], aer[5], aer[4], aer[3]};
				valid_o = {valid[2], valid[1], valid[0], valid[9], valid[8], valid[7], valid[6], valid[5], valid[4], valid[3]};
				encoding_on = {encoding_on_i[6], encoding_on_i[5], encoding_on_i[4], encoding_on_i[3], encoding_on_i[2], encoding_on_i[1], encoding_on_i[0], encoding_on_i[9], encoding_on_i[8], encoding_on_i[7]};
				priority_encoder_valid_o = {priority_encoder_valid[2], priority_encoder_valid[1], priority_encoder_valid[0], priority_encoder_valid[9], priority_encoder_valid[8], priority_encoder_valid[7], priority_encoder_valid[6], priority_encoder_valid[5], priority_encoder_valid[4], priority_encoder_valid[3]};
			end
			8: begin
				aer_o = {aer[1], aer[0], aer[9], aer[8], aer[7], aer[6], aer[5], aer[4], aer[3], aer[2]};
				valid_o = {valid[1], valid[0], valid[9], valid[8], valid[7], valid[6], valid[5], valid[4], valid[3], valid[2]};
				encoding_on = {encoding_on_i[7], encoding_on_i[6], encoding_on_i[5], encoding_on_i[4], encoding_on_i[3], encoding_on_i[2], encoding_on_i[1], encoding_on_i[0], encoding_on_i[9], encoding_on_i[8]};
				priority_encoder_valid_o = {priority_encoder_valid[1], priority_encoder_valid[0], priority_encoder_valid[9], priority_encoder_valid[8], priority_encoder_valid[7], priority_encoder_valid[6], priority_encoder_valid[5], priority_encoder_valid[4], priority_encoder_valid[3], priority_encoder_valid[2]};
			end
			9: begin
				aer_o = {aer[0], aer[9], aer[8], aer[7], aer[6], aer[5], aer[4], aer[3], aer[2], aer[1]};
				valid_o = {valid[0], valid[9], valid[8], valid[7], valid[6], valid[5], valid[4], valid[3], valid[2], valid[1]};
				encoding_on = {encoding_on_i[8], encoding_on_i[7], encoding_on_i[6], encoding_on_i[5], encoding_on_i[4], encoding_on_i[3], encoding_on_i[2], encoding_on_i[1], encoding_on_i[0], encoding_on_i[9]};
				priority_encoder_valid_o = {priority_encoder_valid[0], priority_encoder_valid[9], priority_encoder_valid[8], priority_encoder_valid[7], priority_encoder_valid[6], priority_encoder_valid[5], priority_encoder_valid[4], priority_encoder_valid[3], priority_encoder_valid[2], priority_encoder_valid[1]};
			end
		endcase
	end
	
	assign group0_aer_o = aer[0];
	assign group0_valid_o = valid[0];
	assign valid_ffmode_o = (valid != 0);
endmodule