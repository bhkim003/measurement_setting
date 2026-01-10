//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kim Beomseok
// Contact: kimbss470@snu.ac.kr
// 
// Create Date: 24/07/2024 
// Design Name: PseudoChip which emulates DRAM read/write
// Module Name: pseudoChip
// Project Name: 2024TapeOut
// Target Devices: XEM7360-K160T
// Tool versions: 2024.1
// Description: 
//
//////////////////////////////////////////////////////////////////////////////////

module pseudoChip (
    input  wire         clk,
    input  wire         rstn,
    input  wire         single_rate,   // 0: dual-rate , 1: single-rate
    input  wire         start,
    input  wire         start_store_byte4,
    output wire         done,
    output wire         load_or_store,   
    output wire         store_byte4,   
    inout  wire [127:0] data,
    output wire [ 11:0] axaddr_and_axlen,
    output wire         axvalid,
    input  wire         axready,
    input  wire         rvalid_or_wready,
    output wire         rready_or_wvalid
);


    //************************************************************
    // I/O 
    //************************************************************

    localparam LOAD  = 1'b0;
    localparam STORE = 1'b1;

    wire io_T;
    wire [127:0] data_in;
    wire [127:0] data_out;

    assign io_T = load_or_store;
    assign data = (io_T==STORE) ? data_out : {128{1'bz}};
    assign data_in = (io_T==LOAD) ? data : {128{1'b0}};


    //************************************************************
    // Reg & Wires
    //************************************************************

    // input
    reg         buf0_start;
    reg         buf0_start_store_byte4;
    reg         buf0_single_rate;
    reg [127:0] buf0_data_in_pos;
    reg [127:0] buf0_data_in_neg;
    reg         buf0_arready;
    reg         buf0_awready;
    reg         buf0_rvalid;
    reg         buf0_wready;


    reg         buf1_start;
    reg         buf1_start_store_byte4;
    reg         buf1_single_rate;
    reg [255:0] buf1_data_in;
    reg         buf1_arready;
    reg         buf1_awready;
    reg         buf1_rvalid;
    reg         buf1_wready;


    // output
    reg         buf0_done;
    reg         buf0_load_or_store;
    reg         buf0_store_byte4;
    reg [255:0] buf0_data_out;
    reg [ 11:0] buf0_axaddr_and_axlen;
    reg         buf0_axvalid;
    reg         buf0_rready;
    reg         buf0_wvalid;

  
    reg         buf1_done;
    reg [127:0] buf1_data_out_pos;
    reg [127:0] buf1_data_out_neg;
    reg         buf1_wvalid;


    reg [  1:0] ax_delay;     // delay for axaddr & axlen transfer


    // input to core
    wire         core_start;
    wire         core_start_store_byte4;
    wire         core_single_rate;
    wire [255:0] core_data_in;
    wire         core_arready;
    wire         core_awready;
    wire         core_rvalid;
    wire         core_wready;

    // output from core
    wire         core_done;
    wire         core_load_or_store;
    wire         core_store_byte4;
    wire [255:0] core_data_out;
    wire [ 27:0] core_axaddr;
    wire [  7:0] core_axlen;
    wire [ 27:0] core_araddr;
    wire [  7:0] core_arlen;
    wire [ 27:0] core_awaddr;
    wire [  7:0] core_awlen;
    wire         core_pseudo_arvalid;
    wire         core_pseudo_awvalid;
    wire         core_rready;
    wire         core_wvalid;


    // output to off-hip 
    assign done                  = buf1_done;
    assign load_or_store         = buf0_load_or_store;
    assign store_byte4           = buf0_store_byte4;
    // assign data_out              = buf0_single_rate ? buf1_data_out_pos : (clk ? buf1_data_out_pos : buf1_data_out_neg);
    assign data_out              = buf1_data_out_pos;
    assign axaddr_and_axlen      = buf0_axaddr_and_axlen;
    assign axvalid               = buf0_axvalid;
    assign rready_or_wvalid      = (buf0_load_or_store == LOAD) ? buf0_rready  : (buf0_single_rate ? buf1_wvalid : buf0_wvalid);
 


    // into core
    assign core_start             = buf1_start;
    assign core_start_store_byte4 = buf1_start_store_byte4;
    assign core_single_rate       = buf1_single_rate;
    assign core_data_in           = buf1_data_in;
    assign core_arready           = buf1_arready;
    assign core_awready           = buf1_awready;
    assign core_rvalid            = buf1_rvalid;
    assign core_wready            = buf1_wready;


    //************************************************************
    // Buffer Stages
    //************************************************************

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            // input - stage0
            buf0_start            <= 1'b0;
            buf0_start_store_byte4<= 1'b0;
            buf0_single_rate      <= 1'b0;
            buf0_data_in_pos      <= 128'd0;
            buf0_arready          <= 1'b0;
            buf0_awready          <= 1'b0;
            buf0_rvalid           <= 1'b0;
            buf0_wready           <= 1'b0;

            // input - stage1
            buf1_start            <= 1'b0;
            buf1_start_store_byte4<= 1'b0;
            buf1_single_rate      <= 1'b0;
            buf1_data_in          <= 256'd0;
            buf1_arready          <= 1'b0;
            buf1_awready          <= 1'b0;
            buf1_rvalid           <= 1'b0;
            buf1_wready           <= 1'b0;

            // output - stage0
            buf0_done             <= 1'b0;
            buf0_load_or_store    <= LOAD;
            buf0_store_byte4      <= 1'b0;
            buf0_data_out         <= 256'd0;
            buf0_axaddr_and_axlen <= 12'd0;
            buf0_axvalid          <= 1'b0;
            buf0_rready           <= 1'b0;
            buf0_wvalid           <= 1'b0;

            // output - stage1
            buf1_done             <= 1'b0;
            buf1_data_out_pos     <= 128'd0;
            buf1_wvalid           <= 1'b0;

            // delay for axaddr & axlen transfer
            ax_delay              <= 2'd0;
        end
        else begin
            // input - stage0
            buf0_start            <= start;
            buf0_start_store_byte4<= start_store_byte4;
            buf0_single_rate      <= single_rate;
            buf0_data_in_pos      <= data_in;
            buf0_arready          <= (buf0_load_or_store == LOAD ) ? axready : 1'b0;
            buf0_awready          <= (buf0_load_or_store == STORE) ? axready : 1'b0;
            buf0_rvalid           <= (buf0_load_or_store == LOAD ) ? rvalid_or_wready : 1'b0;
            buf0_wready           <= (buf0_load_or_store == STORE) ? rvalid_or_wready : 1'b0;
 

            // input - stage1
            buf1_start            <= buf0_start;
            buf1_start_store_byte4<= buf0_start_store_byte4;
            buf1_single_rate      <= buf0_single_rate;
  
            if (buf0_single_rate) begin
                if (buf0_rvalid==0) buf1_data_in[127:  0] <= buf0_data_in_pos;
                if (buf0_rvalid==1) buf1_data_in[255:128] <= buf0_data_in_pos;
            end
            else begin
                // buf1_data_in      <= {buf0_data_in_neg, buf0_data_in_pos};    // MSB from neg_ff
            end

            buf1_arready          <= buf0_arready;
            buf1_awready          <= buf0_awready;
            buf1_rvalid           <= buf0_rvalid;
            buf1_wready           <= buf0_wready; 


            // output - stage0
            buf0_done             <= core_done;
            buf0_load_or_store    <= core_load_or_store;
            buf0_store_byte4      <= core_store_byte4;
            buf0_data_out         <= core_data_out;         // 256b
            if (core_pseudo_arvalid || core_pseudo_awvalid) begin
                buf0_axaddr_and_axlen <= core_axaddr[11:0];
                ax_delay              <= ax_delay + 2'd1;
            end
            else if (ax_delay == 2'd1) begin
                buf0_axaddr_and_axlen <= core_axaddr[23:12];
                ax_delay              <= ax_delay + 2'd1;
            end
            else if (ax_delay == 2'd2) begin
                buf0_axaddr_and_axlen <= {core_axlen, core_axaddr[27:24]};
                ax_delay              <= 2'd0;
            end
            buf0_axvalid          <= core_pseudo_arvalid || core_pseudo_awvalid;
            buf0_rready           <= core_rready;
            buf0_wvalid           <= core_wvalid;

            // output - stage1
            buf1_done             <= buf0_done;
            if (buf0_single_rate) begin
                if (buf0_wvalid==0) buf1_data_out_pos <= buf0_data_out[127:  0];   
                if (buf0_wvalid==1) buf1_data_out_pos <= buf0_data_out[255:128];   
            end
            else begin
                buf1_data_out_pos <= buf0_data_out[255:128];   // MSB to pos_ff
            end

            buf1_wvalid           <= buf0_wvalid;
        end
    end

    // /*  Neg-edge triggered FF  */
    // always @(negedge clk or negedge rstn) begin
    //     if (~rstn) begin
    //         buf0_data_in_neg  <= 128'd0;
    //         buf1_data_out_neg <= 128'd0;
    //     end
    //     else begin
    //         buf0_data_in_neg  <= data_in; 
    //         buf1_data_out_neg <= buf0_data_out[127:0];
    //     end
    // end


    //************************************************************
    // Instantiate Core
    //************************************************************
    assign core_axlen  = (core_load_or_store == LOAD) ? core_arlen  : core_awlen;
    assign core_axaddr = (core_load_or_store == LOAD) ? core_araddr  : core_awaddr;

    pseudoCore u_pseudoCore (
        .clk               (clk                    ),
        .rstn              (rstn                   ),
 
        .single_rate       (core_single_rate       ),
        .start             (core_start             ),
        .start_store_byte4 (core_start_store_byte4 ),
        .done              (core_done              ),
 
        .load_or_store     (core_load_or_store     ),
        .store_byte4       (core_store_byte4       ),
 
        .axi_araddr        (core_araddr            ),
        .axi_arlen         (core_arlen             ),
        .axi_arvalid       (core_pseudo_arvalid    ),
        .axi_arready       (core_arready           ),
        .axi_rvalid        (core_rvalid            ),
        .axi_rready        (core_rready            ),
        .axi_rdata         (core_data_in           ),
 
        .axi_awaddr        (core_awaddr            ),
        .axi_awlen         (core_awlen             ),
        .axi_awvalid       (core_pseudo_awvalid    ),
        .axi_awready       (core_awready           ),
        .axi_wvalid        (core_wvalid            ),
        .axi_wready        (core_wready            ),
        .axi_wdata         (core_data_out          )
    );
    
    
endmodule
