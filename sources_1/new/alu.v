`timescale 1ns/1ps

module alu
        #(
            parameter N_BITS_OP = 6,
            parameter N_BITS = 8
        )
        ( 
            output reg        [N_BITS - 1 : 0]              o_alu,
            input wire        [N_BITS_OP - 1 : 0]           i_operator,
            input wire signed [N_BITS - 1 : 0]              i_data_one,
            input wire signed [N_BITS - 1 : 0]              i_data_two
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
                    ADD_OP: o_alu = i_data_one + i_data_two;    //ADD
                    SUB_OP: o_alu = i_data_one - i_data_two;    //SUB 
                    AND_OP: o_alu = i_data_one & i_data_two;    //AND 
                    OR_OP:  o_alu = i_data_one | i_data_two;    //OR
                    XOR_OP: o_alu = i_data_one ^ i_data_two;    //XOR
                    SRA_OP: 
                    begin
                        if (i_data_two > i_data_one) begin
                            o_alu = {N_BITS{1'b0}};
                        end 
                        else begin 
                            o_alu = i_data_one >>> i_data_two;  //SRA
                        end 
                    end
                    SRL_OP: 
                    begin
                        if (i_data_two > i_data_one) begin
                            o_alu = {N_BITS{1'b0}};
                        end 
                        else begin 
                            o_alu = i_data_one >> i_data_two;   //SRL
                        end 
                    end 
                    NOR_OP: o_alu = ~(i_data_one | i_data_two); //NOR
                    default  : 
                    begin
                        o_alu = {N_BITS{1'b0}};
                    end
                endcase
        end
 endmodule
