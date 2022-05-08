`ifndef __IFID_REG_SV
`define __IFID_REG_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif
//IF/ID reg
module IFID_reg 
	import common::*;
    import pipes::*;
    (
    input u1 en,
    input logic clk,rst,clr,flush,
    input fetch_data_t dataF,
    output fetch_data_t dataF_nxt
);
    always_ff@(posedge clk )//or posedge rst)// or posedge clr)
    begin
        if(en==1'b1) begin
            if(rst | clr | flush) dataF_nxt<='0;
            else dataF_nxt<=dataF;
        end
        else begin
            //dataF_nxt<='0;
        end
    end

endmodule
`endif