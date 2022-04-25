`default_nettype none

module uart_rx #(CLK_PER_HALF_BIT = 5208) (
               output logic [7:0] rdata,
               output logic       rdata_ready,
               output logic       ferr,
               input wire         rxd,
               input wire         clk,
               input wire         rstn);
   
   localparam e_clk_bit = CLK_PER_HALF_BIT * 2 - 1;
   localparam half = CLK_PER_HALF_BIT  - 1;
   localparam e_clk_stop_bit = (CLK_PER_HALF_BIT * 2 * 9) / 10 - 1;
   
   (* mark_debug = "true" *) logic [3:0]                  status;
   (* mark_debug = "true" *) logic [7:0]                  rbuf;
   (* mark_debug = "true" *) logic [31:0]                 counter;
   (* mark_debug = "true" *) logic                        next;
   (* mark_debug = "true" *) logic                        rst_ctr;
   (* mark_debug = "true" *) reg [2:0] check;
   (* mark_debug = "true" *) wire j = ~(|check); 
   (* ASYNC_REG = "true" *) reg rxd1;
   (* ASYNC_REG = "true" *) reg rxd2;
   (* mark_debug = "true" *) reg f;
   
   localparam s_idle = 0;
   localparam s_wait = 1;
   localparam s_start = 2;
   localparam s_bit_0 = 3;
   localparam s_bit_1 = 4;
   localparam s_bit_2 = 5;
   localparam s_bit_3 = 6;
   localparam s_bit_4 = 7;
   localparam s_bit_5 = 8;
   localparam s_bit_6 = 9;
   localparam s_bit_7 = 10;
   localparam s_stop = 11;

   always @(posedge clk) begin
      if (~rstn) begin
         counter <= 32'b0;
         next <= 1'b0;
         f <= 0;
      end else begin
         if (counter == e_clk_bit || rst_ctr) begin
            counter <= 32'b0;
         end else begin
            counter <= counter + 32'd1;
         end
         if (~rst_ctr && counter == half) begin
            f <= 1'b1;
         end else begin
            f <= 1'b0;
         end
         if (~rst_ctr && counter == e_clk_bit) begin
            next <= 1'b1;
         end else begin
            next <= 1'b0;
         end
      end
   end
   
	always @(posedge clk) begin
        if(~rstn) begin
            status <= 0;
            rst_ctr <= 0;
            rdata_ready <= 0;
            ferr <= 0;
            rbuf <= 0;
            rdata <= 0;
            check <= 3'b111;
            rxd1 <=0;
            rxd2 <= 0;
        end else begin
            rxd1 <= rxd;
            rxd2 <= rxd1;
            check <= check << 1;
            check[0] <= rxd2;
            if(status == 0 && j) begin
                status <= 1;
                rst_ctr <= 1;
            end else if(status == 1 && f == 1) begin
                status <= 2;
                rst_ctr <= 1;
            end else if(status == 11) begin
                status <= 0;
                rst_ctr <= 1;
                if(rxd2 == 0) begin
                    ferr <= 1;
                end else begin
                    rdata_ready <= 1;
                    rdata <= rbuf;
                end
            end else if(next && status == 10) begin
                status <= status + 1;
                rst_ctr <= 1;
            end else if(next && status != 10 && status != 1 && status != 0 && status != 11) begin
                rbuf[6:0] <= rbuf[7:1];
                rbuf[7] <= rxd2;
                status <= status + 1;
                rst_ctr <= 1;
            end else begin
            rst_ctr <= 0;
            rdata_ready <= 0;
            end
        end
    end
endmodule

`default_nettype wire
