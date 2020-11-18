`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/18/2020 01:24:59 AM
// Design Name: 
// Module Name: Integration_test
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


module integration_test();
    localparam CLOCK_FREQ   = 10*(10**6);
    localparam BAUD_RATE    = 9600;
    localparam NB_DATA      = 8;
    localparam NB_STOPT     = 16;
    localparam N_BITS_OP    = 6;  
    localparam T            = 100;
    localparam middle       = 60;
    
    reg clk;
    reg reset;
    reg tx_start;
    
    reg [NB_DATA-1:0] data_rx;
    reg [NB_DATA-1:0] tx_data;
    
    wire w_tx_out;
    wire w_tx_flag;
    
    wire w_dummy_rx_in;
    wire w_dummy_rx_flag;
    wire w_dummy_brg;
    
    wire w_dummy_tx_out;
    wire [NB_DATA-1:0] w_dummy_data_rx;
    top_module
    #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE (BAUD_RATE ),
        .NB_DATA   (NB_DATA   ),
        .NB_STOPT  (NB_STOPT  ),
        .N_BITS_OP (N_BITS_OP )
    )
    top_integration
    (
        .o_tx(w_tx_out),
        .o_tx_flag(w_tx_flag),
        .i_rx(w_dummy_rx_in),
        .i_rx_flag(w_dummy_rx_flag),
        .clk(clk),
        .i_reset(reset)
    );
    
    uart_tx
    #(
        .NBITS_DATA(NB_DATA),
        .STOPBITS_TCK(NB_STOPT)
    )
    dummy_tx
    (
        .o_tx_done(w_dummy_rx_flag),
        .o_tx(w_dummy_rx_in),
        .i_clk(clk),
        .i_reset(reset),
        .i_tx_start(tx_start),
        .i_tick_brg(w_dummy_brg),
        .i_data(tx_data)
    );
    
    uart_rx
    #(
        .NBITS_DATA(NB_DATA),
        .STOPBITS_TCK(NB_STOPT)
    )
    dummy_rx
    (
        .o_rx_done(w_dummy_tx_out),
        .o_data(w_dummy_data_rx),
        .i_clk(clk),
        .i_reset(reset),
        .i_rx(w_tx_out),
        .i_tick_brg(w_dummy_brg)
    );
    
    baudrate_generator
    #(
        .CLOCK_FREQ      (CLOCK_FREQ),
        .BAUD_RATE       (BAUD_RATE),
        .BAUDRATE_MAX_COUNT (65),
        .BAUDRATE_NUM_BITS (7)
    )
    u_baudrate_generator
    (
        .i_clk                   (clk),
        .i_reset               (reset),
        .o_brg_tck       (w_dummy_brg)
    ); 

    initial
    begin
        assign data_rx = w_dummy_data_rx;
        clk = 1'b0;
        tx_start = 1'b0;
        reset = 1'b1;
        data_rx = {NB_DATA{1'b0}};
        tx_data = {NB_DATA{1'b0}};
        #(T);
        tx_start = 1'b1;
        reset = 1'b0;
        tx_data = 8'h0A;
        @(posedge w_dummy_rx_flag);
        tx_data = 8'h0A;
        @(posedge w_dummy_rx_flag);
        tx_data = 8'h64;
        @(posedge w_dummy_rx_flag);
        tx_data = 8'h0A;
        @(posedge w_dummy_rx_flag);
        tx_data = 8'h6F;
        @(posedge w_dummy_rx_flag);
        tx_data = 8'h20;
        @(posedge w_dummy_rx_flag);
        wait(data_rx == 8'h0F); 
        #(100000000*T);
        $finish;
    end

    always
    begin
        clk = ~clk;
        #(T/2);
        clk = ~clk;
        #(T/2);
    end
    
    task send_uart;
    input [NB_DATA -1 : 0] data_to_send;
    begin
        data_rx = data_to_send;
        #(T);
        
    end
    endtask
endmodule
