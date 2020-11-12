`timescale 1ns / 1ps

module baudrate_generator#(
        parameter   BAUDRATE_MAX_COUNT = 326,     // 50.000.000 / (16 * 9600)
                    BAUDRATE_NUM_BITS = 10
    )(
        input                     i_clk,     // Clock input
        input                   i_reset,     // Reset input
        output                   o_tick      // Cada pulso de "Baudrate" creamos un pulso de tick
    );
    reg [BAUDRATE_NUM_BITS:0]   baudrate_counter_reg;     // Registro usado para contar
    
    always @(posedge i_clk or posedge i_reset) 
    begin
        if (i_reset) 
            begin
                baudrate_counter_reg <= {BAUDRATE_NUM_BITS{1'b0}};
            end 
        else if (o_tick) 
            begin
                baudrate_counter_reg <= {BAUDRATE_NUM_BITS{1'b0}};
            end 
        else 
            begin
                baudrate_counter_reg <= baudrate_counter_reg + 1;
            end
    end
assign o_tick = (baudrate_counter_reg == BAUDRATE_MAX_COUNT);

endmodule
