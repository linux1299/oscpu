
module ysyx_210184_ffn
#( parameter WIDTH = 64 )
(
    input  wire               clk,
    input  wire               rst,
    input  wire               stall,
    input  wire [WIDTH-1 : 0] d,
    output reg  [WIDTH-1 : 0] q
);

    always @(posedge clk) begin
        if (~rst) q <= {WIDTH{1'b0}};
        else begin
            if(stall) q <= q;
            else      q <= d;
        end 
    end

endmodule