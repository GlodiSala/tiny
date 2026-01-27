`timescale 1ns / 1ps

module BranchUnit(
    input [3:0] branch_type,
    input [15:0] branch_offset,      // Déjà extrait par ControlUnit
    input[1:0] stored_flags,
    input branch_enable,
    input [15:0] pc_current,
    output reg [15:0] pc_next
);

// Répète le bit de signe (offset[11]) sur 4 bits pour passer de 12→16 bits
// Exemple : 0xFFA (−6) devient 0xFFFA (toujours −6)

localparam JMP  = 4'b1001;  // jump
localparam BRZ = 4'b1010;  // branch if zero
localparam BRNZ = 4'b1011; // Branch if not zero	
localparam BRNS = 4'b1100; // BRNS : branch if not overflow

reg branch;    
always @(*) begin
    case (branch_type)
        JMP : branch = 1;
        BRZ : branch = stored_flags[0];
        BRNZ : branch = ~stored_flags[0];
        BRNS : branch = ~stored_flags[1];
        default : branch = 0;
    endcase
end
always @(*) begin // logique combinatoire
    if (branch_enable && branch) begin
        pc_next = pc_current + branch_offset;  // Relative jump
    end else begin
        pc_next = pc_current + 1;              // Next instruction
    end
end

endmodule