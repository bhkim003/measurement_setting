//////////////////////////////////////////////////////////////////////////////////
// Engineer: Kim Beomseok
// Contact: kimbss470@snu.ac.kr
// 
// Create Date: 24/07/2024 
// Design Name: PseudoChip which emulages DRAM read/write
// Module Name: pseudoCore
// Project Name: 2024TapeOut
// Target Devices: XEM7360-K160T
// Tool versions: 2024.1
// Description: Emulates DRAM read/write by chip
//
//////////////////////////////////////////////////////////////////////////////////

module pseudoCore (
    input              clk,
    input              rstn,

    input              single_rate,   // 0: dual-rate , 1: single-rate

    input              start,
    input              start_store_byte4,
    output reg         done,

    output reg         load_or_store,   
    output reg         store_byte4,   

    output reg [ 27:0] axi_araddr,
    output reg [  7:0] axi_arlen,
    output reg         axi_arvalid,
    input              axi_arready,
    input              axi_rvalid,
    output reg         axi_rready,
    input      [255:0] axi_rdata,

    output reg [ 27:0] axi_awaddr,
    output reg [  7:0] axi_awlen,
    output reg         axi_awvalid,
    input              axi_awready,
    output             axi_wvalid,
    input              axi_wready,
    output reg [255:0] axi_wdata
);

    //************************************************************
    // Localparams
    //************************************************************

    localparam LOAD  = 1'b0;
    localparam STORE = 1'b1;

    localparam S_IDLE        = 3'd0;
    localparam S_READ        = 3'd1;
    localparam S_WRITE       = 3'd2;
    localparam S_WRITE_BYTE4 = 3'd3;
    localparam S_IO_T        = 3'd4;

    localparam TARGET_ADDR = 28'h000_1000;

    //************************************************************
    // Wires
    //************************************************************

    integer i;

    reg [2:0]   state;
    reg [2:0]   next_state;
    reg [255:0] mem [0:15];
    reg [27:0]  store_byte4_addr_arr [0:3];

    reg [8:0] n_transfer;
    reg [8:0] i_transfer;
    reg [8:0] n_request;
    reg [8:0] i_request;
    reg [4:0] io_trans_cnt;
    
    reg [1:0] delay_3;               // 3 clk cycles are required for axaddr & axlen handshaking
    reg       axi_awaddr_trans_done;
    reg       axi_wdata_trans_done;
    reg       axi_wvalid_tmp;        // to support single-rate I/O mode
    reg       iter_1;                // to support single-rate I/O mode
    reg       first_write;

    assign axi_wvalid = axi_wvalid_tmp && (!iter_1);


    //************************************************************
    // FSM
    //************************************************************

    /* Control flow */
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            state <= S_IDLE;
            next_state <= S_IDLE;
        end
        else begin
            case (state) 
                S_IDLE: begin
                    if      (start)             state <= S_READ;
                    else if (start_store_byte4) begin next_state <= S_WRITE_BYTE4; state <= S_IO_T; end
                    else                        state <= S_IDLE;
                end
                S_READ: begin
                    if (axi_rready && axi_rvalid && (i_transfer == n_transfer - 1)) begin 
                        state      <= S_IO_T;
                        next_state <= S_WRITE;
                    end
                    else state <= S_READ;
                end
                S_WRITE: begin
                    if (axi_awaddr_trans_done && (axi_wdata_trans_done || (axi_wready && axi_wvalid && (i_transfer == n_transfer)))) begin
                        state      <= S_IO_T;
                        next_state <= S_IDLE;
                    end
                    else state <= S_WRITE;
                end
                S_WRITE_BYTE4: begin
                    if (axi_awaddr_trans_done && (axi_wdata_trans_done || (axi_wready && axi_wvalid && (i_transfer == n_transfer)))) begin
                        state      <= S_IO_T;
                        next_state <= S_IDLE;
                    end
                    else state <= S_WRITE_BYTE4;
                end
                S_IO_T: begin
                    if (io_trans_cnt == 5'd16) state <= next_state;
                end
            endcase
        end
    end

    /* Data flow */
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            done           <= 1'b0;

            mem[ 0]        <= 'd0;
            mem[ 1]        <= 'd0;
            mem[ 2]        <= 'd0;
            mem[ 3]        <= 'd0;
            mem[ 4]        <= 'd0;
            mem[ 5]        <= 'd0;
            mem[ 6]        <= 'd0;
            mem[ 7]        <= 'd0;
            mem[ 8]        <= 'd0;
            mem[ 9]        <= 'd0;
            mem[10]        <= 'd0;
            mem[11]        <= 'd0;
            mem[12]        <= 'd0;
            mem[13]        <= 'd0;
            mem[14]        <= 'd0;
            mem[15]        <= 'd0;
              
            store_byte4_addr_arr[0] <= TARGET_ADDR + 28'h0;
            store_byte4_addr_arr[1] <= TARGET_ADDR + 28'h24;   // + 36
            store_byte4_addr_arr[2] <= TARGET_ADDR + 28'h48;   // + 72
            store_byte4_addr_arr[3] <= TARGET_ADDR + 28'h6C;   // + 108

            n_transfer     <= 9'd0;
            i_transfer     <= 9'd0;
            n_request      <= 9'd0;
            i_request      <= 9'd0;
  
            io_trans_cnt   <= 5'd0;

            store_byte4    <= 1'b0;
  
            axi_araddr     <= 28'd0;
            axi_arlen      <= 8'd0;
            axi_arvalid    <= 1'b0;
            axi_rready     <= 1'b0;

            axi_awaddr     <= 28'd0;
            axi_awlen      <= 8'd0;
            axi_awvalid    <= 1'b0;
            axi_wvalid_tmp <= 1'b0;
            axi_wdata      <= 'd0;

            axi_wdata_trans_done <= 1'b0;
            axi_awaddr_trans_done <= 1'b0;
            delay_3        <= 2'd0;
            first_write    <= 1'b1;
        end

        else begin
            case (state) 
                S_IDLE: begin
                    done           <= 1'b0;

                    mem[ 0]        <= 'd0;
                    mem[ 1]        <= 'd0;
                    mem[ 2]        <= 'd0;
                    mem[ 3]        <= 'd0;
                    mem[ 4]        <= 'd0;
                    mem[ 5]        <= 'd0;
                    mem[ 6]        <= 'd0;
                    mem[ 7]        <= 'd0;
                    mem[ 8]        <= 'd0;
                    mem[ 9]        <= 'd0;
                    mem[10]        <= 'd0;
                    mem[11]        <= 'd0;
                    mem[12]        <= 'd0;
                    mem[13]        <= 'd0;
                    mem[14]        <= 'd0;
                    mem[15]        <= 'd0;
                       
                    i_transfer     <= 9'd0;
                    i_request      <= 9'd0;
                    n_request      <= 9'd0;
                    io_trans_cnt   <= 5'd0;
  
                    axi_awaddr     <= 28'd0;
                    axi_awlen      <= 8'd0;
                    axi_awvalid    <= 1'b0;
                    axi_wvalid_tmp <= 1'b0;
                    axi_wdata      <= 'd0;

                    axi_wdata_trans_done <= 1'b0;
                    axi_awaddr_trans_done <= 1'b0;
                    delay_3        <= 2'd0;
                    first_write    <= 1'b1;
                    
                    if (start) begin
                        store_byte4 <= 1'b0;
                        n_transfer  <= 9'd4;

                        axi_araddr  <= TARGET_ADDR;
                        axi_arlen   <= 8'd4 - 8'd1;
                        axi_arvalid <= 1'b1;
                        axi_rready  <= 1'b1;
                    end
                    else if (start_store_byte4) begin
                        store_byte4 <= 1'b1;
                        n_transfer  <= 9'd4;

                        axi_araddr  <= 28'd0;
                        axi_arlen   <= 8'd0;
                        axi_arvalid <= 1'b0;
                        axi_rready  <= 1'b0;
                    end
                    else begin
                        store_byte4 <= 1'b0;
                        n_transfer  <= 9'd0;

                        axi_araddr  <= 28'd0;
                        axi_arlen   <= 8'd0;
                        axi_arvalid <= 1'b0;
                        axi_rready  <= 1'b0;
                    end
                end

                S_READ: begin
                    // deactivate arvalid
                    if (axi_arready && axi_arvalid) begin
                        axi_arvalid <= 1'b0;
                    end

                    // i_transfer
                    if (axi_rready && axi_rvalid) begin
                        if (i_transfer == n_transfer - 1) i_transfer <= 9'd0;
                        else i_transfer <= i_transfer +  9'd1;
                    end

                    // write data into mem
                    if (axi_rready && axi_rvalid) begin
                        mem[i_transfer[3:0]] <= axi_rdata;
                    end

                    axi_awaddr_trans_done <= 1'b0;
                end

                S_WRITE: begin
                    /* No other BURST */

                    // awaddr handshaking
                    if ((axi_awready && axi_awvalid) || (delay_3 > 0)) begin
                        delay_3 <= (delay_3 < 2'd2) ? delay_3 + 2'd1 : delay_3;   // keep delay_3 == 2'd2 
                        axi_awvalid <= 1'b0;
                        // keep awaddr & awlen
                        if (delay_3 == 2'd1) axi_awaddr_trans_done <= 1'b1;
                    end

                    // wdata handshaking 
                    if (first_write) begin
                        first_write    <= 1'b0;
                        i_transfer     <= i_transfer + 9'd1;
                        axi_wvalid_tmp <= 1'b1;
                        for (i = 0; i < 32; i = i + 1) begin
                            axi_wdata[8*i+:8] <= mem[i_transfer[3:0]][8*i+:8] + 8'd1;
                        end
                    end
                    else if (axi_wready && axi_wvalid) begin                    // set next wdata
                        if (i_transfer == n_transfer) begin                     // last transfer is done
                            i_transfer     <= 9'd0;
                            axi_wvalid_tmp <= 1'b0;
                            axi_wdata      <= 'd0;
                            axi_wdata_trans_done <= 1'b1;
                        end
                        else begin
                            i_transfer     <= i_transfer + 9'd1;
                            axi_wvalid_tmp <= 1'b1;
                            for (i = 0; i < 32; i = i + 1) begin
                                axi_wdata[8*i+:8] <= mem[i_transfer[3:0]][8*i+:8] + 8'd1;
                            end
                        end
                    end
                end


                S_WRITE_BYTE4: begin
                    // awaddr handshaking is done
                    if ((axi_awready && axi_awvalid) || (delay_3 > 0)) begin   // set next awaddr

                        if ((delay_3 == 2'd1) && (i_request == n_request)) begin
                            axi_awaddr_trans_done <= 1'b1;
                        end

                        if (delay_3 == 2'd2) begin
                            if (i_request == n_request) begin
                                axi_awvalid <= 1'b0;
                                axi_awaddr  <= 28'd0;
                                axi_awlen   <= 8'd0;                    

                                i_request  <= 9'd0;       
                                delay_3     <= 2'd0;       
                            end
                            else begin
                                axi_awvalid <= 1'b1;
                                axi_awaddr  <= store_byte4_addr_arr[i_request[1:0]];
                                axi_awlen   <= 'd0;                            // only one request

                                i_request  <= i_request + 8'd1;
                                delay_3     <= 2'd0;
                            end
                        end
                        else begin
                            axi_awvalid <= 1'b0;
                            delay_3     <= delay_3 + 2'd1;
                        end
                    end

                    // wdata handshaking 
                    if (first_write) begin
                        first_write    <= 1'b0;
                        axi_wvalid_tmp <= 1'b1;
                        axi_wdata      <= 'd0;    // write ZEROs
                        i_transfer     <= i_transfer + 1;
                    end
                    else if (axi_wready && axi_wvalid) begin                   // set next wdata
                        if (i_transfer == n_transfer) begin                    // last transfer is done
                            axi_wvalid_tmp       <= 1'b0;
                            axi_wdata            <= 'd0;
                            axi_wdata_trans_done <= 1'b1;
                            i_transfer           <= 9'd0;
                            n_transfer           <= 9'd0;
                        end
                        else begin
                            axi_wvalid_tmp       <= 1'b1;
                            axi_wdata            <= 'd0;       // write ZEROs
                            i_transfer           <= i_transfer + 1;
                        end
                    end
                end


                S_IO_T: begin
                    if (io_trans_cnt == 5'd16) io_trans_cnt <= 5'd0;
                    else io_trans_cnt <= io_trans_cnt + 5'd1;

                    if (io_trans_cnt == 5'd16) begin
                        if (next_state == S_WRITE) begin
                            axi_awaddr  <= TARGET_ADDR;
                            axi_awlen   <= 8'd4 - 8'd1;
                            axi_awvalid <= 1'b1;
                        end
                        else if (next_state == S_WRITE_BYTE4) begin
                            axi_awaddr  <= store_byte4_addr_arr[i_request[1:0]];
                            axi_awlen   <= 8'd0;    // NO BURST
                            axi_awvalid <= 1'b1;
                            i_request   <= i_request + 8'd1;
                            n_request   <= 9'd4;
                        end
                        else begin
                            done        <= 1'b1;    // DONE!!
                        end
                    end
                    axi_rready <= 1'b0;
                end
            endcase
        end
    end


    /* Set iter_1 to support single-rate */
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            iter_1 <= 1'b0;
        end
        else begin
            case (state) 
                S_WRITE: begin
                    /*  no other BURST  */
                    if (first_write) begin
                        iter_1 <= single_rate ? 1'b1 : 1'b0;
                    end
                    else if (axi_wready && axi_wvalid) begin               // set next wdata
                        if ((i_transfer == n_transfer) || iter_1) begin    // last transfer is done
                            iter_1 <= 1'b0;
                        end
                        else begin
                            iter_1 <= single_rate ? 1'b1 : 1'b0;
                        end
                    end
                    else if (iter_1) iter_1 <= 'b0;
                end
                S_WRITE_BYTE4: begin
                    if (axi_wready && axi_wvalid) begin                    // set next wdata
                        if ((i_transfer == n_transfer) || iter_1) begin    // last transfer is done
                            iter_1 <= 1'b0;
                        end
                        else begin
                            iter_1 <= single_rate ? 1'b1 : 1'b0;
                        end
                    end
                    else if (iter_1) iter_1 <= 1'b0;
                end
                default: begin
                    iter_1 <= 1'b0;
                end
            endcase
        end
    end


    /* Set load_or_store */
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            load_or_store <= LOAD;
        end
        else begin
            case (state) 
                S_IDLE: begin
                    load_or_store <= LOAD;
                end
                S_READ: begin
                    // if (axi_rready && axi_rvalid && (i_transfer == n_transfer - 1)) begin
                    //     load_or_store <= STORE;
                    // end
                end
                S_WRITE: begin
                    // if (axi_wready && axi_wvalid && (i_transfer == n_transfer)) begin
                        // load_or_store <= LOAD;
                    // end
                end
                S_IO_T: begin
                    if ((next_state == S_WRITE) || (next_state == S_WRITE_BYTE4)) load_or_store <= STORE;
                    else    load_or_store <= LOAD;
                end
            endcase
        end
    end
endmodule
