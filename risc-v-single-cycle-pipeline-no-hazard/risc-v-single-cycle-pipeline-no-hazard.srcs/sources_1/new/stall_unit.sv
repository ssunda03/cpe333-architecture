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
    input logic [31:0] f_instr,
    input logic [1:0] dec_rf_wr_ctrl,
    input logic [4:0] dec_rf_wa,
    input logic [1:0] exec_rf_wr_ctrl,
    input logic [4:0] exec_rf_wa,
    input logic pc_we,
    
    output logic [31:0] out_instr,
    output logic out_pc_we
);

always_comb begin
    out_instr = f_instr;
    out_pc_we = pc_we;
    
    if (
        ((dec_rf_wa==f_instr[24:20] || dec_rf_wa==f_instr[19:15]) && (dec_rf_wr_ctrl == 2 || f_instr[6:0]==7'b1100011)) || // if lw, add OR add, br 
        ((exec_rf_wa==f_instr[24:20] || exec_rf_wa==f_instr[19:15]) && f_instr[6:0]==7'b1100011 && exec_rf_wr_ctrl == 2)
    ) begin
        out_instr = 32'h13;
        out_pc_we = 1'b0;
    end
end    
        
endmodule