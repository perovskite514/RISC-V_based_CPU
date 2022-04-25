`default_nettype none

module uart_rx_wrap #(CLK_PER_HALF_BIT = 5208)(
               output wire [7:0] rdata,
               output wire       rdata_ready,
               input wire        rxd,
               input wire        clk,
               input wire        rstn);
               wire ferr;
       uart_rx uart_rx(rdata, rdata_ready, ferr, rxd, clk, rstn);
endmodule

`default_nettype wire