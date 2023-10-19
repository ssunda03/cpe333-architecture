`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2023 11:24:46 PM
// Design Name: 
// Module Name: regfile
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


module regfile(
    input wire          clk,
    input wire          regfile_we3,
    input wire [4:0]    regfile_a1,
    input wire [4:0]    regfile_a2,
    input wire [4:0]    regfile_a3,
    
    input wire [1:0]    regfile_a3_ctrl,
    input wire [31:0]   regfile_a3_alu_out,
    input wire [31:0]   regfile_a3_dmem_out,
    input wire [31:0]   regfile_a3_next_pc,
    
    output wire [31:0]  regfile_a1_out,
    output wire [31:0]  regfile_a2_out
    );
    reg [31:0]  X[31:0];
    wire [31:0] regfile_a3_data;
    
    assign regfile_a1_out = X[regfile_a1];
    assign regfile_a2_out = X[regfile_a2];
    assign regfile_a3_data = 
        regfile_a3_ctrl == 0 ? regfile_a3_next_pc  : 
        regfile_a3_ctrl == 1 ? 'hDEADBEEF          :
        regfile_a3_ctrl == 2 ? regfile_a3_dmem_out :
                               regfile_a3_alu_out  ;
    
    always_ff @(posedge clk) begin
        if (regfile_we3) X[regfile_a3] <= regfile_a3_data;
    end
    
endmodule
