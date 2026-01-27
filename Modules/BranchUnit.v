`timescale 1ns / 1ps

module BranchUnit(
    input [3:0]  branch_type,
    input [15:0] branch_offset,
    input [3:0]  stored_flags,    // REMIS À 4 BITS
    input        branch_enable,
    input [15:0] pc_current,
    output reg [15:0] pc_next
);

    localparam JMP  = 4'b1001;
    localparam BRZ  = 4'b1010;
    localparam BRNZ = 4'b1011;
    localparam BRNS = 4'b1100;

    reg branch;    
    always @(*) begin
        case (branch_type)
            JMP  : branch = 1;
            BRZ  : branch = stored_flags[0];  // Zero flag
            BRNZ : branch = ~stored_flags[0];
            BRNS : branch = ~stored_flags[1]; // Overflow flag
            default : branch = 0;
        endcase
    end

    always @(*) begin
        if (branch_enable && branch) begin
            pc_next = pc_current + branch_offset;
        end else begin
            pc_next = pc_current + 1;
        end
    end

    // ON CONSOMME LES BITS 2 et 3 ICI POUR LE LINTER
    wire [1:0] _unused_flags = stored_flags[3:2];

endmodule
