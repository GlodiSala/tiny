`timescale 1ns/1ps

module spi_flash_sim (
    input wire spi_cs,
    input wire spi_sck,
    input wire spi_mosi,
    output reg spi_miso,
    
    // Signaux pour observer l'état du CPU
    input wire [15:0] pc_current,
    input wire [1:0]  spi_state,
    input wire [4:0]  bit_cnt
);

    // Programme en mémoire
    reg [15:0] memory [0:15];
    
    initial begin
        memory[0]  = 16'h620A;  // LOADI R1, 10
        memory[1]  = 16'h6414;  // LOADI R2, 20
        memory[2]  = 16'h0650;  // ADD R3, R1, R2
        memory[3]  = 16'h8600;  // STORE R3, [R0+0]
        memory[4]  = 16'h7800;  // LOAD R4, [R0+0]
        memory[5]  = 16'hF700;  // CMP R3, R4
        memory[6]  = 16'hA002;  // BRZ +2
        memory[7]  = 16'h6BFF;  // LOADI R5, 255
        memory[8]  = 16'h6C64;  // LOADI R6, 100
        memory[9]  = 16'h9FFF;  // JMP -1
        memory[10] = 16'h0000;
        memory[11] = 16'h0000;
        memory[12] = 16'h0000;
        memory[13] = 16'h0000;
        memory[14] = 16'h0000;
        memory[15] = 16'h0000;
    end
    
    reg [15:0] current_instruction;
    
    // Logique identique à tt_um_cpu_tb.v
    always @(negedge spi_sck or posedge spi_cs) begin
        if (spi_cs == 1'b1) begin
            spi_miso <= 1'b0;
        end else if (spi_state == 2'd3) begin  // STATE_DATA
            current_instruction = memory[pc_current[3:0]];
            spi_miso <= current_instruction[15 - bit_cnt];
        end else begin
            spi_miso <= 1'b0;
        end
    end

endmodule