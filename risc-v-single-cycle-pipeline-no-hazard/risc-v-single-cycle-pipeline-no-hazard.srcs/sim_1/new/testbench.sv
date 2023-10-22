`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/21/2023 07:00:45 PM
// Design Name: 
// Module Name: testbench
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


module testbench(

    );
    
    reg clk, rst;
    
    mcu UUT(
        clk,
        rst
    );
    
    initial begin
        clk = 0;
        rst = 0;
        forever #5 clk = ~clk;
    end 
    
    initial begin
        #4 rst = 1;
        #5 rst = 0;
        
        #90 $finish();
    end   
    
endmodule
