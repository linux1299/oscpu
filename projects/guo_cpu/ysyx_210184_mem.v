
`include "defines.v"
// `include "ysyx_210184_ff.v"

module ysyx_210184_mem(
    input wire clk,
    input wire rst,
    input wire [`REG_BUS-1 : 0] result_ALU,
    input wire [         4 : 0] rd,
    input wire                  w_rd_ena,
    input wire                  load_ena_i,
    // input wire                  store_ena_i,
    // input wire [         2 : 0] load_store_bytes_i,
    // input wire [`REG_BUS-1 : 0] rs2_data_i,
    // input wire                  is_AL_OP_i,
    input wire                  is_B_i,
    // input wire                  is_U_i,
    input wire                  is_jal_i,
    input wire                  is_jalr_i,
    input wire                  is_B_jump_i,
    input wire                  is_csr_i,
    input wire                  is_ecall_i,
    input wire                  is_mret_i,
    input wire [`REG_BUS-1 : 0] csr_mtvec_i,
    input wire [`REG_BUS-1 : 0] csr_mepc_i,
    input wire [`REG_BUS-1 : 0] pc_plus_i,
    input wire [`REG_BUS-1 : 0] r_csr_i,
    input wire                  MIE,
    input wire                  inst_valid_i,

    input wire                  MAC_ready,
    input wire [`REG_BUS-1 : 0] MAC_data,
    input wire                  mtime_intr_enable_i,
    input wire                  ext_intr_enable_i,
    input wire                  software_intr_enable_i,
    
    output wire [        4 : 0] rd_o,
    output wire                 w_rd_ena_o,
    // output wire                 w_rd_ena_harzied_o,
    output wire [`REG_BUS-1 : 0] wb_data,
    output wire [`REG_BUS-1 : 0] result_ALU_o,
    output wire                  load_ena_o,
    // output wire                  dmem_r_ena,
    // output wire [`REG_BUS-1 : 0] dmem_r_addr,
    // output wire                  dmem_w_ena,
    // output wire [`REG_BUS-1 : 0] dmem_w_addr,
    // output wire [`REG_BUS-1 : 0] dmem_w_data,
    // output wire                  is_AL_OP_o,
    output wire                  is_jal_o,
    output wire                  is_jalr_o,
    // output wire                  is_U_o,
    output wire                  stall,
    // output wire [         2 : 0] r_addr_2_0,
    // output wire [         2 : 0] load_store_bytes_o,
    output wire                  flush,
    output wire [`REG_BUS-1 : 0] pc_plus_o,
    output wire [`REG_BUS-1 : 0] jalr_pc_o,
    output wire                  inst_valid_o
);

    // assign r_addr_2_0 = 3'b000;
    // assign load_store_bytes_o = 3'b0;

    wire intr_flush_inst;
    wire [`REG_BUS-1 : 0] wb_data_wire;



    
    assign stall = ~MAC_ready;

    assign intr_flush_inst = mtime_intr_enable_i | ext_intr_enable_i | software_intr_enable_i;




    ysyx_210184_ff #(.WIDTH( 5)) ff_rd(.clk(clk), .rst(rst), .stall(1'b0), .d(rd), .q(rd_o));
    ysyx_210184_ff #(.WIDTH( 1)) ff_w_rd_ena(.clk(clk), .rst(rst),.stall(1'b0), .d(w_rd_ena & (~stall) & (~ (intr_flush_inst & ~load_ena_i) )), .q(w_rd_ena_o));
    // ysyx_210184_ff #(.WIDTH( 1)) ff_w_rd_h_ena(.clk(clk), .rst(rst),.stall(1'b0), .d(w_rd_ena), .q(w_rd_ena_harzied_o));
    // ff #(.WIDTH( 1)) ff_w_rd_ena(.clk(clk), .rst(rst),.stall(stall), .d(w_rd_ena), .q(w_rd_ena_o));

    assign wb_data_wire = (MAC_ready&load_ena_i) ? MAC_data : wb_data;//load_ena_i ? dmem_r_data : result_ALU;
    ysyx_210184_ff #(.WIDTH(`REG_BUS)) ff_wb_data(.clk(clk), .rst(rst),.stall(1'b0), .d(wb_data_wire), .q(wb_data));
    ysyx_210184_ff #(.WIDTH(`REG_BUS)) ff_result_ALU(.clk(clk), .rst(rst),.stall(1'b0), .d(is_csr_i ? r_csr_i : result_ALU), .q(result_ALU_o));

    ysyx_210184_ff #(.WIDTH( 1)) ff_load_ena(.clk(clk), .rst(rst),.stall(1'b0), .d(load_ena_i), .q(load_ena_o));
    // ysyx_210184_ff #(.WIDTH( 1)) ff_is_AL_OP(.clk(clk), .rst(rst),.stall(1'b0), .d(is_AL_OP_i), .q(is_AL_OP_o));

    ysyx_210184_ff #(.WIDTH( 1)) ff_is_jal(.clk(clk), .rst(rst),.stall(1'b0), .d(is_jal_i), .q(is_jal_o));
    ysyx_210184_ff #(.WIDTH( 1)) ff_is_jalr(.clk(clk), .rst(rst),.stall(1'b0), .d(is_jalr_i), .q(is_jalr_o));
    // ysyx_210184_ff #(.WIDTH( 1)) ff_is_U(.clk(clk), .rst(rst),.stall(1'b0), .d(is_U_i), .q(is_U_o));

    assign flush = (intr_flush_inst) | (is_B_jump_i & is_B_i) | is_jalr_i | (is_ecall_i&MIE) | is_mret_i;
    assign pc_plus_o = pc_plus_i;
    assign jalr_pc_o =  intr_flush_inst ? csr_mtvec_i :
                        (is_ecall_i&MIE) ? csr_mtvec_i :
                        is_mret_i ? csr_mepc_i :
                        result_ALU;

    ysyx_210184_ff #(.WIDTH( 1)) ff_inst_valid(.clk(clk), .rst(rst),.stall(1'b0), .d(inst_valid_i & (~stall) & (~intr_flush_inst)), .q(inst_valid_o));

endmodule
