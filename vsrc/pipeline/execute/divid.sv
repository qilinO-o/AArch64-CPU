`ifndef __DIVID_SV
`define __DIVID_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module divid 
    import common::*; 
	import pipes::*;(
        input addr_t pc,
    input logic clk, resetn, valid,
    input u64 a, b,
    output logic done,
    output u128 c // c = {a % b, a / b}
);
    enum i1 { INIT, DOING } state, state_nxt;
    i67 count, count_nxt;
    localparam DIV_DELAY = {2'b0, 1'b1, 64'b0};
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
                    count_nxt = DIV_DELAY;
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
    u128 p, p_nxt;
    u64 b_nxt;
    u64 b_;
    always_comb begin
        p_nxt = p;
        b_nxt = b_;
        unique case(state)
            INIT: begin
                p_nxt = {64'b0, a};
                b_nxt = b;
            end
            DOING: begin
                p_nxt = {p_nxt[126:0], 1'b0};
                if (p_nxt[127:64] >= b_nxt) begin
                    p_nxt[127:64] -= b_nxt;
                    p_nxt[0] = 1'b1;
                end
            end
        endcase
        //$display("%x %x %x",pc,b_nxt,p);
    end
    always_ff @(posedge clk) begin
        if (~resetn) begin
            p <= '0;
        end else begin
            p <= p_nxt;
            b_ <= b_nxt;
        end
    end
    assign c = p;
endmodule

`endif