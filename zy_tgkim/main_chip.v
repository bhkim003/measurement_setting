`timescale 1ns / 1ps

module main_chip(
    // [1] Opal Kelly Host Interface
    input  wire [4:0]   okUH,
    output wire [2:0]   okHU,
    inout  wire [31:0]  okUHU,
    inout  wire         okAA,

    // [2] System Clock
    input  wire         sys_clkp,
    input  wire         sys_clkn,
    
    // [3] User LED
    output wire [3:0]   led,
    
    // [4] DDR3 Memory Interface
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

    // [5] ASIC Interface (Dummy) & Clock Output
    input clk,  
    output rstn,
    output data_vld,
    output execute,
    output encrypt,
    output generate_keys,
    output dram_read_ready,
    output dram_write_ready,
    input done,
    input addr_wvalid,
    input [19:0] dram_addr,
    input command_type,
    inout [63:0] data,
    
    // [New] Phase Shifted Clock Output (Test Pin)
    output wire clk_out_shifted_sma 
);

    // --- 1. Clock & Reset ---
    wire ui_clk;        
    wire ui_rst;        
    wire okClk;
    wire [112:0] okHE;
    wire [64:0]  okEH;

    // Reset Logic
    wire [31:0] ep00_wire;
    wire        sw_rst_n = ep00_wire[0];
    wire        rst = ~sw_rst_n | ui_rst;

    // --- 2. Opal Kelly Host Interface ---
    okHost okHI(
        .okUH(okUH), .okHU(okHU), .okUHU(okUHU), .okAA(okAA),
        .okClk(okClk), .okHE(okHE), .okEH(okEH)
    );

    // --- 3. User LED ---
    reg [25:0] counter;
    always @(posedge okClk) counter <= counter + 1;
    
    // LED 0: Heartbeat
    // LED 1: MMCM Locked (Clock Shift용)
    // LED 2: Calibration Complete
    assign led[0] = ~counter[25]; 
    assign led[1] = ~mmcm_locked; 
    assign led[2] = ~init_calib_complete;
    assign led[3] = 1'b1; // OFF

    // --- 4. MIG IP (DDR3) ---
    // [주의] 실제 하드웨어에서는 MIG와 Clock Wizard가 같은 sys_clk 핀을 공유하려면
    // MIG 설정을 'No Buffer'로 바꾸고 IBUFDS 출력을 공유해야 합니다.
    // 여기서는 기존 코드를 유지하기 위해 MIG는 핀을 직접 사용하도록 둡니다.
    // (Vivado에서 "IBUFDS driving same net" 에러가 날 경우 MIG 설정을 변경해야 함)
    
    wire init_calib_complete;
    wire [29:0]  app_addr;
    wire [2:0]   app_cmd;
    wire         app_en;
    wire         app_rdy;
    wire [255:0] app_rd_data;
    wire         app_rd_data_end;
    wire         app_rd_data_valid;
    wire [255:0] app_wdf_data;
    wire         app_wdf_end;
    wire [31:0]  app_wdf_mask;
    wire         app_wdf_rdy;
    wire         app_wdf_wren;

    `ifdef SIMULATION
        // [시뮬레이션 모드] 경량화 모델 사용
        mig_sim_model u_mig_7series_0 (
    `else
        // [실제 합성/구현 모드] 실제 Xilinx IP 사용
        mig_7series_0 u_mig_7series_0 (
    `endif
        .ddr3_addr(ddr3_addr), .ddr3_ba(ddr3_ba), .ddr3_cas_n(ddr3_cas_n),
        .ddr3_ck_n(ddr3_ck_n), .ddr3_ck_p(ddr3_ck_p), .ddr3_cke(ddr3_cke),
        .ddr3_ras_n(ddr3_ras_n), .ddr3_reset_n(ddr3_reset_n), .ddr3_we_n(ddr3_we_n),
        .ddr3_dq(ddr3_dq), .ddr3_dqs_n(ddr3_dqs_n), .ddr3_dqs_p(ddr3_dqs_p),
        .init_calib_complete(init_calib_complete),
        .ddr3_cs_n(ddr3_cs_n), .ddr3_dm(ddr3_dm), .ddr3_odt(ddr3_odt),
        
        .app_addr(app_addr), .app_cmd(app_cmd), .app_en(app_en),
        .app_wdf_data(app_wdf_data), .app_wdf_end(app_wdf_end),
        .app_wdf_wren(app_wdf_wren), .app_wdf_mask(app_wdf_mask),
    
        .app_rd_data(app_rd_data), .app_rd_data_end(app_rd_data_end),
        .app_rd_data_valid(app_rd_data_valid),
        .app_rdy(app_rdy), .app_wdf_rdy(app_wdf_rdy),
        
        .app_sr_req(1'b0), .app_ref_req(1'b0), .app_zq_req(1'b0),
        .app_sr_active(), .app_ref_ack(), .app_zq_ack(),
        
        .ui_clk(ui_clk), .ui_clk_sync_rst(ui_rst),
        .sys_clk_i(sys_clk_buffered),
        .sys_rst(1'b0)
    );

    // --- 5. FIFO & Controller (DRAM Test) ---
    // [기존 DRAM 관련 코드 유지]
    wire [31:0]  pipe_in_data;
    wire         pipe_in_valid;
    reg          pipe_in_ready;
    wire [31:0]  pipe_out_data;
    wire         pipe_out_read;
    reg          pipe_out_ready;

    wire [255:0] in_fifo_dout;
    wire         in_fifo_empty, in_fifo_rd_en, in_fifo_dout_valid;
    wire [9:0]   in_fifo_wr_data_count;
    wire [6:0]   in_fifo_rd_data_count;

    fifo_w32_1024_r256_128 u_fifo_in (
        .rst(rst), .wr_clk(okClk), .full(), .wr_en(pipe_in_valid), .din(pipe_in_data),
        .wr_data_count(in_fifo_wr_data_count),
        .rd_clk(ui_clk), .empty(in_fifo_empty), .rd_en(in_fifo_rd_en), .dout(in_fifo_dout),
        .valid(in_fifo_dout_valid), .rd_data_count(in_fifo_rd_data_count)
    );

    wire [127:0] out_fifo_din;
    wire         out_fifo_wr_en, out_fifo_full, out_fifo_empty;
    wire [7:0]   out_fifo_wr_data_count;
    wire [9:0]   out_fifo_rd_data_count;

    fifo_w128_256_r32_1024 u_fifo_out (
        .rst(rst), .wr_clk(ui_clk), .full(out_fifo_full), .wr_en(out_fifo_wr_en), .din(out_fifo_din),
        .wr_data_count(out_fifo_wr_data_count),
        .rd_clk(okClk), .empty(out_fifo_empty), .rd_en(pipe_out_read), .dout(pipe_out_data),
        .valid(), .rd_data_count(out_fifo_rd_data_count)
    );

    always @(posedge okClk) begin
        if (in_fifo_wr_data_count <= 10'd1000) pipe_in_ready <= 1'b1;
        else pipe_in_ready <= 1'b0;
        
        if (out_fifo_rd_data_count >= 10'd4) pipe_out_ready <= 1'b1;
        else pipe_out_ready <= 1'b0;
    end

    mig_controller u_mig_controller(
        .sys_clk(ui_clk), .rst(rst), .calib_done(init_calib_complete),
        .ib_re(in_fifo_rd_en), .ib_data(in_fifo_dout), .ib_count(in_fifo_rd_data_count),
        .ib_valid(in_fifo_dout_valid), .ib_empty(in_fifo_empty),
        .ob_we(out_fifo_wr_en), .ob_data(out_fifo_din), .ob_count(out_fifo_wr_data_count[6:0]), 
        .ob_full(out_fifo_full),
        .app_rdy(app_rdy), .app_en(app_en), .app_cmd(app_cmd), .app_addr(app_addr),
        .app_rd_data(app_rd_data), .app_rd_data_end(app_rd_data_end),
        .app_rd_data_valid(app_rd_data_valid),
        .app_wdf_rdy(app_wdf_rdy), .app_wdf_wren(app_wdf_wren),
        .app_wdf_data(app_wdf_data), .app_wdf_end(app_wdf_end), .app_wdf_mask(app_wdf_mask)
    );

    // =========================================================================
    // [New Feature] Clock Phase Shift & Counter
    // =========================================================================
    
    // 1. IBUFDS (Differential -> Single Ended for Clock Wizard)
    wire sys_clk_buffered;
    IBUFDS #(
        .DIFF_TERM("FALSE"), .IBUF_LOW_PWR("TRUE"), .IOSTANDARD("DEFAULT")
    ) u_ibufds_mmcm (
        .I (sys_clkp), .IB(sys_clkn), .O (sys_clk_buffered)
    );

    // 2. Control Signals
    wire [31:0] ep40_trig; // TriggerIn
    wire        ps_en     = ep40_trig[0]; // Trigger Bit 0
    wire        ps_incdec = ep00_wire[4]; // WireIn Bit 4 (0: Dec, 1: Inc)
    wire        ps_done;
    wire        mmcm_locked;
    wire        clk_out_shifted;

    // 3. Clock Wizard Instance
    clk_wiz_0 u_clk_wiz_0 (
        .clk_in1(sys_clk_buffered), // From IBUFDS
        
        .clk_out1(),                // Fixed Phase (Optional)
        .clk_out2(clk_out_shifted), // Variable Phase
        
        .psclk(okClk),              // Use Opal Kelly Clock for Control
        .psen(ps_en),               // Trigger Pulse
        .psincdec(ps_incdec),       // Direction
        .psdone(ps_done),           // Done Signal
        
        .reset(1'b0),
        .locked(mmcm_locked)
    );

    // 4. Output to SMA (via ODDR for clean clock)
    ODDR #(
        .DDR_CLK_EDGE("OPPOSITE_EDGE"), .INIT(1'b0), .SRTYPE("SYNC")
    ) u_oddr_clk_out (
        .Q(clk_out_shifted_sma), .C(clk_out_shifted), 
        .CE(1'b1), .D1(1'b1), .D2(1'b0), .R(1'b0), .S(1'b0)
    );

    // 5. Phase Step Counter (FPGA Internal Tracking)
    reg signed [31:0] phase_step_count;
    
    always @(posedge okClk) begin
        if (rst) begin
            phase_step_count <= 0;
        end else begin
            // psdone이 1이 되는 순간 카운트 업데이트 (psclk == okClk이므로 직접 사용 가능)
            if (ps_done) begin
                if (ps_incdec) phase_step_count <= phase_step_count + 1;
                else           phase_step_count <= phase_step_count - 1;
            end
        end
    end

    // --- 6. Endpoints ---
    wire [31:0] ep20_wire = {31'b0, init_calib_complete}; // Status
    wire [31:0] ep21_wire = phase_step_count;             // Counter Readback

    // [수정] okEH를 출력하는 모듈은 총 4개입니다 (WireOut 2개, PipeIn 1개, PipeOut 1개).
    // TriggerIn과 WireIn은 okEH가 없습니다.
    wire [64:0] okEH_ep20, okEH_ep21, okEH_ep80, okEH_epA0;
    wire [65*4-1:0] okEHx = {okEH_epA0, okEH_ep80, okEH_ep21, okEH_ep20};
    okWireOR # (.N(4)) wireOR (okEH, okEHx); 

    // 1. okEH가 없는 모듈 (입력 전용)
    okWireIn    ep00 (.okHE(okHE), .ep_addr(8'h00), .ep_dataout(ep00_wire));
    
    // [수정] TriggerIn은 okEH 포트를 제거해야 함
    okTriggerIn ep40 (.okHE(okHE), .ep_addr(8'h40), .ep_clk(okClk), .ep_trigger(ep40_trig)); 

    // 2. okEH가 있는 모듈 (출력 포함) -> okWireOR에 연결
    // Index 0
    okWireOut   ep20 (.okHE(okHE), .okEH(okEH_ep20), .ep_addr(8'h20), .ep_datain(ep20_wire));
    
    // Index 1
    okWireOut   ep21 (.okHE(okHE), .okEH(okEH_ep21), .ep_addr(8'h21), .ep_datain(ep21_wire));
    
    // Index 2
    okBTPipeIn  ep80 (.okHE(okHE), .okEH(okEH_ep80), .ep_addr(8'h80), .ep_dataout(pipe_in_data), .ep_write(pipe_in_valid), .ep_blockstrobe(), .ep_ready(pipe_in_ready));
    
    // Index 3
    okBTPipeOut epA0 (.okHE(okHE), .okEH(okEH_epA0), .ep_addr(8'hA0), .ep_datain(pipe_out_data), .ep_read(pipe_out_read),  .ep_blockstrobe(), .ep_ready(pipe_out_ready));
    // Note: okEHx index shifted because of inserted Endpoints
    
endmodule