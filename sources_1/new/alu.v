`timescale 1ns/1ps

module alu
        #(
            parameter N_BITS_OP = 6,
            parameter N_BITS = 8
        )
        
        (
            input wire        [N_BITS_OP - 1 : 0]           i_operator,
            input wire signed [N_BITS - 1 : 0]              i_data1,
            input wire signed [N_BITS - 1 : 0]              i_data2, 
            output reg        [N_BITS - 1 : 0]              o_alu
        );
                
        /*!
        *
        *   +++++++++++++++++ Parameter Lists +++++++++++++++++
        *
        */
        
        parameter ADD_OP =  6'b100000;
        parameter SUB_OP =  6'b100010;
        parameter AND_OP =  6'b100100;
        parameter OR_OP  =  6'b100101;
        parameter XOR_OP =  6'b100110;
        parameter SRA_OP =  6'b000011;
        parameter SRL_OP =  6'b000010;
        parameter NOR_OP =  6'b100111;
        
        always@(*)
        begin
                case (i_operator)
                    ADD_OP: o_alu = i_data1 + i_data2;    //ADD
                    SUB_OP: o_alu = i_data1 - i_data2;    //SUB 
                    AND_OP: o_alu = i_data1 & i_data2;    //AND 
                    OR_OP:  o_alu = i_data1 | i_data2;    //OR
                    XOR_OP: o_alu = i_data1 ^ i_data2;    //XOR
                    SRA_OP: 
                    begin
                        if (i_data2 > i_data1) begin
                            o_alu = {N_BITS{1'b0}};
                        end 
                        else begin 
                            o_alu = i_data1 >>> i_data2;  //SRA
                        end 
                    end
                    SRL_OP: 
                    begin
                        if (i_data2 > i_data1) begin
                            o_alu = {N_BITS{1'b0}};
                        end 
                        else begin 
                            o_alu = i_data1 >> i_data2;   //SRL
                        end 
                    end 
                    NOR_OP: o_alu = ~(i_data1 | i_data2); //NOR
                    default  : 
                    begin
                        o_alu = {N_BITS{1'b0}};
                    end
                endcase
        end
 endmodule
