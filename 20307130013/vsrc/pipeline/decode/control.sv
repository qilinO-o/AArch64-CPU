`ifndef __CONTROL_SV
`define __CONTROL_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif
//recognize different instr form and give control signal
module control 
	import common::*;
    import pipes::*;
    (
	input u7 op,op2,
    input u3 func,
    
    output control_t ctrl,
    // output u1 branch,
    output decode_op_t op_t,
    output msize_t msize,
    output u1 mem_unsigned
);
    always_comb begin
        op_t = UNKNOWN;
        msize = MSIZE8;
        mem_unsigned = '0;
        unique case(op)
            F7_ADDI: begin
                unique case(func)
                    F3_ADDI: begin
                        op_t=ADDI;
                        ctrl.alufunc=ALU_ADD;
                        ctrl.regwrite=1;
                        ctrl.memread=0;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=0;
                        ctrl.alusrc=1;
                        // branch=0;
                    end
                    F3_XORI: begin
                        op_t=XORI;
                        ctrl.alufunc=ALU_XOR;
                        ctrl.regwrite=1;
                        ctrl.memread=0;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=0;
                        ctrl.alusrc=1;
                        // branch=0;
                    end
                    F3_ORI: begin
                        op_t=ORI;  
                        ctrl.alufunc=ALU_OR;
                        ctrl.regwrite=1;
                        ctrl.memread=0;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=0;
                        ctrl.alusrc=1;
                        // branch=0;
                    end
                    F3_ANDI: begin
                        op_t=ANDI;
                        ctrl.alufunc=ALU_AND;
                        ctrl.regwrite=1;
                        ctrl.memread=0;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=0;
                        ctrl.alusrc=1;
                        // branch=0;
                    end
                    F3_SLTI: begin
                        op_t=SLTI;
                        ctrl.alufunc=ALU_SLTI;
                        ctrl.regwrite=1;
                        ctrl.memread=0;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=0;
                        ctrl.alusrc=1;
                        // branch=0;
                    end
                    F3_SLTIU: begin
                        op_t=SLTIU;
                        ctrl.alufunc=ALU_SLTIU;
                        ctrl.regwrite=1;
                        ctrl.memread=0;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=0;
                        ctrl.alusrc=1;
                        // branch=0;
                    end
                    F3_SLLI: begin
                        op_t=SLLI;
                        ctrl.alufunc=ALU_SLLI;
                        ctrl.regwrite=1;
                        ctrl.memread=0;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=0;
                        ctrl.alusrc=1;
                        // branch=0;
                    end
                    F3_SRLI: begin
                        unique case(op2[6:1])
                            F6_SRLI_2: begin
                                op_t=SRLI;
                                ctrl.alufunc=ALU_SRLI;
                                ctrl.regwrite=1;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=1;
                            end
                            F6_SRAI_2: begin
                                op_t=SRAI;
                                ctrl.alufunc=ALU_SRAI;
                                ctrl.regwrite=1;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=1;
                            end
                            default: begin
                                op_t=UNKNOWN;
                                ctrl.alufunc=ALU_NULL;
                                ctrl.regwrite=0;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=0;
                            end
                        endcase
                    end
                    default: begin
                        op_t=UNKNOWN;
                        ctrl.alufunc=ALU_NULL;
                        ctrl.regwrite=0;
                        ctrl.memread=0;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=0;
                        ctrl.alusrc=0;
                        // branch=0;
                    end
                endcase
            end
            F7_ADDIW: begin
                unique case(func)
                    F3_ADDI: begin
                        op_t=ADDIW;
                        ctrl.alufunc=ALU_ADDW;
                        ctrl.regwrite=1;
                        ctrl.memread=0;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=0;
                        ctrl.alusrc=1;
                    end
                    F3_SLLI: begin
                        op_t=SLLIW;
                        ctrl.alufunc=ALU_SLLW;
                        ctrl.regwrite=1;
                        ctrl.memread=0;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=0;
                        ctrl.alusrc=1;
                    end
                    F3_SRLI: begin
                        unique case(op2[6:1])
                            F6_SRLI_2: begin
                                op_t=SRLIW;
                                ctrl.alufunc=ALU_SRLW;
                                ctrl.regwrite=1;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=1;
                            end
                            F6_SRAI_2: begin
                                op_t=SRAIW;
                                ctrl.alufunc=ALU_SRAW;
                                ctrl.regwrite=1;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=1;
                            end
                            default: begin
                                op_t=UNKNOWN;
                                ctrl.alufunc=ALU_NULL;
                                ctrl.regwrite=0;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=0;
                            end
                        endcase
                    end
                    default: begin
                        op_t=UNKNOWN;
                        ctrl.alufunc=ALU_NULL;
                        ctrl.regwrite=0;
                        ctrl.memread=0;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=0;
                        ctrl.alusrc=0;
                    end
                endcase
                
            end

            F7_LUI: begin
                op_t=LUI;
                ctrl.alufunc=ALU_NULL;
                ctrl.regwrite=1;
                ctrl.memread=0;
                ctrl.memwrite=0;
                ctrl.memtoreg=0;
                ctrl.alusrc=1;
                // branch=0;
            end
            F7_JAL: begin
                op_t=JAL;
                ctrl.alufunc=ALU_NULL;
                ctrl.regwrite=1;
                ctrl.memread=0;
                ctrl.memwrite=0;
                ctrl.memtoreg=0;
                ctrl.alusrc=0;
                // branch=1;
            end
            F7_BEQ: begin
                op_t=BEQ;
                ctrl.alufunc=ALU_NULL;
                ctrl.regwrite=0;
                ctrl.memread=0;
                ctrl.memwrite=0;
                ctrl.memtoreg=0;
                ctrl.alusrc=0;
                //branch=0;//* in decode
            end
            F7_LD: begin
                unique case(func)
                    F3_LD: begin
                        op_t=LD;
                        ctrl.alufunc=ALU_ADD;
                        ctrl.regwrite=1;
                        ctrl.memread=1;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=1;
                        ctrl.alusrc=1;
                        msize=MSIZE8;
                        mem_unsigned=1;
                    end
                    F3_LB: begin
                        op_t=LB;
                        ctrl.alufunc=ALU_ADD;
                        ctrl.regwrite=1;
                        ctrl.memread=1;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=1;
                        ctrl.alusrc=1;
                        msize=MSIZE1;
                        mem_unsigned=0;
                    end
                    F3_LBU: begin
                        op_t=LBU;
                        ctrl.alufunc=ALU_ADD;
                        ctrl.regwrite=1;
                        ctrl.memread=1;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=1;
                        ctrl.alusrc=1;
                        msize=MSIZE1;
                        mem_unsigned=1;
                    end
                    F3_LH: begin
                        op_t=LH;
                        ctrl.alufunc=ALU_ADD;
                        ctrl.regwrite=1;
                        ctrl.memread=1;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=1;
                        ctrl.alusrc=1;
                        msize=MSIZE2;
                        mem_unsigned=0;
                    end
                    F3_LHU: begin
                        op_t=LHU;
                        ctrl.alufunc=ALU_ADD;
                        ctrl.regwrite=1;
                        ctrl.memread=1;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=1;
                        ctrl.alusrc=1;
                        msize=MSIZE2;
                        mem_unsigned=1;
                    end
                    F3_LW: begin
                        op_t=LW;
                        ctrl.alufunc=ALU_ADD;
                        ctrl.regwrite=1;
                        ctrl.memread=1;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=1;
                        ctrl.alusrc=1;
                        msize=MSIZE4;
                        mem_unsigned=0;
                    end
                    F3_LWU: begin
                        op_t=LWU;
                        ctrl.alufunc=ALU_ADD;
                        ctrl.regwrite=1;
                        ctrl.memread=1;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=1;
                        ctrl.alusrc=1;
                        msize=MSIZE4;
                        mem_unsigned=1;
                    end
                    default: begin
                        op_t = UNKNOWN;
                        ctrl='0;
                    end
                endcase
            end
            F7_SD: begin
                unique case(func)
                    F3_SD: begin
                        op_t=SD;
                        ctrl.alufunc=ALU_ADD;
                        ctrl.regwrite=0;
                        ctrl.memread=0;
                        ctrl.memwrite=1;
                        ctrl.memtoreg=0;
                        ctrl.alusrc=1;
                        msize=MSIZE8;
                    end
                    F3_SB: begin
                        op_t=SB;
                        ctrl.alufunc=ALU_ADD;
                        ctrl.regwrite=0;
                        ctrl.memread=0;
                        ctrl.memwrite=1;
                        ctrl.memtoreg=0;
                        ctrl.alusrc=1;
                        msize=MSIZE1;
                    end
                    F3_SH: begin
                        op_t=SH;
                        ctrl.alufunc=ALU_ADD;
                        ctrl.regwrite=0;
                        ctrl.memread=0;
                        ctrl.memwrite=1;
                        ctrl.memtoreg=0;
                        ctrl.alusrc=1;
                        msize=MSIZE2;
                    end
                    F3_SW: begin
                        op_t=SW;
                        ctrl.alufunc=ALU_ADD;
                        ctrl.regwrite=0;
                        ctrl.memread=0;
                        ctrl.memwrite=1;
                        ctrl.memtoreg=0;
                        ctrl.alusrc=1;
                        msize=MSIZE4;
                    end
                    default: begin
                        op_t = UNKNOWN;
                        ctrl='0;
                    end
                endcase
            end
            F7_ADD: begin
                unique case(func)
                    F3_ADD: begin
                        unique case(op2)
                            F7_ADD_2: begin
                                op_t=ADD;
                                ctrl.alufunc=ALU_ADD;
                                ctrl.regwrite=1;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=0;
                                // branch=0;
                            end
                            F7_SUB_2: begin
                                op_t=SUB;
                                ctrl.alufunc=ALU_SUB;
                                ctrl.regwrite=1;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=0;
                                // branch=0;
                            end
                            F7_MUL_2: begin
                                op_t=MUL;
                                ctrl.alufunc=ALU_MUL;
                                ctrl.regwrite=1;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=0;
                                // branch=0;
                            end
                            default: begin
                                op_t=UNKNOWN;
                                ctrl.alufunc=ALU_NULL;
                                ctrl.regwrite=0;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=0;
                                // branch=0;
                            end
                        endcase
                    end
                    F3_AND: begin
                        unique case(op2)
                            F7_AND_2: begin
                                op_t=AND;
                                ctrl.alufunc=ALU_AND;
                                ctrl.regwrite=1;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=0;
                            end
                            F7_REMU_2: begin
                                op_t=REMU;
                                ctrl.alufunc=ALU_REMU;
                                ctrl.regwrite=1;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=0;
                            end
                            default: begin
                                op_t = UNKNOWN;
                                ctrl='0;
                            end
                        endcase
                    end
                    F3_OR: begin
                        unique case(op2)
                            F7_OR_2: begin
                                op_t=OR;
                                ctrl.alufunc=ALU_OR;
                                ctrl.regwrite=1;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=0;
                            end
                            F7_REM_2: begin
                                op_t=REM;
                                ctrl.alufunc=ALU_REM;
                                ctrl.regwrite=1;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=0;
                            end
                            default: begin
                                op_t = UNKNOWN;
                                ctrl='0;
                            end
                        endcase
                        
                    end
                    F3_XOR: begin
                        unique case(op2)
                            F7_XOR_2: begin
                                op_t=XOR;
                                ctrl.alufunc=ALU_XOR;
                                ctrl.regwrite=1;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=0;
                            end
                            F7_DIV_2: begin
                                op_t=DIV;
                                ctrl.alufunc=ALU_DIV;
                                ctrl.regwrite=1;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=0;
                            end
                            default: begin
                                op_t = UNKNOWN;
                                ctrl='0;
                            end
                        endcase
                        
                    end
                    F3_SLL: begin
                        op_t=SLL;
                        ctrl.alufunc=ALU_SLLI;
                        ctrl.regwrite=1;
                        ctrl.memread=0;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=0;
                        ctrl.alusrc=0;
                        // branch=0;
                    end
                    F3_SLT: begin
                        op_t=SLT;
                        ctrl.alufunc=ALU_SLTI;
                        ctrl.regwrite=1;
                        ctrl.memread=0;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=0;
                        ctrl.alusrc=0;
                        // branch=0;
                    end
                    F3_SLTU: begin
                        op_t=SLTU;
                        ctrl.alufunc=ALU_SLTIU;
                        ctrl.regwrite=1;
                        ctrl.memread=0;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=0;
                        ctrl.alusrc=0;
                        // branch=0;
                    end
                    F3_SRL: begin
                        unique case(op2)
                            F7_SRL_2: begin
                                op_t=SRL;
                                ctrl.alufunc=ALU_SRLI;
                                ctrl.regwrite=1;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=0;
                            end
                            F7_SRA_2: begin
                                op_t=SRA;
                                ctrl.alufunc=ALU_SRAI;
                                ctrl.regwrite=1;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=0;
                            end
                            F7_DIVU_2: begin
                                op_t=DIVU;
                                ctrl.alufunc=ALU_DIVU;
                                ctrl.regwrite=1;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=0;
                            end
                            default: begin
                                op_t = UNKNOWN;
                                ctrl='0;
                            end
                        endcase
                        
                    end
                    default: begin
                        op_t = UNKNOWN;
                        ctrl='0;
                    end
                endcase
            end
            
            F7_ADDW: begin
                unique case(func)
                    F3_ADD: begin
                        unique case(op2)
                            F7_ADD_2: begin
                                op_t=ADD;
                                ctrl.alufunc=ALU_ADDW;
                                ctrl.regwrite=1;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=0;
                            end
                            F7_SUB_2: begin
                                op_t=SUB;
                                ctrl.alufunc=ALU_SUBW;
                                ctrl.regwrite=1;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=0;
                            end
                            F7_MUL_2: begin
                                op_t=MULW;
                                ctrl.alufunc=ALU_MULW;
                                ctrl.regwrite=1;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=0;
                            end
                            default: begin
                                op_t = UNKNOWN;
                                ctrl='0;
                            end
                        endcase
                    end
                    F3_SLL: begin
                        op_t=SLL;
                        ctrl.alufunc=ALU_SLLW;
                        ctrl.regwrite=1;
                        ctrl.memread=0;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=0;
                        ctrl.alusrc=0;
                    end
                    F3_SRL: begin
                        unique case(op2)
                            F7_SRL_2: begin
                                op_t=SRL;
                                ctrl.alufunc=ALU_SRLW;
                                ctrl.regwrite=1;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=0;
                            end
                            F7_SRA_2: begin
                                op_t=SRA;
                                ctrl.alufunc=ALU_SRAW;
                                ctrl.regwrite=1;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=0;
                            end
                            F7_DIV_2: begin
                                op_t=DIVUW;
                                ctrl.alufunc=ALU_DIVUW;
                                ctrl.regwrite=1;
                                ctrl.memread=0;
                                ctrl.memwrite=0;
                                ctrl.memtoreg=0;
                                ctrl.alusrc=0;
                            end
                            default: begin
                                op_t = UNKNOWN;
                                ctrl='0;
                            end
                        endcase 
                    end
                    F3_DIVW: begin
                        op_t=DIVW;
                        ctrl.alufunc=ALU_DIVW;
                        ctrl.regwrite=1;
                        ctrl.memread=0;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=0;
                        ctrl.alusrc=0;
                    end
                    F3_REMW: begin
                        op_t=REMW;
                        ctrl.alufunc=ALU_REMW;
                        ctrl.regwrite=1;
                        ctrl.memread=0;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=0;
                        ctrl.alusrc=0;
                    end
                    F3_REMUW: begin
                        op_t=REMUW;
                        ctrl.alufunc=ALU_REMUW;
                        ctrl.regwrite=1;
                        ctrl.memread=0;
                        ctrl.memwrite=0;
                        ctrl.memtoreg=0;
                        ctrl.alusrc=0;
                    end
                    default: begin
                        op_t = UNKNOWN;
                        ctrl='0;
                    end
                endcase
            end

            F7_AUIPC: begin
                op_t=AUIPC;
                ctrl.alufunc=ALU_ADD;
                ctrl.regwrite=1;
                ctrl.memread=0;
                ctrl.memwrite=0;
                ctrl.memtoreg=0;
                ctrl.alusrc=1;
                // branch=0;
            end
            F7_JALR: begin
                op_t=JALR;
                ctrl.alufunc=ALU_NULL;
                ctrl.regwrite=1;
                ctrl.memread=0;
                ctrl.memwrite=0;
                ctrl.memtoreg=0;
                ctrl.alusrc=0;
                // branch=1;
            end
            
            default:begin
                op_t = UNKNOWN;
                ctrl='0;
            end
        endcase
    end


endmodule
`endif