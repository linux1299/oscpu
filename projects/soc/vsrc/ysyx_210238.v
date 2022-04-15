

/* verilator lint_off EOFNEWLINE */

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
`define ADDR_MSCRATCH 12'h340
`define ADDR_MTIMECMP 64'h200_4000
`define ADDR_MTIME    64'h200_bff8

// AXI
`define RW_DATA_WIDTH   64
`define RW_ADDR_WIDTH   64
`define AXI_DATA_WIDTH  64
`define AXI_ADDR_WIDTH  64
`define AXI_ID_WIDTH    4
`define AXI_USER_WIDTH  1

// Burst types
`define AXI_BURST_TYPE_FIXED                                2'b00
`define AXI_BURST_TYPE_INCR                                 2'b01
`define AXI_BURST_TYPE_WRAP                                 2'b10

// Access permissions
`define AXI_PROT_UNPRIVILEGED_ACCESS                        3'b000
`define AXI_PROT_PRIVILEGED_ACCESS                          3'b001
`define AXI_PROT_SECURE_ACCESS                              3'b000
`define AXI_PROT_NON_SECURE_ACCESS                          3'b010
`define AXI_PROT_DATA_ACCESS                                3'b000
`define AXI_PROT_INSTRUCTION_ACCESS                         3'b100

// Memory types (AR)
`define AXI_ARCACHE_DEVICE_NON_BUFFERABLE                   4'b0000
`define AXI_ARCACHE_DEVICE_BUFFERABLE                       4'b0001
`define AXI_ARCACHE_NORMAL_NON_CACHEABLE_NON_BUFFERABLE     4'b0010
`define AXI_ARCACHE_NORMAL_NON_CACHEABLE_BUFFERABLE         4'b0011
`define AXI_ARCACHE_WRITE_THROUGH_NO_ALLOCATE               4'b1010
`define AXI_ARCACHE_WRITE_THROUGH_READ_ALLOCATE             4'b1110
`define AXI_ARCACHE_WRITE_THROUGH_WRITE_ALLOCATE            4'b1010
`define AXI_ARCACHE_WRITE_THROUGH_READ_AND_WRITE_ALLOCATE   4'b1110
`define AXI_ARCACHE_WRITE_BACK_NO_ALLOCATE                  4'b1011
`define AXI_ARCACHE_WRITE_BACK_READ_ALLOCATE                4'b1111
`define AXI_ARCACHE_WRITE_BACK_WRITE_ALLOCATE               4'b1011
`define AXI_ARCACHE_WRITE_BACK_READ_AND_WRITE_ALLOCATE      4'b1111

// Memory types (AW)
`define AXI_AWCACHE_DEVICE_NON_BUFFERABLE                   4'b0000
`define AXI_AWCACHE_DEVICE_BUFFERABLE                       4'b0001
`define AXI_AWCACHE_NORMAL_NON_CACHEABLE_NON_BUFFERABLE     4'b0010
`define AXI_AWCACHE_NORMAL_NON_CACHEABLE_BUFFERABLE         4'b0011
`define AXI_AWCACHE_WRITE_THROUGH_NO_ALLOCATE               4'b0110
`define AXI_AWCACHE_WRITE_THROUGH_READ_ALLOCATE             4'b0110
`define AXI_AWCACHE_WRITE_THROUGH_WRITE_ALLOCATE            4'b1110
`define AXI_AWCACHE_WRITE_THROUGH_READ_AND_WRITE_ALLOCATE   4'b1110
`define AXI_AWCACHE_WRITE_BACK_NO_ALLOCATE                  4'b0111
`define AXI_AWCACHE_WRITE_BACK_READ_ALLOCATE                4'b0111
`define AXI_AWCACHE_WRITE_BACK_WRITE_ALLOCATE               4'b1111
`define AXI_AWCACHE_WRITE_BACK_READ_AND_WRITE_ALLOCATE      4'b1111

`define AXI_SIZE_BYTES_1                                    3'b000
`define AXI_SIZE_BYTES_2                                    3'b001
`define AXI_SIZE_BYTES_4                                    3'b010
`define AXI_SIZE_BYTES_8                                    3'b011
`define AXI_SIZE_BYTES_16                                   3'b100
`define AXI_SIZE_BYTES_32                                   3'b101
`define AXI_SIZE_BYTES_64                                   3'b110
`define AXI_SIZE_BYTES_128                                  3'b111


// PC
`define PC_START        64'h3000_0000

`timescale 1ns/1ns

// priv mode
`define RISCV_PRIV_MODE_U   0
`define RISCV_PRIV_MODE_S   1
`define RISCV_PRIV_MODE_M   3/

module ysyx_210238 (
    input         clock,
    input         reset,

    /* verilator lint_off UNUSED */
    input         io_interrupt,
    input         io_master_awready,
    output        io_master_awvalid,
    output [31:0] io_master_awaddr,
    output [3:0]  io_master_awid,
    output [7:0]  io_master_awlen,
    output [2:0]  io_master_awsize,
    output [1:0]  io_master_awburst,
    input         io_master_wready,
    output        io_master_wvalid,
    output [63:0] io_master_wdata,
    output [7:0]  io_master_wstrb,
    output        io_master_wlast,
    output        io_master_bready,
    input         io_master_bvalid,
    input  [1:0]  io_master_bresp,
    input  [3:0]  io_master_bid,
    input         io_master_arready,
    output        io_master_arvalid,
    output [31:0] io_master_araddr,
    output [3:0]  io_master_arid,
    output [7:0]  io_master_arlen,
    output [2:0]  io_master_arsize,
    output [1:0]  io_master_arburst,
    output        io_master_rready,
    input         io_master_rvalid,
    input  [1:0]  io_master_rresp,
    input  [63:0] io_master_rdata,
    input         io_master_rlast,
    input  [3:0]  io_master_rid,
    
    output        io_slave_awready,
    input         io_slave_awvalid,
    input  [31:0] io_slave_awaddr,
    input  [3:0]  io_slave_awid,
    input  [7:0]  io_slave_awlen,
    input  [2:0]  io_slave_awsize,
    input  [1:0]  io_slave_awburst,
    output        io_slave_wready,
    input         io_slave_wvalid,
    input  [63:0] io_slave_wdata,
    input  [7:0]  io_slave_wstrb,
    input         io_slave_wlast,
    input         io_slave_bready,
    output        io_slave_bvalid,
    output [1:0]  io_slave_bresp,
    output [3:0]  io_slave_bid,
    output        io_slave_arready,
    input         io_slave_arvalid,
    input  [31:0] io_slave_araddr,
    input  [3:0]  io_slave_arid,
    input  [7:0]  io_slave_arlen,
    input  [2:0]  io_slave_arsize,
    input  [1:0]  io_slave_arburst,
    input         io_slave_rready,
    output        io_slave_rvalid,
    output [1:0]  io_slave_rresp,
    output [63:0] io_slave_rdata,
    output        io_slave_rlast,
    output [3:0]  io_slave_rid
);  

wire clk = clock;
wire rst_n = ~reset;

assign io_slave_awready = 1'b0;
assign io_slave_wready  = 1'b0;
assign io_slave_bvalid  = 1'b0;
assign io_slave_bresp   = 2'b00;
assign io_slave_bid     = 4'b0000;
assign io_slave_arready = 1'b0;
assign io_slave_rvalid  = 1'b0;
assign io_slave_rresp   = 2'b00;
assign io_slave_rdata   = 64'd0;
assign io_slave_rlast   = 1'b0;
assign io_slave_rid     = 4'b0000;

wire axi_aw_lock_o  ;
wire [3:0] axi_aw_cache_o ;
wire [2:0] axi_aw_prot_o  ;
wire [3:0] axi_aw_qos_o   ;
wire [3:0] axi_aw_region_o;
wire axi_aw_user_o  ;
wire axi_w_user_o   ;
wire [2:0] axi_ar_prot_o  ;
wire axi_ar_user_o  ;
wire axi_ar_lock_o  ; 
wire [3:0] axi_ar_cache_o ;
wire [3:0] axi_ar_qos_o   ; 
wire [3:0] axi_ar_region_o;

ysyx_210238_rvcpu_axi u_rvcpu_axi(
    .clk             ( clk             ),
    .rst_n           ( rst_n           ),
    .axi_aw_id_o     ( io_master_awid ),
    .axi_aw_addr_o   ( io_master_awaddr ),
    .axi_aw_len_o    ( io_master_awlen ),
    .axi_aw_size_o   ( io_master_awsize ),
    .axi_aw_burst_o  ( io_master_awburst ),
    .axi_aw_lock_o   ( axi_aw_lock_o   ),
    .axi_aw_cache_o  ( axi_aw_cache_o  ),
    .axi_aw_prot_o   ( axi_aw_prot_o   ),
    .axi_aw_qos_o    ( axi_aw_qos_o    ),
    .axi_aw_region_o ( axi_aw_region_o ),
    .axi_aw_user_o   ( axi_aw_user_o   ),
    .axi_aw_valid_o  ( io_master_awvalid ),
    .axi_aw_ready_i  ( io_master_awready ),
    .axi_w_ready_i   ( io_master_wready ),
    .axi_w_valid_o   ( io_master_wvalid ),
    .axi_w_data_o    ( io_master_wdata ),
    .axi_w_strb_o    ( io_master_wstrb ),
    .axi_w_last_o    ( io_master_wlast ),
    .axi_w_user_o    ( axi_w_user_o ),
    .axi_b_ready_o   ( io_master_bready ),
    .axi_b_valid_i   ( io_master_bvalid ),
    .axi_b_resp_i    ( io_master_bresp ),
    .axi_b_id_i      ( io_master_bid ),
    .axi_b_user_i    ( 1'b0 ),
    .axi_ar_ready_i  ( io_master_arready ),
    .axi_ar_valid_o  ( io_master_arvalid ),
    .axi_ar_addr_o   ( io_master_araddr ),
    .axi_ar_prot_o   ( axi_ar_prot_o ),
    .axi_ar_id_o     ( io_master_arid ),
    .axi_ar_user_o   ( axi_ar_user_o ),
    .axi_ar_len_o    ( io_master_arlen ),
    .axi_ar_size_o   ( io_master_arsize ),
    .axi_ar_burst_o  ( io_master_arburst ),
    .axi_ar_lock_o   ( axi_ar_lock_o   ),
    .axi_ar_cache_o  ( axi_ar_cache_o  ),
    .axi_ar_qos_o    ( axi_ar_qos_o    ),
    .axi_ar_region_o ( axi_ar_region_o ),
    .axi_r_ready_o   ( io_master_rready ),
    .axi_r_valid_i   ( io_master_rvalid ),
    .axi_r_resp_i    ( io_master_rresp ),
    .axi_r_data_i    ( io_master_rdata ),
    .axi_r_last_i    ( io_master_rlast ),
    .axi_r_id_i      ( io_master_rid ),
    .axi_r_user_i    ( 1'b0 )
);


endmodule




module ysyx_210238_axi_master_if # (
    parameter RW_DATA_WIDTH     = 64,
    parameter RW_ADDR_WIDTH     = 64,
    parameter AXI_DATA_WIDTH    = 64,
    parameter AXI_ADDR_WIDTH    = 64,
    parameter AXI_ID_WIDTH      = 4,
    parameter AXI_USER_WIDTH    = 1
)(
    input                               clk,
    input                               rst_n,

    // user port
    input                               rw_id_i,
    input                               rw_cen_i,
    input                               rw_wen_i,
    input  [RW_ADDR_WIDTH-1:0]          rw_addr_i,
    input  [2:0]                        rw_size_i,
    input  [RW_DATA_WIDTH-1:0]          rw_wdata_i,
    input  [7:0]                        rw_wmask_i,
    output                              rw_ready_o,
    output [RW_DATA_WIDTH-1:0]          rw_rdata_o,
    output [1:0]                        rw_resp_o,

    //------------AXI port-------------------------
    // write address channel
    output [AXI_ID_WIDTH-1:0]           axi_aw_id_o,
    output [AXI_ADDR_WIDTH-1:0]         axi_aw_addr_o,
    output [7:0]                        axi_aw_len_o,
    output [2:0]                        axi_aw_size_o,
    output [1:0]                        axi_aw_burst_o,
    output                              axi_aw_lock_o,
    output [3:0]                        axi_aw_cache_o,
    output [2:0]                        axi_aw_prot_o,
    output [3:0]                        axi_aw_qos_o,
    output [3:0]                        axi_aw_region_o,
    output [AXI_USER_WIDTH-1:0]         axi_aw_user_o,
    output                              axi_aw_valid_o,
    input                               axi_aw_ready_i,

    // write data channel
    input                               axi_w_ready_i,
    output                              axi_w_valid_o,
    output [AXI_DATA_WIDTH-1:0]         axi_w_data_o,
    output [AXI_DATA_WIDTH/8-1:0]       axi_w_strb_o,
    output                              axi_w_last_o,
    output [AXI_USER_WIDTH-1:0]         axi_w_user_o,

    // write response channel
    output                              axi_b_ready_o,
    input                               axi_b_valid_i,
    input  [1:0]                        axi_b_resp_i,
    input  [AXI_ID_WIDTH-1:0]           axi_b_id_i,
    input  [AXI_USER_WIDTH-1:0]         axi_b_user_i,

    // read address channel
    input                               axi_ar_ready_i,
    output                              axi_ar_valid_o,
    output [AXI_ADDR_WIDTH-1:0]         axi_ar_addr_o,
    output [2:0]                        axi_ar_prot_o,
    output [AXI_ID_WIDTH-1:0]           axi_ar_id_o,
    output [AXI_USER_WIDTH-1:0]         axi_ar_user_o,
    output [7:0]                        axi_ar_len_o,
    output [2:0]                        axi_ar_size_o,
    output [1:0]                        axi_ar_burst_o,
    output                              axi_ar_lock_o,
    output [3:0]                        axi_ar_cache_o,
    output [3:0]                        axi_ar_qos_o,
    output [3:0]                        axi_ar_region_o,

    // read data channel
    output                              axi_r_ready_o,
    input                               axi_r_valid_i,
    input  [1:0]                        axi_r_resp_i,
    input  [AXI_DATA_WIDTH-1:0]         axi_r_data_i,
    input                               axi_r_last_i,
    input  [AXI_ID_WIDTH-1:0]           axi_r_id_i,
    input  [AXI_USER_WIDTH-1:0]         axi_r_user_i
);

assign axi_ar_region_o = 4'd0;

wire w_trans    = rw_wen_i;
wire r_trans    = ~rw_wen_i;
wire w_valid    = rw_cen_i & w_trans;
wire r_valid    = rw_cen_i & r_trans;

// handshake
wire aw_hs      = axi_aw_ready_i & axi_aw_valid_o;
wire w_hs       = axi_w_ready_i  & axi_w_valid_o;
wire b_hs       = axi_b_ready_o  & axi_b_valid_i;
wire ar_hs      = axi_ar_ready_i & axi_ar_valid_o;
wire r_hs       = axi_r_ready_o  & axi_r_valid_i;

wire w_done     = w_hs & axi_w_last_o;
wire r_done     = r_hs & axi_r_last_i;
wire trans_done = w_trans ? b_hs : r_done;


// ------------------State Machine------------------
localparam [2:0] W_STATE_IDLE  = 3'b000;
localparam [2:0] W_STATE_ADDR  = 3'b001;
localparam [2:0] W_STATE_WRITE = 3'b010;
localparam [2:0] W_STATE_RESP  = 3'b011;
localparam [2:0] W_STATE_DONE  = 3'b100;

localparam [1:0] R_STATE_IDLE  = 2'b00;
localparam [1:0] R_STATE_ADDR  = 2'b01;
localparam [1:0] R_STATE_READ  = 2'b10;
localparam [1:0] R_STATE_DONE  = 2'b11;

reg [2:0] w_state;
reg [1:0] r_state;

wire w_state_idle  = w_state == W_STATE_IDLE;
wire w_state_addr  = w_state == W_STATE_ADDR;
wire w_state_write = w_state == W_STATE_WRITE;
wire w_state_resp  = w_state == W_STATE_RESP;
wire w_state_done  = w_state == W_STATE_DONE;

wire r_state_idle  = r_state == R_STATE_IDLE;
wire r_state_addr  = r_state == R_STATE_ADDR;
wire r_state_read  = r_state == R_STATE_READ;
wire r_state_done  = r_state == R_STATE_DONE;

// ------------ Wirte State Machine --------------
always @(posedge clk) begin
    if (~rst_n) begin
        w_state <= W_STATE_IDLE;
    end
    else begin
        if (w_valid) begin
            case (w_state)
                W_STATE_IDLE:               w_state <= W_STATE_ADDR;
                W_STATE_ADDR:  if (aw_hs)   w_state <= W_STATE_WRITE;
                W_STATE_WRITE: if (w_done)  w_state <= W_STATE_RESP;
                W_STATE_RESP:  if (b_hs)    w_state <= W_STATE_DONE;
                W_STATE_DONE:               w_state <= W_STATE_IDLE;
                default     :               w_state <= w_state;
            endcase
        end
    end
end

// ----------------- Read State Machine ----------------
always @(posedge clk) begin
    if (~rst_n) begin
        r_state <= R_STATE_IDLE;
    end
    else begin
        if (r_valid) begin
            case (r_state)
                R_STATE_IDLE:               r_state <= R_STATE_ADDR;
                R_STATE_ADDR: if (ar_hs)    r_state <= R_STATE_READ;
                R_STATE_READ: if (r_done)   r_state <= R_STATE_DONE;
                R_STATE_DONE:               r_state <= R_STATE_IDLE;
                default     :               r_state <= r_state;
            endcase
        end
    end
end




// ------------------Write Transaction------------------
// Write address channel signals
wire [AXI_ID_WIDTH-1:0]   axi_id   = {AXI_ID_WIDTH{1'b0}};
wire [AXI_USER_WIDTH-1:0] axi_user = {AXI_USER_WIDTH{1'b0}};
assign axi_aw_id_o      = axi_id;
assign axi_aw_addr_o    = rw_addr_i;
assign axi_aw_len_o     = 8'd0;
// assign axi_aw_size_o    = rw_size_i;
assign axi_aw_size_o    = (axi_aw_addr_o <  32'h01ff_ffff) ? 3'b010 : // reserve
                          (axi_aw_addr_o >= 32'h1000_0000 && axi_aw_addr_o <= 32'h1000_0fff) ? 3'b000 : // UART
                          (axi_aw_addr_o >= 32'h1000_1000 && axi_aw_addr_o <= 32'h1000_1fff) ? 3'b010 : // SPI
                          (axi_aw_addr_o >= 32'h3000_0000 && axi_aw_addr_o <= 32'h3fff_ffff) ? 3'b010 : rw_size_i;
assign axi_aw_burst_o   = `AXI_BURST_TYPE_FIXED;
assign axi_aw_lock_o    = 1'b0;
assign axi_aw_cache_o   = `AXI_ARCACHE_NORMAL_NON_CACHEABLE_NON_BUFFERABLE;
assign axi_aw_prot_o    = `AXI_PROT_UNPRIVILEGED_ACCESS;
assign axi_aw_qos_o     = 4'h0;
assign axi_aw_region_o  = 4'h0;
assign axi_aw_user_o    = axi_user;
assign axi_aw_valid_o   = w_state_addr;

// Write data channel signals
assign axi_w_valid_o    = w_state_write;
assign axi_w_data_o     = rw_wdata_i;
assign axi_w_strb_o     = rw_wmask_i;
assign axi_w_last_o     = w_state_write;
assign axi_w_user_o     = axi_user;

// Write resp channel signals
assign axi_b_ready_o    = w_state_resp;


// ------------------Read Transaction------------------
// Read address channel signals
assign axi_ar_valid_o   = r_state_addr;
assign axi_ar_addr_o    = rw_addr_i;
assign axi_ar_prot_o    = `AXI_PROT_UNPRIVILEGED_ACCESS;
assign axi_ar_id_o      = axi_id;
assign axi_ar_user_o    = axi_user;
assign axi_ar_len_o     = 8'd0;
assign axi_ar_size_o    = (axi_aw_addr_o >= 32'h1000_0000 && axi_aw_addr_o <= 32'h1000_0fff) ? 3'b000 : // UART
                          (axi_aw_addr_o >= 32'h1000_1000 && axi_aw_addr_o <= 32'h1000_1fff) ? 3'b010 : // SPI
                          (axi_aw_addr_o >= 32'h3000_0000 && axi_aw_addr_o <= 32'h3fff_ffff) ? 3'b010 : rw_size_i;
assign axi_ar_burst_o   = `AXI_BURST_TYPE_FIXED;
assign axi_ar_lock_o    = 1'b0;
assign axi_ar_cache_o   = `AXI_ARCACHE_NORMAL_NON_CACHEABLE_NON_BUFFERABLE;
assign axi_ar_qos_o     = 4'h0;

// Read data channel signals
assign axi_r_ready_o    = r_state_read;


// ------------------User Ports------------------
assign rw_rdata_o = axi_r_data_i;

// reg  rw_ready;
// always @(posedge clk) begin
//     if (~rst_n) begin
//         rw_ready <= 0;
//     end
//     else if (trans_done) begin
//         rw_ready <= 1;
//     end
//     else begin
//         rw_ready <= 0;
//     end
// end
assign rw_ready_o = trans_done;

// reg [1:0] rw_resp;
// wire      rw_resp_next = w_trans ? axi_b_resp_i : axi_r_resp_i;
// always @(posedge clk) begin
//     if (~rst_n) begin
//         rw_resp <= 0;
//     end
//     else if (trans_done) begin
//         rw_resp <= rw_resp_next;
//     end
//     else begin
//         rw_resp <= 0;
//     end
// end
assign rw_resp_o = 2'b00;


endmodule

 

module ysyx_210238_clint (
    input             clk,
    input             rst_n,

    // timer port
    input             timer_int_i,

    // idu port
    input      [63:0] pc_i,
    input             jump_i,
    input      [63:0] jump_pc_i,
    input      [2:0]  expt_info_i,
    output reg [63:0] clint_int_addr_o,
    output reg        clint_int_valid_o,
    output            clint_hold_o,

    // csr port
    input             global_int_en_i,
    input             mtime_int_en_i,
    input             mtime_int_pend_i,

    input      [63:0] csr_mtvec_i,
    input      [63:0] csr_mepc_i,
    input      [63:0] csr_mstatus_i,

    output reg        clint_mepc_wen_o,
    output reg [63:0] clint_mepc_wdata_o,

    output reg        clint_mcause_wen_o,
    output reg [63:0] clint_mcause_wdata_o,

    output reg        clint_mstatus_wen_o,
    output reg [63:0] clint_mstatus_wdata_o

);

//-------Exception or Interrupt Sate-----
localparam INT_IDLE = 0;
localparam INT_EXPT = 1;
localparam INT_TIME = 2;
localparam INT_MRET = 3;

//-------Write CSR state-----------
localparam CSR_IDLE    = 0;
localparam CSR_MEPC_MCAUSE_MSTATUS = 1;
localparam CSR_MRET    = 2;

reg  [1:0]  int_state;
reg  [2:0]  csr_state;
reg  [63:0] mepc_wdata;
reg  [63:0] mcause_wdata;

wire op_ecall   = expt_info_i[2];
wire op_ebreak  = expt_info_i[1];
wire op_mret    = expt_info_i[0];



//------Exception or Interrupt Sate transition----
always @(*) begin
    if(op_ecall || op_ebreak) begin
        int_state = INT_EXPT; // envirionment call or break
    end
    else if (global_int_en_i &&
                ((timer_int_i && mtime_int_en_i) ||
                 (timer_int_i && mtime_int_pend_i)) ) begin

        int_state = INT_TIME; // timer interrupt
    end
    else if (op_mret) begin
        int_state = INT_MRET; // machine return
    end
    else begin
        int_state = INT_IDLE;
    end
end

//-------Write CSR state transition---------
always @(posedge clk) begin
    if(~rst_n) begin
        csr_state <= CSR_IDLE;
    end
    else begin
        case (csr_state)
            CSR_IDLE : begin
                if (int_state == INT_EXPT)
                    csr_state <= CSR_MEPC_MCAUSE_MSTATUS;

                else if (int_state == INT_TIME)
                    csr_state <= CSR_MEPC_MCAUSE_MSTATUS;

                else if (int_state == INT_MRET)
                    csr_state <= CSR_MRET;
            end

            CSR_MEPC_MCAUSE_MSTATUS :
                    csr_state <= CSR_IDLE;

            CSR_MRET :
                    csr_state <= CSR_IDLE;

            default :
                    csr_state <= CSR_IDLE;
        endcase
    end
end

//--------mepc mcause wdata------
always @(posedge clk) begin
    if(~rst_n) begin
        mepc_wdata <= 0;
    end
    else if (csr_state == CSR_IDLE) begin

        if (jump_i & (int_state == INT_TIME))
            mepc_wdata <= jump_pc_i;
        else
            mepc_wdata <= pc_i;
    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        mcause_wdata <= 0;
    end
    else if (csr_state == CSR_IDLE) begin

        if (int_state == INT_EXPT) begin

            if (op_ecall)
                mcause_wdata <= 64'd11;

            else if (op_ebreak)
                mcause_wdata <= 64'd3;

            else
                mcause_wdata <= 64'd10;
        end
        else if (int_state == INT_TIME) begin

            mcause_wdata <= 64'h8000_0000_0000_0007;

        end

    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        clint_mepc_wen_o      <= 1'b0;
        clint_mcause_wen_o    <= 1'b0;
        clint_mstatus_wen_o   <= 1'b0;

        clint_mepc_wdata_o    <= 64'b0;
        clint_mcause_wdata_o  <= 64'b0;
        clint_mstatus_wdata_o <= 64'b0;
    end
    else begin
        case (csr_state)
            CSR_MEPC_MCAUSE_MSTATUS : begin
                clint_mepc_wen_o      <= 1'b1;
                clint_mcause_wen_o    <= 1'b1;
                clint_mstatus_wen_o   <= 1'b1;

                clint_mepc_wdata_o    <= mepc_wdata;
                clint_mcause_wdata_o  <= mcause_wdata;
                clint_mstatus_wdata_o <= {csr_mstatus_i[63:8],
                                          csr_mstatus_i[3], 3'b0, // MPIE[7]=MIE[3]
                                          1'b0, csr_mstatus_i[2:0]// MIE[3]=0 close global int
                                          };
            end

            CSR_MRET : begin
                clint_mstatus_wen_o   <= 1'b1;
                clint_mstatus_wdata_o <= {
                                          csr_mstatus_i[63:8],
                                          4'b1000,          // MPIE[7]=1
                                        //   4'b0000,          // MPIE[7]=0
                                          csr_mstatus_i[7], 3'b0// MIE[3]=MPIE[7]
                                          };
            end

            default : begin
                clint_mepc_wen_o      <= 1'b0;
                clint_mcause_wen_o    <= 1'b0;
                clint_mstatus_wen_o   <= 1'b0;
            end
        endcase
    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        clint_int_addr_o  <= 0;
        clint_int_valid_o <= 0;
    end
    else begin
        case (csr_state)
            CSR_MEPC_MCAUSE_MSTATUS : begin
                clint_int_addr_o  <= csr_mtvec_i;
                clint_int_valid_o <= 1'b1;
            end

            CSR_MRET : begin
                clint_int_addr_o  <= csr_mepc_i;
                clint_int_valid_o <= 1'b1;
            end
            default : begin
                clint_int_addr_o  <= 0;
                clint_int_valid_o <= 0;
            end
        endcase
    end
end

assign clint_hold_o =  (int_state != INT_IDLE)
               | (csr_state != CSR_IDLE);

endmodule

 

module ysyx_210238_csr_file (
    input             clk,
    input             rst_n,

    // cpu port
    input             cpu_csr_wen_i,
    input      [11:0] cpu_csr_raddr_i,
    input      [11:0] cpu_csr_waddr_i,
    input      [63:0] cpu_csr_wdata_i,
    output reg [63:0] csrfile_cpu_csr_rdata_o,

    // clint port
    input             clint_mepc_wen_i     ,
    input [63:0]      clint_mepc_wdata_i   ,
    input             clint_mcause_wen_i   ,
    input [63:0]      clint_mcause_wdata_i ,
    input             clint_mstatus_wen_i  ,
    input [63:0]      clint_mstatus_wdata_i,

    output     [63:0] csrfile_clint_csr_mtvec_o,
    output     [63:0] csrfile_clint_csr_mepc_o,
    output     [63:0] csrfile_clint_csr_mstatus_o,

    output            csrfile_global_int_en_o,
    output            csrfile_mtime_int_en_o,
    output            csrfile_mtime_int_pend_o,

    // timer port
    input             timer_int_i
);

//---------CSR--------
reg [63:0] mstatus;
reg [63:0] mie;
reg [63:0] mtvec;
reg [63:0] mepc;
reg [63:0] mcause;
reg [63:0] mtval;
reg [63:0] mip;
reg [63:0] mcycle;
reg [63:0] mhartid;
reg [63:0] mscratch;


//---------mcycle---------------------------
always @(posedge clk) begin
    if(~rst_n) begin
        mcycle <= 0;
    end
    else begin
        mcycle <= mcycle + 1'b1;
    end
end

//--------------mip------------------------
always @(posedge clk) begin
    if(~rst_n) begin
        mip <= 0;
    end
    else if (timer_int_i) begin
        mip[7] <= 1'b1;
    end
end

//----------Write CSR-----------------------
always @(posedge clk) begin
    if(~rst_n) begin

        // mstatus: MPP[12:11]=11, MPIE[7]=?, MIE[3]=?
        // mstatus <= {51'b0, 13'b11000_1000_1000};
        // mstatus <= {51'b0, 13'b11000_1000_0000};
        mstatus <= {51'b0, 13'b11000_0000_0000};
        
        // mie: MTIE[7]=1
        // mie     <= {56'b0, 8'b1000_0000};
        mie     <= 0;
        mtvec   <= 0;
        mepc    <= 0;
        mcause  <= 0;
        mtval   <= 0;
        mhartid <= 0;
        mscratch<= 0;
    end
    else if (cpu_csr_wen_i) begin
        case (cpu_csr_waddr_i)

            `ADDR_MSTATUS : mstatus <= cpu_csr_wdata_i;

            `ADDR_MIE     : mie     <= cpu_csr_wdata_i;

            `ADDR_MTVEC   : mtvec   <= cpu_csr_wdata_i;

            `ADDR_MEPC    : mepc    <= cpu_csr_wdata_i;

            `ADDR_MCAUSE  : mcause  <= cpu_csr_wdata_i;

            `ADDR_MTVAL   : mtval   <= cpu_csr_wdata_i;

            `ADDR_MHARTID : mhartid <= cpu_csr_wdata_i;

            `ADDR_MSCRATCH: mscratch<= cpu_csr_wdata_i;

            default : mstatus <= mstatus;
        endcase
    end
    else begin
        if (clint_mepc_wen_i) begin

            mepc <= clint_mepc_wdata_i;
        end
        if (clint_mcause_wen_i) begin

            mcause <= clint_mcause_wdata_i;
        end
        if (clint_mstatus_wen_i) begin

            mstatus <= clint_mstatus_wdata_i;
        end
    end
end

//----------Read CSR---------------------
always @(*) begin
    if (cpu_csr_wen_i & (cpu_csr_raddr_i == cpu_csr_waddr_i)) begin
        csrfile_cpu_csr_rdata_o = cpu_csr_wdata_i;
    end
    else begin
        case (cpu_csr_raddr_i)
            `ADDR_MSTATUS : csrfile_cpu_csr_rdata_o = mstatus;

            `ADDR_MIE     : csrfile_cpu_csr_rdata_o = mie;

            `ADDR_MTVEC   : csrfile_cpu_csr_rdata_o = mtvec;

            `ADDR_MEPC    : csrfile_cpu_csr_rdata_o = mepc;

            `ADDR_MCAUSE  : csrfile_cpu_csr_rdata_o = mcause;

            `ADDR_MTVAL   : csrfile_cpu_csr_rdata_o = mtval;

            `ADDR_MIP     : csrfile_cpu_csr_rdata_o = mip;

            `ADDR_MCYCLE  : csrfile_cpu_csr_rdata_o = mcycle;

            `ADDR_MHARTID : csrfile_cpu_csr_rdata_o = mhartid;

            default       : csrfile_cpu_csr_rdata_o = 0;
        endcase
    end
end

assign csrfile_clint_csr_mtvec_o   = mtvec;
assign csrfile_clint_csr_mepc_o    = mepc;
assign csrfile_clint_csr_mstatus_o = mstatus;

assign csrfile_global_int_en_o     = mstatus[3];
assign csrfile_mtime_int_en_o      = mie[7];
assign csrfile_mtime_int_pend_o    = mip[7];

endmodule

// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.07.18
// Execute unit
// As known as "EX"

 

module ysyx_210238_exu(
    // idu ports
    input   [63:0] imm_i,
    input   [63:0] rs1_rdata_i,
    input   [63:0] rs2_rdata_i,
    input   [63:0] csr_rdata_i,
    input   [63:0] pc_i,

    // ex control
    input   [12:0] alu_info_i,
    input   [5:0]  csr_info_i,
    input          op2_is_imm_i,
    input          op_is_jal_i,

    // wbu
    input          rd_wen_i,
    output         exu_rd_wen_o,
    input   [4:0]  rd_addr_i,
    output  [63:0] exu_rd_data_o,
    output  [4:0]  exu_rd_addr_o,

    // ls
    input   [10:0] ls_info_i,
    input          mem_read_i,
    input          mem_write_i,
    output  [63:0] exu_mem_addr_o,
    output  [63:0] exu_mem_wdata_o,
    output  [10:0] exu_ls_info_o,
    output         exu_mem_read_o,
    output         exu_mem_write_o,

    // forward control
    input          forward_ex_rs1_i,
    input          forward_ex_rs2_i,
    input          forward_ls_rs1_i,
    input          forward_ls_rs2_i,
    input   [63:0] ex_ls_rd_data_i,
    input   [63:0] wbu_rd_wdata_i,

    // csr
    input          csr_wen_i,
    input   [11:0] csr_waddr_i,
    output  [63:0] exu_csr_wdata_o,
    output         exu_csr_wen_o,
    output  [11:0] exu_csr_waddr_o


);


//---------------Variables declaration------------------------
wire op_alu_or    = alu_info_i[12];
wire op_alu_add   = alu_info_i[11] & ~alu_info_i[0];
wire op_alu_sub   = alu_info_i[10] & ~alu_info_i[0];
wire op_alu_slt   = alu_info_i[ 9];
wire op_alu_sltu  = alu_info_i[ 8];
wire op_alu_xor   = alu_info_i[ 7];
wire op_alu_sll   = alu_info_i[ 6] & ~alu_info_i[0];
wire op_alu_srl   = alu_info_i[ 5] & ~alu_info_i[0];
wire op_alu_sra   = alu_info_i[ 4] & ~alu_info_i[0];
wire op_alu_and   = alu_info_i[ 3];
wire op_alu_lui   = alu_info_i[ 2];
wire op_alu_auipc = alu_info_i[ 1];
wire op_alu_word  = alu_info_i[ 0];
wire op_alu_addw  = alu_info_i[11] & alu_info_i[0];
wire op_alu_subw  = alu_info_i[10] & alu_info_i[0];
wire op_alu_sllw  = alu_info_i[ 6] & alu_info_i[0];
wire op_alu_srlw  = alu_info_i[ 5] & alu_info_i[0];
wire op_alu_sraw  = alu_info_i[ 4] & alu_info_i[0];

wire op_csr_csrrw = csr_info_i[5];
wire op_csr_csrrs = csr_info_i[4];
wire op_csr_csrrc = csr_info_i[3];
wire op_csr_csrrwi= csr_info_i[2];
wire op_csr_csrrsi= csr_info_i[1];
wire op_csr_csrrci= csr_info_i[0];
wire op_csr       = op_csr_csrrw
                  | op_csr_csrrs
                  | op_csr_csrrc
                  | op_csr_csrrwi
                  | op_csr_csrrsi
                  | op_csr_csrrci
                  ;


wire signed [63:0] add_rd_data;
wire signed [63:0] sub_rd_data;
wire        [63:0] slt_rd_data;
wire        [63:0] sltu_rd_data;
wire        [63:0] xor_rd_data;
wire        [63:0] sll_rd_data;
wire        [63:0] srl_rd_data;
wire signed [63:0] sra_rd_data;
wire        [63:0] and_rd_data;
wire        [63:0] or_rd_data;
wire        [63:0] lui_rd_data;
wire signed [63:0] auipc_rd_data;
wire        [63:0] addw_rd_data;
wire        [63:0] subw_rd_data;
wire        [63:0] sllw_rd_data;
wire        [63:0] srlw_rd_data;
wire        [63:0] sraw_rd_data;
wire        [63:0] jal_rd_data;

wire        [31:0] sllw_temp;
wire        [31:0] srlw_temp;
wire signed [31:0] sraw_temp;

wire        [63:0] csrrw_wdata;
wire        [63:0] csrrs_wdata;
wire        [63:0] csrrc_wdata;
wire        [63:0] csrrwi_wdata;
wire        [63:0] csrrsi_wdata;
wire        [63:0] csrrci_wdata;

reg         [63:0] op1;
reg         [63:0] op2;

wire signed [63:0] op1_signed;
wire signed [63:0] op2_signed;

wire        [31:0] op1_word;
wire signed [31:0] op1_word_signed;

wire signed [63:0] pc_signed;

wire op1_lt_op2_signed;
wire op1_lt_op2_unsigned;

wire [5:0] shift_bits;

//-----------------OP-------------------------
always @(*) begin
    case ({forward_ex_rs1_i, forward_ls_rs1_i})
        2'b10   : op1 = ex_ls_rd_data_i;
        2'b01   : op1 = wbu_rd_wdata_i;
        default : op1 = rs1_rdata_i;
    endcase
end

always @(*) begin
    casez ({forward_ex_rs2_i, forward_ls_rs2_i, op2_is_imm_i})
        3'b100  : op2 = ex_ls_rd_data_i;
        3'b010  : op2 = wbu_rd_wdata_i;
        3'b??1  : op2 = imm_i;
        default : op2 = rs2_rdata_i;
    endcase
end

assign op1_signed = $signed(op1);
assign op2_signed = $signed(op2);

assign op1_word        = op1[31:0];
assign op1_word_signed = $signed(op1_word);

assign pc_signed  = $signed(pc_i);
assign shift_bits = op2[5:0];


//----------------ALU---------------------

// add addi
assign add_rd_data   = op1_signed + op2_signed;

// sub subw
assign sub_rd_data   = op1_signed - op2_signed;

// slt slti
assign op1_lt_op2_signed = op1_signed < op2_signed;
assign slt_rd_data       = {{63{1'b0}}, op1_lt_op2_signed};

// sltu sltiu
assign op1_lt_op2_unsigned = op1 < op2;
assign sltu_rd_data        = {{63{1'b0}}, op1_lt_op2_unsigned};

// xor xori
assign xor_rd_data = op1 ^ op2;

// sll slli
assign sll_rd_data = op1 << shift_bits;

// srl srli
assign srl_rd_data = op1 >> shift_bits;

// sra srai
assign sra_rd_data = op1_signed >>> shift_bits;

// and andi
assign and_rd_data = op1 & op2;

// or ori
assign or_rd_data  = op1 | op2;

// lui
assign lui_rd_data = op2;

// auipc
assign auipc_rd_data = pc_signed + op2_signed;

// addw addiw
assign addw_rd_data = {{32{add_rd_data[31]}}, add_rd_data[31:0]};

// subw
assign subw_rd_data = {{32{sub_rd_data[31]}}, sub_rd_data[31:0]};

// sllw slliw
assign sllw_temp    = op1_word << shift_bits[4:0];
assign sllw_rd_data = {{32{sllw_temp[31]}}, sllw_temp};

// srlw srliw
assign srlw_temp    = op1_word >> shift_bits[4:0];
assign srlw_rd_data = {{32{srlw_temp[31]}}, srlw_temp};

// sraw sraiw
assign sraw_temp    = op1_word_signed >>> shift_bits[4:0];
assign sraw_rd_data = {{32{sraw_temp[31]}}, sraw_temp};

// jal
assign jal_rd_data  = pc_i + 4;


//------------------CSR wdata--------------
assign csrrw_wdata  =  rs1_rdata_i;

assign csrrs_wdata  =  rs1_rdata_i | csr_rdata_i;

assign csrrc_wdata  = ~rs1_rdata_i & csr_rdata_i;

assign csrrwi_wdata =  imm_i;

assign csrrsi_wdata =  imm_i | csr_rdata_i;

assign csrrci_wdata = ~imm_i & csr_rdata_i;




//----------output---------------------
assign exu_rd_wen_o  = rd_wen_i;

assign exu_rd_addr_o = rd_addr_i;

assign exu_rd_data_o = ({64{op_alu_add}}   & add_rd_data)
                |  ({64{op_alu_sub}}   & sub_rd_data)
                |  ({64{op_alu_slt}}   & slt_rd_data)
                |  ({64{op_alu_sltu}}  & sltu_rd_data)
                |  ({64{op_alu_xor}}   & xor_rd_data)
                |  ({64{op_alu_sll}}   & sll_rd_data)
                |  ({64{op_alu_srl}}   & srl_rd_data)
                |  ({64{op_alu_sra}}   & sra_rd_data)
                |  ({64{op_alu_and}}   & and_rd_data)
                |  ({64{op_alu_or}}    & or_rd_data)
                |  ({64{op_alu_lui}}   & lui_rd_data)
                |  ({64{op_alu_auipc}} & auipc_rd_data)
                |  ({64{op_alu_addw}}  & addw_rd_data)
                |  ({64{op_alu_subw}}  & subw_rd_data)
                |  ({64{op_alu_sllw}}  & sllw_rd_data)
                |  ({64{op_alu_srlw}}  & srlw_rd_data)
                |  ({64{op_alu_sraw}}  & sraw_rd_data)
                |  ({64{op_is_jal_i}}  & jal_rd_data)
                |  ({64{op_csr}}       & csr_rdata_i)
                ;


assign exu_mem_addr_o  = add_rd_data;
assign exu_mem_wdata_o = forward_ls_rs2_i ? wbu_rd_wdata_i :
                         forward_ex_rs2_i ? ex_ls_rd_data_i : rs2_rdata_i;

assign exu_ls_info_o   = ls_info_i;
assign exu_mem_read_o  = mem_read_i;
assign exu_mem_write_o = mem_write_i;

assign exu_csr_waddr_o = csr_waddr_i;
assign exu_csr_wen_o   = csr_wen_i;

assign exu_csr_wdata_o = ({64{op_csr_csrrw }} & csrrw_wdata)
                  |  ({64{op_csr_csrrs }} & csrrs_wdata)
                  |  ({64{op_csr_csrrc }} & csrrc_wdata)
                  |  ({64{op_csr_csrrwi}} & csrrwi_wdata)
                  |  ({64{op_csr_csrrsi}} & csrrsi_wdata)
                  |  ({64{op_csr_csrrci}} & csrrci_wdata)
                  ;

endmodule

// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.07.26
// Hazard detect unit

 

module ysyx_210238_hdu (
    // data hazard
    input  [4:0] i_id_ex_rs1,
    input  [4:0] i_id_ex_rs2,
    input        i_id_ex_rs1_cen,
    input        i_id_ex_rs2_cen,

    input  [4:0] i_if_id_rs1,
    input  [4:0] i_if_id_rs2,
    input        i_if_id_rs1_cen,
    input        i_if_id_rs2_cen,

    input  [4:0] i_id_ex_rd,
    input  [4:0] i_ex_ls_rd,
    input  [4:0] i_ls_wb_rd,
    input        i_ex_ls_rd_wen,
    input        i_ls_wb_rd_wen,
    input        i_id_ex_mem_read,
    input        i_ls_wb_mem_read,

    output       o_forward_ex_rs1,
    output       o_forward_ex_rs2,
    output       o_forward_ls_rs1,
    output       o_forward_ls_rs2,
    output       o_load_use,

    // control hazard
    input        i_op_is_branch,
    input        i_id_ex_rd_wen,
    input        i_ex_ls_mem_read,

    output       o_ctrl_forward_ex_rs1,
    output       o_ctrl_forward_ex_rs2,
    output       o_ctrl_forward_ls_rs1,
    output       o_ctrl_forward_ls_rs2,
    output       o_ctrl_load_use

);

//--------------data hazard detect-------------------
assign o_forward_ex_rs1 = i_ex_ls_rd_wen
                        & (i_ex_ls_rd != 5'b0)
                        & (i_ex_ls_rd == i_id_ex_rs1)
                        //& i_id_ex_rs1_cen
                        ;

assign o_forward_ex_rs2 = i_ex_ls_rd_wen
                        & (i_ex_ls_rd != 5'b0)
                        & (i_ex_ls_rd == i_id_ex_rs2)
                        //& i_id_ex_rs2_cen
                        ;

assign o_forward_ls_rs1 = i_ls_wb_rd_wen
                        & (i_ls_wb_rd != 5'b0)
                        & (i_ls_wb_rd == i_id_ex_rs1)
                        & ((i_ex_ls_rd != i_id_ex_rs1) | i_ls_wb_mem_read)
                        //& i_id_ex_rs1_cen
                        ;

assign o_forward_ls_rs2 = i_ls_wb_rd_wen
                        & (i_ls_wb_rd != 5'b0)
                        & (i_ls_wb_rd == i_id_ex_rs2)
                        & ((i_ex_ls_rd != i_id_ex_rs2) | i_ls_wb_mem_read)
                        //& i_id_ex_rs2_cen
                        ;

assign o_load_use = i_id_ex_mem_read
                  & ( (i_if_id_rs1_cen & (i_if_id_rs1 == i_id_ex_rd))
                    | (i_if_id_rs2_cen & (i_if_id_rs2 == i_id_ex_rd)) )
                  ;


//--------------control hazard detect-------------------
assign o_ctrl_forward_ex_rs1 = i_op_is_branch
                            &  i_id_ex_rd_wen
                            & (i_id_ex_rd != 5'b0)
                            & (i_id_ex_rd == i_if_id_rs1)
                            ;

assign o_ctrl_forward_ex_rs2 = i_op_is_branch
                            &  i_id_ex_rd_wen
                            & (i_id_ex_rd != 5'b0)
                            & (i_id_ex_rd == i_if_id_rs2)
                            ;

assign o_ctrl_forward_ls_rs1 = i_op_is_branch
                            &  i_ex_ls_rd_wen
                            & (i_ex_ls_rd != 5'b0)
                            & (i_ex_ls_rd == i_if_id_rs1)
                            & ((i_id_ex_rd != i_if_id_rs1) | i_ex_ls_mem_read)
                            ;

assign o_ctrl_forward_ls_rs2 = i_op_is_branch
                            &  i_ex_ls_rd_wen
                            & (i_ex_ls_rd != 5'b0)
                            & (i_ex_ls_rd == i_if_id_rs2)
                            & ((i_id_ex_rd != i_if_id_rs2) | i_ex_ls_mem_read)
                            ;

assign o_ctrl_load_use = i_op_is_branch
                      &  i_id_ex_mem_read
                      &  ( (i_if_id_rs1 == i_id_ex_rd)
                         | (i_if_id_rs2 == i_id_ex_rd) )
                      ;

endmodule

// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.08.31
// Instruction Decode Unit module
// Pure combinational logic
// branch and jump at id

 

module ysyx_210238_idu(
    // ifu ports
    input [63:0]  pc_i,
    input [31:0]  instr_i,
    output        idu_jump_o,
    output[63:0]  idu_jump_pc_o,


    // reg_file ports
    input  [63:0] rs1_rdata_i,
    input  [63:0] rs2_rdata_i,
    output [4:0]  idu_rs1_addr_o,
    output [4:0]  idu_rs2_addr_o,
    output        idu_rs1_cen_o,
    output        idu_rs2_cen_o,

    // exu ports
    output [63:0] idu_imm_o,
    output [63:0] idu_rs1_rdata_o,
    output [63:0] idu_rs2_rdata_o,
    output [63:0] idu_pc_o,
    output [12:0] idu_alu_info_o,
    output [8:0]  idu_csr_info_o,
    output        idu_op2_is_imm_o,
    output        idu_op_is_jal_o,

    // ls control
    output [10:0] idu_ls_info_o,
    output        idu_mem_read_o,
    output        idu_mem_write_o,

    // wb control
    output        idu_rd_wen_o,
    output [4:0]  idu_rd_addr_o,

    // ctrl hazard
    output        idu_op_is_branch_o,
    input         forward_ex_rs1_i,
    input         forward_ex_rs2_i,
    input         forward_ls_rs1_i,
    input         forward_ls_rs2_i,
    input         ex_ls_mem_read_i,
    input [63:0]  exu_rd_data_i,
    input [63:0]  lsu_rd_data_i,
    input [63:0]  lsu_mem_rdata_i,

    // csr ports
    input  [63:0] csr_rdata_i,
    output        idu_csr_wen_o,
    output [63:0] idu_csr_rdata_o,
    output [11:0] idu_csr_raddr_o,
    output [11:0] idu_csr_waddr_o

);

// test out char
always @(*) begin
    if (instr_i==32'h7b)
        $display("Output!\n");
end


//----------Pre decode--------------
wire [6:0]  opcode = instr_i[6:0];
wire [4:0]  rd     = instr_i[11:7];
wire [4:0]  rs1    = instr_i[19:15];
wire [4:0]  rs2    = instr_i[24:20];
wire [2:0]  func3  = instr_i[14:12];
wire [6:0]  func7  = instr_i[31:25];
wire [11:0] csr    = instr_i[31:20];


wire instr_op_is_imm   = (opcode == `INSTR_I);
wire instr_op_is_alu   = (opcode == `INSTR_R);
wire instr_op_is_load  = (opcode == `INSTR_L);
wire instr_op_is_store = (opcode == `INSTR_S);
wire instr_op_is_jal   = (opcode == `INSTR_JAL);
wire instr_op_is_jalr  = (opcode == `INSTR_JALR);
wire instr_op_is_branch= (opcode == `INSTR_B);
wire instr_op_is_lui   = (opcode == `INSTR_LUI);
wire instr_op_is_auipc = (opcode == `INSTR_AUIPC);
wire instr_op_is_fence = (opcode == `INSTR_FENCE);
wire instr_op_is_sys   = (opcode == `INSTR_SYS);
wire instr_op_is_word  = (opcode == `INSTR_WORD);
wire instr_op_is_wordi = (opcode == `INSTR_WORDI);


wire func3_is_000 = (func3 == 3'b000);
wire func3_is_001 = (func3 == 3'b001);
wire func3_is_010 = (func3 == 3'b010);
wire func3_is_011 = (func3 == 3'b011);
wire func3_is_100 = (func3 == 3'b100);
wire func3_is_101 = (func3 == 3'b101);
wire func3_is_110 = (func3 == 3'b110);
wire func3_is_111 = (func3 == 3'b111);


wire func7_is_0000000 = (func7 == 7'b0000000);
wire func7_is_0100000 = (func7 == 7'b0100000);
wire func7_is_0011000 = (func7 == 7'b0011000);



//--------------ALU and imm ALU imm Instruction------------------------
wire instr_add    = instr_op_is_alu & func3_is_000 & func7_is_0000000;
wire instr_and    = instr_op_is_alu & func3_is_111 & func7_is_0000000;
wire instr_or     = instr_op_is_alu & func3_is_110 & func7_is_0000000;
wire instr_sll    = instr_op_is_alu & func3_is_001 & func7_is_0000000;
wire instr_slt    = instr_op_is_alu & func3_is_010 & func7_is_0000000;
wire instr_sltu   = instr_op_is_alu & func3_is_011 & func7_is_0000000;
wire instr_sra    = instr_op_is_alu & func3_is_101 & func7_is_0100000;
wire instr_srl    = instr_op_is_alu & func3_is_101 & func7_is_0000000;
wire instr_sub    = instr_op_is_alu & func3_is_000 & func7_is_0100000;
wire instr_xor    = instr_op_is_alu & func3_is_100 & func7_is_0000000;
wire instr_subw   = instr_op_is_word & func3_is_000 & func7_is_0100000;
wire instr_srlw   = instr_op_is_word & func3_is_101 & func7_is_0000000;
wire instr_sraw   = instr_op_is_word & func3_is_101 & func7_is_0100000;
wire instr_addw   = instr_op_is_word & func3_is_000 & func7_is_0000000;
wire instr_sllw   = instr_op_is_word & func3_is_001 & func7_is_0000000;

wire instr_tmp_0  = (instr_i[31:26] == 6'b000000);
wire instr_tmp_1  = (instr_i[31:26] == 6'b010000);

wire instr_addi   = instr_op_is_imm & func3_is_000;
wire instr_andi   = instr_op_is_imm & func3_is_111;
wire instr_ori    = instr_op_is_imm & func3_is_110;
wire instr_slli   = instr_op_is_imm & func3_is_001 & instr_tmp_0;
wire instr_slti   = instr_op_is_imm & func3_is_010;
wire instr_sltiu  = instr_op_is_imm & func3_is_011;
wire instr_srai   = instr_op_is_imm & func3_is_101 & instr_tmp_1;
wire instr_srli   = instr_op_is_imm & func3_is_101 & instr_tmp_0;
wire instr_xori   = instr_op_is_imm & func3_is_100;
wire instr_srliw  = instr_op_is_wordi & func3_is_101 & instr_tmp_0;
wire instr_sraiw  = instr_op_is_wordi & func3_is_101 & instr_tmp_1;
wire instr_addiw  = instr_op_is_wordi & func3_is_000;
wire instr_slliw  = instr_op_is_wordi & func3_is_001 & instr_tmp_0;


//---------Load and store-----------------------
wire instr_lb     = instr_op_is_load & func3_is_000;
wire instr_lbu    = instr_op_is_load & func3_is_100;
wire instr_ld     = instr_op_is_load & func3_is_011;
wire instr_lh     = instr_op_is_load & func3_is_001;
wire instr_lhu    = instr_op_is_load & func3_is_101;
wire instr_lw     = instr_op_is_load & func3_is_010;
wire instr_lwu    = instr_op_is_load & func3_is_110;
wire instr_sb     = instr_op_is_store & func3_is_000;
wire instr_sd     = instr_op_is_store & func3_is_011;
wire instr_sh     = instr_op_is_store & func3_is_001;
wire instr_sw     = instr_op_is_store & func3_is_010;
wire instr_load   = instr_op_is_load;
wire instr_store  = instr_op_is_store;


//-------------Exception or CSR----------------------
wire instr_ebreak = instr_op_is_sys & func3_is_000 & func7_is_0000000 & (rs2 == 5'b1);
wire instr_ecall  = instr_op_is_sys & func3_is_000 & func7_is_0000000 & (rs2 == 5'b0);
wire instr_mret   = instr_op_is_sys & func3_is_000 & func7_is_0011000 & (rs2 == 5'b10);

wire instr_csrrw  = instr_op_is_sys & func3_is_001;
wire instr_csrrs  = instr_op_is_sys & func3_is_010;
wire instr_csrrc  = instr_op_is_sys & func3_is_011;
wire instr_csrrwi = instr_op_is_sys & func3_is_101;
wire instr_csrrsi = instr_op_is_sys & func3_is_110;
wire instr_csrrci = instr_op_is_sys & func3_is_111;

wire instr_csri    =  instr_csrrwi
                    | instr_csrrsi
                    | instr_csrrci
                    ;

//--------------Branch jal jalr----------------
wire instr_beq    = instr_op_is_branch & func3_is_000;
wire instr_bge    = instr_op_is_branch & func3_is_101;
wire instr_bgeu   = instr_op_is_branch & func3_is_111;
wire instr_blt    = instr_op_is_branch & func3_is_100;
wire instr_bltu   = instr_op_is_branch & func3_is_110;
wire instr_bne    = instr_op_is_branch & func3_is_001;
wire instr_jal    = instr_op_is_jal;
wire instr_jalr   = instr_op_is_jalr;


//-----------Instruction's type-----------------------
wire instr_type_i = instr_op_is_imm
                  | instr_op_is_jalr
                  | instr_op_is_load
                  | instr_op_is_wordi;     // I type

wire instr_type_s = instr_op_is_store;     // S type

wire instr_type_b = instr_op_is_branch;    // B type

wire instr_type_u = instr_op_is_lui
                  | instr_op_is_auipc;     // U type

wire instr_type_j = instr_op_is_jal;       // J type


//-------------operation is ALU ------------------------
wire op_alu_add   = instr_add | instr_addi | instr_addw | instr_addiw;
wire op_alu_sub   = instr_sub | instr_subw;
wire op_alu_slt   = instr_slt | instr_slti;
wire op_alu_sltu  = instr_sltu| instr_sltiu;
wire op_alu_xor   = instr_xor | instr_xori;
wire op_alu_sll   = instr_sll | instr_slli | instr_sllw | instr_slliw;
wire op_alu_srl   = instr_srl | instr_srli | instr_srlw | instr_srliw;
wire op_alu_sra   = instr_sra | instr_srai | instr_sraw | instr_sraiw;
wire op_alu_and   = instr_and | instr_andi;
wire op_alu_or    = instr_or  | instr_ori;

wire op_alu_lui   = instr_op_is_lui;

wire op_alu_auipc = instr_op_is_auipc;

wire op_alu_word  = instr_op_is_word | instr_op_is_wordi;

wire [12:0]op_alu_info = {
                    op_alu_or,
                    op_alu_add,
                    op_alu_sub,
                    op_alu_slt,
                    op_alu_sltu,
                    op_alu_xor,
                    op_alu_sll,
                    op_alu_srl,
                    op_alu_sra,
                    op_alu_and,
                    op_alu_lui,
                    op_alu_auipc,
                    op_alu_word
                    };


//-----------operation is load/store--------
wire [12:0] op_ls_info = {
                    instr_load,
                    instr_store,
                    instr_lb ,
                    instr_lbu,
                    instr_ld ,
                    instr_lh ,
                    instr_lhu,
                    instr_lw ,
                    instr_lwu,
                    instr_sb ,
                    instr_sd ,
                    instr_sh ,
                    instr_sw
                    };


//-------------operation is Exception or CSR----------
wire [8:0] op_csr_info = {
                         instr_ecall,
                         instr_ebreak,
                         instr_mret,
                         instr_csrrw,
                         instr_csrrs,
                         instr_csrrc,
                         instr_csrrwi,
                         instr_csrrsi,
                         instr_csrrci
                        };


//---------Immediate number---------------

wire op2_is_imm =     instr_type_i
                    | instr_type_s
                    | instr_type_u
                    | instr_type_j;

wire [63:0] i_imm = {{52{instr_i[31]}},
                         instr_i[31:20]};

wire [63:0] s_imm = {{52{instr_i[31]}},
                         instr_i[31:25],
                         instr_i[11:7]};

wire [63:0] b_imm = {{51{instr_i[31]}},
                         instr_i[31],
                         instr_i[7],
                         instr_i[30:25],
                         instr_i[11:8],
                         1'b0};

wire [63:0] u_imm = {{32{instr_i[31]}},
                         instr_i[31:12],
                         12'b0};

wire [63:0] j_imm = {{43{instr_i[31]}},
                         instr_i[31],
                         instr_i[19:12],
                         instr_i[20],
                         instr_i[30:21],
                         1'b0};

wire [63:0] csr_imm = {59'b0, rs1};

wire [63:0] imm =
                  ({64{instr_type_i}} & i_imm)
                | ({64{instr_type_s}} & s_imm)
                | ({64{instr_type_b}} & b_imm)
                | ({64{instr_type_u}} & u_imm)
                | ({64{instr_type_j}} & j_imm)
                | ({64{instr_csri}}   & csr_imm)
                ;


//------------branch/jal/jalr------------

wire signed [63:0] imm_signed = $signed(imm);
wire signed [63:0] pc_signed  = $signed(pc_i);

reg         [63:0] branch_op1;
reg         [63:0] branch_op2;
wire signed [63:0] branch_op1_signed = $signed(branch_op1);
wire signed [63:0] branch_op2_signed = $signed(branch_op2);

wire               forward_lsu_rs1_rd;
wire               forward_lsu_rs2_rd;
wire               forward_lsu_rs1_mem;
wire               forward_lsu_rs2_mem;

assign forward_lsu_rs1_rd = ~ex_ls_mem_read_i & forward_ls_rs1_i;
assign forward_lsu_rs2_rd = ~ex_ls_mem_read_i & forward_ls_rs2_i;
assign forward_lsu_rs1_mem = ex_ls_mem_read_i & forward_ls_rs1_i;
assign forward_lsu_rs2_mem = ex_ls_mem_read_i & forward_ls_rs2_i;


always @(*) begin
case ({forward_ex_rs1_i, forward_lsu_rs1_rd, forward_lsu_rs1_mem})
    3'b100  : branch_op1 = exu_rd_data_i;
    3'b010  : branch_op1 = lsu_rd_data_i;
    3'b001  : branch_op1 = lsu_mem_rdata_i;
    default : branch_op1 = rs1_rdata_i;
endcase
end

always @(*) begin
case ({forward_ex_rs2_i, forward_lsu_rs2_rd, forward_lsu_rs2_mem})
    3'b100  : branch_op2 = exu_rd_data_i;
    3'b010  : branch_op2 = lsu_rd_data_i;
    3'b001  : branch_op2 = lsu_mem_rdata_i;
    default : branch_op2 = rs2_rdata_i;
endcase
end

// beq
wire flag_beq = instr_beq & (branch_op1 == branch_op2);

// bne
wire flag_bne = instr_bne & (branch_op1 != branch_op2);

// blt
wire flag_blt = instr_blt & (branch_op1_signed < branch_op2_signed);

// bge
wire flag_bge = instr_bge & (branch_op1_signed >= branch_op2_signed);

// bltu
wire flag_bltu = instr_bltu & (branch_op1 < branch_op2);

// bgeu
wire flag_bgeu = instr_bgeu & (branch_op1 >= branch_op2);

wire flag_branch = flag_beq | flag_bne | flag_blt
                  |flag_bge | flag_bltu| flag_bgeu;


// branch jal next pc
wire signed[63:0] bjal_next_pc = pc_signed + imm_signed;

// jalr
wire signed[63:0] temp_jalr_next_pc = branch_op1_signed + imm_signed;
wire signed[63:0] jalr_next_pc = {temp_jalr_next_pc[63:1], 1'b0};



//-----------Output----------------
assign idu_jump_o = flag_branch | instr_jal | instr_jalr;

assign idu_jump_pc_o = ({64{flag_branch | instr_jal}} & bjal_next_pc)
                    |  ({64{instr_jalr}}              & jalr_next_pc);

assign idu_rs1_addr_o   = rs1;
assign idu_rs2_addr_o   = rs2;
assign idu_rs1_cen_o    = ~(instr_type_u | instr_type_j);
assign idu_rs2_cen_o    = ~(instr_type_u | instr_type_j | instr_type_i);

assign idu_imm_o        = imm;
assign idu_rs1_rdata_o  = rs1_rdata_i;
assign idu_rs2_rdata_o  = rs2_rdata_i;
assign idu_pc_o         = pc_i;

assign idu_alu_info_o   = op_alu_info;
assign idu_csr_info_o   = op_csr_info;
assign idu_op2_is_imm_o = op2_is_imm;
assign idu_op_is_jal_o  = instr_jal | instr_jalr;

assign idu_ls_info_o    = op_ls_info[10:0];
assign idu_mem_read_o   = op_ls_info[12];
assign idu_mem_write_o  = op_ls_info[11];

assign idu_rd_wen_o     = (~instr_type_s) &
                      (~instr_type_b) &
                      (~instr_ebreak) &
                      (~instr_ecall ) &
                      (~instr_mret  ) &
                      (~instr_op_is_fence) &
                      ~(instr_i == 32'd0)
                    ;

assign idu_rd_addr_o    = rd;

assign idu_op_is_branch_o = instr_op_is_branch | instr_op_is_jalr;


assign idu_csr_raddr_o  = csr;
assign idu_csr_waddr_o  = csr;
assign idu_csr_rdata_o  = csr_rdata_i;

assign idu_csr_wen_o    = instr_csrrw
                        | instr_csrrs
                        | instr_csrrc;


endmodule

// Copyright 2022 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2022.04.11
// Instruction Fetch unit

 

module ysyx_210238_ifu(
    input            clk,
    input            rst_n,

    // ram port
    output reg       ifu_ram_cen_o,
    output reg[63:0] ifu_ram_addr_o,
    output    [2:0]  ifu_ram_size_o,
    input     [63:0] ifu_ram_data_i,
    input            ifu_ram_valid_i,

    // cpu port
    input            jump_i,
    input            hold_i,
    input     [63:0] jump_pc_i,
    output    [31:0] ifu_instr_o,
    output           ifu_instr_valid_o,
    output    [63:0] ifu_pc_o,

    // clint port
    input            int_cen_i,
    input     [63:0] int_addr_i
);

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
            if (~hold_i)
                nxt_state = REQ;
            else
                nxt_state = IDLE;
        end
        REQ  : begin
            if (jump_i || int_cen_i)
                nxt_state = REQ;
            else
                nxt_state = WAIT;
        end
        WAIT : begin
            if (ifu_ram_valid_i)
                nxt_state = IDLE;
            else
                nxt_state = WAIT;
            end
        default : nxt_state = IDLE;
    endcase
end

// ------------ to ram --------------
always @(posedge clk) begin
    if(~rst_n) begin
        ifu_ram_cen_o <= 1'b0;
    end
    else if (cur_state==REQ && nxt_state==REQ) begin
        ifu_ram_cen_o <= 1'b0;
    end
    else if (nxt_state==REQ) begin
        ifu_ram_cen_o <= 1'b1;
    end
    else begin
        ifu_ram_cen_o <= 1'b0;
    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        ifu_ram_addr_o <= `PC_START;
    end
    else if (hold_i) begin
        ifu_ram_addr_o <= ifu_ram_addr_o;
    end
    else if (int_cen_i) begin
        ifu_ram_addr_o <= int_addr_i;
    end
    else if (jump_i) begin
        ifu_ram_addr_o <= jump_pc_i;
    end
    else if (ifu_ram_valid_i) begin
        ifu_ram_addr_o <= ifu_ram_addr_o + 64'd4;
    end
end

assign ifu_ram_size_o = 3'b011;


// -------------- to cpu -------------
assign ifu_instr_o = (ifu_ram_addr_o[2:0]==3'd0) ?
                      ifu_ram_data_i[31:0] : ifu_ram_data_i[63:32];

assign ifu_instr_valid_o = ifu_ram_valid_i;

assign ifu_pc_o = ifu_ram_addr_o;

endmodule

// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.09.07
// Load Store unit
// as known as "MEM"

 

module ysyx_210238_lsu(
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

// Copyright 2022 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2022.04.11
// Pipeline register

 

module ysyx_210238_pipeline_reg #(parameter N = 1)
    (
    input              clk,
    input              rst_n,

    // control ports
    input              clear_i,
    input              hold_i,
    // slave ports
    input      [N-1:0] data_i,
    // master ports
    output reg [N-1:0] data_o
);

always @(posedge clk) begin
    if (~rst_n) begin
        data_o  <= {N{1'b0}};
    end
    else if (clear_i) begin
        data_o  <= {N{1'b0}};
    end
    else if (hold_i) begin
        data_o  <= data_o;
    end
    else begin
        data_o  <= data_i;
    end
end

endmodule

// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.08.18
// Access RAM arbiter

 

module ysyx_210238_ram_arbiter (
    input clk,
    input rst_n,

    // ifu port
    input            ifu_cen_i,
    input     [63:0] ifu_addr_i,
    input     [2:0]  ifu_size_i,
    input            ifu_instr_valid_i,
    output           ram_ifu_valid_o,
    output    [63:0] ram_ifu_data_o,

    // lsu port
    input            lsu_cen_i,
    input            lsu_wen_i,
    input     [63:0] lsu_addr_i,
    input     [2:0]  lsu_size_i,
    input     [63:0] lsu_wdata_i,
    output           ram_lsu_valid_o,
    output    [63:0] ram_lsu_data_o,

    // timer port
    output           ram_timer_cen_o,
    output           ram_timer_wen_o,
    output    [63:0] ram_timer_addr_o,
    output    [63:0] ram_timer_wdata_o,
    input     [63:0] timer_rdata_i,
    input            timer_ready_i,

    // ram port
    output reg       ram_rw_cen_o,
    output reg       ram_rw_wen_o,
    output reg[63:0] ram_rw_addr_o,
    output reg[63:0] ram_rw_wdata_o,
    output reg[7:0]  ram_rw_wmask_o,
    output reg[2:0]  ram_rw_size_o,
    input            ram_rw_ready_i,
    input     [63:0] ram_rw_data_i
);

localparam MASK_WIDTH  = 128;

localparam IDLE    = 4'd0;
localparam IF_REQ  = 4'd1;
localparam IF_WAIT = 4'd2;
localparam LS_HOLD = 4'd4;
localparam LS_REQ_TIMER = 4'd5;
localparam LS_REQ_0= 4'd6;
localparam LS_REQ_1= 4'd7;
localparam LS_WAIT = 4'd8;

reg  [3:0]  cur_state;
reg  [3:0]  nxt_state;

reg  [2:0]  ifu_instr_valid_reg;
reg         ifu_cen_reg;
reg  [63:0] ifu_addr_reg;
reg  [2:0]  ifu_size_reg;

wire        req_timer_valid;
reg [7:0]   lsu_req_len;

// ------------------Process LSU Data------------------
wire lsu_aligned = lsu_addr_i[2:0] == 3'b000;
wire lsu_size_b  = lsu_size_i[1:0] == 2'b00;
wire lsu_size_h  = lsu_size_i[1:0] == 2'b01;
wire lsu_size_w  = lsu_size_i[1:0] == 2'b10;
wire lsu_size_d  = lsu_size_i[1:0] == 2'b11;

wire [3:0]   lsu_addr_op1 = {1'b0, lsu_addr_i[2:0]};

wire [3:0]   lsu_addr_op2 =   ({4{lsu_size_b}} & {4'b0000})
                            | ({4{lsu_size_h}} & {4'b0001})
                            | ({4{lsu_size_w}} & {4'b0011})
                            | ({4{lsu_size_d}} & {4'b0111})
                            ;

wire [3:0]   lsu_addr_end = lsu_addr_op1 + lsu_addr_op2;
wire         lsu_crossover= lsu_addr_end[3]; // LSU reqcross 8 byte boundry

wire [7:0]   lsu_len              = lsu_aligned ? 8'd0 : {7'b0, lsu_crossover}; // 0 or 1
wire [2:0]   lsu_size             = lsu_size_i;
wire [63:0]  lsu_addr             = lsu_addr_i;
wire [63:0]  lsu_addr_aligned     = {lsu_addr_i[63:3], 3'd0};
wire [5:0]   lsu_aligned_offset_l = {3'b0, lsu_addr_i[2:0]} << 3;
wire [5:0]   lsu_aligned_offset_h = 6'd63 + 6'd1 - lsu_aligned_offset_l;

// --------------- read mask and write mask -----------------
wire [127:0] lsu_full_rmask =(({MASK_WIDTH{lsu_size_b}} & {{MASK_WIDTH-8{1'b0}},  8'hff})
                            | ({MASK_WIDTH{lsu_size_h}} & {{MASK_WIDTH-16{1'b0}}, 16'hffff})
                            | ({MASK_WIDTH{lsu_size_w}} & {{MASK_WIDTH-32{1'b0}}, 32'hffffffff})
                            | ({MASK_WIDTH{lsu_size_d}} & {{MASK_WIDTH-64{1'b0}}, 64'hffffffff_ffffffff})
                            ) << lsu_aligned_offset_l;

wire [15:0] lsu_full_wmask  = (({16{lsu_size_b}} & 16'b0000_0001)
                             | ({16{lsu_size_h}} & 16'b0000_0011)
                             | ({16{lsu_size_w}} & 16'b0000_1111)
                             | ({16{lsu_size_d}} & 16'b1111_1111)
                             ) << lsu_addr_i[2:0];

wire [63:0] lsu_rmask_l  = lsu_full_rmask[63:0];
wire [63:0] lsu_rmask_h  = lsu_full_rmask[127:64];
wire [7:0]  lsu_wmask_l  = lsu_full_wmask[7:0];
wire [7:0]  lsu_wmask_h  = lsu_full_wmask[15:8];

wire [63:0] lsu_wdata_l  = (lsu_wdata_i << lsu_aligned_offset_l) & lsu_rmask_l;
wire [63:0] lsu_wdata_h  = (lsu_wdata_i >> lsu_aligned_offset_h) & lsu_rmask_h;

// ------------------Number of transmission------------------
always @(posedge clk) begin
    if (~rst_n) begin
        lsu_req_len <= 8'd0;
    end
    else if (nxt_state==LS_REQ_0) begin
        lsu_req_len <= 8'd0;
    end
    else if (nxt_state==LS_WAIT && ram_rw_ready_i) begin
        lsu_req_len <= lsu_req_len + 1'd1;
    end
end


//-----------state machine-----------
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
            if (ifu_cen_i || ifu_cen_reg)
                nxt_state = IF_REQ;
            else
                nxt_state = IDLE;
        end

        IF_REQ : begin
                nxt_state = IF_WAIT;
        end

        IF_WAIT : begin
            if (ram_rw_ready_i)
                nxt_state = LS_HOLD;
            else
                nxt_state = IF_WAIT;
        end

        LS_HOLD : begin
            if (ifu_instr_valid_reg[2]
                && req_timer_valid
                && lsu_cen_i
                )
                nxt_state = LS_REQ_TIMER;

            else if (ifu_instr_valid_reg[2]
                && ~req_timer_valid
                && lsu_cen_i
                )
                nxt_state = LS_REQ_0;

            else if (| ifu_instr_valid_reg[1:0])
                nxt_state = LS_HOLD;

            else if (ifu_cen_reg)
                nxt_state = IF_REQ;

            else
                nxt_state = LS_HOLD;
        end

        LS_REQ_TIMER : begin
                nxt_state = LS_WAIT;
        end

        LS_REQ_0 : begin
                nxt_state = LS_WAIT;
        end

        LS_REQ_1 : begin
                nxt_state = LS_WAIT;
        end

        LS_WAIT : begin
            if (timer_ready_i) begin
                nxt_state = IDLE;
            end
            else if (ram_rw_ready_i ) begin
                if (lsu_req_len==lsu_len)
                    nxt_state = IDLE;
                else
                    nxt_state = LS_REQ_1;
            end
            else
                nxt_state = LS_WAIT;
        end

        default : nxt_state = IDLE;
    endcase
end


//----------ifu port---------
always @(posedge clk) begin
    if (~rst_n) begin
        ifu_instr_valid_reg <= 3'b0;
    end
    else begin
        ifu_instr_valid_reg[0] <= ifu_instr_valid_i;
        ifu_instr_valid_reg[1] <= ifu_instr_valid_reg[0];
        ifu_instr_valid_reg[2] <= ifu_instr_valid_reg[1];
    end
end

always @(posedge clk) begin
    if (~rst_n) begin
        ifu_cen_reg <= 1'b0;
    end
    else if (nxt_state==IF_REQ) begin
        ifu_cen_reg <= 1'b0;
    end
    else if (ifu_cen_i) begin
        ifu_cen_reg <= 1'b1;
    end
end

always @(posedge clk) begin
    if (~rst_n) begin
        ifu_addr_reg <= 64'b0;
        ifu_size_reg <= 3'b0;
    end
    else if (ifu_cen_i) begin
        ifu_addr_reg <= ifu_addr_i;
        ifu_size_reg <= ifu_size_i;
    end
end

assign ram_ifu_valid_o = (cur_state == IF_WAIT)
                        & ram_rw_ready_i;

assign ram_ifu_data_o  = ram_rw_data_i;


//-----------lsu port------------
wire [63:0] lsu_rdata_l  = (ram_rw_data_i & lsu_rmask_l) >> lsu_aligned_offset_l;
wire [63:0] lsu_rdata_h  = (ram_rw_data_i & lsu_rmask_h) << lsu_aligned_offset_h;
reg  [63:0] lsu_rdata;
reg         lsu_rdata_valid;

always @(posedge clk) begin
    if (~rst_n) begin
        lsu_rdata <= 64'b0;
        lsu_rdata_valid <= 1'b0;
    end
    else if (req_timer_valid) begin
        lsu_rdata <= timer_rdata_i;
        lsu_rdata_valid <= timer_ready_i;
    end
    else if (cur_state==LS_WAIT && ram_rw_ready_i) begin
        if (~lsu_aligned && lsu_crossover) begin
            if (lsu_req_len==8'd1) begin
                lsu_rdata <= lsu_rdata | lsu_rdata_h;
                lsu_rdata_valid <= 1'b1;
            end
            else begin
                lsu_rdata <= lsu_rdata_l;
                lsu_rdata_valid <= 1'b0;
            end
        end
        else begin
            lsu_rdata <= lsu_rdata_l;
            lsu_rdata_valid <= 1'b1;
        end
    end
    else begin
        lsu_rdata_valid <= 1'b0;
    end
end

assign ram_lsu_data_o  = lsu_rdata;
assign ram_lsu_valid_o = lsu_rdata_valid;

//-----------timer port----------
assign req_timer_valid  =  (lsu_addr_i == `ADDR_MTIME)
                        || (lsu_addr_i == `ADDR_MTIMECMP);

assign ram_timer_cen_o   = cur_state==LS_REQ_TIMER;
assign ram_timer_wen_o   = lsu_wen_i;
assign ram_timer_addr_o  = lsu_addr_i;
assign ram_timer_wdata_o = lsu_wdata_i;


//-----------ram port--------------
always @(posedge clk) begin
    if(~rst_n) begin
        ram_rw_addr_o  <= 0;
        ram_rw_wen_o   <= 0;
        ram_rw_cen_o   <= 0;
        ram_rw_wdata_o <= 0;
        ram_rw_size_o  <= 0;
        ram_rw_wmask_o <= 0;
    end
    else begin
        case (nxt_state)
            IF_REQ : begin
                if (ifu_cen_i) begin
                    ram_rw_cen_o   <= 1'b1;
                    ram_rw_wen_o   <= 1'b0;
                    ram_rw_addr_o  <= ifu_addr_i;
                    ram_rw_wdata_o <= 64'b0;
                    ram_rw_size_o  <= ifu_size_i;
                end
                else if (ifu_cen_reg) begin
                    ram_rw_cen_o   <= 1'b1;
                    ram_rw_wen_o   <= 1'b0;
                    ram_rw_addr_o  <= ifu_addr_reg;
                    ram_rw_wdata_o <= 64'b0;
                    ram_rw_size_o  <= ifu_size_reg;
                end
            end

            LS_REQ_0: begin
                ram_rw_cen_o   <= 1'b1;
                ram_rw_wen_o   <= lsu_wen_i;
                ram_rw_addr_o  <= lsu_addr;
                ram_rw_wdata_o <= lsu_wdata_l;
                ram_rw_size_o  <= 3'b011;
                ram_rw_wmask_o <= lsu_wmask_l;
            end

            LS_REQ_1: begin
                ram_rw_cen_o   <= 1'b1;
                ram_rw_wen_o   <= lsu_wen_i;
                ram_rw_addr_o  <= lsu_addr_aligned + 64'd8;
                ram_rw_wdata_o <= lsu_wdata_h;
                ram_rw_size_o  <= 3'b011;
                ram_rw_wmask_o <= lsu_wmask_h;
            end

            LS_WAIT, IF_WAIT  : begin
                ram_rw_cen_o   <= ram_rw_cen_o  ;
                ram_rw_wen_o   <= ram_rw_wen_o  ;
                ram_rw_addr_o  <= ram_rw_addr_o ;
                ram_rw_wdata_o <= ram_rw_wdata_o;
                ram_rw_size_o  <= ram_rw_size_o ;
                ram_rw_wmask_o <= ram_rw_wmask_o;
            end

            default : begin
                ram_rw_addr_o  <= 0;
                ram_rw_wen_o   <= 0;
                ram_rw_cen_o   <= 0;
                ram_rw_wdata_o <= 0;
                ram_rw_size_o  <= 0;
                ram_rw_wmask_o <= 0;
            end
        endcase
    end
end



endmodule

// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.07.21
// Registers File

 

module ysyx_210238_reg_file(
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

// Copyright 2022 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2022.04.11
// RVCPU with AXI master top module

 

module ysyx_210238_rvcpu_axi (
    input clk,
    input rst_n,

    // AXI master
    // write address channel
    output [3:0]    axi_aw_id_o,
    output [31:0]   axi_aw_addr_o,
    output [7:0]    axi_aw_len_o,
    output [2:0]    axi_aw_size_o,
    output [1:0]    axi_aw_burst_o,
    output          axi_aw_lock_o,
    output [3:0]    axi_aw_cache_o,
    output [2:0]    axi_aw_prot_o,
    output [3:0]    axi_aw_qos_o,
    output [3:0]    axi_aw_region_o,
    output [0:0]    axi_aw_user_o,
    output          axi_aw_valid_o,
    input           axi_aw_ready_i,

    // write data channel
    input           axi_w_ready_i,
    output          axi_w_valid_o,
    output [63:0]   axi_w_data_o,
    output [7:0]    axi_w_strb_o,
    output          axi_w_last_o,
    output [0:0]    axi_w_user_o,

    // write response channel
    output          axi_b_ready_o,
    input           axi_b_valid_i,
    input  [1:0]    axi_b_resp_i,
    input  [3:0]    axi_b_id_i,
    input  [0:0]    axi_b_user_i,

    // read address channel
    input           axi_ar_ready_i,
    output          axi_ar_valid_o,
    output [31:0]   axi_ar_addr_o,
    output [2:0]    axi_ar_prot_o,
    output [3:0]    axi_ar_id_o,
    output [0:0]    axi_ar_user_o,
    output [7:0]    axi_ar_len_o,
    output [2:0]    axi_ar_size_o,
    output [1:0]    axi_ar_burst_o,
    output          axi_ar_lock_o,
    output [3:0]    axi_ar_cache_o,
    output [3:0]    axi_ar_qos_o,
    output [3:0]    axi_ar_region_o,

    // read data channel
    output          axi_r_ready_o,
    input           axi_r_valid_i,
    input  [1:0]    axi_r_resp_i,
    input  [63:0]   axi_r_data_i,
    input           axi_r_last_i,
    input  [3:0]    axi_r_id_i,
    input  [0:0]    axi_r_user_i
);

wire         ram_rw_cen_o;
wire         ram_rw_wen_o;
wire  [63:0] ram_rw_addr_o;
wire  [63:0] ram_rw_wdata_o;
wire  [2:0]  ram_rw_size_o;
wire  [7:0]  ram_rw_wmask_o;
wire         ram_rw_ready_i;
wire  [63:0] ram_rw_data_i;
wire  [1:0]  rw_resp_o;

ysyx_210238_axi_master_if#(
    .RW_DATA_WIDTH   ( 64 ),
    .RW_ADDR_WIDTH   ( 32 ),
    .AXI_DATA_WIDTH  ( 64 ),
    .AXI_ADDR_WIDTH  ( 32 ),
    .AXI_ID_WIDTH    ( 4 ),
    .AXI_USER_WIDTH  ( 1 )
)u_axi_master_if(
    .clk             ( clk             ),
    .rst_n           ( rst_n           ),
    .rw_id_i         ( 1'b0            ),
    .rw_cen_i        ( ram_rw_cen_o    ),
    .rw_wen_i        ( ram_rw_wen_o    ),
    .rw_addr_i       ( ram_rw_addr_o[31:0] ),
    .rw_size_i       ( ram_rw_size_o   ),
    .rw_wdata_i      ( ram_rw_wdata_o  ),
    .rw_wmask_i      ( ram_rw_wmask_o  ),
    .rw_ready_o      ( ram_rw_ready_i  ),
    .rw_rdata_o      ( ram_rw_data_i   ),
    .rw_resp_o       ( rw_resp_o       ),
    .axi_aw_id_o     ( axi_aw_id_o     ),
    .axi_aw_addr_o   ( axi_aw_addr_o   ),
    .axi_aw_len_o    ( axi_aw_len_o    ),
    .axi_aw_size_o   ( axi_aw_size_o   ),
    .axi_aw_burst_o  ( axi_aw_burst_o  ),
    .axi_aw_lock_o   ( axi_aw_lock_o   ),
    .axi_aw_cache_o  ( axi_aw_cache_o  ),
    .axi_aw_prot_o   ( axi_aw_prot_o   ),
    .axi_aw_qos_o    ( axi_aw_qos_o    ),
    .axi_aw_region_o ( axi_aw_region_o ),
    .axi_aw_user_o   ( axi_aw_user_o   ),
    .axi_aw_valid_o  ( axi_aw_valid_o  ),
    .axi_aw_ready_i  ( axi_aw_ready_i  ),
    .axi_w_ready_i   ( axi_w_ready_i   ),
    .axi_w_valid_o   ( axi_w_valid_o   ),
    .axi_w_data_o    ( axi_w_data_o    ),
    .axi_w_strb_o    ( axi_w_strb_o    ),
    .axi_w_last_o    ( axi_w_last_o    ),
    .axi_w_user_o    ( axi_w_user_o    ),
    .axi_b_ready_o   ( axi_b_ready_o   ),
    .axi_b_valid_i   ( axi_b_valid_i   ),
    .axi_b_resp_i    ( axi_b_resp_i    ),
    .axi_b_id_i      ( axi_b_id_i      ),
    .axi_b_user_i    ( axi_b_user_i    ),
    .axi_ar_ready_i  ( axi_ar_ready_i  ),
    .axi_ar_valid_o  ( axi_ar_valid_o  ),
    .axi_ar_addr_o   ( axi_ar_addr_o   ),
    .axi_ar_prot_o   ( axi_ar_prot_o   ),
    .axi_ar_id_o     ( axi_ar_id_o     ),
    .axi_ar_user_o   ( axi_ar_user_o   ),
    .axi_ar_len_o    ( axi_ar_len_o    ),
    .axi_ar_size_o   ( axi_ar_size_o   ),
    .axi_ar_burst_o  ( axi_ar_burst_o  ),
    .axi_ar_lock_o   ( axi_ar_lock_o   ),
    .axi_ar_cache_o  ( axi_ar_cache_o  ),
    .axi_ar_qos_o    ( axi_ar_qos_o    ),
    .axi_ar_region_o ( axi_ar_region_o ),
    .axi_r_ready_o   ( axi_r_ready_o   ),
    .axi_r_valid_i   ( axi_r_valid_i   ),
    .axi_r_resp_i    ( axi_r_resp_i    ),
    .axi_r_data_i    ( axi_r_data_i    ),
    .axi_r_last_i    ( axi_r_last_i    ),
    .axi_r_id_i      ( axi_r_id_i      ),
    .axi_r_user_i    ( axi_r_user_i    )
);

ysyx_210238_rvcpu u_rvcpu(
    .clk            ( clk            ),
    .rst_n          ( rst_n          ),
    .ram_rw_cen_o   ( ram_rw_cen_o   ),
    .ram_rw_wen_o   ( ram_rw_wen_o   ),
    .ram_rw_addr_o  ( ram_rw_addr_o  ),
    .ram_rw_wdata_o ( ram_rw_wdata_o ),
    .ram_rw_size_o  ( ram_rw_size_o  ),
    .ram_rw_wmask_o ( ram_rw_wmask_o ),
    .ram_rw_ready_i ( ram_rw_ready_i ),
    .ram_rw_data_i  ( ram_rw_data_i  )
);


endmodule


// Copyright 2022 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2022.04.12
// RVCPU with AXI master top module

 

module ysyx_210238_rvcpu (
    input clk,
    input rst_n,

    // ram port
    output           ram_rw_cen_o,
    output           ram_rw_wen_o,
    output    [63:0] ram_rw_addr_o,
    output    [63:0] ram_rw_wdata_o,
    output    [2:0]  ram_rw_size_o,
    output    [7:0]  ram_rw_wmask_o,
    input            ram_rw_ready_i,
    input     [63:0] ram_rw_data_i
);

//================Signal===================
wire ifu_ram_cen_o  ;
wire [63:0] ifu_ram_addr_o ;
wire [2:0 ] ifu_ram_size_o ;
wire [63:0] ram_ifu_data_o ;
wire ram_ifu_valid_o;
wire [31:0] ifu_instr_o;
wire [63:0] ifu_pc_o;
wire  ifu_instr_valid_o;
wire [95:0] if_id_data;

wire [63:0] rs1_rdata_o;
wire [63:0] rs2_rdata_o;
wire  idu_jump_o ;
wire [63:0] idu_jump_pc_o;
wire [4:0] idu_rs1_addr_o ;
wire [4:0] idu_rs2_addr_o ;
wire  idu_rs1_cen_o  ;
wire  idu_rs2_cen_o  ;
wire [63:0] idu_imm_o      ;
wire [63:0] idu_rs1_rdata_o ;
wire [63:0] idu_rs2_rdata_o ;
wire [63:0] idu_pc_o       ;
wire [12:0] idu_alu_info_o  ;
wire [8:0]  idu_csr_info_o  ;
wire  idu_op2_is_imm_o;
wire  idu_op_is_jal_o ;
wire [10:0] idu_ls_info_o    ;
wire  idu_mem_read_o   ;
wire  idu_mem_write_o ;
wire  idu_rd_wen_o    ;
wire [4:0] idu_rd_addr_o    ;
wire  idu_op_is_branch_o;
wire  idu_csr_wen_o  ;
wire [63:0] idu_csr_rdata_o;
wire [11:0] idu_csr_raddr_o;
wire [11:0] idu_csr_waddr_o;
wire [400:0] id_ex_data ;

wire  exu_rd_wen_o;
wire [63:0] exu_rd_data_o;
wire [4:0] exu_rd_addr_o;
wire [63:0] exu_mem_addr_o;
wire [63:0] exu_mem_wdata_o;
wire [10:0] exu_ls_info_o;
wire  exu_mem_read_o;
wire  exu_mem_write_o;
wire [63:0] exu_csr_wdata_o;
wire  exu_csr_wen_o;
wire [11:0] exu_csr_waddr_o;
wire [63:0] csrfile_cpu_csr_rdata_o;
wire [63:0] csrfile_clint_csr_mtvec_o;
wire [63:0] csrfile_clint_csr_mepc_o;
wire [63:0] csrfile_clint_csr_mstatus_o;
wire  csrfile_global_int_en_o;
wire  csrfile_mtime_int_en_o;
wire  csrfile_mtime_int_pend_o;
wire [63:0] clint_int_addr_o;
wire  clint_int_valid_o;
wire  clint_hold_o;
wire clint_mepc_wen_o     ;
wire [63:0] clint_mepc_wdata_o   ;
wire clint_mcause_wen_o   ;
wire [63:0] clint_mcause_wdata_o ;
wire clint_mstatus_wen_o  ;
wire [63:0] clint_mstatus_wdata_o;
wire [210:0] ex_ls_data;

wire  lsu_ram_cen_o;
wire  lsu_ram_wen_o;
wire [63:0] lsu_ram_addr_o;
wire [2:0] lsu_ram_size_o;
wire [63:0] lsu_ram_wdata_o;
wire  lsu_rd_wen_o;
wire [63:0] lsu_rd_data_o;
wire [4:0] lsu_rd_addr_o;
wire [63:0] lsu_mem_rdata_o;
wire  lsu_mem_read_o;
wire  lsu_hold_o;
wire [134:0] ls_wb_data;

wire  wbu_rd_wen_o;
wire [4:0] wbu_rd_addr_o;
wire [63:0] wbu_rd_wdata_o;
wire  o_forward_ex_rs1;
wire  o_forward_ex_rs2;
wire  o_forward_ls_rs1;
wire  o_forward_ls_rs2;
wire  o_load_use    ;
wire  o_ctrl_forward_ex_rs1;
wire  o_ctrl_forward_ex_rs2;
wire  o_ctrl_forward_ls_rs1;
wire  o_ctrl_forward_ls_rs2;
wire  o_ctrl_load_use;
wire  timer_int_o;
wire [63:0] timer_rdata_o;
wire  timer_ready_o;
wire  ram_lsu_valid_o;
wire [63:0] ram_lsu_data_o  ;
wire  ram_timer_cen_o ;
wire  ram_timer_wen_o  ;
wire [63:0] ram_timer_addr_o ;
wire [63:0] ram_timer_wdata_o;



wire [31:0] if_id_instr = if_id_data[95-:32];
wire [63:0] if_id_pc = if_id_data[63:0];

wire [4:0]  id_ex_rs1_addr = id_ex_data[400-:5];
wire [4:0]  id_ex_rs2_addr = id_ex_data[395-:5];
wire        id_ex_rs1_cen  = id_ex_data[390-:1];
wire        id_ex_rs2_cen  = id_ex_data[389-:1];
wire [63:0] id_ex_imm      = id_ex_data[388-:64];
wire [63:0] id_ex_rs1_rdata= id_ex_data[324-:64] ;
wire [63:0] id_ex_rs2_rdata= id_ex_data[260-:64] ;
wire [63:0] id_ex_pc       = id_ex_data[196-:64];
wire [12:0] id_ex_alu_info = id_ex_data[132-:13];
wire [8:0]  id_ex_csr_info = id_ex_data[119-:9];
wire        id_ex_op2_is_imm= id_ex_data[110-:1];
wire        id_ex_op_is_jal = id_ex_data[109-:1];
wire [10:0] id_ex_ls_info   = id_ex_data[108-:11];
wire        id_ex_mem_read  = id_ex_data[97-:1];
wire        id_ex_mem_write = id_ex_data[96-:1];
wire        id_ex_rd_wen    = id_ex_data[95-:1];
wire [4:0]  id_ex_rd_addr   = id_ex_data[94-:5] ;
wire        id_ex_op_is_branch = id_ex_data[89-:1];
wire        id_ex_csr_wen   = id_ex_data[88-:1];
wire [63:0] id_ex_csr_rdata = id_ex_data[87-:64];
wire [11:0] id_ex_csr_raddr = id_ex_data[23-:12];
wire [11:0] id_ex_csr_waddr = id_ex_data[11-:12];

wire        ex_ls_rd_wen    = ex_ls_data[210-:1];
wire [63:0] ex_ls_rd_data   = ex_ls_data[209-:64];
wire [4:0]  ex_ls_rd_addr   = ex_ls_data[145-:5];
wire [63:0] ex_ls_mem_addr  = ex_ls_data[140-:64];
wire [63:0] ex_ls_mem_wdata = ex_ls_data[76-:64];
wire [10:0] ex_ls_ls_info   = ex_ls_data[12-:11];
wire        ex_ls_mem_read  = ex_ls_data[1-:1];
wire        ex_ls_mem_write = ex_ls_data[0-:1];

wire        ls_wb_rd_wen    = ls_wb_data[134-:1];
wire [63:0] ls_wb_rd_data   = ls_wb_data[133-:64];
wire [4:0]  ls_wb_rd_addr   = ls_wb_data[69-:5];
wire [63:0] ls_wb_mem_rdata = ls_wb_data[64-:64];
wire        ls_wb_mem_read  = ls_wb_data[0-:1];


//=================Module===================
//============Stage 1=====================
//-------ifu---------------
ysyx_210238_ifu u_ifu(
    .clk               ( clk               ),
    .rst_n             ( rst_n             ),
    .ifu_ram_cen_o     ( ifu_ram_cen_o     ),
    .ifu_ram_addr_o    ( ifu_ram_addr_o    ),
    .ifu_ram_size_o    ( ifu_ram_size_o    ),
    .ifu_ram_data_i    ( ram_ifu_data_o    ),
    .ifu_ram_valid_i   ( ram_ifu_valid_o   ),
    .jump_i            ( idu_jump_o
                     && ~o_ctrl_load_use ),
    .hold_i            ( o_load_use
                      || lsu_hold_o
                      || clint_hold_o ),
    .jump_pc_i         ( idu_jump_pc_o         ),
    .ifu_instr_o       ( ifu_instr_o       ),
    .ifu_instr_valid_o ( ifu_instr_valid_o ),
    .ifu_pc_o          ( ifu_pc_o          ),
    .int_cen_i         ( clint_int_valid_o ),
    .int_addr_i        ( clint_int_addr_o )
);

// when load use or jump, stall
ysyx_210238_pipeline_reg#(
    .N       ( 96 )
)u_pipeline_reg_if_id(
    .clk     ( clk     ),
    .rst_n   ( rst_n   ),
    .clear_i ( (idu_jump_o && ~o_ctrl_load_use) || ~ifu_instr_valid_o),
    .hold_i  ( o_load_use || o_ctrl_load_use || lsu_hold_o || clint_hold_o ),
    .data_i  ( {ifu_instr_o,
                ifu_pc_o} ),
    .data_o  ( if_id_data  )
);


//==============Stage 2========================
//---------reg_file---------
ysyx_210238_reg_file u_reg_file(
    .clk         ( clk         ),
    .rst_n       ( rst_n       ),
    .wen_i       ( wbu_rd_wen_o ),
    .addr_i      ( wbu_rd_addr_o ),
    .wdata_i     ( wbu_rd_wdata_o ),
    .rs1_cen_i   ( idu_rs1_cen_o ),
    .rs2_cen_i   ( idu_rs2_cen_o ),
    .rs1_addr_i  ( idu_rs1_addr_o ),
    .rs2_addr_i  ( idu_rs2_addr_o ),
    .rs1_rdata_o ( rs1_rdata_o ),
    .rs2_rdata_o ( rs2_rdata_o  )
);

//-------idu----------
ysyx_210238_idu u_idu(
    .pc_i               ( if_id_pc),
    .instr_i            ( if_id_instr ),
    .idu_jump_o         ( idu_jump_o         ),
    .idu_jump_pc_o      ( idu_jump_pc_o      ),
    .rs1_rdata_i        ( rs1_rdata_o ),
    .rs2_rdata_i        ( rs2_rdata_o ),
    .idu_rs1_addr_o     ( idu_rs1_addr_o     ),
    .idu_rs2_addr_o     ( idu_rs2_addr_o     ),
    .idu_rs1_cen_o      ( idu_rs1_cen_o      ),
    .idu_rs2_cen_o      ( idu_rs2_cen_o      ),
    .idu_imm_o          ( idu_imm_o          ),
    .idu_rs1_rdata_o    ( idu_rs1_rdata_o    ),
    .idu_rs2_rdata_o    ( idu_rs2_rdata_o    ),
    .idu_pc_o           ( idu_pc_o           ),
    .idu_alu_info_o     ( idu_alu_info_o     ),
    .idu_csr_info_o     ( idu_csr_info_o     ),
    .idu_op2_is_imm_o   ( idu_op2_is_imm_o   ),
    .idu_op_is_jal_o    ( idu_op_is_jal_o    ),
    .idu_ls_info_o      ( idu_ls_info_o      ),
    .idu_mem_read_o     ( idu_mem_read_o     ),
    .idu_mem_write_o    ( idu_mem_write_o    ),
    .idu_rd_wen_o       ( idu_rd_wen_o       ),
    .idu_rd_addr_o      ( idu_rd_addr_o      ),
    .idu_op_is_branch_o ( idu_op_is_branch_o ),
    .forward_ex_rs1_i   ( o_ctrl_forward_ex_rs1 ),
    .forward_ex_rs2_i   ( o_ctrl_forward_ex_rs2 ),
    .forward_ls_rs1_i   ( o_ctrl_forward_ls_rs1 ),
    .forward_ls_rs2_i   ( o_ctrl_forward_ls_rs2 ),
    .ex_ls_mem_read_i   ( ex_ls_mem_read ),
    .exu_rd_data_i      ( exu_rd_data_o  ),
    .lsu_rd_data_i      ( lsu_rd_data_o ),
    .lsu_mem_rdata_i    ( lsu_mem_rdata_o ),
    .csr_rdata_i        ( csrfile_cpu_csr_rdata_o ),
    .idu_csr_wen_o      ( idu_csr_wen_o      ),
    .idu_csr_rdata_o    ( idu_csr_rdata_o    ),
    .idu_csr_raddr_o    ( idu_csr_raddr_o    ),
    .idu_csr_waddr_o    ( idu_csr_waddr_o    )
);

ysyx_210238_pipeline_reg#(
    .N       ( 401 )
)u_pipeline_reg_id_ex(
    .clk     ( clk     ),
    .rst_n   ( rst_n   ),
    .clear_i ( 1'b0 ),
    .hold_i  ( lsu_hold_o || clint_hold_o ),
    .data_i  ( {idu_rs1_addr_o,
                idu_rs2_addr_o,
                idu_rs1_cen_o,
                idu_rs2_cen_o,
                idu_imm_o,
                idu_rs1_rdata_o,
                idu_rs2_rdata_o,
                idu_pc_o,
                idu_alu_info_o,
                idu_csr_info_o    ,
                idu_op2_is_imm_o  ,
                idu_op_is_jal_o   ,
                idu_ls_info_o     ,
                idu_mem_read_o    ,
                idu_mem_write_o   ,
                idu_rd_wen_o      ,
                idu_rd_addr_o     ,
                idu_op_is_branch_o,
                idu_csr_wen_o  ,
                idu_csr_rdata_o,
                idu_csr_raddr_o,
                idu_csr_waddr_o} ),
    .data_o  ( id_ex_data  )
);

//===============Stage 3======================
//---------ex-----------
ysyx_210238_exu u_exu(
    .imm_i            ( id_ex_imm ),
    .rs1_rdata_i      ( id_ex_rs1_rdata ),
    .rs2_rdata_i      ( id_ex_rs2_rdata ),
    .csr_rdata_i      ( id_ex_csr_rdata ),
    .pc_i             ( id_ex_pc ),
    .alu_info_i       ( id_ex_alu_info ),
    .csr_info_i       ( id_ex_csr_info[5:0] ),
    .op2_is_imm_i     ( id_ex_op2_is_imm ),
    .op_is_jal_i      ( id_ex_op_is_jal ),
    .rd_wen_i         ( id_ex_rd_wen ),
    .exu_rd_wen_o     ( exu_rd_wen_o     ),
    .rd_addr_i        ( id_ex_rd_addr ),
    .exu_rd_data_o    ( exu_rd_data_o    ),
    .exu_rd_addr_o    ( exu_rd_addr_o    ),
    .ls_info_i        ( id_ex_ls_info ),
    .mem_read_i       ( id_ex_mem_read ),
    .mem_write_i      ( id_ex_mem_write ),
    .exu_mem_addr_o   ( exu_mem_addr_o   ),
    .exu_mem_wdata_o  ( exu_mem_wdata_o  ),
    .exu_ls_info_o    ( exu_ls_info_o    ),
    .exu_mem_read_o   ( exu_mem_read_o   ),
    .exu_mem_write_o  ( exu_mem_write_o  ),
    .forward_ex_rs1_i ( o_forward_ex_rs1 ),
    .forward_ex_rs2_i ( o_forward_ex_rs2 ),
    .forward_ls_rs1_i ( o_forward_ls_rs1 ),
    .forward_ls_rs2_i ( o_forward_ls_rs2 ),
    .ex_ls_rd_data_i  ( ex_ls_rd_data ),
    .wbu_rd_wdata_i   ( wbu_rd_wdata_o ),
    .csr_wen_i        ( id_ex_csr_wen ),
    .csr_waddr_i      ( id_ex_csr_waddr ),
    .exu_csr_wdata_o  ( exu_csr_wdata_o  ),
    .exu_csr_wen_o    ( exu_csr_wen_o    ),
    .exu_csr_waddr_o  ( exu_csr_waddr_o  )
);

//-------------CSR-----------------
ysyx_210238_csr_file u_csr_file(
    .clk                         ( clk                         ),
    .rst_n                       ( rst_n                       ),
    .cpu_csr_wen_i               ( exu_csr_wen_o ),
    .cpu_csr_raddr_i             ( idu_csr_raddr_o ),
    .cpu_csr_waddr_i             ( exu_csr_waddr_o ),
    .cpu_csr_wdata_i             ( exu_csr_wdata_o ),
    .csrfile_cpu_csr_rdata_o     ( csrfile_cpu_csr_rdata_o     ),

    .clint_mepc_wen_i            ( clint_mepc_wen_o     ),
    .clint_mepc_wdata_i          ( clint_mepc_wdata_o   ),
    .clint_mcause_wen_i          ( clint_mcause_wen_o   ),
    .clint_mcause_wdata_i        ( clint_mcause_wdata_o ),
    .clint_mstatus_wen_i         ( clint_mstatus_wen_o  ),
    .clint_mstatus_wdata_i       ( clint_mstatus_wdata_o),
    .csrfile_clint_csr_mtvec_o   ( csrfile_clint_csr_mtvec_o   ),
    .csrfile_clint_csr_mepc_o    ( csrfile_clint_csr_mepc_o    ),
    .csrfile_clint_csr_mstatus_o ( csrfile_clint_csr_mstatus_o ),
    .csrfile_global_int_en_o     ( csrfile_global_int_en_o     ),
    .csrfile_mtime_int_en_o      ( csrfile_mtime_int_en_o      ),
    .csrfile_mtime_int_pend_o    ( csrfile_mtime_int_pend_o    ),
    .timer_int_i                 ( timer_int_o )
);

//-------------Clint----------------
reg [63:0] clint_if_id_pc;
always @(posedge clk) begin
    if (~rst_n)
        clint_if_id_pc <= 0;

    else if (clint_int_valid_o)
        clint_if_id_pc <= clint_int_addr_o;

    else if (idu_jump_o)
        clint_if_id_pc <= idu_jump_pc_o;

    else if (ifu_instr_valid_o)
        clint_if_id_pc <= ifu_pc_o;
end

ysyx_210238_clint u_clint(
    .clk               ( clk   ),
    .rst_n             ( rst_n ),
    .timer_int_i       ( timer_int_o ),
    .pc_i              ( clint_if_id_pc ),
    .jump_i            ( idu_jump_o ),
    .jump_pc_i         ( idu_jump_pc_o ),
    .expt_info_i       ( idu_csr_info_o[8:6] ),
    .clint_int_addr_o  ( clint_int_addr_o  ),
    .clint_int_valid_o ( clint_int_valid_o ),
    .clint_hold_o      ( clint_hold_o      ),
    .global_int_en_i   ( csrfile_global_int_en_o ),
    .mtime_int_en_i    ( csrfile_mtime_int_en_o ),
    .mtime_int_pend_i  ( csrfile_mtime_int_pend_o ),
    .csr_mtvec_i       ( csrfile_clint_csr_mtvec_o ),
    .csr_mepc_i        ( csrfile_clint_csr_mepc_o ),
    .csr_mstatus_i     ( csrfile_clint_csr_mstatus_o ),

    .clint_mepc_wen_o     ( clint_mepc_wen_o  ),
    .clint_mepc_wdata_o   ( clint_mepc_wdata_o),
    .clint_mcause_wen_o   ( clint_mcause_wen_o  ),
    .clint_mcause_wdata_o ( clint_mcause_wdata_o),
    .clint_mstatus_wen_o  ( clint_mstatus_wen_o  ),
    .clint_mstatus_wdata_o( clint_mstatus_wdata_o)
);

ysyx_210238_pipeline_reg#(
    .N       ( 211 )
)u_pipeline_reg_ex_ls(
    .clk     ( clk     ),
    .rst_n   ( rst_n   ),
    .clear_i ( ram_lsu_valid_o ),
    .hold_i  ( lsu_hold_o ),
    .data_i  ( {exu_rd_wen_o,
                exu_rd_data_o,
                exu_rd_addr_o,
                exu_mem_addr_o,
                exu_mem_wdata_o,
                exu_ls_info_o,
                exu_mem_read_o,
                exu_mem_write_o} ),
    .data_o  ( ex_ls_data  )
);

//===================Stage 4=========================
//---------lsu------------
ysyx_210238_lsu u_lsu(
    .clk             ( clk             ),
    .rst_n           ( rst_n           ),
    .mem_addr_i      ( ex_ls_mem_addr  ),
    .mem_wdata_i     ( ex_ls_mem_wdata ),
    .mem_read_i      ( ex_ls_mem_read  ),
    .mem_write_i     ( ex_ls_mem_write ),
    .ls_info_i       ( ex_ls_ls_info ),
    .lsu_ram_cen_o   ( lsu_ram_cen_o   ),
    .lsu_ram_wen_o   ( lsu_ram_wen_o   ),
    .lsu_ram_addr_o  ( lsu_ram_addr_o  ),
    .lsu_ram_size_o  ( lsu_ram_size_o  ),
    .lsu_ram_wdata_o ( lsu_ram_wdata_o ),
    .lsu_ram_data_i  ( ram_lsu_data_o ),
    .lsu_ram_ready_i ( ram_lsu_valid_o ),
    .rd_wen_i        ( ex_ls_rd_wen ),
    .rd_data_i       ( ex_ls_rd_data),
    .rd_addr_i       ( ex_ls_rd_addr ),
    .lsu_rd_wen_o    ( lsu_rd_wen_o    ),
    .lsu_rd_data_o   ( lsu_rd_data_o   ),
    .lsu_rd_addr_o   ( lsu_rd_addr_o   ),
    .lsu_mem_rdata_o ( lsu_mem_rdata_o ),
    .lsu_mem_read_o  ( lsu_mem_read_o  ),
    .lsu_hold_o      ( lsu_hold_o      )
);

ysyx_210238_pipeline_reg#(
    .N       ( 135 )
)u_pipeline_reg_ls_wb(
    .clk     ( clk     ),
    .rst_n   ( rst_n   ),
    .clear_i ( 1'b0 ),
    .hold_i  ( 1'b0 ),
    .data_i  ( {lsu_rd_wen_o   ,
                lsu_rd_data_o  ,
                lsu_rd_addr_o  ,
                lsu_mem_rdata_o,
                lsu_mem_read_o } ),
    .data_o  ( ls_wb_data  )
);

//=====================Stage 5====================
//------------wbu----------------
ysyx_210238_wbu u_wbu(
    .rd_data_i     ( ls_wb_rd_data ),
    .rd_addr_i     ( ls_wb_rd_addr ),
    .rd_wen_i      ( ls_wb_rd_wen ),
    .mem_read_i    ( ls_wb_mem_read ),
    .mem_rdata_i   ( ls_wb_mem_rdata ),
    .wbu_rd_wen_o  ( wbu_rd_wen_o  ),
    .wbu_rd_addr_o ( wbu_rd_addr_o ),
    .wbu_rd_wdata_o  ( wbu_rd_wdata_o  )
);

//------------hazard detect---------
ysyx_210238_hdu u_hdu(
    .i_id_ex_rs1           ( id_ex_rs1_addr ),
    .i_id_ex_rs2           ( id_ex_rs2_addr ),
    .i_id_ex_rs1_cen       ( id_ex_rs1_cen  ),
    .i_id_ex_rs2_cen       ( id_ex_rs2_cen  ),

    .i_if_id_rs1           ( idu_rs1_addr_o ),
    .i_if_id_rs2           ( idu_rs2_addr_o ),
    .i_if_id_rs1_cen       ( idu_rs1_cen_o  ),
    .i_if_id_rs2_cen       ( idu_rs2_cen_o  ),

    .i_id_ex_rd            ( id_ex_rd_addr  ),
    .i_ex_ls_rd            ( ex_ls_rd_addr  ),
    .i_ls_wb_rd            ( ls_wb_rd_addr  ),
    .i_ex_ls_rd_wen        ( ex_ls_rd_wen   ),
    .i_ls_wb_rd_wen        ( ls_wb_rd_wen   ),
    .i_id_ex_mem_read      ( id_ex_mem_read ),
    .i_ls_wb_mem_read      ( ls_wb_mem_read ),

    .o_forward_ex_rs1      ( o_forward_ex_rs1      ),
    .o_forward_ex_rs2      ( o_forward_ex_rs2      ),
    .o_forward_ls_rs1      ( o_forward_ls_rs1      ),
    .o_forward_ls_rs2      ( o_forward_ls_rs2      ),
    .o_load_use            ( o_load_use            ),
    .i_op_is_branch        ( idu_op_is_branch_o ),
    .i_id_ex_rd_wen        ( id_ex_rd_wen ),
    .i_ex_ls_mem_read      ( ex_ls_mem_read ),
    .o_ctrl_forward_ex_rs1 ( o_ctrl_forward_ex_rs1 ),
    .o_ctrl_forward_ex_rs2 ( o_ctrl_forward_ex_rs2 ),
    .o_ctrl_forward_ls_rs1 ( o_ctrl_forward_ls_rs1 ),
    .o_ctrl_forward_ls_rs2 ( o_ctrl_forward_ls_rs2 ),
    .o_ctrl_load_use       ( o_ctrl_load_use       )
);

//--------------timer---------------
ysyx_210238_timer u_timer(
    .clk         ( clk         ),
    .rst_n       ( rst_n       ),
    .timer_int_o ( timer_int_o ),
    .cen_i       ( ram_timer_cen_o ),
    .wen_i       ( ram_timer_wen_o ),
    .addr_i      ( ram_timer_addr_o ),
    .wdata_i     ( ram_timer_wdata_o ),
    .timer_rdata_o  ( timer_rdata_o  ),
    .timer_ready_o  ( timer_ready_o  )
);


//---------------ram arbiter------------
ysyx_210238_ram_arbiter u_ram_arbiter(
    .clk               ( clk   ),
    .rst_n             ( rst_n ),
    .ifu_cen_i         ( ifu_ram_cen_o ),
    .ifu_addr_i        ( ifu_ram_addr_o ),
    .ifu_size_i        ( ifu_ram_size_o ),
    .ifu_instr_valid_i ( ifu_instr_valid_o ),
    .ram_ifu_valid_o   ( ram_ifu_valid_o   ),
    .ram_ifu_data_o    ( ram_ifu_data_o    ),

    .lsu_cen_i         ( lsu_ram_cen_o ),
    .lsu_wen_i         ( lsu_ram_wen_o ),
    .lsu_addr_i        ( lsu_ram_addr_o ),
    .lsu_size_i        ( lsu_ram_size_o ),
    .lsu_wdata_i       ( lsu_ram_wdata_o ),

    .ram_lsu_valid_o   ( ram_lsu_valid_o   ),
    .ram_lsu_data_o    ( ram_lsu_data_o    ),
    .ram_timer_cen_o   ( ram_timer_cen_o   ),
    .ram_timer_wen_o   ( ram_timer_wen_o   ),
    .ram_timer_addr_o  ( ram_timer_addr_o  ),
    .ram_timer_wdata_o ( ram_timer_wdata_o ),
    .timer_rdata_i     ( timer_rdata_o ),
    .timer_ready_i     ( timer_ready_o ),

    .ram_rw_cen_o      ( ram_rw_cen_o      ),
    .ram_rw_wen_o      ( ram_rw_wen_o      ),
    .ram_rw_addr_o     ( ram_rw_addr_o     ),
    .ram_rw_wdata_o    ( ram_rw_wdata_o    ),
    .ram_rw_wmask_o    ( ram_rw_wmask_o    ),
    .ram_rw_size_o     ( ram_rw_size_o     ),
    .ram_rw_ready_i    ( ram_rw_ready_i ),
    .ram_rw_data_i     ( ram_rw_data_i )
);

endmodule
 

// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.09.02
// Timer interruptor


 

module ysyx_210238_timer (
    input             clk,
    input             rst_n,

    output            timer_int_o,

    // cpu port
    input             cen_i,
    input             wen_i,
    input      [63:0] addr_i,
    input      [63:0] wdata_i,
    output reg [63:0] timer_rdata_o,
    output reg        timer_ready_o

);

reg  [63:0] mtime;
reg  [63:0] mtimecmp;

always @(posedge clk) begin
    if(~rst_n) begin
        mtime    <= 0;
        // mtimecmp <= 0;
        mtimecmp <= 64'hffff_ffff_ffff_ffff;
    end
    else if (wen_i & cen_i) begin
        case (addr_i)
            `ADDR_MTIME :    mtime    <= wdata_i;

            `ADDR_MTIMECMP : mtimecmp <= wdata_i;
        endcase
    end
    else begin
        mtime    <= mtime + 1'b1;
        mtimecmp <= mtimecmp;
    end
end

always @(*) begin
    case (addr_i)
        `ADDR_MTIME :    timer_rdata_o = mtime;

        `ADDR_MTIMECMP : timer_rdata_o = mtimecmp;

        default :        timer_rdata_o = 0;
    endcase
end

always @(posedge clk) begin
    if(~rst_n) begin
        timer_ready_o <= 1'b0;
    end
    else if (cen_i) begin
        timer_ready_o <= 1'b1;
    end
    else begin
        timer_ready_o <= 1'b0;
    end
end

assign timer_int_o = (mtime >= mtimecmp);

endmodule

// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.07.18
// Write Back unit
// as known as "WB"

 

module ysyx_210238_wbu(
    // wb
    input  [63:0] rd_data_i,
    input  [4:0]  rd_addr_i,
    input         rd_wen_i,
    input         mem_read_i,
    input  [63:0] mem_rdata_i,

    // reg_file
    output        wbu_rd_wen_o,
    output [4:0]  wbu_rd_addr_o,
    output [63:0] wbu_rd_wdata_o
);

assign wbu_rd_wen_o   = rd_wen_i;
assign wbu_rd_addr_o  = rd_addr_i;
assign wbu_rd_wdata_o = mem_read_i ? mem_rdata_i : rd_data_i;

endmodule // wbu


/* verilator lint_off EOFNEWLINE */
