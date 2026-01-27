`timescale 1ns / 1ps
module DataMemory (
    input wire clk,
    input wire we,                // Write enable
    input wire [7:0] addr,        // 8-bit address (256 locations)
    input wire [7:0] din,         // Data input
    output reg [7:0] dout         // Data output
);

    reg [7:0] mem [0:255];        // 256 x 8-bit memory

    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 8'b0;
    end

    always @(posedge clk) begin
        if (we) begin
            mem[addr] <= din; 
            // dout <= din;          
        end 
    end
    always @(*) begin
        dout = mem[addr];  
    end



endmodule