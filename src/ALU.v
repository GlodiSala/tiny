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
    
    reg [7:0] b_inv;
    reg cin;
    wire [8:0] sum_ext; // Utilisation d'un fil pour l'addition étendue

    // Pré-calcul de l'inversion pour ADD/SUB
    always @(*) begin
        b_inv = operand2;
        cin   = 1'b0;
        if (operation == `OP_SUB) begin
            b_inv = ~operand2;
            cin   = 1'b1;
        end
    end

    // Additionneur unique pour ADD, SUB et CMP
    assign sum_ext = {1'b0, operand1} + {1'b0, b_inv} + {8'b0, cin};

    always @(*) begin
        // Valeurs par défaut minimalistes
        result = 8'b0;
        carry_flag = 1'b0;
        overflow_flag = 1'b0;

        case (operation)
            `OP_ADD, `OP_SUB: begin
                result = sum_ext[7:0];
                carry_flag = sum_ext[8];
                // Overflow : seulement si les signes des opérandes sont identiques 
                // mais différents du signe du résultat
                overflow_flag = (operand1[7] == b_inv[7]) && (result[7] != operand1[7]);
            end

            `OP_SHL: result = operand1 << operand2[3:0];
            `OP_SHR: result = operand1 >> operand2[3:0];

            `OP_AND: result = operand1 & operand2;
            `OP_OR:  result = operand1 | operand2;
            `OP_XOR: result = operand1 ^ operand2;
            
            default: result = sum_ext[7:0]; 
        endcase
        
        // Flags calculés une seule fois en sortie
        zero_flag = ~|result;      
        negative_flag = result[7];
    end
endmodule