module example(
        input sys_clk_p,
        input reset_n,
        input [9983:0] input_vec,
        input [9983:0] input_vec2,
        input [9983:0] input_vec3,
        output reg [9983:0] output_vec,
        output reg [9983:0] output_vec2,
        output reg [9983:0] output_vec3
    );


    always @(posedge sys_clk_p) begin
        if(reset_n == 0) begin
            output_vec <= 0;
            output_vec2 <= 0;
            output_vec3 <= 0;
        end else begin
            output_vec <= input_vec;
            output_vec2 <= input_vec2;
            output_vec3 <= input_vec3;
        end
    end
endmodule
