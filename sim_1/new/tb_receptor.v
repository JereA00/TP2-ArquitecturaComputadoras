`timescale 1ns / 1ps

module tb_receptor();
    parameter   BITS_DATA = 8;
    
    reg                            i_clk;
    reg                       i_reset_01;
    reg                            rx_01;
    reg                        s_tick_01;
    wire                 rx_done_tick_01;
    wire [BITS_DATA-1:0]      data_out_01;
    
    initial
    begin
        $dumpfile("tb_receptor.vcd");
        $dumpvars(0,tb_receptor);
        i_clk           = 1'b0;
        i_reset_01      = 1'b1;
        s_tick_01       = 1'b0;
        rx_01           = 1'b1;
        #15
        i_reset_01      = 1'b0;
        
        /*
            64 viene dado porque cada 5 instantes de tiempo cambia el estado del rate o sea, 
            cada 10 instantes de tiempo hay un nuevo tick entonces 16 * 4 = 64
            
            IMPORTANTE: Observar que para 5 rate para el tick nuevo, falla, porque el tick y el clk estan sincronizados
            Eso es un error del receptor en el always de los estados.
        */
        //START
        #64 rx_01           = 1'b0;
        
        //Datos 
        #64 rx_01           = 1'b1; //Bit 0
       
        #64 rx_01           = 1'b0; //Bit 1
        
        #64 rx_01           = 1'b1; //Bit 2
        
        #64 rx_01           = 1'b0; //Bit 3
        
        #64 rx_01           = 1'b1; //Bit 4
        
        #64 rx_01           = 1'b0; //Bit 5
        
        #64 rx_01           = 1'b1; //Bit 6
        
        #64 rx_01           = 1'b0; //Bit 7
        
        //STOP
        #64 rx_01           = 1'b1; 
        
        
        #4000 $finish;
        
    end
    
    always
        begin
            #1 i_clk=~i_clk; // Simulacion de clock.
        end
    always begin
        #3 s_tick_01=~s_tick_01;
        #1 s_tick_01=~s_tick_01;
    end
    
    
    receptor
    #(
        .BITS_DATA      (BITS_DATA)
    )
    u_receptor
    (
        .rx                       (rx_01),
        .s_tick               (s_tick_01),
        .i_clk                    (i_clk),
        .i_reset             (i_reset_01),
        .rx_done_tick   (rx_done_tick_01),
        .data_out           (data_out_01)
    );  
    
endmodule
