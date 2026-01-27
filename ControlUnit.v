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
    output reg is_branch,
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
        is_branch     = 0;
        branch_type   = 4'b0000;
        branch_offset = 16'b0;
        
        // Adresses par défaut (format R-type standard)
        addr1_select = instruction[8:6];   // RS1
        addr2_select = instruction[5:3];   // RS2
        if (opcode == `OP_ADD) begin
        $display("  [ControlUnit] ADD détecté: I=%04h, bits[8:6]=%b=%d, bits[5:3]=%b=%d",
                 instruction, instruction[8:6], instruction[8:6], 
                 instruction[5:3], instruction[5:3]);
    end
        // ========== DÉCODAGE PAR OPCODE ==========
        case (opcode)
        
            // --- OPÉRATIONS ARITHMÉTIQUES R-TYPE ---
            `OP_ADD, `OP_SUB, `OP_AND, `OP_OR, `OP_XOR: begin
                alu_operation = opcode;
                flag_write    = 1;
                reg_write     = 1;
                // addr1/addr2 utilisent les valeurs par défaut
            end

            // --- ADDI: RD <= RD + Immediate ---
            `OP_ADDI: begin 
                alu_operation = `OP_ADD;
                alu_src       = 1;          // Utiliser immediate
                flag_write    = 1;
                reg_write     = 1;
                
                addr1_select = instruction[11:9];  // RD
                addr2_select = 3'b000;             // Inutilisé
                
                alu_immediate = instruction[7:0];  // Signed 8-bit
            end
            
            // --- LOADI: RD <= Immediate ---
            `OP_LI: begin 
                alu_operation = `OP_ADD;
                alu_src       = 1;          // Utiliser immediate
                flag_write    = 0;          
                reg_write     = 1;
                
                addr1_select = 3'b000;      // R0 = 0
                addr2_select = 3'b000;      // Inutilisé
                
                alu_immediate = instruction[7:0];  // Signed 8-bit
            end
            
            // --- LOAD: RD <= Mem[RS1 + Offset] ---
            `OP_L: begin 
                alu_operation = `OP_ADD;    // Calcul d'adresse
                alu_src       = 1;          // Utiliser offset
                mem_read      = 1;
                reg_write     = 1;
                reg_write_src = 2'b01;      // Données viennent de la mémoire
                
                addr1_select = instruction[8:6];   // RS1 (base)
                addr2_select = 3'b000;             // Inutilisé
                
                alu_immediate = {4'b0000, instruction[3:0]};
            end
            
            // --- STORE: Mem[RS1 + Offset] <= RS2 ---
            `OP_ST: begin 
                alu_operation = `OP_ADD;    // Calcul d'adresse
                alu_src       = 1;          // Utiliser offset
                mem_write     = 1;
                
                addr1_select = instruction[8:6];   // RS1 (base)
                addr2_select = instruction[11:9];  // RS2 (data à stocker)
                
                alu_immediate = {4'b0000, instruction[3:0]};
            end
            
            // --- BRANCHES ---
            `OP_JMP, `OP_BRZ, `OP_BRNZ, `OP_BRNS: begin
                is_branch   = 1;
                branch_type = opcode;
                // Sign-extend 12 bits → 16 bits
                branch_offset = {{4{instruction[11]}}, instruction[11:0]};
            end
            
            // --- SHIFT LEFT/RIGHT ---
            `OP_SHL, `OP_SHR: begin
                alu_operation = opcode;
                flag_write    = 1;
                reg_write     = 1;
                
                addr1_select = instruction[11:9];  // RD
                
                // Le bit [2] détermine si on utilise un registre ou immediate
                if (instruction[2]) begin  // Imm? == 1 → Mode immediate
                    alu_src = 1;
                    alu_immediate = {4'b0000, instruction[5:2]};  // 4 bits d'immediate
                    addr2_select = 3'b000;  // RS inutilisé
                end else begin  // Imm? == 0 → Mode registre
                    alu_src = 0;
                    addr2_select = instruction[8:6];  // RS contient le shift amount
                end
            end
            
            // --- COMPARE: Flags <= RS1 - RS2 ---
            `OP_CMP: begin 
                alu_operation = `OP_SUB;
                flag_write    = 1;
                reg_write     = 0;
                
                addr1_select = instruction[11:9];  // RS1
                addr2_select = instruction[8:6];   // RS2
            end
            
            default: begin
                // NOP implicite
            end
        endcase
    end
endmodule