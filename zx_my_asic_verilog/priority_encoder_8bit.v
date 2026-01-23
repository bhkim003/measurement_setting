module priority_encoder_8bit (
    input wire [7:0] hot_vector_i,
    output reg [2:0] idx_o,
    output reg valid_o
);
    always @ (*) begin
        casex (hot_vector_i)
            8'bxxxxxxx1: begin idx_o = 3'd0; valid_o = 1'b1; end
            8'bxxxxxx10: begin idx_o = 3'd1; valid_o = 1'b1; end
            8'bxxxxx100: begin idx_o = 3'd2; valid_o = 1'b1; end
            8'bxxxx1000: begin idx_o = 3'd3; valid_o = 1'b1; end
            8'bxxx10000: begin idx_o = 3'd4; valid_o = 1'b1; end
            8'bxx100000: begin idx_o = 3'd5; valid_o = 1'b1; end
            8'bx1000000: begin idx_o = 3'd6; valid_o = 1'b1; end
            8'b10000000: begin idx_o = 3'd7; valid_o = 1'b1; end
            default:     begin idx_o = 3'd0; valid_o = 1'b0; end
        endcase
    end
endmodule