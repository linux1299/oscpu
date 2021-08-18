`include "defines.v"

module tb_rvcpu;

reg clk;
reg rst_n;

wire         o_instr_cen;   // instr chip enable
wire [63:0]  o_instr_addr;  // instr addr
reg  [31:0]  i_instr;       // instruction
wire         i_instr_valid; // instr is valid

wire         o_mem_cen;    // data memory chip enable
wire         o_mem_wen;    // data memory write enable
wire [31:0]  o_mem_addr;   // data memory addr
wire [63:0]  o_mem_wdata;  // data memory write data
wire [63:0]  i_mem_rdata;  // read data from mem
wire         i_mem_rdata_valid; //read data is valid

reg  [31:0]  instr_regs [0:1023];


always #5 clk = ~clk;

initial begin
    clk = 1'b0;
    rst_n = 1'b1;
    #5
    rst_n = 1'b0;
    #15
    rst_n = 1'b1;
    #2000000
    $stop;
end

always @(*) begin
    if(~rst_n) begin
    end
    else if(o_instr_cen) begin
        i_instr = instr_regs[(o_instr_addr-64'h8000_0000) >> 2];
    end
end

rvcpu u_rvcpu(
    .clk           ( clk           ),
    .rst_n         ( rst_n         ),
    .o_instr_cen   ( o_instr_cen   ),
    .o_instr_addr  ( o_instr_addr  ),
    .i_instr       ( i_instr       ),
    .i_instr_valid ( i_instr_valid ),
    .o_mem_cen     ( o_mem_cen     ),
    .o_mem_wen     ( o_mem_wen     ),
    .o_mem_addr    ( o_mem_addr    ),
    .o_mem_wdata   ( o_mem_wdata   ),
    .i_mem_rdata   ( 64'b0   ),
    .i_mem_rdata_valid  ( 1'b0  )
);


endmodule