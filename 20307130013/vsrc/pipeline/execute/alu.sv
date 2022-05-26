`ifndef __ALU_SV
`define __ALU_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/execute/mult.sv"
`include "pipeline/execute/divid.sv"
`else

`endif

module alu
	import common::*; 
	import pipes::*;(
	input addr_t pc,
	input logic clk, reset,
	input u64 a, b,
	input alufunc_t alufunc,
	output u64 c,
	output u1 stallE_mult
);
	u1 MUL_valid;
	u1 DIV_valid;
	u1 MUL_done;
	u1 DIV_done;
	u64 MUL_c;
	u128 DIV_c;
	u64 absa;
	u64 absb;

	assign stallE_mult = (MUL_valid & ~MUL_done) | (DIV_valid & ~DIV_done);

	always_comb begin
		c = '0;
		MUL_valid = '0;
		DIV_valid = '0;
		absa = a;
		absb = b;
		unique case(alufunc)
			ALU_ADD:  	c = a + b;
			ALU_SUB:  	c = a - b;
			ALU_XOR:  	c = a ^ b;
			ALU_OR :  	c = a | b;
			ALU_AND:	c = a & b;
			ALU_MUL:	begin
							MUL_valid = 1;
							c = MUL_c;
						end
			ALU_DIV:	begin
							if($signed(a) < 0) absa = ~a + 1'b1;
							if($signed(b) < 0) begin
								DIV_valid = 1;
								absb = ~b + 1'b1;
							end 
							else if ($signed(b) > 0) begin
								DIV_valid = 1;
							end
							else begin//b==0
								DIV_valid = 0;
							end
							if(DIV_valid) c = (a[63] ^ b[63])?(~DIV_c[63:0]+1'b1):DIV_c[63:0];
							else c = '1;
						end
			ALU_DIVU:   begin
							if(b == '0) DIV_valid = 0;
							else DIV_valid = 1;
							if(DIV_valid) c = DIV_c[63:0];
							else c = '1;
						end
			ALU_REM:	begin
							if($signed(a) < 0) absa = ~a + 1'b1;
							if($signed(b) < 0) begin
								DIV_valid = 1;
								absb = ~b + 1'b1;
							end 
							else if ($signed(b) > 0) begin
								DIV_valid = 1;
							end
							else begin
								DIV_valid = 0;
							end
							if(DIV_valid) c = (a[63])?(~DIV_c[127:64]+1'b1):DIV_c[127:64];
							else c = a;
						end
			ALU_REMU: 	begin
							if(b == '0) DIV_valid = 0;
							else DIV_valid = 1;
							if(DIV_valid) c = DIV_c[127:64];
							else c = a;
						end
			ALU_MULW:	begin
							MUL_valid = 1;
							c = MUL_c;
							c = {{32{c[31]}},c[31:0]};
						end
	 		ALU_DIVW:	begin
				 			if($signed(a[31:0]) < 0) absa = {32'b0, ~a[31:0] + 1'b1};
							else absa = {32'b0, a[31:0]};
							if($signed(b[31:0]) < 0) begin
								absb = {32'b0, ~b[31:0] + 1'b1};
								DIV_valid = 1;
							end 
							else if ($signed(b[31:0]) > 0) begin
								absb = {32'b0, b[31:0]};
								DIV_valid = 1;
							end
							else begin
								DIV_valid = 0;
							end
							if(DIV_valid) begin
								c[31:0] = (a[31] ^ b[31])?(~DIV_c[31:0]+1'b1):DIV_c[31:0];
							end
							else begin
								c='1;
							end
							
							
							c = {{32{c[31]}},c[31:0]};
							 //$display("%x %x %x",pc,a,b);
			 			end
			ALU_DIVUW:	begin
							absa = {32'b0, a[31:0]};
							absb = {32'b0, b[31:0]};
							if(b == '0) DIV_valid = 0;
							else DIV_valid = 1;
							if(DIV_valid) c[31:0] = DIV_c[31:0];
							else c = '1;
							c = {{32{c[31]}},c[31:0]};
						end
			ALU_REMW:	begin
							if($signed(a[31:0]) < 0) absa = {32'b0, ~a[31:0] + 1'b1};
							else absa = {32'b0, a[31:0]};
							if($signed(b[31:0]) < 0) begin
								absb = {32'b0, ~b[31:0] + 1'b1};
								DIV_valid = 1;
							end 
							else if ($signed(b[31:0]) > 0) begin
								absb = {32'b0, b[31:0]};
								DIV_valid = 1;
							end
							else begin
								DIV_valid = 0;
							end
							if(DIV_valid) c[31:0] = (a[31])?(~DIV_c[95:64]+1'b1):DIV_c[95:64];
							else c[31:0] = a[31:0];
							c = {{32{c[31]}},c[31:0]};
						end
			ALU_REMUW:	begin
							absa = {32'b0, a[31:0]};
							absb = {32'b0, b[31:0]};
							if(b == '0) DIV_valid = 0;
							else DIV_valid = 1;
							if(DIV_valid) c[31:0] = DIV_c[95:64];
							else c[31:0] = a[31:0];
							c = {{32{c[31]}},c[31:0]};
						end

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

	mult mult(
		clk,
		MUL_valid,
		MUL_valid,
		a,
		b,
		MUL_done,
		MUL_c
	);

	divid divid(
		pc,
		clk,
		DIV_valid,
		DIV_valid,
		absa,
		absb,
		DIV_done,
		DIV_c
	);

	
endmodule

`endif
