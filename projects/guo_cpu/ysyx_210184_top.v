
module ysyx_210184 
(
    input clock,
    input reset,

    input io_interrupt,

    // AIX4 master
    input                              io_master_awready,
    output                             io_master_awvalid,
    output [31:0]                      io_master_awaddr,
    output [3:0]                       io_master_awid,
    output [7:0]                       io_master_awlen,
    output [2:0]                       io_master_awsize,
    output [1:0]                       io_master_awburst,

    input                              io_master_wready,
    output                             io_master_wvalid,
    output [63:0]                      io_master_wdata,
    output [7:0]                       io_master_wstrb,
    output                             io_master_wlast,
    
    output                             io_master_bready,
    input                              io_master_bvalid,
    input  [1:0]                       io_master_bresp,
    input  [3:0]                       io_master_bid,

    input                              io_master_arready,
    output                             io_master_arvalid,
    output [31:0]                      io_master_araddr,
    output [3:0]                       io_master_arid,
    output [7:0]                       io_master_arlen,
    output [2:0]                       io_master_arsize,
    output [1:0]                       io_master_arburst,

    output                             io_master_rready,
    input                              io_master_rvalid,
    input  [1:0]                       io_master_rresp,
    input  [63:0]                      io_master_rdata,
    input                              io_master_rlast,
    input  [3:0]                       io_master_rid,
    
    

/* verilator lint_off UNUSED */

    // AXI4 slave
    output                             io_slave_awready,
    input                              io_slave_awvalid,
    input [31:0]                       io_slave_awaddr,
    input [3:0]                        io_slave_awid,
    input [7:0]                        io_slave_awlen,
    input [2:0]                        io_slave_awsize,
    input [1:0]                        io_slave_awburst,

    output                             io_slave_wready,
    input                              io_slave_wvalid,
    input [63:0]                       io_slave_wdata,
    input [7:0]                        io_slave_wstrb,
    input                              io_slave_wlast,

    input                              io_slave_bready,
    output                             io_slave_bvalid,
    output  [1:0]                      io_slave_bresp,
    output  [3:0]                      io_slave_bid,

    output                             io_slave_arready,
    input                              io_slave_arvalid,
    input [31:0]                       io_slave_araddr,
    input [3:0]                        io_slave_arid,
    input [7:0]                        io_slave_arlen,
    input [2:0]                        io_slave_arsize,
    input [1:0]                        io_slave_arburst,

    input                              io_slave_rready,
    output                             io_slave_rvalid,
    output  [1:0]                      io_slave_rresp,
    output  [63:0]                     io_slave_rdata,
    output                             io_slave_rlast,
    output  [3:0]                      io_slave_rid

/* verilator lint_on UNUSED */
);

    // slave
    assign io_slave_awready = 1'b0;
    assign io_slave_wready = 1'b0;
    assign io_slave_bvalid = 1'b0;
    assign io_slave_bresp = 2'b00;
    assign io_slave_bid = 4'b00;
    assign io_slave_arready = 1'b0;
    assign io_slave_rvalid = 1'b0;
    assign io_slave_rresp = 2'b00;
    assign io_slave_rdata = 64'b0;
    assign io_slave_rlast = 1'b0;
    assign io_slave_rid = 4'b0;

    // parameter RW_DATA_WIDTH     = 64;
    // parameter RW_ADDR_WIDTH     = 64;
    parameter AXI_DATA_WIDTH    = 64;
    parameter AXI_ADDR_WIDTH    = 64;
    parameter AXI_ID_WIDTH      = 4;
    // parameter AXI_USER_WIDTH    = 1;
    //slave end

    // port name switch
    // wire clk;
    // assign clk = clock;
    // wire rst;
    // assign rst = reset;

    wire ext_intr;
    assign ext_intr = io_interrupt;

    wire                              axi_aw_ready_i;
    assign axi_aw_ready_i = io_master_awready;
    wire                              axi_aw_valid_o;
    assign io_master_awvalid = axi_aw_valid_o;
    wire [AXI_ADDR_WIDTH-1:0]         axi_aw_addr_o;
    assign io_master_awaddr = axi_aw_addr_o[31:0] | (32'b0 & axi_aw_addr_o[63:32]);
    // wire [2:0]                        axi_aw_prot_o;
    wire [AXI_ID_WIDTH-1:0]           axi_aw_id_o;
    assign io_master_awid = axi_aw_id_o;
    // wire [AXI_USER_WIDTH-1:0]         axi_aw_user_o;
    wire [7:0]                        axi_aw_len_o;
    assign io_master_awlen = axi_aw_len_o;
    wire [2:0]                        axi_aw_size_o;
    assign io_master_awsize = axi_aw_size_o;
    wire [1:0]                        axi_aw_burst_o;
    assign io_master_awburst = axi_aw_burst_o;
    // wire                              axi_aw_lock_o;
    // wire [3:0]                        axi_aw_cache_o;
    // wire [3:0]                        axi_aw_qos_o;
    // wire [3:0]                        axi_aw_region_o;

    wire                              axi_w_ready_i;
    assign axi_w_ready_i = io_master_wready;
    wire                              axi_w_valid_o;
    assign io_master_wvalid = axi_w_valid_o;
    wire [AXI_DATA_WIDTH-1:0]         axi_w_data_o;
    assign io_master_wdata = axi_w_data_o;
    wire [AXI_DATA_WIDTH/8-1:0]       axi_w_strb_o;
    assign io_master_wstrb = axi_w_strb_o;
    wire                              axi_w_last_o;
    assign io_master_wlast = axi_w_last_o;
    // wire [AXI_USER_WIDTH-1:0]         axi_w_user_o;

    wire                              axi_b_ready_o;
    assign io_master_bready = axi_b_ready_o;
    wire                              axi_b_valid_i;
    assign axi_b_valid_i = io_master_bvalid;
    wire  [1:0]                       axi_b_resp_i;
    assign axi_b_resp_i = io_master_bresp;
    wire  [AXI_ID_WIDTH-1:0]          axi_b_id_i;
    assign axi_b_id_i = io_master_bid;
    // wire  [AXI_USER_WIDTH-1:0]        axi_b_user_i;
    // assign axi_b_user_i = 1'b0;

    wire                              axi_ar_ready_i;
    assign axi_ar_ready_i = io_master_arready;
    wire                              axi_ar_valid_o;
    assign io_master_arvalid = axi_ar_valid_o;
    wire [AXI_ADDR_WIDTH-1:0]         axi_ar_addr_o;
    assign io_master_araddr = axi_ar_addr_o[31:0] | (32'b0 & axi_ar_addr_o[63:32]);
    // wire [2:0]                        axi_ar_prot_o;
    wire [AXI_ID_WIDTH-1:0]           axi_ar_id_o;
    assign io_master_arid = axi_ar_id_o;
    // wire [AXI_USER_WIDTH-1:0]         axi_ar_user_o;
    wire [7:0]                        axi_ar_len_o;
    assign io_master_arlen = axi_ar_len_o;
    wire [2:0]                        axi_ar_size_o;
    assign io_master_arsize = axi_ar_size_o;
    wire [1:0]                        axi_ar_burst_o;
    assign io_master_arburst = axi_ar_burst_o;
    // wire                              axi_ar_lock_o;
    // wire [3:0]                        axi_ar_cache_o;
    // wire [3:0]                        axi_ar_qos_o;
    // wire [3:0]                        axi_ar_region_o;

    wire                              axi_r_ready_o;
    assign io_master_rready = axi_r_ready_o;
    wire                              axi_r_valid_i;
    assign axi_r_valid_i = io_master_rvalid;
    wire  [1:0]                       axi_r_resp_i;
    assign axi_r_resp_i = io_master_rresp; 
    wire  [AXI_DATA_WIDTH-1:0]        axi_r_data_i;
    assign axi_r_data_i = io_master_rdata;
    wire                              axi_r_last_i;
    assign axi_r_last_i = io_master_rlast;
    wire  [AXI_ID_WIDTH-1:0]          axi_r_id_i;
    assign axi_r_id_i = io_master_rid; 
    // wire  [AXI_USER_WIDTH-1:0]        axi_r_user_i;
    // assign axi_r_user_i = 1'b0;


    // wire  [`REG_BUS - 1 : 0] value_x10;
    // wire                     mac_ok;
    // wire  [`REG_BUS-1 : 0] pc_o;
    //  port name switch end


    // port define
    wire to_r_ena;
    wire to_w_ena;
    wire [`REG_BUS-1 : 0] to_addr;
    wire [`REG_BUS-1 : 0] to_w_data;
    wire [`REG_BUS-1 : 0] to_w_mask;

    wire [`REG_BUS-1 : 0] from_r_data;
    wire from_r_ready;
    wire from_w_ready;

    reg [`REG_BUS-1 : 0] mtime, mtimecmp, msip;

    wire mtime_intr;


    wire is_mtime, is_mtimecmp, is_msip, is_CLINT;
    reg [`REG_BUS-1 : 0] CLINT_r_data;
    reg                  CLINT_r_ready;
    reg                  CLINT_w_ready;

    wire to_axi_r_ena;
    wire to_axi_w_ena;
    wire [`REG_BUS-1 : 0] to_axi_addr;
    wire [`REG_BUS-1 : 0] to_axi_w_data;
    wire [`REG_BUS/8-1 : 0] to_axi_w_mask;

    wire [`REG_BUS-1 : 0] from_axi_r_data;
    wire from_axi_r_ready;
    wire from_axi_w_ready;

    wire no_Icache_to_axi4;
    wire is_fencei;

    //port define end


 

    ysyx_210184_core cpu_core(
        .clk(clock),
        .rst(reset),
        .r_data_axi4(from_r_data),
        .r_ready_axi4(from_r_ready),
        .w_ready_axi4(from_w_ready),

        .mtime_intr(mtime_intr),
        .ext_intr(ext_intr),
        .software_intr(msip[0]),

        .r_ena_axi4(to_r_ena),
        .w_ena_axi4(to_w_ena),
        .addr_axi4(to_addr),
        .w_data_axi4(to_w_data),
        .w_mask_axi4_64(to_w_mask),
    
        .no_Icache_to_axi4(no_Icache_to_axi4),
        .is_fencei(is_fencei)

        // .value_x10(value_x10),
        // .mac_ok(mac_ok),
        // .pc_o(pc_o)
    );


    assign from_r_data = CLINT_r_ready ? CLINT_r_data : from_axi_r_data;
    assign from_r_ready = CLINT_r_ready | from_axi_r_ready;
    assign from_w_ready = CLINT_w_ready | from_axi_w_ready;


    // mtime and mtimecmp
    reg [7:0] mtime_div;
    always @(posedge clock) begin
        if(reset) mtime <= 64'd0;
        else begin
            if(to_w_ena & is_mtime) mtime <= (mtime & (~to_w_mask)) | (to_w_data & (to_w_mask));
            else if(mtime_div == 8'b0) mtime <= mtime + 64'b1;
            else mtime <= mtime;
        end
    end

    always @(posedge clock) begin
        if(reset) mtime_div <= 8'b0;
        else if(mtime_div == 8'd5) mtime_div <= 8'b0;
        else mtime_div <= mtime_div + 8'd1;
    end



    always @(posedge clock) begin
        if(reset) mtimecmp <= 64'd0;
        else begin
            if(to_w_ena & is_mtimecmp) begin
                mtimecmp <= (mtimecmp & (~to_w_mask)) | (to_w_data & (to_w_mask));
            end
            else mtimecmp <= mtimecmp;
        end
    end

    always @(posedge clock) begin
        if(reset) msip <= 64'd0;
        else begin
            if(to_w_ena & is_msip) begin
                msip <= {63'b0, to_w_data[0]};
            end
            else msip <= msip;
        end
        
    end

    assign mtime_intr = (mtime > mtimecmp);

    assign is_mtime    = (to_addr[`REG_BUS-1 : 3] == 61'h4017ff) ;//0x200bff8
    assign is_mtimecmp = (to_addr[`REG_BUS-1 : 3] == 61'h400800) ;//0x2004000
    assign is_msip = (to_addr[`REG_BUS-1 : 3] == 61'h400000) ;//0x2000000
    assign is_CLINT = is_mtime | is_mtimecmp | is_msip;

    always @(posedge clock) begin
        if(reset) CLINT_r_data <= 64'b0;
        else begin
            CLINT_r_data <= {64{to_r_ena & is_mtime   }} & mtime   |
                            {64{to_r_ena & is_mtimecmp}} & mtimecmp|
                            {64{to_r_ena & is_msip    }} & msip;
        end
    end

    always @(posedge clock) begin
        if(reset) CLINT_r_ready <= 1'b0;
        else CLINT_r_ready <= to_r_ena & is_CLINT;
    end

    always @(posedge clock) begin
        if(reset) CLINT_w_ready <= 1'b0;
        else CLINT_w_ready <= to_w_ena & is_CLINT;
    end


    assign to_axi_r_ena = is_CLINT ? 1'b0 : to_r_ena;
    assign to_axi_w_ena = is_CLINT ? 1'b0 : to_w_ena;

    assign to_axi_addr = to_addr;
    assign to_axi_w_data = to_w_data;
    assign to_axi_w_mask = {to_w_mask[56], to_w_mask[48], to_w_mask[40], to_w_mask[32], to_w_mask[24], to_w_mask[16], to_w_mask[8], to_w_mask[0]};


    ysyx_210184_axirw axi4(
        .clk(clock),
        .rst(~reset),

	    .r_ena_i(to_axi_r_ena),
        .w_ena_i(to_axi_w_ena),
        .addr_i(to_axi_addr),
        .w_data_i(to_axi_w_data),
        .w_mask_i(to_axi_w_mask),

        .r_data_o(from_axi_r_data),
        .r_ready_o(from_axi_r_ready),
        .w_ready_o(from_axi_w_ready),

        .no_Icache_to_axi4(no_Icache_to_axi4),
        .is_fencei(is_fencei),

    // Advanced eXtensible Interface
        .axi_aw_ready_i(axi_aw_ready_i),
        .axi_aw_valid_o(axi_aw_valid_o),
        .axi_aw_addr_o(axi_aw_addr_o),
        // .axi_aw_prot_o(axi_aw_prot_o),
        .axi_aw_id_o(axi_aw_id_o),
        // .axi_aw_user_o(axi_aw_user_o),
        .axi_aw_len_o(axi_aw_len_o),
        .axi_aw_size_o(axi_aw_size_o),
        .axi_aw_burst_o(axi_aw_burst_o),
        // .axi_aw_lock_o(axi_aw_lock_o),
        // .axi_aw_cache_o(axi_aw_cache_o),
        // .axi_aw_qos_o(axi_aw_qos_o),
        // .axi_aw_region_o(axi_aw_region_o),

        .axi_w_ready_i(axi_w_ready_i),
        .axi_w_valid_o(axi_w_valid_o),
        .axi_w_data_o(axi_w_data_o),
        .axi_w_strb_o(axi_w_strb_o),
        .axi_w_last_o(axi_w_last_o),
        // .axi_w_user_o(axi_w_user_o),

        .axi_b_ready_o(axi_b_ready_o),
        .axi_b_valid_i(axi_b_valid_i),
        .axi_b_resp_i(axi_b_resp_i),
        .axi_b_id_i(axi_b_id_i),
        // .axi_b_user_i(axi_b_user_i),

        .axi_ar_ready_i(axi_ar_ready_i),
        .axi_ar_valid_o(axi_ar_valid_o),
        .axi_ar_addr_o(axi_ar_addr_o),
        // .axi_ar_prot_o(axi_ar_prot_o),
        .axi_ar_id_o(axi_ar_id_o),
        // .axi_ar_user_o(axi_ar_user_o),
        .axi_ar_len_o(axi_ar_len_o),
        .axi_ar_size_o(axi_ar_size_o),
        .axi_ar_burst_o(axi_ar_burst_o),
        // .axi_ar_lock_o(axi_ar_lock_o),
        // .axi_ar_cache_o(axi_ar_cache_o),
        // .axi_ar_qos_o(axi_ar_qos_o),
        // .axi_ar_region_o(axi_ar_region_o),

        .axi_r_ready_o(axi_r_ready_o),
        .axi_r_valid_i(axi_r_valid_i),
        .axi_r_resp_i(axi_r_resp_i),
        .axi_r_data_i(axi_r_data_i),
        .axi_r_last_i(axi_r_last_i),
        .axi_r_id_i  (axi_r_id_i  )
        // .axi_r_user_i(axi_r_user_i)
    );


endmodule
