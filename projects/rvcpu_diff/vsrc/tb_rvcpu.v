`include "defines.v"

module tb_rvcpu;

parameter AXI_DATA_WIDTH      = 64;
parameter AXI_ADDR_WIDTH      = 64;
parameter AXI_ID_WIDTH        = 4;
parameter AXI_STRB_WIDTH      = 8;
parameter AXI_USER_WIDTH      = 1;
parameter WRITE_BUFFER_SIZE   = 32;  //KB
parameter READ_BUFFER_SIZE    = 32;  //KB

reg  clk;
reg  rst_n;

wire [AXI_ADDR_WIDTH-1:0]   aw_addr;
wire [2:0]                  aw_prot;
wire [3:0]                  aw_region;
wire [7:0]                  aw_len;
wire [2:0]                  aw_size;
wire [1:0]                  aw_burst;
wire                        aw_lock;
wire [3:0]                  aw_cache;
wire [3:0]                  aw_qos;
wire [AXI_ID_WIDTH-1:0]     aw_id;
wire [AXI_USER_WIDTH-1:0]   aw_user;
wire                        aw_ready;
wire                        aw_valid;
wire [AXI_ADDR_WIDTH-1:0]   ar_addr;
wire [2:0]                  ar_prot;
wire [3:0]                  ar_region;
wire [7:0]                  ar_len;
wire [2:0]                  ar_size;
wire [1:0]                  ar_burst;
wire                        ar_lock;
wire [3:0]                  ar_cache;
wire [3:0]                  ar_qos;
wire [AXI_ID_WIDTH-1:0]     ar_id;
wire [AXI_USER_WIDTH-1:0]   ar_user;
wire                        ar_ready;
wire                        ar_valid;
wire                        w_valid;
wire [AXI_DATA_WIDTH-1:0]   w_data;
wire [AXI_STRB_WIDTH-1:0]   w_strb;
wire [AXI_USER_WIDTH-1:0]   w_user;
wire                        w_last;
wire                        w_ready;
wire [AXI_DATA_WIDTH-1:0]   r_data;
wire [1:0]                  r_resp;
wire                        r_last;
wire [AXI_ID_WIDTH-1:0]     r_id;
wire [AXI_USER_WIDTH-1:0]   r_user;
wire                        r_ready;
wire                        r_valid;
wire [1:0]                  b_resp;
wire [AXI_ID_WIDTH-1:0]     b_id;
wire [AXI_USER_WIDTH-1:0]   b_user;
wire                        b_ready;
wire                        b_valid;



always #5 clk = ~clk;

initial begin
    clk = 1'b0;
    rst_n = 1'b1;
    #10
    rst_n = 1'b0;
    #10
    rst_n = 1'b1;
    #2000000
    $stop;
end

always @(*) begin
    if (u_rvcpu.axi_aw_valid_o && u_rvcpu.axi_aw_addr_o == 64'h10000000)
        $display("yield");
end

//---------AXI Slave------------------
axi_slave_if#(
    .AXI_DATA_WIDTH    ( 64 ),
    .AXI_ADDR_WIDTH    ( 64 ),
    .AXI_ID_WIDTH      ( 4 ),
    .AXI_STRB_WIDTH    ( 8 ),
    .AXI_USER_WIDTH    ( 1 ),
    .WRITE_BUFFER_SIZE ( 32 ),
    .READ_BUFFER_SIZE  ( 32 )
)u_axi_slave_if(
    .clk               ( clk               ),
    .rst_n             ( rst_n             ),
    .aw_addr           ( aw_addr           ),
    .aw_prot           ( aw_prot           ),
    .aw_region         ( aw_region         ),
    .aw_len            ( aw_len            ),
    .aw_size           ( aw_size           ),
    .aw_burst          ( aw_burst          ),
    .aw_lock           ( aw_lock           ),
    .aw_cache          ( aw_cache          ),
    .aw_qos            ( aw_qos            ),
    .aw_id             ( aw_id             ),
    .aw_user           ( aw_user           ),
    .aw_ready          ( aw_ready          ),
    .aw_valid          ( aw_valid          ),
    .ar_addr           ( ar_addr           ),
    .ar_prot           ( ar_prot           ),
    .ar_region         ( ar_region         ),
    .ar_len            ( ar_len            ),
    .ar_size           ( ar_size           ),
    .ar_burst          ( ar_burst          ),
    .ar_lock           ( ar_lock           ),
    .ar_cache          ( ar_cache          ),
    .ar_qos            ( ar_qos            ),
    .ar_id             ( ar_id             ),
    .ar_user           ( ar_user           ),
    .ar_ready          ( ar_ready          ),
    .ar_valid          ( ar_valid          ),
    .w_valid           ( w_valid           ),
    .w_data            ( w_data            ),
    .w_strb            ( w_strb            ),
    .w_user            ( w_user            ),
    .w_last            ( w_last            ),
    .w_ready           ( w_ready           ),
    .r_data            ( r_data            ),
    .r_resp            ( r_resp            ),
    .r_last            ( r_last            ),
    .r_id              ( r_id              ),
    .r_user            ( r_user            ),
    .r_ready           ( r_ready           ),
    .r_valid           ( r_valid           ),
    .b_resp            ( b_resp            ),
    .b_id              ( b_id              ),
    .b_user            ( b_user            ),
    .b_ready           ( b_ready           ),
    .b_valid           ( b_valid           )
);



rvcpu u_rvcpu(
    .clk             ( clk       ),
    .rst_n           ( rst_n     ),
    .axi_aw_id_o     ( aw_id     ),
    .axi_aw_addr_o   ( aw_addr   ),
    .axi_aw_len_o    ( aw_len    ),
    .axi_aw_size_o   ( aw_size   ),
    .axi_aw_burst_o  ( aw_burst  ),
    .axi_aw_lock_o   ( aw_lock   ),
    .axi_aw_cache_o  ( aw_cache  ),
    .axi_aw_prot_o   ( aw_prot   ),
    .axi_aw_qos_o    ( aw_qos    ),
    .axi_aw_region_o ( aw_region ),
    .axi_aw_user_o   ( aw_user   ),
    .axi_aw_valid_o  ( aw_valid  ),
    .axi_aw_ready_i  ( aw_ready  ),
    .axi_w_ready_i   ( w_ready   ),
    .axi_w_valid_o   ( w_valid   ),
    .axi_w_data_o    ( w_data    ),
    .axi_w_strb_o    ( w_strb    ),
    .axi_w_last_o    ( w_last    ),
    .axi_w_user_o    ( w_user    ),
    .axi_b_ready_o   ( b_ready   ),
    .axi_b_valid_i   ( b_valid   ),
    .axi_b_resp_i    ( b_resp    ),
    .axi_b_id_i      ( b_id      ),
    .axi_b_user_i    ( b_user    ),
    .axi_ar_ready_i  ( ar_ready  ),
    .axi_ar_valid_o  ( ar_valid  ),
    .axi_ar_addr_o   ( ar_addr   ),
    .axi_ar_prot_o   ( ar_prot   ),
    .axi_ar_id_o     ( ar_id     ),
    .axi_ar_user_o   ( ar_user   ),
    .axi_ar_len_o    ( ar_len    ),
    .axi_ar_size_o   ( ar_size   ),
    .axi_ar_burst_o  ( ar_burst  ),
    .axi_ar_lock_o   ( ar_lock   ),
    .axi_ar_cache_o  ( ar_cache  ),
    .axi_ar_qos_o    ( ar_qos    ),
    .axi_ar_region_o ( ar_region ),
    .axi_r_ready_o   ( r_ready   ),
    .axi_r_valid_i   ( r_valid   ),
    .axi_r_resp_i    ( r_resp    ),
    .axi_r_data_i    ( r_data    ),
    .axi_r_last_i    ( r_last    ),
    .axi_r_id_i      ( r_id      ),
    .axi_r_user_i    ( r_user    )
);

`ifdef FSDB
initial begin
    $fsdbDumpfile("tb_rvcpu.fsdb");
    $fsdbDumpvars;
end
`endif

endmodule