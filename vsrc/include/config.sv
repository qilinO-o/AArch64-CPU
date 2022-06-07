`ifndef CONFIG_SV
`define CONFIG_SV

package config_pkg;
	// parameters
	parameter AREG_READ_PORTS = 1;
	parameter AREG_WRITE_PORTS = 1;
	parameter USE_CACHE = 1'b1;
	parameter USE_ICACHE = 1'b1;
	parameter USE_DCACHE = 1'b1;
	parameter ADD_LATENCY = 1'b1;
	parameter AXI_BURST_NUM = 16;
	parameter ICACHE_BITS = 3;
	parameter DCACHE_BITS = 3;
endpackage

`endif
