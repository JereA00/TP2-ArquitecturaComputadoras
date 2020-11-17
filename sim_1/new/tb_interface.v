`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2020 08:26:12 PM
// Design Name: 
// Module Name: tb_interface
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


module tb_interface(

    );
    
    localparam T = 20;
    localparam NB_DATA = 8;
    localparam NB_STOPT = 16;
    
    reg clk;
    reg reset;  
    reg data_rx;
    wire tx_start;
    reg rx_done;    
    wire [NB_DATA-1:0] data_one;
    wire [NB_DATA-1:0] data_two;
    wire [6-1:0] operator;
    wire [NB_DATA-1:0] tx_data;
    reg [NB_DATA-1:0] rx_data;
    wire [NB_DATA-1:0] alu_result;
    
    
    //------------------------------
    //      Module instanciation
    //------------------------------
    
    interface_circuit
    #(
        .DBIT(NB_DATA),
        .NB_OP(6)        
    )
    u_interface
    (
        .o_data_one(data_one),
        .o_data_two(data_two),
        .o_operation(operator),
        .o_tx_start(tx_start),
        .o_alu_result(tx_data),
        .i_clk(clk),
        .i_reset(reset),
        .i_rx_done(rx_done),
        .i_rx_data(rx_data),
        .i_alu_result(alu_result)
        
    );
    
    alu
    #(
        .N_BITS_OP(6),
        .N_BITS(NB_DATA)
    )
    u_alu
    (
        .o_alu(alu_result),
        .i_data_one(data_one),
        .i_data_two(data_two),
        .i_operator(operator)
        
    );
    
    initial
    begin
        clk      = 1'b0;
        rx_done  = 1'b0;
        reset    = 1'b1;
        rx_data  = 8'b0;
        data_rx  = 1'b0;
        #(T);
        reset    = 1'b0;
        
        rx_data  = 8'h64;
        rx_done = ~rx_done;
        #(T/2);
        rx_done = ~rx_done;
        #(T);
        rx_data  = 8'h0A;
        rx_done = ~rx_done;
        #(T/2);
        rx_done = ~rx_done;
        #(T);
                
        rx_data  = 8'h64;
        rx_done = ~rx_done;
        #(T/2);
        rx_done = ~rx_done;
        #(T);
        rx_data  = 8'h05;
        rx_done = ~rx_done;
        #(T/2);
        rx_done = ~rx_done;
        #(T);
        
        rx_data  = 8'h6F;
        rx_done = ~rx_done;
        #(T/2);
        rx_done = ~rx_done;
        #(T);
        rx_data  = 8'h20;
        rx_done = ~rx_done;
        #(T/2);
        rx_done = ~rx_done;
        #(T);
        
        reset    = 1'b1;
        #(T);
        reset    = 1'b0;
        
        rx_data  = 8'h64;
        rx_done = ~rx_done;
        #(T/2);
        rx_done = ~rx_done;
        #(T);
        rx_data  = 8'h0A;
        rx_done = ~rx_done;
        #(T/2);
        rx_done = ~rx_done;
        #(T);
                
        rx_data  = 8'h64;
        rx_done = ~rx_done;
        #(T/2);
        rx_done = ~rx_done;
        #(T);
        rx_data  = 8'h05;
        rx_done = ~rx_done;
        #(T/2);
        rx_done = ~rx_done;
        #(T);
        
        rx_data  = 8'h6F;
        rx_done = ~rx_done;
        #(T/2);
        rx_done = ~rx_done;
        #(T);
        rx_data  = 8'h24;
        rx_done = ~rx_done;
        #(T/2);
        rx_done = ~rx_done;
        #(T);
        
        rx_done = ~rx_done;        
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
endmodule
