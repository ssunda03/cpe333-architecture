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
    logic [31:0]    instr, //current instruction
                    pc, // current pc
                    pc_4; // pc + 4
    logic [31:0]    rs1, //read out from regfile
                    rs2, //read out from regfile 2
                    imm; // generated immediate
    logic [4:0]     rf_wa; //write address for regfile
    logic [31:0]    alu_res, //result of ALU
                    mem_data; //data read from memory
    // ctrl
    logic [1:0]     pc_ctrl; //mux control for PC
    logic [2:0]     imm_ctrl; //mux control for Immediate Gen
    logic           rf_we; //write enable for regfile
    logic [1:0]     rf_wr_ctrl; //mux control for regfile
    logic           alu_a_ctrl, //mux control for a input to ALU
                    alu_b_ctrl; //mux control for b input to ALU
    logic [3:0]     alu_ctrl; //mux control for ALU operation
    logic           mem_we; //write enable to memory
} preg_t; //pipelined register

module mcu(
    input clk, rst
    );

    preg_t          FETCH, DECODE, EXEC, MEM, WRITE; //pipelined registers for each stage
    wire            br_eq, br_lt, br_ltu; //branch condition outputs
    wire [1:0]      pc_ctrl; //pc controller
    wire            alu_zero; //whether ALU returns 0
    
    pc PC( // program counter
        clk, 
        rst,
        
        pc_ctrl,
        DECODE.pc_jalr,
        DECODE.pc_branch,
        DECODE.pc_jal,
        //outputs
        FETCH.pc,
        FETCH.pc_4
    );
    
    imem IMEM( //instruction memory
        FETCH.pc,
        //outputs
        FETCH.instr
    );
    
    always_ff @(posedge clk) begin
        DECODE.instr <= FETCH.instr; //propogate stages
        DECODE.pc <= FETCH.pc;
        DECODE.pc_4 <= FETCH.pc_4;
    end
    
    branch_cond_gen BRANCH_COND_GEN( //branch condition generator
        DECODE.rs1, //read 1 from regfile
        DECODE.rs2, //read 2 from regfile
        //outputs
        br_eq, //branch condition checks
        br_lt,
        br_ltu
    );

    ctrl_unit CTRL_UNIT( //control unit for pipeline registers
        br_eq, //branch conditions
        br_lt,
        br_ltu,
        DECODE.instr[6:0], //inputting opcodes separately
        DECODE.instr[30],
        DECODE.instr[14:12],
        //outputs        
        DECODE.alu_ctrl, //ALU operation mux
        pc_ctrl, //PC mux
        DECODE.alu_a_ctrl, //ALU input muxes
        DECODE.alu_b_ctrl, 
        DECODE.rf_wr_ctrl, //regfile write mux
        DECODE.imm_ctrl, //immediate generator mux
        DECODE.mem_we, //memory write enable
        DECODE.rf_we //regfile write enable
    );
    
    regfile REGFILE(
        clk,
        WRITE.rf_we, //regfile write enable (during write stage)
        DECODE.instr[19:15], //instruction pieces
        DECODE.instr[24:20],
        WRITE.rf_wa, //regfile write address (during write stage)
        
        WRITE.rf_wr_ctrl, //regfile input mux control 
        WRITE.alu_res, //ALU result
        WRITE.mem_data, //data read from memory
        WRITE.pc_4, //pc + 4
        //outputs
        DECODE.rs1, //read registers (during DECODE stage)
        DECODE.rs2 
    );
    
    imm_gen IMM_GEN( //immediate generator
        DECODE.instr, //instruction
        DECODE.imm_ctrl, //immediate selector
        //outputs
        DECODE.imm //immediate (selected by a MUX based on immctrl based on instr)
    );
    
    branch_addr_gen BRANCH_GEN( //branch address generator
        DECODE.pc, //pc
        DECODE.rs1, //read 1 from regfile
        DECODE.imm, //generated immediate
        //outputs
        DECODE.pc_jalr, //pc mux inputs
        DECODE.pc_branch,
        DECODE.pc_jal
    );
    assign DECODE.rf_wa = DECODE.instr[11:7]; //set write address during DECODE stage
    
    always_ff @(posedge clk) begin
        EXEC <= DECODE; //propogate information to next pipeline register
    end
    
    alu ALU( //arithmetic logic unit
        EXEC.alu_a_ctrl, //input selectors
        EXEC.alu_b_ctrl, 
        EXEC.alu_ctrl, //operation selector
        EXEC.rs1, //inputs
        EXEC.pc,
        EXEC.rs2,
        EXEC.imm,
        //outputs
        alu_zero, //if zero
        EXEC.alu_res //result
    );
    
    always_ff @(posedge clk) begin
        MEM <= EXEC; //next pipeline register
    end


    dmem DMEM( //data memory
        clk,
        MEM.mem_we, //write enable for memory
        MEM.alu_res, //result of ALU
        MEM.rs2, //read from regfile
        //outputs
        MEM.mem_data //data read from memory
    );

    always_ff @(posedge clk) begin
        WRITE <= MEM; //next pipeline register
    end
    
    
endmodule
