`default_nettype none
`timescale  1ns/1ps

module register_file (
    
    input wire clk,
    input wire rstn,

    input wire we3,
    //input wire fwe3,
    input wire [5:0] m_rd,
    input wire [5:0] m_rs1,
    input wire [31:0] mm_wd3,

    input wire m_in,
    input wire empty,
    input wire [7:0] uart_in,
    input wire uart_ok_in,
    input wire m_out,
    output logic [7:0] uart_out,

    input wire [5:0] rd,
    input wire [5:0] rs1,
    input wire [5:0] rs2,
    output logic [31:0] rd1,
    output logic [31:0] rd2,
    output logic [31:0] rd3
    //output logic [31:0] frd1,
    //output logic [31:0] frd2,
    //output logic [31:0] frd3
);

    (* mark_debug = "true" *) logic [31:0] gpr [0:63];
    //(* mark_debug = "true" *) logic [31:0] fpr [0:31];

    assign rd1 = gpr [rs1];
    assign rd2 = gpr [rs2];
    assign rd3 = gpr [rd];
    //assign frd1 = fpr [rs1];
    //assign frd2 = fpr [rs2];
    //assign frd3 = fpr [rd];

    //assign led = gpr[10][7:0];
    integer i;
    
    always_ff @ (posedge clk) begin
        if (~rstn) begin
            for (i = 0; i < 64; i = i+1) begin
                begin
                    gpr[i] <= 0;
                end
            end    
        end else begin
            if (we3 && (m_rd != 0)) begin
                gpr[m_rd] <= mm_wd3; 
            end
            if (uart_ok_in && m_in && (m_rd != 0)) begin
                gpr[m_rd] <= ({24'b000000000000000000000000, mm_wd3[7:0]});
            end
            if (m_out) begin
                uart_out <= gpr[m_rs1][7:0];
            end 
        end    
    end

endmodule

`default_nettype wire