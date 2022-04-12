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
    input              valid_i,

    // master ports
    output reg [N-1:0] data_o,
    output reg         valid_o
);

always @(posedge clk) begin
    if (~rst_n) begin
        data_o  <= {N{1'b0}};
        valid_o <= 1'b0;
    end
    else if (clear_i) begin
        data_o  <= {N{1'b0}};
        valid_o <= 1'b0;
    end
    else if (hold_i) begin
        data_o  <= data_o;
        valid_o <= valid_o;
    end
    else if (valid_i) begin
        data_o  <= data_i;
        valid_o <= 1'b1;
    end
    else begin
        valid_o <= 1'b0;
    end
end

endmodule