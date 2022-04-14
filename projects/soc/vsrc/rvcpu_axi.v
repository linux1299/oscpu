// Copyright 2022 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2022.04.11
// RVCPU with AXI master top module

`include "defines.v"

module rvcpu_axi (
    input clk,
    input rst_n,

    // AXI master
    // write address channel
    output [3:0]    axi_aw_id_o,
    output [31:0]   axi_aw_addr_o,
    output [7:0]    axi_aw_len_o,
    output [2:0]    axi_aw_size_o,
    output [1:0]    axi_aw_burst_o,
    output          axi_aw_lock_o,
    output [3:0]    axi_aw_cache_o,
    output [2:0]    axi_aw_prot_o,
    output [3:0]    axi_aw_qos_o,
    output [3:0]    axi_aw_region_o,
    output [0:0]    axi_aw_user_o,
    output          axi_aw_valid_o,
    input           axi_aw_ready_i,

    // write data channel
    input           axi_w_ready_i,
    output          axi_w_valid_o,
    output [63:0]   axi_w_data_o,
    output [7:0]    axi_w_strb_o,
    output          axi_w_last_o,
    output [0:0]    axi_w_user_o,

    // write response channel
    output          axi_b_ready_o,
    input           axi_b_valid_i,
    input  [1:0]    axi_b_resp_i,
    input  [3:0]    axi_b_id_i,
    input  [0:0]    axi_b_user_i,

    // read address channel
    input           axi_ar_ready_i,
    output          axi_ar_valid_o,
    output [63:0]   axi_ar_addr_o,
    output [2:0]    axi_ar_prot_o,
    output [3:0]    axi_ar_id_o,
    output [0:0]    axi_ar_user_o,
    output [7:0]    axi_ar_len_o,
    output [2:0]    axi_ar_size_o,
    output [1:0]    axi_ar_burst_o,
    output          axi_ar_lock_o,
    output [3:0]    axi_ar_cache_o,
    output [3:0]    axi_ar_qos_o,
    output [3:0]    axi_ar_region_o,

    // read data channel
    output          axi_r_ready_o,
    input           axi_r_valid_i,
    input  [1:0]    axi_r_resp_i,
    input  [63:0]   axi_r_data_i,
    input           axi_r_last_i,
    input  [3:0]    axi_r_id_i,
    input  [0:0]    axi_r_user_i
);

wire         ram_rw_cen_o;
wire         ram_rw_wen_o;
wire  [63:0] ram_rw_addr_o;
wire  [63:0] ram_rw_wdata_o;
wire  [2:0]  ram_rw_size_o;
wire  [7:0]  ram_rw_wmask_o;
wire         ram_rw_ready_i;
wire  [63:0] ram_rw_data_i;

axi_master_if#(
    .RW_DATA_WIDTH   ( 64 ),
    .RW_ADDR_WIDTH   ( 32 ),
    .AXI_DATA_WIDTH  ( 64 ),
    .AXI_ADDR_WIDTH  ( 32 ),
    .AXI_ID_WIDTH    ( 4 ),
    .AXI_USER_WIDTH  ( 1 )
)u_axi_master_if(
    .clk             ( clk             ),
    .rst_n           ( rst_n           ),
    .rw_id_i         ( rw_id_i         ),
    .rw_cen_i        ( ram_rw_cen_o    ),
    .rw_wen_i        ( ram_rw_wen_o    ),
    .rw_addr_i       ( ram_rw_addr_o[31:0] ),
    .rw_size_i       ( ram_rw_size_o   ),
    .rw_wdata_i      ( ram_rw_wdata_o  ),
    .rw_wmask_i      ( ram_rw_wmask_o  ),
    .rw_ready_o      ( ram_rw_ready_i  ),
    .rw_rdata_o      ( ram_rw_data_i   ),
    .rw_resp_o       ( rw_resp_o       ),
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

rvcpu u_rvcpu(
    .clk            ( clk            ),
    .rst_n          ( rst_n          ),
    .ram_rw_cen_o   ( ram_rw_cen_o   ),
    .ram_rw_wen_o   ( ram_rw_wen_o   ),
    .ram_rw_addr_o  ( ram_rw_addr_o  ),
    .ram_rw_wdata_o ( ram_rw_wdata_o ),
    .ram_rw_size_o  ( ram_rw_size_o  ),
    .ram_rw_wmask_o ( ram_rw_wmask_o ),
    .ram_rw_ready_i ( ram_rw_ready_i ),
    .ram_rw_data_i  ( ram_rw_data_i  )
);


endmodule