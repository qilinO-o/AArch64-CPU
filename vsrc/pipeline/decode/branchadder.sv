`ifndef __BRANCHADDER_SV
`define __BRANCHADDER_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif
//get pcbranch
module branchadder
	import common::*;
    import pipes::*;
    (
	input decode_op_t op_t,
    input word_t srca,
    input u64 ext_imm,
    input addr_t pc,
    
    output addr_t pcbranch
);
    always_comb begin
        unique case(op_t)
            JAL: begin
                pcbranch = pc + ext_imm;
            end
            BEQ: begin
                pcbranch = pc + ext_imm;
            end
            JALR: begin
                pcbranch = (srca + ext_imm)& ~1;
            end    
            default:begin
                pcbranch = '0;
            end
        endcase
    end


endmodule
`endif