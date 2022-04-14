// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.07.21
// Registers File

`include "defines.v"

module reg_file(
    input   clk,
    input   rst_n,

    // write port
    input        wen_i,
    input [4:0]  addr_i,
    input [63:0] wdata_i,

    // read port
    input            rs1_cen_i,
    input            rs2_cen_i,
    input     [4:0]  rs1_addr_i,
    input     [4:0]  rs2_addr_i,
    output reg[63:0] rs1_rdata_o,
    output reg[63:0] rs2_rdata_o
);

reg [63:0] regs [0:31];
integer i;

//---------Write reg_file--------------
always @(posedge clk) begin
    if(~rst_n) begin
        for (i = 0; i < 32; i=i+1) begin
            regs[i] <= 64'b0;
        end
    end
    else if(wen_i & (addr_i != 5'd0)) begin
        regs[addr_i] <= wdata_i;
    end
end

//----------Read reg_file to rs1----------------
always @(*) begin
    if(rs1_addr_i == 5'b0) begin
        rs1_rdata_o = 64'b0;
    end
    else if(wen_i & (addr_i == rs1_addr_i) & rs1_cen_i) begin
        rs1_rdata_o = wdata_i;
    end
    else if(rs1_cen_i) begin
        rs1_rdata_o = regs[rs1_addr_i];
    end
    else begin
        rs1_rdata_o = 64'b0;
    end
end

//----------Read reg_file to rs2----------------
always @(*) begin
    if(rs2_addr_i == 5'b0) begin
        rs2_rdata_o = 64'b0;
    end
    else if(wen_i & (addr_i == rs2_addr_i) & rs2_cen_i) begin
        rs2_rdata_o = wdata_i;
    end
    else if(rs2_cen_i) begin
        rs2_rdata_o = regs[rs2_addr_i];
    end
    else begin
        rs2_rdata_o = 64'b0;
    end
end

endmodule