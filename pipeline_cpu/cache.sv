`timescale 1ns/1ps
`default_nettype none

module ss_rams_sp_rf (clk, we, wr_addr, wr_data, rd_addr, rd_data);     

    parameter addr_size = 32;     
    parameter data_size = 32;      

    input wire clk;    
    input wire we;
    input [addr_size-1:0] wr_addr;  
    input [data_size-1:0] wr_data;    
    input [addr_size-1:0] rd_addr;       
    output [data_size-1:0] rd_data;   

    (* ram_style = "block" *) reg [data_size-1:0] ram [0:(2**16) - 1]; initial $readmemb("data.mem", ram);
     
    reg [data_size-1:0] rd_data;     

    always @( posedge clk ) begin
        if (we) ram[wr_addr] <= wr_data;
    end

    always @( posedge clk ) begin
        rd_data <= ram[rd_addr];
    end

endmodule

module ss_rams_sp_rf_inst (clk, we, wr_addr, wr_data, re, rd_addr, rd_data);     

    parameter addr_size = 32;     
    parameter data_size = 32;      

    input wire clk;    
    input wire we;     
    input [addr_size-1:0] wr_addr;  
    input [data_size-1:0] wr_data;
    input wire re;    
    input [addr_size-1:0] rd_addr;       
    output [data_size-1:0] rd_data;   

    (* ram_style = "block" *) reg [data_size-1:0] ram [0: (2**16) - 1]; initial $readmemb("f.mem", ram);

    reg [data_size-1:0] rd_data;     

    always @( posedge clk ) begin
        if (we) ram[wr_addr] <= wr_data;
    end

    always @( posedge clk ) begin
        if (re) rd_data <= ram[rd_addr];
    end

endmodule

module cache #
  (
    parameter  C_M_AXI_THREAD_ID_WIDTH       = 1,
    parameter  C_M_AXI_ADDR_WIDTH            = 27, //address_width
    parameter  C_M_AXI_DATA_WIDTH            = 32, //data

    parameter  C_M_AXI_BURST_LEN = 1,

    parameter  CORE_ADDR_WIDTH = 32,
    parameter  CORE_DATA_WIDTH = 32,
    parameter  INST_ADDR_LENGTH = 12492 + 39,
    parameter  BRAM_ADDR_LENGTH = 2**16
   )
  (
    // System Signals
    input wire 	      ACLK,
    input wire 	      ARESETN,
    
    // Master AR
    output logic [C_M_AXI_THREAD_ID_WIDTH-1:0] 	 M_AXI_ARID,//out of order用のID
    (* mark_debug = "true" *) output logic  [C_M_AXI_ADDR_WIDTH-1:0] 	     M_AXI_ARADDR,//読み込み開始アドレス
    output logic [8-1:0] 			 M_AXI_ARLEN,//バ?????スト長
    output logic [3-1:0] 			 M_AXI_ARSIZE,//????ータサイズ
    output logic [2-1:0] 			 M_AXI_ARBURST,//バ?????スト転送タイ????
    output logic [2-1:0] 			 M_AXI_ARLOCK,//ロ????ク方????
    output logic [4-1:0] 			 M_AXI_ARCACHE,//キャ????シュ
    output logic [3-1:0] 			 M_AXI_ARPROT,//プロ????クション
    output logic [4-1:0] 			 M_AXI_ARQOS,//帯域制御
    (* mark_debug = "true" *) output logic 				     M_AXI_ARVALID,//arvalid
    (* mark_debug = "true" *) input  wire 				     M_AXI_ARREADY,//arready
    

    // Master R 
    input  wire [C_M_AXI_THREAD_ID_WIDTH-1:0] 	 M_AXI_RID,//out of order用のID
    (* mark_debug = "true" *) input  wire [C_M_AXI_DATA_WIDTH-1:0] 	     M_AXI_RDATA,//rdata
    input  wire [2-1:0] 			             M_AXI_RRESP,//読み出し応??
    input  wire 				                 M_AXI_RLAST,//????終データ
    (* mark_debug = "true" *) input  wire 				                 M_AXI_RVALID,//rvalid
    (* mark_debug = "true" *) output logic				                 M_AXI_RREADY,//rready


     // Master AW
    output logic [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_AXI_AWID,//out of order用のID
    (* mark_debug = "true" *) output logic [C_M_AXI_ADDR_WIDTH-1:0]        M_AXI_AWADDR,//書き込みアドレス
    output logic [8-1:0] 			             M_AXI_AWLEN,//バ?????スト長
    output logic [3-1:0] 			             M_AXI_AWSIZE,//????ータ長
    output logic [2-1:0] 			             M_AXI_AWBURST,//バ?????スト転送タイ????
    output logic 				                 M_AXI_AWLOCK,//ロ????ク方????
    output logic [4-1:0] 			             M_AXI_AWCACHE,//キャ????シュ
    output logic [3-1:0] 			             M_AXI_AWPROT,//プロ????クション
    output logic [4-1:0] 			             M_AXI_AWQOS,//帯域制御
    (* mark_debug = "true" *) output logic 				                 M_AXI_AWVALID,//awvalid
    (* mark_debug = "true" *) input  wire 				                 M_AXI_AWREADY,//awready


    // Master W
    (* mark_debug = "true" *) output logic [C_M_AXI_DATA_WIDTH-1:0] 	     M_AXI_WDATA,//書き込み????ータ
    output logic [C_M_AXI_DATA_WIDTH/8-1:0] 	 M_AXI_WSTRB,//バイトイネ?????ブル
    output logic 				                 M_AXI_WLAST,//????終データ
    (* mark_debug = "true" *) output logic 				                 M_AXI_WVALID,//wvalid
    (* mark_debug = "true" *) input  wire 				                 M_AXI_WREADY,//wready
    

    // Master B
    input  wire [C_M_AXI_THREAD_ID_WIDTH-1:0] 	 M_AXI_BID,//out of order用のID
    input  wire [2-1:0] 			             M_AXI_BRESP,//書き込み応??
    (* mark_debug = "true" *) input  wire 				                 M_AXI_BVALID,//bvalid
    (* mark_debug = "true" *) output logic 				                 M_AXI_BREADY,//bready

	//inst
    input wire [CORE_ADDR_WIDTH-1:0] 	     pc,
    input wire                               pc_flag,
    output logic [CORE_DATA_WIDTH-1:0] 	     instruction,
    
    //AR
	input wire [CORE_ADDR_WIDTH-1:0] 	     core_ARADDR,
	input wire 				 			     core_ARVALID,

    //R
	output logic [CORE_DATA_WIDTH-1:0] 	     core_RDATA,
    output logic 				 			 core_RVALID,

    //AW
	input wire [CORE_ADDR_WIDTH-1:0]         core_AWADDR,
	input wire 				 			     core_AWVALID,

    //W
	input wire [CORE_DATA_WIDTH-1:0] 	     core_WDATA,

    //B
    output logic 				    	     core_BVALID
    );

    // AXI4 temp signals
    logic aw_valid;
    logic w_valid;
    logic b_ready;
    logic ar_valid; 
    logic r_ready;
    //reg w_last;

    assign M_AXI_AWVALID = aw_valid;
    assign M_AXI_WVALID = w_valid;
    assign M_AXI_BREADY = b_ready;
    assign M_AXI_ARVALID = ar_valid;
    assign M_AXI_RREADY = r_ready;
    //assign M_AXI_WLAST = w_last;

    assign M_AXI_WLAST = 1;


    //////////////////// 
    //Write Address (AW)
    ////////////////////

    // Single threaded   
    assign M_AXI_AWID = 'b0;
    assign M_AXI_AWLEN = C_M_AXI_BURST_LEN - 1; //0 -> 32bit転送を????????
    //sw -> 4byte indata->1byte
    assign M_AXI_AWSIZE = 3'b010;
    //sw ? 2 : indata ? 0 : 0; //????ータのビット?? 32bit -> 4byte -> 3'b010

    // INCR burst type is usually used, except for keyhole bursts
    assign M_AXI_AWBURST = 2'b01;//インクリメントしてアドレスが?????????
    assign M_AXI_AWLOCK = 1'b0;

    // Not Allocated, Modifiable, not Bufferable
    // Not Bufferable since this example is meant to test memory, not intermediate cache   
    assign M_AXI_AWCACHE = 4'b0010;
    assign M_AXI_AWPROT = 3'h0;
    assign M_AXI_AWQOS = 4'h0;

    //All bursts are complete and aligned in this example
    assign M_AXI_WSTRB = 4'b1111;//sw ? 4'b1111 : indata ? 4'b0001 : 0;
    //assign M_AXI_WUSER = 'b0;

    ///////////////////   
    //Read Address (AR)
    ///////////////////
    assign M_AXI_ARID = 'b0;   

    //Burst LENgth is number of transaction beats, minus 1
    assign M_AXI_ARLEN = C_M_AXI_BURST_LEN - 1;

    // Size should be C_M_AXI_DATA_WIDTH, in 2^n bytes, otherwise narrow bursts are used
    assign M_AXI_ARSIZE = 3'b010;//sw ? 2 : indata ? 0 : 0; 

    // INCR burst type is usually used, except for keyhole bursts
    assign M_AXI_ARBURST = 2'b01;
    assign M_AXI_ARLOCK = 1'b0;
    // Not Allocated, Modifiable, not Bufferable
    // Not Bufferable since this example is meant to test memory, not intermediate cache
    assign M_AXI_ARCACHE = 4'b0010;
    assign M_AXI_ARPROT = 3'h0;
    assign M_AXI_ARQOS = 4'h0;
    
    logic unsigned [CORE_ADDR_WIDTH-1:0] core_awaddr; 
    assign core_awaddr = {2'b00, core_AWADDR[31:2]};
    logic unsigned [CORE_ADDR_WIDTH-1:0] core_araddr;
    assign core_araddr = {2'b00, core_ARADDR[31:2]};
    logic unsigned [CORE_ADDR_WIDTH-1:0] core_bram_awaddr;
    assign core_bram_awaddr = core_awaddr - INST_ADDR_LENGTH;
    logic unsigned [CORE_ADDR_WIDTH-1:0] core_bram_araddr;
    assign core_bram_araddr = core_araddr - INST_ADDR_LENGTH;
    
    logic [CORE_DATA_WIDTH-1:0] r_data_out;  
    
    (* mark_debug = "true" *) wire inst_w_flag; 
    assign inst_w_flag = ((core_awaddr < INST_ADDR_LENGTH) && (core_AWVALID)) ? 1'b1 : 1'b0;
    (* mark_debug = "true" *) wire bram_w_flag;
    assign bram_w_flag = ((core_awaddr > INST_ADDR_LENGTH) && (core_awaddr < (BRAM_ADDR_LENGTH + INST_ADDR_LENGTH)) && (core_AWVALID)) ? 1'b1 : 1'b0; 
    (* mark_debug = "true" *) wire bram_r_flag;
    assign bram_r_flag = ((core_araddr > INST_ADDR_LENGTH) && (core_araddr < (BRAM_ADDR_LENGTH + INST_ADDR_LENGTH)) && (core_ARVALID)) ? 1'b1 : 1'b0; 
    (* mark_debug = "true" *) logic flag;
    (* mark_debug = "true" *) logic flag2;
    
    always @( posedge ACLK ) begin
        if (~ARESETN) begin
            core_RVALID <= 1'b0;
            flag <= 1'b0;
        end else begin
            if (flag) begin
                core_RVALID <= M_AXI_RVALID;
                flag <= 1'b0;
            end else begin
                if (bram_r_flag) begin
                    core_RVALID <= 1'b1;
                    flag <= 1'b1;
                end else begin
                    core_RVALID <= M_AXI_RVALID;
                end
            end
        end
    end
    
    always @( posedge ACLK ) begin
        if (~ARESETN) begin
            core_BVALID <= 1'b0;
            flag2 <= 1'b0;
        end else begin
            if (flag2) begin
                core_BVALID <= M_AXI_BVALID;
                flag2 <= 1'b0;
            end else begin
                if (bram_w_flag | inst_w_flag) begin
                    core_BVALID <= 1'b1;
                    flag2 <= 1'b1;
                end else begin
                    core_BVALID <= M_AXI_BVALID;
                end
            end
        end
    end
    
    (* mark_debug = "true" *) logic unsigned [31:0] pc_addr;
    assign pc_addr = {2'b00, pc[31:2]};
    assign core_RDATA = (bram_r_flag) ? r_data_out : M_AXI_RDATA;
    
    ss_rams_sp_rf_inst ss_rams_sp_rf_inst(
        .clk(ACLK),
        .we(inst_w_flag),
        .wr_addr(core_awaddr),
        .wr_data(core_WDATA),
        .re(pc_flag),
        .rd_addr(pc_addr),
        .rd_data(instruction)
    );
    ss_rams_sp_rf ss_rams_sp_rf(
        .clk(ACLK),
        .we(bram_w_flag),
        .wr_addr(core_bram_awaddr),
        .wr_data(core_WDATA), 
        .rd_addr(core_bram_araddr),
        .rd_data(r_data_out)
    );
    
    ///////////////////////
    //Write Address Channel
    ///////////////////////

    assign M_AXI_AWADDR = core_AWADDR; //多分こう修正するべき......?
    logic aw_flag;

    always_ff @(posedge ACLK ) begin
        if(~ARESETN) begin
            aw_valid <= 1'b0;
            aw_flag <= 1'b0;
        end
        else if (b_ready && core_AWVALID && aw_valid == 0 && aw_flag == 0 && bram_w_flag == 0 && inst_w_flag == 0) begin
            aw_valid <= 1'b1;
            aw_flag <= 1'b1;
        end
        else if (M_AXI_AWREADY && aw_valid && bram_w_flag == 0 && inst_w_flag == 0) begin
            aw_valid <= 1'b0;
        end
        else begin
            aw_valid <= aw_valid;
        end

        if (M_AXI_BVALID) begin
            aw_flag <= 1'b0;
        end
    end

    ////////////////////
    //Write Data Channel
    ////////////////////

    assign M_AXI_WDATA = core_WDATA;
    logic w_flag;

    always_ff @(posedge ACLK ) begin
        if(~ARESETN) begin
            w_valid <= 1'b0;
            w_flag <= 1'b0;
            b_ready <= 1'b0;
        end
        else if (b_ready && core_AWVALID && w_valid == 0 && w_flag == 0 && bram_w_flag == 0 && inst_w_flag == 0) begin
            w_valid <= 1'b1;
            w_flag <= 1'b1;
        end
        else if (M_AXI_WREADY && w_valid && bram_w_flag == 0 && inst_w_flag == 0) begin
            w_valid <= 1'b0;
        end
        else begin
            w_valid <= w_valid;
        end

        if (M_AXI_BVALID) begin
            w_flag <= 1'b0;
            b_ready <= 1'b0;
        end
        else begin
            b_ready <= 1'b1;
        end

    end

    //////////////////////   
    //Read Address Channel
    //////////////////////

    assign M_AXI_ARADDR = core_ARADDR;
    logic ar_flag;

    always_ff @(posedge ACLK ) begin
        if(~ARESETN) begin
            ar_valid <= 1'b0;
            ar_flag <= 1'b0;
            r_ready <= 1'b0;
        end
        else if (r_ready && core_ARVALID && ar_valid == 0 && ar_flag == 0 && bram_r_flag == 0) begin
            ar_valid <= 1'b1;
            ar_flag <= 1'b1;
        end
        else if (M_AXI_ARREADY && ar_valid && bram_r_flag == 0) begin
            ar_valid <= 1'b0;
        end
        else begin
            ar_valid <= ar_valid;
        end

        if (M_AXI_RVALID) begin
            ar_flag <= 1'b0;
            r_ready <= 1'b0;
        end
        else begin
            r_ready <= 1'b1;
        end
    end

endmodule

`default_nettype wire