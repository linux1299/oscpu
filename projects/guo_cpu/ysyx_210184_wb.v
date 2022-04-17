
`include "defines.v"

module ysyx_210184_wb(
    // input wire clk,
    // input wire rst,
    input wire [`REG_BUS-1 : 0] wb_data,
    input wire [`REG_BUS-1 : 0] result_ALU,
    input wire [`REG_BUS-1 : 0] pc_plus_4_i,
    input wire                  load_ena_i,
    input wire [         4 : 0] rd,
    input wire                  w_rd_ena,
    // input wire [         3 : 0] bytes_r1,
    // input wire [         3 : 0] bytes_r2,
    // input wire [         2 : 0] r_addr_2_0,
    // input wire [         2 : 0] load_store_bytes_i,
    input wire                  is_jal_i,
    input wire                  is_jalr_i,
    // input wire                  is_U_i,
    
    output wire [`REG_BUS-1 : 0] wb_data_o,
    output wire [         4 : 0] rd_o,
    output wire                  w_ena_o
);

    wire [`REG_BUS-1 : 0] from_mem;
    // wire [`REG_BUS*2-1 : 0] aligned_mem;
    // wire [`REG_BUS-1 : 0] aligned_mem_1;
    // reg  [`REG_BUS-1 : 0] aligned_mem_2;
    // assign aligned_mem = is_misalign ? {wb_data, wb_data_1} : {64'b0, wb_data};
    // assign aligned_mem_1 = aligned_mem[r_addr_2_0*8+:64];
    // always@(*)case (load_store_bytes_i[1:0])
    //     2'b00: aligned_mem_2 = {{56{aligned_mem_1[7]}} & {56{~load_store_bytes_i[2]}}, aligned_mem_1[7:0]};
    //     2'b01: aligned_mem_2 = {{48{aligned_mem_1[15]}} & {48{~load_store_bytes_i[2]}}, aligned_mem_1[15:0]};
    //     2'b10: aligned_mem_2 = {{32{aligned_mem_1[31]}} & {32{~load_store_bytes_i[2]}}, aligned_mem_1[31:0]};
    //     2'b11: aligned_mem_2 = aligned_mem_1[63:0];
    // endcase


    assign from_mem = wb_data;

    assign wb_data_o = (is_jal_i | is_jalr_i) ? pc_plus_4_i : (load_ena_i ? from_mem : result_ALU);
    assign rd_o = rd;
    assign w_ena_o = w_rd_ena;


endmodule
