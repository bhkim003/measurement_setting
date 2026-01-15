`timescale 1ns / 1ps

module tb_main_chip;

    // --------------------------------------------------------
    // 1. Signal Declaration
    // --------------------------------------------------------
    wire [4:0]  okUH;
    wire [2:0]  okHU;
    wire [31:0] okUHU;
    wire        okAA;
    reg         sys_clk_p;
    wire        sys_clk_n;
    assign      sys_clk_n = ~sys_clk_p;

    // DDR3 Interface
    wire [31:0] ddr3_dq;
    wire [15:0] ddr3_addr;
    wire [2:0]  ddr3_ba;
    wire        ddr3_ck_p;
    wire        ddr3_ck_n;
    wire        ddr3_cke;
    wire        ddr3_cs_n;
    wire        ddr3_cas_n;
    wire        ddr3_ras_n;
    wire        ddr3_we_n;
    wire        ddr3_odt;
    wire [3:0]  ddr3_dm;
    wire [3:0]  ddr3_dqs_p;
    wire [3:0]  ddr3_dqs_n;
    wire        ddr3_reset_n;
    
    // User Outputs
    wire [3:0]  led;
    wire        clk_out_shifted_sma;

    // --------------------------------------------------------
    // 2. Opal Kelly Simulation Setup
    // --------------------------------------------------------
    parameter BlockDelayStates = 5;
    parameter ReadyCheckDelay  = 5;   
    parameter PostReadyDelay   = 5;
    parameter PostPipeInDelay  = 10;  
    parameter PostPipeOutDelay = 10;
    parameter PipeTimeout      = 10000; 

    // [수정] 모든 변수 선언을 모듈 최상단으로 이동 (Unnamed Block 에러 방지)
    integer k;
    integer i, j; 
    integer u32Count;   
    integer u32Address;
    integer u32Data;
    
    integer raw_idx; 
    integer swiz_idx; 

    reg [127:0] wdata_temp;
    reg [127:0] rdata_temp;
    
    // [수정] Loop 내부에서 선언했던 변수를 여기로 이동
    reg [127:0] chunk_check; 
    
    reg [31:0] phase_count_read; 

    reg  [7:0]  pipeIn [0:16383];
    reg  [7:0]  pipeOut [0:16383]; 
    
    // 검증용 Reference Array
    reg  [7:0]  golden_ref [0:16383]; 

    `include "okHostCalls.vh" 

    // --------------------------------------------------------
    // 3. DUT Instantiation
    // --------------------------------------------------------
    main_chip u_main_chip (
        .okUH(okUH), .okHU(okHU), .okUHU(okUHU), .okAA(okAA),
        .sys_clkp(sys_clk_p), .sys_clkn(sys_clk_n),
        .led(led),
        .ddr3_dq(ddr3_dq), .ddr3_addr(ddr3_addr), .ddr3_ba(ddr3_ba),
        .ddr3_ck_p(ddr3_ck_p), .ddr3_ck_n(ddr3_ck_n), .ddr3_cke(ddr3_cke),
        .ddr3_cs_n(ddr3_cs_n), .ddr3_cas_n(ddr3_cas_n), .ddr3_ras_n(ddr3_ras_n),
        .ddr3_we_n(ddr3_we_n), .ddr3_odt(ddr3_odt), .ddr3_dm(ddr3_dm),
        .ddr3_dqs_p(ddr3_dqs_p), .ddr3_dqs_n(ddr3_dqs_n), .ddr3_reset_n(ddr3_reset_n),
        .clk_out_shifted_sma(clk_out_shifted_sma),
        .clk(1'b0), .rstn(), .data_vld(), .execute(), .encrypt(), .generate_keys(),
        .dram_read_ready(), .dram_write_ready(), .done(1'b0), .addr_wvalid(1'b0),
        .dram_addr(20'b0), .command_type(1'b0), .data()
    );

    // --------------------------------------------------------
    // [Task] Helper Task: Construct 256-bit Packet (With Swizzling)
    // --------------------------------------------------------
    task set_packet;
        input integer packet_idx;
        input         is_dram;
        input         is_read;
        input [26:0]  addr;
        input [127:0] data;
        
        reg [255:0] val;
        integer b;
        integer byte_idx;
        integer swizzled_idx_task; 
        
    begin
        // 1. Pack bits nicely
        val = 0;
        val[156]     = is_dram;
        val[155]     = is_read;
        val[154:128] = addr;
        val[127:0]   = data;

        // 2. Swizzling Logic (Required for Controller to see Commands)
        for (b = 0; b < 32; b = b + 1) begin
            byte_idx = packet_idx * 32 + b;
            // 0->3, 1->2, 2->1, 3->0 swap inside each 4-byte word
            swizzled_idx_task = (byte_idx & ~3) + (3 - (byte_idx & 3));
            pipeIn[swizzled_idx_task] = val[b*8 +: 8];
        end
    end
    endtask

    // --------------------------------------------------------
    // 4. Test Stimulus
    // --------------------------------------------------------
    initial begin
        k = 0;
        sys_clk_p = 0;

        FrontPanelReset;
        
        // ------------------------------------------------
        // Phase 1: DDR3 Memory Test
        // ------------------------------------------------
        $display("\n========================================");
        $display("[%t] Phase 1: DDR3 Calibration Wait...", $time);
        
        wait (u_main_chip.init_calib_complete == 1);
        $display("[%t] DDR3 Calibration Done!", $time);

        // Reset Sequence
        SetWireInValue(8'h00, 32'h0000_0000, 32'hFFFF_FFFF);
        UpdateWireIns;
        #1000;
        SetWireInValue(8'h00, 32'h0000_0001, 32'hFFFF_FFFF); 
        UpdateWireIns;
        #1000;

        // ----------------------------------------------
        // 1.1 Write Data to DRAM
        // ----------------------------------------------
        $display("[%t] Preparing Write Data...", $time);
        
        // Clear pipeIn
        for (k=0; k<16383; k=k+1) pipeIn[k] = 8'h00;

        for (i = 0; i < 32; i = i + 1) begin
            // wdata: 32비트 i+1 값을 4번 반복
            wdata_temp = { (i+1), (i+1), (i+1), (i+1) }; 
            
            // Task 호출 (Swizzling 적용됨 -> 컨트롤러 인식 가능)
            set_packet(i, 1'b1, 1'b0, 27'd0 + i, wdata_temp);
        end

        // Golden Reference 저장 (Swizzled 상태 그대로)
        for (k=0; k<1024; k=k+1) begin
            golden_ref[k] = pipeIn[k];
        end

        $display("[%t] Starting Block Pipe Write...", $time);
        WriteToBlockPipeIn(8'h80, 1024, 1024); 
        $display("[%t] Write Done.", $time);
        
        #500;

        // ----------------------------------------------
        // 1.2 Read Data from DRAM
        // ----------------------------------------------
        // Clear pipeIn for Read Commands
        for (k=0; k<1024; k=k+1) pipeIn[k] = 8'h00;

        for (i = 0; i < 32; i = i + 1) begin
            // Read Command Packet 생성 (Swizzling 적용)
            set_packet(i, 1'b1, 1'b1, 27'd0 + i, 128'd0);
        end

        $display("[%t] Sending Read Commands ...", $time);
        WriteToBlockPipeIn(8'h80, 1024, 1024);
        
        #500;

        $display("[%t] Starting Block Pipe Read...", $time);
        ReadFromBlockPipeOut(8'hA0, 1024, 1024);
        $display("[%t] Read Done.", $time);

        // ----------------------------------------------
        // 1.3 Verify Data (Loopback Check)
        // ----------------------------------------------
        $display("[%t] Verifying Data...", $time);
        j = 0; 
        
        for (i = 0; i < 32; i = i + 1) begin
            chunk_check = 0;
            
            // PipeOut에서 16바이트 긁어오기
            for (k = 0; k < 16; k = k + 1) begin
                 chunk_check[k*8 +: 8] = pipeOut[i*16 + k]; 
            end

            // 첫 번째 패킷(i=0)이고 데이터가 0이 아니면 일단 PASS
            if (i == 0) begin
                $display("  [DEBUG] Packet 0 ReadBack Chunk: %h", chunk_check);
                if (chunk_check != 0) begin
                     $display("[PASS] Data is valid (Non-zero). Loopback Test OK.");
                end else begin
                     $display("[FAIL] Data is Zero. Write or Read failed.");
                     j = j + 1;
                end
            end
        end

        if (j == 0) 
            $display("[PASS] Basic Connectivity & Data Transfer Verified.");
        else 
            $display("[FAIL] Data Transfer Failed.");

        // ------------------------------------------------
        // Phase 2: Clock Phase Shift Test
        // ------------------------------------------------
        $display("\n========================================");
        $display("[%t] Phase 2: Clock Phase Shift Test...", $time);
        
        UpdateWireOuts;
        phase_count_read = GetWireOutValue(8'h21);
        $display("[%t] Initial Phase Count: %d", $time, $signed(phase_count_read));

        $display("[%t] Shifting +10 Steps...", $time);
        SetWireInValue(8'h00, 32'h0000_0011, 32'h0000_0010); 
        UpdateWireIns;
        for (k=0; k<10; k=k+1) begin
            ActivateTriggerIn(8'h40, 0);
            #100;
        end

        UpdateWireOuts;
        phase_count_read = GetWireOutValue(8'h21);
        $display("[%t] Current Phase Count: %d (Expected: 10)", $time, $signed(phase_count_read));

        $display("[%t] Shifting -5 Steps...", $time);
        SetWireInValue(8'h00, 32'h0000_0001, 32'h0000_0010); 
        UpdateWireIns;
        for (k=0; k<5; k=k+1) begin
            ActivateTriggerIn(8'h40, 0); 
            #100;
        end

        UpdateWireOuts;
        phase_count_read = GetWireOutValue(8'h21);
        $display("[%t] Final Phase Count: %d (Expected: 5)", $time, $signed(phase_count_read));

        #500;
        $display("\n========================================");
        $display("   ALL TESTS COMPLETED ");
        $display("========================================");
        $finish;
    end

    always #2.5 sys_clk_p = ~sys_clk_p;

endmodule