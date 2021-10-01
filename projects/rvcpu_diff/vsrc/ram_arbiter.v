// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.08.18
// Access RAM arbiter

`include "defines.v"

module ram_arbiter (
    input clk,
    input rst_n,

    // ifu port
    input     [63:0] i_ifu_addr,
    input            i_ifu_valid,
    output           o_ifu_ready,
    input     [2:0]  i_ifu_size,
    output    [31:0] o_ifu_rdata,

    // lsu port
    input     [63:0] i_lsu_addr,
    input            i_lsu_wen,
    input            i_lsu_valid,
    output           o_lsu_ready,
    input     [63:0] i_lsu_wdata,
    input     [2:0]  i_lsu_size,
    output    [63:0] o_lsu_rdata,

    // timer port
    output    [63:0] o_timer_addr,
    output           o_timer_wen,
    output           o_timer_valid,
    output    [63:0] o_timer_wdata,

    input     [63:0] i_timer_rdata,

    // ram port
    output reg[63:0] o_ram_addr,
    output reg       o_ram_wen,
    output reg       o_ram_valid,
    input            i_ram_ready,

    output reg[63:0] o_ram_wdata,
    output reg[2:0]  o_ram_size,

    input     [63:0] i_ram_rdata
);

localparam IDLE    = 3'd0;
localparam IF_REQ  = 3'd1;
localparam IF_WAIT = 3'd2;
localparam LS_REQ  = 3'd3;
localparam LS_WAIT = 3'd4;

reg  [2:0]  cur_state;
reg  [2:0]  nxt_state;

wire        ifu_read;
wire        ifu_write;

//i_ifu_addr[63:0], i_ifu_size[2:0]
wire [66:0] ifu_fifo_in;
wire [66:0] ifu_fifo_out;
wire [66:0] ifu_addr;
wire [2:0]  ifu_size;
wire        ifu_empty;
wire        lsu_read;
wire        lsu_write;

//i_lsu_wen[0], i_lsu_wdata[63:0],
//i_lsu_addr[63:0], i_lsu_size[2:0]
wire [131:0] lsu_fifo_in;
wire [131:0] lsu_fifo_out;
wire         lsu_wen;
wire [63:0]  lsu_wdata;
wire [63:0]  lsu_addr;
wire [2:0]   lsu_size;
wire         lsu_empty;

wire         req_to_timer;

reg          req_to_ifu;

//-----------state machine-----------
always @(posedge clk) begin
    if(~rst_n) begin
        cur_state <= IDLE;
    end
    else begin
        cur_state <= nxt_state;
    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        req_to_ifu <= 0;
    end
    else if (cur_state == LS_REQ
          || cur_state == IF_REQ) begin

        req_to_ifu <= ~req_to_ifu;
    end
end

always @(*) begin
    case (cur_state)
        IDLE : begin
            if (req_to_ifu) begin
                if (~ifu_empty)
                    nxt_state = IF_REQ;
                else if (~lsu_empty)
                    nxt_state = LS_REQ;
                else
                    nxt_state = IDLE;
            end
            else begin
                if (~lsu_empty)
                    nxt_state = LS_REQ;
                else if (~ifu_empty)
                    nxt_state = IF_REQ;
                else
                    nxt_state = IDLE;
            end
        end

        IF_REQ : begin
            if (i_ram_ready & ~lsu_empty)
                nxt_state = LS_REQ;

            else if (i_ram_ready)
                nxt_state = IDLE;
            else
                nxt_state = IF_WAIT;
        end

        IF_WAIT : begin
            if (i_ram_ready & ~lsu_empty)
                nxt_state = LS_REQ;

            else if (i_ram_ready)
                nxt_state = IDLE;
            else
                nxt_state = IF_WAIT;
        end

        LS_REQ : begin
            if (req_to_timer)
                nxt_state = IDLE;

            else if (i_ram_ready & ~ifu_empty)
                nxt_state = IF_REQ;

            else if (i_ram_ready)
                nxt_state = IDLE;
            else
                nxt_state = LS_WAIT;
        end

        LS_WAIT : begin
            if (i_ram_ready & ~ifu_empty)
                nxt_state = IF_REQ;

            else if (i_ram_ready)
                nxt_state = IDLE;
            else
                nxt_state = LS_WAIT;
        end

        default : nxt_state = IDLE;
    endcase
end

// ---------req of ifu and lsu into fifo-------
assign ifu_write   = i_ifu_valid;
assign ifu_read    = (nxt_state == IF_REQ);

assign ifu_fifo_in = {i_ifu_addr, i_ifu_size};
assign ifu_addr    = ifu_fifo_out[66:3];
assign ifu_size    = ifu_fifo_out[2:0];

assign lsu_write   = i_lsu_valid;
assign lsu_read    = (nxt_state == LS_REQ);

assign lsu_fifo_in = {i_lsu_wen, i_lsu_wdata, i_lsu_addr, i_lsu_size};
assign lsu_wen     = lsu_fifo_out[131];
assign lsu_wdata   = lsu_fifo_out[130:67];
assign lsu_addr    = lsu_fifo_out[66:3];
assign lsu_size    = lsu_fifo_out[2:0];

fifo_depth_1#(
    .FIFO_WIDTH ( 67 )
)u_fifo_ifu(
    .clk         ( clk          ),
    .rst_n       ( rst_n        ),
    .read        ( ifu_read     ),
    .write       ( ifu_write    ),
    .fifo_in     ( ifu_fifo_in  ),
    .fifo_out    ( ifu_fifo_out ),
    .fifo_empty  ( ifu_empty    )
);

fifo_depth_1#(
    .FIFO_WIDTH ( 132 )
)u_fifo_lsu(
    .clk         ( clk      ),
    .rst_n       ( rst_n    ),
    .read        ( lsu_read     ),
    .write       ( lsu_write    ),
    .fifo_in     ( lsu_fifo_in  ),
    .fifo_out    ( lsu_fifo_out ),
    .fifo_empty  ( lsu_empty    )
);



//----------ifu port---------
assign o_ifu_ready   =  (cur_state == IF_REQ || cur_state == IF_WAIT)
                      & i_ram_ready;

assign o_ifu_rdata   = i_ram_rdata[31:0];

//-----------lsu port------------
assign o_lsu_ready   = ((cur_state == LS_REQ || cur_state == LS_WAIT)
                      & i_ram_ready) || (cur_state == LS_REQ && req_to_timer);

assign o_lsu_rdata   = req_to_timer ? i_timer_rdata : i_ram_rdata;

//-----------timer port----------
assign req_to_timer  = (lsu_addr == `ADDR_MTIME)
                    || (lsu_addr == `ADDR_MTIMECMP);

assign o_timer_addr  = lsu_addr;

assign o_timer_wen   = lsu_wen;

assign o_timer_valid = req_to_timer;

assign o_timer_wdata = lsu_wdata;

//-----------ram port--------------
always @(posedge clk) begin
    if(~rst_n) begin
        o_ram_addr  <= 0;
        o_ram_wen   <= 0;
        o_ram_valid <= 0;
        o_ram_wdata <= 0;
        o_ram_size  <= 0;
    end
    else begin
        case (nxt_state)
            IF_REQ, IF_WAIT : begin
                o_ram_addr  <= ifu_addr;
                o_ram_wen   <= 0;
                o_ram_valid <= 1;
                o_ram_wdata <= 0;
                o_ram_size  <= ifu_size;
            end

            LS_REQ, LS_WAIT : begin
                o_ram_addr  <= lsu_addr;
                o_ram_wen   <= lsu_wen;
                o_ram_valid <= ~req_to_timer;
                o_ram_wdata <= lsu_wdata;
                o_ram_size  <= lsu_size;
            end

            default : begin
                o_ram_addr  <= o_ram_addr;
                o_ram_wen   <= o_ram_wen;
                o_ram_valid <= 0;
                o_ram_wdata <= o_ram_wdata;
                o_ram_size  <= o_ram_size;
            end
        endcase
    end
end



endmodule