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
    //input u1 flush_all,
    input execute_data_t dataE,
    output execute_data_t dataE_nxt
);
    always_ff@(posedge clk )//or posedge rst)
    begin
        if(rst) begin
            dataE_nxt<='0;
        end
        else begin
            if(en==1'b1) begin
                if(clr) dataE_nxt<='0;
                else dataE_nxt<=dataE;
            end
            else begin end
        end
    end

endmodule
`endif