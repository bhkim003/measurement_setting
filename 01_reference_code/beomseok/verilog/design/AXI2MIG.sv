module AXI2MIG (
    input  wire          				sys_clk_p,
    input  wire          				sys_clk_n,
	input  wire          				sys_rst,

	/* DDR3 Interface */
    inout  wire [ 31:0]  			 	ddr3_dq,
    inout  wire [  3:0]  			 	ddr3_dqs_p,
    inout  wire [  3:0]  			 	ddr3_dqs_n,
    output wire [ 15:0]  			 	ddr3_addr,
    output wire [  2:0]  			 	ddr3_ba,
    output wire          			 	ddr3_ras_n,
    output wire          			 	ddr3_cas_n,
    output wire          			 	ddr3_we_n,
    output wire          			 	ddr3_reset_n,  
    output wire          			 	ddr3_ck_p,
    output wire          			 	ddr3_ck_n,
    output wire          			 	ddr3_cke,
    output wire          			 	ddr3_cs_n,
    output wire          			 	ddr3_odt,
    output wire [  3:0]  			 	ddr3_dm,
    output wire          			 	init_calib_complete,

	output wire                         ui_clk,
	output wire                         ui_clk_sync_rst,
	input  wire                         aresetn,
	input  wire                         app_sr_req,
	input  wire                         app_ref_req,
	input  wire                         app_zq_req,
	output wire                         app_sr_active,  // not used
	output wire                         app_ref_ack,    // not used
	output wire                         app_zq_ack,     // not used


	/* AXI4 Slave Interface */

	// AXI Write Address Channel
	input  wire                         s_axi_awid,  // not used
	input  wire [29:0]    				s_axi_awaddr,
	input  wire [7:0]                   s_axi_awlen,
	input  wire [3:0]       			s_axi_awsize,  // not used
	input  wire [1:0]           		s_axi_awburst, // not used
	input  wire      	 				s_axi_awlock,  // not used
	input  wire [3:0] 					s_axi_awcache, // not used
	input  wire [2:0] 					s_axi_awprot,  // not used
	input  wire [3:0] 					s_axi_awqos,   // not used
	input  wire                         s_axi_awvalid,
	output wire                         s_axi_awready,

	// AXI Write Data Channel
	input  wire [255:0]                 s_axi_wdata,
	input  wire [31:0]                  s_axi_wstrb,
	input  wire                         s_axi_wlast,   // not used
	input  wire                         s_axi_wvalid,
	output wire                         s_axi_wready,

	// AXI Write Response Channel
	input  wire        					s_axi_bready,  // not used
	output wire        					s_axi_bid,     // not used
	output wire [1:0]  					s_axi_bresp,   // not used
	output wire        					s_axi_bvalid,  // not used


	// AXI Read Address Channel
	input  wire                         s_axi_arid,  // not used
	input  wire [29:0]    				s_axi_araddr,
	input  wire [7:0]                   s_axi_arlen,
	input  wire [3:0]       			s_axi_arsize,  // not used
	input  wire [1:0]           		s_axi_arburst, // not used
	input  wire      	 				s_axi_arlock,  // not used
	input  wire [3:0] 					s_axi_arcache, // not used
	input  wire [2:0] 					s_axi_arprot,  // not used
	input  wire [3:0] 					s_axi_arqos,   // not used
	input  wire                         s_axi_arvalid,
	output wire                         s_axi_arready,

	// AXI Read Data Channel
	output wire                			s_axi_rid,     // not used
	output wire [255:0]                 s_axi_rdata,
  	output wire                			s_axi_rresp,   // not used
	output wire                         s_axi_rlast,
	output wire                         s_axi_rvalid,
	input  wire                         s_axi_rready

);

    //************************************************************
	// MIG Interface (User Interface to Memory)
    //************************************************************

	wire                         clk = ui_clk;

	// Write/Read Address & Command
	reg  [29:0]     			 app_addr; //comb.
	wire [2:0]                   app_cmd;
	wire                         app_en;

	// Write Data
	wire [255:0]                 app_wdf_data;
	wire                         app_wdf_end;
	wire                         app_wdf_wren;
	wire [31:0]                  app_wdf_mask;

	// MIG Handshakes
	wire                         app_rdy;
	wire                         app_wdf_rdy;

	// Read Data
	wire [255:0]                 app_rd_data;
	wire                         app_rd_data_end;
	wire                         app_rd_data_valid;


    //************************************************************
	// 
    //************************************************************

	localparam IDLE = 2'd0;
	localparam GEN_AWADDR = 2'd1;
	localparam GEN_ARADDR = 2'd2;

	reg [1:0] state;

	reg [29:0] awaddr_buf;
	reg [7:0]  awlen_buf;
	reg [7:0]  awcnt;
	reg [8:0]  wcnt;

	reg [29:0] araddr_buf;
	reg [7:0]  arlen_buf;
	reg [7:0]  arcnt;

	assign app_cmd  = s_axi_awvalid || (state==GEN_AWADDR) ? 3'b000 : 3'b001;
	assign app_en   = ((state==GEN_AWADDR) && (awcnt < wcnt) && app_rdy) || (s_axi_arvalid || (state==GEN_ARADDR));

	assign s_axi_awready  = app_rdy && (state==IDLE);
	assign s_axi_arready  = app_rdy && (state==IDLE) && s_axi_rready;

	assign s_axi_wready = (state==GEN_AWADDR) && app_wdf_rdy;
	assign app_wdf_data = s_axi_wdata;
	assign app_wdf_mask = ~s_axi_wstrb;
	assign app_wdf_wren = s_axi_wvalid;
	assign app_wdf_end  = app_wdf_wren;

	assign s_axi_rvalid = app_rd_data_valid;
	assign s_axi_rdata  = app_rd_data;

	always @(*) begin
		if (state==GEN_AWADDR)	 	app_addr = {2'b0,awaddr_buf[29:5],3'b0} + (awcnt << 3);   //  2 - 25 - 3
		else if (s_axi_arvalid)     app_addr = {2'b0, s_axi_araddr[29:5], 3'b0};
		else if (state==GEN_ARADDR) app_addr = {2'b0, araddr_buf[29:5], 3'b0} + (arcnt << 3);
		else 						app_addr = 'd0;
	end


	always @(posedge clk or negedge aresetn) begin
		if (~aresetn) begin
			state <= IDLE;
		end
		else begin
			case (state)
				IDLE: begin
					if (s_axi_awready && s_axi_awvalid) state <= GEN_AWADDR;
					else if (s_axi_arready && s_axi_arvalid && (s_axi_arlen!=8'd0))  state <= GEN_ARADDR;
					else state <= IDLE;
				end
				GEN_AWADDR: begin
					if (app_rdy && app_en && (awcnt==awlen_buf)) state <= IDLE;
					else state <= GEN_AWADDR;
				end
				GEN_ARADDR: begin
					if (app_rdy && app_en && (arcnt==arlen_buf)) state <= IDLE;
					else state <= GEN_ARADDR;
				end
			endcase
		end
	end


	always @(posedge clk or negedge aresetn) begin
		if (~aresetn) begin
			awaddr_buf <= 30'd0;
			awlen_buf  <= 8'd0;
			awcnt 	   <= 8'd0;

			araddr_buf <= 30'd0;
			arlen_buf  <= 8'd0;
			arcnt 	   <= 8'd0;
		end
		else begin
			case (state)
				IDLE: begin
					if (s_axi_awready && s_axi_awvalid) begin
						awaddr_buf <= s_axi_awaddr;
						awlen_buf  <= s_axi_awlen;
						// if (s_axi_awlen != 0) awcnt <= awcnt + 8'd1;
					end
					else if (s_axi_arready && s_axi_arvalid) begin
						araddr_buf <= s_axi_araddr;
						arlen_buf  <= s_axi_arlen;

						if (s_axi_arlen != 0) arcnt <= arcnt + 8'd1;
					end
					else begin
						awaddr_buf <= 30'd0;
						awlen_buf  <= 8'd0;
						awcnt 	   <= 8'd0;

						araddr_buf <= 30'd0;
						arlen_buf  <= 8'd0;
						arcnt 	   <= 8'd0;
					end
				end

				GEN_AWADDR: begin
					if (app_rdy && app_en) begin
						if (awcnt == awlen_buf) awcnt <= 8'd0;
						else awcnt <= awcnt + 8'd1;
					end
				end

				GEN_ARADDR: begin
					if (app_rdy && app_en) begin
						if (arcnt == arlen_buf) arcnt <= 8'd0;
						else arcnt <= arcnt + 8'd1;
					end
				end
			endcase

		end
	end


	always @(posedge clk or negedge aresetn) begin
		if (~aresetn) begin
			wcnt <= 9'd0;
		end
		else begin
			if (app_rdy && app_en && (awcnt == awlen_buf)) wcnt <= 9'd0;
			else if (app_wdf_wren && app_wdf_rdy) wcnt <= wcnt + 9'd1;
		end
	end





	xem7360_k160t_mig_native u_xem7360_k160t_mig_native
	(
		// Memory interface ports
		.ddr3_addr                      (ddr3_addr),
		.ddr3_ba                        (ddr3_ba),
		.ddr3_cas_n                     (ddr3_cas_n),
		.ddr3_ck_n                      (ddr3_ck_n),
		.ddr3_ck_p                      (ddr3_ck_p),
		.ddr3_cke                       (ddr3_cke),
		.ddr3_ras_n                     (ddr3_ras_n),
		.ddr3_we_n                      (ddr3_we_n),
		.ddr3_dq                        (ddr3_dq),
		.ddr3_dqs_n                     (ddr3_dqs_n),
		.ddr3_dqs_p                     (ddr3_dqs_p),
		.ddr3_reset_n                   (ddr3_reset_n),
		.ddr3_cs_n                      (ddr3_cs_n),
		.ddr3_dm                        (ddr3_dm),
		.ddr3_odt                       (ddr3_odt),
		.init_calib_complete            (init_calib_complete),
		.device_temp                    (),

		// Application interface ports
		.ui_clk                         (ui_clk),              // output
		.ui_clk_sync_rst                (ui_clk_sync_rst),              // output

		// System Clock Ports
		.sys_clk_p                      (sys_clk_p),
		.sys_clk_n                      (sys_clk_n),
		.sys_rst                        (sys_rst),    // active-high

		// cmd
		.app_en                         (app_en),
		.app_cmd                        (app_cmd),
		.app_addr                       (app_addr),
		.app_rdy                        (app_rdy),

		// write
		.app_wdf_data                   (app_wdf_data),
		.app_wdf_end                    (app_wdf_end),
		.app_wdf_mask                   (app_wdf_mask),
		.app_wdf_wren                   (app_wdf_wren),
		.app_wdf_rdy                    (app_wdf_rdy),
		// read
		.app_rd_data                    (app_rd_data),
		.app_rd_data_end                (app_rd_data_end),
		.app_rd_data_valid              (app_rd_data_valid),

		// .etc
		.app_sr_req                     (app_sr_req),
		.app_ref_req                    (app_ref_req),
		.app_zq_req                     (app_zq_req),
		.app_sr_active                  (),
		.app_ref_ack                    (),
		.app_zq_ack                     ()

	);


endmodule
