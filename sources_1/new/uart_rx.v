`timescale 1ns / 1ps

module uart_rx
   #(
      parameter   NBITS_DATA = 8,
      parameter STOPBITS_TCK = 16
   )
   (
      output  reg                o_rx_done,
      output  [NBITS_DATA-1:0]       o_data,
      input                            i_rx,
      input                      i_tick_brg,
      input                           i_clk,
      input                         i_reset
   );
   
//--------------------------------------
//          States definitions
//--------------------------------------   
localparam IDLE    = 2'b00;    //Espero el bit de start
localparam START   = 2'b01;    //Inicializa los registros, solo se ejecuta un ciclo
localparam DATA    = 2'b10;    //Carga datos en el shift reg
localparam STOP    = 2'b11;    //Paso los datos a out, espero el bit de stop

reg [1:0] current_state;
reg [1:0] next_state;
reg [3:0] counter_sampling_current; // Count until 7 in start sate, to 15 in data and to STOPTB_TCK in stop
reg [3:0] counter_sampling_next;
reg [2:0] counter_data_current; //In data estate
reg [2:0] counter_data_next;
reg [NBITS_DATA-1:0] data_buffer_current;
reg [NBITS_DATA-1:0] data_buffer_next;
   
//--------------------------------
//      FSMD state and data registers
//----------------------------------

   always @(posedge i_clk)
      if (i_reset) //Se resetea el receptor
         begin
               current_state            <= IDLE;
               counter_sampling_current <= 0;
               counter_data_current     <= 0;
               data_buffer_current      <= {NBITS_DATA{1'b0}};
         end
      else
         begin
            current_state              <= next_state;          //Pasa al siguiente estado
            counter_sampling_current   <= counter_sampling_next;          
            counter_data_current       <= counter_data_next;           
            data_buffer_current        <= data_buffer_next;
         end
//--------------------------------
//      FSMD next state: Logic and FU
//----------------------------------
   always @(*)
   begin
      next_state               = current_state;
      o_rx_done                = 1'b0;
      counter_sampling_next    = counter_sampling_current;
      counter_data_next        = counter_data_current;
      data_buffer_next         = data_buffer_current;
      
      case (current_state)
         IDLE:
            if (~i_rx)
               begin
                  next_state              = START;    //Proximo estado como START y cant ticks en 0
                  counter_sampling_next   = 0;
               end
         START: //Se cuentan los ticks hasta llegar al septimo
            if (i_tick_brg)
               if (counter_sampling_current==(NBITS_DATA-1))
                  begin
                     next_state                = DATA;     //Proximo estado como DATA para receptar el dato
                     counter_sampling_next     = 0;        //La cantidad de ticks y bits en 0
                     counter_data_next         = 0;
                  end
               else
                  counter_sampling_next = counter_sampling_current + 1;   //Aumento la cantidad de ticks 
         DATA:
            if (i_tick_brg)
               if (counter_sampling_current==(STOPBITS_TCK-1))
                  begin
                     counter_sampling_next   = 0;
                     data_buffer_next        = {i_rx, data_buffer_current[7:1]};    //Se arma el buffer
                     if (counter_data_current==(NBITS_DATA-1))
                     begin
                        next_state = STOP;
                     end
                     else
                     begin
                        counter_data_next = counter_data_current + 1;
                     end
                  end
               else
               begin
                  counter_sampling_next = counter_sampling_current + 1;
               end
         STOP:
            if (i_tick_brg)
               if (counter_sampling_current==(STOPBITS_TCK-1)) //Llego a 15 ticks
                  begin
                     next_state = IDLE;
                     o_rx_done  =1'b1;    //Se termino la recepcion
                  end
               else
                  counter_sampling_next = counter_sampling_current + 1;
      endcase
   end
   assign o_data = data_buffer_current;
endmodule
