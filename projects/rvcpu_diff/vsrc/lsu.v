// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.08.18
// Load Store unit
// as known as "MEM"

`include "defines.v"

module lsu(
    input clk,
    input rst_n,

    // ls
    input  [31:0] i_mem_addr,
    input  [63:0] i_mem_wdata,
    input  [10:0] i_ls_info,
    input         i_mem_read,
    input         i_mem_write,

    // mem port
    output [31:0] o_mem_addr,
    output        o_mem_wen,
    output [63:0] o_mem_wdata,
    input  [63:0] i_mem_rdata,
    input         i_mem_valid,

    // wb
    input  [63:0] i_rd_data,
    input  [4:0]  i_rd_addr,
    output [63:0] o_rd_data,
    output [4:0]  o_rd_addr,
    output [63:0] o_mem_rdata,
    // wb control
    input         i_rd_wen,
    output        o_rd_wen,
    output        o_mem_read
);

integer i;
integer fd;
integer tmp;

reg [63:0]  mem_fd [0:65535];
reg [63:0]  mem    [0:65535];


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

wire [63:0] mem_wdata;
wire [63:0] mem_rdata;

reg  [63:0] lb_tmp;
reg  [63:0] lh_tmp;
reg  [63:0] lw_tmp;
reg  [63:0] lbu_tmp;
reg  [63:0] lhu_tmp;
reg  [63:0] lwu_tmp;

reg  [63:0] sb_tmp;
reg  [63:0] sh_tmp;
reg  [63:0] sw_tmp;
reg  [63:0] sbu_tmp;
reg  [63:0] shu_tmp;
reg  [63:0] swu_tmp;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        for (i = 0; i < 65536; i=i+1) begin
            mem[i] <= {mem_fd[i][39:32], mem_fd[i][47:40], mem_fd[i][55:48], mem_fd[i][63:56],
                       mem_fd[i][7:0],   mem_fd[i][15:8],  mem_fd[i][23:16], mem_fd[i][31:24]};
        end
    end
    else if(i_mem_write) begin
        mem[(i_mem_addr-64'h8000_0000)>>3] <= mem_wdata;
    end
end




//---------------------------store-----------------------------
assign mem_rdata = mem[(i_mem_addr-64'h8000_0000)>>3];

always @(*) begin
    case (i_mem_addr[2:0])
        3'b000  : begin
                    sb_tmp = {mem_rdata[63:40], i_mem_wdata[7:0], mem_rdata[31:0]};
                end
        3'b001  : begin
                    sb_tmp = {mem_rdata[63:48], i_mem_wdata[7:0], mem_rdata[39:0]};
                end
        3'b010  : begin
                    sb_tmp = {mem_rdata[63:56], i_mem_wdata[7:0], mem_rdata[47:0]};
                end
        3'b011  : begin
                    sb_tmp = {                  i_mem_wdata[7:0], mem_rdata[55:0]};
                end
        3'b100  : begin
                    sb_tmp = {mem_rdata[63:8],  i_mem_wdata[7:0]};
                end
        3'b101  : begin
                    sb_tmp = {mem_rdata[63:16], i_mem_wdata[7:0], mem_rdata[7:0]};
                end
        3'b110  : begin
                    sb_tmp = {mem_rdata[63:24], i_mem_wdata[7:0], mem_rdata[15:0]};
                end
        3'b111  : begin
                    sb_tmp = {mem_rdata[63:32], i_mem_wdata[7:0], mem_rdata[23:0]};
                end
        default : begin
                    sb_tmp = {mem_rdata[63:32], i_mem_wdata[7:0], mem_rdata[23:0]};
                end
    endcase
end

always @(*) begin
    case (i_mem_addr[2:1])
        2'b00  : begin
                    sh_tmp = {mem_rdata[63:48], i_mem_wdata[15:0], mem_rdata[31:0]};
                end
        2'b01  : begin
                    sh_tmp = {                  i_mem_wdata[15:0], mem_rdata[47:0]};
                end
        2'b10  : begin
                    sh_tmp = {mem_rdata[63:16], i_mem_wdata[15:0]};
                end
        2'b11  : begin
                    sh_tmp = {mem_rdata[63:32], i_mem_wdata[15:0], mem_rdata[15:0]};
                end
        default : begin
                    sh_tmp = {mem_rdata[63:32], i_mem_wdata[15:0], mem_rdata[15:0]};
               end
    endcase
end

always @(*) begin
    case (i_mem_addr[2])
        1'b0 : begin
                sw_tmp = {i_mem_wdata[31:0], mem_rdata[31:0]};
            end
        1'b1 : begin
                sw_tmp = {mem_rdata[63:32], i_mem_wdata[31:0]};
            end
        default : begin
                sw_tmp = {mem_rdata[63:32], i_mem_wdata[31:0]};
            end
    endcase
end


assign mem_wdata   = ({64{op_ls_sb}} & sb_tmp )

                    |({64{op_ls_sh}} & sh_tmp )

                    |({64{op_ls_sw}} & sw_tmp )

                    |({64{op_ls_sd}} & {i_mem_wdata[31:0], i_mem_wdata[63:32]})
                    ;


//------------------------load----------------------------------------
always @(*) begin
    case (i_mem_addr[2:0])
        3'b000  : begin
                  lb_tmp  = {{56{mem_rdata[39]}},mem_rdata[32+7:32+0]};
                  lbu_tmp = { 56'b0,             mem_rdata[32+7:32+0]};
                end
        3'b001  : begin
                  lb_tmp  = {{56{mem_rdata[47]}},mem_rdata[32+15:32+8]};
                  lbu_tmp = { 56'b0,             mem_rdata[32+15:32+8]};
                end
        3'b010  : begin
                  lb_tmp  = {{56{mem_rdata[55]}},mem_rdata[32+23:32+16]};
                  lbu_tmp = { 56'b0,             mem_rdata[32+23:32+16]};
                end
        3'b011  : begin
                  lb_tmp  = {{56{mem_rdata[63]}},mem_rdata[32+31:32+24]};
                  lbu_tmp = { 56'b0,             mem_rdata[32+31:32+24]};
                end
        3'b100  : begin
                  lb_tmp  = {{56{mem_rdata[7]}}, mem_rdata[7:0]};
                  lbu_tmp = { 56'b0,             mem_rdata[7:0]};
                end
        3'b101  : begin
                  lb_tmp  = {{56{mem_rdata[15]}},mem_rdata[15:8]};
                  lbu_tmp = { 56'b0,             mem_rdata[15:8]};
                end
        3'b110  : begin
                  lb_tmp  = {{56{mem_rdata[23]}},mem_rdata[23:16]};
                  lbu_tmp = { 56'b0,             mem_rdata[23:16]};
                end
        3'b111  : begin
                  lb_tmp  = {{56{mem_rdata[31]}},mem_rdata[31:24]};
                  lbu_tmp = { 56'b0,             mem_rdata[31:24]};
                end
        default : begin
                  lb_tmp  = {{56{mem_rdata[31]}},mem_rdata[31:24]};
                  lbu_tmp = { 56'b0,             mem_rdata[31:24]};
                end
    endcase
end

always @(*) begin
    case (i_mem_addr[2:1])
        2'b00  : begin
                  lh_tmp  = {{48{mem_rdata[47]}},mem_rdata[32+15:32+0]};
                  lhu_tmp = { 48'b0,             mem_rdata[32+15:32+0]};
                end
        2'b01  : begin
                  lh_tmp  = {{48{mem_rdata[63]}},mem_rdata[32+31:32+16]};
                  lhu_tmp = { 48'b0,             mem_rdata[32+31:32+16]};
                end
        2'b10  : begin
                  lh_tmp  = {{48{mem_rdata[15]}},mem_rdata[15:0]};
                  lhu_tmp = { 48'b0,             mem_rdata[15:0]};
                end
        2'b11  : begin
                  lh_tmp  = {{48{mem_rdata[31]}},mem_rdata[31:16]};
                  lhu_tmp = { 48'b0,             mem_rdata[31:16]};
                end
        default : begin
                  lh_tmp  = {{48{mem_rdata[31]}},mem_rdata[31:16]};
                  lhu_tmp = { 48'b0,             mem_rdata[31:16]};
                end
    endcase
end

always @(*) begin
    case (i_mem_addr[2])
        1'b0  : begin
                  lw_tmp  = {{32{mem_rdata[63]}},mem_rdata[32+31:32+0]};
                  lwu_tmp = { 32'b0,             mem_rdata[32+31:32+0]};
                end
        1'b1  : begin
                  lw_tmp  = {{32{mem_rdata[31]}},mem_rdata[31:0]};
                  lwu_tmp = { 32'b0,             mem_rdata[31:0]};
                end
        default : begin
                  lw_tmp  = {{32{mem_rdata[31]}},mem_rdata[31:0]};
                  lwu_tmp = { 32'b0,             mem_rdata[31:0]};
                end
    endcase
end


//---------------output---------------------
assign o_rd_data   = i_rd_data;
assign o_mem_rdata = ({64{op_ls_lb }} & lb_tmp )

                  |  ({64{op_ls_lbu}} & lbu_tmp )

                  |  ({64{op_ls_lh }} & lh_tmp )

                  |  ({64{op_ls_lhu}} & lhu_tmp )

                  |  ({64{op_ls_lw }} & lw_tmp )

                  |  ({64{op_ls_lwu}} & lwu_tmp )

                  |  ({64{op_ls_ld }} & {mem_rdata[31:0], mem_rdata[63:32]})
                  ;

assign o_rd_addr   = i_rd_addr;
assign o_rd_wen    = i_rd_wen;
assign o_mem_read  = i_mem_read;

endmodule // lsu