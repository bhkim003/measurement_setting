module reorderingUnit (
    input          clk,
    input          rstn,
    input          start,

    output [ 27:0] axi_awaddr,
    output [  7:0] axi_awlen,
    output         axi_awvalid,
    input          axi_awready,
    input          axi_wready,
    output         axi_wvalid,
    output [255:0] axi_wdata,

    output [ 27:0] axi_araddr,
    output [  7:0] axi_arlen,
    output         axi_arvalid,
    input          axi_arready,
    input          axi_rvalid,
    output         axi_rready,
    input  [255:0] axi_rdata
);

    // N_new
    // old_addr
    // new_addr
    // addr_
    // 

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin

        end
        else begin

        end
    end
    
endmodule