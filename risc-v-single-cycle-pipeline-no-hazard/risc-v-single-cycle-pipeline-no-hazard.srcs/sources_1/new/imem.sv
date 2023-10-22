`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2023 11:33:34 AM
// Design Name: 
// Module Name: imem
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

module imem(
    input   wire [31:0] imem_a,
    output  wire [31:0] imem_out
    );
    logic [31:0] RAM[63:0];
    initial $readmemh("imem.mem",RAM);
    
    assign imem_out = RAM[imem_a[31:2]];
endmodule
