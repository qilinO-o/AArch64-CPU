`ifndef __MEMORY_SV
`define __MEMORY_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/memory/readdata.sv"
`include "pipeline/memory/writedata.sv"
`else

`endif
//memory
module memory 
	import common::*;
    import pipes::*;
    (
    input execute_data_t dataE,
    output dbus_req_t  dreq,
	input  dbus_resp_t dresp,
    output memory_data_t dataM
);
    strobe_t strobe_temp;
    u3 addr;
    word_t wd;

    assign addr = dataE.aluout[2:0];
    assign dreq.valid= dataE.memread | dataE.memwrite | dataE.memtoreg;
    assign dreq.addr=dataE.aluout;
    always_comb
    begin
        //$display("^***%x***^", dresp.data);
        dreq.strobe=8'b0000_0000;
        dreq.data='0;
        if(dataE.memwrite) begin
            dreq.strobe=strobe_temp;
            dreq.data=wd;
        end  
        if(dataE.memtoreg) dreq.strobe=8'b0000_0000;
    end

    
    readdata readdata(
        ._rd(dresp.data),
        .rd(dataM.readdata),
        .addr(addr),
        .msize(dataE.msize),
        .mem_unsigned(dataE.mem_unsigned)
    );
    assign dreq.size=dataE.msize;
    writedata writedata(
        .addr(addr),
        ._wd(dataE.writedata),
        .msize(dataE.msize),
        .wd(wd),
        .strobe(strobe_temp)
    );
    
    assign dataM.instr=dataE.instr;
    assign dataM.pc=dataE.pc;
    assign dataM.regwrite=dataE.regwrite;
    assign dataM.memread=dataE.memread;
    assign dataM.memwrite=dataE.memwrite;
    assign dataM.memtoreg=dataE.memtoreg;
    assign dataM.aluout=dataE.aluout;
    assign dataM.dst=dataE.dst;
    assign dataM.valid=dataE.valid;
endmodule
`endif