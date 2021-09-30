// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.07.18
// Write Back unit
// as known as "WB"

module  ysyx_210238_wbu(
    // wb
    input  [63:0] i_rd_data,
    input  [4:0]  i_rd_addr,
    input  [63:0] i_mem_rdata,

    // wb control
    input         i_rd_wen,
    input         i_mem_read,

    // reg_file
    output        o_rd_wen,
    output [4:0]  o_rd_addr,
    output [63:0] o_rd_wdata
);

assign o_rd_wen   = i_rd_wen;

assign o_rd_addr  = i_rd_addr;

assign o_rd_wdata = i_mem_read ? i_mem_rdata : i_rd_data;



endmodule // wbu