`timescale 1ns / 1ps

//--------Instruction type---------

// R type
`define INSTR_R      7'b0110011

// Imm
`define INSTR_I      7'b0010011

// S type
`define INSTR_S      7'b0100011

// B type
`define INSTR_B      7'b1100011

// Jump and Link
`define INSTR_JAL    7'b1101111
`define INSTR_JALR   7'b1100111

// Load
`define INSTR_L      7'b0000011

// Load upper immediate
`define INSTR_LUI    7'b0110111

// Add upper immediate to pc
`define INSTR_AUIPC  7'b0010111

// other
`define INSTR_FENCE  7'b0001111
`define INSTR_CSR    7'b1110011

// ALU word op
`define INSTR_WORD   7'b0111011
`define INSTR_WORDI  7'b0011011