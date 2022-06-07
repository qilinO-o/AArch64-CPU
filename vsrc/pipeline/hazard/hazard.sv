`ifndef __HAZARD_SV
`define __HAZARD_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/hazard/forward.sv"
`include "pipeline/hazard/stall.sv"
`else

`endif
//dealing with all hazards
module hazard
	import common::*;
    import pipes::*;
    (
    input decode_op_t op,
    //input u1 branch,
    input u1 ireq_valid,iresp_data_ok,
    input u1 dreq_valid,dresp_data_ok,
    input u5 rs1D,rs2D,
    input decode_data_t dataD,
    input execute_data_t dataE,
    input memory_data_t dataM,
    //input writeback_data_t dataW,
    input word_t srca,srcb,
    input u1 stallE_mult,
    //input u1 flush_csr,
    output hazard_control_t hazard_ctrl,
    output word_t srca_hE,
    output word_t srcb_hE,
    output word_t srca_hD,
    output word_t srcb_hD
    //output u1 flush_all
);
    forward forward(
        op,
        dataD.instr[6:0],
        rs1D,
        rs2D,
        dataD.rs1,
        dataD.rs2,
        
        //dataD.dst,
        dataE.dst,
        dataM.dst,
        
        //dataD.ctrl.regwrite,
        dataE.regwrite,
        dataM.regwrite,
        //dataD.ctrl.memtoreg,
        dataM.memtoreg,
        //data contents
        dataE.aluout,
        dataM.readdata,
        dataM.aluout,
        srca,
        srcb,
        dataD.srca,
        dataD.srcb,
        srca_hE,
        srcb_hE,
        srca_hD,
        srcb_hD
    );

    stall stall(
        op,
        ireq_valid,
        iresp_data_ok,
        dreq_valid,
        dresp_data_ok,
        rs1D,
        rs2D,
        dataD.rs1,
        dataD.rs2,
        dataD.dst,
        dataE.dst,
        dataD.ctrl.regwrite,
        dataE.memwrite | dataE.memtoreg,
        dataE.memtoreg,
        stallE_mult,
        //flush_csr,
        hazard_ctrl.stallF,
	    hazard_ctrl.stallD,
        hazard_ctrl.stallE,
        hazard_ctrl.stallM,
        hazard_ctrl.stallW,
        hazard_ctrl.flushF,
        hazard_ctrl.flushD,
	    hazard_ctrl.flushE,
        hazard_ctrl.flushW
        //flush_all
    );

endmodule
`endif