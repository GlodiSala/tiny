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
    output reg [3:0] branch_type,
    output reg [9:0] branch_offset // RÉDUIT À 10 BITS
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
        branch_type   = 4'b0000;
        branch_offset = 10'b0; 
        
        // Adresses par défaut (Format R-type: RS1 bits 8-6, RS2 bits 5-3)
        addr1_select = instruction[8:6];   
        addr2_select = instruction[5:3];   

        case (opcode)
        
            // ADD, SUB, AND, OR, XOR
            `OP_ADD, `OP_SUB, `OP_AND, `OP_OR, `OP_XOR: begin
                alu_operation = opcode;
                flag_write    = 1;
                reg_write     = 1;
            end

            `OP_ADDI: begin 
                alu_operation = `OP_ADD;
                alu_src       = 1;
                flag_write    = 1;
                reg_write     = 1;  
                addr1_select  = instruction[11:9]; // RD sert de source
                alu_immediate = instruction[7:0];
            end
            
            `OP_LI: begin 
                alu_operation = `OP_ADD;
                alu_src       = 1;
                reg_write     = 1;
                addr1_select  = 3'b000; // R0 (0) + Imm
                alu_immediate = instruction[7:0];
            end
            
            `OP_L: begin 
                alu_operation = `OP_ADD;
                alu_src       = 1;
                mem_read      = 1;
                reg_write     = 1;
                reg_write_src = 2'b01; // Data vient de la RAM
                alu_immediate = {4'b0000, instruction[3:0]};
            end
            
            `OP_ST: begin 
                alu_operation = `OP_ADD;
                alu_src       = 1;
                mem_write     = 1;
                addr2_select  = instruction[11:9]; // Registre à stocker
                alu_immediate = {4'b0000, instruction[3:0]};
            end
            
            // BRANCHES (Optimisées 10 bits)
            `OP_JMP, `OP_BRZ, `OP_BRNZ, `OP_BRNS: begin
                branch_type   = opcode;
                // Extension de signe de l'offset 12 bits vers 10 bits
                // On garde les 10 bits de poids faible pour l'additionneur 10 bits
                branch_offset = instruction[9:0]; 
            end
            
            `OP_SHL, `OP_SHR: begin
                alu_operation = opcode;
                flag_write    = 1;
                reg_write     = 1;
                addr1_select  = instruction[11:9];
                if (instruction[5]) begin // Mode immédiat
                    alu_src = 1;
                    alu_immediate = {4'b0000, instruction[4:1]};
                end
            end
            
            `OP_CMP: begin 
                alu_operation = `OP_SUB;
                flag_write    = 1;
                addr1_select  = instruction[11:9];
                addr2_select  = instruction[8:6];
            end
            
            default: ; // NOP
        endcase
    end
endmodule