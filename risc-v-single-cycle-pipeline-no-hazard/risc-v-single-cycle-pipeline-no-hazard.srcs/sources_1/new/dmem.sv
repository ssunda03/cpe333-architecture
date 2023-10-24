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


module dmem( //data memory
    input   wire        clk,
    input   wire        we, //write enable
    input   wire [31:0] dmem_addr, //write address/read address
    input   wire [31:0] dmem_data, //input data to memory
    output  wire [31:0] dmem_out //output data from memory
    );
    reg [31:0] RAM [63:0]; //memory
    
    assign dmem_out = RAM[dmem_addr[31:2]]; //output data
    
    always_ff @(posedge clk) begin
        if (we) RAM[dmem_addr[31:2]] <= dmem_data; //write data
    end
endmodule
