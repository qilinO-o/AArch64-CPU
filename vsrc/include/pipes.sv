`ifndef __PIPES_SV
`define __PIPES_SV
`ifdef VERILATOR
`include "include/common.sv"
`else

`endif
/* Define instrucion decoding rules here */
package pipes;
import common::*;
// parameter F7_RI = 7'bxxxxxxx;
//addi xori ori andi lui jal beq ld sd add sub and or xor auipc jalr
parameter F7_ADDI = 7'b0010011;//XORI,ORI,ANDI
// parameter F7_XORI = 7'b0010011;
// parameter F7_ORI = 7'b0010011;
// parameter F7_ANDI = 7'b0010011;
// parameter F7_SLTI = 7'b0010011;
// parameter F7_SLTIU = 7'b0010011;
// parameter F7_SLLI = 7'b0010011;
// parameter F7_SRLI = 7'b0010011;
// parameter F7_SRAI = 7'b0010011;

parameter F7_ADDIW = 7'b0011011;//ADDIW SLLIW SRLIW SRAIW
parameter F7_ADDW = 7'b0111011;

parameter F7_LUI = 7'b0110111;//no f3
parameter F7_JAL = 7'b1101111;//no f3
parameter F7_BEQ = 7'b1100011;
//parameter F7_BNE = 7'b1100011;
parameter F7_LD = 7'b0000011;
parameter F7_SD = 7'b0100011;
parameter F7_ADD = 7'b0110011;//SUB,AND,OR,XOR  f7_2
// parameter F7_SUB = 7'b0110011;
// parameter F7_AND = 7'b0110011;
// parameter F7_OR = 7'b0110011;
// parameter F7_XOR = 7'b0110011;
// parameter F7_SLL = 7'b0110011;
// parameter F7_SLT = 7'b0110011;
// parameter F7_SLTU = 7'b0110011;
// parameter F7_SRL = 7'b0110011;

parameter F7_AUIPC = 7'b0010111;//no f3
parameter F7_JALR = 7'b1100111;

parameter F3_ADDI = 3'b000;
parameter F3_XORI = 3'b100;
parameter F3_ORI = 3'b110;
parameter F3_ANDI = 3'b111;
parameter F3_SLTI = 3'b010;
parameter F3_SLTIU = 3'b011;
parameter F3_SLLI = 3'b001;
parameter F3_SRLI = 3'b101;
//parameter F3_SRAI = 3'b101;

parameter F3_BEQ = 3'b000;
parameter F3_BNE = 3'b001;
parameter F3_BLT = 3'b100;
parameter F3_BGE = 3'b101;
parameter F3_BLTU = 3'b110;
parameter F3_BGEU = 3'b111;

parameter F3_LD = 3'b011;
parameter F3_LB = 3'b000;
parameter F3_LBU = 3'b100;
parameter F3_LH = 3'b001;
parameter F3_LHU = 3'b101;
parameter F3_LW = 3'b010;
parameter F3_LWU = 3'b110;

parameter F3_SD = 3'b011;
parameter F3_SB = 3'b000;
parameter F3_SH = 3'b001;
parameter F3_SW = 3'b010;

parameter F3_ADD = 3'b000;//SUB
// parameter F3_SUB = 3'b000;
parameter F3_AND = 3'b111;
parameter F3_OR = 3'b110;
parameter F3_XOR = 3'b100;
parameter F3_SLL = 3'b001;
parameter F3_SLT = 3'b010;
parameter F3_SLTU = 3'b011;
parameter F3_SRL = 3'b101;
parameter F3_SRA = 3'b101;

parameter F3_JALR = 3'b000;


parameter F7_ADD_2 = 7'b0000000;
parameter F7_SUB_2 = 7'b0100000;
parameter F7_AND_2 = 7'b0000000;
parameter F7_OR_2 = 7'b0000000;
parameter F7_XOR_2 = 7'b0000000;
parameter F6_SRLI_2 = 6'b000000;
parameter F6_SRAI_2 = 6'b010000;
parameter F6_SRL_2 = 6'b000000;
parameter F6_SRA_2 = 6'b010000;

/* Define pipeline structures here */

typedef enum logic [4:0] {
	ALU_NULL,
	ALU_ADD, ALU_SUB, ALU_XOR, ALU_OR, ALU_AND,
	ALU_SLTI, ALU_SLTIU, ALU_SLLI, ALU_SRLI, ALU_SRAI,
	ALU_ADDW, ALU_SUBW, ALU_SLLW, ALU_SRLW, ALU_SRAW
} alufunc_t;

typedef enum logic [6:0]{
	UNKNOWN, ADDI, XORI, ORI,
	ANDI, LUI, JAL, BEQ, 
	LD, SD, ADD, SUB, AND, 
	OR, XOR, AUIPC, JALR, SLTI, SLTIU, SLLI, SRLI, SRAI,
	SLL, SLT, SLTU, SRL, SRA,
	ADDIW, SLLIW, SRLIW, SRAIW,
	LB, LBU, LH, LHU, LW, LWU, 
	SB, SH, SW
} decode_op_t;

typedef enum logic [3:0]{
	EXT_NULL, EXT_ADDI,//12->64
	EXT_LUI,//20->64 left shift 12 with 0
	EXT_SD, //ld 12->64
	EXT_JAL, //20->64 left shift 1 with 0
	EXT_BEQ //12->64 left shift 1 with 0
} im_ext_t;

typedef struct packed {
	u32 instr;
    addr_t pc;
	u1 valid;
} fetch_data_t;

typedef struct packed{
	//decode_op_t op;
	alufunc_t alufunc;
	u1 regwrite;
	u1 memread,memwrite;
	u1 memtoreg;
	u1 alusrc;
	//u1 branch;
} control_t;

typedef struct packed {
	u1 stallF;
	u1 stallD;
	u1 stallE;
	u1 stallM;
	u1 flushF;
	u1 flushD;
	u1 flushE;
	u1 flushW;
	word_t srca_hE;
	word_t srcb_hE;
	word_t srca_hD;
	word_t srcb_hD;
} hazard_control_t;

typedef struct packed{
	control_t ctrl;
	word_t srca,srcb;
	u64 ext_imm;
	creg_addr_t dst;//rd
	u32 instr;
    addr_t pc;
	u1 valid;
	u5 rs1;
	u5 rs2;
	msize_t msize;
	u1 mem_unsigned;
} decode_data_t;

typedef struct packed{
	u32 instr;
    addr_t pc;
	u1 regwrite;
	u1 memread,memwrite;
	u1 memtoreg;
	u64 aluout;
	u64 writedata;
	creg_addr_t dst;
	u1 valid;
	msize_t msize;
	u1 mem_unsigned;
} execute_data_t;

typedef struct packed {
	u32 instr;
    addr_t pc;
	u1 regwrite;
	u1 memread,memwrite;
	u1 memtoreg;
	word_t readdata;
	word_t aluout;
	creg_addr_t dst;
	u1 valid;
} memory_data_t;

typedef struct packed {
	u32 instr;
    addr_t pc;
	u1 memread,memwrite;
	word_t aluout;
	word_t resultw;
	u1 regwrite;
	creg_addr_t dst;
	u1 valid;
} writeback_data_t;

endpackage
`endif
