module sram_real_layer1 #(
    parameter N = 160, 
    parameter W = 992
) (
    clk,
    A,
    D,
    CEB,
    WEB,
    Q
);

// synopsys template
localparam M = $clog2(W);
// Input-Output declarations
input wire         clk;
input wire [M-1:0] A;               // Address bus
input wire [N-1:0] D;               // Date input bus
input wire         CEB;             // Active-low Chip enable
input wire         WEB;             // Active-low Write enable
output wire [N-1:0] Q;               // Data output bus

// ln28fds_mc_ra1_hdr_rvt_992x160m4b1c1 u_ln28fds_mc_ra1_hdr_rvt_992x160m4b1c1(
//     .CK     ( clk     ),
//     .A      ( A      ),
//     .DI     ( D     ),
//     .CSN    ( CEB    ),
//     .WEN    ( WEB    ),
//     .RET    ( 1'b0    ),
//     .MCS    ( 2'b01    ),
//     .DFTRAM ( 1'b0 ),
//     .SE     ( 1'b0     ),
//     .ADME   ( 2'b00   ),
//     .DOUT   ( Q   ),
//     .SI_D_L ( 1'b0 ),
//     .SI_D_R ( 1'b0 ),
//     .SO_D_L (  ),
//     .SO_D_R (  )
// );
ln28fds_mc_ra1_hdr_rvt_992x160m4b1c1 u_ln28fds_mc_ra1_hdr_rvt_992x160m4b1c1(
    .clka     ( clk     ),
    .addra      ( A      ),
    .dina     ( D     ),
    .wea    ( !WEB    ),
    .douta   ( Q   )
);

endmodule
