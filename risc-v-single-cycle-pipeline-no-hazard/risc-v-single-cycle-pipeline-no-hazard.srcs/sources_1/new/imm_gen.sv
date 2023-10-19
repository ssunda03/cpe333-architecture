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
    input wire [31:0]   imm_gen_instr,
    
    output wire [31:0] imm_gen_i,
    output wire [31:0] imm_gen_s,
    output wire [31:0] imm_gen_b,
    output wire [31:0] imm_gen_u,
    output wire [31:0] imm_gen_j
    );
    
    
    assign imm_gen_i = {{20{imm_gen_instr[31]}}, imm_gen_instr[31:20]};
    assign imm_gen_s = {{20{imm_gen_instr[31]}}, imm_gen_instr[31:25], imm_gen_instr[11:7]};
    assign imm_gen_b = {{20{imm_gen_instr[31]}}, imm_gen_instr[7], imm_gen_instr[30:25], imm_gen_instr[11:8], 1'b0};
    assign imm_gen_u = {imm_gen_instr[31], imm_gen_instr[30:12], 12'b0};
    assign imm_gen_j = {{12{imm_gen_instr[31]}}, imm_gen_instr[19:12], imm_gen_instr[20], imm_gen_instr[30:21], 1'b0};
    
endmodule

module branch_addr_gen(
    input wire [31:0]   branch_addr_pc,
    input wire [31:0]   branch_addr_reg,
    input wire [31:0]   branch_addr_imm_i,
    input wire [31:0]   branch_addr_imm_b,
    input wire [31:0]   branch_addr_imm_j,
    
    output wire [31:0]  branch_addr_jalr,
    output wire [31:0]  branch_addr_branch,
    output wire [31:0]  branch_addr_jal,
    );
    
    assign branch_addr_jalr     = (branch_addr_reg + branch_addr_imm_i) & ~1;
    assign branch_addr_branch   = branch_addr_pc + branch_addr_imm_b;
    assign branch_addr_jal      = branch_addr_pc + branch_addr_imm_j;
    
endmodule