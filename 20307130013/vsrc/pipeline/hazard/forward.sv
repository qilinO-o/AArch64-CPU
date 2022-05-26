`ifndef __FORWARD_SV
`define __FORWARD_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif
//dealing with forward signals
module forward
	import common::*;
    import pipes::*;
    (
    input decode_op_t op,
    input u7 op2,
	input u5 rs1D,
    input u5 rs2D,
    input creg_addr_t rs1E,
    input creg_addr_t rs2E,
    //input creg_addr_t dstE,
    input creg_addr_t dstM,
    input creg_addr_t dstW,
    //input u1 regwriteE,
    input u1 regwriteM,
    input u1 regwriteW,
    //input u1 memtoregE,
    //input u1 memtoregM,
    input u1 memtoregW,
    //data contents
    input word_t aluoutM,
    input word_t readdataW,
    input word_t aluoutW,
    input word_t srca,
    input word_t srcb,
    input word_t srcaD,
    input word_t srcbD,
    output word_t select_srcaE,
    output word_t select_srcbE,
    output word_t select_srcaD,
    output word_t select_srcbD
);
    
    always_comb//forward to D
    begin
        select_srcaD=srca;
        select_srcbD=srcb;
        if(op!=JAL && op!=AUIPC) begin
            if(regwriteW) begin
                if(rs1D==dstW) begin
                    if(memtoregW) select_srcaD=readdataW;//!!!!
                    else select_srcaD=aluoutW;
                end
                if(op!=JALR && rs2D==dstW) begin
                    if(memtoregW) select_srcbD=readdataW;//!!!!
                    else select_srcbD=aluoutW;
                end
            end
            if(regwriteM) begin
                if(rs1D==dstM) select_srcaD=aluoutM;
                if(op!=JALR && rs2D==dstM) select_srcbD=aluoutM;
            end
            if(rs1D==5'b00000) select_srcaD=srca;
            if(rs2D==5'b00000) select_srcbD=srcb;
        end
    end

    always_comb//forward to E
    begin
        select_srcaE=srcaD;
        select_srcbE=srcbD;
        if(op2!=F7_JAL && op2!=F7_AUIPC) begin
            if(regwriteW) begin
                if(rs1E==dstW) begin
                    if(memtoregW) select_srcaE=readdataW;//!!!!
                    else select_srcaE=aluoutW;
                end
                if(op2!=F7_JALR && rs2E==dstW) begin
                    if(memtoregW) select_srcbE=readdataW;//!!!!
                    else select_srcbE=aluoutW;
                end
            end
            if(regwriteM) begin  
                if(rs1E==dstM) select_srcaE=aluoutM;
                if(op2!=F7_JALR && rs2E==dstM) select_srcbE=aluoutM;
                //$display("%x",select_srcbE);
            end
            if(rs1E==5'b00000) select_srcaE=srcaD;
            if(rs2E==5'b00000) select_srcbE=srcbD;
        end
    end

endmodule
`endif