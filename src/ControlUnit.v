`include "defines.vh"

module ControlUnit(
    input [15:0] instruction,

    // Signaux pour RegisterFile
    output reg reg_write,
    output reg [1:0] reg_write_src, 
    output reg [2:0] addr1_select,  
    output reg [2:0] addr2_select,  
    
    // Signaux pour DataMemory  
    output reg mem_read,
    output reg mem_write,
    
    // Signaux pour ALU
    output reg [3:0] alu_operation,
    output reg alu_src,             
    output reg [7:0] alu_immediate,
    
    // Signaux pour FlagRegister
    output reg flag_write,
    
    // Signaux pour BranchUnit
    // ❌ SUPPRIMÉ : output reg is_branch,
    output reg [3:0] branch_type,
    output reg [15:0] branch_offset
);

    wire [3:0] opcode = instruction[15:12];

    always @(*) begin
        reg_write     = 0;
        reg_write_src = 2'b00; 
        mem_read      = 0;
        mem_write     = 0;
        alu_operation = `OP_ADD;
        alu_src       = 0;
        alu_immediate = 8'b0;
        flag_write    = 0;
        // ❌ SUPPRIMÉ : is_branch     = 0;
        branch_type   = 4'b0000;
        branch_offset = 16'b0;
        
        // Adresses par défaut (format R-type standard)
        addr1_select = instruction[8:6];   // RS1
        addr2_select = instruction[5:3];   // RS2

        // ========== DÉCODAGE PAR OPCODE ==========
        case (opcode)
        
            // --- OPÉRATIONS ARITHMÉTIQUES R-TYPE ---
            `OP_ADD, `OP_SUB, `OP_AND, `OP_OR, `OP_XOR: begin
                alu_operation = opcode;
                flag_write    = 1;
                reg_write     = 1;
            end

            // --- ADDI: RD <= RD + Immediate ---
            `OP_ADDI: begin 
                alu_operation = `OP_ADD;
                alu_src       = 1;
                flag_write    = 1;
                reg_write     = 1;
                
                addr1_select = instruction[11:9];
                addr2_select = 3'b000;
                
                alu_immediate = instruction[7:0];
            end
            
            // --- LOADI: RD <= Immediate ---
            `OP_LI: begin 
                alu_operation = `OP_ADD;
                alu_src       = 1;
                flag_write    = 0;          
                reg_write     = 1;
                
                addr1_select = 3'b000;
                addr2_select = 3'b000;
                
                alu_immediate = instruction[7:0];
            end
            
            // --- LOAD: RD <= Mem[RS1 + Offset] ---
            `OP_L: begin 
                alu_operation = `OP_ADD;
                alu_src       = 1;
                mem_read      = 1;
                reg_write     = 1;
                reg_write_src = 2'b01;
                
                addr1_select = instruction[8:6];
                addr2_select = 3'b000;
                
                alu_immediate = {4'b0000, instruction[3:0]};
            end
            
            // --- STORE: Mem[RS1 + Offset] <= RS2 ---
            `OP_ST: begin 
                alu_operation = `OP_ADD;
                alu_src       = 1;
                mem_write     = 1;
                
                addr1_select = instruction[8:6];
                addr2_select = instruction[11:9];
                
                alu_immediate = {4'b0000, instruction[3:0]};
            end
            
            // --- BRANCHES ---
            `OP_JMP, `OP_BRZ, `OP_BRNZ, `OP_BRNS: begin
                // ❌ SUPPRIMÉ : is_branch   = 1;
                branch_type = opcode;
                branch_offset = {{4{instruction[11]}}, instruction[11:0]};
            end
            
            // --- SHIFT LEFT/RIGHT ---
            `OP_SHL, `OP_SHR: begin
                alu_operation = opcode;
                flag_write    = 1;
                reg_write     = 1;
                
                addr1_select = instruction[11:9];
                
                if (instruction[2]) begin
                    alu_src = 1;
                    alu_immediate = {4'b0000, instruction[5:2]};
                    addr2_select = 3'b000;
                end else begin
                    alu_src = 0;
                    addr2_select = instruction[8:6];
                end
            end
            
            // --- COMPARE: Flags <= RS1 - RS2 ---
            `OP_CMP: begin 
                alu_operation = `OP_SUB;
                flag_write    = 1;
                reg_write     = 0;
                
                addr1_select = instruction[11:9];
                addr2_select = instruction[8:6];
            end
            
            default: begin
                // NOP implicite
            end
        endcase
    end
endmodule
