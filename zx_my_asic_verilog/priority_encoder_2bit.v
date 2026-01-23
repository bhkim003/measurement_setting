module priority_encoder_2bit (
    input wire [1:0] hot_vector_i,
    output reg idx_o,
    output reg valid_o
);
    always @ (*) begin
        casex (hot_vector_i)
            2'bx1: begin idx_o = 1'b0; valid_o = 1'b1; end
            2'b10: begin idx_o = 1'b1; valid_o = 1'b1; end
            default:     begin idx_o = 1'b0; valid_o = 1'b0; end
        endcase
    end
endmodule