// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.07.18
// Instruction Fetch unit

`include "defines.v"

module ifu(
    input         clk,
    input         rst_n,

    output [63:0] o_instr_addr,
    output        o_instr_cen,

    input         i_branch_jump,
    input         i_hold,
    input  [63:0] i_next_pc

);

reg [63:0] pc;

//---------fetch an instruction------
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        pc <= 64'h8000_0000;
    end
    else if(i_hold) begin
        pc <= pc;
    end
    else if(i_branch_jump) begin
        pc <= i_next_pc;
    end
    else begin
        pc <= pc + 4;
    end
end

assign o_instr_addr = pc;
assign o_instr_cen  = 1'b1;


endmodule