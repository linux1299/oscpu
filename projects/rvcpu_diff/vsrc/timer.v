// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.09.02
// Timer interruptor


`include "defines.v"

module timer (
    input             clk,
    input             rst_n,

    output            timer_int_o,

    // cpu port
    input             cen_i,
    input             wen_i,
    input      [63:0] addr_i,
    input      [63:0] wdata_i,
    output reg [63:0] timer_rdata_o,
    output reg        timer_ready_o

);

reg  [63:0] mtime;
reg  [63:0] mtimecmp;

always @(posedge clk) begin
    if(~rst_n) begin
        mtime    <= 0;
        // mtimecmp <= 0;
        mtimecmp <= 64'hffff_ffff_ffff_ffff;
    end
    else if (wen_i & cen_i) begin
        case (addr_i)
            `ADDR_MTIME :    mtime    <= wdata_i;

            `ADDR_MTIMECMP : mtimecmp <= wdata_i;
        endcase
    end
    else begin
        mtime    <= mtime + 1'b1;
        mtimecmp <= mtimecmp;
    end
end

always @(*) begin
    case (addr_i)
        `ADDR_MTIME :    timer_rdata_o = mtime;

        `ADDR_MTIMECMP : timer_rdata_o = mtimecmp;

        default :        timer_rdata_o = 0;
    endcase
end

always @(posedge clk) begin
    if(~rst_n) begin
        timer_ready_o <= 1'b0;
    end
    else if (cen_i) begin
        timer_ready_o <= 1'b1;
    end
    else begin
        timer_ready_o <= 1'b0;
    end
end

assign timer_int_o = (mtime >= mtimecmp);

endmodule