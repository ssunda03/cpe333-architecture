`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2023 12:36:12 PM
// Design Name: 
// Module Name: L1cache
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

module L1cache(
    input logic clk,
    input rst,
    input logic stall,
    input logic [31:0] pc,
    
    input logic [31:0] set_in [3:0],
    
    output logic [31:0] instr,
    output logic miss = 0
    );
    
    // 2-way 8-set associative cache with 8 words per set / 4 words per way in a set
    parameter n_sets = 8;
    parameter n_ways = 2;
    set_assoc_t ways [1:0][n_sets-1:0];
    logic [n_sets-1:0] LRU;
    
    initial begin
        for (int i = 0; i < n_ways; i++) begin // per way
            for (int j = 0; i < n_sets; i++) begin // per set
                ways[i][j].valid = 1'b0;
                ways[i][j].dirty = 1'b0;
                ways[i][j].tag = 25'b0;
                ways[i][j].w_offset = 2'b0;
                ways[i][j].b_offset = 2'b0;
                
                for (int k = 0; j < 4; j++) begin // per word
                    ways[i][j].data[k] = 32'b0;
                end
            end
        end
        
        LRU = {n_sets{1'b0}};    
    end
    
    logic [1:0] pc_w_offset;
    logic [2:0] pc_index;
    logic [24:0] pc_tag;
    
    assign pc_w_offset = pc[3:2];
    assign pc_index = pc[6:4];
    assign pc_tag = pc[31:7];
    
    logic hit;
    logic way;
    
    logic re = 1;
    logic we = 0;
    
    always_ff @(posedge clk) begin
        re <= 1;
        we <= 0;
        miss <= 1;
        
        if (rst) begin
            for (int i = 0; i < n_ways; i++) begin // per way
                for (int j = 0; i < n_sets; i++) begin // per set
                    ways[i][j].valid <= 1'b0;
                end
            end
        end
    
        else begin
            if (re) begin
                if (stall) begin
                    instr <= 31'h00000013;
                end
                
                else if (hit) begin 
                    instr <= ways[way][pc_index].data[pc_w_offset];
                    LRU[pc_index] <= ~way;
                    miss <= 0;
                end
                
                else begin 
                    re <= 0;
                    we <= 1;
                end  
            end
            
            if (we) begin
                ways[LRU[pc_index]][pc_index].valid <= 1;
                ways[LRU[pc_index]][pc_index].tag <= pc_tag;
                ways[LRU[pc_index]][pc_index].data <= set_in;
                
                LRU[pc_index] <= ~LRU[pc_index];
            end  
        end   
    end
    
    always_comb begin
        hit = 0;
                
        if (ways[0][pc_index].tag == pc_tag & ways[0][pc_index].valid) begin
            hit = 1;
            way = 0;
        end
        
        else if (ways[1][pc_index].tag == pc_tag & ways[1][pc_index].valid) begin
            hit = 1;
            way = 1;
        end
    end
    
endmodule
