// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.07.18
// Execute unit
// As known as "EX"

`include "defines.v"

module exu(
    // id
    input   [63:0] i_imm,
    input   [63:0] i_rs1_rdata,
    input   [63:0] i_rs2_rdata,
    input   [63:0] i_csr_rdata,
    input   [63:0] i_pc,

    // ex control
    input   [12:0] i_alu_info,
    input   [5:0]  i_csr_info,
    input          i_op2_is_imm,
    input          i_op_is_jal,

    // wb control
    input          i_rd_wen,
    output         o_rd_wen,
    // wb
    input   [4:0]  i_rd_addr,
    output  [63:0] o_rd_data,
    output  [4:0]  o_rd_addr,

    // ls
    output  [63:0] o_mem_addr,
    output  [63:0] o_mem_wdata,
    // ls control
    input   [10:0] i_ls_info,
    input          i_mem_read,
    input          i_mem_write,
    output  [10:0] o_ls_info,
    output         o_mem_read,
    output         o_mem_write,

    // forward control
    input          i_forward_ex_rs1,
    input          i_forward_ex_rs2,
    input          i_forward_ls_rs1,
    input          i_forward_ls_rs2,

    input   [63:0] i_ex_ls_rd_data,
    input   [63:0] i_wbu_rd_wdata,

    // csr
    input          i_csr_wen,
    input   [11:0] i_csr_waddr,
    output  [63:0] o_csr_wdata,
    output         o_csr_wen,
    output  [11:0] o_csr_waddr


);


//---------------Variables declaration------------------------
wire op_alu_or    = i_alu_info[12];
wire op_alu_add   = i_alu_info[11] & ~i_alu_info[0];
wire op_alu_sub   = i_alu_info[10] & ~i_alu_info[0];
wire op_alu_slt   = i_alu_info[ 9];
wire op_alu_sltu  = i_alu_info[ 8];
wire op_alu_xor   = i_alu_info[ 7];
wire op_alu_sll   = i_alu_info[ 6] & ~i_alu_info[0];
wire op_alu_srl   = i_alu_info[ 5] & ~i_alu_info[0];
wire op_alu_sra   = i_alu_info[ 4] & ~i_alu_info[0];
wire op_alu_and   = i_alu_info[ 3];
wire op_alu_lui   = i_alu_info[ 2];
wire op_alu_auipc = i_alu_info[ 1];
wire op_alu_word  = i_alu_info[ 0];
wire op_alu_addw  = i_alu_info[11] & i_alu_info[0];
wire op_alu_subw  = i_alu_info[10] & i_alu_info[0];
wire op_alu_sllw  = i_alu_info[ 6] & i_alu_info[0];
wire op_alu_srlw  = i_alu_info[ 5] & i_alu_info[0];
wire op_alu_sraw  = i_alu_info[ 4] & i_alu_info[0];

wire op_csr_csrrw = i_csr_info[5];
wire op_csr_csrrs = i_csr_info[4];
wire op_csr_csrrc = i_csr_info[3];
wire op_csr_csrrwi= i_csr_info[2];
wire op_csr_csrrsi= i_csr_info[1];
wire op_csr_csrrci= i_csr_info[0];
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
wire signed [31:0] temp_addw_rd;
wire signed [31:0] temp_subw_rd;
wire signed [31:0] temp_sllw_rd;
wire        [31:0] temp_srlw_rd;
wire signed [31:0] temp_sraw_rd;

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
wire signed [31:0] op1_signed_word;

wire signed [63:0] pc_signed;

wire op1_lt_op2_signed;
wire op1_lt_op2_unsigned;


//----------------ALU---------------------
always @(*) begin
    case ({i_forward_ex_rs1, i_forward_ls_rs1})
        2'b10   : op1 = i_ex_ls_rd_data;
        2'b01   : op1 = i_wbu_rd_wdata;
        default : op1 = i_rs1_rdata;
    endcase
end

always @(*) begin
    casez ({i_forward_ex_rs2, i_forward_ls_rs2, i_op2_is_imm})
        3'b100  : op2 = i_ex_ls_rd_data;
        3'b010  : op2 = i_wbu_rd_wdata;
        3'b??1  : op2 = i_imm;
        default : op2 = i_rs2_rdata;
    endcase
end

assign op1_signed = $signed(op1);
assign op2_signed = $signed(op2);
assign pc_signed  = $signed(i_pc);


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
assign sll_rd_data = op1 << op2[5:0];

// srl srli
assign srl_rd_data = op1 >> op2[5:0];

// sra srai
assign sra_rd_data = op1_signed >>> op2[5:0];

// and andi
assign and_rd_data = op1 & op2;

// or ori
assign or_rd_data  = op1 | op2;

// lui
assign lui_rd_data = op2;

// auipc
assign auipc_rd_data = pc_signed + op2_signed;

// addw addiw
assign temp_addw_rd = add_rd_data[31:0];
assign addw_rd_data = {{32{temp_addw_rd[31]}}, temp_addw_rd};

// subw
assign temp_subw_rd = sub_rd_data[31:0];
assign subw_rd_data = {{32{temp_subw_rd[31]}}, temp_subw_rd};

// sllw slliw
assign temp_sllw_rd = sll_rd_data[31:0];
assign sllw_rd_data = {{32{temp_sllw_rd[31]}}, temp_sllw_rd};

// srlw srliw
assign temp_srlw_rd = op1[31:0] >> op2[4:0];
assign srlw_rd_data = {{32{temp_srlw_rd[31]}}, temp_srlw_rd};

// sraw sraiw
assign op1_signed_word = op1_signed[31:0];
assign temp_sraw_rd = op1_signed_word >>> op2[4:0];
assign sraw_rd_data = {{32{temp_sraw_rd[31]}}, temp_sraw_rd};

// jal
assign jal_rd_data = i_pc + 4;


//------------------CSR wdata--------------
assign csrrw_wdata  =  i_rs1_rdata;

assign csrrs_wdata  =  i_rs1_rdata | i_csr_rdata;

assign csrrc_wdata  = ~i_rs1_rdata & i_csr_rdata;

assign csrrwi_wdata =  i_imm;

assign csrrsi_wdata =  i_imm | i_csr_rdata;

assign csrrci_wdata = ~i_imm & i_csr_rdata;




//----------output---------------------
assign o_rd_wen  = i_rd_wen;

assign o_rd_addr = i_rd_addr;

assign o_rd_data = ({64{op_alu_add}}   & add_rd_data)
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
                |  ({64{i_op_is_jal}}  & jal_rd_data)
                |  ({64{op_csr}}       & i_csr_rdata)
                ;


assign o_mem_addr  = add_rd_data;
assign o_mem_wdata = i_forward_ls_rs2 ? i_wbu_rd_wdata :
                     i_forward_ex_rs2 ? i_ex_ls_rd_data : i_rs2_rdata;

assign o_ls_info   = i_ls_info;
assign o_mem_read  = i_mem_read;
assign o_mem_write = i_mem_write;

assign o_csr_waddr = i_csr_waddr;
assign o_csr_wen   = i_csr_wen;

assign o_csr_wdata = ({64{op_csr_csrrw }} & csrrw_wdata)
                  |  ({64{op_csr_csrrs }} & csrrs_wdata)
                  |  ({64{op_csr_csrrc }} & csrrc_wdata)
                  |  ({64{op_csr_csrrwi}} & csrrwi_wdata)
                  |  ({64{op_csr_csrrsi}} & csrrsi_wdata)
                  |  ({64{op_csr_csrrci}} & csrrci_wdata)
                  ;

endmodule
