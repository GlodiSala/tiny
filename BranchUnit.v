
`include "defines.vh"
module BranchUnit(
    input [3:0]  branch_type,
    input [15:0] branch_offset, 
    input [3:0]  stored_flags,   
    input [15:0] pc_current,
    
    output reg        branch_taken,  // Vers PC.branch_en
    output wire [15:0] branch_target // Vers PC.branch_addr
);

assign branch_target = pc_current + branch_offset;

always @(*) begin
    case (branch_type)
        `OP_JMP : branch_taken = 1;
        `OP_BRZ : branch_taken = stored_flags[0];
        `OP_BRNZ : branch_taken = ~stored_flags[0];
        `OP_BRNS : branch_taken = ~stored_flags[1];
        default : branch_taken = 0;
    endcase
end
wire [1:0] _unused_flags = stored_flags[3:2];

endmodule
