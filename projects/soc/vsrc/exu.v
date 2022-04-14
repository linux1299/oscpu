// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.07.18
// Execute unit
// As known as "EX"

`include "defines.v"

module exu(
    // idu ports
    input   [63:0] imm_i,
    input   [63:0] rs1_rdata_i,
    input   [63:0] rs2_rdata_i,
    input   [63:0] csr_rdata_i,
    input   [63:0] pc_i,

    // ex control
    input   [12:0] alu_info_i,
    input   [5:0]  csr_info_i,
    input          op2_is_imm_i,
    input          op_is_jal_i,

    // wbu
    input          rd_wen_i,
    output         exu_rd_wen_o,
    input   [4:0]  rd_addr_i,
    output  [63:0] exu_rd_data_o,
    output  [4:0]  exu_rd_addr_o,

    // ls
    input   [10:0] ls_info_i,
    input          mem_read_i,
    input          mem_write_i,
    output  [63:0] exu_mem_addr_o,
    output  [63:0] exu_mem_wdata_o,
    output  [10:0] exu_ls_info_o,
    output         exu_mem_read_o,
    output         exu_mem_write_o,

    // forward control
    input          forward_ex_rs1_i,
    input          forward_ex_rs2_i,
    input          forward_ls_rs1_i,
    input          forward_ls_rs2_i,
    input   [63:0] ex_ls_rd_data_i,
    input   [63:0] wbu_rd_wdata_i,

    // csr
    input          csr_wen_i,
    input   [11:0] csr_waddr_i,
    output  [63:0] exu_csr_wdata_o,
    output         exu_csr_wen_o,
    output  [11:0] exu_csr_waddr_o


);


//---------------Variables declaration------------------------
wire op_alu_or    = alu_info_i[12];
wire op_alu_add   = alu_info_i[11] & ~alu_info_i[0];
wire op_alu_sub   = alu_info_i[10] & ~alu_info_i[0];
wire op_alu_slt   = alu_info_i[ 9];
wire op_alu_sltu  = alu_info_i[ 8];
wire op_alu_xor   = alu_info_i[ 7];
wire op_alu_sll   = alu_info_i[ 6] & ~alu_info_i[0];
wire op_alu_srl   = alu_info_i[ 5] & ~alu_info_i[0];
wire op_alu_sra   = alu_info_i[ 4] & ~alu_info_i[0];
wire op_alu_and   = alu_info_i[ 3];
wire op_alu_lui   = alu_info_i[ 2];
wire op_alu_auipc = alu_info_i[ 1];
wire op_alu_word  = alu_info_i[ 0];
wire op_alu_addw  = alu_info_i[11] & alu_info_i[0];
wire op_alu_subw  = alu_info_i[10] & alu_info_i[0];
wire op_alu_sllw  = alu_info_i[ 6] & alu_info_i[0];
wire op_alu_srlw  = alu_info_i[ 5] & alu_info_i[0];
wire op_alu_sraw  = alu_info_i[ 4] & alu_info_i[0];

wire op_csr_csrrw = csr_info_i[5];
wire op_csr_csrrs = csr_info_i[4];
wire op_csr_csrrc = csr_info_i[3];
wire op_csr_csrrwi= csr_info_i[2];
wire op_csr_csrrsi= csr_info_i[1];
wire op_csr_csrrci= csr_info_i[0];
wire op_csr       = op_csr_csrrw
                  | op_csr_csrrs
                  | op_csr_csrrc
                  | op_csr_csrrwi
                  | op_csr_csrrsi
                  | op_csr_csrrci
                  ;


wire signed [63:0] add_rd_data;
wire signed [63:0] sub_rd_data;
wire        [63:0] slt_rd_data;
wire        [63:0] sltu_rd_data;
wire        [63:0] xor_rd_data;
wire        [63:0] sll_rd_data;
wire        [63:0] srl_rd_data;
wire signed [63:0] sra_rd_data;
wire        [63:0] and_rd_data;
wire        [63:0] or_rd_data;
wire        [63:0] lui_rd_data;
wire signed [63:0] auipc_rd_data;
wire        [63:0] addw_rd_data;
wire        [63:0] subw_rd_data;
wire        [63:0] sllw_rd_data;
wire        [63:0] srlw_rd_data;
wire        [63:0] sraw_rd_data;
wire        [63:0] jal_rd_data;

wire        [31:0] sllw_temp;
wire        [31:0] srlw_temp;
wire signed [31:0] sraw_temp;

wire        [63:0] csrrw_wdata;
wire        [63:0] csrrs_wdata;
wire        [63:0] csrrc_wdata;
wire        [63:0] csrrwi_wdata;
wire        [63:0] csrrsi_wdata;
wire        [63:0] csrrci_wdata;

reg         [63:0] op1;
reg         [63:0] op2;

wire signed [63:0] op1_signed;
wire signed [63:0] op2_signed;

wire        [31:0] op1_word;
wire signed [31:0] op1_word_signed;

wire signed [63:0] pc_signed;

wire op1_lt_op2_signed;
wire op1_lt_op2_unsigned;

wire [5:0] shift_bits;

//-----------------OP-------------------------
always @(*) begin
    case ({forward_ex_rs1_i, forward_ls_rs1_i})
        2'b10   : op1 = ex_ls_rd_data_i;
        2'b01   : op1 = wbu_rd_wdata_i;
        default : op1 = rs1_rdata_i;
    endcase
end

always @(*) begin
    casez ({forward_ex_rs2_i, forward_ls_rs2_i, op2_is_imm_i})
        3'b100  : op2 = ex_ls_rd_data_i;
        3'b010  : op2 = wbu_rd_wdata_i;
        3'b??1  : op2 = imm_i;
        default : op2 = rs2_rdata_i;
    endcase
end

assign op1_signed = $signed(op1);
assign op2_signed = $signed(op2);

assign op1_word        = op1[31:0];
assign op1_word_signed = $signed(op1_word);

assign pc_signed  = $signed(pc_i);
assign shift_bits = op2[5:0];


//----------------ALU---------------------

// add addi
assign add_rd_data   = op1_signed + op2_signed;

// sub subw
assign sub_rd_data   = op1_signed - op2_signed;

// slt slti
assign op1_lt_op2_signed = op1_signed < op2_signed;
assign slt_rd_data       = {{63{1'b0}}, op1_lt_op2_signed};

// sltu sltiu
assign op1_lt_op2_unsigned = op1 < op2;
assign sltu_rd_data        = {{63{1'b0}}, op1_lt_op2_unsigned};

// xor xori
assign xor_rd_data = op1 ^ op2;

// sll slli
assign sll_rd_data = op1 << shift_bits;

// srl srli
assign srl_rd_data = op1 >> shift_bits;

// sra srai
assign sra_rd_data = op1_signed >>> shift_bits;

// and andi
assign and_rd_data = op1 & op2;

// or ori
assign or_rd_data  = op1 | op2;

// lui
assign lui_rd_data = op2;

// auipc
assign auipc_rd_data = pc_signed + op2_signed;

// addw addiw
assign addw_rd_data = {{32{add_rd_data[31]}}, add_rd_data[31:0]};

// subw
assign subw_rd_data = {{32{sub_rd_data[31]}}, sub_rd_data[31:0]};

// sllw slliw
assign sllw_temp    = op1_word << shift_bits[4:0];
assign sllw_rd_data = {{32{sllw_temp[31]}}, sllw_temp};

// srlw srliw
assign srlw_temp    = op1_word >> shift_bits[4:0];
assign srlw_rd_data = {{32{srlw_temp[31]}}, srlw_temp};

// sraw sraiw
assign sraw_temp    = op1_word_signed >>> shift_bits[4:0];
assign sraw_rd_data = {{32{sraw_temp[31]}}, sraw_temp};

// jal
assign jal_rd_data  = pc_i + 4;


//------------------CSR wdata--------------
assign csrrw_wdata  =  rs1_rdata_i;

assign csrrs_wdata  =  rs1_rdata_i | csr_rdata_i;

assign csrrc_wdata  = ~rs1_rdata_i & csr_rdata_i;

assign csrrwi_wdata =  imm_i;

assign csrrsi_wdata =  imm_i | csr_rdata_i;

assign csrrci_wdata = ~imm_i & csr_rdata_i;




//----------output---------------------
assign exu_rd_wen_o  = rd_wen_i;

assign exu_rd_addr_o = rd_addr_i;

assign exu_rd_data_o = ({64{op_alu_add}}   & add_rd_data)
                |  ({64{op_alu_sub}}   & sub_rd_data)
                |  ({64{op_alu_slt}}   & slt_rd_data)
                |  ({64{op_alu_sltu}}  & sltu_rd_data)
                |  ({64{op_alu_xor}}   & xor_rd_data)
                |  ({64{op_alu_sll}}   & sll_rd_data)
                |  ({64{op_alu_srl}}   & srl_rd_data)
                |  ({64{op_alu_sra}}   & sra_rd_data)
                |  ({64{op_alu_and}}   & and_rd_data)
                |  ({64{op_alu_or}}    & or_rd_data)
                |  ({64{op_alu_lui}}   & lui_rd_data)
                |  ({64{op_alu_auipc}} & auipc_rd_data)
                |  ({64{op_alu_addw}}  & addw_rd_data)
                |  ({64{op_alu_subw}}  & subw_rd_data)
                |  ({64{op_alu_sllw}}  & sllw_rd_data)
                |  ({64{op_alu_srlw}}  & srlw_rd_data)
                |  ({64{op_alu_sraw}}  & sraw_rd_data)
                |  ({64{op_is_jal_i}}  & jal_rd_data)
                |  ({64{op_csr}}       & csr_rdata_i)
                ;


assign exu_mem_addr_o  = add_rd_data;
assign exu_mem_wdata_o = forward_ls_rs2_i ? wbu_rd_wdata_i :
                         forward_ex_rs2_i ? ex_ls_rd_data_i : rs2_rdata_i;

assign exu_ls_info_o   = ls_info_i;
assign exu_mem_read_o  = mem_read_i;
assign exu_mem_write_o = mem_write_i;

assign exu_csr_waddr_o = csr_waddr_i;
assign exu_csr_wen_o   = csr_wen_i;

assign exu_csr_wdata_o = ({64{op_csr_csrrw }} & csrrw_wdata)
                  |  ({64{op_csr_csrrs }} & csrrs_wdata)
                  |  ({64{op_csr_csrrc }} & csrrc_wdata)
                  |  ({64{op_csr_csrrwi}} & csrrwi_wdata)
                  |  ({64{op_csr_csrrsi}} & csrrsi_wdata)
                  |  ({64{op_csr_csrrci}} & csrrci_wdata)
                  ;

endmodule
