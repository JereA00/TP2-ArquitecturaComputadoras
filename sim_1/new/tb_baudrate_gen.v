`timescale 1ns / 1ps

module tb_baudrate_gen();
    parameter CLOCK_FREQ = 100*(10**6);
    parameter BAUD_RATE  = 9600;
    localparam T = 10;
    
    reg                              clk;
    reg                          i_reset;
    wire                        out_tick;
    
        baudrate_generator
    #(
        .CLOCK_FREQ      (CLOCK_FREQ),
        .BAUD_RATE       (BAUD_RATE)
    )
    u_baudrate_generator
    (
        .i_clk                   (clk),
        .i_reset             (i_reset),
        .o_brg_tck              (out_tick)
    ); 
    
    initial
    begin
        clk          = 1'b0;
        i_reset      = 1'b1;
        #(T);
        i_reset      = 1'b0;
        #(1000*T);
        $finish;
    end
    
    always
        begin
            clk = 1'b1;
            #(T/2);
            clk = 1'b0;
            #(T/2);
        end
    
endmodule
