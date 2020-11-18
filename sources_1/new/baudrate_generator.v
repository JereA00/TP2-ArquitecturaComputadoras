`timescale 1ns / 1ps

module baudrate_generator
    #(
        parameter CLOCK_FREQ = 50*(10**6),
        parameter BAUD_RATE  = 9600,
        parameter BAUDRATE_MAX_COUNT = 325,
        parameter BAUDRATE_NUM_BITS = 9
    )
    (
        output                   o_brg_tck,
        input                        i_clk,
        input                      i_reset
    );
    
    reg [BAUDRATE_NUM_BITS:0]   baudrate_counter_reg;     // Registro usado para contar
    
    always @(posedge i_clk or posedge i_reset) 
    begin
        if (i_reset) 
            begin
                baudrate_counter_reg <= {BAUDRATE_NUM_BITS{1'b0}};
            end 
        else if (o_brg_tck) 
            begin
                baudrate_counter_reg <= {BAUDRATE_NUM_BITS{1'b0}};
            end 
        else 
            begin
                baudrate_counter_reg <= baudrate_counter_reg + 1;
            end
    end
    
assign o_brg_tck = (baudrate_counter_reg == BAUDRATE_MAX_COUNT);

endmodule
