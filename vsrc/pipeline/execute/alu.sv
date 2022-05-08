`ifndef __ALU_SV
`define __ALU_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module alu
	import common::*; 
	import pipes::*;(
	input u64 a, b,
	input alufunc_t alufunc,
	output u64 c
);
	always_comb begin
		c = '0;
		unique case(alufunc)
			ALU_ADD:  	c = a + b;
			ALU_SUB:  	c = a - b;
			ALU_XOR:  	c = a ^ b;
			ALU_OR :  	c = a | b;
			ALU_AND:	c = a & b;
			ALU_SLTI: 	c[0] = $signed(a) < $signed(b);
			ALU_SLTIU:	c[0] = a < b;
			ALU_SLLI:	c = a << b[5:0];
			ALU_SRLI:	c = a >> b[5:0];
			ALU_SRAI:	c = $signed(a) >>> b[5:0];
			ALU_ADDW:	begin c = a + b;c={{32{c[31]}},c[31:0]}; end
			ALU_SUBW:	begin c = a - b;c={{32{c[31]}},c[31:0]}; end
			ALU_SLLW:	begin c[31:0] = a[31:0] << b[4:0];c={{32{c[31]}},c[31:0]}; end
			ALU_SRLW:	begin c[31:0] = a[31:0] >> b[4:0];c={{32{c[31]}},c[31:0]}; end
			ALU_SRAW:	begin c[31:0] = $signed(a[31:0]) >>> b[4:0];c={{32{c[31]}},c[31:0]}; end
			default: begin
				c = b;
			end
		endcase
	end
	
endmodule

`endif
