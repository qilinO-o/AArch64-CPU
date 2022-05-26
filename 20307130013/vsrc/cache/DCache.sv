`ifndef __DCACHE_SV
`define __DCACHE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "ram/RAM_SinglePort.sv"
/* You should not add any additional includes in this file */
`endif

module DCache 
	import common::*; #(
		/* You can modify this part to support more parameters */
		/* e.g. OFFSET_BITS, INDEX_BITS, TAG_BITS */
		//parameter X = 1;
        localparam WORDS_PER_LINE = 16,
        localparam ASSOCIATIVITY = 2,
        localparam SET_NUM = 8,
        localparam OFFSET_BITS = $clog2(WORDS_PER_LINE), //4
        localparam INDEX_BITS = $clog2(SET_NUM), //3
        localparam POSITION_BITS = $clog2(ASSOCIATIVITY),
        localparam TAG_BITS = 64 - INDEX_BITS - OFFSET_BITS - 3, /* Maybe 32, or
        smaller */
        localparam type offset_t = logic [OFFSET_BITS-1:0],
        localparam type index_t = logic [INDEX_BITS-1:0],
        localparam type tag_t = logic [TAG_BITS-1:0],
        localparam type position_t = logic [POSITION_BITS-1:0],
        localparam type state_t = enum logic[2:0] {
            IDLE, COMPARE_TAG, ALLOCATE, WRITE_BACK, SKIP, FLUSH
        }
	)(
	input logic clk, reset,

	input  dbus_req_t  dreq,
    output dbus_resp_t dresp,
    output cbus_req_t  creq,
    input  cbus_resp_t cresp
);

`ifndef REFERENCE_CACHE

	/* TODO: Lab3 Cache */
    //functions of getting addr param
    function offset_t get_offset(addr_t addr);
        return addr[3+OFFSET_BITS-1 : 3];
    endfunction
    function index_t get_index(addr_t addr);
        return addr[3+INDEX_BITS+OFFSET_BITS-1 : OFFSET_BITS+3];
    endfunction
    function tag_t get_tag(addr_t addr);
        return addr[3+INDEX_BITS+OFFSET_BITS+TAG_BITS-1 : 3+INDEX_BITS+OFFSET_BITS];
    endfunction
    
    // registers
    state_t   state; 
    state_t   state_nxt;
    dbus_req_t req;  // dreq is saved once addr_ok is asserted.

    tag_t tag;
    index_t index;
    offset_t offset;
    offset_t offset_cnt;
    
    //meta_type
    typedef struct packed {
        u1 valid;
        u1 dirty;
        tag_t tag;
        position_t age;
    } meta_t;

    typedef meta_t[ASSOCIATIVITY-1:0] meta_set_t;
    typedef position_t[ASSOCIATIVITY-1:0] age_set_t;
    typedef struct packed {
        logic    en;
        strobe_t strobe;
        word_t   wdata;
    } ram_data_t;
    typedef struct packed {
        logic    en;
        logic strobe;
        meta_set_t   wmeta;
    } ram_meta_t;
    typedef struct packed {
        logic    en;
        age_set_t   wage;
    } ram_age_t;
    ram_data_t ram_data;
    ram_meta_t ram_meta;
    ram_age_t  ram_age;

    position_t meta_age[SET_NUM-1:0][ASSOCIATIVITY-1:0];
    
    meta_set_t ram_rmeta;
    word_t ram_rdata;
    age_set_t ram_rage;

    logic[INDEX_BITS - 1:0] meta_addr;
    logic[INDEX_BITS+POSITION_BITS+OFFSET_BITS-1:0] data_addr;
    RAM_SinglePort #(
        .ADDR_WIDTH(INDEX_BITS+POSITION_BITS+OFFSET_BITS),
        .DATA_WIDTH(64),
        .BYTE_WIDTH(8),
        .MEM_TYPE(0),
        .READ_LATENCY(0)
    ) data_ram (
        .clk(clk), .en(ram_data.en),
        .addr(data_addr),  
        .strobe(ram_data.strobe),
        .wdata(ram_data.wdata),
        .rdata(ram_rdata)
    );
    RAM_SinglePort #(
        .ADDR_WIDTH(INDEX_BITS),
        .DATA_WIDTH($bits(meta_t) * ASSOCIATIVITY),
        .BYTE_WIDTH($bits(meta_t) * ASSOCIATIVITY),
        .MEM_TYPE(0),
        .READ_LATENCY(0)
    ) meta_ram (
        .clk(clk), .en(ram_meta.en),
        .addr(meta_addr),
        .strobe(ram_meta.strobe),
        .wdata(ram_meta.wmeta),
        .rdata(ram_rmeta)
    );
    RAM_SinglePort #(
        .ADDR_WIDTH(INDEX_BITS),
        .DATA_WIDTH(POSITION_BITS * ASSOCIATIVITY),
        .BYTE_WIDTH(POSITION_BITS * ASSOCIATIVITY),
        .MEM_TYPE(0),
        .READ_LATENCY(0)
    ) meta_age_ram (
        .clk(clk), .en(ram_age.en | reset),
        .addr(meta_addr),
        .strobe(1'b1),
        .wdata(ram_age.wage & {(POSITION_BITS*ASSOCIATIVITY){~reset}}),
        .rdata(ram_rage)
    );

    // get the param from addr request from pipeline core
    assign tag = get_tag(dreq.addr);
    assign offset = get_offset(dreq.addr);
    assign index = get_index(dreq.addr);
    //search from the meta
    position_t position;
    u1 hit;
    always_comb     
    begin
        position = '0;
        hit = 1'b0;
        ram_age = '0;
        for(int i = 0; i < ASSOCIATIVITY; i++) begin
            if (ram_rmeta[i].valid & ram_rmeta[i].tag == tag) begin
                position = i[POSITION_BITS-1:0];
                hit = 1'b1;
            end
        end
        // if (ram_rmeta[0].valid & ram_rmeta[0].tag == tag) begin
        //     position = 1'b0;
        //     hit = 1'b1;
        // end
        // else if(ram_rmeta[1].valid & ram_rmeta[1].tag == tag) begin
        //     position = 1'b1;
        //     hit = 1'b1;
        // end
        if(~hit) begin
            for(int i = 0; i < ASSOCIATIVITY; i++) begin
                if(~ram_rmeta[i].valid | ram_rage[i] == '1) begin
                    position = i[POSITION_BITS-1:0];
                end
            end
        end
        else begin
            ram_age.en = 1'b1;
            for(int i = 0; i < ASSOCIATIVITY; i++) begin
                if(ram_rage[i] <= ram_rage[position]) begin
                    ram_age.wage[i] = ram_rage[i] + 1;
                end
                else begin
                    ram_age.wage[i] = ram_rage[i];
                end
            end
            ram_age.wage[position] = '0;
        end
        
    end
    
    //ram driver
    //TODO:
    //DBus driver
    assign dresp.addr_ok = state == IDLE;
    assign dresp.data_ok = (state == IDLE & hit) | (state == SKIP & cresp.last);

    // CBus driver
    assign creq.valid    = state == ALLOCATE | state == WRITE_BACK | state == SKIP;
    assign creq.is_write = state == WRITE_BACK | (state == SKIP & dreq.strobe != 8'b0000_0000);
    assign creq.size     = state == SKIP ? dreq.size : MSIZE8;
    assign creq.strobe   = state == SKIP ? dreq.strobe : 8'b11111111;
    assign creq.len      = state == SKIP ? MLEN1 : MLEN16;
	assign creq.burst	 = state == SKIP ? AXI_BURST_FIXED :AXI_BURST_INCR;

    always_comb
    begin
        creq.addr = '0;
        dresp.data = ram_rdata;
        creq.data = ram_rdata;
        meta_addr = index;
        data_addr = {index, position, offset};
        ram_data = '0;
        ram_meta = '0;
        unique case (state)
            FLUSH: begin
                ram_meta.en = 1'b1;
                ram_meta.wmeta = '0;
                ram_meta.strobe = 1'b1;
                meta_addr = offset_cnt[INDEX_BITS - 1:0];
            end
            // IDLE: begin

            // end
            IDLE: begin
                if(hit & (dreq.strobe != 8'b0000_0000)) begin
                    ram_data.en = 1'b1;
                    ram_data.strobe = dreq.strobe;
                    ram_data.wdata = dreq.data;
                    ram_meta.en = 1'b1;
                    ram_meta.strobe = 1'b1;
                    ram_meta.wmeta = ram_rmeta;
                    ram_meta.wmeta[position].dirty = 1'b1;
                end
            end
            ALLOCATE: begin // read new data from mem to cache
                creq.addr = {tag,index,{(OFFSET_BITS+3){1'b0}}};
                ram_data.en = 1'b1;
                ram_data.strobe = 8'b1111_1111;
                ram_data.wdata = cresp.data;
                ram_meta.en = 1'b1;
                ram_meta.strobe = 1'b1;
                ram_meta.wmeta = ram_rmeta;
                ram_meta.wmeta[position].valid = 1'b1;
                ram_meta.wmeta[position].dirty = 1'b0;
                ram_meta.wmeta[position].tag = tag;
                data_addr = {index, position, offset_cnt};
            end
            WRITE_BACK: begin //write data from cache to mem
                creq.addr = {ram_rmeta[position].tag,index,{(OFFSET_BITS+3){1'b0}}};
                creq.data = ram_rdata;
                data_addr = {index, position, offset_cnt};
            end
            SKIP: begin
                creq.addr = dreq.addr;
                dresp.data = cresp.data;
                creq.data = dreq.data;
            end
            default: begin
                
            end
        endcase
    end

    // the finite-state-machine of cache state
    always_ff @(posedge clk)
    begin
        if (~reset) begin
            unique case (state)
                FLUSH: begin
                    state <= IDLE;
                end
                IDLE: begin
                    if (dreq.valid) begin
                        if(~dreq.addr[31]) begin
                            state <= SKIP;
                        end
                        else begin
                            if(hit) begin
                                state <= IDLE;
                            end
                            else begin
                                if(ram_rmeta[position].valid & ram_rmeta[position].dirty) begin
                                    offset_cnt <= '0;
                                    state <= WRITE_BACK;
                                end
                                else begin
                                    offset_cnt <= '0;
                                    state <= ALLOCATE;
                                end
                            end
                        end
                    end
                    else begin
                        state <= IDLE;
                    end    
                end 
                // COMPARE_TAG: begin
                //     if(hit) begin
                //         state <= IDLE;
                //     end
                //     else begin
                //         if(ram_rmeta[position].valid & ram_rmeta[position].dirty) begin
                //             offset_cnt <= '0;
                //             state <= WRITE_BACK;
                //         end
                //         else begin
                //             offset_cnt <= '0;
                //             state <= ALLOCATE;
                //         end
                //     end
                // end
                ALLOCATE: begin // read new data from mem to cache
                    if (cresp.ready) begin
                        state  <= cresp.last ? COMPARE_TAG : ALLOCATE;
                        offset_cnt <= offset_cnt + 1;
                    end
                end
                WRITE_BACK: begin //write data from cache to mem
                    if (cresp.ready) begin
                        state  <= cresp.last ? ALLOCATE : WRITE_BACK;
                        offset_cnt <= offset_cnt + 1;
                    end
                end
                SKIP: begin
                    if(cresp.last) begin
                        state <= IDLE;
                    end
                    else begin
                        state <= SKIP;
                    end
                end
                default: begin
                    state <= IDLE;
                end
            endcase
        end 
        else begin
            state <= FLUSH;
            offset_cnt <= offset_cnt + 1;
        end
    end



/*----------------------------------------------------------------*/
`else

	typedef enum u2 {
		IDLE,
		FETCH,
		READY,
		FLUSH
	} state_t /* verilator public */;

	// typedefs
    typedef union packed {
        word_t data;
        u8 [7:0] lanes;
    } view_t;

    typedef u4 offset_t;

    // registers
    state_t    state /* verilator public_flat_rd */;
    dbus_req_t req;  // dreq is saved once addr_ok is asserted.
    offset_t   offset;

    // wires
    offset_t start;
    assign start = dreq.addr[6:3];

    // the RAM
    struct packed {
        logic    en;
        strobe_t strobe;
        word_t   wdata;
    } ram;
    word_t ram_rdata;

    always_comb
    unique case (state)
    FETCH: begin
        ram.en     = 1;
        ram.strobe = 8'b11111111;
        ram.wdata  = cresp.data;
    end

    READY: begin
        ram.en     = 1;
        ram.strobe = req.strobe;
        ram.wdata  = req.data;
    end

    default: ram = '0;
    endcase

    RAM_SinglePort #(
		.ADDR_WIDTH(4),
		.DATA_WIDTH(64),
		.BYTE_WIDTH(8),
		.READ_LATENCY(0)
	) ram_inst (
        .clk(clk), .en(ram.en),
        .addr(offset),
        .strobe(ram.strobe),
        .wdata(ram.wdata),
        .rdata(ram_rdata)
    );

    // DBus driver
    assign dresp.addr_ok = state == IDLE;
    assign dresp.data_ok = state == READY;
    assign dresp.data    = ram_rdata;

    // CBus driver
    assign creq.valid    = state == FETCH || state == FLUSH;
    assign creq.is_write = state == FLUSH;
    assign creq.size     = MSIZE8;
    assign creq.addr     = req.addr;
    assign creq.strobe   = 8'b11111111;
    assign creq.data     = ram_rdata;
    assign creq.len      = MLEN16;
	assign creq.burst	 = AXI_BURST_INCR;

    // the FSM
    always_ff @(posedge clk)
    if (~reset) begin
        unique case (state)
        IDLE: if (dreq.valid) begin
            state  <= FETCH;
            req    <= dreq;
            offset <= start;
        end

        FETCH: if (cresp.ready) begin
            state  <= cresp.last ? READY : FETCH;
            offset <= offset + 1;
        end

        READY: begin
            state  <= (|req.strobe) ? FLUSH : IDLE;
        end

        FLUSH: if (cresp.ready) begin
            state  <= cresp.last ? IDLE : FLUSH;
            offset <= offset + 1;
        end

        endcase
    end else begin
        state <= IDLE;
        {req, offset} <= '0;
    end

`endif

endmodule

`endif
