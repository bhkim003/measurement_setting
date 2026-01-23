module priority_encoder_4bit (
    input wire [3:0] hot_vector_i,
    output reg [1:0] idx_o,
    output reg valid_o
);
    always @ (*) begin
        casex (hot_vector_i)
            4'bxxx1: begin idx_o = 2'd0; valid_o = 1'b1; end
            4'bxx10: begin idx_o = 2'd1; valid_o = 1'b1; end
            4'bx100: begin idx_o = 2'd2; valid_o = 1'b1; end
            4'b1000: begin idx_o = 2'd3; valid_o = 1'b1; end
            default:     begin idx_o = 2'd0; valid_o = 1'b0; end
        endcase
    end
endmodule