`ifndef __MEMWR_REG_SV
`define __MEMWR_REG_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif
//Mem/Wr reg
module MEMWR_reg 
	import common::*;
    import pipes::*;
    (
    input logic clk,rst,clr,
    input memory_data_t dataM,
    output memory_data_t dataM_nxt
);
    always_ff@(posedge clk )//or posedge rst)
    begin
        if(rst | clr) dataM_nxt<='0;
        else dataM_nxt<=dataM;
    end

endmodule
`endif