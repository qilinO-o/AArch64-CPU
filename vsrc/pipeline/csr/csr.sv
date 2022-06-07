`ifndef __CSR_SV
`define __CSR_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif
//csr
module csr
	import common::*;
    import pipes::*;
    (
    input logic clk, reset,
    input csr_addr_t csr_ra,
    // input u1 w_valid,
    // input csr_addr_t csr_wa,
	// input word_t csr_ctrl.wd,
    // input u1 w_is_mret,
	input csr_control_t csr_ctrl,
	input exception_t except,
	input addr_t pc,
	input logic trint, swint, exint,
	input u1 stall,
    output word_t csr_rd,
    output addr_t csr_pcselect
);

	u1 exception;
	u1 interruption;
    csr_regs_t regs, regs_nxt;
    u2 mode, mode_nxt;
	assign exception = except.exception;
	assign interruption =  regs.mstatus.mie & ((trint & (regs.mie[7] | regs.mie[5])) | (swint & (regs.mie[3] | regs.mie[1])) | (exint & (regs.mie[11] | regs.mie[9])));

	u4 code;
	always_comb begin
		code = '0;
		if(interruption) begin
			//if(mode == 2'b11) begin //machine
			if(exint) begin
				code = 4'd11;
			end
			else if(swint) begin
				code = 4'd3;
			end
			else if(trint) begin
				code = 4'd7;
			end
			//end
			/*else if(mode == 2'b01) begin //supervisor
				if(exint) begin
					code = 4'd9;
				end
				else if(swint) begin
					code = 4'd1;
				end
				else if(trint) begin
					code = 4'd5;
				end
			end*/
		end
		else code = except.exception_code[3:0];
	end

	always_ff @(posedge clk) begin
		//$display("%x",exception,code);
		if (reset) begin
			regs <= '0;
			regs.mcause[1] <= 1'b1;
			regs.mepc[31] <= 1'b1;
            mode <= 2'b11;
		end 
        else if(~(stall | (pc == 0))) begin
			regs <= regs_nxt;
            mode <= mode_nxt;
		end
	end

	// read
	always_comb begin
		//$display("%x",pc);
		csr_rd = '0;
		unique case(csr_ra)
			CSR_MIE: csr_rd = regs.mie;
			CSR_MIP: csr_rd = regs.mip;
			CSR_MTVEC: csr_rd = regs.mtvec;
			CSR_MSTATUS: csr_rd = regs.mstatus;
			CSR_MSCRATCH: csr_rd = regs.mscratch;
			CSR_MEPC: csr_rd = regs.mepc;
			CSR_MCAUSE: csr_rd = regs.mcause;
			CSR_MCYCLE: csr_rd = regs.mcycle;
			CSR_MTVAL: csr_rd = regs.mtval;
			default: begin
				csr_rd = '0;
			end
		endcase
	end

	// write
	always_comb begin
		regs_nxt = regs;
		regs_nxt.mcycle = regs.mcycle + 1;
		mode_nxt = mode;
		csr_pcselect = '0;
		// Writeback: W stage
		if (interruption) begin
			mode_nxt = 2'b11;
			regs_nxt.mepc = pc;
			csr_pcselect = regs.mtvec;
			regs_nxt.mcause[63] = 1'b1;
			regs_nxt.mcause[62:0] = {{59{1'b0}},code};
			regs_nxt.mstatus.mpie = regs.mstatus.mie;
			regs_nxt.mstatus.mie = 1'b0;
			regs_nxt.mstatus.mpp = mode;
			//if(swint) $display("%x",regs_nxt.mepc);
		end
		else if(exception) begin
			mode_nxt = 2'b11;
			regs_nxt.mepc = pc;
			csr_pcselect = regs.mtvec;
			regs_nxt.mcause[63] = 1'b0;
			regs_nxt.mcause[62:0] = {{59{1'b0}},code};
			regs_nxt.mstatus.mpie = regs.mstatus.mie;
			regs_nxt.mstatus.mie = 1'b0;
			regs_nxt.mstatus.mpp = mode;
		end
		else if (csr_ctrl.wvalid) begin
			unique case(csr_ctrl.wa)
				CSR_MIE: regs_nxt.mie = csr_ctrl.wd;
				CSR_MIP:  regs_nxt.mip = csr_ctrl.wd;
				CSR_MTVEC: regs_nxt.mtvec = csr_ctrl.wd;
				CSR_MSTATUS: regs_nxt.mstatus = csr_ctrl.wd;
				CSR_MSCRATCH: regs_nxt.mscratch = csr_ctrl.wd;
				CSR_MEPC: regs_nxt.mepc = csr_ctrl.wd;
				CSR_MCAUSE: regs_nxt.mcause = csr_ctrl.wd;
				CSR_MCYCLE: regs_nxt.mcycle = csr_ctrl.wd;
				CSR_MTVAL: regs_nxt.mtval = csr_ctrl.wd;
				default: begin
					
				end
			endcase
			regs_nxt.mstatus.sd = regs_nxt.mstatus.fs != 0;
			csr_pcselect = pc + 4;
		end 
        else if (csr_ctrl.is_mret) begin
			csr_pcselect = regs.mepc;
			mode_nxt = regs.mstatus.mpp;
			regs_nxt.mstatus.mie = regs.mstatus.mpie;
			regs_nxt.mstatus.mpie = 1'b1;
			regs_nxt.mstatus.mpp = 2'b00;
			regs_nxt.mstatus.xs = 0;
		end
		else begin end
	end


endmodule
`endif