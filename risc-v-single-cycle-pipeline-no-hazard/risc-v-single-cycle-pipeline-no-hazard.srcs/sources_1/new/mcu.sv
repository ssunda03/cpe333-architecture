`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2023 10:55:58 AM
// Design Name: 
// Module Name: mcu
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
typedef struct packed {
    // data
    logic [31:0]    pc_jalr,
                    pc_branch,
                    pc_jal;
    logic [31:0]    instr,
                    pc,
                    pc_4;
    logic [31:0]    rs1,
                    rs2,
                    imm;
    logic [4:0]     rf_wa;
    logic [31:0]    alu_res,
                    mem_data;
    // ctrl
    logic [1:0]     pc_ctrl;
    logic [2:0]     imm_ctrl;           
    logic           rf_we;
    logic [1:0]     rf_wr_ctrl;
    logic           alu_a_ctrl,
                    alu_b_ctrl;
    logic [3:0]     alu_ctrl;
    logic           mem_we;
} preg_t;

module mcu(
    input clk, rst
    );

    preg_t          FETCH, DECODE, EXEC, MEM, WRITE;
    wire            br_eq, br_lt, br_ltu;
    wire [1:0]      pc_ctrl;
    wire            alu_zero;
    
    pc PC(
        clk,
        rst,
        
        pc_ctrl,
        DECODE.pc_jalr,
        DECODE.pc_branch,
        DECODE.pc_jal,
        
        FETCH.pc,
        FETCH.pc_4
    );
    
    imem IMEM(
        FETCH.pc,
        FETCH.instr
    );
    
    always_ff @(posedge clk) begin
        DECODE <= FETCH;
    end
    
    branch_cond_gen BRANCH_COND_GEN(
        DECODE.rs1,
        DECODE.rs2,

        br_eq,
        br_lt,
        br_ltu
    );

    ctrl_unit CTRL_UNIT(
        br_eq,
        br_lt,
        br_ltu,
        DECODE.instr[6:0],
        DECODE.instr[30],
        DECODE.instr[14:12],
        
        DECODE.alu_ctrl,
        pc_ctrl,
        DECODE.alu_a_ctrl,
        DECODE.alu_b_ctrl, 
        DECODE.rf_wr_ctrl,
        DECODE.imm_ctrl,
        DECODE.mem_we
    );
    
    regfile REGFILE(
        clk,
        DECODE.rf_we,
        DECODE.instr[19:15],
        DECODE.instr[24:20],
        WRITE.rf_wa,
    
        WRITE.rf_wr_ctrl,
        WRITE.alu_res,
        WRITE.mem_data,
        WRITE.pc_4,
    
        DECODE.rs1,
        DECODE.rs2
    );
    
    imm_gen IMM_GEN(
        DECODE.instr,
        DECODE.imm_ctrl,

        DECODE.imm
    );
    
    branch_addr_gen BRANCH_GEN(
        DECODE.pc,
        DECODE.rs1,
        DECODE.imm,

        DECODE.pc_jalr,
        DECODE.pc_branch,
        DECODE.pc_jal
    );
    assign DECODE.rf_wa = DECODE.instr[11:7];
    
    always_ff @(posedge clk) begin
        EXEC <= DECODE;
    end
    
    alu ALU(
        EXEC.alu_a_ctrl,
        EXEC.alu_b_ctrl,
        EXEC.alu_ctrl,
        EXEC.rs1,
        EXEC.pc,
        EXEC.rs2,
        EXEC.imm,

        alu_zero,
        EXEC.alu_res
    );
    
    always_ff @(posedge clk) begin
        MEM <= EXEC;
    end


    dmem DMEM(
        clk,
        MEM.mem_we,
        MEM.alu_res,
        MEM.rs2,

        MEM.mem_data
    );

    always_ff @(posedge clk) begin
        WRITE <= MEM;
    end
    
    
endmodule
