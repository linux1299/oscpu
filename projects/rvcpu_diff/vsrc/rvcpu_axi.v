// Copyright 2022 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2022.04.11
// RVCPU with AXI master top module

`include "defines.v"

module rvcpu_axi (
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



endmodule