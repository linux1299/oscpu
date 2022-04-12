// Copyright 2022 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2022.04.12
// RVCPU with AXI master top module

`include "defines.v"

module rvcpu (
    input clk,
    input rst_n,

    // ram port
    output           ram_rw_cen_o,
    output           ram_rw_wen_o,
    output    [63:0] ram_rw_addr_o,
    output    [63:0] ram_rw_wdata_o,
    output    [2:0]  ram_rw_size_o,
    input            ram_rw_ready_i,
    input     [63:0] ram_rw_data_i
);

//================Signal===================
wire ifu_ram_cen_o  ;
wire [63:0] ifu_ram_addr_o ;
wire [2:0 ] ifu_ram_size_o ;
wire [63:0] ram_ifu_data_o ;
wire ram_ifu_valid_o;
wire [31:0] ifu_instr_o;
wire [63:0] ifu_pc_o;
wire  ifu_instr_valid_o;
wire [95:0] if_id_data;
wire  if_id_valid;
wire [63:0] rs1_rdata_o;
wire [63:0] rs2_rdata_o;
wire  idu_jump_o ;
wire [63:0] idu_jump_pc_o;
wire [4:0] idu_rs1_addr_o ;
wire [4:0] idu_rs2_addr_o ;
wire  idu_rs1_cen_o  ;
wire  idu_rs2_cen_o  ;
wire [63:0] idu_imm_o      ;
wire [63:0] idu_rs1_rdata_o ;
wire [63:0] idu_rs2_rdata_o ;
wire [63:0] idu_pc_o       ;
wire [12:0] idu_alu_info_o  ;
wire [8:0]  idu_csr_info_o  ;
wire  idu_op2_is_imm_o;
wire  idu_op_is_jal_o ;
wire [10:0] idu_ls_info_o    ;
wire  idu_mem_read_o   ;
wire  idu_mem_write_o ;
wire  idu_rd_wen_o    ;
wire [4:0] idu_rd_addr_o    ;
wire  idu_op_is_branch_o;
wire  idu_csr_wen_o  ;
wire [63:0] idu_csr_rdata_o;
wire [11:0] idu_csr_raddr_o;
wire [11:0] idu_csr_waddr_o;
wire [400:0] id_ex_data ;
wire  id_ex_valid;
wire  exu_rd_wen_o;
wire [63:0] exu_rd_data_o;
wire [4:0] exu_rd_addr_o;
wire [63:0] exu_mem_addr_o;
wire [63:0] exu_mem_wdata_o;
wire [10:0] exu_ls_info_o;
wire  exu_mem_read_o;
wire  exu_mem_write_o;
wire [63:0] exu_csr_wdata_o;
wire  exu_csr_wen_o;
wire [11:0] exu_csr_waddr_o;
wire [63:0] csrfile_cpu_csr_rdata_o;
wire [63:0] csrfile_clint_csr_mtvec_o;
wire [63:0] csrfile_clint_csr_mepc_o;
wire [63:0] csrfile_clint_csr_mstatus_o;
wire  csrfile_global_int_en_o;
wire  csrfile_mtime_int_en_o;
wire  csrfile_mtime_int_pend_o;
wire [63:0] clint_int_addr_o;
wire  clint_int_valid_o;
wire  clint_hold_o;
wire  clint_csr_wen_o;
wire [11:0] clint_csr_waddr_o;
wire [63:0] clint_csr_wdata_o;
wire [210:0] ex_ls_data;
wire  ex_ls_valid;
wire  lsu_ram_cen_o;
wire  lsu_ram_wen_o;
wire [63:0] lsu_ram_addr_o;
wire [2:0] lsu_ram_size_o;
wire [63:0] lsu_ram_wdata_o;
wire  lsu_rd_wen_o;
wire [63:0] lsu_rd_data_o;
wire [4:0] lsu_rd_addr_o;
wire [63:0] lsu_mem_rdata_o;
wire  lsu_mem_read_o;
wire  lsu_hold_o;
wire [134:0] ls_wb_data;
wire  ls_wb_valid;
wire  wbu_rd_wen_o;
wire [4:0] wbu_rd_addr_o;
wire [63:0] wbu_rd_wdata_o;
wire  o_forward_ex_rs1;
wire  o_forward_ex_rs2;
wire  o_forward_ls_rs1;
wire  o_forward_ls_rs2;
wire  o_load_use    ;
wire  o_ctrl_forward_ex_rs1;
wire  o_ctrl_forward_ex_rs2;
wire  o_ctrl_forward_ls_rs1;
wire  o_ctrl_forward_ls_rs2;
wire  o_ctrl_load_use;
wire  timer_int_o;
wire [63:0] timer_rdata_o;
wire  ram_lsu_valid_o;
wire [63:0] ram_lsu_data_o  ;
wire  ram_timer_cen_o ;
wire  ram_timer_wen_o  ;
wire [63:0] ram_timer_addr_o ;
wire [63:0] ram_timer_wdata_o;



wire [31:0] if_id_instr = if_id_data[95-:64];
wire [63:0] if_id_pc = if_id_data[31:0];

wire [4:0]  id_ex_rs1_addr = id_ex_data[400-:5];
wire [4:0]  id_ex_rs2_addr = id_ex_data[395-:5];
wire        id_ex_rs1_cen  = id_ex_data[390-:1];
wire        id_ex_rs2_cen  = id_ex_data[389-:1];
wire [63:0] id_ex_imm      = id_ex_data[388-:64];
wire [63:0] id_ex_rs1_rdata= id_ex_data[324-:64] ;
wire [63:0] id_ex_rs2_rdata= id_ex_data[260-:64] ;
wire [63:0] id_ex_pc       = id_ex_data[196-:64];
wire [12:0] id_ex_alu_info = id_ex_data[132-:13];
wire [8:0]  id_ex_csr_info = id_ex_data[119-:9];
wire        id_ex_op2_is_imm= id_ex_data[110-:1];
wire        id_ex_op_is_jal = id_ex_data[109-:1];
wire [10:0] id_ex_ls_info   = id_ex_data[108-:11];
wire        id_ex_mem_read  = id_ex_data[97-:1];
wire        id_ex_mem_write = id_ex_data[96-:1];
wire        id_ex_rd_wen    = id_ex_data[95-:1];
wire [4:0]  id_ex_rd_addr   = id_ex_data[94-:5] ;
wire        id_ex_op_is_branch = id_ex_data[89-:1];
wire        id_ex_csr_wen   = id_ex_data[88-:1];
wire [63:0] id_ex_csr_rdata = id_ex_data[87-:64];
wire [11:0] id_ex_csr_raddr = id_ex_data[23-:12];
wire [11:0] id_ex_csr_waddr = id_ex_data[11-:12];

wire        ex_ls_rd_wen    = ex_ls_data[210-:1];
wire [63:0] ex_ls_rd_data   = ex_ls_data[209-:64];
wire [4:0]  ex_ls_rd_addr   = ex_ls_data[145-:5];
wire [63:0] ex_ls_mem_addr  = ex_ls_data[140-:64];
wire [63:0] ex_ls_mem_wdata = ex_ls_data[76-:64];
wire [10:0] ex_ls_ls_info   = ex_ls_data[12-:11];
wire        ex_ls_mem_read  = ex_ls_data[1-:1];
wire        ex_ls_mem_write = ex_ls_data[0-:1];

wire        ls_wb_rd_wen    = ls_wb_data[134-:1];
wire [63:0] ls_wb_rd_data   = ls_wb_data[133-:64];
wire [4:0]  ls_wb_rd_addr   = ls_wb_data[69-:5];
wire [63:0] ls_wb_mem_rdata = ls_wb_data[64-:64];
wire        ls_wb_mem_read  = ls_wb_data[0-:1];


//=================Module===================
//============Stage 1=====================
//-------ifu---------------
ifu u_ifu(
    .clk               ( clk               ),
    .rst_n             ( rst_n             ),
    .ifu_ram_cen_o     ( ifu_ram_cen_o     ),
    .ifu_ram_addr_o    ( ifu_ram_addr_o    ),
    .ifu_ram_size_o    ( ifu_ram_size_o    ),
    .ifu_ram_data_i    ( ram_ifu_data_o    ),
    .ifu_ram_valid_i   ( ram_ifu_valid_o   ),
    .jump_i            ( idu_jump_o
                     && ~o_ctrl_load_use ),
    .hold_i            ( o_load_use
                      || lsu_hold_o
                      || clint_hold_o ),
    .jump_pc_i         ( idu_jump_pc_o         ),
    .ifu_instr_o       ( ifu_instr_o       ),
    .ifu_instr_valid_o ( ifu_instr_valid_o ),
    .ifu_pc_o          ( ifu_pc_o          ),
    .int_cen_i         ( clint_int_valid_o ),
    .int_addr_i        ( clint_int_addr_o )
);

// when load use or jump, stall
pipeline_reg#(
    .N       ( 96 )
)u_pipeline_reg_if_id(
    .clk     ( clk     ),
    .rst_n   ( rst_n   ),
    .clear_i ( idu_jump_o
            && ~o_ctrl_load_use ),
    .hold_i  ( o_load_use
            || o_ctrl_load_use
            || lsu_hold_o
            || clint_hold_o ),
    .data_i  ( {ifu_instr_o,
                ifu_pc_o} ),
    .valid_i ( ifu_instr_valid_o ),
    .data_o  ( if_id_data  ),
    .valid_o ( if_id_valid  )
);


//==============Stage 2========================
//---------reg_file---------
reg_file u_reg_file(
    .clk         ( clk         ),
    .rst_n       ( rst_n       ),
    .wen_i       ( wbu_rd_wen_o ),
    .addr_i      ( wbu_rd_addr_o ),
    .wdata_i     ( wbu_rd_wdata_o ),
    .rs1_cen_i   ( idu_rs1_cen_o ),
    .rs2_cen_i   ( idu_rs2_cen_o ),
    .rs1_addr_i  ( idu_rs1_addr_o ),
    .rs2_addr_i  ( idu_rs2_addr_o ),
    .rs1_rdata_o ( rs1_rdata_o ),
    .rs2_rdata_o ( rs2_rdata_o  )
);

//-------idu----------
idu u_idu(
    .pc_i               ( if_id_pc),
    .instr_i            ( if_id_instr ),
    .instr_valid_i      ( if_id_valid ),
    .idu_jump_o         ( idu_jump_o         ),
    .idu_jump_pc_o      ( idu_jump_pc_o      ),
    .rs1_rdata_i        ( rs1_rdata_o ),
    .rs2_rdata_i        ( rs2_rdata_o ),
    .idu_rs1_addr_o     ( idu_rs1_addr_o     ),
    .idu_rs2_addr_o     ( idu_rs2_addr_o     ),
    .idu_rs1_cen_o      ( idu_rs1_cen_o      ),
    .idu_rs2_cen_o      ( idu_rs2_cen_o      ),
    .idu_imm_o          ( idu_imm_o          ),
    .idu_rs1_rdata_o    ( idu_rs1_rdata_o    ),
    .idu_rs2_rdata_o    ( idu_rs2_rdata_o    ),
    .idu_pc_o           ( idu_pc_o           ),
    .idu_alu_info_o     ( idu_alu_info_o     ),
    .idu_csr_info_o     ( idu_csr_info_o     ),
    .idu_op2_is_imm_o   ( idu_op2_is_imm_o   ),
    .idu_op_is_jal_o    ( idu_op_is_jal_o    ),
    .idu_ls_info_o      ( idu_ls_info_o      ),
    .idu_mem_read_o     ( idu_mem_read_o     ),
    .idu_mem_write_o    ( idu_mem_write_o    ),
    .idu_rd_wen_o       ( idu_rd_wen_o       ),
    .idu_rd_addr_o      ( idu_rd_addr_o      ),
    .idu_op_is_branch_o ( idu_op_is_branch_o ),
    .forward_ex_rs1_i   ( o_ctrl_forward_ex_rs1 ),
    .forward_ex_rs2_i   ( o_ctrl_forward_ex_rs2 ),
    .forward_ls_rs1_i   ( o_ctrl_forward_ls_rs1 ),
    .forward_ls_rs2_i   ( o_ctrl_forward_ls_rs2 ),
    .ex_ls_mem_read_i   ( ex_ls_mem_read ),
    .exu_rd_data_i      ( exu_rd_data_o  ),
    .lsu_rd_data_i      ( lsu_rd_data_o ),
    .lsu_mem_rdata_i    ( lsu_mem_rdata_o ),
    .csr_rdata_i        ( csrfile_cpu_csr_rdata_o ),
    .idu_csr_wen_o      ( idu_csr_wen_o      ),
    .idu_csr_rdata_o    ( idu_csr_rdata_o    ),
    .idu_csr_raddr_o    ( idu_csr_raddr_o    ),
    .idu_csr_waddr_o    ( idu_csr_waddr_o    )
);

pipeline_reg#(
    .N       ( 401 )
)u_pipeline_reg_id_ex(
    .clk     ( clk     ),
    .rst_n   ( rst_n   ),
    .clear_i ( 1'b0 ),
    .hold_i  ( lsu_hold_o || clint_hold_o ),
    .data_i  ( {idu_rs1_addr_o,
                idu_rs2_addr_o,
                idu_rs1_cen_o,
                idu_rs2_cen_o,
                idu_imm_o,
                idu_rs1_rdata_o,
                idu_rs2_rdata_o,
                idu_pc_o,
                idu_alu_info_o,
                idu_csr_info_o    ,
                idu_op2_is_imm_o  ,
                idu_op_is_jal_o   ,
                idu_ls_info_o     ,
                idu_mem_read_o    ,
                idu_mem_write_o   ,
                idu_rd_wen_o      ,
                idu_rd_addr_o     ,
                idu_op_is_branch_o,
                idu_csr_wen_o  ,
                idu_csr_rdata_o,
                idu_csr_raddr_o,
                idu_csr_waddr_o} ),
    .valid_i ( if_id_valid ),
    .data_o  ( id_ex_data  ),
    .valid_o ( id_ex_valid  )
);

//===============Stage 3======================
//---------ex-----------
exu u_exu(
    .imm_i            ( id_ex_imm ),
    .rs1_rdata_i      ( id_ex_rs1_rdata ),
    .rs2_rdata_i      ( id_ex_rs2_rdata ),
    .csr_rdata_i      ( id_ex_csr_rdata ),
    .pc_i             ( id_ex_pc ),
    .alu_info_i       ( id_ex_alu_info ),
    .csr_info_i       ( id_ex_csr_info ),
    .op2_is_imm_i     ( id_ex_op2_is_imm ),
    .op_is_jal_i      ( id_ex_op_is_jal ),
    .rd_wen_i         ( id_ex_rd_wen ),
    .exu_rd_wen_o     ( exu_rd_wen_o     ),
    .rd_addr_i        ( id_ex_rd_addr ),
    .exu_rd_data_o    ( exu_rd_data_o    ),
    .exu_rd_addr_o    ( exu_rd_addr_o    ),
    .ls_info_i        ( id_ex_ls_info ),
    .mem_read_i       ( id_ex_mem_read ),
    .mem_write_i      ( id_ex_mem_write ),
    .exu_mem_addr_o   ( exu_mem_addr_o   ),
    .exu_mem_wdata_o  ( exu_mem_wdata_o  ),
    .exu_ls_info_o    ( exu_ls_info_o    ),
    .exu_mem_read_o   ( exu_mem_read_o   ),
    .exu_mem_write_o  ( exu_mem_write_o  ),
    .forward_ex_rs1_i ( o_forward_ex_rs1 ),
    .forward_ex_rs2_i ( o_forward_ex_rs2 ),
    .forward_ls_rs1_i ( o_forward_ls_rs1 ),
    .forward_ls_rs2_i ( o_forward_ls_rs2 ),
    .ex_ls_rd_data_i  ( ex_ls_rd_data ),
    .wbu_rd_wdata_i   ( wbu_rd_wdata_o ),
    .csr_wen_i        ( id_ex_csr_wen ),
    .csr_waddr_i      ( id_ex_csr_waddr ),
    .exu_csr_wdata_o  ( exu_csr_wdata_o  ),
    .exu_csr_wen_o    ( exu_csr_wen_o    ),
    .exu_csr_waddr_o  ( exu_csr_waddr_o  )
);

//-------------CSR-----------------
csr_file u_csr_file(
    .clk                         ( clk                         ),
    .rst_n                       ( rst_n                       ),
    .cpu_csr_wen_i               ( exu_csr_wen_o ),
    .cpu_csr_raddr_i             ( idu_csr_raddr_o ),
    .cpu_csr_waddr_i             ( exu_csr_waddr_o ),
    .cpu_csr_wdata_i             ( exu_csr_wdata_o ),
    .csrfile_cpu_csr_rdata_o     ( csrfile_cpu_csr_rdata_o     ),
    .clint_csr_wen_i             ( clint_csr_wen_o ),
    .clint_csr_waddr_i           ( clint_csr_waddr_o ),
    .clint_csr_wdata_i           ( clint_csr_wdata_o ),
    .csrfile_clint_csr_mtvec_o   ( csrfile_clint_csr_mtvec_o   ),
    .csrfile_clint_csr_mepc_o    ( csrfile_clint_csr_mepc_o    ),
    .csrfile_clint_csr_mstatus_o ( csrfile_clint_csr_mstatus_o ),
    .csrfile_global_int_en_o     ( csrfile_global_int_en_o     ),
    .csrfile_mtime_int_en_o      ( csrfile_mtime_int_en_o      ),
    .csrfile_mtime_int_pend_o    ( csrfile_mtime_int_pend_o    ),
    .timer_int_i                 ( timer_int_o )
);

//-------------Clint----------------
clint u_clint(
    .clk               ( clk   ),
    .rst_n             ( rst_n ),
    .timer_int_i       ( timer_int_o ),
    .pc_i              ( if_id_pc ),
    .jump_i            ( idu_jump_o ),
    .jump_pc_i         ( idu_jump_pc_o ),
    .expt_info_i       ( idu_csr_info_o[8:6] ),
    .clint_int_addr_o  ( clint_int_addr_o  ),
    .clint_int_valid_o ( clint_int_valid_o ),
    .clint_hold_o      ( clint_hold_o      ),
    .global_int_en_i   ( csrfile_global_int_en_o ),
    .mtime_int_en_i    ( csrfile_mtime_int_en_o ),
    .mtime_int_pend_i  ( csrfile_mtime_int_pend_o ),
    .csr_mtvec_i       ( csrfile_clint_csr_mtvec_o ),
    .csr_mepc_i        ( csrfile_clint_csr_mepc_o ),
    .csr_mstatus_i     ( csrfile_clint_csr_mstatus_o ),
    .clint_csr_wen_o   ( clint_csr_wen_o   ),
    .clint_csr_waddr_o ( clint_csr_waddr_o ),
    .clint_csr_wdata_o  ( clint_csr_wdata_o  )
);

pipeline_reg#(
    .N       ( 211 )
)u_pipeline_reg_ex_ls(
    .clk     ( clk     ),
    .rst_n   ( rst_n   ),
    .clear_i ( 1'b0 ),
    .hold_i  ( lsu_hold_o ),
    .data_i  ( {exu_rd_wen_o,
                exu_rd_data_o,
                exu_rd_addr_o,
                exu_mem_addr_o,
                exu_mem_wdata_o,
                exu_ls_info_o,
                exu_mem_read_o,
                exu_mem_write_o} ),
    .valid_i ( id_ex_valid ),
    .data_o  ( ex_ls_data  ),
    .valid_o ( ex_ls_valid  )
);

//===================Stage 4=========================
//---------lsu------------
lsu u_lsu(
    .clk             ( clk             ),
    .rst_n           ( rst_n           ),
    .mem_addr_i      ( ex_ls_mem_addr  ),
    .mem_wdata_i     ( ex_ls_mem_wdata ),
    .mem_read_i      ( ex_ls_mem_read  ),
    .mem_write_i     ( ex_ls_mem_write ),
    .ls_info_i       ( ex_ls_ls_info ),
    .lsu_ram_cen_o   ( lsu_ram_cen_o   ),
    .lsu_ram_wen_o   ( lsu_ram_wen_o   ),
    .lsu_ram_addr_o  ( lsu_ram_addr_o  ),
    .lsu_ram_size_o  ( lsu_ram_size_o  ),
    .lsu_ram_wdata_o ( lsu_ram_wdata_o ),
    .lsu_ram_data_i  ( ram_lsu_data_o ),
    .lsu_ram_ready_i ( ram_lsu_valid_o ),
    .rd_wen_i        ( ex_ls_rd_wen ),
    .rd_data_i       ( ex_ls_rd_data),
    .rd_addr_i       ( ex_ls_rd_addr ),
    .lsu_rd_wen_o    ( lsu_rd_wen_o    ),
    .lsu_rd_data_o   ( lsu_rd_data_o   ),
    .lsu_rd_addr_o   ( lsu_rd_addr_o   ),
    .lsu_mem_rdata_o ( lsu_mem_rdata_o ),
    .lsu_mem_read_o  ( lsu_mem_read_o  ),
    .lsu_hold_o      ( lsu_hold_o      )
);

pipeline_reg#(
    .N       ( 135 )
)u_pipeline_reg_ls_wb(
    .clk     ( clk     ),
    .rst_n   ( rst_n   ),
    .clear_i ( 1'b0 ),
    .hold_i  ( 1'b0 ),
    .data_i  ( {lsu_rd_wen_o   ,
                lsu_rd_data_o  ,
                lsu_rd_addr_o  ,
                lsu_mem_rdata_o,
                lsu_mem_read_o } ),
    .valid_i ( ex_ls_valid ),
    .data_o  ( ls_wb_data  ),
    .valid_o ( ls_wb_valid  )
);

//=====================Stage 5====================
//------------wbu----------------
wbu u_wbu(
    .rd_data_i     ( ls_wb_rd_data ),
    .rd_addr_i     ( ls_wb_rd_addr ),
    .rd_wen_i      ( ls_wb_rd_wen ),
    .mem_read_i    ( ls_wb_mem_read ),
    .mem_rdata_i   ( ls_wb_mem_rdata ),
    .wbu_rd_wen_o  ( wbu_rd_wen_o  ),
    .wbu_rd_addr_o ( wbu_rd_addr_o ),
    .wbu_rd_wdata_o  ( wbu_rd_wdata_o  )
);

//------------hazard detect---------
hdu u_hdu(
    .i_id_ex_rs1           ( id_ex_rs1_addr ),
    .i_id_ex_rs2           ( id_ex_rs2_addr ),
    .i_id_ex_rs1_cen       ( id_ex_rs1_cen  ),
    .i_id_ex_rs2_cen       ( id_ex_rs2_cen  ),

    .i_if_id_rs1           ( idu_rs1_addr_o ),
    .i_if_id_rs2           ( idu_rs2_addr_o ),
    .i_if_id_rs1_cen       ( idu_rs1_cen_o  ),
    .i_if_id_rs2_cen       ( idu_rs2_cen_o  ),

    .i_id_ex_rd            ( id_ex_rd_addr  ),
    .i_ex_ls_rd            ( ex_ls_rd_addr  ),
    .i_ls_wb_rd            ( ls_wb_rd_addr  ),
    .i_ex_ls_rd_wen        ( ex_ls_rd_wen   ),
    .i_ls_wb_rd_wen        ( ls_wb_rd_wen   ),
    .i_id_ex_mem_read      ( id_ex_mem_read ),
    .i_ls_wb_mem_read      ( ls_wb_mem_read ),

    .o_forward_ex_rs1      ( o_forward_ex_rs1      ),
    .o_forward_ex_rs2      ( o_forward_ex_rs2      ),
    .o_forward_ls_rs1      ( o_forward_ls_rs1      ),
    .o_forward_ls_rs2      ( o_forward_ls_rs2      ),
    .o_load_use            ( o_load_use            ),
    .i_op_is_branch        ( idu_op_is_branch_o ),
    .i_id_ex_rd_wen        ( id_ex_rd_wen ),
    .i_ex_ls_mem_read      ( ex_ls_mem_read ),
    .o_ctrl_forward_ex_rs1 ( o_ctrl_forward_ex_rs1 ),
    .o_ctrl_forward_ex_rs2 ( o_ctrl_forward_ex_rs2 ),
    .o_ctrl_forward_ls_rs1 ( o_ctrl_forward_ls_rs1 ),
    .o_ctrl_forward_ls_rs2 ( o_ctrl_forward_ls_rs2 ),
    .o_ctrl_load_use       ( o_ctrl_load_use       )
);

//--------------timer---------------
timer u_timer(
    .clk         ( clk         ),
    .rst_n       ( rst_n       ),
    .timer_int_o ( timer_int_o ),
    .cen_i       ( ram_timer_cen_o ),
    .wen_i       ( ram_timer_wen_o ),
    .addr_i      ( ram_timer_addr_o ),
    .wdata_i     ( ram_timer_wdata_o ),
    .timer_rdata_o  ( timer_rdata_o  )
);


//---------------ram arbiter------------
ram_arbiter u_ram_arbiter(
    .clk               ( clk   ),
    .rst_n             ( rst_n ),
    .ifu_cen_i         ( ifu_ram_cen_o ),
    .ifu_addr_i        ( ifu_ram_addr_o ),
    .ifu_size_i        ( ifu_ram_size_o ),
    .ifu_instr_valid_i ( ifu_instr_valid_o ),
    .ram_ifu_valid_o   ( ram_ifu_valid_o   ),
    .ram_ifu_data_o    ( ram_ifu_data_o    ),
    .lsu_cen_i         ( lsu_ram_cen_o ),
    .lsu_wen_i         ( lsu_ram_wen_o ),
    .lsu_addr_i        ( lsu_ram_addr_o ),
    .lsu_size_i        ( lsu_ram_size_o ),
    .lsu_wdata_i       ( lsu_ram_wdata_o ),
    .ram_lsu_valid_o   ( ram_lsu_valid_o   ),
    .ram_lsu_data_o    ( ram_lsu_data_o    ),
    .ram_timer_cen_o   ( ram_timer_cen_o   ),
    .ram_timer_wen_o   ( ram_timer_wen_o   ),
    .ram_timer_addr_o  ( ram_timer_addr_o  ),
    .ram_timer_wdata_o ( ram_timer_wdata_o ),
    .timer_rdata_i     ( timer_rdata_o ),
    .ram_rw_cen_o      ( ram_rw_cen_o      ),
    .ram_rw_wen_o      ( ram_rw_wen_o      ),
    .ram_rw_addr_o     ( ram_rw_addr_o     ),
    .ram_rw_wdata_o    ( ram_rw_wdata_o    ),
    .ram_rw_size_o     ( ram_rw_size_o     ),
    .ram_rw_ready_i    ( ram_rw_ready_i ),
    .ram_rw_data_i     ( ram_rw_data_i )
);

endmodule