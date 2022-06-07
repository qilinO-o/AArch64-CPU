`ifndef __PC_SV
`define __PC_SV
`ifdef VERILATOR
`include "include/common.sv"
`else

`endif
module pc 
	import common::*;
    import pipes::*;
    (
    input u1 en,
	input logic clk, reset, flush,
    input u64 pcselect,
	input logic branch, //enable jump offset
    input u64 pcbranch, //32 bit imm for instr ext
    input ibus_resp_t iresp,
    output ibus_req_t ireq,
	output fetch_data_t dataF
);
    addr_t pc;
    addr_t pc_nxt;
    
    always_ff@(posedge clk )//, posedge reset)
    begin
        if(reset) begin
            pc <= 64'h8000_0000;
        end
        else if(en | flush) begin
            pc <= pc_nxt;
        end
    end

    always_comb begin
        if(flush) begin
            pc_nxt = pcselect;
        end
        else if(branch) begin
            pc_nxt = pcbranch;
        end
        else begin
            pc_nxt = pc + 4;
        end 
    end

    always_comb begin
        dataF.except = '0;
        ireq.valid = 1'b1;
        if(pc[0] | pc[1]) begin
            ireq.valid = 1'b0;
            dataF.except.exception = 1'b1;
            dataF.except.exception_code = 5'd0;
        end
        //if(pc <= 64'h80000750)$display("%x %x",pc,en);
    end

    assign dataF.instr = iresp.data;
    assign dataF.valid = ireq.valid;
    assign dataF.pc = pc;
    assign ireq.addr = pc;
    
endmodule
`endif