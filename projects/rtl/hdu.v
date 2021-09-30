// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.07.26
// Hazard detect unit

module  ysyx_210238_hdu (
    // data hazard
    input  [4:0] i_id_ex_rs1,
    input  [4:0] i_id_ex_rs2,
    input        i_id_ex_rs1_cen,
    input        i_id_ex_rs2_cen,

    input  [4:0] i_if_id_rs1,
    input  [4:0] i_if_id_rs2,
    input        i_if_id_rs1_cen,
    input        i_if_id_rs2_cen,

    input  [4:0] i_id_ex_rd,
    input  [4:0] i_ex_ls_rd,
    input  [4:0] i_ls_wb_rd,
    input        i_ex_ls_rd_wen,
    input        i_ls_wb_rd_wen,
    input        i_id_ex_mem_read,
    input        i_ls_wb_mem_read,

    output       o_forward_ex_rs1,
    output       o_forward_ex_rs2,
    output       o_forward_ls_rs1,
    output       o_forward_ls_rs2,
    output       o_load_use,

    // control hazard
    input        i_op_is_branch,
    input        i_id_ex_rd_wen,
    input        i_ex_ls_mem_read,

    output       o_ctrl_forward_ex_rs1,
    output       o_ctrl_forward_ex_rs2,
    output       o_ctrl_forward_ls_rs1,
    output       o_ctrl_forward_ls_rs2,
    output       o_ctrl_load_use

);

//--------------data hazard detect-------------------
assign o_forward_ex_rs1 = i_ex_ls_rd_wen
                        & (i_ex_ls_rd != 5'b0)
                        & (i_ex_ls_rd == i_id_ex_rs1)
                        //& i_id_ex_rs1_cen
                        ;

assign o_forward_ex_rs2 = i_ex_ls_rd_wen
                        & (i_ex_ls_rd != 5'b0)
                        & (i_ex_ls_rd == i_id_ex_rs2)
                        //& i_id_ex_rs2_cen
                        ;

assign o_forward_ls_rs1 = i_ls_wb_rd_wen
                        & (i_ls_wb_rd != 5'b0)
                        & (i_ls_wb_rd == i_id_ex_rs1)
                        & ((i_ex_ls_rd != i_id_ex_rs1) | i_ls_wb_mem_read)
                        //& i_id_ex_rs1_cen
                        ;

assign o_forward_ls_rs2 = i_ls_wb_rd_wen
                        & (i_ls_wb_rd != 5'b0)
                        & (i_ls_wb_rd == i_id_ex_rs2)
                        & ((i_ex_ls_rd != i_id_ex_rs2) | i_ls_wb_mem_read)
                        //& i_id_ex_rs2_cen
                        ;

assign o_load_use = i_id_ex_mem_read
                  & ( (i_if_id_rs1_cen & (i_if_id_rs1 == i_id_ex_rd))
                    | (i_if_id_rs2_cen & (i_if_id_rs2 == i_id_ex_rd)) )
                  ;


//--------------control hazard detect-------------------
assign o_ctrl_forward_ex_rs1 = i_op_is_branch
                            &  i_id_ex_rd_wen
                            & (i_id_ex_rd != 5'b0)
                            & (i_id_ex_rd == i_if_id_rs1)
                            ;

assign o_ctrl_forward_ex_rs2 = i_op_is_branch
                            &  i_id_ex_rd_wen
                            & (i_id_ex_rd != 5'b0)
                            & (i_id_ex_rd == i_if_id_rs2)
                            ;

assign o_ctrl_forward_ls_rs1 = i_op_is_branch
                            &  i_ex_ls_rd_wen
                            & (i_ex_ls_rd != 5'b0)
                            & (i_ex_ls_rd == i_if_id_rs1)
                            & ((i_id_ex_rd != i_if_id_rs1) | i_ex_ls_mem_read)
                            ;

assign o_ctrl_forward_ls_rs2 = i_op_is_branch
                            &  i_ex_ls_rd_wen
                            & (i_ex_ls_rd != 5'b0)
                            & (i_ex_ls_rd == i_if_id_rs2)
                            & ((i_id_ex_rd != i_if_id_rs2) | i_ex_ls_mem_read)
                            ;

assign o_ctrl_load_use = i_op_is_branch
                      &  i_id_ex_mem_read
                      &  ( (i_if_id_rs1 == i_id_ex_rd)
                         | (i_if_id_rs2 == i_id_ex_rd) )
                      ;

endmodule