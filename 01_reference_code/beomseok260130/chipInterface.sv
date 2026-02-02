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
    input  wire         infinite_loop,
    input  wire [ 15:0] wait_chip_cnt,    
    
    output wire         done_network,
    output wire [31:0]  done_network_cnt,
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
    output reg  [  7:0] done_cnt,
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
    wire [7:0] io_T;
    wire [7:0] io_T_;
    wire [127:0] wdata;
    wire [127:0] rdata;


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
    reg [7:0]     buf0_load_or_store; 
    reg           buf0_store_byte4; 
    reg           buf0_axvalid; 
    reg [11:0]    buf0_axaddr_and_axlen; 
    reg           buf0_rready_or_wvalid; 
    reg [127:0]   buf0_wdata_pos;    // 128b  

    reg           buf1_done_layer;
    reg [7:0]     buf1_load_or_store;
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
    reg           buf0_axi_axready; 
    reg           buf0_axi_rvalid; 
    reg           buf1_axi_rvalid_or_buf0_axi_wready; 

    reg [127:0]   buf1_axi_rdata_pos;


    /* Buffered done_layer */
    assign done_layer_buf = buf1_done_layer;


    /* Modeling IO */ 
    assign io_T = buf1_load_or_store;

    assign data[121] = (io_T[0]==LOAD) ? rdata[121]:'z;
    assign data[118] = (io_T[0]==LOAD) ? rdata[118]:'z;
    assign data[123] = (io_T[0]==LOAD) ? rdata[123]:'z;
    assign data[116] = (io_T[0]==LOAD) ? rdata[116]:'z;
    assign data[127] = (io_T[0]==LOAD) ? rdata[127]:'z;

    assign data[124] = (io_T[1]==LOAD) ? rdata[124]:'z;
    assign data[122] = (io_T[1]==LOAD) ? rdata[122]:'z;
    assign data[126] = (io_T[1]==LOAD) ? rdata[126]:'z;
    assign data[119] = (io_T[1]==LOAD) ? rdata[119]:'z;
    assign data[117] = (io_T[1]==LOAD) ? rdata[117]:'z;
    assign data[120] = (io_T[1]==LOAD) ? rdata[120]:'z;
    assign data[125] = (io_T[1]==LOAD) ? rdata[125]:'z;

    assign data[109] = (io_T[2]==LOAD) ? rdata[109]:'z;
    assign data[105] = (io_T[2]==LOAD) ? rdata[105]:'z;
    assign data[114] = (io_T[2]==LOAD) ? rdata[114]:'z;
    assign data[ 74] = (io_T[2]==LOAD) ? rdata[ 74]:'z;
    assign data[ 72] = (io_T[2]==LOAD) ? rdata[ 72]:'z;
    assign data[ 71] = (io_T[2]==LOAD) ? rdata[ 71]:'z;
    assign data[ 70] = (io_T[2]==LOAD) ? rdata[ 70]:'z;
    assign data[ 73] = (io_T[2]==LOAD) ? rdata[ 73]:'z;
    assign data[ 86] = (io_T[2]==LOAD) ? rdata[ 86]:'z;
    assign data[ 84] = (io_T[2]==LOAD) ? rdata[ 84]:'z;
    assign data[ 78] = (io_T[2]==LOAD) ? rdata[ 78]:'z;
    assign data[ 76] = (io_T[2]==LOAD) ? rdata[ 76]:'z;
    assign data[ 87] = (io_T[2]==LOAD) ? rdata[ 87]:'z;
    assign data[ 92] = (io_T[2]==LOAD) ? rdata[ 92]:'z;
    assign data[111] = (io_T[2]==LOAD) ? rdata[111]:'z;
    assign data[103] = (io_T[2]==LOAD) ? rdata[103]:'z;
    assign data[112] = (io_T[2]==LOAD) ? rdata[112]:'z;
    assign data[ 89] = (io_T[2]==LOAD) ? rdata[ 89]:'z;
    assign data[ 90] = (io_T[2]==LOAD) ? rdata[ 90]:'z;
    assign data[ 88] = (io_T[2]==LOAD) ? rdata[ 88]:'z;
    assign data[ 75] = (io_T[2]==LOAD) ? rdata[ 75]:'z;
    assign data[ 85] = (io_T[2]==LOAD) ? rdata[ 85]:'z;

    assign data[ 97] = (io_T[3]==LOAD) ? rdata[ 97]:'z;
    assign data[110] = (io_T[3]==LOAD) ? rdata[110]:'z;
    assign data[108] = (io_T[3]==LOAD) ? rdata[108]:'z;
    assign data[115] = (io_T[3]==LOAD) ? rdata[115]:'z;
    assign data[101] = (io_T[3]==LOAD) ? rdata[101]:'z;
    assign data[100] = (io_T[3]==LOAD) ? rdata[100]:'z;
    assign data[107] = (io_T[3]==LOAD) ? rdata[107]:'z;
    assign data[106] = (io_T[3]==LOAD) ? rdata[106]:'z;
    assign data[ 83] = (io_T[3]==LOAD) ? rdata[ 83]:'z;
    assign data[ 94] = (io_T[3]==LOAD) ? rdata[ 94]:'z;
    assign data[ 99] = (io_T[3]==LOAD) ? rdata[ 99]:'z;
    assign data[ 96] = (io_T[3]==LOAD) ? rdata[ 96]:'z;
    assign data[ 95] = (io_T[3]==LOAD) ? rdata[ 95]:'z;
    assign data[104] = (io_T[3]==LOAD) ? rdata[104]:'z;
    assign data[102] = (io_T[3]==LOAD) ? rdata[102]:'z;
    assign data[113] = (io_T[3]==LOAD) ? rdata[113]:'z;
    assign data[ 98] = (io_T[3]==LOAD) ? rdata[ 98]:'z;
    assign data[ 79] = (io_T[3]==LOAD) ? rdata[ 79]:'z;
    assign data[ 77] = (io_T[3]==LOAD) ? rdata[ 77]:'z;
    assign data[ 81] = (io_T[3]==LOAD) ? rdata[ 81]:'z;
    assign data[ 82] = (io_T[3]==LOAD) ? rdata[ 82]:'z;
    assign data[ 80] = (io_T[3]==LOAD) ? rdata[ 80]:'z;
    assign data[ 93] = (io_T[3]==LOAD) ? rdata[ 93]:'z;
    assign data[ 91] = (io_T[3]==LOAD) ? rdata[ 91]:'z;

    assign data[ 21] = (io_T[4]==LOAD) ? rdata[ 21]:'z;
    assign data[ 35] = (io_T[4]==LOAD) ? rdata[ 35]:'z;
    assign data[ 37] = (io_T[4]==LOAD) ? rdata[ 37]:'z;
    assign data[ 61] = (io_T[4]==LOAD) ? rdata[ 61]:'z;
    assign data[ 63] = (io_T[4]==LOAD) ? rdata[ 63]:'z;
    assign data[ 69] = (io_T[4]==LOAD) ? rdata[ 69]:'z;
    assign data[ 43] = (io_T[4]==LOAD) ? rdata[ 43]:'z;
    assign data[ 29] = (io_T[4]==LOAD) ? rdata[ 29]:'z;
    assign data[ 34] = (io_T[4]==LOAD) ? rdata[ 34]:'z;
    assign data[ 39] = (io_T[4]==LOAD) ? rdata[ 39]:'z;
    assign data[ 28] = (io_T[4]==LOAD) ? rdata[ 28]:'z;
    assign data[ 65] = (io_T[4]==LOAD) ? rdata[ 65]:'z;
    assign data[ 50] = (io_T[4]==LOAD) ? rdata[ 50]:'z;
    assign data[ 59] = (io_T[4]==LOAD) ? rdata[ 59]:'z;
    assign data[ 57] = (io_T[4]==LOAD) ? rdata[ 57]:'z;
    assign data[ 56] = (io_T[4]==LOAD) ? rdata[ 56]:'z;
    assign data[ 67] = (io_T[4]==LOAD) ? rdata[ 67]:'z;
    assign data[ 48] = (io_T[4]==LOAD) ? rdata[ 48]:'z;
    assign data[ 55] = (io_T[4]==LOAD) ? rdata[ 55]:'z;
    assign data[ 23] = (io_T[4]==LOAD) ? rdata[ 23]:'z;
    assign data[ 40] = (io_T[4]==LOAD) ? rdata[ 40]:'z;
    assign data[ 41] = (io_T[4]==LOAD) ? rdata[ 41]:'z;
    assign data[ 47] = (io_T[4]==LOAD) ? rdata[ 47]:'z;
    assign data[ 45] = (io_T[4]==LOAD) ? rdata[ 45]:'z;
    assign data[ 54] = (io_T[4]==LOAD) ? rdata[ 54]:'z;

    assign data[ 26] = (io_T[5]==LOAD) ? rdata[ 26]:'z;
    assign data[ 31] = (io_T[5]==LOAD) ? rdata[ 31]:'z;
    assign data[ 46] = (io_T[5]==LOAD) ? rdata[ 46]:'z;
    assign data[ 42] = (io_T[5]==LOAD) ? rdata[ 42]:'z;
    assign data[ 66] = (io_T[5]==LOAD) ? rdata[ 66]:'z;
    assign data[ 53] = (io_T[5]==LOAD) ? rdata[ 53]:'z;
    assign data[ 51] = (io_T[5]==LOAD) ? rdata[ 51]:'z;
    assign data[ 36] = (io_T[5]==LOAD) ? rdata[ 36]:'z;
    assign data[ 38] = (io_T[5]==LOAD) ? rdata[ 38]:'z;
    assign data[ 64] = (io_T[5]==LOAD) ? rdata[ 64]:'z;
    assign data[ 27] = (io_T[5]==LOAD) ? rdata[ 27]:'z;
    assign data[ 30] = (io_T[5]==LOAD) ? rdata[ 30]:'z;
    assign data[ 22] = (io_T[5]==LOAD) ? rdata[ 22]:'z;
    assign data[ 62] = (io_T[5]==LOAD) ? rdata[ 62]:'z;
    assign data[ 60] = (io_T[5]==LOAD) ? rdata[ 60]:'z;
    assign data[ 44] = (io_T[5]==LOAD) ? rdata[ 44]:'z;
    assign data[ 33] = (io_T[5]==LOAD) ? rdata[ 33]:'z;
    assign data[ 52] = (io_T[5]==LOAD) ? rdata[ 52]:'z;
    assign data[ 20] = (io_T[5]==LOAD) ? rdata[ 20]:'z;
    assign data[ 25] = (io_T[5]==LOAD) ? rdata[ 25]:'z;
    assign data[ 24] = (io_T[5]==LOAD) ? rdata[ 24]:'z;
    assign data[ 58] = (io_T[5]==LOAD) ? rdata[ 58]:'z;
    assign data[ 49] = (io_T[5]==LOAD) ? rdata[ 49]:'z;
    assign data[ 68] = (io_T[5]==LOAD) ? rdata[ 68]:'z;
    assign data[ 32] = (io_T[5]==LOAD) ? rdata[ 32]:'z;

    assign data[ 18] = (io_T[6]==LOAD) ? rdata[ 18]:'z;
    assign data[ 14] = (io_T[6]==LOAD) ? rdata[ 14]:'z;
    assign data[  0] = (io_T[6]==LOAD) ? rdata[  0]:'z;
    assign data[  4] = (io_T[6]==LOAD) ? rdata[  4]:'z;
    assign data[ 16] = (io_T[6]==LOAD) ? rdata[ 16]:'z;
    assign data[ 12] = (io_T[6]==LOAD) ? rdata[ 12]:'z;
    assign data[  1] = (io_T[6]==LOAD) ? rdata[  1]:'z;
    assign data[ 10] = (io_T[6]==LOAD) ? rdata[ 10]:'z;
    assign data[  3] = (io_T[6]==LOAD) ? rdata[  3]:'z;
    assign data[  5] = (io_T[6]==LOAD) ? rdata[  5]:'z;
    assign data[  6] = (io_T[6]==LOAD) ? rdata[  6]:'z;
    assign data[  7] = (io_T[6]==LOAD) ? rdata[  7]:'z;
    assign data[  8] = (io_T[6]==LOAD) ? rdata[  8]:'z;
    assign data[  2] = (io_T[6]==LOAD) ? rdata[  2]:'z;

    assign data[  9] = (io_T[7]==LOAD) ? rdata[  9]:'z;
    assign data[ 13] = (io_T[7]==LOAD) ? rdata[ 13]:'z;
    assign data[ 15] = (io_T[7]==LOAD) ? rdata[ 15]:'z;
    assign data[ 11] = (io_T[7]==LOAD) ? rdata[ 11]:'z;
    assign data[ 17] = (io_T[7]==LOAD) ? rdata[ 17]:'z;
    assign data[ 19] = (io_T[7]==LOAD) ? rdata[ 19]:'z;
  

    assign wdata[121] = (io_T[0]==STORE) ? data[121]:'0;
    assign wdata[118] = (io_T[0]==STORE) ? data[118]:'0;
    assign wdata[123] = (io_T[0]==STORE) ? data[123]:'0;
    assign wdata[116] = (io_T[0]==STORE) ? data[116]:'0;
    assign wdata[127] = (io_T[0]==STORE) ? data[127]:'0;

    assign wdata[124] = (io_T[1]==STORE) ? data[124]:'0;
    assign wdata[122] = (io_T[1]==STORE) ? data[122]:'0;
    assign wdata[126] = (io_T[1]==STORE) ? data[126]:'0;
    assign wdata[119] = (io_T[1]==STORE) ? data[119]:'0;
    assign wdata[117] = (io_T[1]==STORE) ? data[117]:'0;
    assign wdata[120] = (io_T[1]==STORE) ? data[120]:'0;
    assign wdata[125] = (io_T[1]==STORE) ? data[125]:'0;

    assign wdata[109] = (io_T[2]==STORE) ? data[109]:'0;
    assign wdata[105] = (io_T[2]==STORE) ? data[105]:'0;
    assign wdata[114] = (io_T[2]==STORE) ? data[114]:'0;
    assign wdata[ 74] = (io_T[2]==STORE) ? data[ 74]:'0;
    assign wdata[ 72] = (io_T[2]==STORE) ? data[ 72]:'0;
    assign wdata[ 71] = (io_T[2]==STORE) ? data[ 71]:'0;
    assign wdata[ 70] = (io_T[2]==STORE) ? data[ 70]:'0;
    assign wdata[ 73] = (io_T[2]==STORE) ? data[ 73]:'0;
    assign wdata[ 86] = (io_T[2]==STORE) ? data[ 86]:'0;
    assign wdata[ 84] = (io_T[2]==STORE) ? data[ 84]:'0;
    assign wdata[ 78] = (io_T[2]==STORE) ? data[ 78]:'0;
    assign wdata[ 76] = (io_T[2]==STORE) ? data[ 76]:'0;
    assign wdata[ 87] = (io_T[2]==STORE) ? data[ 87]:'0;
    assign wdata[ 92] = (io_T[2]==STORE) ? data[ 92]:'0;
    assign wdata[111] = (io_T[2]==STORE) ? data[111]:'0;
    assign wdata[103] = (io_T[2]==STORE) ? data[103]:'0;
    assign wdata[112] = (io_T[2]==STORE) ? data[112]:'0;
    assign wdata[ 89] = (io_T[2]==STORE) ? data[ 89]:'0;
    assign wdata[ 90] = (io_T[2]==STORE) ? data[ 90]:'0;
    assign wdata[ 88] = (io_T[2]==STORE) ? data[ 88]:'0;
    assign wdata[ 75] = (io_T[2]==STORE) ? data[ 75]:'0;
    assign wdata[ 85] = (io_T[2]==STORE) ? data[ 85]:'0;

    assign wdata[ 97] = (io_T[3]==STORE) ? data[ 97]:'0;
    assign wdata[110] = (io_T[3]==STORE) ? data[110]:'0;
    assign wdata[108] = (io_T[3]==STORE) ? data[108]:'0;
    assign wdata[115] = (io_T[3]==STORE) ? data[115]:'0;
    assign wdata[101] = (io_T[3]==STORE) ? data[101]:'0;
    assign wdata[100] = (io_T[3]==STORE) ? data[100]:'0;
    assign wdata[107] = (io_T[3]==STORE) ? data[107]:'0;
    assign wdata[106] = (io_T[3]==STORE) ? data[106]:'0;
    assign wdata[ 83] = (io_T[3]==STORE) ? data[ 83]:'0;
    assign wdata[ 94] = (io_T[3]==STORE) ? data[ 94]:'0;
    assign wdata[ 99] = (io_T[3]==STORE) ? data[ 99]:'0;
    assign wdata[ 96] = (io_T[3]==STORE) ? data[ 96]:'0;
    assign wdata[ 95] = (io_T[3]==STORE) ? data[ 95]:'0;
    assign wdata[104] = (io_T[3]==STORE) ? data[104]:'0;
    assign wdata[102] = (io_T[3]==STORE) ? data[102]:'0;
    assign wdata[113] = (io_T[3]==STORE) ? data[113]:'0;
    assign wdata[ 98] = (io_T[3]==STORE) ? data[ 98]:'0;
    assign wdata[ 79] = (io_T[3]==STORE) ? data[ 79]:'0;
    assign wdata[ 77] = (io_T[3]==STORE) ? data[ 77]:'0;
    assign wdata[ 81] = (io_T[3]==STORE) ? data[ 81]:'0;
    assign wdata[ 82] = (io_T[3]==STORE) ? data[ 82]:'0;
    assign wdata[ 80] = (io_T[3]==STORE) ? data[ 80]:'0;
    assign wdata[ 93] = (io_T[3]==STORE) ? data[ 93]:'0;
    assign wdata[ 91] = (io_T[3]==STORE) ? data[ 91]:'0;

    assign wdata[ 21] = (io_T[4]==STORE) ? data[ 21]:'0;
    assign wdata[ 35] = (io_T[4]==STORE) ? data[ 35]:'0;
    assign wdata[ 37] = (io_T[4]==STORE) ? data[ 37]:'0;
    assign wdata[ 61] = (io_T[4]==STORE) ? data[ 61]:'0;
    assign wdata[ 63] = (io_T[4]==STORE) ? data[ 63]:'0;
    assign wdata[ 69] = (io_T[4]==STORE) ? data[ 69]:'0;
    assign wdata[ 43] = (io_T[4]==STORE) ? data[ 43]:'0;
    assign wdata[ 29] = (io_T[4]==STORE) ? data[ 29]:'0;
    assign wdata[ 34] = (io_T[4]==STORE) ? data[ 34]:'0;
    assign wdata[ 39] = (io_T[4]==STORE) ? data[ 39]:'0;
    assign wdata[ 28] = (io_T[4]==STORE) ? data[ 28]:'0;
    assign wdata[ 65] = (io_T[4]==STORE) ? data[ 65]:'0;
    assign wdata[ 50] = (io_T[4]==STORE) ? data[ 50]:'0;
    assign wdata[ 59] = (io_T[4]==STORE) ? data[ 59]:'0;
    assign wdata[ 57] = (io_T[4]==STORE) ? data[ 57]:'0;
    assign wdata[ 56] = (io_T[4]==STORE) ? data[ 56]:'0;
    assign wdata[ 67] = (io_T[4]==STORE) ? data[ 67]:'0;
    assign wdata[ 48] = (io_T[4]==STORE) ? data[ 48]:'0;
    assign wdata[ 55] = (io_T[4]==STORE) ? data[ 55]:'0;
    assign wdata[ 23] = (io_T[4]==STORE) ? data[ 23]:'0;
    assign wdata[ 40] = (io_T[4]==STORE) ? data[ 40]:'0;
    assign wdata[ 41] = (io_T[4]==STORE) ? data[ 41]:'0;
    assign wdata[ 47] = (io_T[4]==STORE) ? data[ 47]:'0;
    assign wdata[ 45] = (io_T[4]==STORE) ? data[ 45]:'0;
    assign wdata[ 54] = (io_T[4]==STORE) ? data[ 54]:'0;

    assign wdata[ 26] = (io_T[5]==STORE) ? data[ 26]:'0;
    assign wdata[ 31] = (io_T[5]==STORE) ? data[ 31]:'0;
    assign wdata[ 46] = (io_T[5]==STORE) ? data[ 46]:'0;
    assign wdata[ 42] = (io_T[5]==STORE) ? data[ 42]:'0;
    assign wdata[ 66] = (io_T[5]==STORE) ? data[ 66]:'0;
    assign wdata[ 53] = (io_T[5]==STORE) ? data[ 53]:'0;
    assign wdata[ 51] = (io_T[5]==STORE) ? data[ 51]:'0;
    assign wdata[ 36] = (io_T[5]==STORE) ? data[ 36]:'0;
    assign wdata[ 38] = (io_T[5]==STORE) ? data[ 38]:'0;
    assign wdata[ 64] = (io_T[5]==STORE) ? data[ 64]:'0;
    assign wdata[ 27] = (io_T[5]==STORE) ? data[ 27]:'0;
    assign wdata[ 30] = (io_T[5]==STORE) ? data[ 30]:'0;
    assign wdata[ 22] = (io_T[5]==STORE) ? data[ 22]:'0;
    assign wdata[ 62] = (io_T[5]==STORE) ? data[ 62]:'0;
    assign wdata[ 60] = (io_T[5]==STORE) ? data[ 60]:'0;
    assign wdata[ 44] = (io_T[5]==STORE) ? data[ 44]:'0;
    assign wdata[ 33] = (io_T[5]==STORE) ? data[ 33]:'0;
    assign wdata[ 52] = (io_T[5]==STORE) ? data[ 52]:'0;
    assign wdata[ 20] = (io_T[5]==STORE) ? data[ 20]:'0;
    assign wdata[ 25] = (io_T[5]==STORE) ? data[ 25]:'0;
    assign wdata[ 24] = (io_T[5]==STORE) ? data[ 24]:'0;
    assign wdata[ 58] = (io_T[5]==STORE) ? data[ 58]:'0;
    assign wdata[ 49] = (io_T[5]==STORE) ? data[ 49]:'0;
    assign wdata[ 68] = (io_T[5]==STORE) ? data[ 68]:'0;
    assign wdata[ 32] = (io_T[5]==STORE) ? data[ 32]:'0;

    assign wdata[ 18] = (io_T[6]==STORE) ? data[ 18]:'0;
    assign wdata[ 14] = (io_T[6]==STORE) ? data[ 14]:'0;
    assign wdata[  0] = (io_T[6]==STORE) ? data[  0]:'0;
    assign wdata[  4] = (io_T[6]==STORE) ? data[  4]:'0;
    assign wdata[ 16] = (io_T[6]==STORE) ? data[ 16]:'0;
    assign wdata[ 12] = (io_T[6]==STORE) ? data[ 12]:'0;
    assign wdata[  1] = (io_T[6]==STORE) ? data[  1]:'0;
    assign wdata[ 10] = (io_T[6]==STORE) ? data[ 10]:'0;
    assign wdata[  3] = (io_T[6]==STORE) ? data[  3]:'0;
    assign wdata[  5] = (io_T[6]==STORE) ? data[  5]:'0;
    assign wdata[  6] = (io_T[6]==STORE) ? data[  6]:'0;
    assign wdata[  7] = (io_T[6]==STORE) ? data[  7]:'0;
    assign wdata[  8] = (io_T[6]==STORE) ? data[  8]:'0;
    assign wdata[  2] = (io_T[6]==STORE) ? data[  2]:'0;

    assign wdata[  9] = (io_T[7]==STORE) ? data[  9]:'0;
    assign wdata[ 13] = (io_T[7]==STORE) ? data[ 13]:'0;
    assign wdata[ 15] = (io_T[7]==STORE) ? data[ 15]:'0;
    assign wdata[ 11] = (io_T[7]==STORE) ? data[ 11]:'0;
    assign wdata[ 17] = (io_T[7]==STORE) ? data[ 17]:'0;
    assign wdata[ 19] = (io_T[7]==STORE) ? data[ 19]:'0;
   

    /* Decode in/out port signal */ 
    assign start_layer         = w_start_layer;
    assign axready             = w_axready;
    assign rvalid_or_wready    = w_rvalid_or_wready;

    assign w_axready           = buf0_axi_axready;
    assign w_rvalid_or_wready  = buf1_axi_rvalid_or_buf0_axi_wready;
    assign rdata               = buf1_axi_rdata_pos;
    // assign chip_axi_rvalid     = single_rate ? buf1_axi_rvalid : buf0_axi_rvalid;   // do not use single-rate


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
    always @(posedge clk_for_chip or negedge rstn) begin
        if (~rstn) begin
            // output - stage1
            buf0_axi_axready                   <= 'd0;
            buf0_axi_rvalid                    <= 'd0;
            buf1_axi_rvalid_or_buf0_axi_wready <= 'd0;
            buf0_axi_rdata                     <= 'd0;    // 128b
        
            buf1_axi_rdata_pos                 <= 'd0;    // 128b
        end
        else begin

            // output
            buf0_axi_axready                   <= (buf0_load_or_store[7]==LOAD) ? fifo_axi_arready : fifo_axi_awready;
            buf0_axi_rvalid                    <= fifo_axi_rvalid;
            buf1_axi_rvalid_or_buf0_axi_wready <= (buf0_load_or_store[7]==LOAD) ? buf0_axi_rvalid : fifo_axi_wready;
            buf0_axi_rdata                     <= fifo_axi_rdata;

            buf1_axi_rdata_pos <= buf0_axi_rvalid ? buf0_axi_rdata[255:128] : buf0_axi_rdata[127:0];
            // if (single_rate) begin
                // buf1_axi_rdata_pos <= buf0_axi_rvalid ? buf0_axi_rdata[255:128] : buf0_axi_rdata[127:0];
            // end
            // else begin
            // buf1_axi_rdata_pos <= buf0_axi_rdata[255:128];
            // end
        end
    end


    always @(posedge clk_for_chip or negedge rstn) begin
        if (~rstn) begin
            // delay for axaddr_and_axlen
            ax_delay                  <= 'd0;

            // input - stage0
            buf0_done_layer           <= 'd0;
            buf0_load_or_store        <= {8{LOAD}};
            buf0_store_byte4          <= 'd0;
            buf0_axvalid              <= 'd0;
            buf0_axaddr_and_axlen     <= 'd0;
            buf0_rready_or_wvalid     <= 'd0;
            buf0_wdata_pos            <= 'd0;


            // input - stage1
            buf1_done_layer           <= 'd0;
            buf1_load_or_store        <= {8{LOAD}};
            buf1_store_byte4          <= 'd0;
            buf1_axi_awaddr           <= 'd0;
            buf1_axi_awlen            <= 'd0;
            buf1_axi_awvalid          <= 'd0;
            buf1_axi_wdata            <= 'd0;    // 256b
            buf1_axi_wvalid           <= 'd0;
            buf1_axi_araddr           <= 'd0;
            buf1_axi_arlen            <= 'd0;
            buf1_axi_arvalid          <= 'd0;
            buf1_axi_rready           <= 'd0;

            // input - stage2  
            // to synchronize with time-unrolled axaddr & axlen
            buf2_store_byte4          <= 'd0;
            buf2_axi_awvalid          <= 'd0;
            buf2_axi_arvalid          <= 'd0;

            // input - stage3  
            // to synchronize with time-unrolled axaddr & axlen
            buf3_store_byte4          <= 'd0;
            buf3_axi_awvalid          <= 'd0;
            buf3_axi_arvalid          <= 'd0;
        end
        else begin
            // input - stage0 (directly capture)
            buf0_done_layer       <= done_layer;
            buf0_load_or_store    <= {8{load_or_store}};
            buf0_store_byte4      <= store_byte4;
            buf0_axvalid          <= axvalid;
            buf0_axaddr_and_axlen <= axaddr_and_axlen;
            buf0_rready_or_wvalid <= rready_or_wvalid;
            buf0_wdata_pos        <= wdata;


            // input - stage1
            buf1_done_layer       <= buf0_done_layer;
            buf1_load_or_store    <= buf0_load_or_store;
            buf1_store_byte4      <= buf0_store_byte4;

            if (buf0_axvalid) begin
                // set axaddr[11:0]
                if (buf0_load_or_store[3]==LOAD) begin   
                    ax_delay              <= ax_delay + 2'd1;
                    buf1_axi_araddr[11:0] <= buf0_axaddr_and_axlen;
                    buf1_axi_arlen        <= 'd0;
                    buf1_axi_awaddr       <= 'd0;
                    buf1_axi_awlen        <= 'd0;
                end
                else begin
                    ax_delay              <= ax_delay + 2'd1;
                    buf1_axi_araddr       <= 'd0;
                    buf1_axi_arlen        <= 'd0;
                    buf1_axi_awaddr[11:0] <= buf0_axaddr_and_axlen;
                    buf1_axi_awlen        <= 'd0;
                end
            end
            else if (ax_delay==2'd1) begin
                // set axaddr[23:12]
                if (buf0_load_or_store[3]==LOAD) begin   
                    ax_delay               <= ax_delay + 2'd1;
                    buf1_axi_araddr[23:12] <= buf0_axaddr_and_axlen;
                    buf1_axi_arlen         <= 'd0;
                    buf1_axi_awaddr        <= 'd0;
                    buf1_axi_awlen         <= 'd0;
                end
                else begin
                    ax_delay               <= ax_delay + 2'd1;
                    buf1_axi_araddr        <= 'd0;
                    buf1_axi_arlen         <= 'd0;
                    buf1_axi_awaddr[23:12] <= buf0_axaddr_and_axlen;
                    buf1_axi_awlen         <= 'd0;
                end
            end
            else if (ax_delay==2'd2) begin
                // set axaddr[27:24] & axlen
                if (buf0_load_or_store[3]==LOAD) begin   
                    ax_delay               <= 2'd0;
                    buf1_axi_araddr[27:24] <= buf0_axaddr_and_axlen[3:0];
                    buf1_axi_arlen         <= buf0_axaddr_and_axlen[11:4];
                    buf1_axi_awaddr        <= 'd0;
                    buf1_axi_awlen         <= 'd0;
                end
                else begin
                    ax_delay               <= 2'd0;
                    buf1_axi_araddr        <= 'd0;
                    buf1_axi_arlen         <= 'd0;
                    buf1_axi_awaddr[27:24] <= buf0_axaddr_and_axlen[3:0];
                    buf1_axi_awlen         <= buf0_axaddr_and_axlen[11:4];
                end
            end
            else begin
                ax_delay               <= 'd0;
                buf1_axi_araddr        <= 'd0;
                buf1_axi_arlen         <= 'd0;
                buf1_axi_awaddr        <= 'd0;
                buf1_axi_awlen         <= 'd0;
            end

            buf1_axi_awvalid   <= (buf0_load_or_store[6]==STORE) ? buf0_axvalid : 0;
            buf1_axi_wvalid    <= (buf0_load_or_store[7]==STORE) ? buf0_rready_or_wvalid: 0;
            buf1_axi_arvalid   <= (buf0_load_or_store[6]==LOAD) ? buf0_axvalid : 0;
            buf1_axi_rready    <= (buf0_load_or_store[7]==LOAD) ? buf0_rready_or_wvalid: 0;

            // if (single_rate) begin
            //     if ((buf0_load_or_store[3]==STORE) && (buf0_axi_rready_or_wvalid==1)) 
            //         buf1_axi_wdata[255:128] <= buf0_axi_wdata_pos;
            //     else                   
            //         buf1_axi_wdata[127:  0] <= buf0_axi_wdata_pos;
            // end

            if (buf0_rready_or_wvalid==1) begin
                buf1_axi_wdata[255:128] <= buf0_wdata_pos;
            end
            else begin
                buf1_axi_wdata[127:  0] <= buf0_wdata_pos;
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



    //************************************************************
    // FIFOs between Chip <-> MIG
    //************************************************************

    /* Reset for FIFOs */ 
    wire         fifo_rst;

    reg          rready_toggle;

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
    assign awaddr_fifo_rd_en = mig_axi_awready;

    assign araddr_fifo_wr_en = fifo_axi_arvalid && (!araddr_fifo_full);
    assign araddr_fifo_rd_en = mig_axi_arready;

    assign wdata_fifo_wr_en  = fifo_axi_wvalid && (!wdata_fifo_full);
    assign wdata_fifo_rd_en  = mig_axi_wready;

    // assign rdata_fifo_wr_en  = mig_axi_rvalid_tmp && (!rdata_fifo_full);
    assign rdata_fifo_wr_en  = mig_axi_rvalid && (!rdata_fifo_full);
    // assign rdata_fifo_rd_en  = fifo_axi_rready;
    assign rdata_fifo_rd_en  = fifo_axi_rready && (~rready_toggle);

    always @(posedge clk_for_chip or negedge rstn) begin
        if (~rstn) begin
            rready_toggle <= 1'b1;   // init to 1'b1
        end
        else begin
            if (~rready_toggle) rready_toggle <= 1'b1;
            else if (fifo_axi_rready && rdata_fifo_valid) rready_toggle <= 1'b0;
        end
    end

    assign awaddr_fifo_din   = {buf3_store_byte4, fifo_axi_awvalid, fifo_axi_awlen, fifo_axi_awaddr};   //  38-bit
    assign araddr_fifo_din   = {1'b0, fifo_axi_arvalid, fifo_axi_arlen, fifo_axi_araddr};          //  38-bit
    assign wdata_fifo_din    = {fifo_axi_wvalid, fifo_axi_wdata};                                  // 257-bit
    assign rdata_fifo_din    = {mig_axi_rvalid, mig_axi_rdata};                                    // 257-bit

    assign {mig_store_byte4, mig_axi_awvalid, mig_axi_awlen, mig_axi_awaddr} = awaddr_fifo_rd_en && awaddr_fifo_valid ? awaddr_fifo_dout : 'd0;
    assign {mig_axi_arvalid, mig_axi_arlen, mig_axi_araddr} = araddr_fifo_rd_en && araddr_fifo_valid ? araddr_fifo_dout[36:0] : 'd0;

    assign mig_axi_wvalid   = wdata_fifo_rd_en && wdata_fifo_valid && wdata_fifo_dout[256];
    assign mig_axi_wdata    = wdata_fifo_dout[255:0];
    // assign fifo_axi_rvalid  = rdata_fifo_rd_en && rdata_fifo_valid && rdata_fifo_dout[256]; 
    assign fifo_axi_rvalid  = (~rready_toggle); 
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
        .wait_chip_cnt     (wait_chip_cnt    ),
        .infinite_loop     (infinite_loop    ),
        .done_network      (done_network     ),
        .done_network_cnt  (done_network_cnt ),
        .done_layer        (buf0_done_layer  ),
        .clk_cnt           (clk_cnt          )
    );


    //************************************************************
    // Measure AXI Read Delay for test
    //************************************************************
    // localparam S_DEBUG_IDLE = 2'd0;
    // localparam S_DEBUG_READ_START = 2'd1;
    // localparam S_DEBUG_READ_END = 2'd2;

    // reg [1:0]  state_debug;
    // reg [31:0] chip_axi_read_delay;
    // assign chip_axi_read_delay_out = chip_axi_read_delay;

    // always @(posedge clk_for_chip or negedge rstn) begin
    //     if (~rstn) begin
    //         state_debug <= S_DEBUG_IDLE;
    //     end
    //     else begin
    //         case (state_debug) 
    //             S_DEBUG_IDLE: begin
    //                 if (buf1_axi_arvalid) state_debug <= S_DEBUG_READ_START;
    //                 else                  state_debug <= S_DEBUG_IDLE;
    //             end
    //             S_DEBUG_READ_START: begin
    //                 if (chip_axi_rvalid) state_debug <= S_DEBUG_READ_END;
    //                 else                 state_debug <= S_DEBUG_READ_START;
    //             end
    //             S_DEBUG_READ_END: begin
    //                 // if (chip_axi_wvalid) state_debug <= S_DEBUG_IDLE;
    //                 // else                 state_debug <= S_DEBUG_READ_END;
    //             end
    //         endcase
    //     end
    // end

    // always @(posedge clk_for_chip or negedge rstn) begin
    //     if (~rstn) begin
    //         chip_axi_read_delay <= 32'd0; 
    //     end
    //     else begin
    //         case (state_debug) 
    //             S_DEBUG_IDLE: begin
    //                 if (buf1_axi_arvalid) chip_axi_read_delay <= chip_axi_read_delay + 32'd1;
    //                 else                  chip_axi_read_delay <= 32'd0;
    //             end
    //             S_DEBUG_READ_START: begin
    //                 if (!chip_axi_rvalid) chip_axi_read_delay <= chip_axi_read_delay + 32'd1;
    //             end
    //             S_DEBUG_READ_END: begin
    //             end
    //         endcase
    //     end
    // end


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
            if (fifo_axi_arready) arready_cnt <= arready_cnt + 8'd1;
            if (fifo_axi_awready) awready_cnt <= awready_cnt + 8'd1;
        end
    end

    always @(posedge clk_for_chip or negedge rstn) begin
        if (~rstn) begin
            start_cnt   <= 8'd0;
            done_cnt    <= 8'd0;
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
            if (w_start_layer) start_cnt <= start_cnt + 8'd1;
            if (buf0_done_layer) done_cnt <= done_cnt + 8'd1;

            if (fifo_axi_arready && fifo_axi_arvalid) arvalid_cnt <= arvalid_cnt + 32'd1;
            if (fifo_axi_awready && fifo_axi_awvalid) awvalid_cnt <= awvalid_cnt + 32'd1;

            if (fifo_axi_rready && fifo_axi_rvalid) rvalid_cnt  <= rvalid_cnt + 32'd1;
            if (fifo_axi_wready && fifo_axi_wvalid) wvalid_cnt  <= wvalid_cnt + 32'd1;


            if (fifo_axi_arready && fifo_axi_arvalid) araddr_hist[arvalid_cnt[5:0]] <= fifo_axi_araddr;  // 1st 64 araddr
            if (fifo_axi_awready && fifo_axi_awvalid) awaddr_hist[awvalid_cnt[5:0]] <= fifo_axi_awaddr;  // 1st 64 awaddr

            if (fifo_axi_arready && fifo_axi_arvalid) arlen_hist[arvalid_cnt[5:0]] <= fifo_axi_arlen;  // 1st 64 arlen
            if (fifo_axi_awready && fifo_axi_awvalid) awlen_hist[awvalid_cnt[5:0]] <= fifo_axi_awlen;  // 1st 64 awlen

            //if (chip_axi_rvalid && rvalid_cnt[7:6]==2'd0) rdata_hist[rvalid_cnt[5:0]][255:128] <= chip_axi_rdata;  // 1st 64 rdata
            //else if (rvalid_cnt[7:6]==2'd0)               rdata_hist[rvalid_cnt[5:0]][127:0]   <= chip_axi_rdata;  // 1st 64 rdata

            // if (fifo_axi_rvalid && rvalid_cnt[7:6]==2'd0) rdata_hist[rvalid_cnt[5:0]] <= fifo_axi_rdata;  // 1st 64 rdata
            


        end
    end

    `ifdef DEBUG_FIFO

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

    assign debug_fifo_chip2fpga_din       = reordering_256b({111'd0, done_layer, buf0_load_or_store[4], store_byte4, axaddr_and_axlen, axvalid, rready_or_wvalid, wdata});
    // assign debug_fifo_chip2fpga_din       = reordering_256b(256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f);   // for test
    assign debug_fifo_chip2fpga_wr_en     = after_start && (!debug_fifo_chip2fpga_full);
    // assign debug_fifo_chip2fpga_wr_en     = start_debug && after_start && (!debug_fifo_chip2fpga_full); //debug
    assign debug_fifo_chip2fpga_rd_en     = debug_fifo_chip2fpga_read && (!debug_fifo_chip2fpga_empty) && pipe_out_ready_debug_chip2fpga_buf;
    assign debug_fifo_chip2fpga_rd_en_out = debug_fifo_chip2fpga_rd_en;
    assign pipe_dout_debug_chip2fpga      = debug_fifo_chip2fpga_dout;
    assign pipe_out_valid_debug_chip2fpga = debug_fifo_chip2fpga_valid;


    assign debug_fifo_axaddr_din          = (buf1_load_or_store[4] == LOAD) ? reordering_64b({27'd0, LOAD, fifo_axi_arlen, fifo_axi_araddr}) : reordering_64b({27'd0, STORE, fifo_axi_awlen, fifo_axi_awaddr});
    // assign debug_fifo_axaddr_din          = 64'h0001020304050607;   // for test
    assign debug_fifo_axaddr_wr_en        = (buf1_load_or_store[4] == LOAD) ? fifo_axi_arvalid : fifo_axi_awvalid;
    // assign debug_fifo_axaddr_wr_en        = (start_cnt >= 10) ? ((buf1_load_or_store[4] == LOAD) ? fifo_axi_arvalid : fifo_axi_awvalid) : 1'b0;
    assign debug_fifo_axaddr_rd_en        = debug_fifo_axaddr_read && (!debug_fifo_axaddr_empty) && pipe_out_ready_debug_axaddr_buf;
    assign debug_fifo_axaddr_rd_en_out    = debug_fifo_axaddr_rd_en;
    assign pipe_dout_debug_axaddr         = debug_fifo_axaddr_dout;
    assign pipe_out_valid_debug_axaddr    = debug_fifo_axaddr_valid;


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
            if      (w_start_layer && (!stop)) ttf_axvalid <= ttf_axvalid + 4'd1;
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


    // /* FIFO for axaddr and axlen handshaking debugging */
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

    /* FIFO for axaddr and axlen handshaking debugging */
    // debug_fifo_w64_131072_r32_262144 u_debug_fifo_axaddr0 (
    //     .rstn               (rstn                       ),
    //     .wr_clk             (clk_for_chip               ),
    //     .rd_clk             (okClk                      ),
    //     .din                (debug_fifo_axaddr_din      ),
    //     .wr_en              (debug_fifo_axaddr_wr_en    ),
    //     .rd_en              (debug_fifo_axaddr_rd_en    ),
    //     .dout               (debug_fifo_axaddr_dout     ),
    //     .full               (debug_fifo_axaddr_full     ),
    //     .empty              (debug_fifo_axaddr_empty    ),
    //     .valid              (debug_fifo_axaddr_valid    ),
    //     .prog_full          ()
    // );



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

    `endif



    //************************************************************
    // load_or_store 
    //************************************************************

    // reg wstate;
    // localparam IDLE = 0;
    // localparam WRITE = 1;

    // always @(posedge clk_for_chip or negedge rstn) begin
    //     if (~rstn) begin
    //         wstate <= IDLE;
    //     end
    //     else begin
    //         case (wstate)
    //             IDLE: begin
    //                 if ((load_or_store==STORE) && axvalid) wstate <= WRITE;
    //                 else wstate <= IDLE;
    //             end
    //             WRITE: begin
    //                 if (wdone || mig_abort) wstate <= IDLE;
    //                 else wstate <= WRITE;
    //             end
    //         endcase
    //     end
    // end

    // always @(posedge clk_for_chip or negedge rstn) begin
    //     if (~rstn) begin
    //         wcnt <= 8'd0;
    //     end
    //     else begin
    //         case (wstate)
    //             IDLE: begin
    //                 if ((load_or_store==STORE) && axvalid) wcnt <= wcnt + 8'd1;
    //                 else wcnt <= 8'd0;
    //             end
    //             WRITE: begin
    //                 if (wdone || mig_abort) wstate <= IDLE;
    //                 else wstate <= WRITE;
    //             end
    //         endcase
    //     end
    // end



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