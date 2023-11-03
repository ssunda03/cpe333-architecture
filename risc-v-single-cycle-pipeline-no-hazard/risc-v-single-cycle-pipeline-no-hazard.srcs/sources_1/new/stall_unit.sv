`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2023 10:32:29 AM
// Design Name: 
// Module Name: stall_unit
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

module stall_unit(
    input logic [31:0] instr,
    input wire [1:0] mem_read,
    input logic [4:0] exec_rfwa,
    input logic pc_we,
    //input logic [2:0] pc_ctrl,
    
    output logic [31:0] out_instr,
    output logic out_pc_we
    //output logic [2:0] out_pc_ctrl
);

assign out_instr = (mem_read == 2 & 
        (exec_rfwa==instr[24:20] || exec_rfwa==instr[19:15])) ? 
            32'h00000013 : instr;
assign out_pc_we = (mem_read == 2 & 
        (exec_rfwa==instr[24:20] || exec_rfwa==instr[19:15])) ? 
            0 : pc_we;     
        
endmodule
