// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.09.07
// Load Store unit
// as known as "MEM"

`include "defines.v"

module lsu(
    input            clk,
    input            rst_n,

    // ls
    input     [63:0] mem_addr_i,
    input     [63:0] mem_wdata_i,
    input            mem_read_i,
    input            mem_write_i,
    input     [10:0] ls_info_i,

    // ram port
    output           lsu_ram_cen_o,
    output           lsu_ram_wen_o,
    output    [63:0] lsu_ram_addr_o,
    output    [2:0]  lsu_ram_size_o,
    output    [63:0] lsu_ram_wdata_o,
    input     [63:0] lsu_ram_data_i,
    input            lsu_ram_ready_i,

    // wb
    input            rd_wen_i,
    input     [63:0] rd_data_i,
    input     [4:0]  rd_addr_i,
    output           lsu_rd_wen_o,
    output    [63:0] lsu_rd_data_o,
    output    [4:0]  lsu_rd_addr_o,
    output    [63:0] lsu_mem_rdata_o,
    output           lsu_mem_read_o,
    output           lsu_hold_o
);


wire op_ls_lb  = ls_info_i[10];
wire op_ls_lbu = ls_info_i[9];
wire op_ls_ld  = ls_info_i[8];
wire op_ls_lh  = ls_info_i[7];
wire op_ls_lhu = ls_info_i[6];
wire op_ls_lw  = ls_info_i[5];
wire op_ls_lwu = ls_info_i[4];
wire op_ls_sb  = ls_info_i[3];
wire op_ls_sd  = ls_info_i[2];
wire op_ls_sh  = ls_info_i[1];
wire op_ls_sw  = ls_info_i[0];

wire [63:0] lb_rdata;
wire [63:0] lh_rdata;
wire [63:0] lw_rdata;
wire [63:0] lbu_rdata;
wire [63:0] lhu_rdata;
wire [63:0] lwu_rdata;
wire [63:0] rdata;

wire [63:0] sb_wdata;
wire [63:0] sh_wdata;
wire [63:0] sw_wdata;
wire [63:0] wdata;

wire [2:0]  b_size = 3'b000;
wire [2:0]  h_size = 3'b001;
wire [2:0]  w_size = 3'b010;
wire [2:0]  d_size = 3'b011;
wire [2:0]  size;

wire        mem_req = mem_read_i | mem_write_i;
reg  [1:0]  cur_state;
reg  [1:0]  nxt_state;

localparam IDLE = 2'd0;
localparam REQ  = 2'd1;
localparam WAIT = 2'd2;

//-------------State machine-----------
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
            if (mem_req)
                nxt_state = REQ;
            else
                nxt_state = IDLE;
        end
        REQ  : begin
            if (lsu_ram_ready_i)
                nxt_state = IDLE;
            else
                nxt_state = WAIT;
        end
        WAIT : begin
            if (lsu_ram_ready_i)
                nxt_state = IDLE;
            else
                nxt_state = WAIT;
            end
        default : nxt_state = IDLE;
    endcase
end

//---------------------------store-----------------------------
assign sb_wdata = {56'd0, mem_wdata_i[7:0]};
assign sh_wdata = {48'b0, mem_wdata_i[15:0]};
assign sw_wdata = {32'b0, mem_wdata_i[31:0]};

assign wdata = ({64{op_ls_sb}} & sb_wdata )
              |({64{op_ls_sh}} & sh_wdata )
              |({64{op_ls_sw}} & sw_wdata )
              |({64{op_ls_sd}} & mem_wdata_i)
            ;

assign size  = ({3{op_ls_sb | op_ls_lb | op_ls_lbu}} & b_size )
              |({3{op_ls_sh | op_ls_lh | op_ls_lhu}} & h_size )
              |({3{op_ls_sw | op_ls_lw | op_ls_lwu}} & w_size )
              |({3{op_ls_sd | op_ls_ld}}             & d_size)
            ;

//------------------------load----------------------------------------
assign lb_rdata  = {{56{lsu_ram_data_i[7]}}, lsu_ram_data_i[7:0]};
assign lbu_rdata = { 56'b0,               lsu_ram_data_i[7:0]};

assign lh_rdata  = {{48{lsu_ram_data_i[15]}},lsu_ram_data_i[15:0]};
assign lhu_rdata = { 48'b0,               lsu_ram_data_i[15:0]};

assign lw_rdata  = {{32{lsu_ram_data_i[31]}},lsu_ram_data_i[31:0]};
assign lwu_rdata = { 32'b0,               lsu_ram_data_i[31:0]};

assign rdata = ({64{op_ls_lb }} & lb_rdata )
            |  ({64{op_ls_lbu}} & lbu_rdata )
            |  ({64{op_ls_lh }} & lh_rdata )
            |  ({64{op_ls_lhu}} & lhu_rdata )
            |  ({64{op_ls_lw }} & lw_rdata )
            |  ({64{op_ls_lwu}} & lwu_rdata )
            |  ({64{op_ls_ld }} & lsu_ram_data_i)
                  ;

//---------------ram port-------------
assign lsu_ram_cen_o   = (nxt_state == REQ);
assign lsu_ram_wen_o   = mem_write_i;
assign lsu_ram_addr_o  = mem_addr_i;
assign lsu_ram_wdata_o = wdata;
assign lsu_ram_size_o  = size;

//--------------cpu port------------
assign lsu_rd_wen_o    = mem_read_i ? lsu_ram_ready_i : rd_wen_i;
assign lsu_rd_addr_o   = rd_addr_i;
assign lsu_rd_data_o   = rd_data_i;
assign lsu_mem_read_o  = mem_read_i;
assign lsu_mem_rdata_o = rdata;

//-----------pipeline hold---------
assign lsu_hold_o = (nxt_state == REQ || nxt_state == WAIT);

endmodule