
`include "defines.v"
// `include "ysyx_210184_ff.v"

module ysyx_210184_if(
	input wire             clk,
	input wire             rst,
    input wire [`INS_BUS-1 : 0]  inst_i,
    // input wire                   stall,
    input wire                  flush_i,
    input wire                  is_B_jump_i,
    input wire [`REG_BUS-1 : 0] pc_plus_i,
    input wire [`REG_BUS-1 : 0] pc_plus_ID_i,
    input wire                  is_jal_i,
    input wire                  stall_exe,
    input wire                  stall_mem,
    input wire                  stall_id,
    input wire                  is_jalr_mem_i,
    input wire                  is_ecall_mem_i,
    input wire                  is_mret_mem_i,
    input wire [`REG_BUS-1 : 0] jalr_pc_i,
    input wire                  MAC_ready,
    input wire                  mtime_intr_enable_i,

	output wire [`REG_BUS-1 : 0]  inst_addr,
    output wire  [`INS_BUS-1 : 0] inst_o,
    // output wire                   inst_ena,
	output wire [`REG_BUS-1 : 0]  pc_MEM_o,
	output wire [`REG_BUS-1 : 0]  pc_ID_o,
	output wire [`REG_BUS-1 : 0]  pc_EX_o,
    output wire [`REG_BUS-1 : 0]  pc_IF_o,
    output wire [`REG_BUS-1 : 0]  pc_o,
    output wire                   inst_valid_o
);

    wire flush_in_if, stall_in_if;
    reg [`REG_BUS-1 : 0] pc;
    wire [`REG_BUS-1 : 0] pc_1, pc_2;
    reg [`REG_BUS-1 : 0] pc_IF, pc_ID, pc_EX, pc_MEM;
    wire [`REG_BUS-1 : 0] to_pc_MEM;
    reg [`INS_BUS-1 : 0] inst_o_reg;
    wire inst_valid_wire;



    // assign flush_in_if = flush_i ? 1'b1 :
    //                         stall ? 1'b0:
    //                         is_jal_i ? 1'b1 : 1'b0;
    assign flush_in_if = stall_mem ? 1'b0 :
                            flush_i ? 1'b1 :
                            stall_exe ? 1'b0 :
                            stall_id  ? 1'b0 :
                            is_jal_i ? 1'b1 : 1'b0;
    // assign flush_in_if = flush_i | is_jal_i;
    // assign stall_in_if = flush_i ? 1'b0 : 
    //                         stall ? 1'b1 :
    //                         is_jal_i ? 1'b0 : 1'b0;
    assign stall_in_if = stall_mem ? 1'b1 :
                            flush_i ? 1'b0 : 
                            stall_exe ? 1'b1 :
                            stall_id  ? 1'b1 :
                            is_jal_i ? 1'b0 : 1'b0;
    // assign stall_in_if = stall;



    // PC
    assign pc_1 = mtime_intr_enable_i ? (jalr_pc_i & (~64'b1)) :
                    is_B_jump_i ? pc_EX : 
                    (is_jalr_mem_i | is_ecall_mem_i | is_mret_mem_i)  ? {jalr_pc_i[63:1], 1'b0} : 
                    pc_IF;
    assign pc_2 = mtime_intr_enable_i ? 64'b0 :
                    is_B_jump_i ? pc_plus_i : 
                    (is_jalr_mem_i | is_ecall_mem_i | is_mret_mem_i ) ? 64'b0 : 
                    pc_plus_ID_i;
    always@( posedge clk ) begin
        if( rst )
        begin
            pc <= `PC_RST_VAL;
        end
        else
        begin
            if(stall_in_if) pc <= pc;
            else if (flush_in_if) pc <= pc_1 + pc_2;
            else pc <= pc + 64'd4;
        end
    end

    always @ (posedge clk) begin
        if(rst)begin
            pc_IF <= `REG_BUS'b0;
            pc_ID <= `REG_BUS'b0;
            pc_EX <= `REG_BUS'b0;
            pc_MEM <= `REG_BUS'b0;
        end
        else begin
            if(stall_mem) begin
                pc_IF <= pc_IF;
                pc_ID <= pc_ID;
                pc_EX <= pc_EX;
                pc_MEM <= `REG_BUS'b0;
            end
            else if(stall_exe) begin
                pc_IF <= pc_IF;
                pc_ID <= pc_ID;
                pc_EX <= `REG_BUS'b0;
                pc_MEM <= to_pc_MEM;
            end
            else if(stall_id) begin
                pc_IF <= pc_IF;
                pc_ID <= `REG_BUS'b0;
                pc_EX <= pc_ID;
                pc_MEM <= to_pc_MEM;
            end
            else begin
                pc_IF <= pc;
                pc_ID <= pc_IF;
                pc_EX <= pc_ID;
                pc_MEM <= to_pc_MEM;
            end
        end
    end

    assign to_pc_MEM = pc_EX + 64'd4;

    assign pc_MEM_o = pc_MEM;
    assign pc_ID_o = pc_ID;
    assign pc_EX_o = pc_EX;
    assign pc_IF_o = pc_IF;
    assign pc_o = pc;


    assign inst_addr = pc;
    // assign inst_ena = stall_in_if ? 1'b0 : 1'b1;

    //IF-ID registers
    always @ (posedge clk) begin
        if(rst) inst_o_reg <= `NOP;
        else begin
            if(stall_in_if) inst_o_reg <= inst_o;
            else if(flush_in_if | (~MAC_ready)) inst_o_reg <= 32'b10011;
            else inst_o_reg <= inst_i;
        end
    end
    assign inst_o = inst_o_reg;

    
    assign inst_valid_wire = (flush_in_if | (~MAC_ready)) ? 1'b0 : 1'b1;
    ysyx_210184_ff #(.WIDTH( 1)) ff_inst_valid(.clk(clk), .rst(rst), .stall(stall_in_if), .d(inst_valid_wire), .q(inst_valid_o));

endmodule
