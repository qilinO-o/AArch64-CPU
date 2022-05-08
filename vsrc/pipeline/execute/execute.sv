`ifndef __EXECUTE_SV
`define __EXECUTE_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/execute/alu.sv"
`else

`endif
//execute
module execute 
	import common::*;
    import pipes::*;
    (
    //input u2 forwardAE,
	//input u2 forwardBE,
	//input u64 aluout_back,
	//input word_t resultw_back,
    input decode_data_t dataD,
    input word_t srca_h,srcb_h,
    output execute_data_t dataE
);
    u64 select_srca;
    u64 select_srcb;
    assign select_srca=srca_h;
    
    always_comb begin
        unique case(dataD.ctrl.alusrc)
            1'b1: select_srcb=dataD.ext_imm;
            1'b0: select_srcb=srcb_h;
            default: begin

            end
        endcase
    end
    
    alu alu(
        select_srca,
        select_srcb,
        dataD.ctrl.alufunc,
        dataE.aluout
    );
    assign dataE.instr=dataD.instr;
    assign dataE.pc=dataD.pc;
    assign dataE.regwrite=dataD.ctrl.regwrite;
    assign dataE.memread=dataD.ctrl.memread;
    assign dataE.memwrite=dataD.ctrl.memwrite;
    assign dataE.memtoreg=dataD.ctrl.memtoreg;
    assign dataE.writedata=srcb_h;//may have hazard
    assign dataE.dst=dataD.dst;
    assign dataE.valid=dataD.valid;
    assign dataE.msize=dataD.msize;
    assign dataE.mem_unsigned=dataD.mem_unsigned;
endmodule
`endif