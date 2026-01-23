module priority_encoder_20bit (
    input  wire [19:0] hot_vector_i,
    output [4:0]   idx_o, 
    output valid_o
);

    wire [1:0] sub_idx [0:4];
    wire [4:0] sub_valid;

    genvar i;
    generate
        for (i = 0; i < 5; i = i + 1) begin : gen_priority_encoder_4bit
            priority_encoder_4bit u_priority_encoder_4bit (
                .hot_vector_i(hot_vector_i[i*4 +: 4]),
                .idx_o(sub_idx[i]),
                .valid_o(sub_valid[i])
            );
        end
    endgenerate

    // Stage 2: 5bit priority encoder
    wire [2:0] high_idx;  // log2(5) ≈ 3bit
    wire       high_valid;

    priority_encoder_5bit u_priority_encoder_5bit (
        .hot_vector_i(sub_valid),
        .idx_o(high_idx),
        .valid_o(high_valid)
    );

    // Final output
    assign idx_o   = {high_idx, sub_idx[high_idx]};
    assign valid_o = high_valid;

endmodule