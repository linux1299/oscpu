// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.07.18
// Write Back unit
// as known as "WB"

`include "defines.v"

module wbu(
    // wb
    input  [63:0] rd_data_i,
    input  [4:0]  rd_addr_i,
    input         rd_wen_i,
    input         mem_read_i,
    input  [63:0] mem_rdata_i,

    // reg_file
    output        wbu_rd_wen_o,
    output [4:0]  wbu_rd_addr_o,
    output [63:0] wbu_rd_wdata_o
);

assign wbu_rd_wen_o   = rd_wen_i;
assign wbu_rd_addr_o  = rd_addr_i;
assign wbu_rd_wdata_o = mem_read_i ? mem_rdata_i : rd_data_i;

endmodule // wbu