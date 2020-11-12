`timescale 1ns / 1ps

module receptor#(
    parameter   BITS_DATA = 8
    )(
    input                                 rx,
    input                             s_tick,
    input                              i_clk,
    input                            i_reset,
    output  reg                 rx_done_tick,
    output  [BITS_DATA-1:0]          data_out
    );
    
   //Estados del receptor 
   localparam [1:0]
        IDLE    = 2'b00,    //Espero el bit de start
        START   = 2'b01,    //Inicializa los registros, solo se ejecuta un ciclo
        DATA    = 2'b10,    //Carga datos en el shift reg
        STOP    = 2'b11;    //Paso los datos a out, espero el bit de stop
        
   // Registros del receptor
   reg  [1:0]           state_reg, state_next;
   reg  [3:0]           ticks_reg, ticks_next;
   reg  [2:0]                   n_reg, n_next;
   reg  [BITS_DATA-1:0]   buffer, buffer_next;
   
   //Registros de datos y estados
   always @(posedge i_clk)
      if (i_reset) //Se resetea el receptor
         begin
            state_reg   <= IDLE;                //Estado de espera por bits de start
            ticks_reg   <= 0;                   //Cantidad de ticks
            n_reg       <= 0;                   //Cantidad de bits
            buffer      <= {BITS_DATA{1'b0}};   //Vacia el buffer de bits      
         end
      else
         begin
            state_reg   <= state_next;          //Pasa al siguiente estado
            ticks_reg   <= ticks_next;          
            n_reg       <= n_next;           
            buffer      <= buffer_next;
         end
 
   // Logica para el proximo estado
   always @(*)
   begin
      state_next    = state_reg;
      rx_done_tick  = 1'b0;
      ticks_next    = ticks_reg;
      n_next        = n_reg;
      buffer_next   = buffer;
      
      case (state_reg)
         IDLE:  //Espera de bit de start
            if (~rx)
               begin
                  state_next    = START;    //Proximo estado como START y cant ticks en 0
                  ticks_next        = 0;
               end
         START: //Se cuentan los ticks hasta llegar al septimo
            if (s_tick)
               if (ticks_reg==7)
                  begin
                     state_next     = DATA;     //Proximo estado como DATA para receptar el dato
                     ticks_next     = 0;        //La cantidad de ticks y bits en 0
                     n_next         = 0;
                  end
               else
                  ticks_next = ticks_reg + 1;   //Aumento la cantidad de ticks 
         DATA:
            if (s_tick)
               if (ticks_reg==15)
                  begin
                     ticks_next         = 0;
                     buffer_next        = {rx, buffer[7:1]};    //Se arma el buffer
                     
                     if (n_reg==(BITS_DATA-1))  //Se recibieron todos los bits
                        state_next = STOP ;
                      else
                        n_next = n_reg + 1;     //Se siguen recibiendo datos
                   end
               else
                  ticks_next = ticks_reg + 1;
         STOP:
            if (s_tick)
               if (ticks_reg==15) //Llego a 15 ticks
                  begin
                     state_next = IDLE;
                     rx_done_tick =1'b1;    //Se termino la recepcion
                  end
               else
                  ticks_next = ticks_reg + 1;
      endcase
   end
   assign data_out = buffer;
endmodule
