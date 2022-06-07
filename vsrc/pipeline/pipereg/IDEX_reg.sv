`ifndef __IDEX_REG_SV
`define __IDEX_REG_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif
//ID/Ex reg
module IDEX_reg 
	import common::*;
    import pipes::*;
    (
    input u1 en,
    input logic clk,rst,clr,
    //input u1 flush_all,
    input decode_data_t dataD,
    output decode_data_t dataD_nxt
);
    always_ff@(posedge clk )//or posedge rst)
    begin
        if(rst) begin
            dataD_nxt<='0;
        end
        else begin
            if(en==1'b1) begin
                if(clr) dataD_nxt<='0;
                else dataD_nxt<=dataD;
            end
            else begin end
        end
    end

endmodule
`endif