`include "defines.v"

module fifo_depth_1 #(
    parameter FIFO_WIDTH = 32
)
(
    input                               clk,
    input                               rst_n,
    input                               read,
    input                               write,
    input       [FIFO_WIDTH - 1 : 0]    fifo_in,
    output      [FIFO_WIDTH - 1 : 0]    fifo_out,
    output  reg                         fifo_empty
);

reg     [FIFO_WIDTH - 1 : 0]    fifo_ram  ;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        fifo_empty <= 1'b1;
    end
    else begin
        if(read & ~write) begin
            fifo_empty <= 1'b1;
        end
        else if(~read & write) begin
            fifo_empty <= 1'b0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        fifo_ram <= 0;
    end
    else if (~read & write & fifo_empty) begin
        fifo_ram <= fifo_in;
    end
    else if (read & write & ~fifo_empty) begin
        fifo_ram <= fifo_in;
    end
end

assign fifo_out =  read ?
                  (fifo_empty ? 
                  (write ? fifo_in : 0) :
                   fifo_ram) : 0;


endmodule