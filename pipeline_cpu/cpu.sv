`default_nettype none

module cpu(

    input wire clk,
    input wire rstn,
    input wire empty,
    input wire [7:0] uart_in,
    (* mark_debug = "true" *) input wire [31:0] instruction,
    (* mark_debug = "true" *) output logic [7:0] uart_out,
    (* mark_debug = "true" *) output logic uart_ok_in,
    (* mark_debug = "true" *) output logic uart_ready_out,
    (* mark_debug = "true" *) output logic [31:0] pc,
    output logic [15:0] led,
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

    // Fetch stage
    logic [31:0] pc_prev;
    (* mark_debug = "true" *) logic [31:0] cnt;
    assign led = cnt[15:0];
    (* mark_debug = "true" *) logic stall;
    (* mark_debug = "true" *) logic [2:0] flush_delay;
    (* mark_debug = "true" *) logic [2:0] flush_delay2;
    (* mark_debug = "true" *) logic [2:0] stall_delay;
    
    // F reg
    logic [31:0] f_pc;
    (* mark_debug = "true" *) logic [31:0] f_inst;
    (* mark_debug = "true" *) logic [31:0] inst;

    // Decode stage
    (* mark_debug = "true" *) logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    (* mark_debug = "true" *) logic [5:0] rs1;
    (* mark_debug = "true" *) logic [5:0] rs2;
    (* mark_debug = "true" *) logic [5:0] rd;
    (* mark_debug = "true" *) logic [31:0] imm;

    logic iflag, fflag;
    logic memtoreg, memwrite;
    logic branch, alusrc;
    logic regwrite;
    logic jump;
    (* mark_debug = "true" *) logic add, sub, sll, slt, sltu, _xor, srl, sra, _or, _and, addi, slti, sltiu, xori, ori, andi, slli, srli, srai, 
          beq, bne, blt, bltu, bge, bgeu, lui, jal, jalr, auipc,
          flw, fsw, fadds, fsubs, fmuls, fdivs, feqs, flts, fles, fsqrts, fsgnjs, fsgnjxs, fsgnjns, fcvtsws, fcvtwss, fmvwxs; 
    (* mark_debug = "true" *) logic in, out, endp, lw, sw; 

    // D reg
    (* mark_debug = "true" *) logic [31:0] d_pc;
    logic [6:0] d_opcode;
    (* mark_debug = "true" *) logic [5:0] d_rs1;
    (* mark_debug = "true" *) logic [5:0] d_rs2;
    (* mark_debug = "true" *) logic [5:0] d_rd;
    (* mark_debug = "true" *) logic [31:0] d_op1;
    (* mark_debug = "true" *) logic [31:0] d_op2;
    (* mark_debug = "true" *) logic [31:0] d_op3;
    (* mark_debug = "true" *) logic [2:0] d_funct3;
    (* mark_debug = "true" *) logic [6:0] d_funct7;
    (* mark_debug = "true" *) logic [31:0] d_imm;
    (* mark_debug = "true" *) logic [31:0] rd1;
    (* mark_debug = "true" *) logic [31:0] rd2;
    (* mark_debug = "true" *) logic [31:0] rd3;

    logic d_iflag, d_fflag;
    logic d_memtoreg, d_memwrite;
    logic d_branch, d_alusrc;
    logic d_regwrite;
    logic d_jump;
    (* mark_debug = "true" *) logic d_add, d_sub, d_sll, d_slt, d_sltu, d__xor, d_srl, d_sra, d__or, d__and, d_addi, d_slti, d_sltiu, d_xori, 
                                    d_ori, d_andi, d_slli, d_srli, d_srai, 
                                    d_beq, d_bne, d_blt, d_bltu, d_bge, d_bgeu, d_lui, d_jal, d_jalr, d_auipc,
                                    d_flw, d_fsw, d_fadds, d_fsubs, d_fmuls, d_fdivs, d_feqs, d_flts, d_fles, d_fsqrts, 
                                    d_fsgnjs, d_fsgnjxs, d_fsgnjns, d_fcvtsws, d_fcvtwss, d_fmvwxs; 
    (* mark_debug = "true" *) logic d_in, d_out, d_endp, d_lw, d_sw; 
    

    // Decode to Exec
    (* mark_debug = "true" *) logic [31:0] aluresult;
    logic [31:0] fpuresult;
    (* mark_debug = "true" *) logic [31:0] wd3;
    (* mark_debug = "true" *) logic [31:0] ee_wd3;
    (* mark_debug = "true" *) logic pcsrc;
    logic [31:0] pcbranch;
    logic [31:0] next_pc;
    
    // E reg
    logic [31:0] e_pc;
    logic [6:0] e_opcode;
    logic [2:0] e_funct3;
    logic [6:0] e_funct7;
    (* mark_debug = "true" *) logic [5:0] e_rs1;
    (* mark_debug = "true" *) logic [5:0] e_rs2;
    (* mark_debug = "true" *) logic [5:0] e_rd;
    (* mark_debug = "true" *) logic [31:0] e_op2;
    //logic [31:0] e_fop2;
    logic e_iflag, e_fflag;
    logic e_memtoreg, e_memwrite;
    logic e_branch, e_alusrc;
    logic e_regwrite;
    logic e_jump;
    (* mark_debug = "true" *) logic e_add, e_sub, e_sll, e_slt, e_sltu, e__xor, e_srl, e_sra, e__or, e__and, e_addi, e_slti, e_sltiu, e_xori, 
                                    e_ori, e_andi, e_slli, e_srli, e_srai, 
                                    e_beq, e_bne, e_blt, e_bltu, e_bge, e_bgeu, e_lui, e_jal, e_jalr, e_auipc,
                                    e_flw, e_fsw, e_fadds, e_fsubs, e_fmuls, e_fdivs, e_feqs, e_flts, e_fles, e_fsqrts, 
                                    e_fsgnjs, e_fsgnjxs, e_fsgnjns, e_fcvtsws, e_fcvtwss, e_fmvwxs; 
    (* mark_debug = "true" *) logic e_in, e_out, e_endp, e_lw, e_sw; 
    
    (* mark_debug = "true" *) logic [31:0] e_wd3;
    logic e_pcsrc;
    logic [31:0] e_pcbranch;
    
    // M reg
    logic [31:0] m_pc;
    logic [6:0] m_opcode;
    logic [2:0] m_funct3;
    logic [6:0] m_funct7;
    (* mark_debug = "true" *) logic [5:0] m_rs1;
    (* mark_debug = "true" *) logic [5:0] m_rs2;
    (* mark_debug = "true" *) logic [5:0] m_rd;
    (* mark_debug = "true" *) logic [31:0] m_wd3;
    logic m_pcsrc;
    logic [31:0] m_pcbranch;
    logic m_iflag, m_fflag;
    logic m_memtoreg, m_memwrite;
    logic m_branch, m_alusrc;
    logic m_regwrite;
    logic m_jump;
    (* mark_debug = "true" *) logic m_add, m_sub, m_sll, m_slt, m_sltu, m__xor, m_srl, m_sra, m__or, m__and, m_addi, m_slti, m_sltiu, m_xori, 
                                    m_ori, m_andi, m_slli, m_srli, m_srai, 
                                    m_beq, m_bne, m_blt, m_bltu, m_bge, m_bgeu, m_lui, m_jal, m_jalr, m_auipc,
                                    m_flw, m_fsw, m_fadds, m_fsubs, m_fmuls, m_fdivs, m_feqs, m_flts, m_fles, m_fsqrts, 
                                    m_fsgnjs, m_fsgnjxs, m_fsgnjns, m_fcvtsws, m_fcvtwss, m_fmvwxs; 
    (* mark_debug = "true" *) logic m_in, m_out, m_endp, m_lw, m_sw; 
    

    // M to W
    (* mark_debug = "true" *) logic [31:0] w_pc;
    (* mark_debug = "true" *) logic [31:0] w_wd3;
    
    // stall
    (* mark_debug = "true" *) logic flush, stall_phases, stall_pc;

    // forwarding
    (* mark_debug = "true" *) logic f_rs1_e;
    (* mark_debug = "true" *) logic f_rs2_e;
    (* mark_debug = "true" *) logic f_rd_e;
    (* mark_debug = "true" *) logic f_rs1_m;
    (* mark_debug = "true" *) logic f_rs2_m;
    (* mark_debug = "true" *) logic f_rd_m;
    (* mark_debug = "true" *) logic f_rs1_w;
    (* mark_debug = "true" *) logic f_rs2_w;
    (* mark_debug = "true" *) logic f_rd_w;
    (* mark_debug = "true" *) logic e_trd;
    (* mark_debug = "true" *) logic e_ftrd;
    (* mark_debug = "true" *) logic m_trd;
    (* mark_debug = "true" *) logic m_ftrd;
    (* mark_debug = "true" *) logic w_trd;
    (* mark_debug = "true" *) logic w_ftrd;
    (* mark_debug = "true" *) logic d_fres;
    (* mark_debug = "true" *) logic e_fres;
    (* mark_debug = "true" *) logic m_fres;

    assign f_rd_e = (rd == d_rd) & (e_trd | e_ftrd);
    assign f_rs1_e = (rs1 == d_rd) & (e_trd | e_ftrd);
    assign f_rs2_e = (rs2 == d_rd) & (e_trd | e_ftrd);
    assign f_rd_m = (rd == e_rd) & (m_trd | m_ftrd);
    assign f_rs1_m = (rs1 == e_rd) & (m_trd | m_ftrd);
    assign f_rs2_m = (rs2 == e_rd) & (m_trd | m_ftrd);
    assign f_rd_w = (rd == m_rd) & (w_trd | w_ftrd);
    assign f_rs1_w = (rs1 == m_rd) & (w_trd | w_ftrd);
    assign f_rs2_w = (rs2 == m_rd) & (w_trd | w_ftrd);
    
    assign m_trd = (e_add | e_sub | e_sll | e_slt | e_sltu | e__xor | e_srl | e_sra | e__or | e__and | e_addi | e_slti | e_sltiu | e_xori | 
                    e_ori | e_andi | e_slli | e_srli | e_srai | e_lui | e_jal | e_jalr | e_auipc | e_in | e_lw |
                    e_feqs | e_flts | e_fles | e_fcvtwss);
    assign m_ftrd = (e_flw | e_fadds | e_fsubs | e_fmuls | e_fdivs | e_fsqrts | e_fsgnjs | e_fsgnjxs | e_fsgnjns | e_fcvtsws | e_fmvwxs);  
    assign w_trd = (m_add | m_sub | m_sll | m_slt | m_sltu | m__xor | m_srl | m_sra | m__or | m__and | m_addi | m_slti | m_sltiu | m_xori | 
                    m_ori | m_andi | m_slli | m_srli | m_srai | m_lui | m_jal | m_jalr | m_auipc | m_in | m_lw |
                    m_feqs | m_flts | m_fles | m_fcvtwss);
    assign w_ftrd = (m_flw | m_fadds | m_fsubs | m_fmuls | m_fdivs | m_fsqrts | m_fsgnjs | m_fsgnjxs | m_fsgnjns | m_fcvtsws | m_fmvwxs);  
    assign e_trd = (d_add | d_sub | d_sll | d_slt | d_sltu | d__xor | d_srl | d_sra | d__or | d__and | d_addi | d_slti | d_sltiu | d_xori | 
                    d_ori | d_andi | d_slli | d_srli | d_srai | d_lui | d_jal | d_jalr | d_auipc | d_in | d_lw |
                    d_feqs | d_flts | d_fles | d_fcvtwss);
    assign e_ftrd = (d_flw | d_fadds | d_fsubs | d_fmuls | d_fdivs | d_fsqrts | d_fsgnjs | d_fsgnjxs | d_fsgnjns | d_fcvtsws | d_fmvwxs);  
    
    (* mark_debug = "true" *) logic data_hazard;
    (* mark_debug = "true" *) logic hazard_delay;
    (* mark_debug = "true" *) logic data_stall;

    // pc
    always @(posedge clk) begin
        if (~rstn) begin
            pc <= signed'(0);
            pc_prev <= signed'(-4);
        end else begin
            pc <= (stall_pc) ? pc : w_pc;
            pc_prev <= (stall_pc) ? pc_prev : pc;
        end
    end
    
    always @(posedge clk) begin
        if (m_endp) begin 
            f_pc <= f_pc;
            f_inst <= f_inst;
        end else 
        if  ((~rstn) | flush) begin
            f_pc   <= 0;
            f_inst <= 15;
        end else begin
            f_pc <= (stall_phases) ? f_pc : pc_prev;
            f_inst <= (stall_phases) ? f_inst : instruction;
        end
    end

    //decode
    decoder decoder(.*);

    //decode phase
    
    always @(posedge clk) begin
        if ((~rstn) | (~stall_pc & flush) | (data_stall & (~stall))) begin
            d_pc <= 0;
            d_opcode <= 15;
            d_rs1 <= 0;
            d_rs2 <= 0;
            d_rd <= 0;
            d_funct3 <= 0;
            d_funct7 <= 0;
            d_imm <= 0;
            d_op3 <= 0;
            d_op1 <= 0;
            d_op2 <= 0;
            //d_fop3 <= 0;
            //d_fop1 <= 0;
            //d_fop2 <= 0;
            d_iflag <= 0;
            d_fflag <= 0;
            d_memtoreg <= 0;
            d_memwrite <= 0;
            d_branch <= 0;
            d_alusrc <= 0;
            d_regwrite <= 0;
            d_jump <= 0;
            d_add <= 0;
            d_sub <= 0;
            d_sll <= 0;
            d_slt <= 0;
            d_sltu <= 0;
            d__xor <= 0;
            d_srl <= 0;
            d_sra <= 0;
            d__or <= 0;
            d__and <= 0;
            d_addi <= 0;
            d_slti <= 0;
            d_sltiu <= 0;
            d_xori <= 0;
            d_ori <= 0;
            d_andi <= 0;
            d_slli <= 0;
            d_srli <= 0;
            d_srai <= 0;
            d_beq <= 0;
            d_bne <= 0;
            d_blt <= 0;
            d_bltu <= 0;
            d_bge <= 0;
            d_bgeu <= 0;
            d_lui <= 0;
            d_jal <= 0;
            d_jalr <= 0;
            d_auipc <= 0;
            d_flw <= 0;
            d_fsw <= 0;
            d_fadds <= 0;
            d_fsubs <= 0;
            d_fmuls <= 0;
            d_fdivs <= 0;
            d_feqs <= 0;
            d_flts <= 0;
            d_fles <= 0;
            d_fsqrts <= 0;
            d_fsgnjs <= 0;
            d_fsgnjxs <= 0;
            d_fsgnjns <= 0;
            d_fcvtsws <= 0;
            d_fcvtwss <= 0;
            d_fmvwxs <= 0; 
            d_in <= 0;
            d_out <= 0;
            d_endp <= 0;
            d_lw <= 0;
            d_sw <= 0; 
        end else if(~stall_phases) begin
            d_pc <= f_pc;
            d_opcode <= opcode;
            d_rs1 <= rs1;
            d_rs2 <= rs2;
            d_rd <= rd;
            d_funct3 <= funct3;
            d_funct7 <= funct7;
            d_imm <= imm;
            d_op3 <= (f_rd_e) ? ((d_fres) ? fpuresult : aluresult) :
                     (f_rd_m) ? ee_wd3 :
                     (f_rd_w) ? m_wd3 : rd3;
            d_op1 <= (f_rs1_e) ? ((d_fres) ? fpuresult : aluresult) :
                     (f_rs1_m) ? ee_wd3 :
                     (f_rs1_w) ? m_wd3 : rd1;
            d_op2 <= (f_rs2_e) ? ((d_fres) ? fpuresult : aluresult) :
                     (f_rs2_m) ? ee_wd3 :
                     (f_rs2_w) ? m_wd3 : rd2;
            d_iflag <= iflag;
            d_fflag <= fflag;
            d_memtoreg <= memtoreg;
            d_memwrite <= memwrite;
            d_branch <= branch;
            d_alusrc <= alusrc;
            d_regwrite <= regwrite;
            d_jump <= jump;
            d_add <= add;
            d_sub <= sub;
            d_sll <= sll;
            d_slt <= slt;
            d_sltu <= sltu;
            d__xor <= _xor;
            d_srl <= srl;
            d_sra <= sra;
            d__or <= _or;
            d__and <= _and;
            d_addi <= addi;
            d_slti <= slti;
            d_sltiu <= sltiu;
            d_xori <= xori;
            d_ori <= ori;
            d_andi <= andi;
            d_slli <= slli;
            d_srli <= srli;
            d_srai <= srai;
            d_beq <= beq;
            d_bne <= bne;
            d_blt <= blt;
            d_bltu <= bltu;
            d_bge <= bge;
            d_bgeu <= bgeu;
            d_lui <= lui;
            d_jal <= jal;
            d_jalr <= jalr;
            d_auipc <= auipc;
            d_flw <= flw;
            d_fsw <= fsw;
            d_fadds <= fadds;
            d_fsubs <= fsubs;
            d_fmuls <= fmuls;
            d_fdivs <= fdivs;
            d_feqs <= feqs;
            d_flts <= flts;
            d_fles <= fles;
            d_fsqrts <= fsqrts;
            d_fsgnjs <= fsgnjs;
            d_fsgnjxs <= fsgnjxs;
            d_fsgnjns <= fsgnjns;
            d_fcvtsws <= fcvtsws;
            d_fcvtwss <= fcvtwss;
            d_fmvwxs <= fmvwxs; 
            d_in <= in;
            d_out <= out;
            d_endp <= endp;
            d_lw <= lw;
            d_sw <= sw; 
        end
    end


    // exec stage
    (* mark_debug = "true" *) logic [31:0] src1;
    (* mark_debug = "true" *) logic [31:0] src2;
    assign src1 = (d_jump | d_auipc) ? d_pc : d_op1; 
    assign src2 = d_op2; 
    alu alu(.*);

    logic [31:0] x1;
    logic [31:0] x2;
    assign x1 = d_op1; 
    assign x2 = d_op2;
    (* mark_debug = "true" *) logic [31:0] y;
    (* mark_debug = "true" *) logic fpu_in;
    assign fpu_in = (d_fadds | d_fsubs | d_fmuls | d_fdivs | d_feqs | d_flts | d_fles | d_fsqrts | d_fsgnjs | d_fsgnjxs | d_fsgnjns | d_fcvtwss | d_fcvtsws);
    assign d_fres = (d_feqs | d_flts | d_fles | d_fcvtwss | d_fcvtsws | d_fflag);
    assign e_fres = (e_feqs | e_flts | e_fles | e_fcvtwss | e_fcvtsws | e_fflag);
    assign m_fres = (m_feqs | m_flts | m_fles | m_fcvtwss | m_fcvtsws | m_fflag);
    (* mark_debug = "true" *) logic fpu_out;
    (* mark_debug = "true" *) logic s9, s13, ss3, ss4, ss5, ss6;
    assign ss5 = (e_lw | e_flw);
    assign ss6 = (e_sw | e_fsw);
    fpu fpu(.*);
    assign fpuresult = y;
    (* mark_debug = "true" *) logic [31:0] e_alu;
    (* mark_debug = "true" *) logic [31:0] e_fpu;
    
    assign pcsrc = (d_branch & (aluresult & d_beq) | (aluresult & d_bne) | (aluresult & d_blt) | (aluresult & d_bltu) | (aluresult & d_bge) | (aluresult & d_bgeu)) | d_jump;
    assign pcbranch = (d_jal) ? d_imm + d_pc : 
                      (d_jalr) ? d_op1 + d_imm : d_imm + d_pc;
    assign w_pc = (~rstn) ? 0 : 
                  stall_pc ? pc :
                  pcsrc ? pcbranch : 
                  pc + 4;
    assign wd3 = d_fres ? fpuresult : 
                 aluresult;
                 
    always @(posedge clk) begin
        if (~rstn) begin
            
            e_wd3 <= 0;
            e_pcsrc <= 0;
            e_pcbranch <= 0;
            e_pc <= 0;
            e_opcode <= 0;
            e_funct3 <= 0;
            e_funct7 <= 0;
            e_rs1 <= 0;
            e_rs2 <= 0;
            e_rd <= 0;
            e_op2 <= 0;
            e_iflag <= 0;
            e_fflag <= 0;
            e_memtoreg <= 0;
            e_memwrite <= 0;
            e_branch <= 0;
            e_alusrc <= 0;
            e_regwrite <= 0;
            e_jump <= 0;
            e_add <= 0;
            e_sub <= 0;
            e_sll <= 0;
            e_slt <= 0;
            e_sltu <= 0;
            e__xor <= 0;
            e_srl <= 0;
            e_sra <= 0;
            e__or <= 0;
            e__and <= 0;
            e_addi <= 0;
            e_slti <= 0;
            e_sltiu <= 0;
            e_xori <= 0;
            e_ori <= 0;
            e_andi <= 0;
            e_slli <= 0;
            e_srli <= 0;
            e_srai <= 0;
            e_beq <= 0;
            e_bne <= 0;
            e_blt <= 0;
            e_bltu <= 0;
            e_bge <= 0;
            e_bgeu <= 0;
            e_lui <= 0;
            e_jal <= 0;
            e_jalr <= 0;
            e_auipc <= 0;
            e_flw <= 0;
            e_fsw <= 0;
            e_fadds <= 0;
            e_fsubs <= 0;
            e_fmuls <= 0;
            e_fdivs <= 0;
            e_feqs <= 0;
            e_flts <= 0;
            e_fles <= 0;
            e_fsqrts <= 0;
            e_fsgnjs <= 0;
            e_fsgnjxs <= 0;
            e_fsgnjns <= 0;
            e_fcvtsws <= 0;
            e_fcvtwss <= 0;
            e_fmvwxs <= 0; 
            e_in <= 0;
            e_out <= 0;
            e_endp <= 0;
            e_lw <= 0;
            e_sw <= 0;

        end else if (~stall) begin
        
            e_wd3 <= wd3;
            e_alu <= aluresult;
            e_fpu <= fpuresult;
            e_pcsrc <= pcsrc;
            e_pcbranch <= pcbranch;
            
            e_pc <= d_pc;
            e_opcode <= d_opcode;
            e_funct3 <= d_funct3;
            e_funct7 <= d_funct7;
            e_rs1 <= d_rs1;
            e_rs2 <= d_rs2;
            e_rd <= d_rd;
            e_op2 <= d_op2;
            e_iflag <= d_iflag;
            e_fflag <= d_fflag;
            e_memtoreg <= d_memtoreg;
            e_memwrite <= d_memwrite;
            e_branch <= d_branch;
            e_alusrc <= d_alusrc;
            e_regwrite <= d_regwrite;
            e_jump <= d_jump;
            e_add <= d_add;
            e_sub <= d_sub;
            e_sll <= d_sll;
            e_slt <= d_slt;
            e_sltu <= d_sltu;
            e__xor <= d__xor;
            e_srl <= d_srl;
            e_sra <= d_sra;
            e__or <= d__or;
            e__and <= d__and;
            e_addi <= d_addi;
            e_slti <= d_slti;
            e_sltiu <= d_sltiu;
            e_xori <= d_xori;
            e_ori <= d_ori;
            e_andi <= d_andi;
            e_slli <= d_slli;
            e_srli <= d_srli;
            e_srai <= d_srai;
            e_beq <= d_beq;
            e_bne <= d_bne;
            e_blt <= d_blt;
            e_bltu <= d_bltu;
            e_bge <= d_bge;
            e_bgeu <= d_bgeu;
            e_lui <= d_lui;
            e_jal <= d_jal;
            e_jalr <= d_jalr;
            e_auipc <= d_auipc;
            e_flw <= d_flw;
            e_fsw <= d_fsw;
            e_fadds <= d_fadds;
            e_fsubs <= d_fsubs;
            e_fmuls <= d_fmuls;
            e_fdivs <= d_fdivs;
            e_feqs <= d_feqs;
            e_flts <= d_flts;
            e_fles <= d_fles;
            e_fsqrts <= d_fsqrts;
            e_fsgnjs <= d_fsgnjs;
            e_fsgnjxs <= d_fsgnjxs;
            e_fsgnjns <= d_fsgnjns;
            e_fcvtsws <= d_fcvtsws;
            e_fcvtwss <= d_fcvtwss;
            e_fmvwxs <= d_fmvwxs; 
            e_in <= d_in;
            e_out <= d_out;
            e_endp <= d_endp;
            e_lw <= d_lw;
            e_sw <= d_sw; 

        end
    end


    // mem stage
    (* mark_debug = "true" *) assign core_ARVALID = (e_lw | e_flw);
    (* mark_debug = "true" *) assign core_ARADDR = (e_fres) ? e_fpu : e_alu;
    (* mark_debug = "true" *) assign core_AWVALID = (e_sw | e_fsw);
    (* mark_debug = "true" *) assign core_AWADDR = (e_fres) ? e_fpu : e_alu;
    (* mark_debug = "true" *) assign core_WDATA = e_op2;
    logic [31:0] core_rdata;

    assign ee_wd3 = //(s9) ? core_rdata :
                    (e_lw | e_flw) ? core_RDATA :
                    (e_in) ? uart_in :
                    (e_fres) ? e_fpu : e_alu;
    
    always @(posedge clk) begin
        if (~rstn) begin

            m_wd3 <= 0;
            m_pcsrc <= 0;
            m_pcbranch <= 0;
            m_pc <= 0;
            m_opcode <= 0;
            m_funct3 <= 0;
            m_funct7 <= 0;
            m_rs1 <= 0;
            m_rs2 <= 0;
            m_rd <= 0;
            m_iflag <= 0;
            m_fflag <= 0;
            m_memtoreg <= 0;
            m_memwrite <= 0;
            m_branch <= 0;
            m_alusrc <= 0;
            m_regwrite <= 0;
            m_jump <= 0;
            m_add <= 0;
            m_sub <= 0;
            m_sll <= 0;
            m_slt <= 0;
            m_sltu <= 0;
            m__xor <= 0;
            m_srl <= 0;
            m_sra <= 0;
            m__or <= 0;
            m__and <= 0;
            m_addi <= 0;
            m_slti <= 0;
            m_sltiu <= 0;
            m_xori <= 0;
            m_ori <= 0;
            m_andi <= 0;
            m_slli <= 0;
            m_srli <= 0;
            m_srai <= 0;
            m_beq <= 0;
            m_bne <= 0;
            m_blt <= 0;
            m_bltu <= 0;
            m_bge <= 0;
            m_bgeu <= 0;
            m_lui <= 0;
            m_jal <= 0;
            m_jalr <= 0;
            m_auipc <= 0;
            m_flw <= 0;
            m_fsw <= 0;
            m_fadds <= 0;
            m_fsubs <= 0;
            m_fmuls <= 0;
            m_fdivs <= 0;
            m_feqs <= 0;
            m_flts <= 0;
            m_fles <= 0;
            m_fsqrts <= 0;
            m_fsgnjs <= 0;
            m_fsgnjxs <= 0;
            m_fsgnjns <= 0;
            m_fcvtsws <= 0;
            m_fcvtwss <= 0;
            m_fmvwxs <= 0; 
            m_in <= 0;
            m_out <= 0;
            m_endp <= 0;
            m_lw <= 0;
            m_sw <= 0;
        end else begin
            m_wd3 <= ee_wd3;
            m_pcsrc <= e_pcsrc;
            m_pcbranch <= e_pcbranch;
            m_pc <= e_pc;
            m_opcode <= e_opcode;
            m_funct3 <= e_funct3;
            m_funct7 <= e_funct7;
            m_rs1 <= e_rs1;
            m_rs2 <= e_rs2;
            m_rd <= e_rd;
            m_iflag <= e_iflag;
            m_fflag <= e_fflag;
            m_memtoreg <= e_memtoreg;
            m_memwrite <= e_memwrite;
            m_branch <= e_branch;
            m_alusrc <= e_alusrc;
            m_regwrite <= e_regwrite;
            m_jump <= e_jump;
            m_add <= e_add;
            m_sub <= e_sub;
            m_sll <= e_sll;
            m_slt <= e_slt;
            m_sltu <= e_sltu;
            m__xor <= e__xor;
            m_srl <= e_srl;
            m_sra <= e_sra;
            m__or <= e__or;
            m__and <= e__and;
            m_addi <= e_addi;
            m_slti <= e_slti;
            m_sltiu <= e_sltiu;
            m_xori <= e_xori;
            m_ori <= e_ori;
            m_andi <= e_andi;
            m_slli <= e_slli;
            m_srli <= e_srli;
            m_srai <= e_srai;
            m_beq <= e_beq;
            m_bne <= e_bne;
            m_blt <= e_blt;
            m_bltu <= e_bltu;
            m_bge <= e_bge;
            m_bgeu <= e_bgeu;
            m_lui <= e_lui;
            m_jal <= e_jal;
            m_jalr <= e_jalr;
            m_auipc <= e_auipc;
            m_flw <= e_flw;
            m_fsw <= e_fsw;
            m_fadds <= e_fadds;
            m_fsubs <= e_fsubs;
            m_fmuls <= e_fmuls;
            m_fdivs <= e_fdivs;
            m_feqs <= e_feqs;
            m_flts <= e_flts;
            m_fles <= e_fles;
            m_fsqrts <= e_fsqrts;
            m_fsgnjs <= e_fsgnjs;
            m_fsgnjxs <= e_fsgnjxs;
            m_fsgnjns <= e_fsgnjns;
            m_fcvtsws <= e_fcvtsws;
            m_fcvtwss <= e_fcvtwss;
            m_fmvwxs <= e_fmvwxs; 
            m_in <= e_in;
            m_out <= e_out;
            m_endp <= e_endp;
            m_lw <= e_lw;
            m_sw <= e_sw;
        end
    end

    logic we3;
    (* mark_debug = "true" *) logic [31:0] mm_wd3;
    assign mm_wd3 = m_wd3; 
    assign we3 = m_regwrite; 
    register_file register_file(.*);
    
    // stall
    (* mark_debug = "true" *) logic s1, s2, s3, s4, s5, s6, s7, s8, s10, s11, s12;
    assign s1 = m_endp;
    assign s2 = (e_in) ? ((uart_ok_in & (~empty)) ? 0 : 1) : 0;
    assign s3 = (e_lw | e_flw) ? ((core_RVALID) ? 0 : 1) : 0;
    assign s4 = (e_sw | e_fsw) ? ((core_BVALID) ? 0 : 1) : 0;
    assign s5 = (d_feqs | d_flts | d_fles | d_fcvtwss | d_fcvtsws | d_fflag) ? ((fpu_out) ? 0 : 1) : 0;
    assign stall = (s1 | s2 | s3 | s4 | s5);
    always @(posedge clk) begin
        if (~rstn) begin
            ss3 <= 0;
            ss4 <= 0;
        end else begin
            if (core_RVALID) begin
                ss3 <= 1;
            end else begin
                ss3 <= 0;
            end
            if (core_BVALID) begin
                ss4 <= 1;
            end else begin
                ss4 <= 0;
            end
        end
    end
        
    always @(posedge clk) begin
        if (~rstn) begin
            s6 <= 0;
            s7 <= 0;
            s8 <= 0;
            s9 <= 0;
            core_rdata <= 0;
        end else begin
            if (s3 & s5) begin 
                s6 <= 1;
            end
            if (s6 == 1 && s7 == 0 && s8 == 0) begin
                if(s3 == 0 && s5 == 1) begin
                    s7 <= 1;
                end else if(s3 == 1 && s5 == 0) begin
                    s8 <= 1;
                end else if(s3 == 0 && s5 == 0) begin
                    s6 <= 0;
                    s9 <= 1;
                end
            end
            if (s7 == 1 && s5 == 0) begin
                s6 <= 0;
                s7 <= 0;
                //s9 <= 1;
                core_rdata <= core_RDATA;
            end
            if (s8 == 1 && s3 == 0) begin
                s6 <= 0;
                s8 <= 0;
                s9 <= 1;
                core_rdata <= core_RDATA;
            end
            if (s9) begin
                s9 <= 0;
            end
        end
    end
    
    always @(posedge clk) begin
        if (~rstn) begin
            s10 <= 0;
            s11 <= 0;
            s12 <= 0;
            s13 <= 0;
        end else begin
            if (s4 & s5) begin 
                s10 <= 1;
            end
            if (s10 == 1 && s11 == 0 && s12 == 0) begin
                if(s4 == 0 && s5 == 1) begin
                    s11 <= 1;
                end else if(s4 == 1 && s5 == 0) begin
                    s12 <= 1;
                end else if(s4 == 0 && s5 == 0) begin
                    s10 <= 0;
                    s13 <= 1;
                end
            end
            if (s11 == 1 && s5 == 0) begin
                s10 <= 0;
                s11 <= 0;
                //s13 <= 1;
            end
            if (s12 == 1 && s3 == 0) begin
                s10 <= 0;
                s12 <= 0;
                s13 <= 1;
            end
            if (s13) begin
                s13 <= 0;
            end
        end
    end

    assign stall_pc     = stall | data_stall;
    assign stall_phases = stall | data_stall | (pc == 0);
    assign flush        = pcsrc | flush_delay;
    assign data_hazard = (~hazard_delay) & ((f_rd_e | f_rs1_e | f_rs2_e) & (d_lw | d_in | d_flw));
    assign data_stall = data_hazard | hazard_delay;
    
    always @(posedge clk) begin
        flush_delay <= (~rstn) ? 0 :
                       (pcsrc) ? 1 :
                       (flush_delay == 0) ? 0 : flush_delay - 1;
        flush_delay2 <= (~rstn) ? 0 :
                       (pcsrc) ? 2 :
                       (flush_delay2 == 0) ? 0 : flush_delay2 - 1;
        stall_delay <= (~rstn) ? 0 :
                       (stall_pc) ? 2 :
                       (stall_delay == 0) ? 0 : stall_delay - 1;
        hazard_delay <= (~rstn) ? 0 :
                        (data_hazard & stall) ? 1 :
                        ((hazard_delay == 1) & stall) ? 1 : 0;
    end
    
    always @(posedge clk) begin
        if (~rstn) begin
            cnt <= signed'(-4);
        end else begin
            cnt <= (stall_phases | (|flush_delay2) | flush) ? cnt : cnt + 1;
        end
      end
   
    assign pc_flag = (~rstn | stall_pc) ? 0 : 1; 
    always_ff @ (posedge clk) begin

        if (e_in & (~empty) & (~uart_ok_in)) begin
            uart_ok_in <= 1;
        end else begin
            uart_ok_in <= 0;
        end

        if (m_out) begin
            uart_ready_out <= 1;
        end else begin
            uart_ready_out <= 0;
        end
            
    end

endmodule

`default_nettype wire
