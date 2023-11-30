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


module imm_gen( //immediate generator
    input wire [31:0]   instr, //current instruction
    input wire [2:0]    imm_ctrl, //mux selector

    output wire [31:0]  imm       //output immediate
    );
    wire [31:0]         imm_i, //immediates for each instruction type
                        imm_s,
                        imm_b,
                        imm_u,
                        imm_j;
    
    //generators
    assign imm_i = {{20{instr[31]}}, instr[31:20]};
    assign imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    assign imm_b = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
    assign imm_u = {instr[31], instr[30:12], 12'b0};
    assign imm_j = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
    
    //mux based on instruction type
    assign imm =    imm_ctrl == 0 ? imm_i :
                    imm_ctrl == 1 ? imm_s : 
                    imm_ctrl == 2 ? imm_b :
                    imm_ctrl == 3 ? imm_u :
                                    imm_j ;
endmodule