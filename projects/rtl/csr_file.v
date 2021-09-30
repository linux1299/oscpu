// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.09.02
// Control and Status Registers File

module  ysyx_210238_csr_file (
    input             clk,
    input             rst_n,

    // cpu port
    input             i_cpu_csr_wen,
    input      [11:0] i_cpu_csr_raddr,
    input      [11:0] i_cpu_csr_waddr,
    input      [63:0] i_cpu_csr_wdata,
    output reg [63:0] o_cpu_csr_rdata,

    // clint port
    input             i_clint_csr_wen,
    input      [11:0] i_clint_csr_waddr,
    input      [63:0] i_clint_csr_wdata,

    output     [63:0] o_clint_csr_mtvec,
    output     [63:0] o_clint_csr_mepc,
    output     [63:0] o_clint_csr_mstatus,

    output            o_global_int_en,
    output            o_mtime_int_en,
    output            o_mtime_int_pend,

    // timer port
    input             i_timer_int
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
    else begin
        mip <= i_timer_int;
    end
end

//----------Write CSR-----------------------
always @(posedge clk) begin
    if(~rst_n) begin
        mstatus <= {51'b0, 13'b11_0001_0000000}; // MPP=11, MPIE=1
        mie     <= 0;
        mtvec   <= 0;
        mepc    <= 0;
        mcause  <= 0;
        mtval   <= 0;
        mhartid <= 0;
    end
    else if (i_cpu_csr_wen) begin
        case (i_cpu_csr_waddr)
            `ADDR_MSTATUS : mstatus <= i_cpu_csr_wdata;

            `ADDR_MIE     : mie     <= i_cpu_csr_wdata;

            `ADDR_MTVEC   : mtvec   <= i_cpu_csr_wdata;

            `ADDR_MEPC    : mepc    <= i_cpu_csr_wdata;

            `ADDR_MCAUSE  : mcause  <= i_cpu_csr_wdata;

            `ADDR_MTVAL   : mtval   <= i_cpu_csr_wdata;

            `ADDR_MHARTID : mhartid <= i_cpu_csr_wdata;
        endcase
    end
    else if (i_clint_csr_wen) begin
        case (i_clint_csr_waddr)
            `ADDR_MSTATUS : mstatus <= i_clint_csr_wdata;

            `ADDR_MIE     : mie     <= i_clint_csr_wdata;

            `ADDR_MTVEC   : mtvec   <= i_clint_csr_wdata;

            `ADDR_MEPC    : mepc    <= i_clint_csr_wdata;

            `ADDR_MCAUSE  : mcause  <= i_clint_csr_wdata;

            `ADDR_MTVAL   : mtval   <= i_clint_csr_wdata;

            `ADDR_MHARTID : mhartid <= i_clint_csr_wdata;
        endcase
    end
end

//----------Read CSR---------------------
always @(*) begin
    if (i_cpu_csr_wen & (i_cpu_csr_raddr == i_cpu_csr_waddr)) begin
        o_cpu_csr_rdata = i_cpu_csr_wdata;
    end
    else begin
        case (i_cpu_csr_raddr)
            `ADDR_MSTATUS : o_cpu_csr_rdata = mstatus;

            `ADDR_MIE     : o_cpu_csr_rdata = mie;

            `ADDR_MTVEC   : o_cpu_csr_rdata = mtvec;

            `ADDR_MEPC    : o_cpu_csr_rdata = mepc;

            `ADDR_MCAUSE  : o_cpu_csr_rdata = mcause;

            `ADDR_MTVAL   : o_cpu_csr_rdata = mtval;

            `ADDR_MIP     : o_cpu_csr_rdata = mip;

            `ADDR_MCYCLE  : o_cpu_csr_rdata = mcycle;

            `ADDR_MHARTID : o_cpu_csr_rdata = mhartid;

            default       : o_cpu_csr_rdata = 0;
        endcase
    end
end

assign o_clint_csr_mtvec   = mtvec;
assign o_clint_csr_mepc    = mepc;
assign o_clint_csr_mstatus = mstatus;

assign o_global_int_en     = mstatus[3];
assign o_mtime_int_en      = mie[7];
assign o_mtime_int_pend    = mip[7];

endmodule