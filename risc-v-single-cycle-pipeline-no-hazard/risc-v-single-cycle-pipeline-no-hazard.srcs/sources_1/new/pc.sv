`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2023 10:04:12 PM
// Design Name: 
// Module Name: pc
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


module pc(
    input wire          clk,
    input wire          rst, 
    input wire          pc_we,
    
    input wire [1:0]    pc_ctrl,
    input wire [31:0]   pc_jalr,
    input wire [31:0]   pc_branch,
    input wire [31:0]   pc_jal,
    
    output reg [31:0]   pc,
    output wire [31:0]  pc_plus_4
    );
    
    reg  [31:0] pc_next;
    assign pc_plus_4 = pc + 4;
    
    always_ff @(posedge clk) begin
        if (rst) pc <= 0;
        else if (pc_we) pc <= pc_next;
    end
    
    always_comb begin
        case (pc_ctrl)
            0: pc_next = pc_plus_4;
            1: pc_next = pc_jalr;
            2: pc_next = pc_branch;
            3: pc_next = pc_jal;
            default: pc_next = 'hDEADBEEF;
        endcase
    end
    
endmodule
