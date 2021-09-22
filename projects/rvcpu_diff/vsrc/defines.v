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

// fence
`define INSTR_FENCE  7'b0001111

// System
`define INSTR_SYS    7'b1110011

// ALU word op
`define INSTR_WORD   7'b0111011
`define INSTR_WORDI  7'b0011011

// CSR addr
`define ADDR_MSTATUS  12'h300
`define ADDR_MIE      12'h304
`define ADDR_MTVEC    12'h305
`define ADDR_MEPC     12'h341
`define ADDR_MCAUSE   12'h342
`define ADDR_MTVAL    12'h343
`define ADDR_MIP      12'h344
`define ADDR_MCYCLE   12'hb00
`define ADDR_MHARTID  12'hf14

`define ADDR_MTIMECMP 64'h200_4000
`define ADDR_MTIME    64'h200_bff8

// AXI
`define RW_DATA_WIDTH   64
`define RW_ADDR_WIDTH   64
`define AXI_DATA_WIDTH  64
`define AXI_ADDR_WIDTH  64
`define AXI_ID_WIDTH    4
`define AXI_USER_WIDTH  1

// PC
`define PC_START        64'h30000_0000

// priv mode
`define RISCV_PRIV_MODE_U   0
`define RISCV_PRIV_MODE_S   1
`define RISCV_PRIV_MODE_M   3