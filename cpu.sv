`default_nettype none

module cpu(
    input wire clk,
    input wire rst,
    (* mark_debug = "true" *) input wire empty,
    input wire [7:0] uart_in,
    (* mark_debug = "true" *) input wire [31:0] instruction,
    (* mark_debug = "true" *) output logic [7:0] uart_out,
    (* mark_debug = "true" *) output logic uart_ok_in,
    (* mark_debug = "true" *) output logic uart_ready_out,
    output logic [31:0] next_pc,
    (* mark_debug = "true" *) output logic [15:0] led,
    output logic pc_flag,
    
    //AR
	output logic [31:0] core_ARADDR,
	output logic 		core_ARVALID,

    //R
	input wire [31:0] core_RDATA,
    input wire        core_RVALID,

    //AW
	output logic [31:0] core_AWADDR,
	output logic        core_AWVALID,

    //W
	output logic [31:0] core_WDATA,

    //B
    input wire core_BVALID
);
    
    (* mark_debug = "true" *) logic [31:0] pc;
    (* mark_debug = "true" *) logic [31:0] cnt;
    logic pcsrc;
    logic [31:0] pcbranch;
    assign led = cnt[31:16];
    //assign uart_out = uart_in[7:0];
    
    logic add, sub, sll, slt, sltu, _xor, srl, sra, _or, _and, addi, slti, sltiu, xori, ori, andi, slli, srli, srai, 
          beq, bne, blt, bltu, bge, bgeu, lui, jal, jalr, auipc,
          flw, fsw, fadds, fsubs, fmuls, fdivs, feqs, flts, fles, fsqrts, fsgnjs, fsgnjxs, fsgnjns, fcvtsws, fcvtwss, fmvwxs; 
    (* mark_debug = "true" *) logic in, out, endp, lw, sw;
    (* mark_debug = "true" *) assign pc_flag = (~rst) ? 1 : (((~in) | (uart_ok_in & (~empty))) & (~endp) & (((~lw) & (~flw)) | (core_RVALID)) & (((~sw) & (~fsw)) | (core_BVALID)));
    //logic add, sub, sll, slt, sltu, _xor, srl, sra, _or, _and, addi, slti, sltiu, xori, ori, andi, slli, srli, srai, 
      //    beq, bne, blt, bltu, bge, bgeu, lui, jal, jalr, auipc,
      //    flw, fsw, fadds, fsubs, fmuls, fdivs, feqs, flts, fles, fsqrts, fsgnjs, fsgnjxs, fsgnjns; 
    //(* mark_debug = "true" *) logic in, out, endp, lw, sw;
    //(* mark_debug = "true" *) assign pc_flag = (~rst) ? 1 : (((~in) | (~empty)) & (~endp) & (((~lw) & (~flw)) | (core_RVALID)) & (((~sw) & (~fsw)) | (core_BVALID)));
    
    // decode
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;
    logic iflag, fflag;
    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd = instruction[11:7]; 
    logic memtoreg, memwrite;
    logic branch, alusrc;
    logic regwrite;
    logic jump;
    logic [3:0] alucontrol;
    logic [9:0] controls;
    
    //inst-flag
    assign add  = ((opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0000000));
    assign sub  = ((opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0100000));
    assign sll  =  (opcode == 7'b0110011) && (funct3 == 3'b001);
    assign slt  =  (opcode == 7'b0110011) && (funct3 == 3'b010);
    assign sltu  = (opcode == 7'b0110011) && (funct3 == 3'b011);
    assign _xor  = (opcode == 7'b0110011) && (funct3 == 3'b100);
    assign srl  = ((opcode == 7'b0110011) && (funct3 == 3'b101) && (funct7 == 7'b0000000));
    assign sra  = ((opcode == 7'b0110011) && (funct3 == 3'b101) && (funct7 == 7'b0100000));  
    assign _or  = (opcode == 7'b0110011) && (funct3 == 3'b110);
    assign _and = (opcode == 7'b0110011) && (funct3 == 3'b111);

    assign addi = ((opcode == 7'b0010011) && (funct3 == 3'b000));
    assign slti = (opcode == 7'b0010011) && (funct3 == 3'b010);
    assign sltiu = (opcode == 7'b0010011) && (funct3 == 3'b011);
    assign xori = (opcode == 7'b0010011) && (funct3 == 3'b100);
    assign ori = (opcode == 7'b0010011) && (funct3 == 3'b110);
    assign andi = (opcode == 7'b0010011) && (funct3 == 3'b111);
    assign slli = (opcode == 7'b0010011) && (funct3 == 3'b001);
    assign srli = (opcode == 7'b0010011) && (funct3 == 3'b101) && (funct7 == 7'b0000000);
    assign srai = (opcode == 7'b0010011) && (funct3 == 3'b101) && (funct7 == 7'b0100000);

    assign beq  = ((opcode == 7'b1100011) && (funct3 == 3'b000));
    assign bne  = ((opcode == 7'b1100011) && (funct3 == 3'b001));
    assign blt  = ((opcode == 7'b1100011) && (funct3 == 3'b100));
    assign bge  = ((opcode == 7'b1100011) && (funct3 == 3'b101));
    assign bltu  = ((opcode == 7'b1100011) && (funct3 == 3'b110));
    assign bgeu  = ((opcode == 7'b1100011) && (funct3 == 3'b111));

    assign lui  = (opcode == 7'b0110111);
    assign auipc = (opcode == 7'b0010111);
    assign in = (opcode == 7'b1111111);
    assign out = (opcode == 7'b1111110);
    assign endp = (opcode == 7'b0000000);

    assign jal = (opcode == 7'b1101111);
    assign jalr = (opcode == 7'b1100111);
    
    assign lw  = ((opcode == 7'b0000011) && (funct3 == 3'b010));
    assign sw  = ((opcode == 7'b0100011) && (funct3 == 3'b010));
    assign flw = (opcode == 7'b0000111) && (funct3 == 3'b010);
    assign fsw = (opcode == 7'b0100111) && (funct3 == 3'b010);

    assign fadds  = ((opcode == 7'b1010011) && (funct7 == 7'b0000000));
    assign fsubs  = ((opcode == 7'b1010011) && (funct7 == 7'b0000100));
    assign fmuls  = ((opcode == 7'b1010011) && (funct7 == 7'b0001000));
    assign fdivs  = ((opcode == 7'b1010011) && (funct7 == 7'b0001100));
    
    assign feqs  = ((opcode == 7'b1010011) && (funct7 == 7'b1010000) && (funct3 == 3'b010));
    assign flts  = ((opcode == 7'b1010011) && (funct7 == 7'b1010000) && (funct3 == 3'b001));
    assign fles  = ((opcode == 7'b1010011) && (funct7 == 7'b1010000) && (funct3 == 3'b000));

    assign fsqrts = (opcode == 7'b1010011) && (funct7 == 7'b0101100);
    assign fsgnjs = (opcode == 7'b1010011) && (funct7 == 7'b0010000) && (funct3 == 3'b000);
    assign fsgnjns = (opcode == 7'b1010011) && (funct7 == 7'b0010000) && (funct3 == 3'b001);
    assign fsgnjxs = (opcode == 7'b1010011) && (funct7 == 7'b0010000) && (funct3 == 3'b010);
    assign fcvtsws = (opcode == 7'b1010011) && (funct7 == 7'b1101000) && (funct3 == 3'b000);
    assign fcvtwss = (opcode == 7'b1010011) && (funct7 == 7'b1100000) && (funct3 == 3'b000);
    assign fmvwxs = (opcode == 7'b1010011) && (funct7 == 7'b1111000);
    
    assign iflag = ( add | sub | sll | slt | sltu | _xor | srl | sra | _or | _and | addi | slti | sltiu | xori | ori | 
                     andi | slli | srli | srai | beq | bne | blt | bltu | bge | bgeu | lui | jal | jalr | auipc | lw | sw | feqs | flts | fles | fcvtwss) ? 1 : 0;
    assign fflag = (fadds | fsubs | fmuls | fdivs | fsqrts | fsgnjs | fsgnjxs | fsgnjns | fcvtsws) ? 1 : 0;
    
    logic [31:0] imm;
    logic [31:0] imm_i;
    logic [31:0] imm_s;
    logic [31:0] imm_b;
    logic [31:0] imm_l;
    logic [31:0] imm_j;

    // I-type
    assign imm_i = $signed({instruction[31:20]});

    // S-type
    assign imm_s = $signed({instruction[31:25], instruction[11:7]});

    // B-type
    assign imm_b = $signed({instruction[31], instruction[7], instruction[30:25], instruction[11:8], 2'b00});

    // L-type
    assign imm_l = $signed({instruction[31:12], 12'b000000000000});

    // J-type
    assign imm_j = $signed({instruction[31], instruction[19:12], instruction[20], instruction[30:21], 2'b00});
    
    (* mark_debug = "true" *) assign imm = (opcode == 7'b0010011 | opcode == 7'b0000011 | opcode == 7'b1100111  | opcode == 7'b1111111 | opcode == 7'b1111110 | opcode == 7'b0000111) ? imm_i :
                                          (opcode == 7'b0100011 | opcode == 7'b0100111) ? imm_s :
                                          (opcode == 7'b1100011) ? imm_b :
                                          ((opcode == 7'b0110111) | (opcode == 7'b0010111)) ? imm_l : imm_j;
                                          
    (* mark_debug = "true" *) logic [31:0] aluresult;
    logic zero;
    
    assign pcbranch = (opcode == 7'b1100111) ? aluresult : imm + pc;
    assign pcsrc = (branch & ((zero & beq) | ((~zero) & bne) | (aluresult & blt) | (aluresult & bltu) | (~aluresult & bge) | (~aluresult & bgeu))) | jump;
    assign next_pc = (~rst) ? 0 : pcsrc ? pcbranch : pc + 4;
    
    logic [31:0] rd1;
    logic [31:0] rd2;
    logic [31:0] frd1;
    logic [31:0] frd2;
    
    logic [31:0] x1;
    logic [31:0] x2;
    assign x1 = frd1; 
    assign x2 = frd2;
    logic [31:0] y;
    logic ovf;
    logic exception;
    logic [31:0] itof;
    fcvtsw fcvtsw(rd1, itof);
    fpu fpu(.*);
    logic [31:0] fpuresult;
    assign fpuresult = y;
    
    logic [31:0] wd3; // write data (from alu or fpu to reg)
    (* mark_debug = "true" *) assign wd3 = jump ? pc + 4 :
                                     memtoreg ? core_RDATA : 
                                     auipc ? aluresult + pc :
                                     fcvtsws ? itof :
                                     (feqs | flts | fles | fcvtwss | fflag) ? fpuresult : 
                                     aluresult;

    logic we3, fwe3; // enable write to reg
    (* mark_debug = "true" *) assign we3 = regwrite & iflag & ((~lw) | (core_RVALID));
    assign fwe3 = regwrite & (fflag | flw | fsw | fmvwxs) & ((~flw) | (core_RVALID));

    decoder decoder(.*);
    register_file register_file(.*);
    
    //logic [31:0] wd3; // write data (from alu or fpu to reg)
    //(* mark_debug = "true" *) assign wd3 = jump ? pc + 4 :
      //           memtoreg ? core_RDATA : 
      //           auipc ? aluresult + pc : 
      //           (feqs | flts | fles | fflag) ? fpuresult : 
      //           aluresult;

    //logic we3, fwe3; // enable write to reg
    //(* mark_debug = "true" *) assign we3 = regwrite & iflag & ((~lw) | (core_RVALID));
    //assign fwe3 = regwrite & fflag & ((~flw) | (core_RVALID));

    //logic [31:0] rd1;
    //logic [31:0] rd2;
    //logic [31:0] frd1;
    //logic [31:0] frd2;

    //decoder decoder(.*);
    //register_file register_file(.*);

    //alu
    logic [31:0] src1;
    logic [31:0] src2;
    assign src1 = (lui | auipc) ? imm : rd1; 
    assign src2 = alusrc ? imm : rd2; 

    alu alu(.src1, .src2, .alucontrol, .aluresult, .zero);
    //

    //write back
    //cache
    (* mark_debug = "true" *) assign core_ARVALID = lw | flw;
    (* mark_debug = "true" *) assign core_ARADDR = aluresult;
    (* mark_debug = "true" *) assign core_AWVALID = sw | fsw;
    (* mark_debug = "true" *) assign core_AWADDR = aluresult;
    (* mark_debug = "true" *) assign core_WDATA = sw ? rd2 : frd2;
    
    always_ff @ (posedge clk) begin
        if(~rst) begin
            pc <= 0;
            cnt <= 1;
        end else begin
            if(pc_flag) begin
                pc <= next_pc;
                cnt <= cnt + 1;
            end
            if(in & (~empty) & (~uart_ok_in)) begin
                uart_ok_in <= 1;
                //uart_ready_out <= 1;
            end else begin
                uart_ok_in <= 0;
                //uart_ready_out <= 0;
            end
            if(out) begin
                uart_ready_out <= 1;
            end else begin
                uart_ready_out <= 0;
            end
        end
    end
        
endmodule

`default_nettype wire
