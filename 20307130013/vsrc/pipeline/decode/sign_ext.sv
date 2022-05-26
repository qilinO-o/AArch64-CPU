`ifndef __SIGN_EXT_SV
`define __SIGN_EXT_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif
//extend imm 
module sign_ext 
	import common::*;
    import pipes::*;
    (
	input u20 imm,
    input im_ext_t im_ext,
    output u64 ext_imm
);
    always_comb begin
        unique case(im_ext)
            EXT_NULL: begin
                ext_imm=0;
            end
            EXT_ADDI: begin
                ext_imm = {{(64-12){imm[12-1]}},imm[11:0]};
            end//12->64
	        EXT_LUI: begin
                ext_imm = {{(64-20-12){imm[20-1]}},imm,12'b0000_0000_0000};
            end//20->64 left shift 12 with 0
	        EXT_SD: begin
                ext_imm = {{(64-12){imm[12-1]}},imm[11:0]};
            end //ld 12->64
	        EXT_JAL: begin
                ext_imm = {{(64-20-1){imm[20-1]}},imm,1'b0};
            end //20->64 left shift 1 with 0
	        EXT_BEQ: begin
                ext_imm = {{(64-12-1){imm[12-1]}},imm[11:0],1'b0};
            end//12->64 left shift 1 with 0
            default: begin
                ext_imm=0;
            end
        endcase
    end
    //assign ext_imm = {{(64-12){imm[12-1]}},imm};

endmodule
`endif