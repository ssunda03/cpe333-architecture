`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2023 03:42:28 PM
// Design Name: 
// Module Name: ctrl_unit
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


module ctrl_unit(
    input br_eq, 
	input br_lt, 
	input br_ltu,
    input [6:0] opcode,   //-  ir[6:0]
	input func7,          //-  ir[30]
    input [2:0] func3,    //-  ir[14:12]
    output logic [3:0] alu_fun,
    output logic [1:0] pcSource,
    output logic [1:0] alu_srcA,
    output logic [2:0] alu_srcB, 
	output logic [1:0] rf_wr_sel,
	output logic [2:0] imm_ctrl,
	output logic	   mem_we,
	output logic	   rf_we
	);
    
    //- datatypes for RISC-V opcode types
    typedef enum logic [6:0] {
        LUI    = 7'b0110111,
        AUIPC  = 7'b0010111,
        JAL    = 7'b1101111,
        JALR   = 7'b1100111,
        BRANCH = 7'b1100011,
        LOAD   = 7'b0000011,
        STORE  = 7'b0100011,
        OP_IMM = 7'b0010011,
        OP_RG3 = 7'b0110011,
        SYS    = 7'b1110011
    } opcode_t;
    opcode_t OPCODE; //- define variable of new opcode type
    
    assign OPCODE = opcode_t'(opcode); //- Cast input enum 

    //- datatype for func3Symbols tied to values
    typedef enum logic [2:0] {
        //BRANCH labels
        BEQ = 3'b000,
        BNE = 3'b001,
        BLT = 3'b100,
        BGE = 3'b101,
        BLTU = 3'b110,
        BGEU = 3'b111
    } func3_t;    
    func3_t FUNC3; //- define variable of new opcode type
    
    assign FUNC3 = func3_t'(func3); //- Cast input enum 
       
    always_comb
    begin 
        //- schedule all values to avoid latch
		pcSource = 2'b00;  alu_srcB = 1'b0;    rf_wr_sel = 2'b00; 
		alu_srcA = 1'b0;   alu_fun  = 4'b0000; imm_ctrl = 3'b000; mem_we = 1'b0; rf_we = 1'b0;
		
		case(OPCODE)
			AUIPC:
			begin
			     alu_fun = 4'b0000;
			     alu_srcA = 1;
			     alu_srcB = 1;
			     rf_wr_sel = 3;
				 imm_ctrl = 3;
				 rf_we = 1'b1;
				 
			end
			
			LUI:
			begin
				alu_fun = 4'b1001; 
				alu_srcB = 1;
				rf_wr_sel = 3; 
				imm_ctrl = 3;
				rf_we = 1'b1;
			end
			
			JAL:
			begin
			    pcSource = 3;
				rf_wr_sel = 0;
				imm_ctrl = 4;
				rf_we = 1'b1;
			end
			
			JALR:
			begin
			     pcSource = 1;
			     rf_wr_sel = 0;
				 imm_ctrl = 0;
				 rf_we = 1'b1;
			end
			
			LOAD: 
			begin
				alu_fun = 4'b0000; 
				alu_srcA = 0;
				alu_srcB = 1; 
				rf_wr_sel = 2;
				imm_ctrl = 0; 
				rf_we = 1'b1;
			end
			
			OP_IMM:
			begin
			    alu_srcA = 0;
                alu_srcB = 1;
                rf_wr_sel = 3;
                imm_ctrl = 0;
				rf_we = 1'b1;
                
				case(FUNC3)
					3'b000: alu_fun = 4'b0000; 						// instr: ADDI
					3'b010: alu_fun = 4'b0010; 						// instr: SLTI
					3'b011: alu_fun = 4'b0011; 						// instr: SLTIU
					3'b110: alu_fun = 4'b0110; 						// instr: ORI
					3'b100: alu_fun = 4'b0100; 						// instr: XORI
					3'b111: alu_fun = 4'b0111; 						// instr: ANDI
					3'b001: alu_fun = 4'b0001; 						// instr: SLLI
					3'b101: alu_fun = ~func7 ? 4'b0101 : 4'b1101; 	// SRLI : SRAI
					
				endcase
	        end
		
			BRANCH:
			begin
				 imm_ctrl = 2;

			     case(func3)
			         3'b000: pcSource = br_eq  ? 2 : 0; 	// BEQ
			         3'b001: pcSource = br_eq  ? 0 : 2; 	// BNE
			         3'b100: pcSource = br_lt  ? 2 : 0; 	// BLT
			         3'b101: pcSource = br_lt  ? 0 : 2; 	// BGE
			         3'b110: pcSource = br_ltu ? 2 : 0; 	// BLTU
			         3'b111: pcSource = br_ltu ? 0 : 2;		// BGEU
			     endcase
			end
			
			STORE:
			begin
				alu_fun = 4'b0000; 
				alu_srcA = 0; 
				alu_srcB = 2;
				imm_ctrl = 1;
				mem_we = 1;
			end
			
			OP_RG3:
			begin
			     alu_srcA = 0;
			     alu_srcB = 0;
			     rf_wr_sel = 3;
				 rf_we = 1'b0;

			     case(func3)
                    3'b000: alu_fun = ~func7 ? 4'b0000 : 4'b1000; // ADD : SUB
                    3'b001: alu_fun = 4'b0001; // SLL
                    3'b010: alu_fun = 4'b0010; // SLT
                    3'b011: alu_fun = 4'b0011; // SLTU
                    3'b100: alu_fun = 4'b0100; // XOR
                    3'b101: alu_fun = ~func7 ? 4'b0101 : 4'b1101; // SRL : SRA
                    3'b110: alu_fun = 4'b0110; // OR
                    3'b111: alu_fun = 4'b0111; // AND
                 endcase
            end
            
			default:
			begin
				 pcSource = 2'b00; 
				 alu_srcB = 2'b00; 
				 rf_wr_sel = 2'b00; 
				 alu_srcA = 1'b0; 
				 alu_fun = 4'b0000;
				 imm_ctrl = 5;
			end
        endcase
    end
endmodule
