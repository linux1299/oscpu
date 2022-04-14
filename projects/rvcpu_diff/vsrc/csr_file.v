// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.09.02
// Control and Status Registers File

`include "defines.v"

module csr_file (
    input             clk,
    input             rst_n,

    // cpu port
    input             cpu_csr_wen_i,
    input      [11:0] cpu_csr_raddr_i,
    input      [11:0] cpu_csr_waddr_i,
    input      [63:0] cpu_csr_wdata_i,
    output reg [63:0] csrfile_cpu_csr_rdata_o,

    // clint port
    input             clint_mepc_wen_i     ,
    input [63:0]      clint_mepc_wdata_i   ,
    input             clint_mcause_wen_i   ,
    input [63:0]      clint_mcause_wdata_i ,
    input             clint_mstatus_wen_i  ,
    input [63:0]      clint_mstatus_wdata_i,

    output     [63:0] csrfile_clint_csr_mtvec_o,
    output     [63:0] csrfile_clint_csr_mepc_o,
    output     [63:0] csrfile_clint_csr_mstatus_o,

    output            csrfile_global_int_en_o,
    output            csrfile_mtime_int_en_o,
    output            csrfile_mtime_int_pend_o,

    // timer port
    input             timer_int_i
);

//---------CSR--------
reg [63:0] mstatus;
reg [63:0] mie;
reg [63:0] mtvec;
reg [63:0] mepc;
reg [63:0] mcause;
reg [63:0] mtval;
reg [63:0] mip;
reg [63:0] mcycle;
reg [63:0] mhartid;
reg [63:0] mscratch;


//---------mcycle---------------------------
always @(posedge clk) begin
    if(~rst_n) begin
        mcycle <= 0;
    end
    else begin
        mcycle <= mcycle + 1'b1;
    end
end

//--------------mip------------------------
always @(posedge clk) begin
    if(~rst_n) begin
        mip <= 0;
    end
    else if (timer_int_i) begin
        mip[7] <= 1'b1;
    end
end

//----------Write CSR-----------------------
always @(posedge clk) begin
    if(~rst_n) begin

        // mstatus: MPP[12:11]=11, MPIE[7]=?, MIE[3]=?
        // mstatus <= {51'b0, 13'b11000_1000_1000};
        mstatus <= {51'b0, 13'b11000_0000_0000}; // 
        
        // mie: MTIE[7]=1
        // mie     <= {56'b0, 8'b1000_0000};
        mie     <= 0;
        mtvec   <= 0;
        mepc    <= 0;
        mcause  <= 0;
        mtval   <= 0;
        mhartid <= 0;
        mscratch<= 0;
    end
    else if (cpu_csr_wen_i) begin
        case (cpu_csr_waddr_i)

            `ADDR_MSTATUS : mstatus <= cpu_csr_wdata_i;

            `ADDR_MIE     : mie     <= cpu_csr_wdata_i;

            `ADDR_MTVEC   : mtvec   <= cpu_csr_wdata_i;

            `ADDR_MEPC    : mepc    <= cpu_csr_wdata_i;

            `ADDR_MCAUSE  : mcause  <= cpu_csr_wdata_i;

            `ADDR_MTVAL   : mtval   <= cpu_csr_wdata_i;

            `ADDR_MHARTID : mhartid <= cpu_csr_wdata_i;

            `ADDR_MSCRATCH: mscratch<= cpu_csr_wdata_i;

            default : mstatus <= mstatus;
        endcase
    end
    else begin
        if (clint_mepc_wen_i) begin

            mepc <= clint_mepc_wdata_i;
        end
        if (clint_mcause_wen_i) begin

            mcause <= clint_mcause_wdata_i;
        end
        if (clint_mstatus_wen_i) begin

            mstatus <= clint_mstatus_wdata_i;
        end
    end
end

//----------Read CSR---------------------
always @(*) begin
    if (cpu_csr_wen_i & (cpu_csr_raddr_i == cpu_csr_waddr_i)) begin
        csrfile_cpu_csr_rdata_o = cpu_csr_wdata_i;
    end
    else begin
        case (cpu_csr_raddr_i)
            `ADDR_MSTATUS : csrfile_cpu_csr_rdata_o = mstatus;

            `ADDR_MIE     : csrfile_cpu_csr_rdata_o = mie;

            `ADDR_MTVEC   : csrfile_cpu_csr_rdata_o = mtvec;

            `ADDR_MEPC    : csrfile_cpu_csr_rdata_o = mepc;

            `ADDR_MCAUSE  : csrfile_cpu_csr_rdata_o = mcause;

            `ADDR_MTVAL   : csrfile_cpu_csr_rdata_o = mtval;

            `ADDR_MIP     : csrfile_cpu_csr_rdata_o = mip;

            `ADDR_MCYCLE  : csrfile_cpu_csr_rdata_o = mcycle;

            `ADDR_MHARTID : csrfile_cpu_csr_rdata_o = mhartid;

            default       : csrfile_cpu_csr_rdata_o = 0;
        endcase
    end
end

assign csrfile_clint_csr_mtvec_o   = mtvec;
assign csrfile_clint_csr_mepc_o    = mepc;
assign csrfile_clint_csr_mstatus_o = mstatus;

assign csrfile_global_int_en_o     = mstatus[3];
assign csrfile_mtime_int_en_o      = mie[7];
assign csrfile_mtime_int_pend_o    = mip[7];

endmodule