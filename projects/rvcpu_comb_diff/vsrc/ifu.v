// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.08.18
// Instruction Fetch unit

`include "defines.v"

module ifu(
    input            clk,
    input            rst_n,

    // ram port
    output reg[63:0] o_ram_addr,
    output reg       o_ram_valid,
    // ready also indicates rdata is valid
    input            i_ram_ready,
    input     [31:0] i_ram_rdata,
    output    [2:0]  o_ram_size,

    // cpu port
    input            i_branch_jump,
    input            i_hold,
    input     [63:0] i_next_pc,
    output    [31:0] o_instr,
    output           o_instr_valid,
    output    [63:0] o_pc,

    // clint port
    input            i_int_valid,
    input     [63:0] i_int_addr
);


//--------------output----------------------
always @(posedge clk) begin
    if(~rst_n) begin
        o_ram_addr <= `PC_START;
    end

    else if(i_hold) begin
        o_ram_addr <= o_ram_addr;
    end

    else if (i_int_valid) begin
        o_ram_addr <= i_int_addr;
    end

    else if(i_branch_jump) begin
        o_ram_addr <= i_next_pc;
    end

    // wait for ready
    else if(i_ram_ready) begin
        o_ram_addr <= o_ram_addr + 4;
    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        o_ram_valid <= 0;
    end
    else if (~i_hold) begin
        o_ram_valid <= 1;
    end
end

assign o_ram_size    = 3'b010;

assign o_pc          = o_ram_addr;

assign o_instr       = i_ram_rdata;

assign o_instr_valid = i_ram_ready & ~i_hold;

endmodule