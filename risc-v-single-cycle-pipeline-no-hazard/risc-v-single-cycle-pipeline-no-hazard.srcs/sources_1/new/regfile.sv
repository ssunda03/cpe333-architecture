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


module regfile( //register file
    input wire          clk,
    input wire          rf_we,//write enable
    input wire [4:0]    rf_a1, //read address 1
    input wire [4:0]    rf_a2, //read address 2
    input wire [4:0]    rf_wa, //write address
    
    input wire [1:0]    rf_wr_ctrl, //write selector
    input wire [31:0]   alu_res, //ALU result
    input wire [31:0]   mem_data, //input from memory
    input wire [31:0]   pc_4, //pc + 4
    
    output wire [31:0]  rs1, //read output 1
    output wire [31:0]  rs2 //read output 2
    );
    reg [31:0]  X[31:0]; //registers
    wire [31:0] rf_wd; //write input
    
    initial begin //initialize registers
        for (int i = 0; i < 32; i++) begin
            X[i] = 0;
        end
    end
    
    assign rs1 = X[rf_a1]; //read outputs
    assign rs2 = X[rf_a2];
    assign rf_wd = //write MUX, select from ALU, memory, or pc
        rf_wr_ctrl == 0 ? pc_4       : 
        rf_wr_ctrl == 1 ? 'hDEADBEEF :
        rf_wr_ctrl == 2 ? mem_data   :
                          alu_res    ;
    
    always_ff @(posedge clk) begin //write into registers
        if (rf_we && rf_wa != 0) X[rf_wa] <= rf_wd; //if we and not writing to 0
    end
    
endmodule
