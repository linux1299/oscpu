
`timescale 1ns / 1ps
// PC
`define PC_START        64'h8000_0000

// priv mode
`define RISCV_PRIV_MODE_U   0
`define RISCV_PRIV_MODE_S   1
`define RISCV_PRIV_MODE_M   3

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

wire          icache_cmd_valid;
wire          icache_cmd_ready = 1'b1;
wire [63:0]   icache_cmd_payload_addr;
reg           icache_rsp_valid;
reg  [31:0]   icache_rsp_payload_data;
wire          dcache_cmd_valid;
wire          dcache_cmd_ready = 1'b1;
wire [63:0]   dcache_cmd_payload_addr;
wire          dcache_cmd_payload_wen;
wire [63:0]   dcache_cmd_payload_wdata;
wire [7:0]    dcache_cmd_payload_wstrb;
wire [2:0]    dcache_cmd_payload_size;
reg           dcache_rsp_valid;
reg  [63:0]   dcache_rsp_payload_data;


// ------------- cpu core -----------------
DandRiscvSimple u_DandRiscvSimple(
    .icache_cmd_valid         ( icache_cmd_valid         ),
    .icache_cmd_ready         ( icache_cmd_ready         ),
    .icache_cmd_payload_addr  ( icache_cmd_payload_addr  ),
    .icache_rsp_valid         ( icache_rsp_valid         ),
    .icache_rsp_payload_data  ( icache_rsp_payload_data  ),
    .dcache_cmd_valid         ( dcache_cmd_valid         ),
    .dcache_cmd_ready         ( dcache_cmd_ready         ),
    .dcache_cmd_payload_addr  ( dcache_cmd_payload_addr  ),
    .dcache_cmd_payload_wen   ( dcache_cmd_payload_wen   ),
    .dcache_cmd_payload_wdata ( dcache_cmd_payload_wdata ),
    .dcache_cmd_payload_wstrb ( dcache_cmd_payload_wstrb ),
    .dcache_cmd_payload_size  ( dcache_cmd_payload_size  ),
    .dcache_rsp_valid         ( dcache_rsp_valid         ),
    .dcache_rsp_payload_data  ( dcache_rsp_payload_data  ),
    .clk                      ( clock                    ),
    .reset                    ( reset                    )
);

// ----------------- ram ------------------
wire [63:0] iram_data_o;
wire [63:0] iram_addr_tmp = (icache_cmd_payload_addr-`PC_START);
wire [27:0] iram_addr = iram_addr_tmp[30:3];
RAMHelper RAMHelper_instruction(
    .clk   ( clock   ),
    .en    ( icache_cmd_valid    ),
    .rIdx  ( iram_addr ),
    .rdata ( iram_data_o ),
    .wIdx  ( iram_addr ),
    .wdata ( 63'b0     ),
    .wmask ( 8'b0      ),
    .wen   ( 1'b0      )
);

always @(posedge clock) begin
    if (icache_cmd_valid) begin
      icache_rsp_valid <= 1'b1;
    end
    else begin
      icache_rsp_valid <= 1'b0;
    end
    
    if (icache_cmd_valid) begin
      icache_rsp_payload_data <= iram_data_o[iram_addr_tmp[2]*32+:32];
    end
end

wire [63:0] dram_data_o;
wire [63:0] dram_addr_tmp = (dcache_cmd_payload_addr-`PC_START);
wire [27:0] dram_addr = dram_addr_tmp[27:0];
wire [63:0] dram_wmask={{8{dcache_cmd_payload_wstrb[7]}}, 
                        {8{dcache_cmd_payload_wstrb[6]}}, 
                        {8{dcache_cmd_payload_wstrb[5]}}, 
                        {8{dcache_cmd_payload_wstrb[4]}}, 
                        {8{dcache_cmd_payload_wstrb[3]}}, 
                        {8{dcache_cmd_payload_wstrb[2]}}, 
                        {8{dcache_cmd_payload_wstrb[1]}}, 
                        {8{dcache_cmd_payload_wstrb[0]}}};
RAMHelper RAMHelper_data(
    .clk   ( clock   ),
    .en    ( dcache_cmd_valid    ),
    .rIdx  ( dram_addr ),
    .rdata ( dram_data_o ),
    .wIdx  ( dram_addr ),
    .wdata ( dcache_cmd_payload_wdata),
    .wmask ( dram_wmask),
    .wen   ( dcache_cmd_payload_wen)
);

always @(posedge clock) begin
    if (dcache_cmd_valid && !dcache_cmd_payload_wen) begin
      dcache_rsp_valid <= 1'b1;
    end
    else begin
      dcache_rsp_valid <= 1'b0;
    end
    
    if (dcache_cmd_valid) begin
      dcache_rsp_payload_data <= dram_data_o;
    end
end

// ------------ Difftest ----------------
reg        cmt_wen;
reg [7:0]  cmt_wdest;
reg [63:0] cmt_wdata;
reg [63:0] cmt_pc;
reg [31:0] cmt_inst;
reg        cmt_valid;
reg        trap;
reg [7:0]  trap_code;
reg [63:0] cycleCnt;
reg [63:0] instrCnt;
reg [63:0] regs_diff [0:31];

reg [63:0] writeback_pc;
reg        writeback_wen;
reg [31:0] writeback_inst;
reg        writeback_valid;
wire[63:0] regs_o [0:31];

genvar j;
generate
	for (j = 0; j < 32; j = j + 1) begin
		assign regs_o[j] = (writeback_wen && u_DandRiscvSimple.writeback_RD_ADDR ==j && j!=0) ? 
                        u_DandRiscvSimple.writeback_RD : u_DandRiscvSimple.regFileModule_1.reg_file[j];
	end
endgenerate

reg branch_ebreak_ecall_mret;
always @(posedge clock) begin
    if (reset) begin
        branch_ebreak_ecall_mret <= 1'b0;
    end
    else begin
        branch_ebreak_ecall_mret <= u_DandRiscvSimple.execute_REDIRECT_VALID;
    end
end

always@(*) begin
  writeback_wen = u_DandRiscvSimple.writeback_RD_WEN & u_DandRiscvSimple.writeback_arbitration_isValid;
  writeback_pc = u_DandRiscvSimple.writeback_PC[63:0];
  writeback_inst = u_DandRiscvSimple.writeback_INSTRUCTION[31:0];
end

always @(posedge clock) begin
    if (branch_ebreak_ecall_mret)
        writeback_valid <= 1;
    else
        writeback_valid <= 0;
end

always @(posedge clock) begin
  if (reset) begin
    { cmt_wen, 
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
    cmt_wen   <= writeback_wen;
    cmt_wdest <= {3'd0, u_DandRiscvSimple.writeback_RD_ADDR};
    cmt_wdata <= u_DandRiscvSimple.writeback_RD;
    cmt_pc    <= writeback_pc;
    cmt_inst  <= writeback_inst;
    cmt_valid <= writeback_wen | writeback_valid;
    regs_diff <= regs_o;
    trap      <= writeback_inst[6:0] == 7'h6b;
    trap_code <= u_DandRiscvSimple.regFileModule_1.reg_file[10][7:0];
    cycleCnt  <= cycleCnt + 1;
    instrCnt  <= instrCnt + (writeback_wen | writeback_valid);
  end
end

reg skip;
always @(posedge clock) begin
  if (reset)
    skip <= 0;
  else if (writeback_inst==32'h7b)
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
  .mstatus            (u_DandRiscvSimple.csrRegfile_1.mstatus),
  .sstatus            (0),
  .mepc               (u_DandRiscvSimple.csrRegfile_1.mepc),
  .sepc               (0),
  .mtval              (0),
  .stval              (0),
  .mtvec              (u_DandRiscvSimple.csrRegfile_1.mtvec),
  .stvec              (0),
  .mcause             (u_DandRiscvSimple.csrRegfile_1.mcause),
  .scause             (0),
  .satp               (0),
  .mip                (u_DandRiscvSimple.csrRegfile_1.mip),
  .mie                (u_DandRiscvSimple.csrRegfile_1.mie),
  .mscratch           (u_DandRiscvSimple.csrRegfile_1.mscratch),
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