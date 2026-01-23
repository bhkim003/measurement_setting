module priority_encoder_5bit (
    input wire [4:0] hot_vector_i,
    output reg [2:0] idx_o,
    output reg valid_o
);
    always @ (*) begin
        casex (hot_vector_i)
            5'bxxxx1: begin idx_o = 3'd0; valid_o = 1'b1; end
            5'bxxx10: begin idx_o = 3'd1; valid_o = 1'b1; end
            5'bxx100: begin idx_o = 3'd2; valid_o = 1'b1; end
            5'bx1000: begin idx_o = 3'd3; valid_o = 1'b1; end
            5'b10000: begin idx_o = 3'd4; valid_o = 1'b1; end
            default:     begin idx_o = 3'd0; valid_o = 1'b0; end
        endcase
    end
endmodule