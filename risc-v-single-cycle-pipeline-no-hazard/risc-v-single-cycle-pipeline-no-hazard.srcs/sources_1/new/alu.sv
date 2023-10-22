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
    input wire          alu_a_ctrl,
    input wire          alu_b_ctrl,
    input wire [3:0]    alu_ctrl,
    
    input wire [31:0]   rs1,
    input wire [31:0]   pc,
    
    input wire [31:0]   rs2,
    input wire [31:0]   imm,
    
    output wire         alu_zero,
    output reg [31:0]   alu_res
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
    
    assign alu_zero = alu_res == 0;
    assign alu_a = ~alu_a_ctrl ? rs1 : pc;
    assign alu_b = ~alu_b_ctrl ? rs2 : imm;
    
    always_comb begin
        case (alu_ctrl)
            alu_ADD:    alu_res = alu_a + alu_b;
            alu_SLL:    alu_res = alu_a << alu_b;
            alu_SLT:    alu_res = $signed(alu_a) < $signed(alu_b) ? alu_a : alu_b;
            alu_SLTU:   alu_res = $unsigned(alu_a) < $unsigned(alu_b) ? alu_a : alu_b;
            alu_XOR:    alu_res = alu_a ^ alu_b;
            alu_SRL:    alu_res = alu_a >> alu_b;
            alu_OR:     alu_res = alu_a | alu_b;
            alu_AND:    alu_res = alu_a & alu_b;
            alu_SUB:    alu_res = alu_a - alu_b;
            alu_LUI:    alu_res = alu_b;
            alu_SRA:    alu_res = alu_a >>> alu_b;
            
            default: alu_res = 'hDEADBEEF;
        endcase
    end
endmodule
