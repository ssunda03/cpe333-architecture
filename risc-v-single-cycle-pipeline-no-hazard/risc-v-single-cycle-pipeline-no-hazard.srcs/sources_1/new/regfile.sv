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
    input wire          rf_we,
    input wire [4:0]    rf_a1,
    input wire [4:0]    rf_a2,
    input wire [4:0]    rf_wa,
    
    input wire [1:0]    rf_wr_ctrl,
    input wire [31:0]   alu_res,
    input wire [31:0]   mem_data,
    input wire [31:0]   pc_4,
    
    output wire [31:0]  rs1,
    output wire [31:0]  rs2
    );
    reg [31:0]  X[31:0];
    wire [31:0] rf_wd;
    
    initial begin
        for (int i = 0; i < 32; i++) begin
            X[i] = 0;
        end
    end
    
    assign rs1 = X[rf_a1];
    assign rs2 = X[rf_a2];
    assign rf_wd = 
        rf_wr_ctrl == 0 ? pc_4       : 
        rf_wr_ctrl == 1 ? 'hDEADBEEF :
        rf_wr_ctrl == 2 ? mem_data   :
                          alu_res    ;
    
    always_ff @(posedge clk) begin
        if (rf_we && rf_wa != 0) X[rf_wa] <= rf_wd;
    end
    
endmodule
