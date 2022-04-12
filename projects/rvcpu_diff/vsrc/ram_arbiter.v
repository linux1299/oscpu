// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.08.18
// Access RAM arbiter

`include "defines.v"

module ram_arbiter (
    input clk,
    input rst_n,

    // ifu port
    input            ifu_cen_i,
    input     [63:0] ifu_addr_i,
    input     [2:0]  ifu_size_i,
    input            ifu_instr_valid_i,
    output           ram_ifu_valid_o,
    output    [63:0] ram_ifu_data_o,

    // lsu port
    input            lsu_cen_i,
    input            lsu_wen_i,
    input     [63:0] lsu_addr_i,
    input     [2:0]  lsu_size_i,
    input     [63:0] lsu_wdata_i,
    output           ram_lsu_valid_o,
    output    [63:0] ram_lsu_data_o,

    // timer port
    output           ram_timer_cen_o,
    output           ram_timer_wen_o,
    output    [63:0] ram_timer_addr_o,
    output    [63:0] ram_timer_wdata_o,
    input     [63:0] timer_rdata_i,

    // ram port
    output reg       ram_rw_cen_o,
    output reg       ram_rw_wen_o,
    output reg[63:0] ram_rw_addr_o,
    output reg[63:0] ram_rw_wdata_o,
    output reg[2:0]  ram_rw_size_o,
    input            ram_rw_ready_i,
    input     [63:0] ram_rw_data_i
);

localparam IDLE    = 3'd0;
localparam IF_REQ  = 3'd1;
localparam IF_WAIT = 3'd2;
localparam LS_TIME = 3'd4;
localparam LS_REQ  = 3'd5;
localparam LS_WAIT = 3'd6;

reg  [2:0]  cur_state;
reg  [2:0]  nxt_state;

reg  [2:0]  ifu_instr_valid_reg;
reg         ifu_cen_reg;
reg  [63:0] ifu_addr_reg;
reg  [2:0]  ifu_size_reg;

wire        req_timer_valid;

//-----------state machine-----------
always @(posedge clk) begin
    if(~rst_n) begin
        cur_state <= IDLE;
    end
    else begin
        cur_state <= nxt_state;
    end
end

always @(*) begin
    case (cur_state)
        IDLE : begin
            if (ifu_cen_i || ifu_cen_reg)
                nxt_state = IF_REQ;
            else
                nxt_state = IDLE;
        end

        IF_REQ : begin
                nxt_state = IF_WAIT;
        end

        IF_WAIT : begin
            if (ram_rw_ready_i)
                nxt_state = LS_TIME;
            else
                nxt_state = IF_WAIT;
        end

        LS_TIME : begin
            if (ifu_instr_valid_reg[2]
                && lsu_cen_i
                && ~req_timer_valid)

                nxt_state = LS_REQ;

            else if (| ifu_instr_valid_reg[1:0])
                nxt_state = LS_TIME;

            else if (ifu_cen_i)
                nxt_state = IF_REQ;

            else
                nxt_state = LS_TIME;
        end

        LS_REQ : begin
                nxt_state = LS_WAIT;
        end

        LS_WAIT : begin
            if (ram_rw_ready_i || req_timer_valid)
                nxt_state = IDLE;
            else
                nxt_state = LS_WAIT;
        end

        default : nxt_state = IDLE;
    endcase
end


//----------ifu port---------
always @(posedge clk) begin
    if (~rst_n) begin
        ifu_instr_valid_reg <= 3'b0;
    end
    else begin
        ifu_instr_valid_reg[0] <= ifu_instr_valid_i;
        ifu_instr_valid_reg[1] <= ifu_instr_valid_reg[0];
        ifu_instr_valid_reg[2] <= ifu_instr_valid_reg[1];
    end
end

always @(posedge clk) begin
    if (~rst_n) begin
        ifu_cen_reg <= 1'b0;
    end
    else if (ifu_cen_i) begin
        ifu_cen_reg <= 1'b1;
    end
    else if (nxt_state==IF_REQ) begin
        ifu_cen_reg <= 1'b0;
    end
end

always @(posedge clk) begin
    if (~rst_n) begin
        ifu_addr_reg <= 64'b0;
        ifu_size_reg <= 3'b0;
    end
    else if (ifu_cen_i) begin
        ifu_addr_reg <= ifu_addr_i;
        ifu_size_reg <= ifu_size_i;
    end
end

assign ram_ifu_valid_o = (cur_state == IF_WAIT)
                        & ram_rw_ready_i;

assign ram_ifu_data_o  = ram_rw_data_i;


//-----------lsu port------------
assign ram_lsu_valid_o = (cur_state == LS_WAIT)
                        & ram_rw_ready_i;

assign ram_lsu_data_o  = ram_rw_data_i;


//-----------timer port----------
assign req_timer_valid  =  (lsu_addr_i == `ADDR_MTIME)
                        || (lsu_addr_i == `ADDR_MTIMECMP);

assign ram_timer_cen_o   = lsu_cen_i && req_timer_valid;
assign ram_timer_wen_o   = lsu_wen_i;
assign ram_timer_addr_o  = lsu_addr_i;
assign ram_timer_wdata_o = lsu_wdata_i;


//-----------ram port--------------
always @(posedge clk) begin
    if(~rst_n) begin
        ram_rw_addr_o  <= 0;
        ram_rw_wen_o   <= 0;
        ram_rw_cen_o   <= 0;
        ram_rw_wdata_o <= 0;
        ram_rw_size_o  <= 0;
    end
    else begin
        case (nxt_state)
            IF_REQ, IF_WAIT : begin
                if (ifu_cen_i) begin
                    ram_rw_cen_o   <= 1'b1;
                    ram_rw_wen_o   <= 1'b0;
                    ram_rw_addr_o  <= ifu_addr_i;
                    ram_rw_wdata_o <= 64'b0;
                    ram_rw_size_o  <= ifu_size_i;
                end
                else if (ifu_cen_reg) begin
                    ram_rw_cen_o   <= 1'b1;
                    ram_rw_wen_o   <= 1'b0;
                    ram_rw_addr_o  <= ifu_addr_reg;
                    ram_rw_wdata_o <= 64'b0;
                    ram_rw_size_o  <= ifu_size_reg;
                end
            end

            LS_REQ, LS_WAIT : begin
                ram_rw_cen_o   <= 1'b1;
                ram_rw_wen_o   <= lsu_wen_i;
                ram_rw_addr_o  <= lsu_addr_i;
                ram_rw_wdata_o <= lsu_wdata_i;
                ram_rw_size_o  <= lsu_size_i;
            end

            default : begin
                ram_rw_addr_o  <= 0;
                ram_rw_wen_o   <= 0;
                ram_rw_cen_o   <= 0;
                ram_rw_wdata_o <= 0;
                ram_rw_size_o  <= 0;
            end
        endcase
    end
end



endmodule