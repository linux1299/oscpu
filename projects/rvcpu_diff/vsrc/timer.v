// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.09.02
// Timer interruptor


`include "defines.v"

module timer (
    input             clk,
    input             rst_n,

    output            o_timer_int,

    // cpu port
    input             i_wen,
    input             i_valid,
    input      [63:0] i_addr,
    input      [63:0] i_wdata,
    output reg [63:0] o_rdata

);

reg  [63:0] mtime;
reg  [63:0] mtimecmp;

always @(posedge clk) begin
    if(~rst_n) begin
        mtime    <= 0;
        mtimecmp <= 0;
    end
    else if (i_wen & i_valid) begin
        case (i_addr)
            `ADDR_MTIME :    mtime    <= i_wdata;

            `ADDR_MTIMECMP : mtimecmp <= i_wdata;
        endcase
    end
    else begin
        mtime    <= mtime + 1'b1;
        mtimecmp <= mtimecmp;
    end
end

always @(*) begin
    case (i_addr)
        `ADDR_MTIME :    o_rdata = mtime;

        `ADDR_MTIMECMP : o_rdata = mtimecmp;

        default :        o_rdata = 0;
    endcase
end

assign o_timer_int = (mtime >= mtimecmp);

endmodule