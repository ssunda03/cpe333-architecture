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
        input logic [31:0]  dec_instr, //current instruction being executed
        input logic [31:0]  exec_instr, //current instruction being executed
        input logic [31:0]  mem_instr, //current instruction being executed
        input logic [4:0]   mem_rd, //address prev instruction will write to
        input logic [4:0]   write_rd, //address prev instruction will write to
        input logic [1:0]   mem_rf_wr_ctrl,

        output wire [1:0]   exec_fw_A,
        output wire [1:0]   exec_fw_B,
        output wire         dec_fw_A,
        output wire         dec_fw_B
    );
    
    wire [4:0] exec_a1 = exec_instr[19:15];
    wire [4:0] exec_a2 = exec_instr[24:20];
    wire [4:0] dec_a1 = dec_instr[19:15];
    wire [4:0] dec_a2 = dec_instr[24:20];
    
    //check if nop, if reading from 0, if need forward from ALU, if need forward from MEM
    assign exec_fw_A =  (exec_instr == 32'h00000013) ? 2'b00 : 
                   (exec_a1 == 0)          ? 2'b00 :
                   (mem_rd == exec_a1)     ? 2'b10 : 
                   (write_rd == exec_a1)   ? 2'b01 :
                                             2'b00 ;
    
    assign exec_fw_B =  (exec_instr == 32'h00000013) ? 2'b00 : 
                   (exec_a2 == 0)          ? 2'b00 :
                   (mem_rd == exec_a2)     ? 2'b10 : 
                   (write_rd == exec_a2)   ? 2'b01 :
                                             2'b00 ;
                                             
     assign dec_fw_A =  (dec_instr[6:0] != 7'b1100011 && dec_instr[6:0] != 7'b1100111)  ? 1'b0 :
                        (dec_a1 == 0)                   ? 1'b0 :
                        (mem_rd == dec_a1 && 
                         mem_instr != 32'h00000013 && 
                         mem_rf_wr_ctrl == 3)           ? 1'b1 :
                                                          1'b0 ;
                                                                                     
     assign dec_fw_B =  (dec_instr[6:0] != 7'b1100011 && dec_instr[6:0] != 7'b1100111)  ? 1'b0 :
                        (dec_a2 == 0)                   ? 1'b0 :
                        (mem_rd == dec_a2 && 
                         mem_instr != 32'h00000013 && 
                         mem_rf_wr_ctrl == 3)           ? 1'b1 :
                                                          1'b0 ;
endmodule
