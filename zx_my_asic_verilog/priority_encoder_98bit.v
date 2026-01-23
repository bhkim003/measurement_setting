module priority_encoder_98bit (
    input  wire [97:0] hot_vector_i,
    output [6:0]   idx_o,   // log2(103) ≈ 7bit
    output valid_o
);

    wire [97:0] hot_vector_temp;
    assign hot_vector_temp = hot_vector_i;

    wire [2:0] sub_idx [0:12];
    wire [12:0] sub_valid;

    genvar i;
    generate
        for (i = 0; i < 12; i = i + 1) begin : gen_priority_encoder_8bit
            priority_encoder_8bit u_priority_encoder_8bit (
                .hot_vector_i(hot_vector_temp[8*i +: 8]),
                .idx_o(sub_idx[i]),
                .valid_o(sub_valid[i])
            );
        end
    endgenerate


    // Stage 1-2: 2bit priority encoder for the last 2 bits
    priority_encoder_2bit u_priority_encoder_2bit (
        .hot_vector_i(hot_vector_temp[8*12 +: 2]),
        .idx_o(sub_idx[12][0]),
        .valid_o(sub_valid[12])
    );
    assign sub_idx[12][1] = 1'b0; // Last 2 bits only need 1 bit index
    assign sub_idx[12][2] = 1'b0; // Last 2 bits only need 1 bit index


    // Stage 2: 13bit priority encoder
    wire [3:0] high_idx;  // log2(13)=4bit
    wire       high_valid;

    priority_encoder_13bit u_priority_encoder_13bit (
        .hot_vector_i(sub_valid),
        .idx_o(high_idx),
        .valid_o(high_valid)
    );

    // Final output
    assign idx_o = {high_idx, sub_idx[high_idx]};
    assign valid_o = high_valid;

endmodule
