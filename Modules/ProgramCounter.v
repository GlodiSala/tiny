`timescale 1ns / 1ps
module ProgramCounter(
    input clk,
    input rst,
    input [15:0] pc_next,
    output reg [15:0] pc_current
);
always @ (posedge clk or posedge rst)
begin
    if (rst) begin
        pc_current <= 16'h0;
    end else begin
        pc_current <= pc_next;
    end
end

endmodule