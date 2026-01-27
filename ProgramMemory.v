

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

        // Preload a simple program:
        memory[0] = 16'b0110_0001_0000_0101;
        memory[1] = 16'b0110_0010_0000_0011;
        memory[2] = 16'b0001_0011_0000_0000;
        memory[3] = 16'b1111_0000_0000_0000;
        
        // The above encodings are illustrative. Adjust if your instruction format differs.
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