`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2023 10:31:24 PM
// Design Name: 
// Module Name: dmem
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
    // imem_a = pc_out[19:15]
    input   wire [31:0] imem_a,
    output  wire [31:0] imem_out
    );
    logic [31:0] RAM[63:0];
    initial $readmemh("imem.mem",RAM);
    
    assign imem_out = RAM[imem_a[31:2]];
endmodule
