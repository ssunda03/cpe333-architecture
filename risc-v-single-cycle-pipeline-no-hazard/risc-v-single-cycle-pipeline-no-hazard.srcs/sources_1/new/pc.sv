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


module pc( //program counter
    input wire          clk,
    input wire          rst,
    input wire          pc_we,
    
    input wire [2:0]    pc_ctrl, //next instruction mux selector
    input wire [31:0]   pc_jalr, //potential next addresses
    input wire [31:0]   pc_branch,
    input wire [31:0]   pc_jal,
    input wire [31:0]   pc_prev,
    
    output reg [31:0]   pc, //current address
    output wire [31:0]  pc_4 //address + 4
    );
    
    reg  [31:0] pc_next; //next 
    assign pc_4 = pc + 4; //add 4
    
    always_ff @(posedge clk) begin //update address
        if (rst) pc <= 0;
        else if (pc_we) pc <= pc_next;
    end
    
    always_comb begin
        case (pc_ctrl) //mux selector for next address
            0: pc_next = pc_4;
            1: pc_next = pc_jalr;
            2: pc_next = pc_branch;
            3: pc_next = pc_jal;
            4: pc_next = pc_prev;
        endcase
    end
    
endmodule
