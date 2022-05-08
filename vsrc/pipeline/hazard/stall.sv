`ifndef __STALL_SV
`define __STALL_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif
//dealing with stall&bubble signals
module stall
	import common::*;
    import pipes::*;
    (
    input decode_op_t op,
    input u1 ireq_valid,
    input u1 iresp_data_ok,
    input u1 dreq_valid,
    input u1 dresp_data_ok,
    input u5 rs1D,
    input u5 rs2D,
    input u5 rs1E,
    input u5 rs2E,
    input creg_addr_t dstE,
    input creg_addr_t dstM,
    input u1 regwriteE,
    input u1 memtoregM,
    
    output u1 stallF,
	output u1 stallD,
    output u1 stallE,
    output u1 stallM,
    output u1 flushF,
    output u1 flushD,
	output u1 flushE,
    output u1 flushW 
);
    u1 ldstall;
    u1 lestall;
    always_comb
    begin
        if(op==BEQ || op==JALR) begin
            ldstall= (regwriteE & ((rs1D==dstE) | (rs2D==dstE))) |
                     (memtoregM & ((rs1D==dstM) | (rs2D==dstM)));
        end
        else ldstall=0;
    end
    assign lestall= memtoregM & ((rs1E==dstM) | (rs2E==dstM));
    assign stallF= ldstall | lestall | stallM | (ireq_valid && ~iresp_data_ok);
    assign stallD= ldstall | lestall | stallM;
    assign stallE= lestall | stallM;
    assign stallM= dreq_valid && ~dresp_data_ok;
    assign flushF= ireq_valid && ~iresp_data_ok;
    assign flushD= stallD;
    assign flushE= stallE;
    assign flushW = dreq_valid && ~dresp_data_ok;
endmodule
`endif