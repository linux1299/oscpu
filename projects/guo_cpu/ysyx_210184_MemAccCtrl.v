
`include "defines.v"
// `include "ysyx_210184_ff.v"
`include "S011HD1P_X32Y2D128.v"

module ysyx_210184_MemAccCtrl(
    input wire clk,
    input wire rst,

    // with cpu
    input wire                  r_if_ena,
    input wire [`REG_BUS-1 : 0] r_if_addr,
    input wire [         2 : 0] r_if_bytes,

    input wire                  r_mem_ena,
    input wire                  w_mem_ena,
    input wire [`REG_BUS-1 : 0] rw_mem_addr,
    input wire [         2 : 0] rw_mem_bytes,
    input wire [`REG_BUS-1 : 0] w_mem_data,

    output wire                 ready,
    output wire [`INS_BUS-1 : 0] if_data,
    output wire [`REG_BUS-1 : 0] mem_data,

    //with AXI4

    input  [`REG_BUS-1 : 0] r_data_from_axi4,
    input                   r_ready_from_axi4,
    input                   w_ready_from_axi4,
    output r_ena_to_axi4,
    output w_ena_to_axi4,
    output [`REG_BUS-1 : 0] addr_to_axi4,
    output [`REG_BUS-1 : 0] w_data_to_axi4,
    output [         7 : 0] w_mask_to_axi4,

    output        reg       no_Icache,
    output        wire      is_fencei
);

    reg [3:0] state, nxt_state;
    reg ready_reg;
    reg [`INS_BUS-1 : 0] if_data_reg;
    reg [`REG_BUS-1 : 0] mem_data_reg;


    // is misaligned IF
    wire [3:0] remain_bytes_IF;
    wire [3:0] need_bytes_IF;
    wire misalign_IF;
    wire [4:0] additional_bytes_IF;
    // is misaligned MEM
    wire [3:0] remain_bytes_MEM;
    wire [3:0] need_bytes_MEM;
    wire misalign_MEM;
    wire [4:0] additional_bytes_MEM;
    //Output <> AXI4
    reg r_ena_to_axi4_reg;
    reg w_ena_to_axi4_reg;
    reg [`REG_BUS-1 : 0] addr_to_axi4_reg;
    reg [`REG_BUS-1 : 0] w_data_to_axi4_reg;
    reg [         7 : 0] w_mask_to_axi4_reg;
    // with cache
    reg  [5  :0] Icache_0_addr;
    wire [127:0] Icache_0_rdata;
    reg [127:0] Icache_0_rdata_fix_timing;
    reg          Icache_0_cen;
    reg          Icache_0_wen;
    reg  [127:0] Icache_0_wdata;
    // reg  [109:0] Icache_0_wdata;
    wire         is_Icache_0_miss;
    reg  [127:0] Icache_0_valid;

    reg  [5  :0] Icache_1_addr;
    wire [127:0] Icache_1_rdata;
    reg [127:0] Icache_1_rdata_fix_timing;
    reg          Icache_1_cen;
    reg          Icache_1_wen;
    reg  [127:0] Icache_1_wdata;
    // reg  [109:0] Icache_1_wdata;
    wire         is_Icache_1_miss;
    reg  [127:0] Icache_1_valid;

    reg  [1:0] Icache_priority[0:127];

    wire is_fencei_inifreg;

    assign is_fencei = is_fencei_inifreg;


    assign is_fencei_inifreg = if_data_reg == 32'h100f;
    always @(posedge clk) begin
        if(rst) no_Icache <= 1'b0;
        else no_Icache <= is_fencei_inifreg | ~(nxt_state==4'd1 | nxt_state==4'd2);
    end



    // State register

    always @(posedge clk) begin
        if(rst) state <= 4'd0;
        else state <= nxt_state;
    end

    always@(*) case(state)
        4'd0: begin
            if(r_mem_ena) nxt_state = 4'd3;
            else if(w_mem_ena) nxt_state = 4'd5;
            else if(r_if_ena) nxt_state = 4'd8;
            else nxt_state = 4'd0;
        end
        4'd1: begin
            if(r_ready_from_axi4 & (~misalign_IF) & r_if_addr[1:0] != 2'b00) nxt_state = 4'd7;
            else if(r_ready_from_axi4 & (~misalign_IF) & r_if_addr[1:0] == 2'b00) nxt_state = 4'd10;
            else if(r_ready_from_axi4 & misalign_IF) nxt_state = 4'd2;
            else nxt_state = 4'd1;
        end
        4'd2: begin
            if(r_ready_from_axi4) nxt_state = 4'd7;
            else nxt_state = 4'd2;
        end
        4'd3: begin
            if(r_ready_from_axi4 & (~misalign_MEM)) nxt_state = 4'd8;
            else if(r_ready_from_axi4 & misalign_MEM) nxt_state = 4'd4;
            else nxt_state = 4'd3;
        end
        4'd4: begin
            if(r_ready_from_axi4) nxt_state = 4'd8;
            else nxt_state = 4'd4;
        end
        4'd5: begin
            if(w_ready_from_axi4 & (~misalign_MEM)) nxt_state = 4'd8;
            else if(w_ready_from_axi4 & misalign_MEM) nxt_state = 4'd6;
            else nxt_state = 4'd5;
        end
        4'd6: begin
            if(w_ready_from_axi4) nxt_state = 4'd8;
            else nxt_state = 4'd6;
        end
        4'd7: nxt_state = 4'd0;
        4'd8: nxt_state = 4'd11;
        4'd9: begin
            if(is_Icache_0_miss & is_Icache_1_miss) nxt_state = 4'd1;
            else nxt_state = 4'd7;
        end
        4'd10: nxt_state = 4'd7;
        4'd11: nxt_state = 4'd9;
        default: nxt_state = 4'd0;
    endcase



    // with cache
    // integer i;
    always @(posedge clk) begin
        if(rst) begin
            // for(i=0; i<128; i=i+1) begin
            //     Icache_priority[i] <= 2'b01;
            // end
            Icache_priority[0] <= 2'b01;
            Icache_priority[1] <= 2'b01;
            Icache_priority[2] <= 2'b01;
            Icache_priority[3] <= 2'b01;
            Icache_priority[4] <= 2'b01;
            Icache_priority[5] <= 2'b01;
            Icache_priority[6] <= 2'b01;
            Icache_priority[7] <= 2'b01;
            Icache_priority[8] <= 2'b01;
            Icache_priority[9] <= 2'b01;
            Icache_priority[10] <= 2'b01;
            Icache_priority[11] <= 2'b01;
            Icache_priority[12] <= 2'b01;
            Icache_priority[13] <= 2'b01;
            Icache_priority[14] <= 2'b01;
            Icache_priority[15] <= 2'b01;
            Icache_priority[16] <= 2'b01;
            Icache_priority[17] <= 2'b01;
            Icache_priority[18] <= 2'b01;
            Icache_priority[19] <= 2'b01;
            Icache_priority[20] <= 2'b01;
            Icache_priority[21] <= 2'b01;
            Icache_priority[22] <= 2'b01;
            Icache_priority[23] <= 2'b01;
            Icache_priority[24] <= 2'b01;
            Icache_priority[25] <= 2'b01;
            Icache_priority[26] <= 2'b01;
            Icache_priority[27] <= 2'b01;
            Icache_priority[28] <= 2'b01;
            Icache_priority[29] <= 2'b01;
            Icache_priority[30] <= 2'b01;
            Icache_priority[31] <= 2'b01;
            Icache_priority[32] <= 2'b01;
            Icache_priority[33] <= 2'b01;
            Icache_priority[34] <= 2'b01;
            Icache_priority[35] <= 2'b01;
            Icache_priority[36] <= 2'b01;
            Icache_priority[37] <= 2'b01;
            Icache_priority[38] <= 2'b01;
            Icache_priority[39] <= 2'b01;
            Icache_priority[40] <= 2'b01;
            Icache_priority[41] <= 2'b01;
            Icache_priority[42] <= 2'b01;
            Icache_priority[43] <= 2'b01;
            Icache_priority[44] <= 2'b01;
            Icache_priority[45] <= 2'b01;
            Icache_priority[46] <= 2'b01;
            Icache_priority[47] <= 2'b01;
            Icache_priority[48] <= 2'b01;
            Icache_priority[49] <= 2'b01;
            Icache_priority[50] <= 2'b01;
            Icache_priority[51] <= 2'b01;
            Icache_priority[52] <= 2'b01;
            Icache_priority[53] <= 2'b01;
            Icache_priority[54] <= 2'b01;
            Icache_priority[55] <= 2'b01;
            Icache_priority[56] <= 2'b01;
            Icache_priority[57] <= 2'b01;
            Icache_priority[58] <= 2'b01;
            Icache_priority[59] <= 2'b01;
            Icache_priority[60] <= 2'b01;
            Icache_priority[61] <= 2'b01;
            Icache_priority[62] <= 2'b01;
            Icache_priority[63] <= 2'b01;
            Icache_priority[64] <= 2'b01;
            Icache_priority[65] <= 2'b01;
            Icache_priority[66] <= 2'b01;
            Icache_priority[67] <= 2'b01;
            Icache_priority[68] <= 2'b01;
            Icache_priority[69] <= 2'b01;
            Icache_priority[70] <= 2'b01;
            Icache_priority[71] <= 2'b01;
            Icache_priority[72] <= 2'b01;
            Icache_priority[73] <= 2'b01;
            Icache_priority[74] <= 2'b01;
            Icache_priority[75] <= 2'b01;
            Icache_priority[76] <= 2'b01;
            Icache_priority[77] <= 2'b01;
            Icache_priority[78] <= 2'b01;
            Icache_priority[79] <= 2'b01;
            Icache_priority[80] <= 2'b01;
            Icache_priority[81] <= 2'b01;
            Icache_priority[82] <= 2'b01;
            Icache_priority[83] <= 2'b01;
            Icache_priority[84] <= 2'b01;
            Icache_priority[85] <= 2'b01;
            Icache_priority[86] <= 2'b01;
            Icache_priority[87] <= 2'b01;
            Icache_priority[88] <= 2'b01;
            Icache_priority[89] <= 2'b01;
            Icache_priority[90] <= 2'b01;
            Icache_priority[91] <= 2'b01;
            Icache_priority[92] <= 2'b01;
            Icache_priority[93] <= 2'b01;
            Icache_priority[94] <= 2'b01;
            Icache_priority[95] <= 2'b01;
            Icache_priority[96] <= 2'b01;
            Icache_priority[97] <= 2'b01;
            Icache_priority[98] <= 2'b01;
            Icache_priority[99] <= 2'b01;
            Icache_priority[100] <= 2'b01;
            Icache_priority[101] <= 2'b01;
            Icache_priority[102] <= 2'b01;
            Icache_priority[103] <= 2'b01;
            Icache_priority[104] <= 2'b01;
            Icache_priority[105] <= 2'b01;
            Icache_priority[106] <= 2'b01;
            Icache_priority[107] <= 2'b01;
            Icache_priority[108] <= 2'b01;
            Icache_priority[109] <= 2'b01;
            Icache_priority[110] <= 2'b01;
            Icache_priority[111] <= 2'b01;
            Icache_priority[112] <= 2'b01;
            Icache_priority[113] <= 2'b01;
            Icache_priority[114] <= 2'b01;
            Icache_priority[115] <= 2'b01;
            Icache_priority[116] <= 2'b01;
            Icache_priority[117] <= 2'b01;
            Icache_priority[118] <= 2'b01;
            Icache_priority[119] <= 2'b01;
            Icache_priority[120] <= 2'b01;
            Icache_priority[121] <= 2'b01;
            Icache_priority[122] <= 2'b01;
            Icache_priority[123] <= 2'b01;
            Icache_priority[124] <= 2'b01;
            Icache_priority[125] <= 2'b01;
            Icache_priority[126] <= 2'b01;
            Icache_priority[127] <= 2'b01;
        end
        else if(state==4'd9 && ~is_Icache_0_miss) begin
            case(Icache_priority[r_if_addr[8:2]])
                2'b00: Icache_priority[r_if_addr[8:2]] <= 2'b01;
                2'b01: Icache_priority[r_if_addr[8:2]] <= 2'b10;
                2'b10: Icache_priority[r_if_addr[8:2]] <= 2'b11;
                2'b11: Icache_priority[r_if_addr[8:2]] <= 2'b11;
            endcase
        end
        else if(state==4'd9 && ~is_Icache_1_miss) begin
            case(Icache_priority[r_if_addr[8:2]])
                2'b00: Icache_priority[r_if_addr[8:2]] <= 2'b00;
                2'b01: Icache_priority[r_if_addr[8:2]] <= 2'b00;
                2'b10: Icache_priority[r_if_addr[8:2]] <= 2'b01;
                2'b11: Icache_priority[r_if_addr[8:2]] <= 2'b10;
            endcase
        end
        else if(state == 4'd10) begin
            case(Icache_priority[r_if_addr[8:2]])
                2'b00: Icache_priority[r_if_addr[8:2]] <= 2'b10;
                2'b01: Icache_priority[r_if_addr[8:2]] <= 2'b10;
                2'b10: Icache_priority[r_if_addr[8:2]] <= 2'b01;
                2'b11: Icache_priority[r_if_addr[8:2]] <= 2'b10;
            endcase
        end
        // else begin
            // for(i=0; i<128; i=i+1) Icache_priority[i] <= Icache_priority[i];
        // end
    end

    always @(posedge clk) begin
        if(rst) begin
            Icache_0_addr <= 6'b0;
            Icache_1_addr <= 6'b0;
        end
        else if(nxt_state == 4'd8)begin
            Icache_0_addr <= r_if_addr[8:3];
            Icache_1_addr <= r_if_addr[8:3];
        end 
        else begin
            Icache_0_addr <= Icache_0_addr;
            Icache_1_addr <= Icache_1_addr;
        end 
    end

    always @(posedge clk) begin
        if(rst) begin
            Icache_0_cen <= 1'b1;
            Icache_1_cen <= 1'b1;
        end
        else if(nxt_state == 4'd8) begin
            Icache_0_cen <= 1'b0;
            Icache_1_cen <= 1'b0;
        end
        else if(nxt_state == 4'd10) begin
            Icache_0_cen <= Icache_priority[r_if_addr[8:2]][1] ? 1'b1 : 1'b0;
            Icache_1_cen <= Icache_priority[r_if_addr[8:2]][1] ? 1'b0 : 1'b1;
        end
        else begin
            Icache_0_cen <= 1'b1;
            Icache_1_cen <= 1'b1;
        end
    end

    always @(posedge clk) begin
        if(rst) Icache_0_wen <= 1'b1;
        else if(nxt_state == 4'd10)begin
            Icache_0_wen <= Icache_priority[r_if_addr[8:2]][1] ? 1'b1 : 1'b0;
        end
        else Icache_0_wen <= 1'b1;
    end 
    always @(posedge clk) begin
        if(rst) Icache_1_wen <= 1'b1;
        else if(nxt_state == 4'd10) begin 
            Icache_1_wen <= Icache_priority[r_if_addr[8:2]][1] ? 1'b0 : 1'b1;
        end
        else Icache_1_wen <= 1'b1;
    end

    always @(posedge clk) begin
        if(rst) begin
            Icache_0_wdata <= 128'b0;
            Icache_0_valid <= 128'b0;
        end
        else if(nxt_state == 4'd1) Icache_0_wdata[111:0] <= Icache_0_rdata_fix_timing[111:0];
        else if(nxt_state == 4'd10) begin
            if(~r_if_addr[2]) begin
                Icache_0_wdata[110] <= 1'b1;
                Icache_0_wdata[86:64] <= r_if_addr[31:9];
                Icache_0_wdata[31:0] <= r_data_from_axi4[31:0];
                if(~Icache_priority[r_if_addr[8:2]][1]) Icache_0_valid[{Icache_0_addr, 1'b0}] <= 1'b1;
            end
            else begin
                Icache_0_wdata[111] <= 1'b1;
                Icache_0_wdata[109:87] <= r_if_addr[31:9];
                Icache_0_wdata[63:32] <= r_data_from_axi4[63:32];
                if(~Icache_priority[r_if_addr[8:2]][1]) Icache_0_valid[{Icache_0_addr, 1'b1}] <= 1'b1;
            end
        end
        else if(state==4'd7 && is_fencei_inifreg) begin
            Icache_0_wdata <= Icache_0_wdata;
            Icache_0_valid <= 128'b0;
        end
        else begin
            Icache_0_wdata <= Icache_0_wdata;
            Icache_0_valid <= Icache_0_valid;
        end
    end
    always @(posedge clk) begin
        if(rst) begin
            Icache_1_wdata <= 128'b0;
            Icache_1_valid <= 128'b0;
        end
        else if(nxt_state == 4'd1) Icache_1_wdata[111:0] <= Icache_1_rdata_fix_timing[111:0];
        else if(nxt_state == 4'd10) begin
            if(~r_if_addr[2]) begin
                Icache_1_wdata[110] <= 1'b1;
                Icache_1_wdata[86:64] <= r_if_addr[31:9];
                Icache_1_wdata[31:0] <= r_data_from_axi4[31:0];
                if(Icache_priority[r_if_addr[8:2]][1]) Icache_1_valid[{Icache_1_addr, 1'b0}] <= 1'b1;
            end
            else begin
                Icache_1_wdata[111] <= 1'b1;
                Icache_1_wdata[109:87] <= r_if_addr[31:9];
                Icache_1_wdata[63:32] <= r_data_from_axi4[63:32];
                if(Icache_priority[r_if_addr[8:2]][1]) Icache_1_valid[{Icache_1_addr, 1'b1}] <= 1'b1;
            end
        end
        else if(state==4'd7 && is_fencei_inifreg) begin
            Icache_1_wdata <= Icache_1_wdata;
            Icache_1_valid <= 128'b0;
        end
        else begin
            Icache_1_wdata <= Icache_1_wdata;
            Icache_1_valid <= Icache_1_valid;
        end
    end

    always @(posedge clk) begin
        if(rst) Icache_0_rdata_fix_timing <= 128'b0;
        else if(nxt_state == 4'd9) Icache_0_rdata_fix_timing <= Icache_0_rdata;
        else Icache_0_rdata_fix_timing <= Icache_0_rdata_fix_timing;
    end
    always @(posedge clk) begin
        if(rst) Icache_1_rdata_fix_timing <= 128'b0;
        else if(nxt_state == 4'd9) Icache_1_rdata_fix_timing <= Icache_1_rdata;
        else Icache_1_rdata_fix_timing <= Icache_1_rdata_fix_timing;
    end


    wire Icache_0_hit_1 = r_if_addr[2] & Icache_0_valid[{Icache_0_addr, 1'b1}] & (r_if_addr[31:9] == Icache_0_rdata_fix_timing[109:87]);
    wire Icache_0_hit_0 = ~r_if_addr[2] & Icache_0_valid[{Icache_0_addr, 1'b0}] & (r_if_addr[31:9] == Icache_0_rdata_fix_timing[86:64]);
    assign is_Icache_0_miss = ~( (Icache_0_hit_1 | Icache_0_hit_0) & r_if_addr[1:0] == 2'b00 );

    wire Icache_1_hit_1 = r_if_addr[2] & Icache_1_valid[{Icache_1_addr, 1'b1}] & (r_if_addr[31:9] == Icache_1_rdata_fix_timing[109:87]);
    wire Icache_1_hit_0 = ~r_if_addr[2] & Icache_1_valid[{Icache_1_addr, 1'b0}] & (r_if_addr[31:9] == Icache_1_rdata_fix_timing[86:64]);
    assign is_Icache_1_miss = ~( (Icache_1_hit_1 | Icache_1_hit_0) & r_if_addr[1:0] == 2'b00 );

    S011HD1P_X32Y2D128 Icache_0(
        .Q(Icache_0_rdata), 
        .CLK(clk), 
        .CEN(Icache_0_cen), 
        .WEN(Icache_0_wen), 
        .A(Icache_0_addr), 
        .D(Icache_0_wdata)
    );
    S011HD1P_X32Y2D128 Icache_1(
        .Q(Icache_1_rdata), 
        .CLK(clk), 
        .CEN(Icache_1_cen), 
        .WEN(Icache_1_wen), 
        .A(Icache_1_addr), 
        .D(Icache_1_wdata)
    );

    // output <> cpu
    assign ready = ready_reg;
    assign if_data = if_data_reg;
    assign mem_data = mem_data_reg;

    always@(posedge clk) begin
        if(rst) ready_reg <= 1'b0;
        else ready_reg <= (nxt_state == 4'd7);
    end

    always @(posedge clk) begin
        if(rst) if_data_reg <= `INS_BUS'd0;
        else begin
            if(state==4'd1 && r_ready_from_axi4)begin
                case(r_if_addr[2:0]) 
                    3'b000: if_data_reg <= r_data_from_axi4[4*8-1:0*8];
                    3'b001: if_data_reg <= r_data_from_axi4[5*8-1:1*8];
                    3'b010: if_data_reg <= r_data_from_axi4[6*8-1:2*8];
                    3'b011: if_data_reg <= r_data_from_axi4[7*8-1:3*8];
                    3'b100: if_data_reg <= r_data_from_axi4[8*8-1:4*8];
                    3'b101: if_data_reg <= {8'b0, r_data_from_axi4[8*8-1:5*8]};
                    3'b110: if_data_reg <= {16'b0, r_data_from_axi4[8*8-1:6*8]};
                    3'b111: if_data_reg <= {24'b0, r_data_from_axi4[8*8-1:7*8]};
                endcase
            end
            else if(state==4'd2 && r_ready_from_axi4)begin
                case(r_if_addr[2:0])
                    3'b000: if_data_reg <= if_data_reg;
                    3'b001: if_data_reg <= if_data_reg;
                    3'b010: if_data_reg <= if_data_reg;
                    3'b011: if_data_reg <= if_data_reg;
                    3'b100: if_data_reg <= if_data_reg;
                    3'b101: if_data_reg <= {r_data_from_axi4[1*8-1:0], if_data_reg[3*8-1:0*8]};
                    3'b110: if_data_reg <= {r_data_from_axi4[2*8-1:0], if_data_reg[2*8-1:0*8]};
                    3'b111: if_data_reg <= {r_data_from_axi4[3*8-1:0], if_data_reg[1*8-1:0*8]};
                endcase
            end
            else if(state==4'd9 && ~(is_Icache_0_miss & is_Icache_1_miss)) begin
                if(~is_Icache_0_miss) begin
                    if(~r_if_addr[2]) if_data_reg <= Icache_0_rdata_fix_timing[31:0];
                    else if_data_reg <= Icache_0_rdata_fix_timing[63:32];
                end
                if(~is_Icache_1_miss) begin
                    if(~r_if_addr[2]) if_data_reg <= Icache_1_rdata_fix_timing[31:0];
                    else if_data_reg <= Icache_1_rdata_fix_timing[63:32];
                end
            end
            else if_data_reg <= if_data_reg;
        end
    end

    always @(posedge clk) begin
        if(rst) mem_data_reg <= `REG_BUS'd0;
        else begin
            if(state==4'd3 && r_ready_from_axi4)begin
                case(rw_mem_bytes[1:0])
                    2'b00: case(rw_mem_addr[2:0])
                        3'b000: mem_data_reg <= {{56{r_data_from_axi4[1*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[1*8-1:0*8]};
                        3'b001: mem_data_reg <= {{56{r_data_from_axi4[2*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[2*8-1:1*8]};
                        3'b010: mem_data_reg <= {{56{r_data_from_axi4[3*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[3*8-1:2*8]};
                        3'b011: mem_data_reg <= {{56{r_data_from_axi4[4*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[4*8-1:3*8]};
                        3'b100: mem_data_reg <= {{56{r_data_from_axi4[5*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[5*8-1:4*8]};
                        3'b101: mem_data_reg <= {{56{r_data_from_axi4[6*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[6*8-1:5*8]};
                        3'b110: mem_data_reg <= {{56{r_data_from_axi4[7*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[7*8-1:6*8]};
                        3'b111: mem_data_reg <= {{56{r_data_from_axi4[8*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[8*8-1:7*8]};
                    endcase
                    2'b01: case(rw_mem_addr[2:0])
                        3'b000: mem_data_reg <= {{48{r_data_from_axi4[2*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[2*8-1:0*8]};
                        3'b001: mem_data_reg <= {{48{r_data_from_axi4[3*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[3*8-1:1*8]};
                        3'b010: mem_data_reg <= {{48{r_data_from_axi4[4*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[4*8-1:2*8]};
                        3'b011: mem_data_reg <= {{48{r_data_from_axi4[5*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[5*8-1:3*8]};
                        3'b100: mem_data_reg <= {{48{r_data_from_axi4[6*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[6*8-1:4*8]};
                        3'b101: mem_data_reg <= {{48{r_data_from_axi4[7*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[7*8-1:5*8]};
                        3'b110: mem_data_reg <= {{48{r_data_from_axi4[8*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[8*8-1:6*8]};
                        3'b111: mem_data_reg <= {{56{r_data_from_axi4[8*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[8*8-1:7*8]};
                    endcase
                    2'b10: case(rw_mem_addr[2:0])
                        3'b000: mem_data_reg <= {{32{r_data_from_axi4[4*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[4*8-1:0*8]};
                        3'b001: mem_data_reg <= {{32{r_data_from_axi4[5*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[5*8-1:1*8]};
                        3'b010: mem_data_reg <= {{32{r_data_from_axi4[6*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[6*8-1:2*8]};
                        3'b011: mem_data_reg <= {{32{r_data_from_axi4[7*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[7*8-1:3*8]};
                        3'b100: mem_data_reg <= {{32{r_data_from_axi4[8*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[8*8-1:4*8]};
                        3'b101: mem_data_reg <= {{40{r_data_from_axi4[8*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[8*8-1:5*8]};
                        3'b110: mem_data_reg <= {{48{r_data_from_axi4[8*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[8*8-1:6*8]};
                        3'b111: mem_data_reg <= {{56{r_data_from_axi4[8*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[8*8-1:7*8]};
                    endcase
                    2'b11: case(rw_mem_addr[2:0])
                        3'b000: mem_data_reg <= r_data_from_axi4[8*8-1:0*8];
                        3'b001: mem_data_reg <= {{ 8{r_data_from_axi4[8*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[8*8-1:1*8]};
                        3'b010: mem_data_reg <= {{16{r_data_from_axi4[8*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[8*8-1:2*8]};
                        3'b011: mem_data_reg <= {{24{r_data_from_axi4[8*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[8*8-1:3*8]};
                        3'b100: mem_data_reg <= {{32{r_data_from_axi4[8*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[8*8-1:4*8]};
                        3'b101: mem_data_reg <= {{40{r_data_from_axi4[8*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[8*8-1:5*8]};
                        3'b110: mem_data_reg <= {{48{r_data_from_axi4[8*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[8*8-1:6*8]};
                        3'b111: mem_data_reg <= {{56{r_data_from_axi4[8*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[8*8-1:7*8]};
                    endcase
                endcase
            end  
            else if(state==4'd4 && r_ready_from_axi4) begin
                case(rw_mem_bytes[1:0])
                    2'b00: mem_data_reg <= mem_data_reg;
                    2'b01: case(rw_mem_addr[2:0])
                        3'b111: mem_data_reg <= {{48{r_data_from_axi4[1*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[1*8-1:0*8], mem_data_reg[1*8-1:0*8]};
                        default: mem_data_reg <= mem_data_reg;
                    endcase
                    2'b10: case(rw_mem_addr[2:0])
                        3'b101: mem_data_reg <= {{32{r_data_from_axi4[1*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[1*8-1:0*8], mem_data_reg[3*8-1:0*8]};
                        3'b110: mem_data_reg <= {{32{r_data_from_axi4[2*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[2*8-1:0*8], mem_data_reg[2*8-1:0*8]};
                        3'b111: mem_data_reg <= {{32{r_data_from_axi4[3*8-1]&(~rw_mem_bytes[2])}}, r_data_from_axi4[3*8-1:0*8], mem_data_reg[1*8-1:0*8]};
                        default: mem_data_reg <= mem_data_reg;
                    endcase
                    2'b11: case(rw_mem_addr[2:0])
                        3'b001: mem_data_reg <= {r_data_from_axi4[1*8-1:0*8], mem_data_reg[7*8-1:0*8]};
                        3'b010: mem_data_reg <= {r_data_from_axi4[2*8-1:0*8], mem_data_reg[6*8-1:0*8]};
                        3'b011: mem_data_reg <= {r_data_from_axi4[3*8-1:0*8], mem_data_reg[5*8-1:0*8]};
                        3'b100: mem_data_reg <= {r_data_from_axi4[4*8-1:0*8], mem_data_reg[4*8-1:0*8]};
                        3'b101: mem_data_reg <= {r_data_from_axi4[5*8-1:0*8], mem_data_reg[3*8-1:0*8]};
                        3'b110: mem_data_reg <= {r_data_from_axi4[6*8-1:0*8], mem_data_reg[2*8-1:0*8]};
                        3'b111: mem_data_reg <= {r_data_from_axi4[7*8-1:0*8], mem_data_reg[1*8-1:0*8]};
                        default: mem_data_reg <= mem_data_reg;
                    endcase
                endcase
            end
            else mem_data_reg <= mem_data_reg;
        end
    end




    assign need_bytes_IF = {r_if_bytes[1]&r_if_bytes[0], r_if_bytes[1]&(~r_if_bytes[0]), (~r_if_bytes[1])&r_if_bytes[0], (~r_if_bytes[1])&(~r_if_bytes[0])} | {4{r_if_bytes[2]}};
    assign remain_bytes_IF = 4'b1000 - {1'b0, r_if_addr[2:0]};
    assign additional_bytes_IF = {1'b0, need_bytes_IF} - {1'b0, remain_bytes_IF};
    assign misalign_IF = ~((additional_bytes_IF[4]) | (additional_bytes_IF==5'b0));



    assign need_bytes_MEM = {rw_mem_bytes[1]&rw_mem_bytes[0], rw_mem_bytes[1]&(~rw_mem_bytes[0]), (~rw_mem_bytes[1])&rw_mem_bytes[0], (~rw_mem_bytes[1])&(~rw_mem_bytes[0])};
    assign remain_bytes_MEM = 4'b1000 - {1'b0, rw_mem_addr[2:0]};
    assign additional_bytes_MEM = {1'b0, need_bytes_MEM} - {1'b0, remain_bytes_MEM};
    assign misalign_MEM = ~((additional_bytes_MEM[4]) | (additional_bytes_MEM==5'b0));




    assign r_ena_to_axi4 = r_ena_to_axi4_reg;
    assign w_ena_to_axi4 = w_ena_to_axi4_reg;
    assign addr_to_axi4  = addr_to_axi4_reg;
    assign w_data_to_axi4 = w_data_to_axi4_reg;
    assign w_mask_to_axi4   = w_mask_to_axi4_reg;

    always @(posedge clk) begin
        if(rst) r_ena_to_axi4_reg <= 1'b0;
        else r_ena_to_axi4_reg <= (nxt_state==4'd1 | nxt_state==4'd2 | nxt_state==4'd3 | nxt_state==4'd4) & (state != nxt_state); 
    end

    always @(posedge clk) begin
        if(rst) w_ena_to_axi4_reg <= 1'b0;
        else w_ena_to_axi4_reg <= (nxt_state==4'd5 | nxt_state==4'd6) & (state != nxt_state);
    end

    wire [63:0] if_addr_p_8;
    assign if_addr_p_8 = {r_if_addr[63:3] + 61'b1, 3'b000};
    wire [63:0] mem_addr_p_8;
    assign mem_addr_p_8 = {rw_mem_addr[63:3] + 61'b1, 3'b000};
    always @(posedge clk) begin
        if(rst) addr_to_axi4_reg <= `REG_BUS'd0;
        else begin
            case(nxt_state)
                4'd1: addr_to_axi4_reg <= r_if_addr;
                4'd2: addr_to_axi4_reg <= if_addr_p_8;
                4'd3, 4'd5: addr_to_axi4_reg <= rw_mem_addr;
                4'd4, 4'd6: addr_to_axi4_reg <= mem_addr_p_8;
                default: addr_to_axi4_reg <= addr_to_axi4_reg;
            endcase
        end
    end


    always @(posedge clk) begin
        if(rst) w_data_to_axi4_reg <= `REG_BUS'd0;
        else if(nxt_state==4'd5) begin
            case(rw_mem_bytes[1:0])
                2'b00: case(rw_mem_addr[2:0])
                    3'b000: w_data_to_axi4_reg <= {56'b0, w_mem_data[1*8-1:0*8]};
                    3'b001: w_data_to_axi4_reg <= {48'b0, w_mem_data[1*8-1:0*8],  8'b0};
                    3'b010: w_data_to_axi4_reg <= {40'b0, w_mem_data[1*8-1:0*8], 16'b0};
                    3'b011: w_data_to_axi4_reg <= {32'b0, w_mem_data[1*8-1:0*8], 24'b0};
                    3'b100: w_data_to_axi4_reg <= {24'b0, w_mem_data[1*8-1:0*8], 32'b0};
                    3'b101: w_data_to_axi4_reg <= {16'b0, w_mem_data[1*8-1:0*8], 40'b0};
                    3'b110: w_data_to_axi4_reg <= { 8'b0, w_mem_data[1*8-1:0*8], 48'b0};
                    3'b111: w_data_to_axi4_reg <= {       w_mem_data[1*8-1:0*8], 56'b0};
                endcase
                2'b01: case (rw_mem_addr[2:0])
                    3'b000: w_data_to_axi4_reg <= {48'b0, w_mem_data[2*8-1:0*8]};
                    3'b001: w_data_to_axi4_reg <= {40'b0, w_mem_data[2*8-1:0*8],  8'b0};
                    3'b010: w_data_to_axi4_reg <= {32'b0, w_mem_data[2*8-1:0*8], 16'b0};
                    3'b011: w_data_to_axi4_reg <= {24'b0, w_mem_data[2*8-1:0*8], 24'b0};
                    3'b100: w_data_to_axi4_reg <= {16'b0, w_mem_data[2*8-1:0*8], 32'b0};
                    3'b101: w_data_to_axi4_reg <= { 8'b0, w_mem_data[2*8-1:0*8], 40'b0};
                    3'b110: w_data_to_axi4_reg <= {       w_mem_data[2*8-1:0*8], 48'b0};
                    3'b111: w_data_to_axi4_reg <= {       w_mem_data[1*8-1:0*8], 56'b0};
                endcase
                2'b10: case (rw_mem_addr[2:0])
                    3'b000: w_data_to_axi4_reg <= {32'b0, w_mem_data[4*8-1:0*8]};
                    3'b001: w_data_to_axi4_reg <= {24'b0, w_mem_data[4*8-1:0*8],  8'b0};
                    3'b010: w_data_to_axi4_reg <= {16'b0, w_mem_data[4*8-1:0*8], 16'b0};
                    3'b011: w_data_to_axi4_reg <= { 8'b0, w_mem_data[4*8-1:0*8], 24'b0};
                    3'b100: w_data_to_axi4_reg <= {       w_mem_data[4*8-1:0*8], 32'b0};
                    3'b101: w_data_to_axi4_reg <= {       w_mem_data[3*8-1:0*8], 40'b0};
                    3'b110: w_data_to_axi4_reg <= {       w_mem_data[2*8-1:0*8], 48'b0};
                    3'b111: w_data_to_axi4_reg <= {       w_mem_data[1*8-1:0*8], 56'b0};
                endcase
                2'b11: case (rw_mem_addr[2:0])
                    3'b000: w_data_to_axi4_reg <= {w_mem_data[8*8-1:0*8]};
                    3'b001: w_data_to_axi4_reg <= {w_mem_data[7*8-1:0*8],  8'b0};
                    3'b010: w_data_to_axi4_reg <= {w_mem_data[6*8-1:0*8], 16'b0};
                    3'b011: w_data_to_axi4_reg <= {w_mem_data[5*8-1:0*8], 24'b0};
                    3'b100: w_data_to_axi4_reg <= {w_mem_data[4*8-1:0*8], 32'b0};
                    3'b101: w_data_to_axi4_reg <= {w_mem_data[3*8-1:0*8], 40'b0};
                    3'b110: w_data_to_axi4_reg <= {w_mem_data[2*8-1:0*8], 48'b0};
                    3'b111: w_data_to_axi4_reg <= {w_mem_data[1*8-1:0*8], 56'b0};
                endcase
            endcase
        end
        else if(nxt_state==4'd6) begin
            case(rw_mem_bytes[1:0])
                2'b00: w_data_to_axi4_reg <= w_data_to_axi4_reg;
                2'b01: case (rw_mem_addr[2:0])
                    3'b111: w_data_to_axi4_reg <= {56'b0, w_mem_data[2*8-1:1*8]};
                    default: w_data_to_axi4_reg <= w_data_to_axi4_reg;
                endcase
                2'b10: case (rw_mem_addr[2:0])
                    3'b101: w_data_to_axi4_reg <= {56'b0, w_mem_data[4*8-1:3*8]};
                    3'b110: w_data_to_axi4_reg <= {48'b0, w_mem_data[4*8-1:2*8]};
                    3'b111: w_data_to_axi4_reg <= {40'b0, w_mem_data[4*8-1:1*8]};
                    default: w_data_to_axi4_reg <= w_data_to_axi4_reg;
                endcase
                2'b11: case (rw_mem_addr[2:0])
                    3'b000: w_data_to_axi4_reg <= w_data_to_axi4_reg;
                    3'b001: w_data_to_axi4_reg <= {56'b0, w_mem_data[8*8-1:7*8]};
                    3'b010: w_data_to_axi4_reg <= {48'b0, w_mem_data[8*8-1:6*8]};
                    3'b011: w_data_to_axi4_reg <= {40'b0, w_mem_data[8*8-1:5*8]};
                    3'b100: w_data_to_axi4_reg <= {32'b0, w_mem_data[8*8-1:4*8]};
                    3'b101: w_data_to_axi4_reg <= {24'b0, w_mem_data[8*8-1:3*8]};
                    3'b110: w_data_to_axi4_reg <= {16'b0, w_mem_data[8*8-1:2*8]};
                    3'b111: w_data_to_axi4_reg <= { 8'b0, w_mem_data[8*8-1:1*8]};
                endcase
            endcase
        end
    end


    always @(posedge clk) begin
        if(rst) w_mask_to_axi4_reg <= 8'd0;
        else if(nxt_state==4'd5) begin
            case(rw_mem_bytes[1:0])
                2'b00: case(rw_mem_addr[2:0])
                    3'b000: w_mask_to_axi4_reg <= 8'b0000_0001;
                    3'b001: w_mask_to_axi4_reg <= 8'b0000_0010;
                    3'b010: w_mask_to_axi4_reg <= 8'b0000_0100;
                    3'b011: w_mask_to_axi4_reg <= 8'b0000_1000;
                    3'b100: w_mask_to_axi4_reg <= 8'b0001_0000;
                    3'b101: w_mask_to_axi4_reg <= 8'b0010_0000;
                    3'b110: w_mask_to_axi4_reg <= 8'b0100_0000;
                    3'b111: w_mask_to_axi4_reg <= 8'b1000_0000;
                endcase
                2'b01: case (rw_mem_addr[2:0])
                    3'b000: w_mask_to_axi4_reg <= 8'b0000_0011;
                    3'b001: w_mask_to_axi4_reg <= 8'b0000_0110;
                    3'b010: w_mask_to_axi4_reg <= 8'b0000_1100;
                    3'b011: w_mask_to_axi4_reg <= 8'b0001_1000;
                    3'b100: w_mask_to_axi4_reg <= 8'b0011_0000;
                    3'b101: w_mask_to_axi4_reg <= 8'b0110_0000;
                    3'b110: w_mask_to_axi4_reg <= 8'b1100_0000;
                    3'b111: w_mask_to_axi4_reg <= 8'b1000_0000;
                endcase
                2'b10: case (rw_mem_addr[2:0])
                    3'b000: w_mask_to_axi4_reg <= 8'b0000_1111;
                    3'b001: w_mask_to_axi4_reg <= 8'b0001_1110;
                    3'b010: w_mask_to_axi4_reg <= 8'b0011_1100;
                    3'b011: w_mask_to_axi4_reg <= 8'b0111_1000;
                    3'b100: w_mask_to_axi4_reg <= 8'b1111_0000;
                    3'b101: w_mask_to_axi4_reg <= 8'b1110_0000;
                    3'b110: w_mask_to_axi4_reg <= 8'b1100_0000;
                    3'b111: w_mask_to_axi4_reg <= 8'b1000_0000;
                endcase
                2'b11: case (rw_mem_addr[2:0])
                    3'b000: w_mask_to_axi4_reg <= 8'b1111_1111;
                    3'b001: w_mask_to_axi4_reg <= 8'b1111_1110;
                    3'b010: w_mask_to_axi4_reg <= 8'b1111_1100;
                    3'b011: w_mask_to_axi4_reg <= 8'b1111_1000;
                    3'b100: w_mask_to_axi4_reg <= 8'b1111_0000;
                    3'b101: w_mask_to_axi4_reg <= 8'b1110_0000;
                    3'b110: w_mask_to_axi4_reg <= 8'b1100_0000;
                    3'b111: w_mask_to_axi4_reg <= 8'b1000_0000;
                endcase
            endcase
        end
        else if(nxt_state==4'd6) begin
            case(rw_mem_bytes[1:0])
                2'b00: w_mask_to_axi4_reg <= 8'b0000_0000;
                2'b01: case (rw_mem_addr[2:0])
                    3'b111: w_mask_to_axi4_reg <= 8'b0000_0001;
                    default: w_mask_to_axi4_reg <= 8'b0000_0000;
                endcase
                2'b10: case (rw_mem_addr[2:0])
                    3'b101: w_mask_to_axi4_reg <= 8'b0000_0001;
                    3'b110: w_mask_to_axi4_reg <= 8'b0000_0011;
                    3'b111: w_mask_to_axi4_reg <= 8'b0000_0111;
                    default: w_mask_to_axi4_reg <= 8'b0000_0000;
                endcase
                2'b11: case (rw_mem_addr[2:0])
                    3'b000: w_mask_to_axi4_reg <= 8'b0000_0000;
                    3'b001: w_mask_to_axi4_reg <= 8'b0000_0001;
                    3'b010: w_mask_to_axi4_reg <= 8'b0000_0011;
                    3'b011: w_mask_to_axi4_reg <= 8'b0000_0111;
                    3'b100: w_mask_to_axi4_reg <= 8'b0000_1111;
                    3'b101: w_mask_to_axi4_reg <= 8'b0001_1111;
                    3'b110: w_mask_to_axi4_reg <= 8'b0011_1111;
                    3'b111: w_mask_to_axi4_reg <= 8'b0111_1111;
                endcase
            endcase
        end
    end

endmodule
