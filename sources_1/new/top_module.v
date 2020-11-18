`timescale 1ns / 1ps
module top_module
    #(
        parameter CLOCK_FREQ   = 50*(10**6),
        parameter BAUD_RATE    = 9600,        
        parameter NB_DATA      = 8,
        parameter NB_STOPT     = 16,
        parameter N_BITS_OP    = 6                
    )
    (
        output o_tx,
        output o_tx_flag,
        input  i_rx,
        input  i_rx_flag,
        input  clk,
        input  i_reset
    );
      
    
    
    /*
    //**************************************
      Register used to hold data
    //**************************************
    reg r_tx_out;
    reg r_tx_flag;
    reg r_rx_in;
    reg r_rx_flag;
    
    always@(posedge i_reset)
    begin
        r_tx_out    <= 0;
        r_tx_flag   <= 0;
        r_rx_in     <= 0;
        r_rx_flag   <= 0;
    end
    assign o_tx      = r_tx_out;
    assign o_tx_flag = r_tx_flag;
    assign i_rx      = r_rx_in;
    assign i_rx_flag = r_rx_flag;
    */
    
    

    //**************************************
    //*  Wires used to interconnect modules
    //**************************************

    wire                         w_brg;
    wire [NB_DATA-1:0]      w_data_one;
    wire [NB_DATA-1:0]      w_data_two;
    wire [N_BITS_OP-1:0]    w_operator;
    wire [NB_DATA-1:0]        w_result;
    wire                    w_start_tx;
    wire                     w_done_rx;
    wire [NB_DATA-1:0]    w_data_to_tx;
    wire [NB_DATA-1:0]  w_data_from_rx;
    
    localparam BAUDRATE_MAX_COUNT = $ceil(CLOCK_FREQ/(16*BAUD_RATE));
    localparam BAUDRATE_NUM_BITS  = $clog2(BAUDRATE_MAX_COUNT);

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
        .i_reset             (i_reset),
        .o_brg_tck             (w_brg)
    );

    uart_tx
    #(
        .NBITS_DATA(NB_DATA),
        .STOPBITS_TCK(NB_STOPT)
    )
    u_uart_tx
    (
        .o_tx_done    (o_tx_flag),
        .o_tx              (o_tx),
        .i_clk              (clk),
        .i_reset        (i_reset),
        .i_tx_start  (w_start_tx),
        .i_tick_brg       (w_brg),
        .i_data    (w_data_to_tx)
    );

    uart_rx
    #(
        .NBITS_DATA(NB_DATA),
        .STOPBITS_TCK(NB_STOPT)
    )
    u_uart_rx
    (
        .o_rx_done       (w_done_rx),
        .o_data     (w_data_from_rx),
        .i_rx                 (i_rx),
        .i_tick_brg          (w_brg),
        .i_clk                 (clk),
        .i_reset           (i_reset)
    );

    interface_circuit
    #(
        .DBIT(NB_DATA),
        .NB_OP(N_BITS_OP)        
    )
    u_interface
    (
        .o_data_one       (w_data_one),
        .o_data_two      (w_data_two),
        .o_operation     (w_operator),
        .o_tx_start      (w_start_tx),
        .o_alu_result  (w_data_to_tx),
        .i_clk                  (clk),
        .i_reset            (i_reset),
        .i_rx_done        (w_done_rx),
        .i_rx_data   (w_data_from_rx),
        .i_result_from_alu (w_result)
        
    );

    alu
    #(
        .N_BITS_OP(N_BITS_OP),
        .N_BITS(NB_DATA)
    )
    u_alu
    (
        .o_alu       (w_result),
        .i_data_one(w_data_one),
        .i_data_two(w_data_two),
        .i_operator(w_operator)
        
    );    

endmodule
