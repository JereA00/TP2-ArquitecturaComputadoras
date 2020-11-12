`timescale 1ns / 1ps

module tb_baudrate_gen();
    parameter BAUDRATE_MAX_COUNT = 15;
    parameter BAUDRATE_NUM_BITS = 5;
    
    reg                              clk;
    reg                          i_reset;
    wire                        out_tick;
    
    initial
    begin
        $dumpfile("tb_baudrate_gen.vcd");
        $dumpvars(0,tb_baudrate_gen);
        clk          = 1'b0;
        i_reset      = 1'b0;
        #10
        i_reset      = 1'b1;
        #10
        i_reset      = 1'b0;
        #2000
        $finish;
    end
    
    always
        begin
            #5 clk = ~clk;
        end
        
        
    baudrate_generator
    #(
        .BAUDRATE_MAX_COUNT      (BAUDRATE_MAX_COUNT),
        .BAUDRATE_NUM_BITS       (BAUDRATE_NUM_BITS)
    )
    u_baudrate_generator
    (
        .i_clk                   (clk),
        .i_reset             (i_reset),
        .o_tick              (out_tick)
    ); 
    
endmodule
