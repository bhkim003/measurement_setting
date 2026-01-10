`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
//  
// Create Date: 2025/07/14 10:29:43
// Design Name: 
// Module Name: mem_controller_jsw
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module mem_controller_chip_clean
#(  parameter OUT_FIFO_SIZE = 1024   // depth of F2P / F2C FIFOs
)
(
    // ---------------- Clocks / Reset ---------------------------------------
    input               clk,            // MIG ui_clk (200 MHz typical)
    input               rst,            // active-high, synchronous
    input               calib_done,     // MIG calibration done

    // ---------------- PC → FPGA  (first-fill) ------------------------------
    output              p2f_rd_en,
    input      [255:0]  p2f_rd_data,
    input               p2f_rd_valid,
    input               p2f_empty,

    // ---------------- FPGA → PC  (optional read-back) ----------------------
    output reg          f2p_wr_en,
    output reg   [127:0]  f2p_wr_data,
    input      [  9:0]  f2p_wr_cnt,

    // ---------------- CHIP → FPGA  -----------------------------------------
    output              c2f_rd_en,
    input      [148:0]  c2f_rd_data,
    input               c2f_rd_valid,
    input               c2f_empty,

    // ---------------- FPGA → CHIP  -----------------------------------------
    output reg          f2c_wr_en,
    output reg [127:0]  f2c_wr_data,
    input      [  10:0]  f2c_wr_cnt,

    // ---------------- MIG DDR3 UI  -----------------------------------------
    input               app_rdy,
    output              app_en,
    output     [2:0]    app_cmd,
    output     [29:0]   app_addr,

    input      [255:0]  app_rd_data,
    input               app_rd_valid,

    input               app_wdf_rdy,
    output              app_wdf_wren,
    output     [255:0]  app_wdf_data,
    output              app_wdf_end,
    output     [31:0]   app_wdf_mask,
    
    //added
    input               sel_chip  //1: chip FIFO,  0: PC FIFO  //comes from PC WireIn
);

    // =========================================================================
    // 0. Phase FSM  
    // =========================================================================
    localparam PH_PC = 2'b00,
               PH_CHIP  = 2'b01;

    reg [1:0] phase;

    always @(posedge clk) begin
        if (rst)
            phase <= PH_PC;
        else if (calib_done) begin
            case (phase) 
                PH_PC: if (sel_chip && p2f_empty) phase <= PH_CHIP;
                PH_CHIP: begin
                    if (~sel_chip && c2f_empty) begin
                        phase <= PH_PC;  //PC turns off sel_chip after receiving done signal  //changed!! added c2f_empty, or else store_decoding_out gets neglected
                    end
                end
                default : phase <= PH_PC;
            endcase
        end
    end
    
    // =========================================================================
    // 1. Packet pipeline : nxt_* (look-ahead) → cur_* (being issued)
    // =========================================================================
    reg          nxt_valid, cur_valid;  
    reg          nxt_is_read, cur_is_read;  
    reg  [19:0]  nxt_addr,    cur_addr;       // 20-bit (half-line addr[0] = half select  <- doesn't use half select!)
    reg  [127:0] nxt_wd,      cur_wd;         // write data (128 b)
    reg          cur_from_chip;


    assign c2f_rd_en = calib_done & (phase == PH_CHIP) & ~c2f_empty & (cur_accepted || (~nxt_valid & ~cur_valid)) ;
    assign p2f_rd_en = calib_done & (phase == PH_PC) & ~p2f_empty & (cur_accepted || (~nxt_valid & ~cur_valid)) ; 

    /* capture nxt_* when data_valid arrives */
    always @(posedge clk) begin
        if (rst)
            nxt_valid <= 1'b0;
        else begin
            if (c2f_rd_valid & ~(cur_accepted & ~nxt_valid)) begin     // CHIP packet
                nxt_valid   <= 1'b1;
                nxt_is_read <=  c2f_rd_data[148];
                nxt_addr    <=  c2f_rd_data[147:128];
                nxt_wd      <=  c2f_rd_data[127:0];
            end
            else if ( p2f_rd_valid & ~(cur_accepted & ~nxt_valid) ) begin// PC packet  
                nxt_valid   <= 1'b1;
                nxt_is_read <=  p2f_rd_data[148];
                nxt_addr    <=  p2f_rd_data[147:128];
                nxt_wd      <=  p2f_rd_data[127:0];
            end
            else if (cur_accepted || (~cur_valid & nxt_valid & ~(p2f_rd_valid || c2f_rd_valid))) begin  // promote → clear nxt  
                nxt_valid <= 1'b0;
            end
        end
    end

    /* promote nxt → cur when cur empty */
    wire cur_accepted = cur_valid &
                        (cur_is_read  ?  app_rdy
                                      : (app_rdy & app_wdf_rdy));

    always @(posedge clk) begin
        if (rst)
            cur_valid <= 1'b0;
        else begin
            if (~cur_valid & nxt_valid) begin
                cur_valid     <= 1'b1;
                cur_is_read   <= nxt_is_read;
                cur_addr      <= nxt_addr;
                cur_wd        <= nxt_wd;
            end
            else if (cur_accepted & nxt_valid) begin  
                cur_valid     <= 1'b1;
                cur_is_read   <= nxt_is_read;
                cur_addr      <= nxt_addr;
                cur_wd        <= nxt_wd;
            end
            else if (cur_accepted & ~nxt_valid & p2f_rd_valid) begin  
                cur_valid     <= 1'b1;
                cur_is_read   <= p2f_rd_data[148];
                cur_addr      <= p2f_rd_data[147:128];
                cur_wd        <= p2f_rd_data[127:0];
            end
            else if (cur_accepted & ~nxt_valid & c2f_rd_valid) begin  
                cur_valid     <= 1'b1;
                cur_is_read   <= c2f_rd_data[148];
                cur_addr      <= c2f_rd_data[147:128];
                cur_wd        <= c2f_rd_data[127:0];
            end
            else if (cur_accepted & ~nxt_valid & ~(p2f_rd_valid || c2f_rd_valid))  
                cur_valid <= 1'b0;
        end
    end

    // =========================================================================
    // 2. MIG command & write-data (combinational)
    // =========================================================================
    
    assign app_en   = (cur_accepted)? cur_valid : 1'b0; 
    assign app_cmd  = cur_is_read ? 3'b001/*RD*/ : 3'b000/*WR*/;
    assign app_addr = {7'b0, cur_addr[19:0], 3'b000};     // 256-bit line  // just used all addresses (doesn't use half-select)

    assign app_wdf_wren = (cur_accepted)? cur_valid & ~cur_is_read : 1'b0 ; 
    assign app_wdf_end  = app_wdf_wren;
    assign app_wdf_data = {128'd0, cur_wd};  
    assign app_wdf_mask = {16'hFFFF,16'd0};  
//    assign app_wdf_data = cur_addr[0] ? {cur_wd, 128'd0}
//                                      : {128'd0, cur_wd};
//    assign app_wdf_mask = cur_addr[0] ? {16'd0,16'hFFFF}
//                                      : {16'hFFFF,16'd0};


    // =========================================================================
    // 3.  Output FIFO writes (phase-dependent)
    // =========================================================================
    // should I consider f2c_fifo_full?? I don't think so... because it survived even for f2p_fifo_full (200MHz <-> 100.8MHz) 애초에 f2p_fifo_full && f2p_fifo_wr_en == 1인 경우가 발생하지 않았음.
    always @(posedge clk) begin
        // default 0
        f2p_wr_en <= 1'b0;
        f2c_wr_en <= 1'b0;
        f2p_wr_data <= 128'b0;
        f2c_wr_data <= 128'b0;

        if (app_rd_valid) begin
            case (phase)
                PH_PC: begin
                    f2p_wr_en <= 1'b1;     // PC read-back     
                    f2p_wr_data <= app_rd_data[127:0] ;  
                end
                PH_CHIP : begin
                    f2c_wr_en <= 1'b1;     // DRAM → CHIP
                    f2c_wr_data <= app_rd_data[127:0] ;  
                end
                default : ;                    
            endcase
        end
    end


endmodule
