`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2023 11:26:51 AM
// Design Name: 
// Module Name: branch_addr_gen
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


module branch_addr_gen( //branch address generator
    input wire [31:0]   pc, //pc
    input wire [31:0]   rs1, //read out from regfile
    input wire [31:0]   imm, //immediate
    
    output wire [31:0]  pc_jalr, //jump
    output wire [31:0]  pc_branch, //branch
    output wire [31:0]  pc_jal //jump
    );
    
    //set next pc instruction based on generated immediate
    assign pc_jalr      = (rs1 + imm) & ~1;
    assign pc_branch    = pc + imm;
    assign pc_jal       = pc + imm;
    
endmodule
