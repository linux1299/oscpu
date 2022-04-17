
`include "defines.v"
`include "ysyx_210184_if.v"
`include "ysyx_210184_id.v"
`include "ysyx_210184_exe.v"
`include "ysyx_210184_mem.v"
`include "ysyx_210184_wb.v"
`include "ysyx_210184_ff.v"
`include "ysyx_210184_csr.v"
`include "ysyx_210184_MemAccCtrl.v"

module ysyx_210184_core(
    input wire            clk,
    input wire            rst,
    input wire  [`REG_BUS-1 : 0] r_data_axi4,
    input wire                   r_ready_axi4,
    input wire                   w_ready_axi4,

    input wire                   mtime_intr,
    input wire                   ext_intr,
    input wire                   software_intr,


    output wire                  r_ena_axi4,
    output wire                  w_ena_axi4,
    output wire [`REG_BUS-1 : 0] addr_axi4,
    output wire [`REG_BUS-1 : 0] w_data_axi4,
    output wire [        63 : 0] w_mask_axi4_64,

    output wire                  no_Icache_to_axi4,
    output wire                  is_fencei
    

//     output wire [`REG_BUS - 1 : 0] value_x10,
//     output wire                    mac_ok,
//     output wire [`REG_BUS-1 : 0] pc_o
);


    // port define 
//     reg MAC_ready_reg;
    wire [7:0] w_mask_axi4;
    wire [`REG_BUS-1 : 0] inst_addr_if_mac;
    wire [`INS_BUS-1 : 0] inst_mac_if;
    wire [`REG_BUS-1 : 0] data_mac_mem;
    wire MAC_ready;
    wire [`REG_BUS-1 : 0] pc_IF_if_csr;
    wire [`REG_BUS-1 : 0] pc;

    // IF<>ID
    wire [`INS_BUS-1 : 0] inst_if_id;
    wire [`REG_BUS-1 : 0] pc_plus_if_id;
    wire                  is_jal_if_id;
    wire                  inst_valid_if_id;

    wire stall_id;

    // ID<>EX
    wire [3:0] mode_ALU_id_ex;
    wire [1:0] n_bytes_id_ex;
    wire [4:0] rd_id_ex;
    wire       w_rd_ena_id_ex;
    wire [`REG_BUS-1 : 0] op1_id_ex, op2_id_ex;
    wire [4:0] rs1_id_ex, rs2_id_ex;
    wire       load_ena_id_ex;
    wire [2:0] load_store_bytes_id_ex;
    wire       is_AL_OP_id_ex;
    wire       is_I_AL_OP_id_ex;
    wire       store_ena_id_ex;
    wire [`REG_BUS-1 : 0] rs2_data_id_ex;
    wire [`REG_BUS-1 : 0] pc_plus_id_ex;
    wire                  is_B_id_ex;
    wire                  is_jal_id_ex;
    wire                  is_jalr_id_ex;
    wire                  is_auipc_id_ex;
    wire                  is_lui_id_ex;
    wire                  is_csr_id_ex;
    wire                  is_ecall_id_ex;
    wire                  is_mret_id_ex;
    wire [`REG_BUS-1 : 0] pc_ID_if_exe;
    wire                  inst_valid_id_ex;

    //data hazard
    wire                  stall_exe;
    // EX<>MEM
    wire [`REG_BUS-1 : 0] result_ALU_ex_mem;
    wire [`REG_BUS-1 : 0] rs2_data_ex_mem;
    wire [4:0] rd_ex_mem;
    wire       w_rd_ena_ex_mem;
    wire       load_ena_ex_mem;
    wire [2:0] load_store_bytes_ex_mem;
    // wire       is_AL_OP_ex_mem;
    // wire       is_AL_OP_mem;
    wire       store_ena_ex_mem;
    wire       is_B_ex_mem;
    wire       is_B_jump_ex_mem;
    wire       is_ecall_ex_mem;
    wire       is_mret_ex_mem;
    wire [`REG_BUS-1 : 0] pc_plus_ex_mem;
    wire stall_mem;
    wire flush_mem;
    wire [`REG_BUS-1 : 0] pc_plus_mem_if;
    wire is_jal_ex_mem;
    wire is_jalr_ex_mem;
    wire [`REG_BUS-1 : 0] jalr_pc_mem_if;
    // wire  is_U_ex_mem;
    wire inst_valid_ex_mem;

//     wire w_rd_ena_harzied_mem_ex;

    // MEM<>WB
    wire [`REG_BUS-1 : 0] wb_data_mem_wb;
    wire [4:0] rd_mem_wb;
    wire       w_rd_ena_mem_wb;
    wire       load_ena_mem_wb;
    wire [`REG_BUS-1 : 0] result_ALU_mem_wb;
    //WB<>ID
    wire [`REG_BUS-1 : 0] wb_data_wb_id;
    wire [4:0] rd_wb_id;
    wire       w_rd_ena_wb_id;
    // wire [2:0] r_addr_2_0_mem_wb;
    // wire [2:0] load_store_bytes_mem_wb;
    wire [`REG_BUS-1 : 0] pc_plus_4_wb_if;
    wire is_jal_mem_wb;
    wire is_jalr_mem_wb;
    // wire  is_U_mem_wb;


    wire is_csr_ex_csr;
    wire MIE, MTIE, MEIE, MSIE;
    wire [`REG_BUS-1 : 0] r_csr_data_csr_mem;
    wire [`REG_BUS-1 : 0] csr_mtvec_csr_mem;
    wire [`REG_BUS-1 : 0] csr_mepc_csr_mem;
    wire [`REG_BUS-1 : 0] pc_EX_if_csr;
    wire                  inst_valid_mem_csr;


    // Interrupt control
    wire mtime_intr_enable;
    wire [`REG_BUS-1 : 0] pc_intr;

    wire ext_intr_enable;
    wire software_intr_enable;
    //port define end

//     assign pc_o = IF.pc_MEM - 64'd4;
 
//     assign value_x10 = ID.RegFile.regs[10];
//     assign mac_ok = MEIE;//MAC_ready_reg & inst_valid_mem_csr;
//     always @(posedge clk) begin
//             MAC_ready_reg <= MAC_ready;
            
//     end

    assign w_mask_axi4_64 = {{8{w_mask_axi4[7]}}, 
                                {8{w_mask_axi4[6]}},
                                {8{w_mask_axi4[5]}},
                                {8{w_mask_axi4[4]}},
                                {8{w_mask_axi4[3]}},
                                {8{w_mask_axi4[2]}},
                                {8{w_mask_axi4[1]}},
                                {8{w_mask_axi4[0]}}
                                };


    ysyx_210184_MemAccCtrl mac(
            .clk(clk),
            .rst(rst),

            //with cpu
            .r_if_ena(1'b1),
            .r_if_addr(inst_addr_if_mac),
            .r_if_bytes(3'b010),

            .r_mem_ena(load_ena_ex_mem),
            .w_mem_ena(store_ena_ex_mem),
            .rw_mem_addr(result_ALU_ex_mem),
            .rw_mem_bytes(load_store_bytes_ex_mem),
            .w_mem_data(rs2_data_ex_mem),

            .ready(MAC_ready),
            .if_data(inst_mac_if),
            .mem_data(data_mac_mem),

            //with AXI4
            .r_data_from_axi4(r_data_axi4),
            .r_ready_from_axi4(r_ready_axi4),
            .w_ready_from_axi4(w_ready_axi4),

            .r_ena_to_axi4(r_ena_axi4),
            .w_ena_to_axi4(w_ena_axi4),
            .addr_to_axi4(addr_axi4),
            .w_data_to_axi4(w_data_axi4),
            .w_mask_to_axi4(w_mask_axi4),
            .no_Icache(no_Icache_to_axi4),
            .is_fencei(is_fencei)
    );



    ysyx_210184_if IF(
            .clk(clk),
            .rst(rst),
            .inst_i(inst_mac_if),
        //     .stall(stall_exe | stall_mem | stall_id),//(is_jal_if_id & is_B_id_ex)
            .stall_exe(stall_exe),
            .stall_mem(stall_mem),
            .stall_id(stall_id),
            .pc_plus_i(pc_plus_mem_if),
            .flush_i(flush_mem),
            .is_B_jump_i(is_B_jump_ex_mem & is_B_ex_mem),
            .pc_plus_ID_i(pc_plus_if_id),
            .is_jal_i(is_jal_if_id ),
            .is_jalr_mem_i(is_jalr_ex_mem),
            .is_ecall_mem_i(is_ecall_ex_mem & MIE),
            .is_mret_mem_i(is_mret_ex_mem),
            .jalr_pc_i(jalr_pc_mem_if),
            .MAC_ready(MAC_ready),
            .inst_valid_o(inst_valid_if_id),
            .mtime_intr_enable_i(mtime_intr_enable | ext_intr_enable | software_intr_enable),

            .inst_addr(inst_addr_if_mac),
            .inst_o(inst_if_id),
        //     .inst_ena(inst_ena),
            .pc_MEM_o(pc_plus_4_wb_if),
            .pc_ID_o(pc_ID_if_exe),
            .pc_EX_o(pc_EX_if_csr),
            .pc_IF_o(pc_IF_if_csr),
            .pc_o(pc)
             );

    ysyx_210184_id ID(
            .clk(clk),
            .rst(rst),
            .inst_i(inst_if_id),
            .regfile_w_ena(w_rd_ena_wb_id),
            .regfile_w_addr(rd_wb_id),
            .regfile_w_data(wb_data_wb_id),
            .stall_mem(stall_mem),
            .stall_exe(stall_exe),
            .flush_i(flush_mem),
            .is_B_id_ex(is_B_id_ex),
            .inst_valid_i(inst_valid_if_id),
    
            .op1(op1_id_ex),
            .op2(op2_id_ex),
            .rd(rd_id_ex),
            .w_rd_ena(w_rd_ena_id_ex),
            .load_ena(load_ena_id_ex),
            .store_ena(store_ena_id_ex),
            .load_store_bytes(load_store_bytes_id_ex),
            .mode_ALU(mode_ALU_id_ex),
            .n_bytes_ALU(n_bytes_id_ex),
            .is_AL_OP(is_AL_OP_id_ex),
            .is_I_AL_OP_o(is_I_AL_OP_id_ex),
            .rs1(rs1_id_ex),
            .rs2(rs2_id_ex),
            .rs2_data_o(rs2_data_id_ex),
            .is_B_o(is_B_id_ex),
            .is_auipc_o(is_auipc_id_ex),
            .is_lui_o(is_lui_id_ex),
            .pc_plus(pc_plus_id_ex),
            .is_jal_o(is_jal_id_ex),
            .is_jalr_o(is_jalr_id_ex),
            .is_jal_IF_o(is_jal_if_id),
            .is_csr_o(is_csr_id_ex),
            .is_ecall_o(is_ecall_id_ex),
            .is_mret_o(is_mret_id_ex),
            .pc_plus_IF_o(pc_plus_if_id),
            .stall_o(stall_id),
            .inst_valid_o(inst_valid_id_ex)
             );



    ysyx_210184_exe EX(
            .clk(clk),
            .rst(rst),
            .mode_ALU(mode_ALU_id_ex),
            .n_bytes_ALU(n_bytes_id_ex),
            .op1_alu(op1_id_ex),
            .op2_alu(op2_id_ex),
            .rd(rd_id_ex),
            .w_rd_ena(w_rd_ena_id_ex),
            .rs1(rs1_id_ex),
            .rs2(rs2_id_ex),
            .load_ena_i(load_ena_id_ex),
            .store_ena_i(store_ena_id_ex),
            .load_store_bytes_i(load_store_bytes_id_ex),
            .rs2_data_i(rs2_data_id_ex),
            .is_B_i(is_B_id_ex),
            .is_auipc_i(is_auipc_id_ex),
            .is_lui_i(is_lui_id_ex),
            .is_jal_i(is_jal_id_ex),
            .is_jalr_i(is_jalr_id_ex),
            .is_csr_i(is_csr_id_ex),
            .is_ecall_i(is_ecall_id_ex),
            .is_mret_i(is_mret_id_ex),
            .pc_plus_i(pc_plus_id_ex),
            .flush_i(flush_mem),
            .pc_ID_i(pc_ID_if_exe),
            .inst_valid_i(inst_valid_id_ex),

            .rd_mem_wb(rd_mem_wb),
            .wb_data_mem_wb(wb_data_wb_id),
            .wb_ena_mem_wb(w_rd_ena_mem_wb),
            .rd_ex_mem(rd_ex_mem),
            .wb_data_ex_mem(result_ALU_ex_mem),
            .wb_ena_ex_mem(w_rd_ena_ex_mem),
            .is_AL_OP_i(is_AL_OP_id_ex),
        //     .is_AL_OP_ex_mem(is_AL_OP_ex_mem),
        //     .is_AL_OP_mem(is_AL_OP_mem),
            .is_I_AL_OP(is_I_AL_OP_id_ex),
            .stall_i(stall_mem),
            .is_jal_o(is_jal_ex_mem),
            .is_jalr_o(is_jalr_ex_mem),
            // .is_U_o(is_U_ex_mem),
            .is_csr_o(is_csr_ex_csr),
            .is_ecall_o(is_ecall_ex_mem),
            .is_mret_o(is_mret_ex_mem),

            .load_ena_o(load_ena_ex_mem),
            .store_ena_o(store_ena_ex_mem),
            .load_store_bytes_o(load_store_bytes_ex_mem),
            .rd_o(rd_ex_mem),
            .w_rd_ena_o(w_rd_ena_ex_mem),
            .result_ALU(result_ALU_ex_mem),
            // .is_AL_OP_o(is_AL_OP_ex_mem),
            .stall_o(stall_exe), // load-use data hazard
            .rs2_data_o(rs2_data_ex_mem),
            .is_B_o(is_B_ex_mem),
            .pc_plus_o(pc_plus_ex_mem),
            .is_B_jump_o(is_B_jump_ex_mem),
            .inst_valid_o(inst_valid_ex_mem)
             );
    
    ysyx_210184_mem MEM(
            .clk(clk),
            .rst(rst),
            .result_ALU(result_ALU_ex_mem),
            .rd(rd_ex_mem),
            .w_rd_ena(w_rd_ena_ex_mem),
            .load_ena_i(load_ena_ex_mem),
        //     .store_ena_i(store_ena_ex_mem),
        //     .load_store_bytes_i(load_store_bytes_ex_mem),
        //     .dmem_r_data(dmem_r_data),
            // .is_AL_OP_i(is_AL_OP_ex_mem),
        //     .rs2_data_i(rs2_data_ex_mem),
            .is_B_i(is_B_ex_mem),
            // .is_U_i(is_U_ex_mem),
            .pc_plus_i(pc_plus_ex_mem),
            .is_B_jump_i(is_B_jump_ex_mem),
            .is_jal_i(is_jal_ex_mem),
            .is_jalr_i(is_jalr_ex_mem),
            .is_csr_i(is_csr_ex_csr),
            .is_ecall_i(is_ecall_ex_mem),
            .is_mret_i(is_mret_ex_mem),
            .r_csr_i(r_csr_data_csr_mem),
            .csr_mtvec_i(csr_mtvec_csr_mem),
            .csr_mepc_i(csr_mepc_csr_mem),
            .MIE(MIE),
            .inst_valid_i(inst_valid_ex_mem),
            .mtime_intr_enable_i(mtime_intr_enable),
            .ext_intr_enable_i(ext_intr_enable),
            .software_intr_enable_i(software_intr_enable),

            .MAC_ready(MAC_ready),
            .MAC_data(data_mac_mem),
            
            .rd_o(rd_mem_wb),
            .w_rd_ena_o(w_rd_ena_mem_wb),
        //     .w_rd_ena_harzied_o(w_rd_ena_harzied_mem_ex),
            .wb_data(wb_data_mem_wb),
            .result_ALU_o(result_ALU_mem_wb),
            .load_ena_o(load_ena_mem_wb),
            // .is_AL_OP_o(is_AL_OP_mem),
            .stall(stall_mem),
            // .r_addr_2_0(r_addr_2_0_mem_wb),
            // .load_store_bytes_o(load_store_bytes_mem_wb),
            .pc_plus_o(pc_plus_mem_if),
            .flush(flush_mem),
            .is_jal_o(is_jal_mem_wb),
            .is_jalr_o(is_jalr_mem_wb),
            .jalr_pc_o(jalr_pc_mem_if),
            // .is_U_o(is_U_mem_wb),
            .inst_valid_o(inst_valid_mem_csr)
             );

    ysyx_210184_wb WB(
            // .clk(clk),
            // .rst(rst), 
            .wb_data(wb_data_mem_wb),
            .result_ALU(result_ALU_mem_wb),
            .load_ena_i(load_ena_mem_wb),
            .rd(rd_mem_wb),
            .w_rd_ena(w_rd_ena_mem_wb),
        //     .r_addr_2_0(r_addr_2_0_mem_wb),
        //     .load_store_bytes_i(load_store_bytes_mem_wb),
            .pc_plus_4_i(pc_plus_4_wb_if),
            .is_jal_i(is_jal_mem_wb),
            .is_jalr_i(is_jalr_mem_wb),
        //     .is_U_i(is_U_mem_wb),
            
            .wb_data_o(wb_data_wb_id),
            .rd_o(rd_wb_id),
            .w_ena_o(w_rd_ena_wb_id)  );


    ysyx_210184_csr CSR(
            .clk(clk),
            .rst(rst),

            .is_ecall(is_ecall_ex_mem & (~stall_mem)),
            .is_mret(is_mret_ex_mem & (~stall_mem)),
            
            .w_addr(result_ALU_ex_mem[11:0]),
            .w_data(rs2_data_ex_mem),
            .w_ena(is_csr_ex_csr & (~stall_mem) & (~mtime_intr_enable) & (~ext_intr_enable) & (~software_intr_enable)),
            .w_mode(load_store_bytes_ex_mem[1:0]),
            
            .r_addr(result_ALU_ex_mem[11:0]),

            .MIE(MIE),
            .MTIE(MTIE),
            .MEIE(MEIE),
            .MSIE(MSIE),

            .r_data(r_csr_data_csr_mem),
            .csr_mtvec_o(csr_mtvec_csr_mem),
            .csr_mepc_o(csr_mepc_csr_mem),
            .pc_from_ex(pc_EX_if_csr),
            .pc_intr(pc_intr),

            .inst_valid(inst_valid_mem_csr),
            .mtime_intr_i(mtime_intr),
            .mtime_intr_enable_i(mtime_intr_enable & (~stall_mem)),
            .ext_intr_i(ext_intr),
            .ext_intr_enable_i(ext_intr_enable & (~stall_mem)),
            .software_intr_i(software_intr),
            .software_intr_enable_i(software_intr_enable & (~stall_mem))

            // .r_exception(),
            // .w_exception()
    );


    assign mtime_intr_enable = mtime_intr & MIE & MTIE;

    assign pc_intr = inst_valid_ex_mem & (~store_ena_ex_mem) & (~load_ena_ex_mem) ? pc_EX_if_csr :
                     inst_valid_id_ex  ? pc_ID_if_exe :
                     inst_valid_if_id  ? pc_IF_if_csr :
                                         pc;

    assign ext_intr_enable = ext_intr & MIE & MEIE;

    assign software_intr_enable = software_intr & MIE & MSIE;

    // always @(posedge clk) begin
    //     if(mtime_intr_enable & (~stall_mem)) $display("\nmtime intr...........................................");
        
    // end


endmodule
