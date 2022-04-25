`timescale  1ns/1ps
`default_nettype none

module cpu_wrap(
    input wire clk,
    input wire rst,
    input wire empty,
    input wire [7:0] uart_in,
    input wire [31:0] instruction,
    output wire [7:0] uart_out,
    output wire uart_ok_in,
    output wire uart_ready_out,
    output wire [31:0] next_pc,
    output wire [15:0] led,
    output wire pc_flag,
    //AR
	output wire [31:0] core_ARADDR,
	output wire 	   core_ARVALID,

    //R
	input wire [31:0] core_RDATA,
    input wire        core_RVALID,

    //AW
	output wire [31:0] core_AWADDR,
	output wire        core_AWVALID,

    //W
	output wire [31:0] core_WDATA,

    //B
    input wire core_BVALID
);
    
    cpu cpu(clk, rst, empty, uart_in, instruction, uart_out, uart_ok_in, uart_ready_out, next_pc, led, pc_flag,
            core_ARADDR, core_ARVALID, core_RDATA, core_RVALID, core_AWADDR, core_AWVALID, core_WDATA, core_BVALID);
endmodule

`default_nettype wire