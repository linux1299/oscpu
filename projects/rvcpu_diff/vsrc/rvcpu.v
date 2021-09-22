// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.07.19
// RVCPU top module

`include "defines.v"

module rvcpu (
    input clk,
    input rst_n,

    // AXI master
    // write address channel
    output [`AXI_ID_WIDTH-1:0]          axi_aw_id_o,
    output [`AXI_ADDR_WIDTH-1:0]        axi_aw_addr_o,
    output [7:0]                        axi_aw_len_o,
    output [2:0]                        axi_aw_size_o,
    output [1:0]                        axi_aw_burst_o,
    output                              axi_aw_lock_o,
    output [3:0]                        axi_aw_cache_o,
    output [2:0]                        axi_aw_prot_o,
    output [3:0]                        axi_aw_qos_o,
    output [3:0]                        axi_aw_region_o,
    output [`AXI_USER_WIDTH-1:0]        axi_aw_user_o,
    output                              axi_aw_valid_o,
    input                               axi_aw_ready_i,

    // write data channel
    input                               axi_w_ready_i,
    output                              axi_w_valid_o,
    output [`AXI_DATA_WIDTH-1:0]        axi_w_data_o,
    output [`AXI_DATA_WIDTH/8-1:0]      axi_w_strb_o,
    output                              axi_w_last_o,
    output [`AXI_USER_WIDTH-1:0]        axi_w_user_o,

    // write response channel
    output                              axi_b_ready_o,
    input                               axi_b_valid_i,
    input  [1:0]                        axi_b_resp_i,
    input  [`AXI_ID_WIDTH-1:0]          axi_b_id_i,
    input  [`AXI_USER_WIDTH-1:0]        axi_b_user_i,

    // read address channel
    input                               axi_ar_ready_i,
    output                              axi_ar_valid_o,
    output [`AXI_ADDR_WIDTH-1:0]        axi_ar_addr_o,
    output [2:0]                        axi_ar_prot_o,
    output [`AXI_ID_WIDTH-1:0]          axi_ar_id_o,
    output [`AXI_USER_WIDTH-1:0]        axi_ar_user_o,
    output [7:0]                        axi_ar_len_o,
    output [2:0]                        axi_ar_size_o,
    output [1:0]                        axi_ar_burst_o,
    output                              axi_ar_lock_o,
    output [3:0]                        axi_ar_cache_o,
    output [3:0]                        axi_ar_qos_o,
    output [3:0]                        axi_ar_region_o,

    // read data channel
    output                              axi_r_ready_o,
    input                               axi_r_valid_i,
    input  [1:0]                        axi_r_resp_i,
    input  [`AXI_DATA_WIDTH-1:0]        axi_r_data_i,
    input                               axi_r_last_i,
    input  [`AXI_ID_WIDTH-1:0]          axi_r_id_i,
    input  [`AXI_USER_WIDTH-1:0]        axi_r_user_i
);

//==============S 1===================
wire [63:0] o_ifu_addr;
wire        o_ifu_valid;
wire        i_ifu_ready;
wire [31:0] i_ifu_rdata;
wire [2:0]  o_ifu_size;

wire        i_ifu_branch_jump;
wire [63:0] i_ifu_next_pc;
wire [31:0] o_ifu_instr;
wire        o_ifu_instr_valid;
wire [63:0] o_ifu_pc;

wire [31:0] if_id_instr;
wire [63:0] if_id_instr_addr;

//=============S 2======================
wire [63:0] i_idu_rs1_rdata;
wire [63:0] i_idu_rs2_rdata;

wire [4:0]  o_idu_rs1_addr;
wire [4:0]  o_idu_rs2_addr;
wire [4:0]  o_idu_idu_rd_addr;

wire        o_idu_rs1_cen;
wire        o_idu_rs2_cen;

wire [63:0] o_idu_imm;
wire [63:0] o_idu_rs1_rdata;
wire [63:0] o_idu_rs2_rdata;
wire [63:0] o_idu_pc;

wire [12:0] o_idu_alu_info;
wire [8:0]  o_idu_csr_info;
wire        o_idu_op2_is_imm;
wire        o_idu_op_is_jal;

wire [10:0] o_idu_ls_info;
wire        o_idu_mem_read;
wire        o_idu_mem_write;

wire        o_idu_rd_wen;
wire [4:0]  o_idu_rd_addr;
wire        o_idu_op_is_branch;

wire        o_idu_csr_wen;
wire [63:0] o_idu_csr_rdata;
wire [11:0] o_idu_csr_raddr;
wire [11:0] o_idu_csr_waddr;

wire [4:0]  id_ex_rs1_addr;
wire [4:0]  id_ex_rs2_addr;
wire        id_ex_rs1_cen;
wire        id_ex_rs2_cen;

wire [63:0] id_ex_imm;
wire [63:0] id_ex_rs1_rdata;
wire [63:0] id_ex_rs2_rdata;
wire [63:0] id_ex_pc;

wire [12:0] id_ex_alu_info;
wire        id_ex_op2_is_imm;
wire        id_ex_op_is_jal;

wire [10:0] id_ex_ls_info;
wire        id_ex_mem_read;
wire        id_ex_mem_write;

wire        id_ex_rd_wen;
wire [4:0]  id_ex_rd_addr;

wire        id_ex_csr_wen;
wire [63:0] id_ex_csr_rdata;
wire [11:0] id_ex_csr_raddr;
wire [11:0] id_ex_csr_waddr;
wire [5:0]  id_ex_csr_info;

//===================S 3====================
wire [63:0] o_exu_rd_data;
wire [4:0]  o_exu_rd_addr;
wire        o_exu_rd_wen;
wire [63:0] o_exu_mem_addr;
wire [63:0] o_exu_mem_wdata;
wire [10:0] o_exu_ls_info;
wire        o_exu_mem_read;
wire        o_exu_mem_write;

wire        i_forward_ex_rs1;
wire        i_forward_ex_rs2;
wire        i_forward_ls_rs1;
wire        i_forward_ls_rs2;

wire [63:0] o_exu_csr_wdata;
wire        o_exu_csr_wen;
wire [11:0] o_exu_csr_waddr;

wire [63:0] o_cpu_csr_rdata;
wire [63:0] o_clint_csr_mtvec;
wire [63:0] o_clint_csr_mepc;
wire [63:0] o_clint_csr_mstatus;
wire        o_global_int_en;
wire        o_mtime_int_en;
wire        o_mtime_int_pend;

wire [63:0] ex_ls_rd_data;
wire [4:0]  ex_ls_rd_addr;
wire        ex_ls_rd_wen;
wire        ex_ls_mem_cen;
wire        ex_ls_mem_wen;
wire [63:0] ex_ls_mem_addr;
wire [63:0] ex_ls_mem_wdata;
wire [10:0] ex_ls_ls_info;
wire        ex_ls_mem_read;
wire        ex_ls_mem_write;

//=================S 4=======================
wire [63:0] o_lsu_rd_data;
wire [4:0]  o_lsu_rd_addr;
wire        o_lsu_rd_wen;
wire [63:0] o_lsu_mem_rdata;
wire        o_lsu_mem_read;

wire [63:0] ls_wb_rd_data;
wire [4:0]  ls_wb_rd_addr;
wire        ls_wb_rd_wen;
wire [63:0] ls_wb_mem_rdata;
wire        ls_wb_mem_read;

wire [63:0] o_lsu_addr;
wire        o_lsu_wen;
wire        o_lsu_valid;

wire [63:0] o_lsu_wdata;
wire [2:0]  o_lsu_size;
wire        o_lsu_hold;

//=================S 5========================
wire        o_wbu_rd_wen;
wire [4:0]  o_wbu_rd_addr;
wire [63:0] o_wbu_rd_wdata;

//==============hazard dtection==============
wire        o_load_use;
wire        o_ctrl_forward_ex_rs1;
wire        o_ctrl_forward_ex_rs2;
wire        o_ctrl_forward_ls_rs1;
wire        o_ctrl_forward_ls_rs2;
wire        o_ctrl_load_use;

//==============Clint====================
wire [63:0] o_clint_int_addr;
wire        o_clint_int_valid;
wire        o_clint_hold;

wire        o_clint_csr_wen;
wire [11:0] o_clint_csr_waddr;
wire [63:0] o_clint_csr_wdata;

//==============Timer===================
wire        o_timer_int;
wire [63:0] o_timer_rdata;

//===========Ram Arbiter==================
wire        o_arb_ifu_ready;
wire [31:0] o_arb_ifu_rdata;

wire        o_arb_lsu_ready;
wire [63:0] o_arb_lsu_rdata;

wire [63:0] o_arb_timer_addr;
wire        o_arb_timer_wen;
wire        o_arb_timer_valid;
wire [63:0] o_arb_timer_wdata;

wire [63:0] o_arb_ram_addr;
wire        o_arb_ram_wen;
wire        o_arb_ram_valid;
wire [63:0] o_arb_ram_wdata;
wire [2:0]  o_arb_ram_size;


//===========AXI master interface=======
wire        o_rw_ready;
wire [63:0] o_rw_rdata;




//============Stage 1=====================
//-------ifu---------------
ifu u_ifu(
    .clk          ( clk          ),
    .rst_n        ( rst_n        ),

    .o_ram_addr   ( o_ifu_addr   ),
    .o_ram_valid  ( o_ifu_valid  ),
    .i_ram_ready  ( o_arb_ifu_ready  ),
    .i_ram_rdata  ( o_arb_ifu_rdata  ),
    .o_ram_size   ( o_ifu_size   ),

    .i_branch_jump( i_ifu_branch_jump & ~o_ctrl_load_use),
    .i_hold       ( o_load_use | o_lsu_hold | o_clint_hold ),
    .i_next_pc    ( i_ifu_next_pc    ),
    .o_instr      ( o_ifu_instr      ),
    .o_instr_valid( o_ifu_instr_valid),
    .o_pc         ( o_ifu_pc         ),

    .i_int_valid  ( o_clint_int_valid),
    .i_int_addr   ( o_clint_int_addr )
);

// when load use, stall
// when jump, flush
pipeline_reg#(
    .N     ( 32 )
)u0_if_id_reg(
    .clk   ( clk   ),
    .clear ( (i_ifu_branch_jump & ~o_ctrl_load_use) | ~o_ifu_instr_valid),
    .hold  ( o_load_use | o_ctrl_load_use | o_lsu_hold | o_clint_hold ),
    .din   ( o_ifu_instr   ),
    .dout  ( if_id_instr  )
);

// when load use, stall
// when jump, flush
pipeline_reg#(
    .N     ( 64 )
)u1_if_id_reg(
    .clk   ( clk   ),
    .clear ( (i_ifu_branch_jump & ~o_ctrl_load_use) | ~o_ifu_instr_valid),
    .hold  ( o_load_use | o_ctrl_load_use | o_lsu_hold | o_clint_hold ),
    .din   ( o_ifu_pc   ),
    .dout  ( if_id_instr_addr  )
);



//==============Stage 2========================
//---------reg_file---------
reg_file u_reg_file(
    .clk         ( clk         ),
    .rst_n       ( rst_n       ),
    .i_wen       ( o_wbu_rd_wen     ),
    .i_addr      ( o_wbu_rd_addr    ),
    .i_wdata     ( o_wbu_rd_wdata   ),
    .i_rs1_addr  ( o_idu_rs1_addr   ),
    .i_rs2_addr  ( o_idu_rs2_addr   ),
    .i_rs1_cen   ( o_idu_rs1_cen    ),
    .i_rs2_cen   ( o_idu_rs2_cen    ),
    .o_rs1_rdata ( i_idu_rs1_rdata  ),
    .o_rs2_rdata ( i_idu_rs2_rdata  )
);

//-------idu----------
idu u_idu(
    .i_instr        ( if_id_instr        ),
    .i_instr_addr   ( if_id_instr_addr   ),
    .o_next_pc      ( i_ifu_next_pc  ),
    .o_branch_jump  ( i_ifu_branch_jump  ),

    .i_rs1_rdata    ( i_idu_rs1_rdata    ),
    .i_rs2_rdata    ( i_idu_rs2_rdata    ),
    .o_rs1_addr     ( o_idu_rs1_addr     ),
    .o_rs2_addr     ( o_idu_rs2_addr     ),
    .o_rs1_cen      ( o_idu_rs1_cen      ),
    .o_rs2_cen      ( o_idu_rs2_cen      ),

    .o_imm          ( o_idu_imm          ),
    .o_rs1_rdata    ( o_idu_rs1_rdata    ),
    .o_rs2_rdata    ( o_idu_rs2_rdata    ),
    .o_pc           ( o_idu_pc           ),

    .o_alu_info     ( o_idu_alu_info     ),
    .o_csr_info     ( o_idu_csr_info     ),
    .o_op2_is_imm   ( o_idu_op2_is_imm   ),
    .o_op_is_jal    ( o_idu_op_is_jal    ),

    .o_ls_info      ( o_idu_ls_info      ),
    .o_mem_read     ( o_idu_mem_read     ),
    .o_mem_write    ( o_idu_mem_write    ),

    .o_rd_wen       ( o_idu_rd_wen       ),
    .o_rd_addr      ( o_idu_rd_addr      ),

    .o_op_is_branch  ( o_idu_op_is_branch ),
    .i_forward_ex_rs1( o_ctrl_forward_ex_rs1 ),
    .i_forward_ex_rs2( o_ctrl_forward_ex_rs2 ),
    .i_forward_ls_rs1( o_ctrl_forward_ls_rs1),
    .i_forward_ls_rs2( o_ctrl_forward_ls_rs2),
    .i_ex_ls_mem_read( ex_ls_mem_read),
    .i_exu_rd_data   ( o_exu_rd_data ),
    .i_lsu_rd_data   ( o_lsu_rd_data ),
    .i_lsu_mem_rdata ( o_lsu_mem_rdata),

    .i_csr_rdata     ( o_cpu_csr_rdata),
    .o_csr_wen       ( o_idu_csr_wen),
    .o_csr_rdata     ( o_idu_csr_rdata),
    .o_csr_raddr     ( o_idu_csr_raddr),
    .o_csr_waddr     ( o_idu_csr_waddr)
);

pipeline_reg#(
    .N     ( 5 )
)u0_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold | o_clint_hold ),
    .din   ( o_idu_rs1_addr   ),
    .dout  ( id_ex_rs1_addr   )
);

pipeline_reg#(
    .N     ( 5 )
)u1_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold | o_clint_hold  ),
    .din   ( o_idu_rs2_addr   ),
    .dout  ( id_ex_rs2_addr   )
);

pipeline_reg#(
    .N     ( 1 )
)u2_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold | o_clint_hold  ),
    .din   ( o_idu_rs1_cen   ),
    .dout  ( id_ex_rs1_cen   )
);

pipeline_reg#(
    .N     ( 1 )
)u3_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold | o_clint_hold  ),
    .din   ( o_idu_rs2_cen   ),
    .dout  ( id_ex_rs2_cen   )
);

pipeline_reg#(
    .N     ( 64 )
)u4_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold | o_clint_hold  ),
    .din   ( o_idu_imm   ),
    .dout  ( id_ex_imm   )
);

pipeline_reg#(
    .N     ( 64 )
)u5_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold | o_clint_hold  ),
    .din   ( o_idu_rs1_rdata   ),
    .dout  ( id_ex_rs1_rdata   )
);

pipeline_reg#(
    .N     ( 64 )
)u6_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold | o_clint_hold  ),
    .din   ( o_idu_rs2_rdata   ),
    .dout  ( id_ex_rs2_rdata   )
);

pipeline_reg#(
    .N     ( 64 )
)u7_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold | o_clint_hold  ),
    .din   ( o_idu_pc   ),
    .dout  ( id_ex_pc   )
);

pipeline_reg#(
    .N     ( 13 )
)u8_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold | o_clint_hold  ),
    .din   ( o_idu_alu_info   ),
    .dout  ( id_ex_alu_info   )
);

pipeline_reg#(
    .N     ( 1 )
)u9_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold | o_clint_hold  ),
    .din   ( o_idu_op2_is_imm   ),
    .dout  ( id_ex_op2_is_imm   )
);

pipeline_reg#(
    .N     ( 1 )
)u10_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold | o_clint_hold  ),
    .din   ( o_idu_op_is_jal   ),
    .dout  ( id_ex_op_is_jal   )
);

pipeline_reg#(
    .N     ( 11 )
)u11_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold | o_clint_hold  ),
    .din   ( o_idu_ls_info   ),
    .dout  ( id_ex_ls_info   )
);

// when load use, clear mem read signal
pipeline_reg#(
    .N     ( 1 )
)u12_id_ex_reg(
    .clk   ( clk   ),
    .clear ( o_load_use | o_lsu_hold | o_clint_hold),
    .hold  ( 1'b0  ),
    .din   ( o_idu_mem_read   ),
    .dout  ( id_ex_mem_read   )
);

// when load use, clear mem write signal
pipeline_reg#(
    .N     ( 1 )
)u13_id_ex_reg(
    .clk   ( clk   ),
    .clear ( o_load_use | o_lsu_hold | o_clint_hold),
    .hold  ( 1'b0  ),
    .din   ( o_idu_mem_write   ),
    .dout  ( id_ex_mem_write   )
);

// when load use, clear rd write signal
pipeline_reg#(
    .N     ( 1 )
)u14_id_ex_reg(
    .clk   ( clk   ),
    .clear ( o_load_use | o_lsu_hold | o_clint_hold),
    .hold  ( 1'b0  ),
    .din   ( o_idu_rd_wen   ),
    .dout  ( id_ex_rd_wen   )
);

pipeline_reg#(
    .N     ( 5 )
)u15_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold | o_clint_hold ),
    .din   ( o_idu_rd_addr   ),
    .dout  ( id_ex_rd_addr   )
);

pipeline_reg#(
    .N     ( 1 )
)u16_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold | o_clint_hold  ),
    .din   ( o_idu_csr_wen   ),
    .dout  ( id_ex_csr_wen   )
);

pipeline_reg#(
    .N     ( 64 )
)u17_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold | o_clint_hold  ),
    .din   ( o_idu_csr_rdata   ),
    .dout  ( id_ex_csr_rdata   )
);

pipeline_reg#(
    .N     ( 12 )
)u18_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold | o_clint_hold ),
    .din   ( o_idu_csr_raddr   ),
    .dout  ( id_ex_csr_raddr   )
);

pipeline_reg#(
    .N     ( 12 )
)u19_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold | o_clint_hold ),
    .din   ( o_idu_csr_waddr   ),
    .dout  ( id_ex_csr_waddr   )
);

pipeline_reg#(
    .N     ( 6 )
)u20_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold | o_clint_hold ),
    .din   ( o_idu_csr_info[5:0] ),
    .dout  ( id_ex_csr_info      )
);

//===============Stage 3======================
//---------ex-----------
exu u_exu(
    .i_imm         ( id_ex_imm     ),
    .i_rs1_rdata   ( id_ex_rs1_rdata   ),
    .i_rs2_rdata   ( id_ex_rs2_rdata   ),
    .i_csr_rdata   ( id_ex_csr_rdata   ),
    .i_pc          ( id_ex_pc          ),

    .i_alu_info    ( id_ex_alu_info    ),
    .i_csr_info    ( id_ex_csr_info    ),
    .i_op2_is_imm  ( id_ex_op2_is_imm  ),
    .i_op_is_jal   ( id_ex_op_is_jal   ),

    .i_rd_wen      ( id_ex_rd_wen      ),
    .o_rd_wen      ( o_exu_rd_wen      ),
    .i_rd_addr     ( id_ex_rd_addr     ),
    .o_rd_data     ( o_exu_rd_data     ),
    .o_rd_addr     ( o_exu_rd_addr     ),

    .o_mem_addr    ( o_exu_mem_addr    ),
    .o_mem_wdata   ( o_exu_mem_wdata   ),
    .i_ls_info     ( id_ex_ls_info     ),
    .i_mem_read    ( id_ex_mem_read    ),
    .i_mem_write   ( id_ex_mem_write   ),
    .o_ls_info     ( o_exu_ls_info     ),
    .o_mem_read    ( o_exu_mem_read    ),
    .o_mem_write   ( o_exu_mem_write   ),

    .i_forward_ex_rs1(i_forward_ex_rs1),
    .i_forward_ex_rs2(i_forward_ex_rs2),
    .i_forward_ls_rs1(i_forward_ls_rs1),
    .i_forward_ls_rs2(i_forward_ls_rs2),

    .i_ex_ls_rd_data (ex_ls_rd_data),
    .i_wbu_rd_wdata  (o_wbu_rd_wdata),

    .i_csr_wen       (id_ex_csr_wen),
    .i_csr_waddr     (id_ex_csr_waddr),
    .o_csr_wdata     (o_exu_csr_wdata),
    .o_csr_wen       (o_exu_csr_wen),
    .o_csr_waddr     (o_exu_csr_waddr)
);

//-------------CSR-----------------
csr_file u_csr_file(
    .clk                 ( clk                 ),
    .rst_n               ( rst_n               ),
    .i_cpu_csr_wen       ( o_exu_csr_wen       ),
    .i_cpu_csr_raddr     ( o_idu_csr_raddr     ),
    .i_cpu_csr_waddr     ( o_exu_csr_waddr     ),
    .i_cpu_csr_wdata     ( o_exu_csr_wdata     ),
    .o_cpu_csr_rdata     ( o_cpu_csr_rdata     ),

    .i_clint_csr_wen     ( o_clint_csr_wen     ),
    .i_clint_csr_waddr   ( o_clint_csr_waddr   ),
    .i_clint_csr_wdata   ( o_clint_csr_wdata   ),
    .o_clint_csr_mtvec   ( o_clint_csr_mtvec   ),
    .o_clint_csr_mepc    ( o_clint_csr_mepc    ),
    .o_clint_csr_mstatus ( o_clint_csr_mstatus ),
    .o_global_int_en     ( o_global_int_en     ),
    .o_mtime_int_en      ( o_mtime_int_en      ),
    .o_mtime_int_pend    ( o_mtime_int_pend    ),
    .i_timer_int         ( o_timer_int         )
);

//-------------Clint----------------
clint u_clint(
    .clk              ( clk              ),
    .rst_n            ( rst_n            ),
    .i_timer_int      ( o_timer_int      ),
    .i_expt_info      ( o_idu_csr_info[8:6] ),
    .i_instr_addr     ( if_id_instr_addr  ),
    .i_branch_jump    ( i_ifu_branch_jump ),
    .i_jump_addr      ( i_ifu_next_pc     ),
    .o_int_addr       ( o_clint_int_addr  ),
    .o_int_valid      ( o_clint_int_valid ),
    .o_hold           ( o_clint_hold      ),
    .i_global_int_en  ( o_global_int_en   ),
    .i_mtime_int_en   ( o_mtime_int_en    ),
    .i_mtime_int_pend ( o_mtime_int_pend  ),
    .i_csr_mtvec      ( o_clint_csr_mtvec ),
    .i_csr_mepc       ( o_clint_csr_mepc  ),
    .i_csr_mstatus    ( o_clint_csr_mstatus ),
    .o_csr_wen        ( o_clint_csr_wen  ),
    .o_csr_waddr      ( o_clint_csr_waddr),
    .o_csr_wdata      ( o_clint_csr_wdata)
);

pipeline_reg#(
    .N     ( 64 )
)u0_ex_ls_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold ),
    .din   ( o_exu_rd_data   ),
    .dout  ( ex_ls_rd_data   )
);

pipeline_reg#(
    .N     ( 5 )
)u1_ex_ls_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold ),
    .din   ( o_exu_rd_addr   ),
    .dout  ( ex_ls_rd_addr   )
);

pipeline_reg#(
    .N     ( 1 )
)u2_ex_ls_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold ),
    .din   ( o_exu_rd_wen   ),
    .dout  ( ex_ls_rd_wen   )
);

pipeline_reg#(
    .N     ( 64 )
)u3_ex_ls_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold ),
    .din   ( o_exu_mem_addr   ),
    .dout  ( ex_ls_mem_addr   )
);

pipeline_reg#(
    .N     ( 64 )
)u4_ex_ls_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold ),
    .din   ( o_exu_mem_wdata   ),
    .dout  ( ex_ls_mem_wdata   )
);

pipeline_reg#(
    .N     ( 11 )
)u5_ex_ls_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold ),
    .din   ( o_exu_ls_info   ),
    .dout  ( ex_ls_ls_info   )
);

pipeline_reg#(
    .N     ( 1 )
)u6_ex_ls_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold ),
    .din   ( o_exu_mem_read   ),
    .dout  ( ex_ls_mem_read   )
);

pipeline_reg#(
    .N     ( 1 )
)u7_ex_ls_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( o_lsu_hold ),
    .din   ( o_exu_mem_write   ),
    .dout  ( ex_ls_mem_write   )
);


//===================Stage 4=========================
//---------lsu------------
lsu u_lsu(
    .clk          ( clk               ),
    .rst_n        ( rst_n             ),
    .i_mem_addr   ( ex_ls_mem_addr    ),
    .i_mem_wdata  ( ex_ls_mem_wdata   ),
    .i_ls_info    ( ex_ls_ls_info     ),
    .i_mem_read   ( ex_ls_mem_read    ),
    .i_mem_write  ( ex_ls_mem_write   ),

    .o_ram_addr   ( o_lsu_addr),
    .o_ram_wen    ( o_lsu_wen),
    .o_ram_valid  ( o_lsu_valid),
    .i_ram_ready  ( o_arb_lsu_ready),
    .o_ram_wdata  ( o_lsu_wdata),
    .o_ram_size   ( o_lsu_size),
    .i_ram_rdata  ( o_arb_lsu_rdata),

    .i_rd_data    ( ex_ls_rd_data     ),
    .i_rd_addr    ( ex_ls_rd_addr     ),
    .o_rd_data    ( o_lsu_rd_data     ),
    .o_rd_addr    ( o_lsu_rd_addr     ),
    .o_mem_rdata  ( o_lsu_mem_rdata   ),

    .i_rd_wen     ( ex_ls_rd_wen      ),
    .o_rd_wen     ( o_lsu_rd_wen      ),
    .o_mem_read   ( o_lsu_mem_read    ),

    .o_hold       ( o_lsu_hold )
);

pipeline_reg#(
    .N     ( 64 )
)u0_ls_wb_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_lsu_rd_data   ),
    .dout  ( ls_wb_rd_data   )
);

pipeline_reg#(
    .N     ( 5 )
)u1_ls_wb_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_lsu_rd_addr   ),
    .dout  ( ls_wb_rd_addr   )
);

pipeline_reg#(
    .N     ( 1 )
)u2_ls_wb_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_lsu_rd_wen   ),
    .dout  ( ls_wb_rd_wen   )
);

pipeline_reg#(
    .N     ( 64 )
)u3_ls_wb_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_lsu_mem_rdata   ),
    .dout  ( ls_wb_mem_rdata   )
);

pipeline_reg#(
    .N     ( 1 )
)u5_ls_wb_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_lsu_mem_read   ),
    .dout  ( ls_wb_mem_read   )
);

//=====================Stage 5====================
//------------wbu----------------
wbu u_wbu(
    .i_rd_data    ( ls_wb_rd_data   ),
    .i_rd_addr    ( ls_wb_rd_addr   ),
    .i_rd_wen     ( ls_wb_rd_wen    ),
    .i_mem_rdata  ( ls_wb_mem_rdata ),
    .i_mem_read   ( ls_wb_mem_read  ),
    .o_rd_wen     ( o_wbu_rd_wen    ),
    .o_rd_addr    ( o_wbu_rd_addr   ),
    .o_rd_wdata   ( o_wbu_rd_wdata  )
);


//------------hazard detect---------
hdu u_hdu(
    .i_id_ex_rs1      ( id_ex_rs1_addr ),
    .i_id_ex_rs2      ( id_ex_rs2_addr ),
    .i_id_ex_rs1_cen  ( id_ex_rs1_cen  ),
    .i_id_ex_rs2_cen  ( id_ex_rs2_cen  ),

    .i_if_id_rs1      ( o_idu_rs1_addr ),
    .i_if_id_rs2      ( o_idu_rs2_addr ),
    .i_if_id_rs1_cen  ( o_idu_rs1_cen  ),
    .i_if_id_rs2_cen  ( o_idu_rs2_cen  ),

    .i_id_ex_rd       ( id_ex_rd_addr  ),
    .i_ex_ls_rd       ( ex_ls_rd_addr  ),
    .i_ls_wb_rd       ( ls_wb_rd_addr  ),
    .i_ex_ls_rd_wen   ( ex_ls_rd_wen   ),
    .i_ls_wb_rd_wen   ( ls_wb_rd_wen   ),
    .i_id_ex_mem_read ( id_ex_mem_read ),
    .i_ls_wb_mem_read ( ls_wb_mem_read ),

    .o_forward_ex_rs1 ( i_forward_ex_rs1 ),
    .o_forward_ex_rs2 ( i_forward_ex_rs2 ),
    .o_forward_ls_rs1 ( i_forward_ls_rs1 ),
    .o_forward_ls_rs2 ( i_forward_ls_rs2 ),
    .o_load_use       ( o_load_use       ),
    .i_op_is_branch       (o_idu_op_is_branch),
    .i_id_ex_rd_wen       (id_ex_rd_wen),
    .i_ex_ls_mem_read     (ex_ls_mem_read),
    .o_ctrl_forward_ex_rs1(o_ctrl_forward_ex_rs1),
    .o_ctrl_forward_ex_rs2(o_ctrl_forward_ex_rs2),
    .o_ctrl_forward_ls_rs1(o_ctrl_forward_ls_rs1),
    .o_ctrl_forward_ls_rs2(o_ctrl_forward_ls_rs2),
    .o_ctrl_load_use      (o_ctrl_load_use)
);


//--------------timer---------------
timer u_timer(
    .clk         ( clk         ),
    .rst_n       ( rst_n       ),
    .o_timer_int ( o_timer_int ),
    .i_wen       ( o_arb_timer_wen ),
    .i_valid     ( o_arb_timer_valid ),
    .i_addr      ( o_arb_timer_addr  ),
    .i_wdata     ( o_arb_timer_wdata ),
    .o_rdata     ( o_timer_rdata     )
);


//---------------ram arbiter------------
ram_arbiter u_ram_arbiter(
    .clk           ( clk               ),
    .rst_n         ( rst_n             ),
    .i_ifu_addr    ( o_ifu_addr        ),
    .i_ifu_valid   ( o_ifu_valid       ),
    .o_ifu_ready   ( o_arb_ifu_ready   ),
    .i_ifu_size    ( o_ifu_size        ),
    .o_ifu_rdata   ( o_arb_ifu_rdata   ),

    .i_lsu_addr    ( o_lsu_addr        ),
    .i_lsu_wen     ( o_lsu_wen         ),
    .i_lsu_valid   ( o_lsu_valid       ),
    .o_lsu_ready   ( o_arb_lsu_ready   ),
    .i_lsu_wdata   ( o_lsu_wdata       ),
    .i_lsu_size    ( o_lsu_size        ),
    .o_lsu_rdata   ( o_arb_lsu_rdata   ),

    .o_timer_addr  ( o_arb_timer_addr  ),
    .o_timer_wen   ( o_arb_timer_wen   ),
    .o_timer_valid ( o_arb_timer_valid ),
    .o_timer_wdata ( o_arb_timer_wdata ),
    .i_timer_rdata ( o_timer_rdata     ),

    .o_ram_addr    ( o_arb_ram_addr    ),
    .o_ram_wen     ( o_arb_ram_wen     ),
    .o_ram_valid   ( o_arb_ram_valid   ),
    .i_ram_ready   ( o_rw_ready        ),
    .o_ram_wdata   ( o_arb_ram_wdata   ),
    .o_ram_size    ( o_arb_ram_size    ),
    .i_ram_rdata   ( o_rw_rdata        )
);

//-----------AXI master interface---------
axi_master_if#(
    .RW_DATA_WIDTH   ( 64 ),
    .RW_ADDR_WIDTH   ( 64 ),
    .AXI_DATA_WIDTH  ( 64 ),
    .AXI_ADDR_WIDTH  ( 64 ),
    .AXI_ID_WIDTH    ( 4 ),
    .AXI_USER_WIDTH  ( 1 )
)u_axi_master_if(
    .clk             ( clk             ),
    .rst_n           ( rst_n           ),
    .rw_id_i         ( 1'b0            ),
    .rw_valid_i      ( o_arb_ram_valid ),
    .rw_ready_o      ( o_rw_ready      ),
    .rw_req_i        ( o_arb_ram_wen   ),
    .rw_rdata_o      ( o_rw_rdata      ),
    .rw_wdata_i      ( o_arb_ram_wdata ),
    .rw_addr_i       ( o_arb_ram_addr  ),
    .rw_size_i       ( o_arb_ram_size  ),
    .rw_resp_o       (                 ),

    .axi_aw_id_o     ( axi_aw_id_o     ),
    .axi_aw_addr_o   ( axi_aw_addr_o   ),
    .axi_aw_len_o    ( axi_aw_len_o    ),
    .axi_aw_size_o   ( axi_aw_size_o   ),
    .axi_aw_burst_o  ( axi_aw_burst_o  ),
    .axi_aw_lock_o   ( axi_aw_lock_o   ),
    .axi_aw_cache_o  ( axi_aw_cache_o  ),
    .axi_aw_prot_o   ( axi_aw_prot_o   ),
    .axi_aw_qos_o    ( axi_aw_qos_o    ),
    .axi_aw_region_o ( axi_aw_region_o ),
    .axi_aw_user_o   ( axi_aw_user_o   ),
    .axi_aw_valid_o  ( axi_aw_valid_o  ),
    .axi_aw_ready_i  ( axi_aw_ready_i  ),
    .axi_w_ready_i   ( axi_w_ready_i   ),
    .axi_w_valid_o   ( axi_w_valid_o   ),
    .axi_w_data_o    ( axi_w_data_o    ),
    .axi_w_strb_o    ( axi_w_strb_o    ),
    .axi_w_last_o    ( axi_w_last_o    ),
    .axi_w_user_o    ( axi_w_user_o    ),
    .axi_b_ready_o   ( axi_b_ready_o   ),
    .axi_b_valid_i   ( axi_b_valid_i   ),
    .axi_b_resp_i    ( axi_b_resp_i    ),
    .axi_b_id_i      ( axi_b_id_i      ),
    .axi_b_user_i    ( axi_b_user_i    ),
    .axi_ar_ready_i  ( axi_ar_ready_i  ),
    .axi_ar_valid_o  ( axi_ar_valid_o  ),
    .axi_ar_addr_o   ( axi_ar_addr_o   ),
    .axi_ar_prot_o   ( axi_ar_prot_o   ),
    .axi_ar_id_o     ( axi_ar_id_o     ),
    .axi_ar_user_o   ( axi_ar_user_o   ),
    .axi_ar_len_o    ( axi_ar_len_o    ),
    .axi_ar_size_o   ( axi_ar_size_o   ),
    .axi_ar_burst_o  ( axi_ar_burst_o  ),
    .axi_ar_lock_o   ( axi_ar_lock_o   ),
    .axi_ar_cache_o  ( axi_ar_cache_o  ),
    .axi_ar_qos_o    ( axi_ar_qos_o    ),
    .axi_ar_region_o ( axi_ar_region_o ),
    .axi_r_ready_o   ( axi_r_ready_o   ),
    .axi_r_valid_i   ( axi_r_valid_i   ),
    .axi_r_resp_i    ( axi_r_resp_i    ),
    .axi_r_data_i    ( axi_r_data_i    ),
    .axi_r_last_i    ( axi_r_last_i    ),
    .axi_r_id_i      ( axi_r_id_i      ),
    .axi_r_user_i    ( axi_r_user_i    )
);

// =============Difftest=============================
reg cmt_wen;
reg [7:0]  cmt_wdest;
reg [63:0] cmt_wdata;
reg [63:0] cmt_pc;
reg [31:0] cmt_inst;
reg cmt_valid;
reg trap;
reg [7:0] trap_code;
reg [63:0] cycleCnt;
reg [63:0] instrCnt;
reg [63:0] regs_diff [0:31];

reg [63:0] if_id_pc;
reg [63:0] id_exe_pc;
reg [63:0] ex_ls_pc;
reg [63:0] ls_wb_pc;

reg [31:0] id_ex_inst;
reg [31:0] ex_ls_inst;
reg [31:0] ls_wb_inst;

reg if_id_inst_valid;
reg id_ex_inst_valid;
reg ex_ls_inst_valid;
reg ls_wb_inst_valid;

always @(posedge clk) begin
    if_id_pc <= o_ifu_addr;
    id_exe_pc <= if_id_pc;
    ex_ls_pc <= id_exe_pc;
    ls_wb_pc <= ex_ls_pc;

    id_ex_inst <= if_id_instr;
    ex_ls_inst <= id_ex_inst;
    ls_wb_inst <= ex_ls_inst;

    if_id_inst_valid <= o_ifu_instr_valid;
    id_ex_inst_valid <= if_id_inst_valid;
    ex_ls_inst_valid <= id_ex_inst_valid;
    ls_wb_inst_valid <= ex_ls_inst_valid;
end

always @(posedge clk) begin
  if (~rst_n) begin
    {cmt_wen, 
    cmt_wdest, 
    cmt_wdata, 
    cmt_pc, 
    cmt_inst, 
    cmt_valid, 
    trap, 
    trap_code, 
    cycleCnt, 
    instrCnt} <= 0;
  end
  else if (~trap) begin
    cmt_wen   <= o_wbu_rd_wen;
    cmt_wdest <= {3'd0, o_wbu_rd_addr};
    cmt_wdata <= o_wbu_rd_wdata;
    cmt_pc    <= ls_wb_pc;
    cmt_inst  <= ls_wb_inst;
    cmt_valid <= ls_wb_inst_valid;
    regs_diff <= u_reg_file.regs;
    trap      <= ls_wb_inst[6:0] == 7'h6b;
    trap_code <= u_reg_file.regs[10][7:0];
    cycleCnt  <= cycleCnt + 1;
    instrCnt  <= instrCnt + ls_wb_inst_valid;
  end
end

DifftestInstrCommit DifftestInstrCommit(
  .clock              (clk),
  .coreid             (0),
  .index              (0),
  .valid              (cmt_valid),
  .pc                 (cmt_pc),
  .instr              (cmt_inst),
  .skip               (0),
  .isRVC              (0),
  .scFailed           (0),
  .wen                (cmt_wen),
  .wdest              (cmt_wdest),
  .wdata              (cmt_wdata)
);

DifftestArchIntRegState DifftestArchIntRegState (
  .clock              (clk),
  .coreid             (0),
  .gpr_0              (regs_diff[0]),
  .gpr_1              (regs_diff[1]),
  .gpr_2              (regs_diff[2]),
  .gpr_3              (regs_diff[3]),
  .gpr_4              (regs_diff[4]),
  .gpr_5              (regs_diff[5]),
  .gpr_6              (regs_diff[6]),
  .gpr_7              (regs_diff[7]),
  .gpr_8              (regs_diff[8]),
  .gpr_9              (regs_diff[9]),
  .gpr_10             (regs_diff[10]),
  .gpr_11             (regs_diff[11]),
  .gpr_12             (regs_diff[12]),
  .gpr_13             (regs_diff[13]),
  .gpr_14             (regs_diff[14]),
  .gpr_15             (regs_diff[15]),
  .gpr_16             (regs_diff[16]),
  .gpr_17             (regs_diff[17]),
  .gpr_18             (regs_diff[18]),
  .gpr_19             (regs_diff[19]),
  .gpr_20             (regs_diff[20]),
  .gpr_21             (regs_diff[21]),
  .gpr_22             (regs_diff[22]),
  .gpr_23             (regs_diff[23]),
  .gpr_24             (regs_diff[24]),
  .gpr_25             (regs_diff[25]),
  .gpr_26             (regs_diff[26]),
  .gpr_27             (regs_diff[27]),
  .gpr_28             (regs_diff[28]),
  .gpr_29             (regs_diff[29]),
  .gpr_30             (regs_diff[30]),
  .gpr_31             (regs_diff[31])
);

DifftestTrapEvent DifftestTrapEvent(
  .clock              (clk),
  .coreid             (0),
  .valid              (trap),
  .code               (trap_code),
  .pc                 (cmt_pc),
  .cycleCnt           (cycleCnt),
  .instrCnt           (instrCnt)
);

DifftestCSRState DifftestCSRState(
  .clock              (clk),
  .coreid             (0),
  .priviledgeMode     (`RISCV_PRIV_MODE_M),
  .mstatus            (0),
  .sstatus            (0),
  .mepc               (0),
  .sepc               (0),
  .mtval              (0),
  .stval              (0),
  .mtvec              (0),
  .stvec              (0),
  .mcause             (0),
  .scause             (0),
  .satp               (0),
  .mip                (0),
  .mie                (0),
  .mscratch           (0),
  .sscratch           (0),
  .mideleg            (0),
  .medeleg            (0)
);

DifftestArchFpRegState DifftestArchFpRegState(
  .clock              (clk),
  .coreid             (0),
  .fpr_0              (0),
  .fpr_1              (0),
  .fpr_2              (0),
  .fpr_3              (0),
  .fpr_4              (0),
  .fpr_5              (0),
  .fpr_6              (0),
  .fpr_7              (0),
  .fpr_8              (0),
  .fpr_9              (0),
  .fpr_10             (0),
  .fpr_11             (0),
  .fpr_12             (0),
  .fpr_13             (0),
  .fpr_14             (0),
  .fpr_15             (0),
  .fpr_16             (0),
  .fpr_17             (0),
  .fpr_18             (0),
  .fpr_19             (0),
  .fpr_20             (0),
  .fpr_21             (0),
  .fpr_22             (0),
  .fpr_23             (0),
  .fpr_24             (0),
  .fpr_25             (0),
  .fpr_26             (0),
  .fpr_27             (0),
  .fpr_28             (0),
  .fpr_29             (0),
  .fpr_30             (0),
  .fpr_31             (0)
);

endmodule