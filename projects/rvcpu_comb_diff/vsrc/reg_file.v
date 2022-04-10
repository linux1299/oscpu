// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.07.21
// Registers File

`include "defines.v"

module reg_file(
    input   clk,
    input   rst_n,

    // write port
    input        i_wen,
    input [4:0]  i_addr,
    input [63:0] i_wdata,

    // read port
    input     [4:0]  i_rs1_addr,
    input     [4:0]  i_rs2_addr,
    input            i_rs1_cen,
    input            i_rs2_cen,
    output reg[63:0] o_rs1_rdata,
    output reg[63:0] o_rs2_rdata,

    // difftest
    output    [63:0] regs_o[0:31]
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
    else if(i_wen & (i_addr != 5'd0)) begin
        regs[i_addr] <= i_wdata;
    end
end

//----------Read reg_file to rs1----------------
always @(*) begin
    if(i_rs1_addr == 5'b0) begin
        o_rs1_rdata = 64'b0;
    end
    else if(i_wen & (i_addr == i_rs1_addr) & i_rs1_cen) begin
        o_rs1_rdata = i_wdata;
    end
    else if(i_rs1_cen) begin
        o_rs1_rdata = regs[i_rs1_addr];
    end
    else begin
        o_rs1_rdata = 64'b0;
    end
end

//----------Read reg_file to rs2----------------
always @(*) begin
    if(i_rs2_addr == 5'b0) begin
        o_rs2_rdata = 64'b0;
    end
    else if(i_wen & (i_addr == i_rs2_addr) & i_rs2_cen) begin
        o_rs2_rdata = i_wdata;
    end
    else if(i_rs2_cen) begin
        o_rs2_rdata = regs[i_rs2_addr];
    end
    else begin
        o_rs2_rdata = 64'b0;
    end
end

//------------difftest--------------
genvar j;
generate
	for (j = 0; j < 32; j = j + 1) begin
		assign regs_o[j] = (i_wen & i_addr == j & j != 0) ? i_wdata : regs[j];
	end
endgenerate

endmodule