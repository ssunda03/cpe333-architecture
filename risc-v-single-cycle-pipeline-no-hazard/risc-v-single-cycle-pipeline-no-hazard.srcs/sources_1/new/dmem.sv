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


module dmem(
    input   wire        clk,
    input   wire        we,
    input   wire [31:0] dmem_addr,
    input   wire [31:0] dmem_data,
    output  wire [31:0] dmem_out
    );
    reg [31:0] RAM [63:0];
    
    assign dmem_out = RAM[dmem_addr[31:2]];
    
    always_ff @(posedge clk) begin
        if (we) RAM[dmem_addr[31:2]] <= dmem_data;
    end
endmodule
