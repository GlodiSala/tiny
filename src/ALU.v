`include "defines.vh"
module ALU(
    input  [3:0] operation,
    input  [7:0] operand1,
    input  [7:0] operand2,
    output reg [7:0] result,
    output reg zero_flag,
    output reg overflow_flag,
    output reg carry_flag,
    output reg negative_flag  
    );
    
    reg [8:0] tmp_result;
    reg [7:0] b_inv;
    reg cin;

    always @(*) begin
        // Valeurs par défaut pour éviter les latches
        tmp_result = 9'b0;
        overflow_flag = 1'b0;
        carry_flag = 1'b0;
        b_inv = 8'b0; 
        cin = 1'b0;

        case (operation)
            `OP_ADD, `OP_SUB: begin
                b_inv = (operation == `OP_SUB) ? ~operand2 : operand2;
                cin   = (operation == `OP_SUB);
                {carry_flag, result} = {1'b0, operand1} + {1'b0, b_inv} + {8'b0, cin};
                overflow_flag = (operand1[7] == b_inv[7]) && (result[7] != operand1[7]);
            end
            `OP_SHL: begin
                    result = operand1 << operand2[3:0];   // Shift left by lower 4 bits of operand2
                if (operand2[3:0] != 0 && operand2[3:0] <= 8) begin
                    carry_flag = operand1[8 - operand2[3:0]];
                    end 
            end
            `OP_SHR: begin
                result = operand1 >> operand2[3:0]; // Shift right by lower 4 bits of operand
                if (operand2[3:0] != 0 && operand2[3:0] <= 8) begin
                    carry_flag = operand1[operand2[3:0] - 1];
                    end 
                end
            `OP_AND: result = operand1 & operand2;
            `OP_OR:  result = operand1 | operand2;
            `OP_XOR: result = operand1 ^ operand2;
            
            default: result = 8'b0; // Default case to avoid latches
        endcase
        
        zero_flag = (result == 8'b0);
        negative_flag = result[7];
    end

 
endmodule
