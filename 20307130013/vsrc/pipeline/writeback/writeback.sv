`ifndef __WRITEBACK_SV
`define __WRITEBACK_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif
//writeback
module writeback 
	import common::*;
    import pipes::*;
    (
    input memory_data_t dataM,
    output writeback_data_t dataW
);
    always_comb
    begin
        unique case(dataM.memtoreg)
            1'b1: begin
                dataW.resultw=dataM.readdata;
            end
            1'b0: begin
                dataW.resultw=dataM.aluout;
            end
            default: begin

            end
        endcase
    end

    assign dataW.instr=dataM.instr;
    assign dataW.pc=dataM.pc;
    assign dataW.regwrite=dataM.regwrite;
    assign dataW.memread=dataM.memread;
    assign dataW.memwrite=dataM.memwrite;
    assign dataW.aluout=dataM.aluout;
    assign dataW.dst=dataM.dst;
    assign dataW.valid=dataM.valid;
endmodule
`endif