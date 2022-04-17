
/* verilator lint_off UNUSED */
`include "ysyx_210184_ffn.v"

module ysyx_210184_axirw # (
    parameter RW_DATA_WIDTH     = 64,
    // parameter RW_ADDR_WIDTH     = 64,
    parameter AXI_DATA_WIDTH    = 64,
    parameter AXI_ADDR_WIDTH    = 64,
    parameter AXI_ID_WIDTH      = 4
    // parameter AXI_USER_WIDTH    = 1
)(
    input                               clk,
    input                               rst,

	input                               r_ena_i,
    input                               w_ena_i,
    input  [AXI_DATA_WIDTH-1:0]         addr_i,
    input  [RW_DATA_WIDTH-1:0]          w_data_i,
    input  [RW_DATA_WIDTH/8-1:0]        w_mask_i,
    output [RW_DATA_WIDTH-1:0]          r_data_o,
    output                              r_ready_o,
    output                              w_ready_o,

    input                               no_Icache_to_axi4,
    input                               is_fencei,

    // Advanced eXtensible Interface
    input                               axi_aw_ready_i,
    output                              axi_aw_valid_o,
    output [AXI_ADDR_WIDTH-1:0]         axi_aw_addr_o,
    // output [2:0]                        axi_aw_prot_o,
    output [AXI_ID_WIDTH-1:0]           axi_aw_id_o,
    // output [AXI_USER_WIDTH-1:0]         axi_aw_user_o,
    output [7:0]                        axi_aw_len_o,
    output [2:0]                        axi_aw_size_o,
    output [1:0]                        axi_aw_burst_o,
    // output                              axi_aw_lock_o,
    // output [3:0]                        axi_aw_cache_o,
    // output [3:0]                        axi_aw_qos_o,
    // output [3:0]                        axi_aw_region_o,

    input                               axi_w_ready_i,
    output                              axi_w_valid_o,
    output [AXI_DATA_WIDTH-1:0]         axi_w_data_o,
    output [AXI_DATA_WIDTH/8-1:0]       axi_w_strb_o,
    output                              axi_w_last_o,
    // output [AXI_USER_WIDTH-1:0]         axi_w_user_o,
    
    output                              axi_b_ready_o,
    input                               axi_b_valid_i,
    input  [1:0]                        axi_b_resp_i,
    input  [AXI_ID_WIDTH-1:0]           axi_b_id_i,
    // input  [AXI_USER_WIDTH-1:0]         axi_b_user_i,

    input                               axi_ar_ready_i,
    output                              axi_ar_valid_o,
    output [AXI_ADDR_WIDTH-1:0]         axi_ar_addr_o,
    // output [2:0]                        axi_ar_prot_o,
    output [AXI_ID_WIDTH-1:0]           axi_ar_id_o,
    // output [AXI_USER_WIDTH-1:0]         axi_ar_user_o,
    output [7:0]                        axi_ar_len_o,
    output [2:0]                        axi_ar_size_o,
    output [1:0]                        axi_ar_burst_o,
    // output                              axi_ar_lock_o,
    // output [3:0]                        axi_ar_cache_o,
    // output [3:0]                        axi_ar_qos_o,
    // output [3:0]                        axi_ar_region_o,
    
    output                              axi_r_ready_o,
    input                               axi_r_valid_i,
    input  [1:0]                        axi_r_resp_i,
    input  [AXI_DATA_WIDTH-1:0]         axi_r_data_i,
    input                               axi_r_last_i,
    input  [AXI_ID_WIDTH-1:0]           axi_r_id_i
    // input  [AXI_USER_WIDTH-1:0]         axi_r_user_i
);


    // port define
    wire axi_ar_valid_o_wire;
    wire [AXI_ADDR_WIDTH-1 : 0] axi_ar_addr_o_wire;
    wire [2:0] axi_ar_size_o_wire;
    wire axi_aw_valid_o_wire;
    wire [AXI_ADDR_WIDTH-1 : 0] axi_aw_addr_o_wire;
    wire axi_w_valid_o_wire;
    // wire [AXI_DATA_WIDTH-1 : 0] axi_w_data_o_wire;
    // wire [AXI_DATA_WIDTH/8-1 : 0] axi_w_strb_o_wire;
    reg r_ready_o_wire;
    reg [RW_DATA_WIDTH-1 : 0] r_data_o_wire;
    reg w_ready_o_wire;
    wire [2:0] axi_aw_size_o_wire;

    reg r_cache_valid;
    reg [31:0] r_cache_addr;
    reg [3:0] send_state, nxt_send_state;

    reg [9:0] reset_delay;
    wire      is_reset_delay_ok;
    always @(posedge clk) begin
        if(~rst) reset_delay <= 10'b0;
        else begin
            if(is_reset_delay_ok) reset_delay <= reset_delay;
            else reset_delay <= reset_delay + 10'b1;
        end
    end
    assign is_reset_delay_ok = (reset_delay == 10'd300);

    //port define

    // Regist imformation
    reg [63:0] addr_cache, w_data_cache;
    reg [ 7:0] w_mask_cache;
    reg        is_32_bus;

    always @ (posedge clk) begin
        if(~rst) addr_cache <= 64'b0;
        else begin
            if( (r_ena_i | w_ena_i) & send_state==4'd0) addr_cache <= addr_i;
            else addr_cache <= addr_cache;
        end
    end

    always @(posedge clk) begin
        if(~rst) w_data_cache <= 64'b0;
        else begin
            if(r_ena_i | w_ena_i) w_data_cache <= w_data_i;
            else w_data_cache <= w_data_cache;
        end
    end

    always @(posedge clk) begin
        if(~rst) w_mask_cache <= 8'b0;
        else begin
            if(r_ena_i | w_ena_i) w_mask_cache <= w_mask_i;
            else w_mask_cache <= w_mask_cache;
        end
    end

    always @(posedge clk) begin
        if(~rst) is_32_bus <= 1'b0;
        else begin
            if(r_ena_i | w_ena_i) is_32_bus <= (addr_i[63:13] == 51'b0001_0000_0000_0000_000) | (addr_i[63:28] == 36'b11);
            else is_32_bus <= is_32_bus;
        end
    end


    // Send transaction
    always @(posedge clk) begin
        if(~rst) send_state <= 4'd0;
        else send_state <= nxt_send_state;
    end


    wire r_hit_cache = r_ena_i & ~no_Icache_to_axi4 & (addr_i>=64'h80000000) & (addr_i[31:3] == r_cache_addr[31:3]) & r_cache_valid ;//& 1'b0;

    always @ (*)begin
        case(send_state)
            4'd0:begin
                if(r_hit_cache) nxt_send_state = 4'd0;
                else if(r_ena_i) nxt_send_state = 4'd1;
                else if(w_ena_i) nxt_send_state = 4'd4;
                else nxt_send_state =4'd0;
            end
            4'd1:begin
                if(is_reset_delay_ok) begin
                    if(is_32_bus & addr_cache[2] == 1'b0) nxt_send_state = 4'd2;
                    else if(is_32_bus & addr_cache[2] == 1'b1) nxt_send_state = 4'd3;
                    else nxt_send_state = 4'd2;
                end
                else nxt_send_state = 4'b1;
            end
            4'd2:begin
                if(~axi_ar_ready_i) nxt_send_state = 4'd2;
                // else if(axi_ar_ready_i & (~is_32_bus) ) nxt_send_state = 4'd0;
                // else if(axi_ar_ready_i & is_32_bus) nxt_send_state = 4'd3;
                else nxt_send_state = 4'd0; // Never execute
            end
            4'd3: begin
                if(~axi_ar_ready_i) nxt_send_state = 4'd3;
                else nxt_send_state = 4'd0;
            end
            4'd4: begin
                if(is_reset_delay_ok) begin
                    if(is_32_bus & addr_cache[2] == 1'b0) nxt_send_state = 4'd5;
                    else if(is_32_bus & addr_cache[2] == 1'b1) nxt_send_state = 4'd8;
                    else nxt_send_state = 4'd5;
                end
                else nxt_send_state = 4'd4;
            end
            4'd5: begin
                if(~axi_aw_ready_i & ~axi_w_ready_i) nxt_send_state = 4'd5;
                else if(axi_aw_ready_i & (~axi_w_ready_i) ) nxt_send_state = 4'd6;
                else if(~axi_aw_ready_i & axi_w_ready_i) nxt_send_state = 4'd7;
                else if(axi_aw_ready_i & axi_w_ready_i) nxt_send_state = 4'd0;
                else nxt_send_state = 4'd5; // Never execute 
            end
            4'd6: begin
                if(axi_w_ready_i) nxt_send_state = 4'd0; 
                else nxt_send_state = 4'd6;
            end
            4'd7: begin
                if(axi_aw_ready_i) nxt_send_state = 4'd0; 
                else nxt_send_state = 4'd7;
            end
            4'd8: begin
                if(~axi_aw_ready_i & ~axi_w_ready_i) nxt_send_state = 4'd8;
                else if(axi_aw_ready_i & (~axi_w_ready_i) ) nxt_send_state = 4'd9;
                else if(~axi_aw_ready_i & axi_w_ready_i) nxt_send_state = 4'd10;
                else if(axi_aw_ready_i & axi_w_ready_i) nxt_send_state = 4'd0;
                else nxt_send_state = 4'd8; // Never execute 
            end
            4'd9: begin
                if(axi_w_ready_i) nxt_send_state = 4'd0; 
                else nxt_send_state = 4'd9;
            end
            4'd10: begin
                if(axi_aw_ready_i) nxt_send_state = 4'd0; 
                else nxt_send_state = 4'd10;
            end
            default: nxt_send_state = 4'd0;
        endcase
    end




    assign axi_ar_valid_o_wire =    (send_state == 4'd1 & is_reset_delay_ok) ? 1'b1 :
                                    (send_state == 4'd2 & (~axi_ar_ready_i)) ? 1'b1 :
                                    (send_state == 4'd3 & (~axi_ar_ready_i)) ? 1'b1 : 1'b0;
    ysyx_210184_ffn #(.WIDTH( 1)) ff_ar_valid(.clk(clk), .rst(rst), .stall(1'b0), .d(axi_ar_valid_o_wire), .q(axi_ar_valid_o));

    assign axi_ar_addr_o_wire = (send_state == 4'd1 & is_reset_delay_ok) ? addr_cache : axi_ar_addr_o;
    ysyx_210184_ffn #(.WIDTH(AXI_ADDR_WIDTH)) ff_ar_addr(.clk(clk), .rst(rst), .stall(1'b0), .d(axi_ar_addr_o_wire), .q(axi_ar_addr_o));

    assign axi_ar_size_o_wire = is_32_bus ? 3'b010 : 3'b011;
    ysyx_210184_ffn #(.WIDTH(3)) ff_ar_size(.clk(clk), .rst(rst), .stall(1'b0), .d(axi_ar_size_o_wire), .q(axi_ar_size_o));

    // assign axi_ar_prot_o = 3'b000;
    assign axi_ar_id_o = 4'b0000;
    // assign axi_ar_user_o = 1'b0;
    assign axi_ar_len_o = 8'b0;
    assign axi_ar_burst_o = 2'b01;
    // assign axi_ar_lock_o = 1'b0;
    // assign axi_ar_cache_o = 4'b0000;
    // assign axi_ar_qos_o = 4'b0000;
    // assign axi_ar_region_o = 4'b0000;




    assign axi_aw_valid_o_wire =    (send_state == 4'd4 & is_reset_delay_ok) ? 1'b1 :
                                    (send_state == 4'd5 & ~axi_aw_ready_i) ? 1'b1 :
                                    (send_state == 4'd7 & ~axi_aw_ready_i) ? 1'b1 :
                                    (send_state == 4'd8 & ~axi_aw_ready_i) ? 1'b1 :
                                    (send_state == 4'd10 & ~axi_aw_ready_i) ? 1'b1 : 1'b0;
    ysyx_210184_ffn #(.WIDTH( 1)) ff_aw_valid(.clk(clk), .rst(rst), .stall(1'b0), .d(axi_aw_valid_o_wire), .q(axi_aw_valid_o));

    assign axi_aw_addr_o_wire = (send_state == 4'd4 &  is_reset_delay_ok) ? addr_cache : axi_aw_addr_o;
    ysyx_210184_ffn #(.WIDTH(AXI_ADDR_WIDTH)) ff_aw_addr(.clk(clk), .rst(rst), .stall(1'b0), .d(axi_aw_addr_o_wire), .q(axi_aw_addr_o));


    assign axi_aw_size_o_wire = is_32_bus ? 3'b010 : 3'b011;
    ysyx_210184_ffn #(.WIDTH(3)) ff_aw_size(.clk(clk), .rst(rst), .stall(1'b0), .d(axi_aw_size_o_wire), .q(axi_aw_size_o));

    // assign axi_aw_prot_o = 3'b000;
    assign axi_aw_id_o = 4'b0000;
    // assign axi_aw_user_o = 1'b0;
    assign axi_aw_len_o = 8'b0;
    assign axi_aw_burst_o = 2'b01;
    // assign axi_aw_lock_o = 1'b0;
    // assign axi_aw_cache_o = 4'b0000;
    // assign axi_aw_qos_o = 4'b0000;
    // assign axi_aw_region_o = 4'b0000;


    assign axi_w_valid_o_wire = (send_state == 4'd4 & is_reset_delay_ok) ? 1'b1 :
                                (send_state == 4'd5 & ~axi_w_ready_i) ? 1'b1 :
                                (send_state == 4'd6 & ~axi_w_ready_i) ? 1'b1 :
                                (send_state == 4'd8 & ~axi_w_ready_i) ? 1'b1 :
                                (send_state == 4'd9 & ~axi_w_ready_i) ? 1'b1 : 1'b0;
    ysyx_210184_ffn #(.WIDTH( 1)) ff_w_valid(.clk(clk), .rst(rst), .stall(1'b0), .d(axi_w_valid_o_wire), .q(axi_w_valid_o));

    // assign axi_w_data_o_wire =  w_data_cache;
    // ysyx_210184_ffn #(.WIDTH(AXI_DATA_WIDTH)) ff_w_data(.clk(clk), .rst(rst), .stall(1'b0), .d(axi_w_data_o_wire), .q(axi_w_data_o));
    assign axi_w_data_o = w_data_cache;

    // assign axi_w_strb_o_wire = w_mask_i;//{w_mask_i[56], w_mask_i[48], w_mask_i[40], w_mask_i[32], w_mask_i[24], w_mask_i[16], w_mask_i[8], w_mask_i[0]};
    // ysyx_210184_ffn #(.WIDTH(AXI_DATA_WIDTH/8)) ff_w_strb(.clk(clk), .rst(rst), .stall(1'b0), .d(axi_w_strb_o_wire), .q(axi_w_strb_o));
    assign axi_w_strb_o = w_mask_cache;

    // assign axi_w_user_o = 1'b0;
    ysyx_210184_ffn #(.WIDTH( 1)) ff_w_last(.clk(clk), .rst(rst), .stall(1'b0), .d(axi_w_valid_o_wire), .q(axi_w_last_o));



    // Receive transcation
    reg [1:0] recv_state;
    // reg [1:0] nxt_recv_state;
    always @(posedge clk) begin
        if(~rst) recv_state <= 2'b00;
        // else recv_state <= nxt_recv_state;
        else recv_state <= 2'b00;
    end

    // always@(*) case(recv_state)
    //     2'b00: begin
    //         // if(axi_r_valid_i & is_32_bus) nxt_recv_state = 2'b01;
    //         if(axi_r_valid_i & is_32_bus) nxt_recv_state = 2'b00;
    //         // else if(axi_b_valid_i & is_32_bus) nxt_recv_state = 2'b10;
    //         else if(axi_b_valid_i & is_32_bus) nxt_recv_state = 2'b00;
    //         else nxt_recv_state = 2'b00;
    //     end
    //     2'b01: begin
    //         if(axi_r_valid_i) nxt_recv_state = 2'b00;
    //         else nxt_recv_state = 2'b01;
    //     end
    //     2'b10: begin
    //         if(axi_b_valid_i) nxt_recv_state = 2'b00;
    //         else nxt_recv_state = 2'b10;
    //     end
    //     2'b11: nxt_recv_state = 2'b00;
    // endcase

    assign axi_r_ready_o = 1'b1;

    // assign r_ready_o_wire = axi_r_valid_i & (axi_r_resp_i == 2'b00) & axi_r_last_i & (axi_r_id_i == 4'b0);
    always@(posedge clk)begin
        if(~rst) r_ready_o_wire <= 1'b0;
        else if(r_hit_cache) r_ready_o_wire <= 1'b1;
        else r_ready_o_wire <= ( (recv_state == 2'b00 & axi_r_valid_i) ? 1'b1 :1'b0 ) & (axi_r_resp_i == 2'b00) & axi_r_last_i & (axi_r_id_i == 4'b0);
    end 
    assign r_ready_o = r_ready_o_wire;


    always @(posedge clk) begin
        if(~rst) r_data_o_wire <= 64'b0;
        else begin
            if(recv_state == 2'b00 & axi_r_valid_i) r_data_o_wire <= axi_r_data_i;
            // else if(recv_state == 2'b01 & axi_r_valid_i) r_data_o_wire <= {axi_r_data_i[63:32], r_data_o[31:0]};
            else r_data_o_wire <= r_data_o_wire;
        end
    end
    assign r_data_o = r_data_o_wire;

    always @(posedge clk) begin
        if(~rst) r_cache_valid <= 1'b0;
        else if(is_fencei) r_cache_valid <= 1'b0;
        else if(w_ena_i) r_cache_valid <= 1'b0;
        else if(recv_state == 2'b00 & axi_r_valid_i) r_cache_valid <= 1'b1;
        else r_cache_valid <= r_cache_valid;
    end

    always @(posedge clk) begin
        if(~rst) r_cache_addr <= 32'b0;
        else if(recv_state == 2'b00 & axi_r_valid_i) r_cache_addr <= addr_cache[31:0];
        else r_cache_addr <= r_cache_addr;
    end


    assign axi_b_ready_o = 1'b1;

    always @(posedge clk) begin
        if(~rst) w_ready_o_wire <= 1'b0;
        else w_ready_o_wire <= ( (recv_state == 2'b00 & axi_b_valid_i) ? 1'b1 : 1'b0 ) & (axi_b_resp_i == 2'b00) & (axi_b_id_i == 4'b0);
    end
    assign w_ready_o = w_ready_o_wire;


endmodule
