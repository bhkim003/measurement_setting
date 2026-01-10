//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kim Beomseok
// Contact: kimbss470@snu.ac.kr
// 
// Create Date: 18/07/2024 
// Design Name: OpalKelly frontpanel for USB3 in Verilog
// Module Name: chipInterface 
// Project Name: 2024TapeOut
// Target Devices: XEM7360-K160T
// Tool versions: 2024.1
// Description: - Buffering stages for handling time-muxed axaddr&axlen and 
//                single-rate I/O
//              - Convert AXI signals cross chip <-> MIG domains
//////////////////////////////////////////////////////////////////////////////////
`include "params.vh"
module chipInterface(
    input  wire         clk_for_chip,
    input  wire         clk_for_chip_in,
    input  wire         clk_for_chip_out,
    input  wire         mig_clk,      
    input  wire         okClk,
    input  wire         rstn,

    /* okFP <-> Chip */
    // clk_for_chip domain
    input  wire         start_network,
    output wire         start_layer,
    output wire         start_store_byte4,   // only used for loopback test
    input  wire         single_rate,    
    input  wire [  5:0] n_layers,
    
    output wire         done_network,
    input  wire         done_layer,
    output wire         done_layer_buf,             // goto okFP domain, synchronized with clk_for_chip_out
    output wire [ 30:0] clk_cnt,
    output wire [ 31:0] chip_axi_read_delay_out,    // check delay of AXI-read

    /* Chip <-> MIG */
    // clk_for_chip domain
    input  wire         load_or_store,
    input  wire         store_byte4,
    inout  wire [127:0] data,
    input  wire [ 11:0] axaddr_and_axlen,
    input  wire         axvalid,
    output wire         axready,
    output wire         rvalid_or_wready,
    input  wire         rready_or_wvalid,

    // mig_clk domain 
    output wire         mig_store_byte4,
    output wire [ 27:0] mig_axi_awaddr,
    output wire [  7:0] mig_axi_awlen,
    output wire         mig_axi_awvalid,
    input  wire         mig_axi_awready,
    input  wire         mig_axi_wready,
    output wire         mig_axi_wvalid,
    output wire [255:0] mig_axi_wdata,
    output wire [ 27:0] mig_axi_araddr,
    output wire [  7:0] mig_axi_arlen,
    output wire         mig_axi_arvalid,
    input  wire         mig_axi_arready,
    input  wire         mig_axi_rvalid,    // toggled when single_rate = 1'b1
    input  wire         mig_axi_rvalid_tmp,
    output wire         mig_axi_rready,
    input  wire [255:0] mig_axi_rdata,

    /* Debug */
    output reg  [  7:0] start_cnt,
    output reg  [ 31:0] arvalid_cnt,
    output reg  [  7:0] arready_cnt,
    output reg  [ 31:0] rvalid_cnt,

    output reg  [ 31:0] awvalid_cnt,
    output reg  [  7:0] awready_cnt,
    output reg  [ 31:0] wvalid_cnt,

    output reg  [ 27:0] araddr_hist [0:63],
    output reg  [  7:0] arlen_hist  [0:63],
    output reg  [255:0] rdata_hist  [0:63],
    output reg  [ 27:0] awaddr_hist [0:63],
    output reg  [  7:0] awlen_hist  [0:63],
    // output reg  [255:0] wdata_hist  [0:63]

    output reg  [  3:0] ttf_axvalid,   // #cycles from start_layer activation to axvalid activation

    /* FIFO for cycle level debugging of fpga2chip signals */
    input  wire         debug_fifo_fpga2chip_read,
    output wire         debug_fifo_fpga2chip_rd_en_out,
    input  wire         pipe_out_ready_debug_fpga2chip,
    output wire         pipe_out_valid_debug_fpga2chip,
    output wire [ 31:0] pipe_dout_debug_fpga2chip,

    /* FIFO for cycle level debugging of chip2fpga signals */
    input  wire         debug_fifo_chip2fpga_read,
    output wire         debug_fifo_chip2fpga_rd_en_out,
    input  wire         pipe_out_ready_debug_chip2fpga,
    output wire         pipe_out_valid_debug_chip2fpga,
    output wire [ 31:0] pipe_dout_debug_chip2fpga,

    /* FIFO for axaddr and axlen handshaking debugging */
    input  wire         debug_fifo_axaddr_read,
    output wire         debug_fifo_axaddr_rd_en_out,
    input  wire         pipe_out_ready_debug_axaddr,
    output wire         pipe_out_valid_debug_axaddr,
    output wire [ 31:0] pipe_dout_debug_axaddr,

    ////
    output wire         debug_fifo_axaddr_valid_debug,
    output wire         debug_fifo_axaddr_empty_debug,
    output wire         pipe_out_ready_debug_axaddr_debug,
    output wire         pipe_out_valid_debug_axaddr_debug,
    ///

    /* FIFO for rdata transfer debugging */
    input  wire         debug_fifo_rdata_read,
    output wire         debug_fifo_rdata_rd_en_out,
    input  wire         pipe_out_ready_debug_rdata,
    output wire         pipe_out_valid_debug_rdata,
    output wire [ 31:0] pipe_dout_debug_rdata,

    /* FIFO for wdata transfer debugging */
    input  wire         debug_fifo_wdata_read,
    output wire         debug_fifo_wdata_rd_en_out,
    input  wire         pipe_out_ready_debug_wdata,
    output wire         pipe_out_valid_debug_wdata,
    output wire [ 31:0] pipe_dout_debug_wdata,

    /* Debug of regular FIFOs btw chip <-> MIG */
    output wire         araddr_fifo_rd_en_debug,
    output wire         araddr_fifo_wr_en_debug,
    output wire         araddr_fifo_valid_debug, 
    output wire         araddr_fifo_empty_debug, 
    output wire         araddr_fifo_full_debug, 
    output wire         araddr_fifo_prog_full_debug, 
       
    output wire         awaddr_fifo_rd_en_debug,
    output wire         awaddr_fifo_wr_en_debug,
    output wire         awaddr_fifo_valid_debug, 
    output wire         awaddr_fifo_empty_debug, 
    output wire         awaddr_fifo_full_debug, 
    output wire         awaddr_fifo_prog_full_debug, 
       
    output wire         rdata_fifo_rd_en_debug,
    output wire         rdata_fifo_wr_en_debug,
    output wire         rdata_fifo_valid_debug, 
    output wire         rdata_fifo_empty_debug, 
    output wire         rdata_fifo_full_debug, 
    output wire         rdata_fifo_prog_full_debug, 
       
    output wire         wdata_fifo_rd_en_debug,
    output wire         wdata_fifo_wr_en_debug,
    output wire         wdata_fifo_valid_debug, 
    output wire         wdata_fifo_empty_debug, 
    output wire         wdata_fifo_full_debug, 
    output wire         wdata_fifo_prog_full_debug
);

    wire w_start_layer;
    wire w_axready;
    wire w_rvalid_or_wready;


    //************************************************************
    // Buffering Stages & Decoding AXI
    //************************************************************

    localparam LOAD  = 1'b0;
    localparam STORE = 1'b1;
    localparam FIFO_HEADROOM = 8'd20;


    /*  Modeling IO  */ 
    // wire io_T;
    wire io_T;
    wire io_T_;
    wire [127:0] wdata;
    wire [127:0] rdata;


    /* Decode in/out port singal (clk_for_chip domain) */ 
    wire [11:0]   chip_axi_axaddr_and_axlen;     

    wire          chip_axi_awvalid;
    wire          chip_axi_awready;
    wire [127:0]  chip_axi_wdata;
    wire          chip_axi_wvalid;
    wire          chip_axi_wready;

    wire          chip_axi_arvalid;
    wire          chip_axi_arready;
    wire [127:0]  chip_axi_rdata;      
    wire          chip_axi_rvalid;
    wire          chip_axi_rready;


    /* AXI signal (buffer stage <-> FIFO, clk_for_chip domain) */
    wire          fifo_store_byte4;     

    wire [27:0]   fifo_axi_awaddr;
    wire [7:0]    fifo_axi_awlen;
    wire          fifo_axi_awvalid;
    wire          fifo_axi_awready;
    wire [255:0]  fifo_axi_wdata;
    wire          fifo_axi_wvalid;
    wire          fifo_axi_wready;

    wire [27:0]   fifo_axi_araddr;     
    wire [7:0]    fifo_axi_arlen;
    wire          fifo_axi_arvalid;
    wire          fifo_axi_arready;
    wire [255:0]  fifo_axi_rdata;      
    wire          fifo_axi_rvalid;
    wire          fifo_axi_rready;


    /* Input buffer */
    reg           buf0_done_layer;
    reg           buf0_load_or_store_chip_out; 
    reg           buf0_load_or_store_chip_in; 
    reg           buf0_store_byte4; 
    reg [27:0]    buf0_axi_awaddr; 
    reg [7:0]     buf0_axi_awlen; 
    reg           buf0_axi_awvalid; 
    reg [127:0]   buf0_axi_wdata_pos;    // 128b  (LSB of 256b wdata)
    reg [127:0]   buf0_axi_wdata_neg;    // 128b  (MSB of 256b wdata)
    reg           buf0_axi_wvalid; 
    reg [27:0]    buf0_axi_araddr; 
    reg [7:0]     buf0_axi_arlen; 
    reg           buf0_axi_arvalid; 
    reg           buf0_axi_rready; 

    reg           buf1_load_or_store;
    reg           buf1_store_byte4; 
    reg [27:0]    buf1_axi_awaddr; 
    reg [7:0]     buf1_axi_awlen; 
    reg           buf1_axi_awvalid; 
    reg [255:0]   buf1_axi_wdata;      // 256b
    reg           buf1_axi_wvalid; 
    reg [27:0]    buf1_axi_araddr; 
    reg [7:0]     buf1_axi_arlen; 
    reg           buf1_axi_arvalid; 
    reg           buf1_axi_rready; 

    reg           buf2_store_byte4; 
    reg           buf2_axi_awvalid; 
    reg           buf2_axi_arvalid; 

    reg           buf3_store_byte4; 
    reg           buf3_axi_awvalid; 
    reg           buf3_axi_arvalid; 

    reg [1:0]     ax_delay;


    /* Output buffer */
    reg [255:0]   buf0_axi_rdata;
    reg           buf0_axi_awready; 
    reg           buf0_axi_arready; 
    reg           buf0_axi_wready; 
    reg           buf0_axi_rvalid; 

    reg           buf1_axi_rvalid; 
    reg [127:0]   buf1_axi_rdata_pos;
    reg [127:0]   buf1_axi_rdata_neg;


    /* Buffered done_layer */
    assign done_layer_buf = buf0_done_layer;


    /* Modeling IO */ 
    assign io_T  = load_or_store;
    assign io_T_ = buf0_load_or_store_chip_out;
    assign data  = (io_T  == LOAD ) ? rdata : 'z;
    assign wdata = (io_T_ == STORE) ? data  : '0;


    /* Decode in/out port signal */ 
    assign start_layer               = w_start_layer;
    assign axready                   = w_axready;
    assign rvalid_or_wready          = w_rvalid_or_wready;
    assign chip_axi_axaddr_and_axlen = axaddr_and_axlen;
    assign chip_axi_arvalid          = (load_or_store == LOAD ) ? axvalid: 0;
    assign chip_axi_awvalid          = (load_or_store == STORE) ? axvalid: 0;
    assign w_axready                 = (buf0_load_or_store_chip_in == LOAD ) ? chip_axi_arready : chip_axi_awready;
    assign chip_axi_rready           = (load_or_store == LOAD ) ? rready_or_wvalid : 0;
    assign chip_axi_wvalid           = (load_or_store == STORE) ? rready_or_wvalid : 0;
    assign w_rvalid_or_wready        = (buf0_load_or_store_chip_in == LOAD ) ? chip_axi_rvalid  : chip_axi_wready;
    assign chip_axi_wdata            = wdata;
    assign rdata                     = chip_axi_rdata;

    // assign chip_axi_rdata   = single_rate ? buf1_axi_rdata_pos : (clk_for_chip_in ? buf1_axi_rdata_pos : buf1_axi_rdata_neg);
    assign chip_axi_rdata      = buf1_axi_rdata_pos;
    assign chip_axi_awready    = buf0_axi_awready;
    assign chip_axi_arready    = buf0_axi_arready;
    assign chip_axi_wready     = buf0_axi_wready;
    assign chip_axi_rvalid     = single_rate ? buf1_axi_rvalid : buf0_axi_rvalid;

    /* Signals to/from FIFO */
    assign fifo_store_byte4    = buf3_store_byte4;           // buf3

    assign fifo_axi_awaddr     = buf1_axi_awaddr;
    assign fifo_axi_awlen      = buf1_axi_awlen;
    assign fifo_axi_awvalid    = buf3_axi_awvalid;           // buf3
    assign fifo_axi_wvalid     = buf1_axi_wvalid;
    assign fifo_axi_wdata      = buf1_axi_wdata;

    assign fifo_axi_araddr     = buf1_axi_araddr;
    assign fifo_axi_arlen      = buf1_axi_arlen;
    assign fifo_axi_arvalid    = buf3_axi_arvalid;           // buf3
    assign fifo_axi_rready     = buf1_axi_rready;


    // clk for chip_in !!!
    always @(posedge clk_for_chip_in or negedge rstn) begin
        if (~rstn) begin
            // output - stage1
            buf0_load_or_store_chip_in <= LOAD;
            buf0_axi_awready           <= 'd0;
            buf0_axi_arready           <= 'd0;
            buf0_axi_wready            <= 'd0;
            buf0_axi_rvalid            <= 'd0;
            buf0_axi_rdata             <= 'd0;    // 128b
        
            buf1_axi_rvalid            <= 'd0;
            buf1_axi_rdata_pos         <= 'd0;    // 128b
        end
        else begin

            // output
            buf0_load_or_store_chip_in <= load_or_store;
            buf0_axi_awready           <= fifo_axi_awready;
            buf0_axi_arready           <= fifo_axi_arready;
            // buf0_axi_arready           <= 1'b1;  //debug
            buf0_axi_wready            <= fifo_axi_wready;
            buf0_axi_rvalid            <= fifo_axi_rvalid;
            buf0_axi_rdata             <= fifo_axi_rdata;

            if (single_rate) begin
                buf1_axi_rdata_pos <= buf0_axi_rvalid ? buf0_axi_rdata[255:128] : buf0_axi_rdata[127:0];
            end
            else begin
                buf1_axi_rdata_pos <= buf0_axi_rdata[255:128];
            end

            buf1_axi_rvalid    <= buf0_axi_rvalid;   // for single-rate mode, need additional buffering to synchronize rdata & rvalid
        end
    end

    // clk for chip_out !!! Buffers chip_out signals to buf0s 
    always @(posedge clk_for_chip_out or negedge rstn) begin
        if (~rstn) begin
            // input - stage0
            buf0_done_layer             <= 'd0;
            buf0_load_or_store_chip_out <= LOAD;
            buf0_store_byte4            <= 'd0;
            buf0_axi_awaddr             <= 'd0;
            buf0_axi_awlen              <= 'd0;
            buf0_axi_awvalid            <= 'd0;
            buf0_axi_wdata_pos          <= 'd0;    // 128b
            buf0_axi_wvalid             <= 'd0;
            buf0_axi_araddr             <= 'd0;
            buf0_axi_arlen              <= 'd0;
            buf0_axi_arvalid            <= 'd0;
            buf0_axi_rready             <= 'd0;

            // delay for axaddr_and_axlen
            ax_delay                    <= 'd0;
        end
        else begin
            // input -stage0
            buf0_done_layer             <= done_layer;
            buf0_load_or_store_chip_out <= load_or_store;

            if (axvalid) begin
                // set LSB 12bit of axaddr
                if (load_or_store==LOAD) begin   
                    ax_delay              <= ax_delay + 2'd1;
                    buf0_axi_araddr[11:0] <= chip_axi_axaddr_and_axlen;
                    buf0_axi_arlen        <= 'd0;
                    buf0_axi_awaddr       <= 'd0;
                    buf0_axi_awlen        <= 'd0;
                end
                else begin
                    ax_delay              <= ax_delay + 2'd1;
                    buf0_axi_araddr       <= 'd0;
                    buf0_axi_arlen        <= 'd0;
                    buf0_axi_awaddr[11:0] <= chip_axi_axaddr_and_axlen;
                    buf0_axi_awlen        <= 'd0;
                end
            end
            else if (ax_delay==2'd1) begin
                // set axaddr[23:12]
                if (load_or_store==LOAD) begin   
                    ax_delay               <= ax_delay + 2'd1;
                    buf0_axi_araddr[23:12] <= chip_axi_axaddr_and_axlen;
                    buf0_axi_arlen         <= 'd0;
                    buf0_axi_awaddr        <= 'd0;
                    buf0_axi_awlen         <= 'd0;
                end
                else begin
                    ax_delay               <= ax_delay + 2'd1;
                    buf0_axi_araddr        <= 'd0;
                    buf0_axi_arlen         <= 'd0;
                    buf0_axi_awaddr[23:12] <= chip_axi_axaddr_and_axlen;
                    buf0_axi_awlen         <= 'd0;
                end
            end
            else if (ax_delay==2'd2) begin
                // set axaddr[27:24] & axlen
                if (load_or_store==LOAD) begin   
                    ax_delay               <= 2'd0;
                    buf0_axi_araddr[27:24] <= chip_axi_axaddr_and_axlen[3:0];
                    buf0_axi_arlen         <= chip_axi_axaddr_and_axlen[11:4];
                    buf0_axi_awaddr        <= 'd0;
                    buf0_axi_awlen         <= 'd0;
                end
                else begin
                    ax_delay               <= 2'd0;
                    buf0_axi_araddr        <= 'd0;
                    buf0_axi_arlen         <= 'd0;
                    buf0_axi_awaddr[27:24] <= chip_axi_axaddr_and_axlen[3:0];
                    buf0_axi_awlen         <= chip_axi_axaddr_and_axlen[11:4];
                end
            end
            else begin
                ax_delay               <= 'd0;
                buf0_axi_araddr        <= 'd0;
                buf0_axi_arlen         <= 'd0;
                buf0_axi_awaddr        <= 'd0;
                buf0_axi_awlen         <= 'd0;
            end

            buf0_store_byte4   <= store_byte4;
            buf0_axi_arvalid   <= chip_axi_arvalid;
            buf0_axi_awvalid   <= chip_axi_awvalid;
            buf0_axi_wdata_pos <= chip_axi_wdata;    // 128b
            buf0_axi_wvalid    <= chip_axi_wvalid;
            buf0_axi_rready    <= chip_axi_rready;
        end
    end

    always @(posedge clk_for_chip or negedge rstn) begin
        if (~rstn) begin
            // input - stage1
            buf1_load_or_store <= 'd0;
            buf1_store_byte4   <= 'd0;
            buf1_axi_awaddr    <= 'd0;
            buf1_axi_awlen     <= 'd0;
            buf1_axi_awvalid   <= 'd0;
            buf1_axi_wdata     <= 'd0;    // 256b
            buf1_axi_wvalid    <= 'd0;
            buf1_axi_araddr    <= 'd0;
            buf1_axi_arlen     <= 'd0;
            buf1_axi_arvalid   <= 'd0;
            buf1_axi_rready    <= 'd0;

            // input - stage2  
            // to synchronize with time-unrolled axaddr & axlen
            buf2_store_byte4   <= 'd0;
            buf2_axi_awvalid   <= 'd0;
            buf2_axi_arvalid   <= 'd0;

            // input - stage3  
            // to synchronize with time-unrolled axaddr & axlen
            buf3_store_byte4   <= 'd0;
            buf3_axi_awvalid   <= 'd0;
            buf3_axi_arvalid   <= 'd0;
        end
        else begin
            // input -stage1
            buf1_load_or_store <= buf0_load_or_store_chip_out;
            buf1_store_byte4   <= buf0_store_byte4;
            buf1_axi_awaddr    <= buf0_axi_awaddr;
            buf1_axi_awlen     <= buf0_axi_awlen;
            buf1_axi_awvalid   <= buf0_axi_awvalid;
            buf1_axi_wvalid    <= buf0_axi_wvalid;
            buf1_axi_araddr    <= buf0_axi_araddr;
            buf1_axi_arlen     <= buf0_axi_arlen;
            buf1_axi_arvalid   <= buf0_axi_arvalid;
            buf1_axi_rready    <= buf0_axi_rready;

            if (single_rate) begin
                if (buf0_axi_wvalid==1) buf1_axi_wdata[255:128] <= buf0_axi_wdata_pos;
                else                    buf1_axi_wdata[127:  0] <= buf0_axi_wdata_pos;
            end
            else begin
                // buf1_axi_wdata <= {buf0_axi_wdata_neg, buf0_axi_wdata_pos};
            end


            // input - stage2
            // to synchronize with time-unrolled axaddr & axlen
            buf2_store_byte4   <= buf1_store_byte4;
            buf2_axi_awvalid   <= buf1_axi_awvalid;
            buf2_axi_arvalid   <= buf1_axi_arvalid;

            // input - stage3
            // to synchronize with time-unrolled axaddr & axlen
            buf3_store_byte4   <= buf2_store_byte4;
            buf3_axi_awvalid   <= buf2_axi_awvalid;
            buf3_axi_arvalid   <= buf2_axi_arvalid;
        end
    end

    // always @(negedge clk_for_chip or negedge rstn) begin  // not used...
    //     if (~rstn) begin
    //         buf0_axi_wdata_neg <= 'd0;
    //         buf1_axi_rdata_neg <= 'd0;
    //     end
    //     else begin
    //         // input from NPU
    //         buf0_axi_wdata_neg <= chip_axi_wdata;
    //         // output to MIG
    //         buf1_axi_rdata_neg <= buf0_axi_rdata[127:0];
    //     end
    // end


    //************************************************************
    // FIFOs between Chip <-> MIG
    //************************************************************

    /* Reset for FIFOs */ 
    wire         fifo_rst;

    /* Wires */ 
    wire         araddr_fifo_wr_en; 
    wire         araddr_fifo_rd_en; 
    wire [ 37:0] araddr_fifo_din; 
    wire [ 37:0] araddr_fifo_dout; 
    wire         araddr_fifo_valid; 
    wire         araddr_fifo_empty; 
    wire         araddr_fifo_full; 
    wire         araddr_fifo_prog_full; 

    wire         awaddr_fifo_wr_en; 
    wire         awaddr_fifo_rd_en; 
    wire [ 37:0] awaddr_fifo_din; 
    wire [ 37:0] awaddr_fifo_dout; 
    wire         awaddr_fifo_valid; 
    wire         awaddr_fifo_empty; 
    wire         awaddr_fifo_full; 
    wire         awaddr_fifo_prog_full; 

    wire         rdata_fifo_wr_en; 
    wire         rdata_fifo_rd_en; 
    wire [256:0] rdata_fifo_din; 
    wire [256:0] rdata_fifo_dout; 
    wire         rdata_fifo_valid; 
    wire         rdata_fifo_empty; 
    wire         rdata_fifo_full; 
    wire         rdata_fifo_prog_full; 

    wire         wdata_fifo_wr_en; 
    wire         wdata_fifo_rd_en; 
    wire [256:0] wdata_fifo_din; 
    wire [256:0] wdata_fifo_dout; 
    wire         wdata_fifo_valid; 
    wire         wdata_fifo_empty; 
    wire         wdata_fifo_full; 
    wire         wdata_fifo_prog_full; 
    

    assign fifo_rst = ~rstn;    // active-high

    assign awaddr_fifo_wr_en = fifo_axi_awvalid && (!awaddr_fifo_full);
    // assign awaddr_fifo_rd_en = mig_axi_awready && (!awaddr_fifo_empty); 
    assign awaddr_fifo_rd_en = mig_axi_awready;  // handling timing failure

    assign araddr_fifo_wr_en = fifo_axi_arvalid && (!araddr_fifo_full);
    // assign araddr_fifo_rd_en = mig_axi_arready && (!araddr_fifo_empty); 
    assign araddr_fifo_rd_en = mig_axi_arready;  // handling timing failure

    assign wdata_fifo_wr_en  = fifo_axi_wvalid && (!wdata_fifo_full);
    // assign wdata_fifo_rd_en  = mig_axi_wready && (!wdata_fifo_empty);
    assign wdata_fifo_rd_en  = mig_axi_wready;   // handling timing failure

    assign rdata_fifo_wr_en  = mig_axi_rvalid_tmp && (!rdata_fifo_full);
    // assign rdata_fifo_rd_en  = fifo_axi_rready && (!rdata_fifo_empty); 
    assign rdata_fifo_rd_en  = fifo_axi_rready;  // handling timing failure

    assign awaddr_fifo_din   = {buf3_store_byte4, fifo_axi_awvalid, fifo_axi_awlen, fifo_axi_awaddr};   //  38-bit
    assign araddr_fifo_din   = {1'b0, fifo_axi_arvalid, fifo_axi_arlen, fifo_axi_araddr};          //  38-bit
    assign wdata_fifo_din    = {fifo_axi_wvalid, fifo_axi_wdata};                                  // 257-bit
    assign rdata_fifo_din    = {mig_axi_rvalid, mig_axi_rdata};                                    // 257-bit

    assign {mig_store_byte4, mig_axi_awvalid, mig_axi_awlen, mig_axi_awaddr} = awaddr_fifo_rd_en && awaddr_fifo_valid ? awaddr_fifo_dout : 'd0;
    assign {mig_axi_arvalid, mig_axi_arlen, mig_axi_araddr} = araddr_fifo_rd_en && araddr_fifo_valid ? araddr_fifo_dout[36:0] : 'd0;

    // assign {mig_axi_wvalid, mig_axi_wdata}  = wdata_fifo_rd_en && wdata_fifo_valid ? wdata_fifo_dout : 'd0;
    // assign {fifo_axi_rvalid, fifo_axi_rdata}  = rdata_fifo_rd_en && rdata_fifo_valid ? rdata_fifo_dout : 'd0;
    assign mig_axi_wvalid   = wdata_fifo_rd_en && wdata_fifo_valid && wdata_fifo_dout[256];
    assign mig_axi_wdata    = wdata_fifo_dout[255:0];
    assign fifo_axi_rvalid  = rdata_fifo_rd_en && rdata_fifo_valid && rdata_fifo_dout[256]; 
    assign fifo_axi_rdata   = rdata_fifo_dout[255:0];

    assign fifo_axi_awready = !awaddr_fifo_prog_full;
    assign fifo_axi_arready = !araddr_fifo_prog_full;
    assign fifo_axi_wready  = !wdata_fifo_prog_full;
    assign mig_axi_rready   = !rdata_fifo_prog_full;

    // for debugging
    assign araddr_fifo_rd_en_debug     = araddr_fifo_rd_en;
    assign araddr_fifo_wr_en_debug     = araddr_fifo_wr_en;
    assign araddr_fifo_valid_debug     = araddr_fifo_valid; 
    assign araddr_fifo_empty_debug     = araddr_fifo_empty; 
    assign araddr_fifo_full_debug      = araddr_fifo_full; 
    assign araddr_fifo_prog_full_debug = araddr_fifo_prog_full; 

    assign awaddr_fifo_rd_en_debug     = awaddr_fifo_rd_en;
    assign awaddr_fifo_wr_en_debug     = awaddr_fifo_wr_en;
    assign awaddr_fifo_valid_debug     = awaddr_fifo_valid; 
    assign awaddr_fifo_empty_debug     = awaddr_fifo_empty; 
    assign awaddr_fifo_full_debug      = awaddr_fifo_full; 
    assign awaddr_fifo_prog_full_debug = awaddr_fifo_prog_full; 

    assign rdata_fifo_rd_en_debug      = rdata_fifo_rd_en;
    assign rdata_fifo_wr_en_debug      = rdata_fifo_wr_en;
    assign rdata_fifo_valid_debug      = rdata_fifo_valid; 
    assign rdata_fifo_empty_debug      = rdata_fifo_empty; 
    assign rdata_fifo_full_debug       = rdata_fifo_full; 
    assign rdata_fifo_prog_full_debug  = rdata_fifo_prog_full; 

    assign wdata_fifo_rd_en_debug      = wdata_fifo_rd_en;
    assign wdata_fifo_wr_en_debug      = wdata_fifo_wr_en;
    assign wdata_fifo_valid_debug      = wdata_fifo_valid; 
    assign wdata_fifo_empty_debug      = wdata_fifo_empty; 
    assign wdata_fifo_full_debug       = wdata_fifo_full; 
    assign wdata_fifo_prog_full_debug  = wdata_fifo_prog_full;           

    /* awaddr fifo (Chip -> MIG) */
    awaddr_builtin_fifo_38_512 awaddr_fifo_chip2mig (
        .rst                (fifo_rst             ),
        .wr_clk             (clk_for_chip         ),
        .rd_clk             (mig_clk              ),
        .din                (awaddr_fifo_din      ),
        .wr_en              (awaddr_fifo_wr_en    ),
        .rd_en              (awaddr_fifo_rd_en    ),
        .dout               (awaddr_fifo_dout     ),
        .full               (awaddr_fifo_full     ),
        .empty              (awaddr_fifo_empty    ),
        .valid              (awaddr_fifo_valid    ),
        // .prog_full_thresh   (8'd255-FIFO_HEADROOM ),    // set during reset
        .prog_full          (awaddr_fifo_prog_full)
    );


    /* wdata fifo (Chip -> MIG) */
    wdata_builtin_fifo_257_512 wdata_fifo_chip2mig (
        .rst                (fifo_rst            ),
        .wr_clk             (clk_for_chip        ),
        .rd_clk             (mig_clk             ),
        .din                (wdata_fifo_din      ),
        .wr_en              (wdata_fifo_wr_en    ),
        .rd_en              (wdata_fifo_rd_en    ),
        .dout               (wdata_fifo_dout     ),
        .full               (wdata_fifo_full     ),
        .empty              (wdata_fifo_empty    ),
        .valid              (wdata_fifo_valid    ),
        // .prog_full_thresh   (9'd511-FIFO_HEADROOM),
        .prog_full          (wdata_fifo_prog_full)
    );


    /* araddr fifo (Chip -> MIG) */
    araddr_builtin_fifo_38_512 araddr_fifo_chip2mig (
        .rst                (fifo_rst             ),
        .wr_clk             (clk_for_chip         ),
        .rd_clk             (mig_clk              ),
        .din                (araddr_fifo_din      ),
        .wr_en              (araddr_fifo_wr_en    ),
        .rd_en              (araddr_fifo_rd_en    ),
        .dout               (araddr_fifo_dout     ),
        .full               (araddr_fifo_full     ),
        .empty              (araddr_fifo_empty    ),
        .valid              (araddr_fifo_valid    ),
        // .prog_full_thresh   (8'd255-FIFO_HEADROOM ),
        .prog_full          (araddr_fifo_prog_full)
    );


    /* rdata fifo (Chip <- MIG) */
    rdata_builtin_fifo_257_512 rdata_fifo_mig2chip (    // write by MIG, ready by CORE 
        .rst                (fifo_rst            ),
        .wr_clk             (mig_clk             ),
        .rd_clk             (clk_for_chip        ),
        .din                (rdata_fifo_din      ),
        .wr_en              (rdata_fifo_wr_en    ),
        .rd_en              (rdata_fifo_rd_en    ),
        .dout               (rdata_fifo_dout     ),
        .full               (rdata_fifo_full     ),
        .empty              (rdata_fifo_empty    ),
        .valid              (rdata_fifo_valid    ),
        // .prog_full_thresh   (9'd511-FIFO_HEADROOM),
        .prog_full          (rdata_fifo_prog_full)
    );


    //************************************************************
    // Instantiate chipController
    //************************************************************

    chipController u_chipController (
        .chip_clk          (clk_for_chip     ),
        .clk_for_chip_in   (clk_for_chip_in  ),
        .rstn              (rstn             ),
        .start_network     (start_network    ),
        .start_layer       (w_start_layer    ),
        .start_store_byte4 (start_store_byte4),
        .n_layers          (n_layers         ),
        .done_network      (done_network     ),
        .done_layer        (buf0_done_layer   ),
        .clk_cnt           (clk_cnt          )
    );


    //************************************************************
    // Measure AXI Read Delay for test
    //************************************************************
    localparam S_DEBUG_IDLE = 2'd0;
    localparam S_DEBUG_READ_START = 2'd1;
    localparam S_DEBUG_READ_END = 2'd2;

    reg [1:0]  state_debug;
    reg [31:0] chip_axi_read_delay;
    assign chip_axi_read_delay_out = chip_axi_read_delay;

    always @(posedge clk_for_chip or negedge rstn) begin
        if (~rstn) begin
            state_debug <= S_DEBUG_IDLE;
        end
        else begin
            case (state_debug) 
                S_DEBUG_IDLE: begin
                    if (chip_axi_arvalid) state_debug <= S_DEBUG_READ_START;
                    else                  state_debug <= S_DEBUG_IDLE;
                end
                S_DEBUG_READ_START: begin
                    if (chip_axi_rvalid) state_debug <= S_DEBUG_READ_END;
                    else                 state_debug <= S_DEBUG_READ_START;
                end
                S_DEBUG_READ_END: begin
                    // if (chip_axi_wvalid) state_debug <= S_DEBUG_IDLE;
                    // else                 state_debug <= S_DEBUG_READ_END;
                end
            endcase
        end
    end

    always @(posedge clk_for_chip or negedge rstn) begin
        if (~rstn) begin
            chip_axi_read_delay <= 32'd0; 
        end
        else begin
            case (state_debug) 
                S_DEBUG_IDLE: begin
                    if (chip_axi_arvalid) chip_axi_read_delay <= chip_axi_read_delay + 32'd1;
                    else                  chip_axi_read_delay <= 32'd0;
                end
                S_DEBUG_READ_START: begin
                    if (!chip_axi_rvalid) chip_axi_read_delay <= chip_axi_read_delay + 32'd1;
                end
                S_DEBUG_READ_END: begin
                end
            endcase
        end
    end


    //************************************************************
    // Save signals to/from Chip for debugging
    //************************************************************
    integer i;

    // always @(posedge clk_for_chip_in or negedge rstn) begin
    always @(posedge clk_for_chip or negedge rstn) begin
        if (~rstn) begin
            arready_cnt <= 8'd0;
            awready_cnt <= 8'd0;
        end
        else begin
            // if (w_axready && (buf0_load_or_store_chip_in == LOAD )) arready_cnt <= arready_cnt + 8'd1;
            // if (w_axready && (buf0_load_or_store_chip_in == STORE)) awready_cnt <= awready_cnt + 8'd1;
            if (fifo_axi_arready) arready_cnt <= arready_cnt + 8'd1;
            if (fifo_axi_awready) awready_cnt <= awready_cnt + 8'd1;
        end
    end

    always @(posedge clk_for_chip or negedge rstn) begin
        if (~rstn) begin
            start_cnt   <= 8'd0;
            arvalid_cnt <= 32'd0;
            rvalid_cnt  <= 32'd0;
            awvalid_cnt <= 32'd0;
            wvalid_cnt  <= 32'd0;

            for (i=0; i<64; i=i+1) begin
                araddr_hist[i] <= 28'd0;
                arlen_hist [i] <= 8'd0;
                rdata_hist [i] <= 256'd0;
                awaddr_hist[i] <= 28'd0;
                awlen_hist [i] <= 8'd0;
                // wdata_hist [i] <= 128'd0;
            end
        end
        else begin
            if (start_layer) start_cnt <= start_cnt + 8'd1;

            /* Store oldest */
            // if (fifo_axi_arvalid && (arvalid_cnt < 8'd255)) arvalid_cnt <= arvalid_cnt + 8'd1;
            // if (fifo_axi_awvalid && (awvalid_cnt < 8'd255)) awvalid_cnt <= awvalid_cnt + 8'd1;

            // if (fifo_axi_rvalid && (rvalid_cnt < 8'd255)) rvalid_cnt  <= rvalid_cnt + 8'd1;
            // if (fifo_axi_wvalid && (wvalid_cnt < 8'd255)) wvalid_cnt  <= wvalid_cnt + 8'd1;


            /* Store newest */
            if (fifo_axi_arvalid) arvalid_cnt <= arvalid_cnt + 32'd1;
            if (fifo_axi_awvalid) awvalid_cnt <= awvalid_cnt + 32'd1;

            if (fifo_axi_rvalid) rvalid_cnt  <= rvalid_cnt + 32'd1;
            if (fifo_axi_wvalid) wvalid_cnt  <= wvalid_cnt + 32'd1;



            if (fifo_axi_arvalid && arvalid_cnt[7:6]==2'd0) araddr_hist[arvalid_cnt[5:0]] <= fifo_axi_araddr;  // 1st 64 araddr
            if (fifo_axi_awvalid && awvalid_cnt[7:6]==2'd0) awaddr_hist[awvalid_cnt[5:0]] <= fifo_axi_awaddr;  // 1st 64 awaddr

            if (fifo_axi_arvalid && arvalid_cnt[7:6]==2'd0) arlen_hist[arvalid_cnt[5:0]] <= fifo_axi_arlen;  // 1st 64 arlen
            if (fifo_axi_awvalid && awvalid_cnt[7:6]==2'd0) awlen_hist[awvalid_cnt[5:0]] <= fifo_axi_awlen;  // 1st 64 awlen

            //if (chip_axi_rvalid && rvalid_cnt[7:6]==2'd0) rdata_hist[rvalid_cnt[5:0]][255:128] <= chip_axi_rdata;  // 1st 64 rdata
            //else if (rvalid_cnt[7:6]==2'd0)               rdata_hist[rvalid_cnt[5:0]][127:0]   <= chip_axi_rdata;  // 1st 64 rdata

            // if (fifo_axi_rvalid && rvalid_cnt[7:6]==2'd0) rdata_hist[rvalid_cnt[5:0]] <= fifo_axi_rdata;  // 1st 64 rdata
            


        end
    end


    //************************************************************
    // Save signals to/from Chip into FIFO for debugging
    //************************************************************

    wire         after_start;
    reg          stop;

    wire [255:0] debug_fifo_fpga2chip_din; 
    wire [ 31:0] debug_fifo_fpga2chip_dout;    
    wire         debug_fifo_fpga2chip_wr_en;
    wire         debug_fifo_fpga2chip_rd_en;
    wire         debug_fifo_fpga2chip_empty;
    wire         debug_fifo_fpga2chip_valid;
    wire         debug_fifo_fpga2chip_full;
    wire         debug_fifo_fpga2chip_prog_full;

    wire [255:0] debug_fifo_chip2fpga_din;
    wire [ 31:0] debug_fifo_chip2fpga_dout;
    wire         debug_fifo_chip2fpga_wr_en;
    wire         debug_fifo_chip2fpga_rd_en;
    wire         debug_fifo_chip2fpga_empty;
    wire         debug_fifo_chip2fpga_valid;
    wire         debug_fifo_chip2fpga_full;
    wire         debug_fifo_chip2fpga_prog_full;

    wire [ 63:0] debug_fifo_axaddr_din;
    wire [ 31:0] debug_fifo_axaddr_dout;
    wire         debug_fifo_axaddr_wr_en;
    wire         debug_fifo_axaddr_rd_en;
    wire         debug_fifo_axaddr_empty;
    wire         debug_fifo_axaddr_valid;
    wire         debug_fifo_axaddr_full;
    wire         debug_fifo_axaddr_prog_full;

    wire [255:0] debug_fifo_rdata_din;
    wire [ 31:0] debug_fifo_rdata_dout;
    wire         debug_fifo_rdata_wr_en;
    wire         debug_fifo_rdata_rd_en;
    wire         debug_fifo_rdata_empty;
    wire         debug_fifo_rdata_valid;
    wire         debug_fifo_rdata_full;
    wire         debug_fifo_rdata_prog_full;

    wire [255:0] debug_fifo_wdata_din;
    wire [ 31:0] debug_fifo_wdata_dout;
    wire         debug_fifo_wdata_wr_en;
    wire         debug_fifo_wdata_rd_en;
    wire         debug_fifo_wdata_empty;
    wire         debug_fifo_wdata_valid;
    wire         debug_fifo_wdata_full;
    wire         debug_fifo_wdata_prog_full;


    reg pipe_out_ready_debug_fpga2chip_buf;
    reg pipe_out_ready_debug_chip2fpga_buf;
    reg pipe_out_ready_debug_axaddr_buf;
    reg pipe_out_ready_debug_rdata_buf;
    reg pipe_out_ready_debug_wdata_buf;

    reg start_debug;




    assign debug_fifo_fpga2chip_din       = reordering_256b({125'd0, w_start_layer, w_axready, w_rvalid_or_wready, rdata});
    // assign debug_fifo_fpga2chip_din       = reordering_256b({111'd0, fifo_axi_wvalid, buf0_load_or_store_chip_out, buf1_axi_wvalid, 12'd0, buf0_axi_awvalid, buf0_axi_wvalid, buf0_axi_wdata_pos});  //used as buf0 wdata debug
    // assign debug_fifo_fpga2chip_din       = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;   // for test
    assign debug_fifo_fpga2chip_wr_en     = (w_start_layer || after_start) && (!debug_fifo_fpga2chip_full);
    // assign debug_fifo_fpga2chip_wr_en     = start_debug && (w_start_layer || after_start) && (!debug_fifo_fpga2chip_full); //debug

    assign debug_fifo_fpga2chip_rd_en     = debug_fifo_fpga2chip_read && (!debug_fifo_fpga2chip_empty) && pipe_out_ready_debug_fpga2chip_buf;
    assign debug_fifo_fpga2chip_rd_en_out = debug_fifo_fpga2chip_rd_en;
    assign pipe_dout_debug_fpga2chip      = debug_fifo_fpga2chip_dout;
    assign pipe_out_valid_debug_fpga2chip = debug_fifo_fpga2chip_valid;

    assign debug_fifo_chip2fpga_din       = reordering_256b({111'd0, done_layer, buf0_load_or_store_chip_out, store_byte4, axaddr_and_axlen, axvalid, rready_or_wvalid, wdata});
    // assign debug_fifo_chip2fpga_din       = reordering_256b(256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f);   // for test
    assign debug_fifo_chip2fpga_wr_en     = after_start && (!debug_fifo_chip2fpga_full);
    // assign debug_fifo_chip2fpga_wr_en     = start_debug && after_start && (!debug_fifo_chip2fpga_full); //debug
    assign debug_fifo_chip2fpga_rd_en     = debug_fifo_chip2fpga_read && (!debug_fifo_chip2fpga_empty) && pipe_out_ready_debug_chip2fpga_buf;
    assign debug_fifo_chip2fpga_rd_en_out = debug_fifo_chip2fpga_rd_en;
    assign pipe_dout_debug_chip2fpga      = debug_fifo_chip2fpga_dout;
    assign pipe_out_valid_debug_chip2fpga = debug_fifo_chip2fpga_valid;


    assign debug_fifo_axaddr_din          = (buf1_load_or_store == LOAD) ? reordering_64b({27'd0, LOAD, fifo_axi_arlen, fifo_axi_araddr}) : reordering_64b({27'd0, STORE, fifo_axi_awlen, fifo_axi_awaddr});
    // assign debug_fifo_axaddr_din          = 64'h0001020304050607;   // for test
    assign debug_fifo_axaddr_wr_en        = (buf1_load_or_store == LOAD) ? fifo_axi_arvalid : fifo_axi_awvalid;
    // assign debug_fifo_axaddr_wr_en        = (buf1_load_or_store==STORE) && fifo_axi_awvalid && buf3_store_byte4;   // only for OCT_NEW STORE
    // assign debug_fifo_axaddr_wr_en        = (buf1_load_or_store == LOAD) ? start_debug && fifo_axi_arvalid : start_debug && fifo_axi_awvalid;

    assign debug_fifo_axaddr_rd_en        = debug_fifo_axaddr_read && (!debug_fifo_axaddr_empty) && pipe_out_ready_debug_axaddr_buf;
    assign debug_fifo_axaddr_rd_en_out    = debug_fifo_axaddr_rd_en;
    assign pipe_dout_debug_axaddr         = debug_fifo_axaddr_dout;
    assign pipe_out_valid_debug_axaddr    = debug_fifo_axaddr_valid;

    /// debug debug
    assign debug_fifo_axaddr_valid_debug     = debug_fifo_axaddr_valid;
    assign debug_fifo_axaddr_empty_debug     = debug_fifo_axaddr_empty;
    assign pipe_out_ready_debug_axaddr_debug = pipe_out_ready_debug_axaddr;
    assign pipe_out_valid_debug_axaddr_debug = pipe_out_valid_debug_axaddr;
    ///

    assign debug_fifo_rdata_din           = reordering_256b(fifo_axi_rdata);
    assign debug_fifo_rdata_wr_en         = fifo_axi_rvalid;
    // assign debug_fifo_rdata_wr_en         = start_debug && fifo_axi_rvalid;  // debug
    assign debug_fifo_rdata_rd_en         = debug_fifo_rdata_read && (!debug_fifo_rdata_empty) && pipe_out_ready_debug_rdata_buf;
    assign debug_fifo_rdata_rd_en_out     = debug_fifo_rdata_rd_en;
    assign pipe_dout_debug_rdata          = debug_fifo_rdata_dout;
    assign pipe_out_valid_debug_rdata     = debug_fifo_rdata_valid;

    assign debug_fifo_wdata_din           = reordering_256b(fifo_axi_wdata);
    assign debug_fifo_wdata_wr_en         = fifo_axi_wvalid;
    // assign debug_fifo_wdata_wr_en         = start_debug && fifo_axi_wvalid;  // debug
    assign debug_fifo_wdata_rd_en         = debug_fifo_wdata_read && (!debug_fifo_wdata_empty) && pipe_out_ready_debug_wdata_buf;
    assign debug_fifo_wdata_rd_en_out     = debug_fifo_wdata_rd_en;
    assign pipe_dout_debug_wdata          = debug_fifo_wdata_dout;
    assign pipe_out_valid_debug_wdata     = debug_fifo_wdata_valid;

    assign after_start = (ttf_axvalid >= 4'd1);

    /* store last pipeOut ready signal */
    always @(posedge okClk) begin
        pipe_out_ready_debug_fpga2chip_buf <= pipe_out_ready_debug_fpga2chip;
        pipe_out_ready_debug_chip2fpga_buf <= pipe_out_ready_debug_chip2fpga;
        pipe_out_ready_debug_axaddr_buf    <= pipe_out_ready_debug_axaddr;
        pipe_out_ready_debug_rdata_buf     <= pipe_out_ready_debug_rdata;
        pipe_out_ready_debug_wdata_buf     <= pipe_out_ready_debug_wdata;
    end


    /* ttf_axvalid */
    always @(posedge clk_for_chip or negedge rstn) begin
        if (~rstn) begin
            ttf_axvalid <= 'd0;
            stop <= 1'b0;
        end
        else begin
            if      (start_layer && (!stop)) ttf_axvalid <= ttf_axvalid + 4'd1;
            else if (axvalid)                stop        <= 1'b1;
            else if (after_start && (!stop)) ttf_axvalid <= ttf_axvalid + 4'b1;
        end
    end

    /* debug */
    always @(posedge clk_for_chip or negedge rstn) begin
        if (~rstn) begin
            start_debug <= 'd0;
        end
        else begin
            if (fifo_axi_araddr>28'h1475bc0) start_debug <= 1'b1;
        end
    end

    /* FIFO for cycle level debugging of fpga2chip signals */
    debug_fifo_w256_512_r32_4096 u_debug_fifo_fpga2chip (
        .rstn               (rstn                          ),
        .wr_clk             (clk_for_chip_in               ),
        .rd_clk             (okClk                         ),
        .din                (debug_fifo_fpga2chip_din      ),
        .wr_en              (debug_fifo_fpga2chip_wr_en    ),
        .rd_en              (debug_fifo_fpga2chip_rd_en    ),
        .dout               (debug_fifo_fpga2chip_dout     ),
        .full               (debug_fifo_fpga2chip_full     ),
        .empty              (debug_fifo_fpga2chip_empty    ),
        .valid              (debug_fifo_fpga2chip_valid    ),
        .prog_full          (debug_fifo_fpga2chip_prog_full)
    );


    /* FIFO for cycle level debugging of chip2fpga signals */
    debug_fifo_w256_512_r32_4096 u_debug_fifo_chip2fpga (
        .rstn               (rstn                          ),
        .wr_clk             (clk_for_chip_out              ),
        .rd_clk             (okClk                         ),
        .din                (debug_fifo_chip2fpga_din      ),
        .wr_en              (debug_fifo_chip2fpga_wr_en    ),
        .rd_en              (debug_fifo_chip2fpga_rd_en    ),
        .dout               (debug_fifo_chip2fpga_dout     ),
        .full               (debug_fifo_chip2fpga_full     ),
        .empty              (debug_fifo_chip2fpga_empty    ),
        .valid              (debug_fifo_chip2fpga_valid    ),
        .prog_full          (debug_fifo_chip2fpga_prog_full)
    );


    /* FIFO for axaddr and axlen handshaking debugging */
    debug_fifo_w64_2048_r32_4096 u_debug_fifo_axaddr (
        .rstn               (rstn                       ),
        .wr_clk             (clk_for_chip               ),
        .rd_clk             (okClk                      ),
        .din                (debug_fifo_axaddr_din      ),
        .wr_en              (debug_fifo_axaddr_wr_en    ),
        .rd_en              (debug_fifo_axaddr_rd_en    ),
        .dout               (debug_fifo_axaddr_dout     ),
        .full               (debug_fifo_axaddr_full     ),
        .empty              (debug_fifo_axaddr_empty    ),
        .valid              (debug_fifo_axaddr_valid    ),
        .prog_full          (debug_fifo_axaddr_prog_full)
    );


    /* FIFO for rdata transfer debugging */
    debug_fifo_w256_512_r32_4096 u_debug_fifo_rdata (
        .rstn               (rstn                      ),
        .wr_clk             (clk_for_chip              ),
        .rd_clk             (okClk                     ),
        .din                (debug_fifo_rdata_din      ),
        .wr_en              (debug_fifo_rdata_wr_en    ),
        .rd_en              (debug_fifo_rdata_rd_en    ),
        .dout               (debug_fifo_rdata_dout     ),
        .full               (debug_fifo_rdata_full     ),
        .empty              (debug_fifo_rdata_empty    ),
        .valid              (debug_fifo_rdata_valid    ),
        .prog_full          (debug_fifo_rdata_prog_full)
    );


    /* FIFO for wdata transfer debugging */
    debug_fifo_w256_512_r32_4096 u_debug_fifo_wdata (
        .rstn               (rstn                      ),
        .wr_clk             (clk_for_chip              ),
        .rd_clk             (okClk                     ),
        .din                (debug_fifo_wdata_din      ),
        .wr_en              (debug_fifo_wdata_wr_en    ),
        .rd_en              (debug_fifo_wdata_rd_en    ),
        .dout               (debug_fifo_wdata_dout     ),
        .full               (debug_fifo_wdata_full     ),
        .empty              (debug_fifo_wdata_empty    ),
        .valid              (debug_fifo_wdata_valid    ),
        .prog_full          (debug_fifo_wdata_prog_full)
    );


endmodule


function [255:0] reordering_256b (
    input [255:0] data
);
    // 0 1 2 3 4 5 6 7 ... ->  3 2 1 0 7 6 5 4 ...
    begin
        integer i, j;
        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                reordering_256b[i*32 + j*8 +: 8] = data[i*32 + (3-j)*8 +: 8];
            end
        end
    end
endfunction

function [63:0] reordering_64b (
    input [63:0] data
);
    // 0 1 2 3 4 5 6 7  ->  3 2 1 0 7 6 5 4 ...
    begin
        integer i, j;
        for (i = 0; i < 2; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                reordering_64b[i*32 + j*8 +: 8] = data[i*32 + (3-j)*8 +: 8];
            end
        end
    end
endfunction