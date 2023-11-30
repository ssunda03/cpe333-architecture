`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2023 11:55:21 PM
// Design Name: 
// Module Name: alu
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


module alu( //arithmetic logic unit
    input wire          alu_a_ctrl, //input selectors
    input wire          alu_b_ctrl,
    input wire [3:0]    alu_ctrl, //operation selector
    
    input wire [31:0]   rs1, //inputs
    input wire [31:0]   pc,
    
    input wire [31:0]   rs2,
    input wire [31:0]   imm,
    
    input wire [1:0]    forwardA, //control for rs1
    input wire [1:0]    forwardB, //control for rs2
    
    input logic [31:0]  mem_data,
    input logic [31:0]  mem_alu, //data forwarded from the memory module
    input logic [31:0]  forward_alu, //data forwarded from the alu
    input wire [1:0]    rf_ctrl,
    
    output wire         alu_zero, //if zero
    output logic [31:0] alu_res,
    output reg [31:0]   alub
    );
    parameter   alu_ADD     = 4'b0000, //operations
                alu_SLL     = 4'b0001,
                alu_SLT     = 4'b0010,
                alu_SLTU    = 4'b0011,
                alu_XOR     = 4'b0100,
                alu_SRL     = 4'b0101,
                alu_OR      = 4'b0110,
                alu_AND     = 4'b0111,
                alu_SUB     = 4'b1000,
                alu_LUI     = 4'b1001,
                alu_SRA     = 4'b1101;
                
    wire [31:0] intermed_a;
    wire [31:0] intermed_b;            
    wire [31:0] alu_a; //inputs
    wire [31:0] alu_b;
    wire [31:0] forward_mem;
    
    assign forward_mem = (rf_ctrl == 2) ? mem_data : (rf_ctrl == 3) ? mem_alu : 0;
    
    assign alu_zero = alu_res == 0;
    assign alu_a = ~alu_a_ctrl ? intermed_a : pc; //selector of inputs based on instruction
    assign alu_b = ~alu_b_ctrl ? intermed_b : imm;
    assign alub = intermed_b;
    assign intermed_a = (forwardA == 2'b00) ? rs1 :
                  (forwardA == 2'b01) ? forward_mem :
                  (forwardA == 2'b10) ? forward_alu :
                  rs1;
 
    assign intermed_b = (forwardB == 2'b00) ? rs2 :
                  (forwardB == 2'b01) ? forward_mem :
                  (forwardB == 2'b10) ? forward_alu :
                  rs2;
    
    always_comb begin
        case (alu_ctrl) //perform operations
            alu_ADD:    alu_res = alu_a + alu_b;
            alu_SLL:    alu_res = alu_a << alu_b;
            alu_SLT:    alu_res = $signed(alu_a) < $signed(alu_b) ? alu_a : alu_b;
            alu_SLTU:   alu_res = $unsigned(alu_a) < $unsigned(alu_b) ? alu_a : alu_b;
            alu_XOR:    alu_res = alu_a ^ alu_b;
            alu_SRL:    alu_res = alu_a >> alu_b;
            alu_OR:     alu_res = alu_a | alu_b;
            alu_AND:    alu_res = alu_a & alu_b;
            alu_SUB:    alu_res = alu_a - alu_b;
            alu_LUI:    alu_res = alu_b;
            alu_SRA:    alu_res = alu_a >>> alu_b;
            
            default: alu_res = 'hDEADBEEF;
        endcase
    end
endmodule
