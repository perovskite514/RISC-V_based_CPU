`default_nettype none
`timescale  1ns/1ps

module alu (
  input wire clk,
  input wire rstn,
  input wire [31:0] d_imm,
  input wire d_add, d_sub, d_sll, d_slt, d_sltu, d__xor, d_srl, d_sra, d__or, d__and, d_addi, d_slti, d_sltiu, d_xori, d_ori, d_andi, 
             d_slli, d_srli, d_srai, d_beq, d_bne, d_blt, d_bltu, d_bge, d_bgeu, d_lw, d_sw, d_flw, d_fsw, d_fmvwxs,
             d_lui, d_jump, d_auipc, d_in, d_out, 
  input wire [31:0] src1,
  input wire [31:0] src2,
  //input wire [31:0] fsrc1,
  //input wire [31:0] fsrc2,
  output logic [31:0] aluresult
);

    assign aluresult = (d_jump) ? src1 + 4 :
                       (d_addi | d_lw | d_sw | d_flw | d_fsw) ? src1 + d_imm :
                       (d_add) ? src1 + src2 :
                       (d_sub) ? src1 - src2 :
                       (d_slti) ? ($signed(src1) < $signed(d_imm)) :
                       (d_slt) ?  ($signed(src1) < $signed(src2)) :
                       (d_sltiu) ? (src1 < d_imm) :
                       (d_sltu) ? (src1 < src2) :
                       (d_slli) ? src1 << d_imm[4:0] :
                       (d_sll) ? src1 << src2[4:0] :
                       (d_srli) ? ($signed({1'b0, src1}) >>> d_imm[4:0]) :
                       (d_srai) ? ($signed({src1[31], src1}) >>> d_imm[4:0]) :
                       (d_srl) ? ($signed({1'b0, src1}) >>> src2[4:0]) :
                       (d_sra) ? ($signed({src1[31], src1}) >>> src2[4:0]) :
                       (d_xori) ? src1 ^ d_imm :
                       (d__xor) ? src1 ^ src2 :
                       (d_ori) ? src1 | d_imm :
                       (d__or) ? src1 | src2 :
                       (d_andi) ? src1 & d_imm :
                       (d__and) ? src1 & src2 :
                       (d_beq) ? (src1 == src2) :
                       (d_bne) ? !(src1 == src2) :
                       (d_bge) ? !($signed(src1) < $signed(src2)) :
                       (d_bgeu) ? !(src1 < src2) :
                       (d_blt) ? ($signed(src1) < $signed(src2)) :
                       (d_bltu) ? (src1 < src2) : 
                       (d_lui) ? d_imm :
                       (d_auipc) ? src1 + d_imm : 
                       (d_fmvwxs) ? src1 : 32'd0;

endmodule

`default_nettype wire