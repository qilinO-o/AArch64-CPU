`ifndef __DECODE_SV
`define __DECODE_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/decode/control.sv"
`include "pipeline/decode/sign_ext.sv"
`include "pipeline/decode/branchadder.sv"
`else

`endif
//decode & recognize different dataF.instr form
module decode 
	import common::*;
    import pipes::*;
    (
    input fetch_data_t dataF,
    input word_t srca,srcb,
    output u5 rs1,
    output u5 rs2,
    output u1 branch,
    output addr_t pcbranch,
    output decode_data_t dataD,
    output decode_op_t op_t
);
    u7 op;
    u3 func;
    u7 op2;
    u20 imm;
    im_ext_t im_ext;
    assign op = dataF.instr[6:0];
    assign dataD.dst = dataF.instr[11:7];
    assign rs1 = dataF.instr[19:15];
    assign rs2 = dataF.instr[24:20];
    assign func = dataF.instr[14:12];
    assign op2 = dataF.instr[31:25];
    
    always_comb begin
        unique case(op)
            F7_ADDI: begin
                unique case(func)
                    F3_ADDI: begin
                        imm={8'b00000000,dataF.instr[31:20]};
                        im_ext=EXT_ADDI;
                        branch=0;
                    end
                    F3_XORI: begin
                        imm={8'b00000000,dataF.instr[31:20]};
                        im_ext=EXT_ADDI;
                        branch=0;
                    end
                    F3_ORI: begin
                        imm={8'b00000000,dataF.instr[31:20]};
                        im_ext=EXT_ADDI;
                        branch=0;
                    end
                    F3_ANDI: begin
                        imm={8'b00000000,dataF.instr[31:20]};
                        im_ext=EXT_ADDI;
                        branch=0;
                    end
                    F3_SLTI: begin
                        imm={8'b00000000,dataF.instr[31:20]};
                        im_ext=EXT_ADDI;
                        branch=0;
                    end
                    F3_SLTIU: begin
                        imm={8'b00000000,dataF.instr[31:20]};
                        im_ext=EXT_ADDI;
                        branch=0;
                    end
                    F3_SLLI: begin
                        imm={8'b00000000,dataF.instr[31:20]};
                        im_ext=EXT_ADDI;
                        branch=0;
                    end
                    F3_SRLI: begin
                        unique case(op2[6:1])
                            F6_SRLI_2: begin
                                imm={8'b00000000,dataF.instr[31:20]};
                                im_ext=EXT_ADDI;
                                branch=0;
                            end
                            F6_SRAI_2: begin
                                imm={8'b00000000,dataF.instr[31:20]};
                                im_ext=EXT_ADDI;
                                branch=0;
                            end
                            default: begin
                                imm=0;
                                im_ext=EXT_NULL;
                                branch=0;
                            end
                        endcase
                    end
                    default: begin
                        imm=0;
                        im_ext=EXT_NULL;
                        branch=0;
                    end
                endcase
            end
            F7_ADDIW: begin
                unique case(func)
                    F3_ADDI: begin
                        imm={8'b00000000,dataF.instr[31:20]};
                        im_ext=EXT_ADDI;
                        branch=0;
                    end
                    F3_SLLI: begin
                        imm={8'b00000000,dataF.instr[31:20]};
                        im_ext=EXT_ADDI;
                        branch=0;
                    end
                    F3_SRLI: begin //SRAI
                        imm={8'b00000000,dataF.instr[31:20]};
                        im_ext=EXT_ADDI;
                        branch=0;
                    end
                    default: begin
                        imm=0;
                        im_ext=EXT_NULL;
                        branch=0;
                    end
                endcase
            end

            F7_LUI: begin
                imm=dataF.instr[31:12];
                im_ext=EXT_LUI;
                branch=0;
            end
            F7_JAL: begin
                imm={dataF.instr[31],dataF.instr[19:12],dataF.instr[20],dataF.instr[30:21]};
                im_ext=EXT_JAL;
                branch=1;
            end
            F7_BEQ: begin
                unique case(func)
                    F3_BEQ: begin
                        if(srca==srcb) begin
                            branch=1;
                            //$display("%x", 1);
                        end 
                        else begin
                            branch=0;
                            //$display("%x", srca);
                            //$display("%x", srcb);
                        end
                        imm={8'b00000000,dataF.instr[31],dataF.instr[7],dataF.instr[30:25],dataF.instr[11:8]};
                        im_ext=EXT_BEQ;
                    end
                    F3_BNE: begin
                        if(srca!=srcb) begin
                            branch=1;
                        end 
                        else begin
                            branch=0;
                        end
                        imm={8'b00000000,dataF.instr[31],dataF.instr[7],dataF.instr[30:25],dataF.instr[11:8]};
                        im_ext=EXT_BEQ;
                    end
                    F3_BLT: begin
                        if($signed(srca) < $signed(srcb)) begin
                            branch=1;
                        end 
                        else begin
                            branch=0;
                        end
                        imm={8'b00000000,dataF.instr[31],dataF.instr[7],dataF.instr[30:25],dataF.instr[11:8]};
                        im_ext=EXT_BEQ;
                    end
                    F3_BGE: begin
                        if($signed(srca) >= $signed(srcb)) begin
                            branch=1;
                        end 
                        else begin
                            branch=0;
                        end
                        imm={8'b00000000,dataF.instr[31],dataF.instr[7],dataF.instr[30:25],dataF.instr[11:8]};
                        im_ext=EXT_BEQ;
                    end
                    F3_BLTU: begin
                        if(srca < srcb) begin
                            branch=1;
                        end 
                        else begin
                            branch=0;
                        end
                        imm={8'b00000000,dataF.instr[31],dataF.instr[7],dataF.instr[30:25],dataF.instr[11:8]};
                        im_ext=EXT_BEQ;
                    end
                    F3_BGEU: begin
                        if(srca >= srcb) begin
                            branch=1;
                        end 
                        else begin
                            branch=0;
                        end
                        imm={8'b00000000,dataF.instr[31],dataF.instr[7],dataF.instr[30:25],dataF.instr[11:8]};
                        im_ext=EXT_BEQ;
                    end
                    default: begin
                        imm=0;
                        im_ext=EXT_NULL;
                        branch=0;
                    end
                endcase
                
            end
            F7_LD: begin
                imm={8'b00000000,dataF.instr[31:20]};
                im_ext=EXT_SD;
                branch=0;
            end


            F7_SD: begin
                imm={8'b00000000,dataF.instr[31:25],dataF.instr[11:7]};
                im_ext=EXT_SD;
                branch=0;
            end


            F7_ADD: begin
                unique case(func)
                    F3_ADD: begin
                        unique case(op2)
                            F7_ADD_2: begin
                                imm=0;
                                im_ext=EXT_NULL;
                                branch=0;
                            end
                            F7_SUB_2: begin
                                imm=0;
                                im_ext=EXT_NULL;
                                branch=0;
                            end
                            default:begin
                                imm=0;
                                im_ext=EXT_NULL;
                                branch=0;
                            end
                        endcase
                    end
                    F3_AND: begin
                        imm=0;
                        im_ext=EXT_NULL;
                        branch=0;
                    end
                    F3_OR: begin
                        imm=0;
                        im_ext=EXT_NULL;
                        branch=0;
                    end
                    F3_XOR: begin
                        imm=0;
                        im_ext=EXT_NULL;
                        branch=0;
                    end
                    F3_SLL: begin
                        imm=0;
                        im_ext=EXT_NULL;
                        branch=0;
                    end
                    F3_SLT: begin
                        imm=0;
                        im_ext=EXT_NULL;
                        branch=0;
                    end
                    F3_SLTU: begin
                        imm=0;
                        im_ext=EXT_NULL;
                        branch=0;
                    end
                    F3_SRL: begin//and contain SRA
                        imm=0;
                        im_ext=EXT_NULL;
                        branch=0;
                    end
                    default:begin
                        imm=0;
                        im_ext=EXT_NULL;
                        branch=0;
                    end
                endcase
            end
            F7_ADDW: begin
                unique case(func)
                    F3_ADD: begin
                        unique case(op2)
                            F7_ADD_2: begin
                                imm=0;
                                im_ext=EXT_NULL;
                                branch=0;
                            end
                            F7_SUB_2: begin
                                imm=0;
                                im_ext=EXT_NULL;
                                branch=0;
                            end
                            default:begin
                                imm=0;
                                im_ext=EXT_NULL;
                                branch=0;
                            end
                        endcase
                    end
                    F3_SLL: begin
                        imm=0;
                        im_ext=EXT_NULL;
                        branch=0;
                    end
                    F3_SRL: begin
                        imm=0;
                        im_ext=EXT_NULL;
                        branch=0;
                    end
                    default:begin
                        imm=0;
                        im_ext=EXT_NULL;
                        branch=0;
                    end
                endcase
            end

            F7_AUIPC: begin
                imm=dataF.instr[31:12];
                im_ext=EXT_LUI;
                branch=0;
            end
            F7_JALR: begin
                imm={8'b00000000,dataF.instr[31:20]};
                im_ext=EXT_SD;
                branch=1;
            end
            default:begin
                imm=0;
                im_ext=EXT_NULL;
                branch=0;
            end
        endcase
    end
    control control(
        op,
        op2,
        func,
        dataD.ctrl,
        op_t,
        dataD.msize,
        dataD.mem_unsigned
    );

    sign_ext sign_ext(
        imm,
        im_ext,
        dataD.ext_imm
    );
    
    //pcbranch for JAL , BEQ , JALR
    branchadder branchadder(
        op_t,
        srca,
        dataD.ext_imm,
        dataF.pc,
        pcbranch
    );
    
    //assign dataD for complete output

    always_comb begin
        unique case(op_t)
            JAL: begin
                dataD.srca=srca;
                dataD.srcb=dataF.pc+4;
            end
            JALR: begin
                dataD.srca=srca;
                dataD.srcb=dataF.pc+4;
            end
            AUIPC: begin
                dataD.srca=dataF.pc;
                dataD.srcb=srcb;
                //$display("^***%x***^", dataD.ext_imm);
                //$display("****%x****", dataD.srcb);
            end
            default: begin
                dataD.srca=srca;
                dataD.srcb=srcb;
            end
        endcase
    end
    assign dataD.rs1=dataF.instr[19:15];
    assign dataD.rs2=dataF.instr[24:20];
    assign dataD.instr=dataF.instr;
    assign dataD.pc=dataF.pc;
    assign dataD.valid=dataF.valid;

endmodule
`endif