`timescale 1ns/1ps
`default_nettype none

module cache_wrap #
  (
    parameter  C_M_AXI_THREAD_ID_WIDTH       = 1,
    parameter  C_M_AXI_ADDR_WIDTH            = 27, //address_width
    parameter  C_M_AXI_DATA_WIDTH            = 32, //data

    parameter  C_M_AXI_BURST_LEN = 1,

    parameter  CORE_ADDR_WIDTH = 32,
    parameter  CORE_DATA_WIDTH = 32
   )
  (
    // System Signals
    input wire 	      ACLK,
    input wire 	      ARESETN,

    //core interface axi4litelite
  //inst
    input wire [CORE_ADDR_WIDTH-1:0] 	     pc,
    input wire                               pc_flag,
    output wire [CORE_DATA_WIDTH-1:0] 	     instruction,

	//AR
	input wire [CORE_ADDR_WIDTH-1:0] 	     core_ARADDR,
	input wire 				 			     core_ARVALID,

    //R
	output wire [CORE_DATA_WIDTH-1:0] 	     core_RDATA,
    output wire 				 			 core_RVALID,

    //AW
	input wire [CORE_ADDR_WIDTH-1:0]         core_AWADDR,
	input wire 				 			     core_AWVALID,

    //W
	input wire [CORE_DATA_WIDTH-1:0] 	     core_WDATA,

    //B
    output wire 				    	     core_BVALID
    );

    cache
  #(C_M_AXI_THREAD_ID_WIDTH,C_M_AXI_ADDR_WIDTH,C_M_AXI_DATA_WIDTH,
  C_M_AXI_BURST_LEN,CORE_ADDR_WIDTH,CORE_DATA_WIDTH) 
  cache1 (
    .ACLK     (ACLK),
    .ARESETN      (ARESETN),
    .pc (pc),
    .pc_flag (pc_flag),
    .instruction (instruction),
    .core_ARADDR      (core_ARADDR),
    .core_ARVALID (core_ARVALID),
    .core_RDATA           (core_RDATA),
    .core_RVALID         (core_RVALID),
    .core_AWADDR      (core_AWADDR),
    .core_AWVALID      (core_AWVALID),
    .core_WDATA (core_WDATA),
    .core_BVALID       (core_BVALID)
  );

endmodule

`default_nettype wire