// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.07.19
// Instruction Decode Unit module
// Pure combinational logic
// branch and jump at id

`include "defines.v"

module idu(
    // if
    input [31:0]  i_instr,
    input [63:0]  i_instr_addr,
    output[63:0]  o_next_pc,

    // if control
    output        o_branch_jump,

    // reg_file
    input  [63:0]  i_rs1_rdata,
    input  [63:0]  i_rs2_rdata,
    output [4:0]   o_rs1_addr,
    output [4:0]   o_rs2_addr,
    output         o_rs1_cen,
    output         o_rs2_cen,

    // ex
    output [63:0]  o_imm,
    output [63:0]  o_rs1_rdata,
    output [63:0]  o_rs2_rdata,
    output [63:0]  o_pc,

    // ex control
    output [12:0] o_alu_info,
    output        o_op2_is_imm,
    output        o_op_is_jal,

    // ls control
    output [10:0] o_ls_info,
    output        o_mem_read,
    output        o_mem_write,

    // wb control
    output        o_rd_wen,
    output [4:0]  o_rd_addr,

    // ctrl hazard
    output        o_op_is_branch,
    input         i_forward_ex_rs1,
    input         i_forward_ex_rs2,
    input         i_forward_ls_rs1,
    input         i_forward_ls_rs2,
    input         i_ex_ls_mem_read,

    input [63:0]  i_exu_rd_data,
    input [63:0]  i_lsu_rd_data,
    input [63:0]  i_lsu_mem_rdata

);


//----------Pre decode--------------
wire [6:0]  opcode = i_instr[6:0];
wire [4:0]  rd     = i_instr[11:7];
wire [4:0]  rs1    = i_instr[19:15];
wire [4:0]  rs2    = i_instr[24:20];
wire [2:0]  func3  = i_instr[14:12];
wire [6:0]  func7  = i_instr[31:25];


wire instr_op_is_imm   = (opcode == `INSTR_I);
wire instr_op_is_alu   = (opcode == `INSTR_R);
wire instr_op_is_load  = (opcode == `INSTR_L);
wire instr_op_is_store = (opcode == `INSTR_S);
wire instr_op_is_jal   = (opcode == `INSTR_JAL);
wire instr_op_is_jalr  = (opcode == `INSTR_JALR);
wire instr_op_is_branch= (opcode == `INSTR_B);
wire instr_op_is_lui   = (opcode == `INSTR_LUI);
wire instr_op_is_auipc = (opcode == `INSTR_AUIPC);
wire instr_op_is_fence = (opcode == `INSTR_FENCE);
wire instr_op_is_csr   = (opcode == `INSTR_CSR);
wire instr_op_is_word  = (opcode == `INSTR_WORD);
wire instr_op_is_wordi = (opcode == `INSTR_WORDI);


wire func3_is_000 = (func3 == 3'b000);
wire func3_is_001 = (func3 == 3'b001);
wire func3_is_010 = (func3 == 3'b010);
wire func3_is_011 = (func3 == 3'b011);
wire func3_is_100 = (func3 == 3'b100);
wire func3_is_101 = (func3 == 3'b101);
wire func3_is_110 = (func3 == 3'b110);
wire func3_is_111 = (func3 == 3'b111);


wire func7_is_0000000 = (func7 == 7'b0000000);
wire func7_is_0100000 = (func7 == 7'b0100000);



//--------------ALU and imm ALU imm Instruction------------------------
wire instr_add    = instr_op_is_alu & func3_is_000 & func7_is_0000000;
wire instr_and    = instr_op_is_alu & func3_is_111 & func7_is_0000000;
wire instr_or     = instr_op_is_alu & func3_is_110 & func7_is_0000000;
wire instr_sll    = instr_op_is_alu & func3_is_001 & func7_is_0000000;
wire instr_slt    = instr_op_is_alu & func3_is_010 & func7_is_0000000;
wire instr_sltu   = instr_op_is_alu & func3_is_011 & func7_is_0000000;
wire instr_sra    = instr_op_is_alu & func3_is_101 & func7_is_0100000;
wire instr_srl    = instr_op_is_alu & func3_is_101 & func7_is_0000000;
wire instr_sub    = instr_op_is_alu & func3_is_000 & func7_is_0100000;
wire instr_xor    = instr_op_is_alu & func3_is_100 & func7_is_0000000;
wire instr_subw   = instr_op_is_word & func3_is_000 & func7_is_0100000;
wire instr_srlw   = instr_op_is_word & func3_is_101 & func7_is_0000000;
wire instr_sraw   = instr_op_is_word & func3_is_101 & func7_is_0100000;
wire instr_addw   = instr_op_is_word & func3_is_000 & func7_is_0000000;
wire instr_sllw   = instr_op_is_word & func3_is_001 & func7_is_0000000;

wire instr_tmp_0  = (i_instr[31:26] == 6'b000000);
wire instr_tmp_1  = (i_instr[31:26] == 6'b010000);

wire instr_addi   = instr_op_is_imm & func3_is_000;
wire instr_andi   = instr_op_is_imm & func3_is_111;
wire instr_ori    = instr_op_is_imm & func3_is_110;
wire instr_slli   = instr_op_is_imm & func3_is_001 & instr_tmp_0;
wire instr_slti   = instr_op_is_imm & func3_is_010;
wire instr_sltiu  = instr_op_is_imm & func3_is_011;
wire instr_srai   = instr_op_is_imm & func3_is_101 & instr_tmp_1;
wire instr_srli   = instr_op_is_imm & func3_is_101 & instr_tmp_0;
wire instr_xori   = instr_op_is_imm & func3_is_100;
wire instr_srliw  = instr_op_is_wordi & func3_is_101 & instr_tmp_0;
wire instr_sraiw  = instr_op_is_wordi & func3_is_101 & instr_tmp_1;
wire instr_addiw  = instr_op_is_wordi & func3_is_000;
wire instr_slliw  = instr_op_is_wordi & func3_is_001 & instr_tmp_0;


//---------Load and store-----------------------
wire instr_lb     = instr_op_is_load & func3_is_000;
wire instr_lbu    = instr_op_is_load & func3_is_100;
wire instr_ld     = instr_op_is_load & func3_is_011;
wire instr_lh     = instr_op_is_load & func3_is_001;
wire instr_lhu    = instr_op_is_load & func3_is_101;
wire instr_lw     = instr_op_is_load & func3_is_010;
wire instr_lwu    = instr_op_is_load & func3_is_110;
wire instr_sb     = instr_op_is_store & func3_is_000;
wire instr_sd     = instr_op_is_store & func3_is_011;
wire instr_sh     = instr_op_is_store & func3_is_001;
wire instr_sw     = instr_op_is_store & func3_is_010;
wire instr_load   = instr_op_is_load;
wire instr_store  = instr_op_is_store;


//-------------Ebreak Ecall----------------------
wire instr_ebreak = instr_op_is_csr & func3_is_000 & (i_instr[31:20] == 12'b0000_0000_0001);
wire instr_ecall  = instr_op_is_csr & func3_is_000 & (i_instr[31:20] == 12'b0000_0000_0000);


//--------------Branch jal jalr----------------
wire instr_beq    = instr_op_is_branch & func3_is_000;
wire instr_bge    = instr_op_is_branch & func3_is_101;
wire instr_bgeu   = instr_op_is_branch & func3_is_111;
wire instr_blt    = instr_op_is_branch & func3_is_100;
wire instr_bltu   = instr_op_is_branch & func3_is_110;
wire instr_bne    = instr_op_is_branch & func3_is_001;
wire instr_jal    = instr_op_is_jal;
wire instr_jalr   = instr_op_is_jalr;


//-----------Instruction's type-----------------------
wire instr_type_i = instr_op_is_imm
                  | instr_op_is_jalr
                  | instr_op_is_load
                  | instr_op_is_wordi;     // I type

wire instr_type_s = instr_op_is_store;     // S type

wire instr_type_b = instr_op_is_branch;    // B type

wire instr_type_u = instr_op_is_lui
                  | instr_op_is_auipc;     // U type

wire instr_type_j = instr_op_is_jal;       // J type


//-------------instruction is ALU operation------
wire op_alu_add   = instr_add | instr_addi | instr_addw | instr_addiw;
wire op_alu_sub   = instr_sub | instr_subw;
wire op_alu_slt   = instr_slt | instr_slti;
wire op_alu_sltu  = instr_sltu| instr_sltiu;
wire op_alu_xor   = instr_xor | instr_xori;
wire op_alu_sll   = instr_sll | instr_slli | instr_sllw | instr_slliw;
wire op_alu_srl   = instr_srl | instr_srli | instr_srlw | instr_srliw;
wire op_alu_sra   = instr_sra | instr_srai | instr_sraw | instr_sraiw;
wire op_alu_and   = instr_and | instr_andi;
wire op_alu_or    = instr_or  | instr_ori;

wire op_alu_lui   = instr_op_is_lui;

wire op_alu_auipc = instr_op_is_auipc;

wire op_alu_word  = instr_op_is_word | instr_op_is_wordi;

wire [12:0]op_alu_info = {
                    op_alu_or,
                    op_alu_add,
                    op_alu_sub,
                    op_alu_slt,
                    op_alu_sltu,
                    op_alu_xor,
                    op_alu_sll,
                    op_alu_srl,
                    op_alu_sra,
                    op_alu_and,
                    op_alu_lui,
                    op_alu_auipc,
                    op_alu_word
                    };


//-----------operation is load/store--------
wire [12:0] op_ls_info = {
                    instr_load,
                    instr_store,
                    instr_lb ,
                    instr_lbu,
                    instr_ld ,
                    instr_lh ,
                    instr_lhu,
                    instr_lw ,
                    instr_lwu,
                    instr_sb ,
                    instr_sd ,
                    instr_sh ,
                    instr_sw
                    };


//-------------instruction operation is other----------
wire op_ecall  = instr_ecall;

wire op_ebreak = instr_ebreak;




//---------Immediate number---------------

wire op2_is_imm =     instr_type_i
                    | instr_type_s
                    | instr_type_u
                    | instr_type_j;

wire [63:0] i_imm = {{52{i_instr[31]}},
                         i_instr[31:20]};

wire [63:0] s_imm = {{52{i_instr[31]}},
                         i_instr[31:25],
                         i_instr[11:7]};

wire [63:0] b_imm = {{51{i_instr[31]}},
                         i_instr[31],
                         i_instr[7],
                         i_instr[30:25],
                         i_instr[11:8],
                         1'b0};

wire [63:0] u_imm = {{32{i_instr[31]}},
                         i_instr[31:12],
                         12'b0};

wire [63:0] j_imm = {{43{i_instr[31]}},
                         i_instr[31],
                         i_instr[19:12],
                         i_instr[20],
                         i_instr[30:21],
                         1'b0};

wire [63:0] imm =
                  ({64{instr_type_i}} & i_imm)
                | ({64{instr_type_s}} & s_imm)
                | ({64{instr_type_b}} & b_imm)
                | ({64{instr_type_u}} & u_imm)
                | ({64{instr_type_j}} & j_imm)
                ;       // Use AND and OR Logic replace CASE


//------------branch/jal/jalr------------

wire signed [63:0] imm_signed = $signed(imm);
wire signed [63:0] pc_signed = $signed(i_instr_addr);

reg         [63:0] branch_op1;
reg         [63:0] branch_op2;
wire signed [63:0] branch_op1_signed = $signed(branch_op1);
wire signed [63:0] branch_op2_signed = $signed(branch_op2);

wire               forward_lsu_rs1_rd;
wire               forward_lsu_rs2_rd;
wire               forward_lsu_rs1_mem;
wire               forward_lsu_rs2_mem;

assign forward_lsu_rs1_rd = ~i_ex_ls_mem_read & i_forward_ls_rs1;
assign forward_lsu_rs2_rd = ~i_ex_ls_mem_read & i_forward_ls_rs2;
assign forward_lsu_rs1_mem = i_ex_ls_mem_read & i_forward_ls_rs1;
assign forward_lsu_rs2_mem = i_ex_ls_mem_read & i_forward_ls_rs2;


always @(*) begin
case ({i_forward_ex_rs1, forward_lsu_rs1_rd, forward_lsu_rs1_mem})
    3'b100  : branch_op1 = i_exu_rd_data;
    3'b010  : branch_op1 = i_lsu_rd_data;
    3'b001  : branch_op1 = i_lsu_mem_rdata;
    default : branch_op1 = i_rs1_rdata;
endcase
end

always @(*) begin
case ({i_forward_ex_rs2, forward_lsu_rs2_rd, forward_lsu_rs2_mem})
    3'b100  : branch_op2 = i_exu_rd_data;
    3'b010  : branch_op2 = i_lsu_rd_data;
    3'b001  : branch_op2 = i_lsu_mem_rdata;
    default : branch_op2 = i_rs2_rdata;
endcase
end

// beq
wire flag_beq = instr_beq & (branch_op1 == branch_op2);

// bne
wire flag_bne = instr_bne & (branch_op1 != branch_op2);

// blt
wire flag_blt = instr_blt & (branch_op1_signed < branch_op2_signed);

// bge
wire flag_bge = instr_bge & (branch_op1_signed >= branch_op2_signed);

// bltu
wire flag_bltu = instr_bltu & (branch_op1 < branch_op2);

// bgeu
wire flag_bgeu = instr_bgeu & (branch_op1 >= branch_op2);

wire flag_branch = flag_beq | flag_bne | flag_blt
                  |flag_bge | flag_bltu| flag_bgeu;


// branch jal next pc
wire signed[63:0] bjal_next_pc = pc_signed + imm_signed;

// jalr
wire signed[63:0] temp_jalr_next_pc = branch_op1_signed + imm_signed;
wire signed[63:0] jalr_next_pc = {temp_jalr_next_pc[63:1], 1'b0};



//-----------Output----------------
assign o_branch_jump = flag_branch | instr_jal | instr_jalr;

assign o_next_pc = ({64{flag_branch | instr_jal}} & bjal_next_pc)
                |  ({64{instr_jalr}}              & jalr_next_pc);

assign o_rs1_addr   = rs1;
assign o_rs2_addr   = rs2;
assign o_rs1_cen    = ~(instr_type_u | instr_type_j);
assign o_rs2_cen    = ~(instr_type_u | instr_type_j | instr_type_i);

assign o_imm        = imm;
assign o_rs1_rdata  = i_rs1_rdata;
assign o_rs2_rdata  = i_rs2_rdata;
assign o_pc         = i_instr_addr;

assign o_alu_info   = op_alu_info;
assign o_op2_is_imm = op2_is_imm;
assign o_op_is_jal  = instr_jal | instr_jalr;

assign o_ls_info    = op_ls_info[10:0];
assign o_mem_read   = op_ls_info[12];
assign o_mem_write  = op_ls_info[11];

assign o_rd_wen     = ~(instr_type_s | instr_type_b);
assign o_rd_addr    = rd;

assign o_op_is_branch = instr_op_is_branch | instr_op_is_jalr;

endmodule