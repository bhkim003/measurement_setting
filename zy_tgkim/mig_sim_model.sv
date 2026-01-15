`timescale 1ns / 1ps

module mig_sim_model (
    // [1] DDR3 Physical Interface (껍데기만 존재, 연결 안 함)
    inout  wire [31:0]  ddr3_dq,
    inout  wire [3 :0]  ddr3_dqs_n,
    inout  wire [3 :0]  ddr3_dqs_p,
    output wire [15:0]  ddr3_addr,
    output wire [2 :0]  ddr3_ba,
    output wire         ddr3_cas_n,
    output wire         ddr3_ras_n,
    output wire         ddr3_we_n,
    output wire         ddr3_reset_n,
    output wire [0 :0]  ddr3_ck_p,
    output wire [0 :0]  ddr3_ck_n,
    output wire [0 :0]  ddr3_cke,
    output wire [0 :0]  ddr3_cs_n,
    output wire [3 :0]  ddr3_dm,
    output wire [0 :0]  ddr3_odt,

    // [2] User Interface (여기가 중요)
    input  wire         sys_clk_i, // No Buffer 모드라서 단일 입력
    input  wire         sys_rst,
    
    output reg          ui_clk,
    output reg          ui_clk_sync_rst,
    output reg          init_calib_complete,

    // Command Interface
    input  wire [29:0]  app_addr,
    input  wire [2:0]   app_cmd,
    input  wire         app_en,
    output reg          app_rdy,

    // Write Data Interface
    input  wire [255:0] app_wdf_data,
    input  wire         app_wdf_end,
    input  wire [31:0]  app_wdf_mask,
    input  wire         app_wdf_wren,
    output reg          app_wdf_rdy,

    // Read Data Interface
    output reg  [255:0] app_rd_data,
    output reg          app_rd_data_end,
    output reg          app_rd_data_valid,
    
    // Unused
    input  wire         app_sr_req,
    input  wire         app_ref_req,
    input  wire         app_zq_req,
    output wire         app_sr_active,
    output wire         app_ref_ack,
    output wire         app_zq_ack
);

    // -------------------------------------------------------------------------
    // 1. Clock & Reset Generation
    // -------------------------------------------------------------------------
    // 실제 MIG는 sys_clk(200MHz)를 받아 ui_clk(100MHz)를 만듭니다.
    // 시뮬레이션에서는 간단히 주기를 2배로 하여 100MHz를 만듭니다.
    initial ui_clk = 0;
    always #5.0 ui_clk = ~ui_clk; // 100MHz (Period 10ns)

    initial begin
        ui_clk_sync_rst = 1;
        init_calib_complete = 0;
        app_rdy = 0;
        app_wdf_rdy = 0;
        
        #200; // 잠시 대기
        ui_clk_sync_rst = 0;      // 리셋 해제
        #100;
        init_calib_complete = 1;  // 즉시 보정 완료!
        app_rdy = 1;              // 항상 명령 받을 준비 됨
        app_wdf_rdy = 1;          // 항상 데이터 받을 준비 됨
    end

    // Unused outputs
    assign app_sr_active = 0;
    assign app_ref_ack = 1;
    assign app_zq_ack = 1;
    // -------------------------------------------------------------------------
    // [NEW] DDR3 Physical Interface Driving (Z 상태 방지)
    // -------------------------------------------------------------------------
    // Reset 신호는 내부 Reset과 연동 (Active Low)
    assign ddr3_reset_n = ~ui_clk_sync_rst; 

    // 나머지 신호들은 Idle(Inactive) 상태로 고정
    assign ddr3_ck_p   = 1'b0;
    assign ddr3_ck_n   = 1'b1;
    assign ddr3_cke    = 1'b0;
    assign ddr3_cs_n   = 1'b1; // Chip Select Inactive
    assign ddr3_ras_n  = 1'b1;
    assign ddr3_cas_n  = 1'b1;
    assign ddr3_we_n   = 1'b1;
    assign ddr3_odt    = 1'b0;
    assign ddr3_ba     = 3'b0;
    assign ddr3_addr   = 16'b0;
    assign ddr3_dm     = 4'b0;
    // ddr3_dq, ddr3_dqs 등은 inout이므로 그대로 둠 (필요 시 pullup 등 추가)
    // -------------------------------------------------------------------------
    // 2. Memory Simulation (Associative Array)
    // -------------------------------------------------------------------------
    // SystemVerilog 기능을 사용하여 거대한 메모리를 효율적으로 시뮬레이션
    // (Vivado Simulator는 .v 파일에서도 이 문법을 대부분 지원합니다)
    reg [255:0] memory [int]; 

    // -------------------------------------------------------------------------
    // 3. Command Processing
    // -------------------------------------------------------------------------
    // app_cmd: 000 (Write), 001 (Read)
    
    always @(posedge ui_clk) begin
        // Default Outputs
        app_rd_data_valid <= 0;
        app_rd_data_end <= 0;
        app_rd_data <= 256'b0;

        if (!ui_clk_sync_rst && init_calib_complete) begin
            
            // [WRITE Operation]
            // app_en(명령 유효) + app_wdf_wren(데이터 유효) + app_cmd==0(쓰기)
            if (app_en && app_rdy && app_cmd == 3'b000 && app_wdf_wren && app_wdf_rdy) begin
                // 실제 주소의 하위 비트는 Byte addressing 등 복잡하지만, 
                // 시뮬레이션에서는 app_addr을 정수 인덱스로 바로 사용
                memory[app_addr] = app_wdf_data;
                $display("[MIG_SIM] WRITE Addr: 0x%h, Data: 0x%h", app_addr, app_wdf_data);
            end

            // [READ Operation]
            // app_en(명령 유효) + app_cmd==1(읽기)
            if (app_en && app_rdy && app_cmd == 3'b001) begin
                // 1 Cycle 뒤에 바로 데이터 리턴 (Latency 시뮬레이션 가능)
                app_rd_data_valid <= 1;
                app_rd_data_end   <= 1;
                
                if (memory.exists(app_addr)) begin
                    app_rd_data <= memory[app_addr];
                    $display("[MIG_SIM] READ  Addr: 0x%h, Data: 0x%h", app_addr, memory[app_addr]);
                end else begin
                    app_rd_data <= 256'hDEADBEEF; // 초기화 안 된 영역 읽음
                    $display("[MIG_SIM] READ  Addr: 0x%h, Data: (Uninitialized)", app_addr);
                end
            end
        end
    end

endmodule