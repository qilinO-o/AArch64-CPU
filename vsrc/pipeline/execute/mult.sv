`ifndef __MULT_SV
`define __MULT_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module mult 
    import common::*; 
	import pipes::*;(
    input logic clk, resetn, valid,
    input u64 a, b,
    output logic done, // 握手信号，done 上升沿时的输出是有效的
    output u64 c // c = a * b
);
    enum u1 { INIT, DOING } state, state_nxt;
    i67 count, count_nxt;
    localparam MULT_DELAY = {2'b0, 1'b1, 64'b0};
    always_ff @(posedge clk) begin
        if (~resetn) begin
            {state, count} <= '0;
        end else begin
            {state, count} <= {state_nxt, count_nxt};
        end
    end
    assign done = (state_nxt == INIT);
    always_comb begin
        {state_nxt, count_nxt} = {state, count}; // default
        unique case(state)
            INIT: begin
                if (valid) begin
                    state_nxt = DOING;
                    count_nxt = MULT_DELAY;
                end
            end
            DOING: begin
                count_nxt = {1'b0, count_nxt[66:1]};
                if (count_nxt == '0) begin
                    state_nxt = INIT;
                end
            end
        endcase
    end
    logic[128:0] p, p_nxt;
    u64 b_nxt;
    u64 b_;
    always_comb begin
        p_nxt = p;
        b_nxt = b_;
        unique case(state)
            INIT: begin
                p_nxt = {65'b0, a};
                b_nxt = b;
            end
            DOING: begin
                if (p_nxt[0]) begin
                    p_nxt[128:64] = p_nxt[127:64] + b_nxt;
            	end
            	p_nxt = {1'b0, p_nxt[128:1]};
            end
        endcase
    end
    always_ff @(posedge clk) begin
        if (~resetn) begin
            p <= '0;
        end else begin
            p <= p_nxt;
            b_ <= b_nxt;
        end
    end
    assign c = p[63:0];
endmodule

`endif
