`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/23/2023 03:12:04 PM
// Design Name: 
// Module Name: ALU
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


module ALU(
    input [31:0] A,
    input [31:0] B,
    input [2:0] op,
    output reg [31:0] result,
    output zero
    );
    
    assign zero = result == 0;
    
    parameter   op_and      = 'b000,
                op_or       = 'b001,
                op_add      = 'b010,
                op_sub      = 'b110,
                op_setlt    = 'b111;
                
    always @(*) begin
        case (op)
            op_and:     result = A & B;
            op_or:      result = A | B;
            op_add:     result = A + B;
            op_sub:     result = A - B;
            op_setlt:   result = $signed(A) < $signed(B);
            
            default:    result = 'hDEADBEEF;
        endcase
    end
endmodule
