`default_nettype none

module uart_tx_wrap #(CLK_PER_HALF_BIT = 5208)(
               input wire [7:0] sdata,
               input wire       tx_start,
               output wire      tx_busy,
               output wire      txd,
               input wire       clk,
               input wire       rstn);
       
       uart_tx uart_tx(sdata, tx_start, tx_busy, txd, clk, rstn); 
endmodule

`default_nettype wire