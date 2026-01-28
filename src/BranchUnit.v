
`include "defines.vh"
module BranchUnit(
    input [3:0]  branch_type,
    input [9:0]  branch_offset,
    input [3:0]  stored_flags,   
    input [9:0] pc_current,
    output wire [9:0] next_pc
);

    reg branch_taken;
    wire [9:0] adder_input_b;

    always @(*) begin
        case (branch_type)
            `OP_JMP : branch_taken = 1;
            `OP_BRZ : branch_taken = stored_flags[0];
            `OP_BRNZ : branch_taken = ~stored_flags[0];
            `OP_BRNS : branch_taken = ~stored_flags[1];
            default : branch_taken = 0;
        endcase
    end
    assign adder_input_b = branch_taken ? branch_offset : 10'd1;
    assign next_pc = pc_current + adder_input_b;
    wire [1:0] _unused_flags = stored_flags[3:2];

endmodule
