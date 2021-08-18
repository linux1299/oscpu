// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.07.19
// RVCPU top module

`include "defines.v"

module rvcpu (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low

    // Instruction fetch
    output           o_instr_cen,   // instr chip enable
    output  [63:0]   o_instr_addr,  // instr addr
    input   [31:0]   i_instr,       // instruction
    input            i_instr_valid, // instr is valid

    // Load from or store to data memory
    output           o_mem_cen,    // data memory chip enable
    output           o_mem_wen,    // data memory write enable
    output  [31:0]   o_mem_addr,   // data memory addr
    output  [63:0]   o_mem_wdata,  // data memory write data
    input   [63:0]   i_mem_rdata,  // read data from mem
    input            i_mem_rdata_valid //read data is valid
);

//==============S 1===================
wire        i_ifu_branch_jump;
wire [63:0] i_ifu_next_pc;
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
wire        o_idu_op2_is_imm;
wire        o_idu_op_is_jal;

wire [10:0] o_idu_ls_info;
wire        o_idu_mem_read;
wire        o_idu_mem_write;

wire        o_idu_rd_wen;
wire [4:0]  o_idu_rd_addr;
wire        o_idu_op_is_branch;

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

//===================S 3====================
wire [63:0] o_exu_rd_data;
wire [4:0]  o_exu_rd_addr;
wire        o_exu_rd_wen;
wire [31:0] o_exu_mem_addr;
wire [63:0] o_exu_mem_wdata;
wire [10:0] o_exu_ls_info;
wire        o_exu_mem_read;
wire        o_exu_mem_write;

wire i_forward_ex_rs1;
wire i_forward_ex_rs2;
wire i_forward_ls_rs1;
wire i_forward_ls_rs2;

wire [63:0] ex_ls_rd_data;
wire [4:0]  ex_ls_rd_addr;
wire        ex_ls_rd_wen;
wire        ex_ls_mem_cen;
wire        ex_ls_mem_wen;
wire [31:0] ex_ls_mem_addr;
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



//============Stage 1=====================
//-------ifu---------------
ifu u_ifu(
    .clk          ( clk          ),
    .rst_n        ( rst_n        ),
    .o_instr_addr ( o_instr_addr ),
    .o_instr_cen  ( o_instr_cen  ),
    .i_branch_jump( i_ifu_branch_jump & ~o_ctrl_load_use),
    .i_hold       ( o_load_use       ),
    .i_next_pc    ( i_ifu_next_pc    )
);

// when load use, stall
// when jump, flush
pipline_reg#(
    .N     ( 32 )
)u0_if_id_reg(
    .clk   ( clk   ),
    .clear ( i_ifu_branch_jump & ~o_ctrl_load_use ),
    .hold  ( o_load_use | o_ctrl_load_use ),
    .din   ( i_instr   ),
    .dout  ( if_id_instr  )
);

// when load use, stall
// when jump, flush
pipline_reg#(
    .N     ( 64 )
)u1_if_id_reg(
    .clk   ( clk   ),
    .clear ( i_ifu_branch_jump & ~o_ctrl_load_use ),
    .hold  ( o_load_use | o_ctrl_load_use ),
    .din   ( o_instr_addr   ),
    .dout  ( if_id_instr_addr  )
);



//==============Stage 2========================
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
    .o_pc           ( o_idu_pc),

    .o_alu_info     ( o_idu_alu_info     ),
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
    .i_lsu_mem_rdata ( o_lsu_mem_rdata)
);

pipline_reg#(
    .N     ( 5 )
)u0_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_idu_rs1_addr   ),
    .dout  ( id_ex_rs1_addr   )
);

pipline_reg#(
    .N     ( 5 )
)u1_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_idu_rs2_addr   ),
    .dout  ( id_ex_rs2_addr   )
);

pipline_reg#(
    .N     ( 1 )
)u2_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_idu_rs1_cen   ),
    .dout  ( id_ex_rs1_cen   )
);

pipline_reg#(
    .N     ( 1 )
)u3_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_idu_rs2_cen   ),
    .dout  ( id_ex_rs2_cen   )
);

pipline_reg#(
    .N     ( 64 )
)u4_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_idu_imm   ),
    .dout  ( id_ex_imm   )
);

pipline_reg#(
    .N     ( 64 )
)u5_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_idu_rs1_rdata   ),
    .dout  ( id_ex_rs1_rdata   )
);

pipline_reg#(
    .N     ( 64 )
)u6_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_idu_rs2_rdata   ),
    .dout  ( id_ex_rs2_rdata   )
);

pipline_reg#(
    .N     ( 64 )
)u7_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_idu_pc   ),
    .dout  ( id_ex_pc   )
);

pipline_reg#(
    .N     ( 13 )
)u8_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_idu_alu_info   ),
    .dout  ( id_ex_alu_info   )
);

pipline_reg#(
    .N     ( 1 )
)u9_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_idu_op2_is_imm   ),
    .dout  ( id_ex_op2_is_imm   )
);

pipline_reg#(
    .N     ( 1 )
)u10_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_idu_op_is_jal   ),
    .dout  ( id_ex_op_is_jal   )
);

pipline_reg#(
    .N     ( 11 )
)u11_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_idu_ls_info   ),
    .dout  ( id_ex_ls_info   )
);

// when load use, clear mem read signal
pipline_reg#(
    .N     ( 1 )
)u12_id_ex_reg(
    .clk   ( clk   ),
    .clear ( o_load_use ),
    .hold  ( 1'b0  ),
    .din   ( o_idu_mem_read   ),
    .dout  ( id_ex_mem_read   )
);

// when load use, clear mem write signal
pipline_reg#(
    .N     ( 1 )
)u13_id_ex_reg(
    .clk   ( clk   ),
    .clear ( o_load_use ),
    .hold  ( 1'b0  ),
    .din   ( o_idu_mem_write   ),
    .dout  ( id_ex_mem_write   )
);

// when load use, clear rd write signal
pipline_reg#(
    .N     ( 1 )
)u14_id_ex_reg(
    .clk   ( clk   ),
    .clear ( o_load_use ),
    .hold  ( 1'b0  ),
    .din   ( o_idu_rd_wen   ),
    .dout  ( id_ex_rd_wen   )
);

pipline_reg#(
    .N     ( 5 )
)u15_id_ex_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0 ),
    .din   ( o_idu_rd_addr   ),
    .dout  ( id_ex_rd_addr   )
);



//===============Stage 3======================
//---------ex-----------
exu u_exu(
    .i_imm         ( id_ex_imm     ),
    .i_rs1_rdata   ( id_ex_rs1_rdata   ),
    .i_rs2_rdata   ( id_ex_rs2_rdata   ),
    .i_pc          ( id_ex_pc          ),
    .i_alu_info    ( id_ex_alu_info    ),
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
    .i_wbu_rd_wdata  (o_wbu_rd_wdata)
);



pipline_reg#(
    .N     ( 64 )
)u0_ex_ls_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_exu_rd_data   ),
    .dout  ( ex_ls_rd_data   )
);

pipline_reg#(
    .N     ( 5 )
)u1_ex_ls_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_exu_rd_addr   ),
    .dout  ( ex_ls_rd_addr   )
);

pipline_reg#(
    .N     ( 1 )
)u2_ex_ls_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_exu_rd_wen   ),
    .dout  ( ex_ls_rd_wen   )
);

pipline_reg#(
    .N     ( 32 )
)u3_ex_ls_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_exu_mem_addr   ),
    .dout  ( ex_ls_mem_addr   )
);

pipline_reg#(
    .N     ( 64 )
)u4_ex_ls_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_exu_mem_wdata   ),
    .dout  ( ex_ls_mem_wdata   )
);

pipline_reg#(
    .N     ( 11 )
)u5_ex_ls_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_exu_ls_info   ),
    .dout  ( ex_ls_ls_info   )
);

pipline_reg#(
    .N     ( 1 )
)u6_ex_ls_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_exu_mem_read   ),
    .dout  ( ex_ls_mem_read   )
);

pipline_reg#(
    .N     ( 1 )
)u7_ex_ls_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
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

    .i_rd_data    ( ex_ls_rd_data     ),
    .i_rd_addr    ( ex_ls_rd_addr     ),
    .o_rd_data    ( o_lsu_rd_data     ),
    .o_rd_addr    ( o_lsu_rd_addr     ),
    .o_mem_rdata  ( o_lsu_mem_rdata   ),

    .i_rd_wen     ( ex_ls_rd_wen      ),
    .o_rd_wen     ( o_lsu_rd_wen      ),
    .o_mem_read   ( o_lsu_mem_read    )
);

pipline_reg#(
    .N     ( 64 )
)u0_ls_wb_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_lsu_rd_data   ),
    .dout  ( ls_wb_rd_data   )
);

pipline_reg#(
    .N     ( 5 )
)u1_ls_wb_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_lsu_rd_addr   ),
    .dout  ( ls_wb_rd_addr   )
);

pipline_reg#(
    .N     ( 1 )
)u2_ls_wb_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_lsu_rd_wen   ),
    .dout  ( ls_wb_rd_wen   )
);

pipline_reg#(
    .N     ( 64 )
)u3_ls_wb_reg(
    .clk   ( clk   ),
    .clear ( 1'b0 ),
    .hold  ( 1'b0  ),
    .din   ( o_lsu_mem_rdata   ),
    .dout  ( ls_wb_mem_rdata   )
);

pipline_reg#(
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


endmodule