`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2023 11:55:21 PM
// Design Name: 
// Module Name: alu
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


module alu(
    input wire          alu_src_a,
    input wire [1:0]    alu_src_b,
    input wire [3:0]    alu_op,
    
    input wire [31:0]   alu_a_reg,
    input wire [31:0]   alu_a_imm_u,
    
    input wire [31:0]   alu_b_reg,
    input wire [31:0]   alu_b_imm_i,
    input wire [31:0]   alu_b_imm_s,
    input wire [31:0]   alu_b_pc,
    
    output wire         alu_zero,
    output reg [31:0]   alu_out
    );
    parameter   alu_ADD     = 4'b0000,
                alu_SLL     = 4'b0001,
                alu_SLT     = 4'b0010,
                alu_SLTU    = 4'b0011,
                alu_XOR     = 4'b0100,
                alu_SRL     = 4'b0101,
                alu_OR      = 4'b0110,
                alu_AND     = 4'b0111,
                alu_SUB     = 4'b1000,
                alu_LUI     = 4'b1001,
                alu_SRA     = 4'b1101;
                
                
    wire [31:0] alu_a;
    wire [31:0] alu_b;
    
    assign alu_zero = alu_out == 0;
    assign alu_a = ~alu_src_a ? alu_a_reg : alu_a_imm_u;
    assign alu_b = alu_src_b == 0 ? alu_b_reg :
                   alu_src_b == 1 ? alu_b_imm_i :
                   alu_src_b == 2 ? alu_b_imm_s : 
                                    alu_b_pc    ;
    
    always_comb begin
        case (alu_op)
            alu_ADD:    alu_out = alu_a + alu_b;
            alu_SLL:    alu_out = alu_a << alu_b;
            alu_SLT:    alu_out = $signed(alu_a) < $signed(alu_b) ? alu_a : alu_b;
            alu_SLTU:   alu_out = $unsigned(alu_a) < $unsigned(alu_b) ? alu_a : alu_b;
            alu_XOR:    alu_out = alu_a ^ alu_b;
            alu_SRL:    alu_out = alu_a >> alu_b;
            alu_OR:     alu_out = alu_a | alu_b;
            alu_AND:    alu_out = alu_a & alu_b;
            alu_SUB:    alu_out = alu_a - alu_b;
            alu_LUI:    alu_out = alu_a;
            alu_SRA:    alu_out = alu_a >>> alu_b;
            
            default: alu_out = 'hDEADBEEF;
        endcase
    end
endmodule
