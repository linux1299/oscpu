
`include "defines.v"
`include "ysyx_210184_regfile.v"
// `include "ysyx_210184_ff.v"

module ysyx_210184_id(
    input wire clk,
    input wire rst,
    input wire [`INS_BUS-1 : 0] inst_i,
    input wire                  regfile_w_ena,
    input wire [4:0]            regfile_w_addr,
    input wire [`REG_BUS-1 : 0] regfile_w_data,
    input wire                  stall_mem,
    input wire                  stall_exe,
    input wire                  flush_i,
    input wire                  is_B_id_ex,
    input wire                  inst_valid_i,
    
    output wire [`REG_BUS-1 : 0] op1,
    output wire [`REG_BUS-1 : 0] op2,
    output wire [         4 : 0] rd,
    output wire                  w_rd_ena,
    output wire                  load_ena,
    output wire                  store_ena,
    output wire [         2 : 0] load_store_bytes,
    output wire [         3 : 0] mode_ALU,
    output wire [         1 : 0] n_bytes_ALU, 
    output wire                  is_AL_OP,
    output wire                  is_I_AL_OP_o,
    output wire                  is_B_o,
    output wire                  is_jal_o,
    output wire                  is_jalr_o,
    output wire                  is_jal_IF_o,
    output wire                  is_auipc_o,
    output wire                  is_lui_o,
    output wire                  is_csr_o,
    output wire                  is_ecall_o,
    output wire                  is_mret_o,
    output wire                  inst_valid_o,

    output wire [`REG_BUS-1 : 0] pc_plus_IF_o,
    output wire [4  :   0] rs1,
    output wire [4  :   0] rs2,
    output wire [`REG_BUS-1 : 0] rs2_data_o,
    output wire [`REG_BUS-1 : 0] pc_plus,
    output wire                  stall_o
);

    // stall_in_id, flush_in_id
    wire stall_in_id, flush_in_id;
    //Instruction decode
    wire [6  :   2] opcode;
    wire [4  :   0] rs1_wire;
    wire [4  :   0] rs2_wire;
    wire [4  :   0] rd_wire;
    wire [6  :   0] func7;
    wire [2  :   0] func3;
    wire [`REG_BUS-1 : 0] imm;
    wire is_R, is_I, is_S, is_B, is_U, is_J;
    wire is_AL_OP_wire; //is arithmetic logic operation
    wire is_shift; //is atithmetic or ligical shift operation
    wire [  3:   0] mode_ALU_wire;
    wire w_rd_ena_wire;
    wire is_R_AL_OP;
    wire is_I_AL_OP;
    wire is_LOAD;
    wire is_STORE;
    wire is_jalr_wire;
    wire is_auipc;
    wire is_lui;
    wire is_csr;
    wire is_ecall;
    wire is_mret;
    //To ALU: op1 ; op2 ; mode_ALU
    wire [`REG_BUS-1 : 0] rs1_data, rs2_data;
    wire [`REG_BUS-1 : 0] op1_wire, op2_wire;
    wire is_I_reg;
    // n bytes of ALU
    wire [1 : 0] n_bytes_ALU_wire;
    // load store
    wire load_ena_wire;
    wire [2:0] load_store_bytes_wire;
    wire [`REG_BUS-1 : 0] rs2_data_o_wire;
    wire [`REG_BUS-1 : 0] pc_plus_wire;
    wire is_csr_reg;
    wire is_S_reg;
    wire is_U_reg;






    // assign stall_in_id = flush_i ? 1'b0 :
    //                     stall ? 1'b1 : 1'b0;
    assign stall_in_id = stall_mem ? 1'b1 :
                        flush_i ? 1'b0 :
                        stall_exe ? 1'b1: 1'b0;
    // assign flush_in_id = flush_i ? 1'b1 :
    //                     stall ? 1'b0 : 1'b0;
    assign flush_in_id = flush_i;
                        

    assign stall_o = is_B_id_ex & is_jal_IF_o;

    assign is_csr_o = is_csr_reg;


    assign w_rd_ena_wire = (opcode==5'b01100 || opcode==5'b01110 || opcode==5'b00100 || opcode==5'b00110 || opcode==5'b00000 || opcode==5'b11011 || opcode==5'b11001 || opcode==5'b00101 || opcode==5'b01101 || is_csr);
    assign is_R = (opcode==5'b01100 || opcode==5'b01110); //Only ALU
    assign is_I = ((opcode==5'b00100) || (opcode==5'b00110) || (opcode==5'b11100) || (opcode==5'b00011) || (opcode==5'b11001) || (opcode==5'b00000));
    assign is_S = (opcode==5'b01000);
    assign is_B = (opcode==5'b11000);
    assign is_U = (opcode==5'b00101 || opcode==5'b01101);
    assign is_J = (opcode==5'b11011);
    assign is_AL_OP_wire = is_R_AL_OP | is_I_AL_OP;
    assign is_shift = (func3==3'b001 || func3==3'b101);

    assign opcode = inst_i[6 : 2] & {3'b111, inst_i[1:0]};
    assign rs1_wire= is_U ? 5'b0 : inst_i[19:15];
    assign rs2_wire= is_U ? 5'b0 : inst_i[24:20];
    assign rd_wire= w_rd_ena_wire ? inst_i[11: 7] : 5'b0;
    // assign rd_wire= inst_i[11: 7];
    assign func3  = inst_i[14:12];
    assign func7  = inst_i[31:25];
    assign imm = ({`REG_BUS{(is_R | is_I)}} & {{(`REG_BUS-12){inst_i[`INS_BUS-1]}}, inst_i[31:20]}) |
                    ({`REG_BUS{is_S}} & {{(`REG_BUS-12){inst_i[`INS_BUS-1]}}, inst_i[31:25], inst_i[11:7]}) |
                    ({`REG_BUS{is_B}} & {{(`REG_BUS-13){inst_i[`INS_BUS-1]}}, inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0}) |
                    ({`REG_BUS{is_U}} & {{(`REG_BUS-32){inst_i[`INS_BUS-1]}}, inst_i[31:12], 12'b0}) |
                    ({`REG_BUS{is_J}} & {{(`REG_BUS-21){inst_i[`INS_BUS-1]}}, inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0});
    assign is_R_AL_OP = (opcode==5'b01100 || opcode==5'b01110);
    assign is_I_AL_OP = (opcode==5'b00100 || opcode==5'b00110);
    assign is_LOAD = (opcode==5'b00000);
    assign is_STORE = (opcode==5'b01000);
    assign is_jalr_wire = (opcode==5'b11001);
    assign is_auipc = opcode==5'b00101;
    assign is_lui = opcode==5'b01101;
    assign is_csr = (opcode==5'b11100) & (func3 != 3'b000);
    assign is_ecall = (opcode==5'b11100) & (func3==3'b000) & (func7==7'b0000000) & (rs2_wire==5'b00000);
    assign is_mret =  (opcode==5'b11100) & (func3==3'b000) & (func7==7'b0011000) & (rs2_wire==5'b00010);


    assign mode_ALU_wire = ( {4{is_R_AL_OP}} & {inst_i[30], func3} ) | 
                            ( {4{is_I_AL_OP}} & {inst_i[30]&is_shift, func3} ) |
                            ({4{is_LOAD | is_STORE | is_jalr_wire | is_csr}} & {4'b0000});



    assign op1_wire = rs1_data & {`REG_BUS{(~((stall_in_id & is_csr_reg) | (is_csr&(~stall_in_id))))}};
    assign op2_wire = (stall_in_id ? (is_I_reg | is_S_reg | is_U_reg) : (is_I | is_S | is_U)) ? imm : rs2_data;

    ysyx_210184_ff #(.WIDTH( 1)) ff_is_I_reg(.clk(clk), .rst(rst), .stall(stall_in_id), .d(is_I), .q(is_I_reg));
    ysyx_210184_ff #(.WIDTH( 1)) ff_is_S_reg(.clk(clk), .rst(rst), .stall(stall_in_id), .d(is_S), .q(is_S_reg));
    ysyx_210184_ff #(.WIDTH( 1)) ff_is_U_reg(.clk(clk), .rst(rst), .stall(stall_in_id), .d(is_U), .q(is_U_reg));
    ysyx_210184_ff #(.WIDTH( 1)) ff_is_csr_reg(.clk(clk), .rst(rst), .stall(stall_in_id), .d(is_csr & (~(flush_in_id))), .q(is_csr_reg));


    ysyx_210184_ff #(.WIDTH(64)) ff_op1(.clk(clk), .rst(rst), .stall(1'b0), .d(op1_wire), .q(op1));
    ysyx_210184_ff #(.WIDTH(64)) ff_op2(.clk(clk), .rst(rst), .stall(stall_in_id & (is_I_reg|is_S_reg|is_U_reg)), .d(op2_wire), .q(op2));
    ysyx_210184_ff #(.WIDTH( 4)) ff_mode_ALU(.clk(clk), .rst(rst), .stall(stall_in_id), .d(mode_ALU_wire), .q(mode_ALU));

    // rd rs1 rs2
    ysyx_210184_ff #(.WIDTH( 5)) ff_rd(.clk(clk), .rst(rst), .stall(stall_in_id), .d(rd_wire), .q(rd));
    ysyx_210184_ff #(.WIDTH( 1)) ff_w_rd_ena(.clk(clk), .rst(rst), .stall(stall_in_id), .d(w_rd_ena_wire & (~(flush_in_id)) & (~(inst_i[11:7]==5'b0)) & (~stall_o)), .q(w_rd_ena));
    ysyx_210184_ff #(.WIDTH( 5)) ff_rs1(.clk(clk), .rst(rst), .stall(stall_in_id), .d(rs1_wire), .q(rs1));
    ysyx_210184_ff #(.WIDTH( 5)) ff_rs2(.clk(clk), .rst(rst), .stall(stall_in_id), .d(rs2_wire), .q(rs2));

    assign n_bytes_ALU_wire = (opcode==5'b01100 || opcode==5'b00100) ? 2'b11 :
                                (opcode==5'b01110 || opcode==5'b00110) ? 2'b10 :
                                2'b11;

    ysyx_210184_ff #(.WIDTH( 2)) ff_n_bytes_ALU(.clk(clk), .rst(rst), .stall(stall_in_id), .d(n_bytes_ALU_wire), .q(n_bytes_ALU));


    assign load_ena_wire = is_LOAD;
    assign load_store_bytes_wire = func3;

    ysyx_210184_ff #(.WIDTH( 1)) ff_load_ena(.clk(clk), .rst(rst), .stall(stall_in_id), .d(load_ena_wire & (~(flush_in_id)) & (~(rd_wire==5'b0))), .q(load_ena));
    ysyx_210184_ff #(.WIDTH( 1)) ff_store_ena(.clk(clk), .rst(rst), .stall(stall_in_id), .d(is_STORE & (~(flush_in_id))), .q(store_ena));
    ysyx_210184_ff #(.WIDTH( 3)) ff_load_store_bytes(.clk(clk), .rst(rst), .stall(stall_in_id), .d(load_store_bytes_wire), .q(load_store_bytes));
    ysyx_210184_ff #(.WIDTH( 1)) ff_is_I_AL_OP(.clk(clk), .rst(rst), .stall(stall_in_id), .d(is_I_AL_OP), .q(is_I_AL_OP_o));
    ysyx_210184_ff #(.WIDTH( 1)) ff_is_AL_OP(.clk(clk), .rst(rst), .stall(stall_in_id), .d(is_AL_OP_wire), .q(is_AL_OP));
    ysyx_210184_ff #(.WIDTH( 1)) ff_is_auipc(.clk(clk), .rst(rst), .stall(stall_in_id), .d(is_auipc), .q(is_auipc_o));
    ysyx_210184_ff #(.WIDTH( 1)) ff_is_lui(.clk(clk), .rst(rst), .stall(stall_in_id), .d(is_lui), .q(is_lui_o));
    ysyx_210184_ff #(.WIDTH( 1)) ff_is_ecall(.clk(clk), .rst(rst), .stall(stall_in_id), .d(is_ecall & (~(flush_in_id))), .q(is_ecall_o));
    ysyx_210184_ff #(.WIDTH( 1)) ff_is_mret(.clk(clk), .rst(rst), .stall(stall_in_id), .d(is_mret & (~(flush_in_id))), .q(is_mret_o));


    assign rs2_data_o_wire = (is_csr_reg & load_store_bytes[2] & stall_in_id) ? rs2_data_o :
                            (is_csr_reg & (~load_store_bytes[2]) & stall_in_id) ? rs1_data ://rs2_data_o :
                            is_csr & (~stall_in_id) ? (func3[2] ? {59'b0, rs1_wire} : rs1_data) :
                            rs2_data;
    // assign rs2_data_o_wire = (is_csr | (is_csr_reg & stall_in_id)) ? (() ? rs1 : rs1_data) : rs2_data;
    ysyx_210184_ff #(.WIDTH(64)) ff_rs2_data(.clk(clk), .rst(rst), .stall(1'b0), .d(rs2_data_o_wire), .q(rs2_data_o));


    assign pc_plus_wire = is_B ? imm : `REG_BUS'b0;
    ysyx_210184_ff #(.WIDTH(`REG_BUS)) ff_pc_plus(.clk(clk), .rst(rst), .stall(stall_in_id), .d(pc_plus_wire), .q(pc_plus));
    ysyx_210184_ff #(.WIDTH( 1)) ff_is_B(.clk(clk), .rst(rst), .stall(stall_in_id), .d(is_B & (~flush_in_id)), .q(is_B_o));

    // jal
    assign is_jal_IF_o = is_J;
    ysyx_210184_ff #(.WIDTH( 1)) ff_is_J(.clk(clk), .rst(rst), .stall(stall_in_id), .d(is_J & (~flush_in_id)), .q(is_jal_o));
    assign pc_plus_IF_o = imm;

    //jalr
    ysyx_210184_ff #(.WIDTH( 1)) ff_is_jalr(.clk(clk), .rst(rst), .stall(stall_in_id), .d(is_jalr_wire & (~flush_in_id)), .q(is_jalr_o));


    ysyx_210184_ff #(.WIDTH( 1)) ff_inst_valid(.clk(clk), .rst(rst), .stall(stall_in_id), .d(inst_valid_i & (~flush_in_id) & (~stall_o)), .q(inst_valid_o));




    //Register file
    ysyx_210184_regfile RegFile(
        .clk(clk),
        .rst(rst),
        .w_addr(regfile_w_addr),
        .w_data(regfile_w_data),
        .w_ena(regfile_w_ena),
        .r_addr1(stall_in_id ? rs1 : rs1_wire),
        .r_data1(rs1_data),
        .r_addr2(stall_in_id ? rs2 : rs2_wire),
        .r_data2(rs2_data)
        );
endmodule
