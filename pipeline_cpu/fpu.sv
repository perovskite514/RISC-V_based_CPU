`timescale 1ns/1ps
`default_nettype none

module fpu(
    input wire clk, 
    input wire rstn,
    input wire [31:0] x1,
    input wire [31:0] x2,
    input wire fpu_in,
    input wire ss3, ss4, ss5, ss6, stall,
    input wire d_fadds, d_fsubs, d_fmuls, d_fdivs, d_feqs, d_flts, d_fles, d_fsqrts, d_fsgnjs, d_fsgnjxs, d_fsgnjns, d_fcvtwss, d_fcvtsws,
    output logic fpu_out,
    output logic [31:0] y
);

    logic [31:0] fadd_s_res;
    logic [31:0] fsub_s_res;
    (* mark_debug = "true" *) logic [31:0] fmul_s_res;
    logic [31:0] fdiv_s_res;
    logic [31:0] fsqrt_s_res;
    logic feq_s_res;
    logic flt_s_res;
    logic fle_s_res;
    logic [31:0] fcvtws_s_res;
    logic [31:0] fcvtsw_s_res;
    
    fadd fadd(x1, x2, clk, rstn, fadd_s_res);
    fsub fsub(x1, x2, clk, rstn, fsub_s_res);
    fmul fmul(x1, x2, clk, rstn, fmul_s_res);
    fdiv fdiv(x1, x2, clk, rstn, fdiv_s_res);
    fsqrt fsqrt(x1, clk, rstn, fsqrt_s_res);
    feq feq(x1, x2, clk, rstn, feq_s_res);
    flt flt(x1, x2, clk, rstn, flt_s_res);
    fle fle(x1, x2, clk, rstn, fle_s_res);
    fcvtws fcvtws(x1, clk, rstn, fcvtws_s_res);
    fcvtsw fcvtsw(x1, clk, rstn, fcvtsw_s_res);
    
    always_ff @ (posedge clk) begin
        if(~rstn) begin
            y <= 0;
        end else begin 
            y <= d_fadds ? fadd_s_res :
                 d_fsubs ? fsub_s_res :
                 d_fmuls ? fmul_s_res :
                 d_fdivs ? fdiv_s_res :
                 d_fsqrts ? fsqrt_s_res :
                 d_feqs ? feq_s_res :
                 d_flts ? flt_s_res :
                 d_fles ? fle_s_res : 
                 d_fcvtwss ? fcvtws_s_res :
                 d_fcvtsws ? fcvtsw_s_res :
                 d_fsgnjs ? {x2[31], x1[30:0]} :
                 d_fsgnjxs ? {x1[31] ^ x2[31], x1[30:0]} :
                 d_fsgnjns ? {~x2[31], x1[30:0]} : 0; 
        end
    end
    
    (* mark_debug = "true" *) logic [2:0] counter;
    always_ff @ (posedge clk) begin
        if(~rstn) begin
            fpu_out <= 0;
            counter <= 0;
        end else begin
            if (~stall) begin
                counter <= 0;
                fpu_out <= 0;
            end else 
            if (fpu_in) begin
                if ((ss5 ? (ss3 ? 0 : 1) : 0) | (ss6 ? (ss4 ? 0 : 1) : 0)) begin
                //if (s3 | s4) begin
                    counter <= counter + 1;
                end else if ((counter >= 5) & d_fdivs) begin
                    fpu_out <= 1;
                    counter <= -1;
                end else if ((counter >= 3) & (d_fsqrts)) begin
                    fpu_out <= 1;
                    counter <= -1;
                end else if ((counter >= 2) & (d_fadds | d_fsubs | d_fmuls | d_fcvtsws)) begin
                    fpu_out <= 1;
                    counter <= -1;
                end else if ((counter >= 1) & (d_feqs | d_flts | d_fles | d_fsgnjs | d_fsgnjxs | d_fsgnjns | d_fcvtwss)) begin
                    fpu_out <= 1;
                    counter <= -1;
                end else begin
                    fpu_out <= 0;
                    counter <= counter + 1;
                end
             end else begin
                fpu_out <= 0;
                counter <= 0;
             end
        end
    end
    
endmodule

`default_nettype wire