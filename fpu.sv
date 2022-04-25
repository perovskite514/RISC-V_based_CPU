`timescale 1ns/1ps
`default_nettype none

module fpu(
    input wire clk, 
    input wire rst,
    input wire [31:0] x1,
    input wire [31:0] x2,
    input wire fadds, fsubs, fmuls, fdivs, feqs, flts, fles, fsqrts, fsgnjs, fsgnjxs, fsgnjns, fcvtwss,
    output logic [31:0] y,
    output logic ovf,
    output logic exception
);

    logic [31:0] fadd_s_res;
    logic fadd_ovf; 
    logic [31:0] fsub_s_res;
    logic fsub_ovf;
    logic [31:0] fmul_s_res;
    logic fmul_ovf;
    logic [31:0] fdiv_s_res;
    logic fdiv_ovf;
    logic [31:0] fsqrt_s_res;
    logic fsqrt_exception;
    logic feq_s_res;
    logic feq_exception;
    logic flt_s_res;
    logic fle_s_res;
    logic [31:0] fcvtws_s_res;
    logic fcvtws_exception;
    
    fadd fadd(x1, x2, fadd_s_res, fadd_ovf);
    fsub fsub(x1, x2, fsub_s_res, fsub_ovf);
    fmul fmul(x1, x2, fmul_s_res, fmul_ovf);
    fdiv fdiv(x1, x2, fdiv_s_res, fdiv_ovf);
    fsqrt fsqrt(x1, fsqrt_s_res, fsqrt_exception);
    feq feq(x1, x2, feq_s_res, feq_exception);
    flt flt(x1, x2, flt_s_res);
    fle fle(x1, x2, fle_s_res);
    fcvtws fcvtws(x1, fcvtws_s_res, fcvtws_exception);
    
    assign y = fadds  ? fadd_s_res :
               fsubs  ? fsub_s_res :
               fmuls  ? fmul_s_res :
               fdivs  ? fdiv_s_res :
               fsqrts ? fsqrt_s_res :
               feqs   ? feq_s_res :
               flts   ? flt_s_res :
               fles   ? fle_s_res : 
               fcvtwss ? fcvtws_s_res :
               fsgnjs  ? {x2[31], x1[30:0]} :
               fsgnjxs ? {x1[31] ^ x2[31], x1[30:0]} :
               fsgnjns ? {~x2[31], x1[30:0]} : 0; 
    
    assign ovf = fadds ? fadd_ovf :
                 fsubs ? fsub_ovf :
                 fmuls ? fmul_ovf :
                 fdivs ? fdiv_ovf : 0;
    
    assign exception = feqs   ? feq_exception :
                       fsqrts ? fsqrt_exception :
                       fcvtwss ? fcvtws_exception : 0;
                       
endmodule

`default_nettype wire