`ifndef __CORE_SV
`define __CORE_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/fetch/pc.sv"
`include "pipeline/regfile/regfile.sv"
`include "pipeline/decode/decode.sv"
`include "pipeline/execute/execute.sv"
`include "pipeline/pipereg/IFID_reg.sv"
`include "pipeline/pipereg/IDEX_reg.sv"
`include "pipeline/pipereg/EXMEM_reg.sv"
`include "pipeline/pipereg/MEMWR_reg.sv"
`include "pipeline/memory/memory.sv"
`include "pipeline/writeback/writeback.sv"
`include "pipeline/hazard/hazard.sv"
`else

`endif

module core 
	import common::*;
	import pipes::*;
	(
	input logic clk, reset,
	output ibus_req_t  ireq,
	input  ibus_resp_t iresp,
	output dbus_req_t  dreq,
	input  dbus_resp_t dresp
);
	/* TODO: Add your pipeline here. */
	
	//as wire
	fetch_data_t dataF;
	fetch_data_t dataF_nxt;
	decode_data_t dataD;
	decode_data_t dataD_nxt;
	execute_data_t dataE;
	execute_data_t dataE_nxt;
	memory_data_t dataM;
	memory_data_t dataM_nxt;
	writeback_data_t dataW;
	addr_t temp_pc;
	u1 branch;
    u7 op,op2;
	decode_op_t op_t;
    u5 rs1,rs2;
	word_t srca,srcb;
	addr_t pcbranch;
	u64 aluout_back;
	word_t resultw_back;
	u1 stallE_mult;
	u1 branch_nxt;
	addr_t pcbranch_nxt;
    //hazard
	hazard_control_t hazard_ctrl;
	word_t srca_hE;
	word_t srcb_hE;
	word_t srca_hD;
	word_t srcb_hD;

	hazard hazard_hazard(
		op_t,
    	//branch,
		ireq.valid,
		iresp.data_ok,
		dreq.valid,
		dresp.data_ok,
    	rs1,
		rs2,
		dataD_nxt,
		dataE_nxt,
		dataM_nxt,
		//dataW,
		srca,
		srcb,
		stallE_mult,
    	hazard_ctrl,
		srca_hE,
		srcb_hE,
		srca_hD,
		srcb_hD
	);
	//fetch
    pc pc_pc(
		~hazard_ctrl.stallF,
        clk,reset,
        branch | branch_nxt,
        pcbranch | pcbranch_nxt,
		iresp,
		temp_pc,
        dataF
    );
	assign ireq.addr=temp_pc;
	assign ireq.valid=1;
    //IF/ID reg
    IFID_reg IFID_reg_IFID_reg(
		~hazard_ctrl.stallD,
		clk,reset,branch_nxt | branch,hazard_ctrl.flushF,
		dataF,
		dataF_nxt
	);
	
	always_ff @(posedge clk)
	begin
		if(~hazard_ctrl.stallD) begin
			if(reset | (branch_nxt & iresp.data_ok) | (branch & iresp.data_ok)) begin
				branch_nxt <= '0;
				pcbranch_nxt <= '0;
			end
			else if(branch) begin
				branch_nxt <= branch;
				pcbranch_nxt <= pcbranch;
			end
			else begin end
		end
		
	end
    //decode
	
    decode decode_decode(
		dataF_nxt,
		srca_hD,
		srcb_hD,
		rs1,
		rs2,
		branch,
		pcbranch,
		dataD,
		op_t
	);
    //ID/Ex reg
	IDEX_reg IDEX_reg_IDEX_reg(
		~hazard_ctrl.stallE,
		clk,reset,hazard_ctrl.flushD,
		dataD,
		dataD_nxt
	);
    //execute
	execute execute_execute(
		clk,reset,
		dataD_nxt,
		srca_hE,
		srcb_hE,
		dataE,
		stallE_mult
	);
    //Ex/Mem reg
	EXMEM_reg EXMEM_reg_EXMEM_reg(
		~hazard_ctrl.stallM,
		clk,reset,hazard_ctrl.flushE,
		dataE,
		dataE_nxt
	);
	//assign aluout_back=dataE.aluout;//forward
    //Data Memory
	memory memory_memory(
		dataE_nxt,
		dreq,
		dresp,
		dataM
	);
    //Mem/Wr reg
	MEMWR_reg MEMWR_reg_MEMWR_reg(
		~hazard_ctrl.stallW,
		clk,reset,hazard_ctrl.flushW,
		dataM,
		dataM_nxt
	);
    //write back
	writeback writeback_writeback(
		dataM_nxt,
		dataW
	);
	//assign resultw_back=dataW.resultw;//forward

	regfile regfile(
		.clk, .reset,
		.ra1(rs1),
		.ra2(rs2),
		.rd1(srca),
		.rd2(srcb),
		.wvalid(dataW.regwrite),
		.wa(dataW.dst),//write addr
		.wd(dataW.resultw)//write data
	);

`ifdef VERILATOR
	DifftestInstrCommit DifftestInstrCommit(
		.clock              (clk),
		.coreid             (0),
		.index              (0),
		.valid              (dataW.valid),
		.pc                 (dataW.pc),
		.instr              (dataW.instr),
		.skip               ((dataW.memread | dataW.memwrite)&(dataW.aluout[31]==0)),
		.isRVC              (0),
		.scFailed           (0),
		.wen                (dataW.regwrite),
		.wdest              ({3'b000,dataW.dst}),
		.wdata              (dataW.resultw)
	);
	      
	DifftestArchIntRegState DifftestArchIntRegState (
		.clock              (clk),
		.coreid             (0),
		.gpr_0              (regfile.regs_nxt[0]),
		.gpr_1              (regfile.regs_nxt[1]),
		.gpr_2              (regfile.regs_nxt[2]),
		.gpr_3              (regfile.regs_nxt[3]),
		.gpr_4              (regfile.regs_nxt[4]),
		.gpr_5              (regfile.regs_nxt[5]),
		.gpr_6              (regfile.regs_nxt[6]),
		.gpr_7              (regfile.regs_nxt[7]),
		.gpr_8              (regfile.regs_nxt[8]),
		.gpr_9              (regfile.regs_nxt[9]),
		.gpr_10             (regfile.regs_nxt[10]),
		.gpr_11             (regfile.regs_nxt[11]),
		.gpr_12             (regfile.regs_nxt[12]),
		.gpr_13             (regfile.regs_nxt[13]),
		.gpr_14             (regfile.regs_nxt[14]),
		.gpr_15             (regfile.regs_nxt[15]),
		.gpr_16             (regfile.regs_nxt[16]),
		.gpr_17             (regfile.regs_nxt[17]),
		.gpr_18             (regfile.regs_nxt[18]),
		.gpr_19             (regfile.regs_nxt[19]),
		.gpr_20             (regfile.regs_nxt[20]),
		.gpr_21             (regfile.regs_nxt[21]),
		.gpr_22             (regfile.regs_nxt[22]),
		.gpr_23             (regfile.regs_nxt[23]),
		.gpr_24             (regfile.regs_nxt[24]),
		.gpr_25             (regfile.regs_nxt[25]),
		.gpr_26             (regfile.regs_nxt[26]),
		.gpr_27             (regfile.regs_nxt[27]),
		.gpr_28             (regfile.regs_nxt[28]),
		.gpr_29             (regfile.regs_nxt[29]),
		.gpr_30             (regfile.regs_nxt[30]),
		.gpr_31             (regfile.regs_nxt[31])
	);
	      
	DifftestTrapEvent DifftestTrapEvent(
		.clock              (clk),
		.coreid             (0),
		.valid              (0),
		.code               (0),
		.pc                 (0),
		.cycleCnt           (0),
		.instrCnt           (0)
	);
	      
	DifftestCSRState DifftestCSRState(
		.clock              (clk),
		.coreid             (0),
		.priviledgeMode     (3),
		.mstatus            (0),
		.sstatus            (0),
		.mepc               (0),
		.sepc               (0),
		.mtval              (0),
		.stval              (0),
		.mtvec              (0),
		.stvec              (0),
		.mcause             (0),
		.scause             (0),
		.satp               (0),
		.mip                (0),
		.mie                (0),
		.mscratch           (0),
		.sscratch           (0),
		.mideleg            (0),
		.medeleg            (0)
	      );
	      
	DifftestArchFpRegState DifftestArchFpRegState(
		.clock              (clk),
		.coreid             (0),
		.fpr_0              (0),
		.fpr_1              (0),
		.fpr_2              (0),
		.fpr_3              (0),
		.fpr_4              (0),
		.fpr_5              (0),
		.fpr_6              (0),
		.fpr_7              (0),
		.fpr_8              (0),
		.fpr_9              (0),
		.fpr_10             (0),
		.fpr_11             (0),
		.fpr_12             (0),
		.fpr_13             (0),
		.fpr_14             (0),
		.fpr_15             (0),
		.fpr_16             (0),
		.fpr_17             (0),
		.fpr_18             (0),
		.fpr_19             (0),
		.fpr_20             (0),
		.fpr_21             (0),
		.fpr_22             (0),
		.fpr_23             (0),
		.fpr_24             (0),
		.fpr_25             (0),
		.fpr_26             (0),
		.fpr_27             (0),
		.fpr_28             (0),
		.fpr_29             (0),
		.fpr_30             (0),
		.fpr_31             (0)
	);
	
`endif
endmodule
`endif