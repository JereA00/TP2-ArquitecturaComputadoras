`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2020 02:14:28 PM
// Design Name: 
// Module Name: tb_uartTx
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

module tb_uartTx;
    localparam T = 20;
    localparam NB_DATA = 8;
    localparam NB_STOPT = 16;
    
    reg clk;
    reg reset;  
    reg tx_start;
    reg brg_clk;
    reg [NB_DATA-1:0] data;
    wire tx_done;
    wire tx_out;
    
    //------------------------------
    //      Module instanciation
    //------------------------------
    
    uart_tx
    #(
        .NBITS_DATA(NB_DATA),
        .STOPBITS_TCK(NB_STOPT)
    )
    u_uart_tx
    (
        .o_tx_done(tx_done),
        .o_tx(tx_out),
        .i_clk(clk),
        .i_reset(reset),
        .i_tx_start(tx_start),
        .i_tick_brg(brg_clk),
        .i_data(data)
    );
          
    initial
    begin
        clk      = 1'b0;
        brg_clk  = 1'b0;
        reset    = 1'b1;
        data     = 8'b000000;
        tx_start = 1'b0;
        #T;
        reset    = 1'b0;
        #(2*T);
        data     = 8'b00110011;
        #T;
        tx_start = 1'b1;
        #T
        tx_start = ~tx_start;
        wait(tx_done == 1'b1);
        data     = 8'b11110010;
        #T;
        tx_start = ~tx_start;
        #T
        tx_start = ~tx_start;
        #(1000*T);
        $finish;
    end
    
    always
    begin
    clk = 1'b1;
    #(T/4);
    clk = 1'b0;
    #(T/4);
    end
    
    always
    begin
    brg_clk = 1'b1;
    #(T*1.2);
    brg_clk = 1'b0;
    #(T*1.2);
    end
    
endmodule
