`timescale 1ns / 1ps

module ALU(
    input  [3:0] operation,
    input  [7:0] operand1,
    input  [7:0] operand2,
    output reg [7:0] result,
    output reg        zero_flag,
    output reg        overflow_flag
    );
    
    localparam ADD = 4'b0000;
    localparam SUB  = 4'b0010;
    localparam AND  = 4'b0011;
    localparam OR   = 4'b0100;
    localparam XOR  = 4'b0101;
    localparam SHL  = 4'b1101;
    localparam SHR  = 4'b1110;

    always @(*) begin
        case (operation)
            ADD: begin
                {overflow_flag, result} = operand1 + operand2;
            end
            SUB: begin
                {overflow_flag, result} = operand1 - operand2;
            end
            AND: begin
                result = operand1 & operand2;
                overflow_flag = 0; // No overflow for AND operation
            end
            OR: begin
                result = operand1 | operand2;
                overflow_flag = 0; // No overflow for OR operation
            end
            XOR: begin
                result = operand1 ^ operand2;
                overflow_flag = 0; // No overflow for XOR operation
            end
            SHL: begin
                result = operand1 << operand2[3:0]; // Shift left by lower 4 bits of operand2
                overflow_flag = 0; // No overflow for shift operations
            end
            SHR: begin
                result = operand1 >> operand2[3:0]; // Shift right by lower 4 bits of operand2
                overflow_flag = 0; // No overflow for shift operations
            end
            default: begin
                result = 8'b0; // Default case to avoid latches
                overflow_flag = 0;
            end
        endcase
        
        zero_flag = (result == 8'b0);
    end

 
endmodule