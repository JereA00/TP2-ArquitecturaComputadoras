`timescale 1ns / 1ps

module interface_circuit
#(
parameter  DBIT    = 8,  // buffer bits
           NB_OP  = 6   // Operation bits
            
) 
(   //INPUT
    input                     i_clk,
    input                     i_reset,
    input                     i_rx_done,
    input      [DBIT-1:0]     i_rx_data,
    input      [DBIT-1:0]     i_alu_result,
    //OUTPUT
    output       [DBIT-1 : 0]   o_data_one,
    output       [DBIT-1 : 0]   o_data_two,
    output      [NB_OP-1 : 0]  o_operation,
    output reg                  o_tx_start,
    output      [DBIT-1:0]     o_alu_result 
);

reg [DBIT-1 : 0] r_data_one;
reg [DBIT-1 : 0] r_data_two;
reg [DBIT-1 : 0] r_operator;
reg [DBIT-1 : 0]  r_result;
reg [1:0]      counter_in;
reg [1:0]      current_state;
reg [1:0]      next_state;

localparam STATE_IDLE  = 2'b00;
localparam STATE_DIN  = 2'b01;
localparam STATE_OIN  = 2'b10;
localparam STATE_ORT  = 2'b11;

localparam DATA = 8'h64;
localparam OP   = 8'h6F;

always @(posedge i_clk) 
begin
    if (i_reset)
    begin 
        r_data_one      <= 0;
        r_data_two      <= 0;
        r_operator      <= 0;
        counter_in      <= 0;  
        r_result        <= 0;  
        current_state   <= STATE_IDLE;
        next_state      <= STATE_IDLE;
    end
    else
    begin
        current_state <= next_state;
    end
end

always @(*)
begin
    next_state = current_state;
    case(current_state)
        STATE_IDLE:
            if(i_rx_done)
            begin
                next_state = STATE_DIN;
            end
        STATE_DIN:
            if(i_rx_done)
            begin
                if(i_rx_data == DATA && counter_in == 0)
                    begin
                        counter_in = counter_in + 1;
                    end
                case (counter_in)
                    2'b01:
                        r_data_one = i_rx_data;
                    2'b10:
                    begin
                        r_data_two = i_rx_data;
                        counter_in = counter_in + 1;
                        counter_in = 0;
                        next_state = STATE_OIN;
                    end                                
                    default: 
                        counter_in = 0;
                endcase
            end
        STATE_OIN:
            if(i_rx_done)
            begin
                if(i_rx_data == OP)
                begin
                    counter_in = counter_in + 1;
                end
                case (counter_in)
                    2'b01:
                    begin
                        r_operator = i_rx_data;
                        counter_in = 0;
                        next_state = STATE_ORT;
                    end                                                              
                    default: 
                        counter_in = 0;
                endcase
            end
        STATE_ORT:
            if(i_alu_result)
            begin
                o_tx_start = 1'b1;
                r_result   = i_alu_result;
            end
    endcase
end

assign o_alu_result = r_result;
assign o_data_one = r_data_one;
assign o_data_two = r_data_two;
assign o_operation = r_operator;
endmodule
