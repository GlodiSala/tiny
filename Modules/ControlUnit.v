`timescale 1ns / 1ps
module ControlUnit(
    input [15:0] instruction,

    // signals for RegisterFile
    output reg reg_write,
    output reg [1:0] reg_write_src, // ALU/Memory/PC+1
    // Possible values for reg_write_src
    // 2'b00 : ALU result (default)
    // 2'b01 : Data Memory read value
    // 2'b10 : PC + 1 (used in jump-and-link instructions for saving return address, not used in this CPU implementation)
    
    // signals for DataMemory  
    output reg mem_read,
    output reg mem_write,
    
    // signals pour ALU
    output reg [3:0] alu_operation,
    output reg alu_src,             // Register/Immediate
    
    // signals for FlagRegister
    output reg flag_write,
    
    output reg is_branch,
    output reg [3:0] branch_type,
    output reg [15:0] branch_offset
);

wire [3:0] opcode = instruction[15:12];

localparam ADD  = 4'b0000;
localparam ADDI = 4'b0001;
localparam SUB  = 4'b0010;
localparam AND  = 4'b0011;
localparam OR   = 4'b0100;
localparam XOR  = 4'b0101;
localparam LI   = 4'b0110; 
localparam L    = 4'b0111;
localparam ST   = 4'b1000;
localparam JMP  = 4'b1001;  
localparam BRZ  = 4'b1010;  
localparam BRNZ = 4'b1011;  
localparam BRNS = 4'b1100;  
localparam SHL  = 4'b1101;
localparam SHR  = 4'b1110;
localparam CMP  = 4'b1111;

always @(*) begin
    // Valeurs par défaut
   reg_write     = 0;
    reg_write_src = 2'b00; // ALU
    mem_read      = 0;
    mem_write     = 0;
    alu_operation = 4'b0000;
    alu_src       = 0;
    flag_write    = 0;
    is_branch     = 0;
    branch_type   = 4'b0000;
    branch_offset = 16'b0;

    case (opcode)
        ADD, SUB, AND, OR, XOR, SHL, SHR : begin 
            alu_operation = opcode;
            flag_write    = 1;
            reg_write     = 1;
        end

        ADDI : begin 
            alu_operation = ADD;
            alu_src       = 1;     // Immediate
            flag_write    = 1;
            reg_write     = 1;
        end
        
        BRZ, BRNZ, BRNS, JMP : begin
            is_branch   = 1;
            branch_type = opcode;
            branch_offset = {{4{instruction[11]}}, instruction[11:0]}; // Sign extension

        end
        
        LI: begin 
            alu_operation = ADD;
            alu_src     = 1;
            reg_write   = 1;
            
        end
        
        L: begin 
            alu_operation = ADD;    // Doit utiliser ADD pour calculer l'adresse
            alu_src       = 1;      // Doit utiliser l'offset comme opérande 2
            mem_read      = 1;
            reg_write     = 1;
            reg_write_src = 2'b01;  // Source = mémoire
        end
        
        ST: begin 
                alu_operation = ADD;    
                alu_src       = 1;     
                mem_write     = 1;

        end
        
        CMP: begin 
            alu_operation = SUB;  // Only to update flags
            flag_write    = 1;
        end
        
        default: begin 
            // Pas d'action
        end
    endcase
end

endmodule
