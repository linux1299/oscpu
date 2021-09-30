// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.08.18
// Instruction Fetch unit

module  ysyx_210238_ifu(
    input            clk,
    input            rst_n,

    // ram port
    output    [63:0] o_ram_addr,
    output           o_ram_valid,
    // ready also indicates rdata is valid
    input            i_ram_ready,
    input     [31:0] i_ram_rdata,
    output    [2:0]  o_ram_size,

    // cpu port
    input            i_branch_jump,
    input            i_hold,
    input     [63:0] i_next_pc,
    output    [31:0] o_instr,
    output           o_instr_valid,
    output    [63:0] o_pc,

    // clint port
    input            i_int_valid,
    input     [63:0] i_int_addr
);

reg [1:0]  state;

localparam IDLE = 2'd0;
localparam START= 2'd1;
localparam REQ  = 2'd2;
localparam WAIT = 2'd3;

//-------------State machine-----------
always @(posedge clk) begin
    if(~rst_n) begin
        state <= IDLE;
    end
    else begin
        case (state)
            IDLE : begin
                state <= START;
            end

            START : begin
                if (i_hold)
                    state <= START;
                else
                    state <= REQ;
            end

            REQ  : begin
                if (i_branch_jump | i_int_valid)
                    state <= REQ;
                else
                    state <= WAIT;
            end

            WAIT : begin
                if (i_hold)
                    state <= START;
                else if (i_ram_ready)
                    state <= REQ;
                else
                    state <= WAIT;
            end

            default : state <= IDLE;
        endcase
    end
end

//--------------output----------------------
reg  [63:0] ram_addr_r0;
reg  [63:0] ram_addr_r1;
reg         ram_valid_r0;

always @(posedge clk) begin
    if(~rst_n) begin
        ram_addr_r0 <= `PC_START;
    end

    else if(i_hold) begin
        ram_addr_r0 <= ram_addr_r0;
    end

    else if (i_int_valid) begin
        ram_addr_r0 <= i_int_addr;
    end

    else if(i_branch_jump) begin
        ram_addr_r0 <= i_next_pc;
    end

    // wait for ready
    else if(i_ram_ready) begin
        ram_addr_r0 <= ram_addr_r0 + 4;
    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        ram_addr_r1 <= 0;
    end
    else begin
        ram_addr_r1 <= ram_addr_r0;
    end
end

always @(posedge clk) begin
    if(~rst_n) begin
        ram_valid_r0 <= 0;
    end
    else begin
        ram_valid_r0 <= (state == REQ) &
                        ~i_branch_jump &
                        ~i_hold;
    end
end

assign o_ram_addr    = ram_addr_r1;

assign o_ram_valid   = ram_valid_r0;

assign o_ram_size    = 3'b010;

assign o_pc          = o_ram_addr;

assign o_instr       = i_ram_rdata;

assign o_instr_valid = i_ram_ready & ~i_hold;

endmodule