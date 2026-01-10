module main_chip_clean(
    // ok signals
    input  wire [4:0]   okUH,
	output wire [2:0]   okHU,
	inout  wire [31:0]  okUHU,
	inout  wire         okAA,

	input  wire         sys_clkp,
	input  wire         sys_clkn,
	
	output wire [3:0]   led,
	
    // ddr signals
	inout  wire [31:0]  ddr3_dq,
	output wire [15:0]  ddr3_addr,
	output wire [2 :0]  ddr3_ba,
	output wire [0 :0]  ddr3_ck_p,
	output wire [0 :0]  ddr3_ck_n,
	output wire [0 :0]  ddr3_cke,
	output wire [0 :0]  ddr3_cs_n,
	output wire         ddr3_cas_n,
	output wire         ddr3_ras_n,
	output wire         ddr3_we_n,
	output wire [0 :0]  ddr3_odt,
	output wire [3 :0]  ddr3_dm,
	inout  wire [3 :0]  ddr3_dqs_p,
	inout  wire [3 :0]  ddr3_dqs_n,
	output wire         ddr3_reset_n,

    // Chip Input
    input clk,  // clk input (chip clk)
    output rstn,
    output reg data_vld,
    output reg execute,
    output encrypt,
    output generate_keys,
    output  dram_read_ready,
    output  dram_write_ready,

    // Chip Output
    input done,
    input addr_wvalid,
    input [20 - 1:0] dram_addr,
    input command_type,

    // Chip Data
    inout [128 - 1:0] data
);

//phase delayed clock for FPGA
wire clk_dly;
assign clk_dly = clk ;
//clk_wiz_1 inst_clk_wiz (.clk_in1(clk), .clk_out1(clk_dly));
//IBUFGDS osc_clk(.O(clk_dly), .I(sys_clkp), .IB(sys_clkn));

// Buffering
wire            data_vld_d;
reg            data_vld_2d; //2-stage buffering to turn on data_vld one-cycle before data_to_chip

reg             done_q;
reg             addr_wvalid_q;
reg             addr_wvalid_2q; //2-stage buffering because addr_wvalid is turned on one-cycle before data_from_chip
reg [20 - 1:0]  dram_addr_q;
reg             is_read_q;

//// NOTICE
assign dram_read_ready = 1'b1;
assign dram_write_ready = 1'b1;

always @(posedge clk_dly) begin
    if(rst) begin
        data_vld <= 1'b0;
        data_vld_2d <= 1'b0;
        //dram_read_ready <= 1'b0;
        //dram_write_ready <= 1'b0;
        done_q <= 1'b0;
        addr_wvalid_q <= 1'b0;
        addr_wvalid_2q <= 1'b0;
        dram_addr_q <= 20'b0;
        is_read_q <= 1'b0;
    end
    else begin
        data_vld_2d <= data_vld_d;
        data_vld <= data_vld_2d || data_vld_d; //turn on data_vld one-cycle before data_to_chip
        //if(init_calib_complete & app_rdy) dram_read_ready <= 1'b1;  //just keep it on.. or else src code doesn't work properly
        //if(init_calib_complete & app_rdy & app_wdf_rdy) dram_write_ready <= 1'b1 ;
        done_q <= done;
        addr_wvalid_q <= addr_wvalid;
        addr_wvalid_2q <= addr_wvalid_q;
        dram_addr_q <= dram_addr;
        is_read_q <= ~command_type;
    end
end

// MIG signals:
wire                init_calib_complete;

wire	[30 - 1:0]	app_addr;
wire	[3 - 1:0] 	app_cmd;
wire	         	app_en;
wire	         	app_rdy;
wire	[256 - 1:0] app_rd_data;
wire	         	app_rd_data_end;
wire	         	app_rd_data_valid;
wire	[256 - 1:0] app_wdf_data;
wire	         	app_wdf_end;
wire	[32 - 1:0]  app_wdf_mask;
wire	         	app_wdf_rdy;
wire	         	app_wdf_wren;

wire          		ui_clk;
wire          		ui_rst;

// Target interface bus:
wire         	    okClk;
wire    [112:0]     okHE;
wire    [64:0]      okEH;

// Endpoint connections:
wire    [32 - 1:0]  wirein00_wire;  // rstn
wire    [32 - 1:0]  wirein01_wire;  // sel_chip
wire    [32 - 1:0]  wirein02_wire;  // encrypt, generate_keys

wire                rstn_buf = wirein00_wire[0];
wire                rst = ~rstn_buf;
assign              rstn = rstn_buf;  // chip reset

wire                sel_chip_buf = wirein01_wire[0];
wire                sel_chip = sel_chip_buf;

wire                encrypt_buf = wirein02_wire[0];
wire                generate_keys_buf = wirein02_wire[1];
assign              encrypt = encrypt_buf;  //should set this signal faster than execute signal
assign              generate_keys = generate_keys_buf;

wire    [32 - 1:0]  trigin40_wire;  // execute;
wire                execute_buf = trigin40_wire[0];

wire    [32 - 1:0]  trigout60_wire;
assign  trigout60_wire = {31'b0, done_q};

//// NOTICE:
always @(posedge clk_dly) begin
    if(rst) begin
        execute <= 1'b0;
    end
    else begin
        execute <= 1'b0;  //on for 1 cycle
        if(execute_buf) begin
            execute <= 1'b1;
        end
    end
end


wire    [32 - 1:0]  pipe_in_data;
wire                pipe_in_valid;
reg                 pipe_in_ready;

wire                pipe_out_read;
wire    [32 - 1:0]  pipe_out_data;
reg                 pipe_out_ready;


// INOUT signals:
wire    [128 - 1:0] data_from_chip;
wire    [128 - 1:0] data_to_chip;

// P2F FIFO signals:
wire                p2f_fifo_full;
wire                p2f_fifo_wr_en = pipe_in_valid;
wire    [32 - 1:0]  p2f_fifo_din = pipe_in_data;
wire                p2f_fifo_empty;
wire                p2f_fifo_rd_en;
wire    [256 - 1:0] p2f_fifo_dout;
wire                p2f_fifo_dout_valid;
wire    [10 - 1:0]  p2f_fifo_wr_data_count;
wire    [7 - 1:0]   p2f_fifo_rd_data_count;


// F2P FIFO signals:
wire                f2p_fifo_full;
wire                f2p_fifo_wr_en;
wire    [128 - 1:0] f2p_fifo_din;
wire                f2p_fifo_empty;
wire                f2p_fifo_rd_en = pipe_out_read;
wire    [32 - 1:0]  f2p_fifo_dout;
wire                f2p_fifo_dout_valid;
wire    [8 - 1:0]   f2p_fifo_wr_data_count;
wire    [10 - 1:0]  f2p_fifo_rd_data_count;

assign pipe_out_data = f2p_fifo_dout;

always @(posedge okClk) begin
    if(p2f_fifo_wr_data_count <= 10'd1000) begin
        pipe_in_ready <= 1'b1;
    end
    else begin
        pipe_in_ready <= 1'b0;
    end
end

always @(posedge okClk) begin
    if(f2p_fifo_rd_data_count >= 10'd4) begin
        // 4 sequential read
        pipe_out_ready <= 1'b1;
    end
    else begin
        pipe_out_ready <= 1'b0;
    end
end

//// C2F FIFO signals:
wire                c2f_fifo_full;
wire                c2f_fifo_wr_en = addr_wvalid_q & addr_wvalid_2q ;  // turn on c2f_fifo_wr_en at the same cycle with c2f_fifo_din
wire    [149 - 1:0] c2f_fifo_din;
wire                c2f_fifo_empty;
wire                c2f_fifo_rd_en;
wire    [149 - 1:0] c2f_fifo_dout;
wire                c2f_fifo_dout_valid;
wire    [10 - 1:0]  c2f_fifo_wr_data_count;
wire    [10 - 1:0]  c2f_fifo_rd_data_count;

//// F2C FIFO signals:
wire                f2c_fifo_full;
wire                f2c_fifo_wr_en;
wire    [128 - 1:0] f2c_fifo_din;
wire                f2c_fifo_empty;
//wire                f2c_fifo_rd_en = is_read_q;
reg                 f2c_fifo_rd_en;
wire    [128 - 1:0] f2c_fifo_dout;
wire                f2c_fifo_dout_valid;
wire    [11 - 1:0]  f2c_fifo_wr_data_count;
wire    [11 - 1:0]  f2c_fifo_rd_data_count;

wire    [128 - 1:0] f2c_data;  // FPGA to chip
wire    [128 - 1:0] c2f_data;  // chip to FPGA

reg     [128 - 1:0] f2c_data_q;
reg     [128 - 1:0] f2c_data_2q;
reg     [128 - 1:0] c2f_data_q;

//to keep data_vld continuous (chip doesn't support un-continuous data_vld)
always @(posedge clk_dly) begin
    if(rst) begin
        f2c_fifo_rd_en <= 'd0;
    end 
    else if (sel_chip == 1'b1) begin //change init_calib_complete to sel_chip!! to avoid clk conflict
        if(f2c_fifo_rd_data_count >= 'd200 ) begin //200 정도 하니까 중간에 data_vld 안끊김. 이것 때문에 f2c_fifo_full 뜨면 안되니까 depth 1024->2048로 늘려
            f2c_fifo_rd_en <= 1'b1;
        end
        else if (f2c_fifo_empty) begin
            f2c_fifo_rd_en <= 1'b0;
        end
        //for TF loading (less than 200 data)
        if (f2c_fifo_rd_data_count >= 'd9 && f2c_fifo_rd_data_count <= 'd19 && ~f2c_fifo_rd_en && ~c2f_fifo_wr_en) begin  
            f2c_fifo_rd_en <= 1'b1;
        end
    end
    else begin //sel_chip==0
        f2c_fifo_rd_en <= 'd0;
    end
end

// NOTICE:
always @(posedge clk_dly) begin
    if(rst) begin
        f2c_data_q <= 128'b0;
        f2c_data_2q <= 128'b0;
        c2f_data_q <= 128'b0;
    end
    else begin
        f2c_data_q <= f2c_data;
        f2c_data_2q <= f2c_data_q; //2-stage buffering
        c2f_data_q <= c2f_data;
    end
end

assign c2f_fifo_din = {is_read_q, dram_addr_q, c2f_data_q};

assign f2c_data = f2c_fifo_dout;
assign data_vld_d = f2c_fifo_dout_valid ;


function [3:0] xem7360_led;
input [3:0] a;
integer i;
begin
	for(i=0; i<4; i=i+1) begin: u
		xem7360_led[i] = (a[i]==1'b1) ? (1'b0) : (1'bz);
	end
end
endfunction

//assign led = xem7360_led({pipe_in_valid, p2f_fifo_dout_valid, f2p_fifo_dout_valid, pipe_out_read});
//assign led = xem7360_led({execute, encrypt, generate_keys, done_q});

assign data_to_chip   = f2c_data_2q ;
assign c2f_data = data_from_chip;

//genvar gio;
//generate
//    for(gio = 0; gio < 128; gio = gio + 1) begin: IO
//        IOBUF u_IOBUF(
//            .IO(data[gio]),
//            .I(data_to_chip[gio]),
//            .O(data_from_chip[gio]),
//            .T(~is_read_q)  // O = IO if T == 1 (Write to FPGA)
//        );
//    end
//endgenerate

//added to avoid setup violation!! Implicitly using IOBUF helps to remove T delay, which is asynchronous
//assign data = (is_read_q) ? data_to_chip : {128{1'bz}};
//assign data_from_chip = data;

//made reg for each T to reduce fanout of is_read_q
reg [127:0] command_type_q;
genvar gio;
generate
    for (gio = 0; gio < 128; gio = gio + 1) begin : GEN_CMD_Q
        always @(posedge clk_dly) begin
            if (rst) begin
                command_type_q[gio] <= 1'b0;
            end else begin
                command_type_q[gio] <= command_type;
            end
        end

        assign data[gio]         = (command_type_q[gio]) ? 1'bz : data_to_chip[gio];
        assign data_from_chip[gio] = data[gio];
    end
endgenerate



// MIG User Interface instantiation
mig_7series_0 u_mig_7series_0 (
	// Memory interface ports
	.ddr3_addr                      (ddr3_addr),
	.ddr3_ba                        (ddr3_ba),
	.ddr3_cas_n                     (ddr3_cas_n),
	.ddr3_ck_n                      (ddr3_ck_n),
	.ddr3_ck_p                      (ddr3_ck_p),
	.ddr3_cke                       (ddr3_cke),
	.ddr3_ras_n                     (ddr3_ras_n),
	.ddr3_reset_n                   (ddr3_reset_n),
	.ddr3_we_n                      (ddr3_we_n),
	.ddr3_dq                        (ddr3_dq),
	.ddr3_dqs_n                     (ddr3_dqs_n),
	.ddr3_dqs_p                     (ddr3_dqs_p),
	.init_calib_complete            (init_calib_complete),
	
	.ddr3_cs_n                      (ddr3_cs_n),
	.ddr3_dm                        (ddr3_dm),
	.ddr3_odt                       (ddr3_odt),
	// Application interface ports
	.app_addr                       (app_addr),
	.app_cmd                        (app_cmd),
	.app_en                         (app_en),
	.app_wdf_data                   (app_wdf_data),
	.app_wdf_end                    (app_wdf_end),
	.app_wdf_wren                   (app_wdf_wren),
	.app_rd_data                    (app_rd_data),
	.app_rd_data_end                (app_rd_data_end),
	.app_rd_data_valid              (app_rd_data_valid),
	.app_rdy                        (app_rdy),
	.app_wdf_rdy                    (app_wdf_rdy),
	.app_sr_req                     (1'b0),
	.app_sr_active                  (),
	.app_ref_req                    (1'b0),
	.app_ref_ack                    (),
	.app_zq_req                     (1'b0),
	.app_zq_ack                     (),
	.ui_clk                         (ui_clk),
	.ui_clk_sync_rst                (ui_rst),
	
	.app_wdf_mask                   (app_wdf_mask),
	
	// System Clock Ports
	.sys_clk_p                      (sys_clkp),
	.sys_clk_n                      (sys_clkn),
	
	.sys_rst                        (rst)
);

mem_controller_chip_clean u_memory_controller(
    .clk(ui_clk),
    .rst(rst),
    .calib_done(init_calib_complete),

    // P2F FIFO signals:
    .p2f_rd_en(p2f_fifo_rd_en),
    .p2f_rd_data(p2f_fifo_dout),
    //.p2f_fifo_rd_data_count(p2f_fifo_rd_data_count),
    .p2f_rd_valid(p2f_fifo_dout_valid),
    .p2f_empty(p2f_fifo_empty),

    // F2P FIFO signals:
    .f2p_wr_en(f2p_fifo_wr_en),
    .f2p_wr_data(f2p_fifo_din),
    .f2p_wr_cnt(f2p_fifo_wr_data_count),

    // C2F FIFO signals:
    .c2f_rd_en(c2f_fifo_rd_en),
    .c2f_rd_data(c2f_fifo_dout),
//    .c2f_fifo_rd_data_count(c2f_fifo_rd_data_count),
    .c2f_rd_valid(c2f_fifo_dout_valid),
    .c2f_empty(c2f_fifo_empty),

    // F2C FIFO signals:
    .f2c_wr_en(f2c_fifo_wr_en),
    .f2c_wr_data(f2c_fifo_din),
    .f2c_wr_cnt(f2c_fifo_wr_data_count),

    // MIG signals:
	.app_rdy(app_rdy),
	.app_en(app_en),
	.app_cmd(app_cmd),
	.app_addr(app_addr),

	.app_rd_data(app_rd_data),
	//.app_rd_data_end(app_rd_data_end),
	.app_rd_valid(app_rd_data_valid),

	.app_wdf_rdy(app_wdf_rdy),
	.app_wdf_wren(app_wdf_wren),
	.app_wdf_data(app_wdf_data),
	.app_wdf_end(app_wdf_end),
	.app_wdf_mask(app_wdf_mask),
	
	.sel_chip (sel_chip)
);

fifo_w32_1024_r256_128 P2F_FIFO(
    .rst(rst),
    // write:
    .wr_clk(okClk),
    .full(p2f_fifo_full),
    .wr_en(p2f_fifo_wr_en),
    .din(p2f_fifo_din),
    // read:
    .rd_clk(ui_clk),
    .empty(p2f_fifo_empty),
    .rd_en(p2f_fifo_rd_en),
    .dout(p2f_fifo_dout),
    .valid(p2f_fifo_dout_valid),
    // status:
    .wr_data_count(p2f_fifo_wr_data_count),
    .rd_data_count(p2f_fifo_rd_data_count)
);

fifo_w128_256_r32_1024 F2P_FIFO(
    .rst(rst),
    // write:
    .wr_clk(ui_clk),
    .full(f2p_fifo_full),
    .wr_en(f2p_fifo_wr_en),
    .din(f2p_fifo_din),
    // read:
    .rd_clk(okClk),
    .empty(f2p_fifo_empty),
    .rd_en(f2p_fifo_rd_en),
    .dout(f2p_fifo_dout),
    .valid(f2p_fifo_dout_valid),
    // status:
    .wr_data_count(f2p_fifo_wr_data_count),
    .rd_data_count(f2p_fifo_rd_data_count)
);

fifo_w149_1024_r149_1024 C2F_FIFO(
    .rst(rst),
    // write:
    .wr_clk(clk_dly),
    .full(c2f_fifo_full),
    .wr_en(c2f_fifo_wr_en),
    .din(c2f_fifo_din),
    // read:
    .rd_clk(ui_clk),
    .empty(c2f_fifo_empty),
    .rd_en(c2f_fifo_rd_en),
    .dout(c2f_fifo_dout),
    .valid(c2f_fifo_dout_valid),
    // status:
    .wr_data_count(c2f_fifo_wr_data_count),
    .rd_data_count(c2f_fifo_rd_data_count)
);
//changed F2C_FIFO depth 1024->2048
fifo_w128_2048_r128_2048 F2C_FIFO(
    .rst(rst),
    // write:
    .wr_clk(ui_clk),
    .full(f2c_fifo_full),
    .wr_en(f2c_fifo_wr_en),
    .din(f2c_fifo_din),
    // read:
    .rd_clk(clk_dly),
    .empty(f2c_fifo_empty),
    .rd_en(f2c_fifo_rd_en),
    .dout(f2c_fifo_dout),
    .valid(f2c_fifo_dout_valid),
    // status:
    .wr_data_count(f2c_fifo_wr_data_count),
    .rd_data_count(f2c_fifo_rd_data_count)
);


// Instantiate the okHost and connect endpoints.
wire [65 * 3 - 1:0]  okEHx;

okHost okHI(
	.okUH(okUH),
	.okHU(okHU),
	.okUHU(okUHU),
	.okAA(okAA),
	.okClk(okClk),
	.okHE(okHE),
	.okEH(okEH)
);

okWireOR # (.N(3)) wireOR (okEH, okEHx);

okWireIn        WireIn00        (.okHE(okHE),                               .ep_addr(8'h00),    .ep_dataout(wirein00_wire));
okWireIn        WireIn01        (.okHE(okHE),                               .ep_addr(8'h01),    .ep_dataout(wirein01_wire));
okWireIn        WireIn02        (.okHE(okHE),                               .ep_addr(8'h02),    .ep_dataout(wirein02_wire));

okBTPipeIn      BTPipeIn80      (.okHE(okHE),   .okEH(okEHx[0 * 65 +: 65]), .ep_addr(8'h80),    .ep_dataout(pipe_in_data), .ep_write(pipe_in_valid),   .ep_blockstrobe(),  .ep_ready(pipe_in_ready));
okBTPipeOut     BTPipeOutA0     (.okHE(okHE),   .okEH(okEHx[1 * 65 +: 65]), .ep_addr(8'hA0),    .ep_datain(pipe_out_data), .ep_read(pipe_out_read),    .ep_blockstrobe(),  .ep_ready(pipe_out_ready));

okTriggerIn     TriggerIn40     (.okHE(okHE),                               .ep_addr(8'h40),    .ep_clk(clk_dly), .ep_trigger(trigin40_wire));
okTriggerOut    TriggerOut60    (.okHE(okHE),   .okEH(okEHx[2 * 65 +: 65]), .ep_addr(8'h60),    .ep_clk(clk_dly), .ep_trigger(trigout60_wire));

endmodule