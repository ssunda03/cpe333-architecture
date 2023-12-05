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

module imem( //instruction memory
    input   wire [31:0] imem_a, //address to read from (set by PC)    
    output  wire [31:0] imem_out [3:0] //instruct that has been read
    );
    logic [31:0] RAM[65535:0]; //memory
    initial begin 
    for(int i = 0; i < 65535; i++) begin
        RAM[i] = 32'h00000013;
    end
    $readmemh("imem.mem",RAM); //input program
    end
    //assign imem_out = (imem_stall) ? 31'h00000013 : RAM[imem_a[31:2]]; //send out
    logic [31:0] block [3:0];
    
    /*always_comb begin
        for (int i = 0; i < 4; i++) begin
            block[i] = RAM[{imem_a[31:4], i[1:0]}];
        end
    end*/
    
    assign block[0] = RAM[{imem_a[31:4], 2'b00}];
    assign block[1] = RAM[{imem_a[31:4], 2'b01}];
    assign block[2] = RAM[{imem_a[31:4], 2'b10}];
    assign block[3] = RAM[{imem_a[31:4], 2'b11}];
    
    assign imem_out = block; //send out
endmodule
