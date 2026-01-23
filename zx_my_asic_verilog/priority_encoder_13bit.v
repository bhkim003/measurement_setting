module priority_encoder_13bit (
    input wire [12:0] hot_vector_i,
    output reg [3:0] idx_o,
    output reg valid_o
);
    always @ (*) begin
        casex (hot_vector_i)
            13'bxxxxxxxxxxxx1: begin idx_o = 4'd0; valid_o = 1'b1; end
            13'bxxxxxxxxxxx10: begin idx_o = 4'd1; valid_o = 1'b1; end
            13'bxxxxxxxxxx100: begin idx_o = 4'd2; valid_o = 1'b1; end
            13'bxxxxxxxxx1000: begin idx_o = 4'd3; valid_o = 1'b1; end
            13'bxxxxxxxx10000: begin idx_o = 4'd4; valid_o = 1'b1; end
            13'bxxxxxxx100000: begin idx_o = 4'd5; valid_o = 1'b1; end
            13'bxxxxxx1000000: begin idx_o = 4'd6; valid_o = 1'b1; end
            13'bxxxxx10000000: begin idx_o = 4'd7; valid_o = 1'b1; end
            13'bxxxx100000000: begin idx_o = 4'd8; valid_o = 1'b1; end
            13'bxxx1000000000: begin idx_o = 4'd9; valid_o = 1'b1; end
            13'bxx10000000000: begin idx_o = 4'd10; valid_o = 1'b1; end
            13'bx100000000000: begin idx_o = 4'd11; valid_o = 1'b1; end
            13'b1000000000000: begin idx_o = 4'd12; valid_o = 1'b1; end
            default:     begin idx_o = 4'd0; valid_o = 1'b0; end
        endcase
    end
endmodule