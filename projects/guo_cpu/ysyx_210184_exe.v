
`include "defines.v"
// `include "ysyx_210184_ff.v"

module ysyx_210184_exe(
    input wire clk,
    input wire rst,
    input wire [         3 : 0] mode_ALU,
    input wire [         1 : 0] n_bytes_ALU,
    input wire [`REG_BUS-1 : 0] op1_alu,
    input wire [`REG_BUS-1 : 0] op2_alu,
    input wire [         4 : 0] rd,
    input wire                  w_rd_ena,
    input wire [         4 : 0] rs1,
    input wire [         4 : 0] rs2,
    input wire                  load_ena_i,
    input wire                  store_ena_i,
    input wire [         2 : 0] load_store_bytes_i,
    input wire [`REG_BUS-1 : 0] rs2_data_i,
    input wire                  is_jal_i,
    input wire                  is_auipc_i,
    input wire                  is_lui_i,
    input wire                  is_csr_i,
    input wire [`REG_BUS-1 : 0] pc_ID_i,
    input wire                  inst_valid_i,
    // Data hazard
    input wire [         4 : 0] rd_mem_wb,
    input wire [`REG_BUS-1 : 0] wb_data_mem_wb,
    input wire                  wb_ena_mem_wb,
    input wire [         4 : 0] rd_ex_mem,
    input wire [`REG_BUS-1 : 0] wb_data_ex_mem,
    input wire                  wb_ena_ex_mem,
    input wire                  is_AL_OP_i,
    // input wire                  is_AL_OP_ex_mem,
    // input wire                  is_AL_OP_mem,
    input wire                  is_I_AL_OP,
    input wire                  stall_i,
    input wire                  flush_i,
    input wire [`REG_BUS-1 : 0] pc_plus_i,
    input wire                  is_B_i,
    input wire                  is_jalr_i,
    input wire                  is_ecall_i,
    input wire                  is_mret_i,


    
    output wire                  load_ena_o,
    output wire                  store_ena_o,
    output wire [         2 : 0] load_store_bytes_o,
    output wire [         4 : 0] rd_o,
    output wire                  w_rd_ena_o,
    output wire [`REG_BUS-1 : 0] result_ALU,
    // output wire                  is_AL_OP_o,
    output wire                  stall_o,
    output wire [`REG_BUS-1 : 0] rs2_data_o,
    output wire                  is_B_o,
    output wire                  is_B_jump_o,
    output wire [`REG_BUS-1 : 0] pc_plus_o,
    output wire                  is_jal_o,
    output wire                  is_jalr_o,
    // output wire                  is_U_o,
    output wire                  is_csr_o,
    output wire                  is_ecall_o,
    output wire                  is_mret_o,
    output wire                  inst_valid_o

    
);

    //port define
    wire [`REG_BUS-1 : 0] op1;
    wire [`REG_BUS-1 : 0] op2;
    // wire [`REG_BUS-1 : 0] result_AL_OP;
    wire [`REG_BUS-1 : 0] r_add_sub;
    wire [`REG_BUS-1 : 0] r_and;
    wire [`REG_BUS-1 : 0] r_or;
    wire [`REG_BUS-1 : 0] r_xor;
    wire [`REG_BUS-1 : 0] r_slt;
    wire is_equal, is_less_than, r_slt_lsb;
    wire s, s1, s2, c1, c2;
    wire is_byte;
    wire expend_shift; 
    wire is_sll;
    wire [`REG_BUS-1 : 0] shift_op1;
    wire [5:0] shift_op2;
    reg [`REG_BUS-1 : 0] shift_op1_reverse;
    wire [`REG_BUS-1 : 0] shift_op1_in;
    wire [`REG_BUS-1 : 0] shift_result;
    reg [`REG_BUS-1 : 0] shift_result_reverse;
    wire [`REG_BUS-1 : 0] shift_out;
    wire signed [`REG_BUS-1 : 0] sign_original;
    wire signed [`REG_BUS-1 : 0] sign_out;
    wire [`REG_BUS-1 : 0] sub_result;
    wire [`REG_BUS-1 : 0] r_shift;
    wire is_load_use;
    reg [`REG_BUS-1 : 0] result_ALU_wire;
    wire [`REG_BUS-1 : 0] result_ALU_wire_1;
    wire [`REG_BUS-1 : 0] rs2_data_hazard;
    reg is_B_jump_wire;

    //port define end




    // assign op1 = ((rs1 == rd_ex_mem)&wb_ena_ex_mem) ? wb_data_ex_mem :
    //                 ((rs1 == rd_mem_wb)&wb_ena_mem_wb) ? wb_data_mem_wb : 
    //                 is_auipc_i ? pc_ID_i : is_lui_i ? 64'b0 : op1_alu;
    assign op1 = (is_lui_i | is_csr_i) ? 64'b0 :
                    is_auipc_i ? pc_ID_i :
                    ((rs1 == rd_ex_mem)&wb_ena_ex_mem) ? wb_data_ex_mem :
                    ((rs1 == rd_mem_wb)&wb_ena_mem_wb) ? wb_data_mem_wb : 
                    op1_alu;
    assign op2 = (is_I_AL_OP | load_ena_i | store_ena_i | is_csr_i) ? op2_alu :
                    ((rs2 == rd_ex_mem)&wb_ena_ex_mem) ? wb_data_ex_mem :
                    ((rs2 == rd_mem_wb)&wb_ena_mem_wb) ? wb_data_mem_wb : 
                    op2_alu;
    

    // Addition and subtraction
    assign r_add_sub = op1 + (op2^{`REG_BUS{mode_ALU[3]}}) + {63'b0, mode_ALU[3]};

    // AND
    assign r_and = op1 & op2;

    // OR
    assign r_or = op1 | op2;

    // XOR
    assign r_xor = op1 ^ op2;

    // set less than : signed and unsigned
    assign is_equal = (op1[`REG_BUS-2:0] == op2[`REG_BUS-2:0]);
    assign is_less_than = (op1[`REG_BUS-2:0] < op2[`REG_BUS-2:0]);
    assign s = mode_ALU[0];
    assign s1 = op1[`REG_BUS-1];
    assign s2 = op2[`REG_BUS-1];
    assign c1 = is_less_than;
    assign c2 = is_equal;
    // assign r_slt_lsb = ((~s)&s1&(~s2)) | (s&(~s1)&s2) | (c1&(s|((~s1)&(~s2)))) | (((~s)&s1)&((~c1)&(~c2)));
    assign r_slt_lsb = s ? (({s1, s2}==2'b01) | ((s1==s2)&c1)) : (({s1, s2}==2'b10) | ((s1==s2)&c1));
    assign r_slt = {{(`REG_BUS-1){1'b0}}, r_slt_lsb};

    // Shift
    assign is_sll = (mode_ALU[2:0] == 001);
    assign is_byte = (n_bytes_ALU == 2'b10);
    assign expend_shift = op1[31] & mode_ALU[3];

    assign shift_op1 = is_byte ? {{32{expend_shift}}, op1[31:0]} : op1;

    assign shift_op2 = {op2[5]&(~is_byte), op2[4:0]};

    integer i;
    always@(*)
    for(i=0; i<`REG_BUS; i=i+1) begin
        shift_op1_reverse[i] = shift_op1[63-i];
    end


    assign shift_op1_in = is_sll ? shift_op1 : shift_op1_reverse;

    assign shift_result = (shift_op1_in << shift_op2);
    
    always@(*)
    for(i=0; i<64; i=i+1) begin
        shift_result_reverse[i] = shift_result[63-i];
    end

    assign shift_out = is_sll ? shift_result : shift_result_reverse;

    assign sign_original = {mode_ALU[3] & (n_bytes_ALU==2'b11) & op1[63], 63'b0};

    assign sign_out = (sign_original >>> shift_op2);

    assign sub_result = shift_out | sign_out;

    assign r_shift = (n_bytes_ALU==2'b11) ? sub_result : {{32{sub_result[31]}}, sub_result[31:0]};


    // is load-use
    assign is_load_use = (load_ena_o | is_csr_o) & (rs1 == rd_ex_mem || rs2 == rd_ex_mem) & (is_AL_OP_i | load_ena_i | store_ena_i | is_B_i | is_jalr_i | is_lui_i | is_csr_i);
    // ff #(.WIDTH( 4)) ff_stall(.clk(clk), .rst(rst), .stall(1'b0), .d({{2{is_load_use}}, 2'b00}), .q(stall_o));
    assign stall_o = is_load_use;


    //Output
    always @(*) case(mode_ALU[2:0])
        3'b000        : result_ALU_wire = r_add_sub;
        3'b001, 3'b101: result_ALU_wire = r_shift;
        3'b010, 3'b011: result_ALU_wire = r_slt;
        3'b100        : result_ALU_wire = r_xor;
        3'b110        : result_ALU_wire = r_or;
        3'b111        : result_ALU_wire = r_and;
    endcase

    assign result_ALU_wire_1 = is_byte ? {{32{result_ALU_wire[31]}}, result_ALU_wire[31:0]} : result_ALU_wire;

    ysyx_210184_ff #(.WIDTH(64)) ff_ALU(.clk(clk), .rst(rst), .stall(stall_i), .d(result_ALU_wire_1), .q(result_ALU));
    ysyx_210184_ff #(.WIDTH( 5)) ff_rd(.clk(clk), .rst(rst), .stall(stall_i), .d(rd), .q(rd_o));
    ysyx_210184_ff #(.WIDTH( 1)) ff_w_rd_ena(.clk(clk), .rst(rst), .stall(stall_i), .d(w_rd_ena & (~is_load_use) & (~flush_i)), .q(w_rd_ena_o));
    ysyx_210184_ff #(.WIDTH( 1)) ff_load_ena(.clk(clk), .rst(rst), .stall(stall_i), .d(load_ena_i & (~is_load_use) & (~flush_i)), .q(load_ena_o));
    ysyx_210184_ff #(.WIDTH( 1)) ff_store_ena(.clk(clk), .rst(rst), .stall(stall_i), .d(store_ena_i & (~is_load_use) & (~flush_i)), .q(store_ena_o));
    ysyx_210184_ff #(.WIDTH( 3)) ff_load_store_bytes(.clk(clk), .stall(stall_i), .rst(rst), .d(load_store_bytes_i), .q(load_store_bytes_o));
    // ysyx_210184_ff #(.WIDTH( 1)) ff_is_AL_OP(.clk(clk), .rst(rst), .stall(stall_i), .d(is_AL_OP_i), .q(is_AL_OP_o));
    ysyx_210184_ff #(.WIDTH( 1)) ff_is_jal(.clk(clk), .rst(rst), .stall(stall_i), .d(is_jal_i & (~flush_i)), .q(is_jal_o));
    ysyx_210184_ff #(.WIDTH( 1)) ff_is_jalr(.clk(clk), .rst(rst), .stall(stall_i), .d(is_jalr_i & (~is_load_use) & (~flush_i)), .q(is_jalr_o));
    ysyx_210184_ff #(.WIDTH( 1)) ff_is_ecall(.clk(clk), .rst(rst), .stall(stall_i), .d(is_ecall_i & (~flush_i)), .q(is_ecall_o));
    ysyx_210184_ff #(.WIDTH( 1)) ff_is_mret(.clk(clk), .rst(rst), .stall(stall_i), .d(is_mret_i & (~(flush_i))), .q(is_mret_o));

    assign rs2_data_hazard = (is_csr_i) ? (
                                (load_store_bytes_i[2]) ? rs2_data_i :
                                ((rs1 == rd_ex_mem)&wb_ena_ex_mem) ? wb_data_ex_mem :
                                ((rs1 == rd_mem_wb)&wb_ena_mem_wb) ? wb_data_mem_wb : 
                                rs2_data_i
                            ) :
                            (
                                ((rs2 == rd_ex_mem)&wb_ena_ex_mem) ? wb_data_ex_mem :
                                ((rs2 == rd_mem_wb)&wb_ena_mem_wb) ? wb_data_mem_wb : 
                                rs2_data_i
                            );
    ysyx_210184_ff #(.WIDTH(64)) ff_rs2_data_o(.clk(clk), .rst(rst), .stall(stall_i), .d(rs2_data_hazard), .q(rs2_data_o));


    // is_B
    ysyx_210184_ff #(.WIDTH( 1)) ff_is_B_o(.clk(clk), .rst(rst), .stall(stall_i), .d(is_B_i & (~flush_i) & (~is_load_use)), .q(is_B_o));
    ysyx_210184_ff #(.WIDTH(64)) ff_pc_plus_o(.clk(clk), .rst(rst), .stall(stall_i), .d(pc_plus_i), .q(pc_plus_o));

    // ysyx_210184_ff #(.WIDTH( 1)) ff_is_U(.clk(clk), .rst(rst), .stall(stall_i), .d(is_auipc_i | is_lui_i), .q(is_U_o));

    ysyx_210184_ff #(.WIDTH( 1)) ff_is_csr(.clk(clk), .rst(rst), .stall(stall_i), .d(is_csr_i & (~flush_i) & (~is_load_use)), .q(is_csr_o));



    ysyx_210184_ff #(.WIDTH( 1)) ff_inst_valid(.clk(clk), .rst(rst), .stall(stall_i), .d(inst_valid_i & (~flush_i) & (~stall_o)), .q(inst_valid_o));



    always @ (*) case (load_store_bytes_i)
        3'b000 : is_B_jump_wire = (s1==s2) & c2;
        // 3'b101 : is_B_jump_wire = ((s1==s2)&c2) | (s1==1'b0 & s2==1'b1) | (({s1, s2}==2'b00)&({c1, c2}==2'b00)) | (({s1, s2}==2'b11)&c1); 
        3'b101 : is_B_jump_wire = ((s1==s2)&c2) | (s1==1'b0 & s2==1'b1) | ((s1==s2)&({c1, c2}==2'b00)); 
        3'b111 : is_B_jump_wire = ((s1==s2)&c2) | (s1==1'b1 & s2==1'b0) | (s1==s2 & {c1, c2}==2'b00); 
        // 3'b100 : is_B_jump_wire = (s1==1'b1 & s2==1'b0) | (({s1, s2}==2'b00)&c1) | (({s1, s2}==2'b11)&({c1, c2}==2'b00)); 
        3'b100 : is_B_jump_wire = (s1==1'b1 & s2==1'b0) | ((s1==s2)&c1); 
        3'b110 : is_B_jump_wire = ((s1==s2)&c1) | ({s1, s2}==2'b01); 
        3'b001 : is_B_jump_wire = ~((s1==s2)&c2);
        default: is_B_jump_wire = 1'b0;
    endcase

    ysyx_210184_ff #(.WIDTH( 1)) ff_is_B_jump(.clk(clk), .rst(rst), .stall(stall_i), .d(is_B_jump_wire), .q(is_B_jump_o));

    
endmodule
