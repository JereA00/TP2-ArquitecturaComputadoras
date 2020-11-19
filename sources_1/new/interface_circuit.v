`timescale 1ns / 1ps

module interface_circuit
#(
parameter  DBIT    = 8,  // buffer bits
             NB_OP  = 6   // Operation bits
            
) 
(   
    output       [DBIT-1 : 0]   o_data_one,
    output       [DBIT-1 : 0]   o_data_two,
    output      [NB_OP-1 : 0]  o_operation,
    output reg                  o_tx_start,
    output      [DBIT-1:0]    o_alu_result,
    input                            i_clk,
    input                          i_reset,
    input                        i_rx_done,
    input      [DBIT-1:0]        i_rx_data,
    input      [DBIT-1:0]     i_result_from_alu
);

reg [DBIT-1 : 0] r_data_one;
reg [DBIT-1 : 0] r_data_two;
reg [DBIT-1 : 0] r_operator;
reg [DBIT-1 : 0]  r_result;
reg [2:0]      current_state;
reg [2:0]      next_state;
reg         flag_first_data;

localparam STATE_IDLE       = 3'b000;
localparam STATE_DATA_LOAD  = 3'b001;
localparam STATE_DATA_ONE   = 3'b010;
localparam STATE_DATA_TWO   = 3'b011;
localparam STATE_OP_LOAD    = 3'b100;
localparam STATE_OPERATION  = 3'b101;
localparam STATE_RESULT_OP  = 3'b110;

localparam DATA = 8'h64;
localparam OP   = 8'h6F;

always @(posedge i_clk) 
begin
    if (i_reset)
    begin 
        r_data_one      <= 0;
        r_data_two      <= 0;
        r_operator      <= 0;
        r_result        <= 0;
        o_tx_start      <= 0;
        current_state   <= STATE_DATA_LOAD;
        next_state      <= STATE_DATA_LOAD;
        flag_first_data <= 0;
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
                next_state = STATE_DATA_LOAD;
        STATE_DATA_LOAD:
            if(i_rx_done)
            begin
                if((i_rx_data == DATA) && (flag_first_data == 1'b0))
                begin
                    next_state      = STATE_DATA_ONE;
                    flag_first_data = 1'b1;
                end
                else if(i_rx_data == DATA && flag_first_data == 1'b1)
                begin
                    next_state = STATE_DATA_TWO;
                    flag_first_data = 1'b0;
                end      
            end
        STATE_DATA_ONE:
            if(i_rx_done)
            begin
                r_data_one = i_rx_data;
                next_state = STATE_DATA_LOAD;
            end
        STATE_DATA_TWO:
            if(i_rx_done)
            begin
                r_data_two = i_rx_data;
                next_state = STATE_OP_LOAD;
            end            
        STATE_OP_LOAD:
            if(i_rx_done)
            begin
                if(i_rx_data == OP)
                    begin
                        next_state = STATE_OPERATION;
                    end
            end
        STATE_OPERATION:
            if(i_rx_done)
            begin
                r_operator = i_rx_data;
                next_state = STATE_RESULT_OP;                
            end
        STATE_RESULT_OP:                
            begin
                o_tx_start = 1'b1;
                r_result   = i_result_from_alu;
                next_state = STATE_IDLE;
            end
    endcase
end

assign o_alu_result = r_result;
assign o_data_one = r_data_one;
assign o_data_two = r_data_two;
assign o_operation = r_operator;
endmodule
