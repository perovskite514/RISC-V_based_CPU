
// HALF_TMCLK_UART corresponds to 100 MHz system clock
// HALF_TMCLK_UART = 10^9 / (100M) / 2

// HALF_TMCLK corresponds to 10 MHz system clock
// HALF_TMCLK = 10^9 / (10M) / 2

// TMBIT and CLK_PER_HALF_BIT corresponds to 576000 bps
// TMBIT = 10^9 / baud rate
// CLK_PER_HALF_BIT = 100M / baud rate / 2

// localparam TMBIT = 1736;
// localparam TMINTVL = TMBIT*5;
// localparam HALF_TMCLK_UART = 5;
// localparam HALF_TMCLK = 50;
// localparam CLK_PER_HALF_BIT = 86;

module cpu_smi;

    logic clk, rst, txd, rxd, led;
    localparam STEP = 104166;

    logic [7:0] prog [2000:0];
    logic [31:0] program_size;
    assign program_size = 136;// ここはプログラムのサイズを入れる
    
    always #25 begin
        clk = ~clk;
    end

    int i;
    design_1_wrapper design_1_wrapper(.led(led), .reset(rst), .sys_clock(clk), .usb_uart_rxd(txd), .usb_uart_txd(rxd));

    task uart(input logic [7:0] data);
        begin
            #STEP rxd = 0;
            #STEP rxd = data[0];
            #STEP rxd = data[1];
            #STEP rxd = data[2];
            #STEP rxd = data[3];
            #STEP rxd = data[4];
            #STEP rxd = data[5];
            #STEP rxd = data[6];
            #STEP rxd = data[7];
            #STEP rxd = 1;
            end
        endtask

    initial begin
        rst = 1;
        clk = 1;
        // 8bit単位
        $readmemb("program.mem", prog);
        #25 rst = 0;
        #25 rst = 1;
        #500000
    
    uart(program_size[7:0]);
    uart(program_size[15:8]);
    uart(program_size[23:16]);
    uart(program_size[31:24]);

    for (i=0;i<program_size;i++) begin
        uart(prog[i]);
    end

    $finish;
end

endmodule

