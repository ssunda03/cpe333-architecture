`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2023 04:35:46 PM
// Design Name: 
// Module Name: branch_cond_gen
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


module branch_cond_gen(
    input wire [31:0]   rs1,
    input wire [31:0]   rs2,
    
    output wire br_eq, 
	output wire br_lt, 
	output wire br_ltu
    );
    
    assign br_eq = &(~(rs1 ^ rs2));
    assign br_lt = $signed(rs1) < $signed(rs2);
    assign br_ltu = $unsigned(rs1) < $unsigned(rs2);
endmodule
