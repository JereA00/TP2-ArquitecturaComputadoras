`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 7429 - Computer Architectura
// Engineer Student: Agustinoy J. (jeremias dot agustinoy at mi dot unc dot edu dot ar)
//                   Valenzuela G. (gabriel dot valenzuela at mi dot unc dot edu dot ar)                     
// Create Date: 11/16/2020 02:14:28 PM
// Design Name: 
// Module Name: tb_uartTx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module uart_tx 
#(
    parameter NBITS_DATA = 8,
    parameter STOPBITS_TCK = 16
)
(
    output reg             o_tx_done,
    output                      o_tx,
    input                      i_clk,
    input                    i_reset,
    input                 i_tx_start,
    input                 i_tick_brg,
    input [NBITS_DATA-1:0]    i_data
);

//--------------------------------------
//          States definitions
//--------------------------------------
localparam  [1:0] IDLE    = 2'b00;
localparam  [1:0] START   = 2'b01;
localparam  [1:0] DATA    = 2'b10;
localparam  [1:0] STOP    = 2'b11;

reg [1:0] current_state;
reg [1:0] next_state;
reg [3:0] counter_sampling_current; // Count until 7 in start sate, to 15 in data and to STOPTB_TCK in stop
reg [3:0] counter_sampling_next;
reg [2:0] counter_data_current; //In data estate
reg [2:0] counter_data_next;
reg [NBITS_DATA-1:0] shifted_bits_current;
reg [NBITS_DATA-1:0] shifted_bits_next;
reg tx_reg_current;
reg tx_reg_next;

//--------------------------------
//      FSMD state and data registers
//----------------------------------

always @(posedge i_clk)
begin
    if(i_reset)
    begin
        current_state <= IDLE;
        counter_sampling_current <= 0;
        counter_data_current <= 0;
        shifted_bits_current <= 0;
        tx_reg_current <= 1'b1;
    end
    else
    begin
        current_state            <= next_state;
        counter_sampling_current <= counter_sampling_next;
        counter_data_current     <= counter_data_next;
        shifted_bits_current     <= shifted_bits_next;
        tx_reg_current           <= tx_reg_next;
    end
end

//--------------------------------
//      FSMD next state: Logic and FU
//----------------------------------
always @*
begin
    next_state            = current_state;
    o_tx_done             = 1'b0;
    counter_sampling_next = counter_sampling_current;
    counter_data_next     = counter_data_current;
    shifted_bits_next     = shifted_bits_current;
    tx_reg_next           = tx_reg_current;

    case (current_state)
        IDLE:
            begin
                tx_reg_next = 1'b1;
                if(i_tx_start)
                begin
                    next_state = START;
                    counter_sampling_next = 0;
                    shifted_bits_next = i_data;
                end
            end
        START:
            begin
                tx_reg_next = 1'b0;
                if(i_tick_brg)
                begin
                    if(counter_sampling_current==(STOPBITS_TCK-1))
                    begin
                        next_state = DATA;
                        counter_sampling_next = 0;
                        counter_data_next     = 0;
                    end
                    else
                    begin
                        counter_sampling_next = counter_sampling_current+1;
                    end
                end
            end
        DATA:
            begin
                tx_reg_next = shifted_bits_current[0];
                if(i_tick_brg)
                begin
                    if(counter_sampling_current==(STOPBITS_TCK-1))
                    begin
                        counter_sampling_next = 0;
                        shifted_bits_next = shifted_bits_current >> 1;
                        if(counter_data_current == (NBITS_DATA-1))
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
            end
        end
        STOP:
        begin
            tx_reg_next = 1'b1;
            if(i_tick_brg)
            begin
                if(counter_sampling_current==(STOPBITS_TCK-1))
                begin
                    next_state = IDLE;
                    o_tx_done  = 1'b1;
                end
                else
                begin
                    counter_sampling_next = counter_sampling_current+1;
                end
            end
        end
    endcase
end

//-------------------------------------
// Output assign
//-------------------------------------

assign o_tx = tx_reg_current;
endmodule