`default_nettype none

module decoder(

    input wire clk,
    input wire rstn,
    input wire [31:0] f_inst,
    output logic [3:0] opcode,
    output logic [2:0] funct3,
    output logic [6:0] funct7,
    output logic [5:0] rs1,
    output logic [5:0] rs2,
    output logic [5:0] rd,
    output logic add, sub, sll, slt, sltu, _xor, srl, sra, _or, _and, addi, slti, sltiu, xori, ori, andi, slli, srli, srai, 
                 beq, bne, blt, bltu, bge, bgeu, lui, jal, jalr, auipc, lw, sw, in, out, endp,
                 flw, fsw, fadds, fsubs, fmuls, fdivs, feqs, flts, fles, fcvtsws, fcvtwss, fmvwxs, fsqrts, fsgnjs, fsgnjxs, fsgnjns, iflag, fflag,
    output logic memtoreg, memwrite,
    output logic branch, alusrc,
    output logic regwrite,
    output logic jump,
    output logic [31:0] imm

    );
    
    assign opcode = f_inst[3:0];
    assign funct3 = f_inst[12:10];
    assign funct7 = f_inst[31:25];
    assign rs1 = f_inst[18:13];
    assign rs2 = f_inst[24:19];
    assign rd = f_inst[9:4];
    logic [5:0] controls;

    //inst-flag
    assign add  = ((opcode == 4'b0000) && (funct3 == 3'b000) && (funct7 == 7'b0000000));
    assign sub  = ((opcode == 4'b0000) && (funct3 == 3'b000) && (funct7 == 7'b0100000));
    assign sll  =  (opcode == 4'b0000) && (funct3 == 3'b001);
    assign slt  =  (opcode == 4'b0000) && (funct3 == 3'b010);
    assign sltu  = (opcode == 4'b0000) && (funct3 == 3'b011);
    assign _xor  = (opcode == 4'b0000) && (funct3 == 3'b100);
    assign srl  = ((opcode == 4'b0000) && (funct3 == 3'b101) && (funct7 == 7'b0000000));
    assign sra  = ((opcode == 4'b0000) && (funct3 == 3'b101) && (funct7 == 7'b0100000));  
    assign _or  = (opcode == 4'b0000) && (funct3 == 3'b110);
    assign _and = (opcode == 4'b0000) && (funct3 == 3'b111);

    assign addi = ((opcode == 4'b0001) && (funct3 == 3'b000));
    assign slti = (opcode == 4'b0001) && (funct3 == 3'b010);
    assign sltiu = (opcode == 4'b0001) && (funct3 == 3'b011);
    assign xori = (opcode == 4'b0001) && (funct3 == 3'b100);
    assign ori = (opcode == 4'b0001) && (funct3 == 3'b110);
    assign andi = (opcode == 4'b0001) && (funct3 == 3'b111);
    assign slli = (opcode == 4'b0001) && (funct3 == 3'b001);
    assign srli = (opcode == 4'b0001) && (funct3 == 3'b101) && (funct7 == 7'b0000000);
    assign srai = (opcode == 4'b0001) && (funct3 == 3'b101) && (funct7 == 7'b0100000);

    assign beq  = ((opcode == 4'b0111) && (funct3 == 3'b000));
    assign bne  = ((opcode == 4'b0111) && (funct3 == 3'b001));
    assign blt  = ((opcode == 4'b0111) && (funct3 == 3'b100));
    assign bge  = ((opcode == 4'b0111) && (funct3 == 3'b101));
    assign bltu  = ((opcode == 4'b0111) && (funct3 == 3'b110));
    assign bgeu  = ((opcode == 4'b0111) && (funct3 == 3'b111));

    assign lui  = (opcode == 4'b1000);
    assign auipc = (opcode == 4'b1001);
    assign in = (opcode == 4'b0100);
    assign out = (opcode == 4'b0101);
    assign endp = (f_inst == 0);

    assign jal = (opcode == 4'b1010);
    assign jalr = (opcode == 4'b0011);
    
    assign lw  = ((opcode == 4'b0010) && (funct3 == 3'b010));
    assign sw  = ((opcode == 4'b0110) && (funct3 == 3'b010));
    assign flw = (opcode == 4'b1011) && (funct3 == 3'b010);
    assign fsw = (opcode == 4'b1100) && (funct3 == 3'b010);

    assign fadds  = ((opcode == 4'b1101) && (funct7 == 7'b0000000));
    assign fsubs  = ((opcode == 4'b1101) && (funct7 == 7'b0000100));
    assign fmuls  = ((opcode == 4'b1101) && (funct7 == 7'b0001000));
    assign fdivs  = ((opcode == 4'b1101) && (funct7 == 7'b0001100));
    
    assign feqs  = ((opcode == 4'b1101) && (funct7 == 7'b1010000) && (funct3 == 3'b010));
    assign flts  = ((opcode == 4'b1101) && (funct7 == 7'b1010000) && (funct3 == 3'b001));
    assign fles  = ((opcode == 4'b1101) && (funct7 == 7'b1010000) && (funct3 == 3'b000));

    assign fsqrts = (opcode == 4'b1101) && (funct7 == 7'b0101100);
    assign fsgnjs = (opcode == 4'b1101) && (funct7 == 7'b0010000) && (funct3 == 3'b000);
    assign fsgnjns = (opcode == 4'b1101) && (funct7 == 7'b0010000) && (funct3 == 3'b001);
    assign fsgnjxs = (opcode == 4'b1101) && (funct7 == 7'b0010000) && (funct3 == 3'b010);
    assign fcvtsws = (opcode == 4'b1101) && (funct7 == 7'b1101000) && (funct3 == 3'b000);
    assign fcvtwss = (opcode == 4'b1101) && (funct7 == 7'b1100000) && (funct3 == 3'b000);
    assign fmvwxs = (opcode == 4'b1101) && (funct7 == 7'b1111000);
    
    assign iflag = ( add | sub | sll | slt | sltu | _xor | srl | sra | _or | _and | addi | slti | sltiu | xori | ori | 
                   andi | slli | srli | srai | beq | bne | blt | bltu | bge | bgeu | lui | jal | jalr | auipc | lw | sw | feqs | flts | fles | fcvtwss) ? 1 : 0;
    assign fflag = (fadds | fsubs | fmuls | fdivs | fsqrts | fsgnjs | fsgnjxs | fsgnjns | fcvtsws) ? 1 : 0;
            
    logic [31:0] imm_i;
    logic [31:0] imm_s;
    logic [31:0] imm_b;
    logic [31:0] imm_l;
    logic [31:0] imm_j;

    // I-type
    assign imm_i = $signed({f_inst[30:19]});

    // S-type
    assign imm_s = $signed({f_inst[30:25], f_inst[9:4]});

    // B-type
    assign imm_b = $signed({f_inst[30:25], f_inst[9:4], 2'b00});

    // L-type
    assign imm_l = $signed({f_inst[29:10], 12'b000000000000});

    // J-type
    assign imm_j = $signed({f_inst[29:10], 2'b00});

    (* mark_debug = "true" *) assign imm = (opcode == 4'b0001 | opcode == 4'b0010 | opcode == 4'b0011 | opcode == 4'b0100 | opcode == 4'b0101 | opcode == 4'b1011) ? imm_i :
                                           (opcode == 4'b0110 | opcode == 4'b1100) ? imm_s :
                                           (opcode == 4'b0111) ? imm_b :
                                           ((opcode == 4'b1000) | (opcode == 4'b1001)) ? imm_l : imm_j;
    

    assign {regwrite, alusrc, branch, memwrite, memtoreg, jump} = controls;
    
    assign controls = add  ? 10'b100000 :
                      sub  ? 10'b100000 :
                      sll  ? 10'b100000 : 
                      slt  ? 10'b100000 : 
                      sltu ? 10'b100000 : 
                      _xor ? 10'b100000 : 
                      srl  ? 10'b100000 : 
                      sra  ? 10'b100000 : 
                      _or  ? 10'b100000 : 
                      _and ? 10'b100000 : 
                      
                      addi ? 10'b110000 :
                      slti ? 10'b110000 : 
                      sltiu? 10'b110000 :
                      xori ? 10'b110000 : 
                      ori  ? 10'b110000 : 
                      andi ? 10'b110000 :
                      slli ? 10'b110000 :  
                      srli ? 10'b110000 : 
                      srai ? 10'b110000 : 

                      beq  ? 10'b001000 :
                      bne  ? 10'b001000 :
                      blt  ? 10'b001000 :
                      bltu ? 10'b001000 :
                      bge  ? 10'b001000 :
                      bgeu ? 10'b001000 :

                      jal  ? 10'b110001 :
                      jalr ? 10'b110001 :
                      lui  ? 10'b100000 : 
                      auipc? 10'b100000 :
                      in   ? 10'b000000 :
                      out  ? 10'b000000 :
                      lw   ? 10'b110010 :
                      sw   ? 10'b010100 :
                      
                      //fsgnjxs, fmvsx, fcvtsw, fcvtws,
                      flw     ? 10'b110010 : // ovbiously 0101, rs + imm
                      fsw     ? 10'b010100 : // too
                      fadds   ? 10'b100000 :
                      fsubs   ? 10'b100000 :
                      fmuls   ? 10'b100000 :
                      fdivs   ? 10'b100000 :
                      
                      fsqrts  ? 10'b100000 :

                      feqs    ? 10'b100000 : // no jump
                      flts    ? 10'b100000 :
                      fles    ? 10'b100000 : 
                      fsgnjs  ? 10'b100000 :
                      fsgnjxs ? 10'b100000 :
                      fsgnjns ? 10'b100000 :
                      fcvtsws ? 10'b100000 :
                      fcvtwss ? 10'b100000 :
                      fmvwxs  ? 10'b100000 : 0;

endmodule

`default_nettype wire