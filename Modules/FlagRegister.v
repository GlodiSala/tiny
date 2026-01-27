`timescale 1ns / 1ps

module FlagRegister(
    input clk,
    input rst,
    input write,
    input[1:0] flags_alu,
    output reg [1:0] stored_flags
);
always @(posedge clk or posedge rst)
begin 
    if (rst) begin
        stored_flags <= 0;
    end
    else if(write) begin
        stored_flags <= flags_alu;
    end
end
    
endmodule