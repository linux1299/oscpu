
`include "defines.v"

module SimTop(
    input         clock,
    input         reset,

    input  [63:0] io_logCtrl_log_begin,
    input  [63:0] io_logCtrl_log_end,
    input  [63:0] io_logCtrl_log_level,
    input         io_perfInfo_clean,
    input         io_perfInfo_dump,

    output        io_uart_out_valid,
    output [7:0]  io_uart_out_ch,
    output        io_uart_in_valid,
    input  [7:0]  io_uart_in_ch
);

wire ram_rw_cen_o  ;
wire ram_rw_wen_o  ;
wire [63:0] ram_rw_addr_o ;
wire [63:0] ram_rw_wdata_o;
wire [2:0]  ram_rw_size_o ;
wire [7:0]  ram_rw_wmask_o;





// ------------- cpu core -----------------
rvcpu u_rvcpu(
    .clk            ( clock            ),
    .rst_n          ( ~reset           ),
    .ram_rw_cen_o   ( ram_rw_cen_o   ),
    .ram_rw_wen_o   ( ram_rw_wen_o   ),
    .ram_rw_addr_o  ( ram_rw_addr_o  ),
    .ram_rw_wdata_o ( ram_rw_wdata_o ),
    .ram_rw_wmask_o ( ram_rw_wmask_o ),
    .ram_rw_size_o  ( ram_rw_size_o  ),
    .ram_rw_ready_i ( ram_rw_ready_i ),
    .ram_rw_data_i  ( ram_rw_data_i  )
);

// ----------------- ram ------------------
wire [63:0] ram_wmask ={{8{ram_rw_wmask_o[7]}}, 
                        {8{ram_rw_wmask_o[6]}}, 
                        {8{ram_rw_wmask_o[5]}}, 
                        {8{ram_rw_wmask_o[4]}}, 
                        {8{ram_rw_wmask_o[3]}}, 
                        {8{ram_rw_wmask_o[2]}}, 
                        {8{ram_rw_wmask_o[1]}}, 
                        {8{ram_rw_wmask_o[0]}}};
reg  [63:0] ram_data_o;

wire [63:0] ram_addr_tmp = (ram_rw_addr_o-`PC_START)>>3;
wire [15:0] ram_addr = ram_addr_tmp[15:0];
RAMHelper RAMHelper(
    .clk   ( clock   ),
    .en    ( ram_rw_cen_o    ),
    .rIdx  ( ram_addr ),
    .rdata ( ram_data_o ),
    .wIdx  ( ram_addr ),
    .wdata ( ram_rw_wdata_o ),
    .wmask ( ram_wmask ),
    .wen   ( ram_rw_wen_o   )
);

reg  [63:0] ram_rw_data_i;
reg         ram_rw_ready_i;
always @(posedge clock) begin

    if (ram_rw_cen_o) begin
        ram_rw_ready_i <= 1'b1;
    end
    else begin
        ram_rw_ready_i <= 1'b0;
    end
    
    if (ram_rw_cen_o && ~ram_rw_wen_o) begin
        ram_rw_data_i <= ram_data_o;
    end
end


// ------------ Difftest ----------------
reg cmt_wen;
reg [7:0]  cmt_wdest;
reg [63:0] cmt_wdata;
reg [63:0] cmt_pc;
reg [31:0] cmt_inst;
reg cmt_valid;
reg trap;
reg [7:0] trap_code;
reg [63:0] cycleCnt;
reg [63:0] instrCnt;
reg [63:0] regs_diff [0:31];

reg [63:0] ls_wb_pc;
reg [31:0] ls_wb_inst;
reg ls_wb_ready;
wire[63:0] regs_o [0:31];

genvar j;
generate
	for (j = 0; j < 32; j = j + 1) begin
		assign regs_o[j] = (u_rvcpu.wbu_rd_wen_o && u_rvcpu.wbu_rd_addr_o ==j && j!=0) ? 
                            u_rvcpu.wbu_rd_wdata_o : u_rvcpu.u_reg_file.regs[j];
	end
endgenerate

reg branch_ebreak_ecall_mret;
reg mret;
reg mret_r0;
always @(posedge clock) begin
    if (reset) begin
        branch_ebreak_ecall_mret <= 1'b0;
        mret <= 1'b0;
        mret_r0 <= 1'b0;
    end
    else begin
        branch_ebreak_ecall_mret <= u_rvcpu.u_idu.instr_type_b 
                                  | u_rvcpu.u_idu.instr_ebreak 
                                  | u_rvcpu.u_idu.instr_ecall  
                                  | u_rvcpu.u_idu.instr_mret
                                  ;
        mret <=  u_rvcpu.u_idu.instr_mret;
        mret_r0 <= mret;
    end
end

always @(posedge clock) begin
    if (u_rvcpu.ram_lsu_valid_o)
        ls_wb_ready <= 1;
    else if (branch_ebreak_ecall_mret)
        ls_wb_ready <= 1;
    else
        ls_wb_ready <= 0;
end

always @(posedge clock) begin
    if (reset) begin
        ls_wb_pc <= 0;
    end
    else if (u_rvcpu.ifu_instr_valid_o) begin
        ls_wb_pc <= u_rvcpu.ifu_pc_o;
    end
end

always @(posedge clock) begin
    if (reset) begin
        ls_wb_inst <= 0;
    end
    else if (u_rvcpu.ifu_instr_valid_o) begin
        ls_wb_inst <= u_rvcpu.ifu_instr_o;
    end
end

always @(posedge clock) begin
  if (reset) begin
    {cmt_wen, 
    cmt_wdest, 
    cmt_wdata, 
    cmt_pc, 
    cmt_inst, 
    cmt_valid, 
    trap, 
    trap_code, 
    cycleCnt, 
    instrCnt} <= 0;
  end
  else if (~trap) begin
    cmt_wen   <= u_rvcpu.wbu_rd_wen_o;
    cmt_wdest <= {3'd0, u_rvcpu.wbu_rd_addr_o};
    cmt_wdata <= u_rvcpu.wbu_rd_wdata_o;
    cmt_pc    <= ls_wb_pc;
    cmt_inst  <= ls_wb_inst;
    cmt_valid <= u_rvcpu.wbu_rd_wen_o | ls_wb_ready;
    regs_diff <= regs_o;
    trap      <= ls_wb_inst[6:0] == 7'h6b;
    trap_code <= u_rvcpu.u_reg_file.regs[10][7:0];
    cycleCnt  <= cycleCnt + 1;
    instrCnt  <= instrCnt + (u_rvcpu.wbu_rd_wen_o | ls_wb_ready);
  end
end

reg skip;
always @(posedge clock) begin
  if (reset)
    skip <= 0;
  else if (ls_wb_inst==32'h7b)
    skip <= 1;
  else if (mret_r0)
    skip <= 1;
  else
    skip <= 0; 
end

DifftestInstrCommit DifftestInstrCommit(
  .clock              (clock),
  .coreid             (0),
  .index              (0),
  .valid              (cmt_valid),
  .pc                 (cmt_pc),
  .instr              (cmt_inst),
  .skip               (skip),
  .isRVC              (0),
  .scFailed           (0),
  .wen                (cmt_wen),
  .wdest              (cmt_wdest),
  .wdata              (cmt_wdata)
);

DifftestArchIntRegState DifftestArchIntRegState (
  .clock              (clock),
  .coreid             (0),
  .gpr_0              (regs_diff[0]),
  .gpr_1              (regs_diff[1]),
  .gpr_2              (regs_diff[2]),
  .gpr_3              (regs_diff[3]),
  .gpr_4              (regs_diff[4]),
  .gpr_5              (regs_diff[5]),
  .gpr_6              (regs_diff[6]),
  .gpr_7              (regs_diff[7]),
  .gpr_8              (regs_diff[8]),
  .gpr_9              (regs_diff[9]),
  .gpr_10             (regs_diff[10]),
  .gpr_11             (regs_diff[11]),
  .gpr_12             (regs_diff[12]),
  .gpr_13             (regs_diff[13]),
  .gpr_14             (regs_diff[14]),
  .gpr_15             (regs_diff[15]),
  .gpr_16             (regs_diff[16]),
  .gpr_17             (regs_diff[17]),
  .gpr_18             (regs_diff[18]),
  .gpr_19             (regs_diff[19]),
  .gpr_20             (regs_diff[20]),
  .gpr_21             (regs_diff[21]),
  .gpr_22             (regs_diff[22]),
  .gpr_23             (regs_diff[23]),
  .gpr_24             (regs_diff[24]),
  .gpr_25             (regs_diff[25]),
  .gpr_26             (regs_diff[26]),
  .gpr_27             (regs_diff[27]),
  .gpr_28             (regs_diff[28]),
  .gpr_29             (regs_diff[29]),
  .gpr_30             (regs_diff[30]),
  .gpr_31             (regs_diff[31])
);

DifftestTrapEvent DifftestTrapEvent(
  .clock              (clock),
  .coreid             (0),
  .valid              (trap),
  .code               (trap_code),
  .pc                 (cmt_pc),
  .cycleCnt           (cycleCnt),
  .instrCnt           (instrCnt)
);

DifftestCSRState DifftestCSRState(
  .clock              (clock),
  .coreid             (0),
  .priviledgeMode     (`RISCV_PRIV_MODE_M),
  .mstatus            (u_rvcpu.u_csr_file.mstatus),
  .sstatus            (0),
  .mepc               (u_rvcpu.u_csr_file.mepc),
  .sepc               (0),
  .mtval              (0),
  .stval              (0),
  .mtvec              (u_rvcpu.u_csr_file.mtvec),
  .stvec              (0),
  .mcause             (u_rvcpu.u_csr_file.mcause),
  .scause             (0),
  .satp               (0),
  .mip                (u_rvcpu.u_csr_file.mip),
  .mie                (u_rvcpu.u_csr_file.mie),
  .mscratch           (0),
  .sscratch           (0),
  .mideleg            (0),
  .medeleg            (0)
);

DifftestArchFpRegState DifftestArchFpRegState(
  .clock              (clock),
  .coreid             (0),
  .fpr_0              (0),
  .fpr_1              (0),
  .fpr_2              (0),
  .fpr_3              (0),
  .fpr_4              (0),
  .fpr_5              (0),
  .fpr_6              (0),
  .fpr_7              (0),
  .fpr_8              (0),
  .fpr_9              (0),
  .fpr_10             (0),
  .fpr_11             (0),
  .fpr_12             (0),
  .fpr_13             (0),
  .fpr_14             (0),
  .fpr_15             (0),
  .fpr_16             (0),
  .fpr_17             (0),
  .fpr_18             (0),
  .fpr_19             (0),
  .fpr_20             (0),
  .fpr_21             (0),
  .fpr_22             (0),
  .fpr_23             (0),
  .fpr_24             (0),
  .fpr_25             (0),
  .fpr_26             (0),
  .fpr_27             (0),
  .fpr_28             (0),
  .fpr_29             (0),
  .fpr_30             (0),
  .fpr_31             (0)
);

endmodule