// Copyright 2022 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2022.04.11
// Instruction Fetch unit

`include "defines.v"

module ifu(
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
    else if (nxt_state==REQ && ~jump_i && ~int_cen_i) begin
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
        ifu_ram_addr_o <= ifu_ram_addr_o + 3'd4;
    end
end

assign ifu_ram_size_o = 3'b011;


// -------------- to cpu -------------
assign ifu_instr_o = (ifu_ram_addr_o[2:0]==3'd0) ?
                      ifu_ram_data_i[31:0] : ifu_ram_data_i[63:32];

assign ifu_instr_valid_o = ifu_ram_valid_i;

assign ifu_pc_o = ifu_ram_addr_o;

endmodule