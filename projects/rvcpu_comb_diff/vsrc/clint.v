// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.08.31
// Core local interruptor

`include "defines.v"

module clint (
    input             clk,
    input             rst_n,

    // timer port
    input             i_timer_int,

    // idu port
    input      [2:0]  i_expt_info,
    input      [63:0] i_instr_addr,
    input             i_branch_jump,
    input      [63:0] i_jump_addr,
    output reg [63:0] o_int_addr,
    output reg        o_int_valid,
    output            o_hold,

    // csr port
    input             i_global_int_en,
    input             i_mtime_int_en,
    input             i_mtime_int_pend,

    input      [63:0] i_csr_mtvec,
    input      [63:0] i_csr_mepc,
    input      [63:0] i_csr_mstatus,

    output reg        o_csr_wen,
    output reg [11:0] o_csr_waddr,
    output reg [63:0] o_csr_wdata

);

//-------Exception or Interrupt Sate-----
localparam INT_IDLE = 0;
localparam INT_EXPT = 1;
localparam INT_TIME = 2;
localparam INT_MRET = 3;

//-------Write CSR state-----------
localparam CSR_IDLE    = 0;
localparam CSR_MSTATUS = 1;
localparam CSR_MEPC    = 2;
localparam CSR_MRET    = 3;
localparam CSR_MCAUSE  = 4;

reg  [1:0]  int_state;
reg  [2:0]  csr_state;
reg  [63:0] mepc_wdata;
reg  [63:0] mcause_wdata;

wire op_ecall   = i_expt_info[2];
wire op_ebreak  = i_expt_info[1];
wire op_mret    = i_expt_info[0];



//------Exception or Interrupt Sate transition----
always @(*) begin
    if(op_ecall || op_ebreak) begin
        int_state = INT_EXPT; // envirionment call or break
    end
    else if (i_global_int_en &
            ((i_timer_int & i_mtime_int_en) |
             (i_timer_int & i_mtime_int_pend)) ) begin

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
                    csr_state <= CSR_MEPC;

                else if (int_state == INT_TIME)
                    csr_state <= CSR_MEPC;

                else if (int_state == INT_MRET)
                    csr_state <= CSR_MRET;
            end

            CSR_MEPC :
                    csr_state <= CSR_MSTATUS;

            CSR_MSTATUS :
                    csr_state <= CSR_MCAUSE;

            CSR_MCAUSE :
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

        if (i_branch_jump & (int_state == INT_TIME))
            mepc_wdata <= i_jump_addr;
        else
            mepc_wdata <= i_instr_addr;
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
        o_csr_wen   <= 0;
        o_csr_waddr <= 0;
        o_csr_wdata <= 0;
    end
    else begin
        case (csr_state)
            CSR_MEPC : begin
                o_csr_wen   <= 1'b1;
                o_csr_waddr <= `ADDR_MEPC;
                o_csr_wdata <= mepc_wdata;
            end

            CSR_MCAUSE : begin
                o_csr_wen   <= 1'b1;
                o_csr_waddr <= `ADDR_MCAUSE;
                o_csr_wdata <= mcause_wdata;
            end

            CSR_MSTATUS : begin
                o_csr_wen   <= 1'b1;
                o_csr_waddr <= `ADDR_MSTATUS;
                o_csr_wdata <= {i_csr_mstatus[63:4],
                                1'b0, // close global int
                                i_csr_mstatus[2:0]};
            end

            CSR_MRET : begin
                o_csr_wen   <= 1'b1;
                o_csr_waddr <= `ADDR_MSTATUS;
                o_csr_wdata <= {i_csr_mstatus[63:4],
                                i_csr_mstatus[7], // MIE=MPIE
                                i_csr_mstatus[2:0]};
            end

            default : begin
                o_csr_wen   <= 0;
                o_csr_waddr <= 0;
                o_csr_wdata <= 0;
            end
        endcase
    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        o_int_addr  <= 0;
        o_int_valid <= 0;
    end
    else begin
        case (csr_state)
            CSR_MCAUSE : begin
                o_int_addr  <= i_csr_mtvec;
                o_int_valid <= 1'b1;
            end

            CSR_MRET : begin
                o_int_addr  <= i_csr_mepc;
                o_int_valid <= 1'b1;
            end
            default : begin
                o_int_addr  <= 0;
                o_int_valid <= 0;
            end
        endcase
    end
end

assign o_hold =  (int_state != INT_IDLE)
               | (csr_state != CSR_IDLE);

endmodule