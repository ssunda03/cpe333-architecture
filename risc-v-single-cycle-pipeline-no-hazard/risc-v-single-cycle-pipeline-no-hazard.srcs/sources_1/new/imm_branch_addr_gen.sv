`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2023 12:15:44 AM
// Design Name: 
// Module Name: imm_gen
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


module imm_gen(
    input wire [1:0]    imm_gen_ctrl,
    input wire [31:0]   imm_gen_instr,
    
    output wire [31:0]  imm_gen_alu
    );
    
    wire [31:0] imm_gen_i;
    wire [31:0] imm_gen_s;
    wire [31:0] imm_gen_b;
    wire [31:0] imm_gen_u;
    wire [31:0] imm_gen_j;
    
    
    assign imm_gen_i = {{20{imm_gen_instr[31]}}, imm_gen_instr[31:20]};
    assign imm_gen_s = {{20{imm_gen_instr[31]}}, imm_gen_instr[31:25], imm_gen_instr[11:7]};
    assign imm_gen_b = {{20{imm_gen_instr[31]}}, imm_gen_instr[7], imm_gen_instr[30:25], imm_gen_instr[11:8], 1'b0};
    assign imm_gen_u = {imm_gen_instr[31], imm_gen_instr[30:12], 12'b0};
    assign imm_gen_j = {{12{imm_gen_instr[31]}}, imm_gen_instr[19:12], imm_gen_instr[20], imm_gen_instr[30:21], 1'b0};
    
    assign imm_gen_alu = 
        imm_gen_ctrl == 0 ? imm_gen_i : 
        imm_gen_ctrl == 1 ? imm_gen_s : imm_gen_b;
endmodule
