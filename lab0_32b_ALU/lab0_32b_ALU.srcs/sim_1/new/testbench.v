`timescale 1ns / 1ps
module testbench;
    reg clk = 0;
    reg [31:0] A, B;
    wire [31:0] result;
    reg [2:0] ALU_op;
    wire zero;

    ALU ALU_module(
        .A(A),
        .B(B),
        .op(ALU_op),
        .result(result),
        .zero(zero)
    );
    
    // Generate 10MHz clock signal
    initial begin
        forever #5 clk <= ~clk;
    end

    
    initial begin
       A = 0;
       B = 0;
       ALU_op = 3'b000;
       #10 //test and
       A = 32'b11111111111111111111111111111111;
       B = 32'b11111111111111111111111111111111;
       #20 //test add
       A = 22222;
       B = 44444;
       ALU_op = 3'b010;
       #20 //test or
       A = 32'b11111111111111110000000000000000;
       B = 32'b11111111000000001111111100000000;
       ALU_op = 3'b001;
       #20 //test subtract
       A = 44444;
       B = 22222;
       ALU_op = 3'b110;
       #20 //test negative subtraction
       A = 22222;
       B = 44444; 
       #20 //set on less than
       A = 1;
       B = 2;
       ALU_op = 3'b111;
       #20
       A = 2;
       B = 1;
       #20
       A = -100;
       B = -1;
    end
endmodule
