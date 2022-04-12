// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.08.31
// Instruction Decode Unit module
// Pure combinational logic
// branch and jump at id

`include "defines.v"

module idu(
    // ifu ports
    input [63:0]  pc_i,
    input [31:0]  instr_i,
    input         instr_valid_i,
    output        idu_jump_o,
    output[63:0]  idu_jump_pc_o,


    // reg_file ports
    input  [63:0] rs1_rdata_i,
    input  [63:0] rs2_rdata_i,
    output [4:0]  idu_rs1_addr_o,
    output [4:0]  idu_rs2_addr_o,
    output        idu_rs1_cen_o,
    output        idu_rs2_cen_o,

    // exu ports
    output [63:0] idu_imm_o,
    output [63:0] idu_rs1_rdata_o,
    output [63:0] idu_rs2_rdata_o,
    output [63:0] idu_pc_o,
    output [12:0] idu_alu_info_o,
    output [8:0]  idu_csr_info_o,
    output        idu_op2_is_imm_o,
    output        idu_op_is_jal_o,

    // ls control
    output [10:0] idu_ls_info_o,
    output        idu_mem_read_o,
    output        idu_mem_write_o,

    // wb control
    output        idu_rd_wen_o,
    output [4:0]  idu_rd_addr_o,

    // ctrl hazard
    output        idu_op_is_branch_o,
    input         forward_ex_rs1_i,
    input         forward_ex_rs2_i,
    input         forward_ls_rs1_i,
    input         forward_ls_rs2_i,
    input         ex_ls_mem_read_i,
    input [63:0]  exu_rd_data_i,
    input [63:0]  lsu_rd_data_i,
    input [63:0]  lsu_mem_rdata_i,

    // csr ports
    input  [63:0] csr_rdata_i,
    output        idu_csr_wen_o,
    output [63:0] idu_csr_rdata_o,
    output [11:0] idu_csr_raddr_o,
    output [11:0] idu_csr_waddr_o

);


//----------Pre decode--------------
wire [6:0]  opcode = {7{instr_valid_i}} & instr_i[6:0];
wire [4:0]  rd     = {5{instr_valid_i}} & instr_i[11:7];
wire [4:0]  rs1    = {5{instr_valid_i}} & instr_i[19:15];
wire [4:0]  rs2    = {5{instr_valid_i}} & instr_i[24:20];
wire [2:0]  func3  = {3{instr_valid_i}} & instr_i[14:12];
wire [6:0]  func7  = {7{instr_valid_i}} & instr_i[31:25];
wire [11:0] csr    = {12{instr_valid_i}}& instr_i[31:20];


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
wire instr_op_is_sys   = (opcode == `INSTR_SYS);
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
wire func7_is_0011000 = (func7 == 7'b0011000);



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

wire instr_tmp_0  = (instr_i[31:26] == 6'b000000);
wire instr_tmp_1  = (instr_i[31:26] == 6'b010000);

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


//-------------Exception or CSR----------------------
wire instr_ebreak = instr_op_is_sys & func3_is_000 & func7_is_0000000 & (rs2 == 5'b1);
wire instr_ecall  = instr_op_is_sys & func3_is_000 & func7_is_0000000 & (rs2 == 5'b0);
wire instr_mret   = instr_op_is_sys & func3_is_000 & func7_is_0011000 & (rs2 == 5'b10);

wire instr_csrrw  = instr_op_is_sys & func3_is_001;
wire instr_csrrs  = instr_op_is_sys & func3_is_010;
wire instr_csrrc  = instr_op_is_sys & func3_is_011;
wire instr_csrrwi = instr_op_is_sys & func3_is_101;
wire instr_csrrsi = instr_op_is_sys & func3_is_110;
wire instr_csrrci = instr_op_is_sys & func3_is_111;

wire instr_csri    =  instr_csrrwi
                    | instr_csrrsi
                    | instr_csrrci
                    ;

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


//-------------operation is ALU ------------------------
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


//-------------operation is Exception or CSR----------
wire [8:0] op_csr_info = {
                         instr_ecall,
                         instr_ebreak,
                         instr_mret,
                         instr_csrrw,
                         instr_csrrs,
                         instr_csrrc,
                         instr_csrrwi,
                         instr_csrrsi,
                         instr_csrrci
                        };


//---------Immediate number---------------

wire op2_is_imm =     instr_type_i
                    | instr_type_s
                    | instr_type_u
                    | instr_type_j;

wire [63:0] i_imm = {{52{instr_i[31]}},
                         instr_i[31:20]};

wire [63:0] s_imm = {{52{instr_i[31]}},
                         instr_i[31:25],
                         instr_i[11:7]};

wire [63:0] b_imm = {{51{instr_i[31]}},
                         instr_i[31],
                         instr_i[7],
                         instr_i[30:25],
                         instr_i[11:8],
                         1'b0};

wire [63:0] u_imm = {{32{instr_i[31]}},
                         instr_i[31:12],
                         12'b0};

wire [63:0] j_imm = {{43{instr_i[31]}},
                         instr_i[31],
                         instr_i[19:12],
                         instr_i[20],
                         instr_i[30:21],
                         1'b0};

wire [63:0] csr_imm = {59'b0, rs1};

wire [63:0] imm =
                  ({64{instr_type_i}} & i_imm)
                | ({64{instr_type_s}} & s_imm)
                | ({64{instr_type_b}} & b_imm)
                | ({64{instr_type_u}} & u_imm)
                | ({64{instr_type_j}} & j_imm)
                | ({64{instr_csri}}   & csr_imm)
                ;


//------------branch/jal/jalr------------

wire signed [63:0] imm_signed = $signed(imm);
wire signed [63:0] pc_signed  = $signed(pc_i);

reg         [63:0] branch_op1;
reg         [63:0] branch_op2;
wire signed [63:0] branch_op1_signed = $signed(branch_op1);
wire signed [63:0] branch_op2_signed = $signed(branch_op2);

wire               forward_lsu_rs1_rd;
wire               forward_lsu_rs2_rd;
wire               forward_lsu_rs1_mem;
wire               forward_lsu_rs2_mem;

assign forward_lsu_rs1_rd = ~ex_ls_mem_read_i & forward_ls_rs1_i;
assign forward_lsu_rs2_rd = ~ex_ls_mem_read_i & forward_ls_rs2_i;
assign forward_lsu_rs1_mem = ex_ls_mem_read_i & forward_ls_rs1_i;
assign forward_lsu_rs2_mem = ex_ls_mem_read_i & forward_ls_rs2_i;


always @(*) begin
case ({forward_ex_rs1_i, forward_lsu_rs1_rd, forward_lsu_rs1_mem})
    3'b100  : branch_op1 = exu_rd_data_i;
    3'b010  : branch_op1 = lsu_rd_data_i;
    3'b001  : branch_op1 = lsu_mem_rdata_i;
    default : branch_op1 = rs1_rdata_i;
endcase
end

always @(*) begin
case ({forward_ex_rs2_i, forward_lsu_rs2_rd, forward_lsu_rs2_mem})
    3'b100  : branch_op2 = exu_rd_data_i;
    3'b010  : branch_op2 = lsu_rd_data_i;
    3'b001  : branch_op2 = lsu_mem_rdata_i;
    default : branch_op2 = rs2_rdata_i;
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
assign idu_jump_o = flag_branch | instr_jal | instr_jalr;

assign idu_jump_pc_o = ({64{flag_branch | instr_jal}} & bjal_next_pc)
                    |  ({64{instr_jalr}}              & jalr_next_pc);

assign idu_rs1_addr_o   = rs1;
assign idu_rs2_addr_o   = rs2;
assign idu_rs1_cen_o    = ~(instr_type_u | instr_type_j);
assign idu_rs2_cen_o    = ~(instr_type_u | instr_type_j | instr_type_i);

assign idu_imm_o        = imm;
assign idu_rs1_rdata_o  = rs1_rdata_i;
assign idu_rs2_rdata_o  = rs2_rdata_i;
assign idu_pc_o         = pc_i;

assign idu_alu_info_o   = op_alu_info;
assign idu_csr_info_o   = op_csr_info;
assign idu_op2_is_imm_o = op2_is_imm;
assign idu_op_is_jal_o  = instr_jal | instr_jalr;

assign idu_ls_info_o    = op_ls_info[10:0];
assign idu_mem_read_o   = op_ls_info[12];
assign idu_mem_write_o  = op_ls_info[11];

assign idu_rd_wen_o     = (~instr_type_s) &
                      (~instr_type_b) &
                      (~instr_ebreak) &
                      (~instr_ecall ) &
                      (~instr_mret  ) &
                      (~instr_op_is_fence) &
                      ~(instr_i == 32'd0)
                    ;

assign idu_rd_addr_o    = rd;

assign idu_op_is_branch_o = instr_op_is_branch | instr_op_is_jalr;


assign idu_csr_raddr_o  = csr;
assign idu_csr_waddr_o  = csr;
assign idu_csr_rdata_o  = csr_rdata_i;

assign idu_csr_wen_o    = instr_csrrw
                    | instr_csrrs
                    | instr_csrrc;


endmodule