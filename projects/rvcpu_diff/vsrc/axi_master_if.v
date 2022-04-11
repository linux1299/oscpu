`include "defines.v"

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


module axi_master_if # (
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
    input                               rw_valid_i,
    output                              rw_ready_o,
    input                               rw_req_i,
    output reg [RW_DATA_WIDTH-1:0]      rw_rdata_o,
    input  [RW_DATA_WIDTH-1:0]          rw_wdata_i,
    input  [RW_ADDR_WIDTH-1:0]          rw_addr_i,
    input  [2:0]                        rw_size_i,
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

    wire w_trans    = rw_req_i;
    wire r_trans    = ~rw_req_i;
    wire w_valid    = rw_valid_i & w_trans;
    wire r_valid    = rw_valid_i & r_trans;

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

    // Wirte State Machine
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

    // Read State Machine
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
                    default:                    r_state <= r_state;
                endcase
            end
        end
    end

    // ------------------Process Data------------------
    parameter ALIGNED_WIDTH = 3;
    parameter OFFSET_WIDTH  = 6;
    parameter MASK_WIDTH    = 128;
    parameter TRANS_LEN     = 1;

    wire aligned = rw_addr_i[2:0] == 0;
    wire size_b  = rw_size_i[1:0] == 2'b00;
    wire size_h  = rw_size_i[1:0] == 2'b01;
    wire size_w  = rw_size_i[1:0] == 2'b10;
    wire size_d  = rw_size_i[1:0] == 2'b11;

    wire [3:0]   addr_op1     = {1'b0, rw_addr_i[2:0]};

    wire [3:0]   addr_op2     =   ({4{size_b}} & {4'b0000})
                                | ({4{size_h}} & {4'b0001})
                                | ({4{size_w}} & {4'b0011})
                                | ({4{size_d}} & {4'b0111})
                                ;
    wire [3:0]   addr_end     = addr_op1 + addr_op2;
    wire         crossover    = addr_end[3]; // cross 8 byte boundry

    wire [7:0]   axi_len      = aligned ? 8'd0 : {7'b0, crossover}; // 0 or 1
    wire [2:0]   axi_size     = rw_size_i;

    wire [63:0]  axi_addr         = rw_addr_i;
    wire [5:0]   aligned_offset_l = {3'b0, rw_addr_i[2:0]} << 3;
    wire [5:0]   aligned_offset_h = AXI_DATA_WIDTH - aligned_offset_l;
    wire [127:0] mask             =    (({MASK_WIDTH{size_b}} & {{MASK_WIDTH-8{1'b0}},  8'hff})
                                      | ({MASK_WIDTH{size_h}} & {{MASK_WIDTH-16{1'b0}}, 16'hffff})
                                      | ({MASK_WIDTH{size_w}} & {{MASK_WIDTH-32{1'b0}}, 32'hffffffff})
                                      | ({MASK_WIDTH{size_d}} & {{MASK_WIDTH-64{1'b0}}, 64'hffffffff_ffffffff})
                                      ) << aligned_offset_l;

    wire [63:0] mask_l            = mask[63:0];
    wire [63:0] mask_h            = mask[127:64];

    wire [15:0] w_mask =    (({16{size_b}} & 16'b0000_0001)
                           | ({16{size_h}} & 16'b0000_0011)
                           | ({16{size_w}} & 16'b0000_1111)
                           | ({16{size_d}} & 16'b1111_1111)
                           ) << rw_addr_i[2:0];

    wire [7:0]  w_mask_l  = w_mask[7:0];
    wire [7:0]  w_mask_h  = w_mask[15:8];

    wire [AXI_ID_WIDTH-1:0]   axi_id            = {AXI_ID_WIDTH{1'b0}};
    wire [AXI_USER_WIDTH-1:0] axi_user          = {AXI_USER_WIDTH{1'b0}};

    reg  rw_ready;
    always @(posedge clk) begin
        if (~rst_n) begin
            rw_ready <= 0;
        end
        else if (trans_done) begin
            rw_ready <= 1;
        end
        else begin
            rw_ready <= 0;
        end
    end
    assign rw_ready_o = rw_ready;

    reg [1:0] rw_resp;
    wire      rw_resp_next = w_trans ? axi_b_resp_i : axi_r_resp_i;
    always @(posedge clk) begin
        if (~rst_n) begin
            rw_resp <= 0;
        end
        else if (trans_done) begin
            rw_resp <= rw_resp_next;
        end
        else begin
            rw_resp <= 0;
        end
    end
    assign rw_resp_o = rw_resp;



    // ------------------Number of transmission------------------
    reg [7:0] len;
    wire len_rst        = ~rst_n | (w_trans & w_state_idle) | (r_trans & r_state_idle);
    wire len_incr_en    = (len != axi_len) & (w_hs | r_hs);
    always @(posedge clk) begin
        if (len_rst) begin
            len <= 0;
        end
        else if (len_incr_en) begin
            len <= len + 1;
        end
    end


    // ------------------Write Transaction------------------
    // Write address channel signals
    assign axi_aw_id_o      = axi_id;
    
    assign axi_aw_addr_o    = axi_addr;

    assign axi_aw_len_o     = axi_len;

    assign axi_aw_size_o    = axi_size;
    // assign axi_aw_size_o    = 3'b011;

    assign axi_aw_burst_o   = `AXI_BURST_TYPE_INCR;
    assign axi_aw_lock_o    = 1'b0;
    assign axi_aw_cache_o   = `AXI_ARCACHE_NORMAL_NON_CACHEABLE_NON_BUFFERABLE;
    assign axi_aw_prot_o    = `AXI_PROT_UNPRIVILEGED_ACCESS;
    assign axi_aw_qos_o     = 4'h0;
    assign axi_aw_region_o  = 4'h0;
    assign axi_aw_user_o    = axi_user;
    assign axi_aw_valid_o   = w_state_addr;

    // Write data channel signals
    reg  [63:0] w_data;
    reg  [7:0]  w_strb;

    wire [63:0] w_data_l    = (rw_wdata_i << aligned_offset_l) & mask_l;
    wire [63:0] w_data_h    = (rw_wdata_i >> aligned_offset_h) & mask_h;

    assign axi_w_valid_o    = w_state_write;
    assign axi_w_data_o     = w_data;
    assign axi_w_strb_o     = w_strb;
    assign axi_w_last_o     = w_state_write & (len == axi_len);
    assign axi_w_user_o     = axi_user;

    always @(posedge clk) begin
        if (~rst_n) begin
            w_data <= 0;
            w_strb <= 0;
        end
        else if (len == 8'd0) begin
            w_data <= w_data_l;
            w_strb <= w_mask_l;
        end
        else if (len_incr_en || len == 8'd1) begin
            w_data <= w_data_h;
            w_strb <= w_mask_h;
        end
    end


    // Write resp channel signals
    assign axi_b_ready_o    = w_state_resp;

    // ------------------Read Transaction------------------

    // Read address channel signals
    assign axi_ar_valid_o   = r_state_addr;

    assign axi_ar_addr_o    = axi_addr;
    assign axi_ar_prot_o    = `AXI_PROT_UNPRIVILEGED_ACCESS;
    assign axi_ar_id_o      = axi_id;
    assign axi_ar_user_o    = axi_user;
    assign axi_ar_len_o     = axi_len;
    // assign axi_ar_size_o    = axi_size;
    assign axi_ar_size_o    = 3'b011;

    assign axi_ar_burst_o   = `AXI_BURST_TYPE_INCR;
    assign axi_ar_lock_o    = 1'b0;
    assign axi_ar_cache_o   = `AXI_ARCACHE_NORMAL_NON_CACHEABLE_NON_BUFFERABLE;
    assign axi_ar_qos_o     = 4'h0;

    // Read data channel signals
    assign axi_r_ready_o    = r_state_read;

    wire [AXI_DATA_WIDTH-1:0] axi_r_data_l  = (axi_r_data_i & mask_l) >> aligned_offset_l;
    wire [AXI_DATA_WIDTH-1:0] axi_r_data_h  = (axi_r_data_i & mask_h) << aligned_offset_h;

    generate
        for (genvar i = 0; i < TRANS_LEN; i = i+1) begin
            always @(posedge clk) begin
                if (~rst_n) begin
                    rw_rdata_o[i*AXI_DATA_WIDTH+:AXI_DATA_WIDTH] <= 0;
                end
                else if (r_hs) begin
                    if (~aligned & crossover) begin
                        if (len[0]) begin // high data
                            rw_rdata_o[AXI_DATA_WIDTH-1:0] <= rw_rdata_o[AXI_DATA_WIDTH-1:0] | axi_r_data_h;
                        end
                        else begin // low data
                            rw_rdata_o[AXI_DATA_WIDTH-1:0] <= axi_r_data_l;
                        end
                    end
                    else if (len == i) begin
                        rw_rdata_o[i*AXI_DATA_WIDTH+:AXI_DATA_WIDTH] <= axi_r_data_l;
                    end
                end
            end
        end
    endgenerate

endmodule