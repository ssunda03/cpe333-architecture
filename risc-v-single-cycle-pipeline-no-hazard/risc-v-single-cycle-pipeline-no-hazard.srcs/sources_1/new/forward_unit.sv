`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Alex Short
// 
// Create Date: 10/31/2023 09:25:30 PM
// Design Name: 
// Module Name: forward_unit
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


module forward_unit(
        input logic [4:0] exec_a1,  //rs1 address from execute register
        input logic [4:0] exec_a2,  //rs2 address from execute register
        input logic [4:0] mem_rd, //address prev instruction will write to
        input logic [4:0] write_rd, //address prev instruction will write to
        input logic [31:0] instr, //current instruction being executed
        
        output wire [1:0] fw_A,
        output wire [1:0] fw_B
    );
    
    //check if nop, if reading from 0, if need forward from ALU, if need forward from MEM
    assign fw_A =  (instr == 32'h00000013) ? 2'b00 : 
                   (exec_a1 == 0)          ? 2'b00 :
                   (mem_rd == exec_a1)     ? 2'b10 : 
                   (write_rd == exec_a1)   ? 2'b01 :
                                             2'b00 ;
    
    assign fw_B =  (instr == 32'h00000013) ? 2'b00 : 
                   (exec_a2 == 0)          ? 2'b00 :
                   (mem_rd == exec_a2)     ? 2'b10 : 
                   (write_rd == exec_a2)   ? 2'b01 :
                                             2'b00 ;
endmodule
