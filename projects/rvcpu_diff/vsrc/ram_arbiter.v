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
    output reg[7:0]  ram_rw_wmask_o,
    output reg[2:0]  ram_rw_size_o,
    input            ram_rw_ready_i,
    input     [63:0] ram_rw_data_i
);

parameter MASK_WIDTH    = 128;

localparam IDLE    = 3'd0;
localparam IF_REQ  = 3'd1;
localparam IF_WAIT = 3'd2;
localparam LS_TIME = 3'd4;
localparam LS_REQ_0= 3'd5;
localparam LS_REQ_1= 3'd6;
localparam LS_WAIT = 3'd7;

reg  [2:0]  cur_state;
reg  [2:0]  nxt_state;

reg  [2:0]  ifu_instr_valid_reg;
reg         ifu_cen_reg;
reg  [63:0] ifu_addr_reg;
reg  [2:0]  ifu_size_reg;

wire        req_timer_valid;
reg [7:0]   lsu_req_len;

// ------------------Process LSU Data------------------
wire lsu_aligned = lsu_addr_i[2:0] == 3'b000;
wire lsu_size_b  = lsu_size_i[1:0] == 2'b00;
wire lsu_size_h  = lsu_size_i[1:0] == 2'b01;
wire lsu_size_w  = lsu_size_i[1:0] == 2'b10;
wire lsu_size_d  = lsu_size_i[1:0] == 2'b11;

wire [3:0]   lsu_addr_op1 = {1'b0, lsu_addr_i[2:0]};

wire [3:0]   lsu_addr_op2 =   ({4{lsu_size_b}} & {4'b0000})
                            | ({4{lsu_size_h}} & {4'b0001})
                            | ({4{lsu_size_w}} & {4'b0011})
                            | ({4{lsu_size_d}} & {4'b0111})
                            ;

wire [3:0]   lsu_addr_end = lsu_addr_op1 + lsu_addr_op2;
wire         lsu_crossover= lsu_addr_end[3]; // LSU reqcross 8 byte boundry

wire [7:0]   lsu_len              = lsu_aligned ? 8'd0 : {7'b0, lsu_crossover}; // 0 or 1
wire [2:0]   lsu_size             = lsu_size_i;
wire [63:0]  lsu_addr             = lsu_addr_i;
wire [63:0]  lsu_addr_aligned     = {lsu_addr_i[63:3], 3'd0};
wire [5:0]   lsu_aligned_offset_l = {3'b0, lsu_addr_i[2:0]} << 3;
wire [5:0]   lsu_aligned_offset_h = `AXI_DATA_WIDTH - lsu_aligned_offset_l;

// --------------- read mask and write mask -----------------
wire [127:0] lsu_full_rmask =(({MASK_WIDTH{lsu_size_b}} & {{MASK_WIDTH-8{1'b0}},  8'hff})
                            | ({MASK_WIDTH{lsu_size_h}} & {{MASK_WIDTH-16{1'b0}}, 16'hffff})
                            | ({MASK_WIDTH{lsu_size_w}} & {{MASK_WIDTH-32{1'b0}}, 32'hffffffff})
                            | ({MASK_WIDTH{lsu_size_d}} & {{MASK_WIDTH-64{1'b0}}, 64'hffffffff_ffffffff})
                            ) << lsu_aligned_offset_l;

wire [15:0] lsu_full_wmask  = (({16{lsu_size_b}} & 16'b0000_0001)
                             | ({16{lsu_size_h}} & 16'b0000_0011)
                             | ({16{lsu_size_w}} & 16'b0000_1111)
                             | ({16{lsu_size_d}} & 16'b1111_1111)
                             ) << lsu_addr_i[2:0];

wire [63:0] lsu_rmask_l  = lsu_full_rmask[63:0];
wire [63:0] lsu_rmask_h  = lsu_full_rmask[127:64];
wire [7:0]  lsu_wmask_l  = lsu_full_wmask[7:0];
wire [7:0]  lsu_wmask_h  = lsu_full_wmask[15:8];

wire [63:0] lsu_wdata_l  = (lsu_wdata_i << lsu_aligned_offset_l) & lsu_rmask_l;
wire [63:0] lsu_wdata_h  = (lsu_wdata_i >> lsu_aligned_offset_h) & lsu_rmask_h;

// ------------------Number of transmission------------------
always @(posedge clk) begin
    if (~rst_n) begin
        lsu_req_len <= 8'd0;
    end
    else if (nxt_state==LS_REQ_0) begin
        lsu_req_len <= 8'd0;
    end
    else if (nxt_state==LS_WAIT && ram_rw_ready_i) begin
        lsu_req_len <= lsu_req_len + 1'd1;
    end
end


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
                && ~req_timer_valid
                && lsu_cen_i
                )
                nxt_state = LS_REQ_0;

            else if (| ifu_instr_valid_reg[1:0])
                nxt_state = LS_TIME;

            else if (ifu_cen_reg)
                nxt_state = IF_REQ;

            else
                nxt_state = LS_TIME;
        end

        LS_REQ_0 : begin
                nxt_state = LS_WAIT;
        end

        LS_REQ_1 : begin
                nxt_state = LS_WAIT;
        end

        LS_WAIT : begin
            if (ram_rw_ready_i || req_timer_valid) begin
                if (lsu_req_len==lsu_len)
                    nxt_state = IDLE;
                else
                    nxt_state = LS_REQ_1;
            end
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
    else if (nxt_state==IF_REQ) begin
        ifu_cen_reg <= 1'b0;
    end
    else if (ifu_cen_i) begin
        ifu_cen_reg <= 1'b1;
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
wire [63:0] lsu_rdata_l  = (ram_rw_data_i & lsu_rmask_l) >> lsu_aligned_offset_l;
wire [63:0] lsu_rdata_h  = (ram_rw_data_i & lsu_rmask_h) << lsu_aligned_offset_h;
reg  [63:0] lsu_rdata;
reg         lsu_rdata_valid;

always @(posedge clk) begin
    if (~rst_n) begin
        lsu_rdata[63:0] <= 64'b0;
        lsu_rdata_valid <= 1'b0;
    end
    else if (cur_state==LS_WAIT && ram_rw_ready_i) begin
        if (~lsu_aligned && lsu_crossover) begin
            if (lsu_req_len==8'd1) begin
                lsu_rdata[63:0] <= lsu_rdata[63:0] | lsu_rdata_h;
                lsu_rdata_valid <= 1'b1;
            end
            else begin
                lsu_rdata[63:0] <= lsu_rdata_l;
                lsu_rdata_valid <= 1'b0;
            end
        end
        else begin
            lsu_rdata[63:0] <= lsu_rdata_l;
            lsu_rdata_valid <= 1'b1;
        end
    end
    else begin
        lsu_rdata_valid <= 1'b0;
    end
end

assign ram_lsu_valid_o = lsu_rdata_valid;

assign ram_lsu_data_o  = lsu_rdata;


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
        ram_rw_wmask_o <= 0;
    end
    else begin
        case (nxt_state)
            IF_REQ : begin
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

            LS_REQ_0: begin
                ram_rw_cen_o   <= 1'b1;
                ram_rw_wen_o   <= lsu_wen_i;
                ram_rw_addr_o  <= lsu_addr;
                ram_rw_wdata_o <= lsu_wdata_l;
                ram_rw_size_o  <= 3'b011;
                ram_rw_wmask_o <= 0;
            end

            LS_REQ_1: begin
                ram_rw_cen_o   <= 1'b1;
                ram_rw_wen_o   <= lsu_wen_i;
                ram_rw_addr_o  <= lsu_addr_aligned + 4'd8;
                ram_rw_wdata_o <= lsu_wdata_h;
                ram_rw_size_o  <= 3'b011;
                ram_rw_wmask_o <= lsu_wmask_l;
            end

            LS_WAIT, IF_WAIT  : begin
                ram_rw_cen_o   <= ram_rw_cen_o  ;
                ram_rw_wen_o   <= ram_rw_wen_o  ;
                ram_rw_addr_o  <= ram_rw_addr_o ;
                ram_rw_wdata_o <= ram_rw_wdata_o;
                ram_rw_size_o  <= ram_rw_size_o ;
                ram_rw_wmask_o <= lsu_wmask_h;
            end

            default : begin
                ram_rw_addr_o  <= 0;
                ram_rw_wen_o   <= 0;
                ram_rw_cen_o   <= 0;
                ram_rw_wdata_o <= 0;
                ram_rw_size_o  <= 0;
                ram_rw_wmask_o <= 0;
            end
        endcase
    end
end



endmodule