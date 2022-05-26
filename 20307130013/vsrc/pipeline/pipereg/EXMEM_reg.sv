`ifndef __EXMEM_REG_SV
`define __EXMEM_REG_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif
//Ex/Mem reg
module EXMEM_reg 
	import common::*;
    import pipes::*;
    (
    input u1 en,
    input logic clk,rst,clr,
    input execute_data_t dataE,
    output execute_data_t dataE_nxt
);
    always_ff@(posedge clk )//or posedge rst)
    begin
        if(en==1'b1) begin
            if(rst | clr) dataE_nxt<='0;
            else dataE_nxt<=dataE;
        end
        else begin

        end
    end

endmodule
`endif