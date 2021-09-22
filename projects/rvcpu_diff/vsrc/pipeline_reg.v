// Copyright 2021 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2021.07.19
// Pipeline register

`include "defines.v"

module pipeline_reg #(parameter N = 1)
    (
    input              clk,
    input              clear,
    input              hold,
    input      [N-1:0] din,
    output reg [N-1:0] dout
);

always @(posedge clk) begin
    if (clear)
        dout <= {N{1'b0}};
    else if (hold)
        dout <= dout;
    else
        dout <= din;
end


endmodule