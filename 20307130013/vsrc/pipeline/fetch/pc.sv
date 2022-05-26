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
	input logic clk, reset,
	input offset_en, //enable jump offset
    input u64 offset, //32 bit imm for instr ext
    input ibus_resp_t iresp,
    output addr_t temp_pc,
	output fetch_data_t dataF
);
    addr_t addr;
    addr_t addr_nxt;
    always_comb
    begin
        if(en==1'b1) begin
            if(offset_en==1'b1) begin
                addr_nxt=offset;
            end
            else begin
                addr_nxt=addr+4;
            end 
        end
        else begin
            addr_nxt=addr;
        end
    end
    always_ff@(posedge clk )//, posedge reset)
    begin
        if(reset) begin
            addr<=64'h8000_0000;
        end
        else if(en) begin
            addr<=addr_nxt;
        end
    end
    assign dataF.instr=iresp.data;
    assign dataF.valid=1;
    assign dataF.pc=addr;
    assign temp_pc=addr;
endmodule
`endif