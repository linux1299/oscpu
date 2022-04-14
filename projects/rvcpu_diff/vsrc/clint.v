// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.08.31
// Core local interruptor

`include "defines.v"

module clint (
    input             clk,
    input             rst_n,

    // timer port
    input             timer_int_i,

    // idu port
    input      [63:0] pc_i,
    input             jump_i,
    input      [63:0] jump_pc_i,
    input      [2:0]  expt_info_i,
    output reg [63:0] clint_int_addr_o,
    output reg        clint_int_valid_o,
    output            clint_hold_o,

    // csr port
    input             global_int_en_i,
    input             mtime_int_en_i,
    input             mtime_int_pend_i,

    input      [63:0] csr_mtvec_i,
    input      [63:0] csr_mepc_i,
    input      [63:0] csr_mstatus_i,

    output reg        clint_mepc_wen_o,
    output reg [63:0] clint_mepc_wdata_o,

    output reg        clint_mcause_wen_o,
    output reg [63:0] clint_mcause_wdata_o,

    output reg        clint_mstatus_wen_o,
    output reg [63:0] clint_mstatus_wdata_o

);

//-------Exception or Interrupt Sate-----
localparam INT_IDLE = 0;
localparam INT_EXPT = 1;
localparam INT_TIME = 2;
localparam INT_MRET = 3;

//-------Write CSR state-----------
localparam CSR_IDLE    = 0;
localparam CSR_MEPC_MCAUSE_MSTATUS = 1;
localparam CSR_MRET    = 2;

reg  [1:0]  int_state;
reg  [2:0]  csr_state;
reg  [63:0] mepc_wdata;
reg  [63:0] mcause_wdata;

wire op_ecall   = expt_info_i[2];
wire op_ebreak  = expt_info_i[1];
wire op_mret    = expt_info_i[0];



//------Exception or Interrupt Sate transition----
always @(*) begin
    if(op_ecall || op_ebreak) begin
        int_state = INT_EXPT; // envirionment call or break
    end
    else if (global_int_en_i &&
                ((timer_int_i && mtime_int_en_i) ||
                 (timer_int_i && mtime_int_pend_i)) ) begin

        int_state = INT_TIME; // timer interrupt
    end
    else if (op_mret) begin
        int_state = INT_MRET; // machine return
    end
    else begin
        int_state = INT_IDLE;
    end
end

//-------Write CSR state transition---------
always @(posedge clk) begin
    if(~rst_n) begin
        csr_state <= CSR_IDLE;
    end
    else begin
        case (csr_state)
            CSR_IDLE : begin
                if (int_state == INT_EXPT)
                    csr_state <= CSR_MEPC_MCAUSE_MSTATUS;

                else if (int_state == INT_TIME)
                    csr_state <= CSR_MEPC_MCAUSE_MSTATUS;

                else if (int_state == INT_MRET)
                    csr_state <= CSR_MRET;
            end

            CSR_MEPC_MCAUSE_MSTATUS :
                    csr_state <= CSR_IDLE;

            CSR_MRET :
                    csr_state <= CSR_IDLE;

            default :
                    csr_state <= CSR_IDLE;
        endcase
    end
end

//--------mepc mcause wdata------
always @(posedge clk) begin
    if(~rst_n) begin
        mepc_wdata <= 0;
    end
    else if (csr_state == CSR_IDLE) begin

        if (jump_i & (int_state == INT_TIME))
            mepc_wdata <= jump_pc_i;
        else
            mepc_wdata <= pc_i;
    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        mcause_wdata <= 0;
    end
    else if (csr_state == CSR_IDLE) begin

        if (int_state == INT_EXPT) begin

            if (op_ecall)
                mcause_wdata <= 64'd11;

            else if (op_ebreak)
                mcause_wdata <= 64'd3;

            else
                mcause_wdata <= 64'd10;
        end
        else if (int_state == INT_TIME) begin

            mcause_wdata <= 64'h8000_0000_0000_0007;

        end

    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        clint_mepc_wen_o      <= 1'b0;
        clint_mcause_wen_o    <= 1'b0;
        clint_mstatus_wen_o   <= 1'b0;

        clint_mepc_wdata_o    <= 64'b0;
        clint_mcause_wdata_o  <= 64'b0;
        clint_mstatus_wdata_o <= 64'b0;
    end
    else begin
        case (csr_state)
            CSR_MEPC_MCAUSE_MSTATUS : begin
                clint_mepc_wen_o      <= 1'b1;
                clint_mcause_wen_o    <= 1'b1;
                clint_mstatus_wen_o   <= 1'b1;

                clint_mepc_wdata_o    <= mepc_wdata;
                clint_mcause_wdata_o  <= mcause_wdata;
                clint_mstatus_wdata_o <= {csr_mstatus_i[63:4],
                                          1'b0, // close global int
                                          csr_mstatus_i[2:0]};
            end

            CSR_MRET : begin
                clint_mstatus_wen_o   <= 1'b1;
                clint_mstatus_wdata_o <= {
                                          csr_mstatus_i[63:8],
                                          4'b1000,          // MPIE[7]=1
                                        //   4'b0000,          // MPIE[7]=0
                                          csr_mstatus_i[7], // MIE=MPIE[7]
                                          3'b0};
            end

            default : begin
                clint_mepc_wen_o      <= 1'b0;
                clint_mcause_wen_o    <= 1'b0;
                clint_mstatus_wen_o   <= 1'b0;
            end
        endcase
    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        clint_int_addr_o  <= 0;
        clint_int_valid_o <= 0;
    end
    else begin
        case (csr_state)
            CSR_MEPC_MCAUSE_MSTATUS : begin
                clint_int_addr_o  <= csr_mtvec_i;
                clint_int_valid_o <= 1'b1;
            end

            CSR_MRET : begin
                clint_int_addr_o  <= csr_mepc_i;
                clint_int_valid_o <= 1'b1;
            end
            default : begin
                clint_int_addr_o  <= 0;
                clint_int_valid_o <= 0;
            end
        endcase
    end
end

assign clint_hold_o =  (int_state != INT_IDLE)
               | (csr_state != CSR_IDLE);

endmodule