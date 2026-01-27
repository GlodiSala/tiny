`timescale 1ns / 1ps

module ProgramMemory (
    input wire clk,
    input wire [15:0] address,
    output reg [15:0] instruction
);

    // Memory array: 2^16 locations, each 16 bits wide
    reg [15:0] memory [0:65535];
    
    // Initialize memory with some default values (optional)
    integer i;
    initial begin
        // Initialize all memory locations to NOP (0x0000) or any default instruction
        for (i = 0; i < 65536; i = i + 1) begin
            memory[i] = 16'h0000;
        end
        
        // You can preload specific instructions here if needed
        // Example:
        // memory[0] = 16'h1234;  // First instruction
        // memory[1] = 16'h5678;  // Second instruction
    end
    
    // Task to load program from file
    task load_program;
        input [1023:0] filename;
        begin
            $readmemh(filename, memory);
            $display("Program loaded from %s", filename);
        end
    endtask
    
    // Synchronous read operation
    always @(posedge clk) begin
        instruction <= memory[address];
    end

endmodule