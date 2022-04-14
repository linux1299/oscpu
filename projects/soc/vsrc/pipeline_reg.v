// Copyright 2022 LinYouxu, linyouxu1997@foxmail.com
// Last edit: 2022.04.11
// Pipeline register

`include "defines.v"

module pipeline_reg #(parameter N = 1)
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