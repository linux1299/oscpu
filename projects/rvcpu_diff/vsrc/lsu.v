// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.09.07
// Load Store unit
// as known as "MEM"

`include "defines.v"

module lsu(
    input            clk,
    input            rst_n,

    // ls
    input     [63:0] i_mem_addr,
    input     [63:0] i_mem_wdata,
    input     [10:0] i_ls_info,
    input            i_mem_read,
    input            i_mem_write,

    // ram port
    output    [63:0] o_ram_addr,
    output           o_ram_wen,
    output           o_ram_valid,
    // ready also indicates rdata is valid
    input            i_ram_ready,
    output    [63:0] o_ram_wdata,
    output    [2:0]  o_ram_size,
    input     [63:0] i_ram_rdata,

    // wb
    input     [63:0] i_rd_data,
    input     [4:0]  i_rd_addr,
    output    [63:0] o_rd_data,
    output    [4:0]  o_rd_addr,
    output    [63:0] o_mem_rdata,
    // wb control
    input            i_rd_wen,
    output           o_rd_wen,
    output           o_mem_read,

    output           o_hold
);


wire op_ls_lb  = i_ls_info[10];
wire op_ls_lbu = i_ls_info[9];
wire op_ls_ld  = i_ls_info[8];
wire op_ls_lh  = i_ls_info[7];
wire op_ls_lhu = i_ls_info[6];
wire op_ls_lw  = i_ls_info[5];
wire op_ls_lwu = i_ls_info[4];
wire op_ls_sb  = i_ls_info[3];
wire op_ls_sd  = i_ls_info[2];
wire op_ls_sh  = i_ls_info[1];
wire op_ls_sw  = i_ls_info[0];

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

wire        i_mem_cen = i_mem_read | i_mem_write;

reg  [1:0]  state;

localparam IDLE = 2'd0;
localparam REQ  = 2'd1;
localparam WAIT = 2'd2;

//-------------State machine-----------
always @(posedge clk) begin
    if(~rst_n) begin
        state <= IDLE;
    end
    else begin
        case (state)
            IDLE : begin
                if (i_mem_cen)
                    state <= REQ;
                else
                    state <= IDLE;
                end
            REQ  : begin
                if (i_ram_ready)
                    state <= IDLE;
                else
                    state <= WAIT;
                end
            WAIT : begin
                if (i_ram_ready)
                    state <= IDLE;
                else
                    state <= WAIT;
                end
            default : state <= IDLE;
        endcase
    end
end

//---------------------------store-----------------------------
assign sb_wdata = {56'd0, i_mem_wdata[7:0]};

assign sh_wdata = {48'b0, i_mem_wdata[15:0]};

assign sw_wdata = {32'b0, i_mem_wdata[31:0]};


assign wdata = ({64{op_ls_sb}} & sb_wdata )

              |({64{op_ls_sh}} & sh_wdata )

              |({64{op_ls_sw}} & sw_wdata )

              |({64{op_ls_sd}} & i_mem_wdata)
                ;

assign size  = ({3{op_ls_sb | op_ls_lb | op_ls_lbu}} & b_size )

              |({3{op_ls_sh | op_ls_lh | op_ls_lhu}} & h_size )

              |({3{op_ls_sw | op_ls_lw | op_ls_lwu}} & w_size )

              |({3{op_ls_sd | op_ls_ld}}             & d_size)
            ;

//------------------------load----------------------------------------
assign lb_rdata  = {{56{i_ram_rdata[7]}}, i_ram_rdata[7:0]};
assign lbu_rdata = { 56'b0,               i_ram_rdata[7:0]};

assign lh_rdata  = {{48{i_ram_rdata[15]}},i_ram_rdata[15:0]};
assign lhu_rdata = { 48'b0,               i_ram_rdata[15:0]};

assign lw_rdata  = {{32{i_ram_rdata[31]}},i_ram_rdata[31:0]};
assign lwu_rdata = { 32'b0,               i_ram_rdata[31:0]};

assign rdata = ({64{op_ls_lb }} & lb_rdata )

            |  ({64{op_ls_lbu}} & lbu_rdata )

            |  ({64{op_ls_lh }} & lh_rdata )

            |  ({64{op_ls_lhu}} & lhu_rdata )

            |  ({64{op_ls_lw }} & lw_rdata )

            |  ({64{op_ls_lwu}} & lwu_rdata )

            |  ({64{op_ls_ld }} & i_ram_rdata)
                  ;


//---------------ram port-------------
assign o_ram_addr  = i_mem_addr;

assign o_ram_wen   = i_mem_write;

assign o_ram_valid = (state == REQ);

assign o_ram_wdata = wdata;

assign o_ram_size  = size;

assign o_ram_ready = 1'b1;

//--------------cpu port------------
assign o_rd_data   = i_rd_data;

assign o_rd_addr   = i_rd_addr;

assign o_rd_wen    = i_mem_read ?
                     i_ram_ready : i_rd_wen;

assign o_mem_read  = i_mem_read;

assign o_mem_rdata = rdata;

//-----------pipeline hold---------
assign o_hold = i_mem_cen & ~i_ram_ready;

endmodule