`timescale 1ns / 1ps

module CPU(
    input clk,
    input rst,
    output [15:0] pc_out,
    output [15:0] current_instruction,
    output [7:0] alu_result_out
);

    wire [15:0] pc_current, pc_next;
    wire [15:0] instruction;
    wire [1:0] stored_flags;
    wire [7:0] alu_result;
    wire [7:0] reg_data1, reg_data2;
    wire [7:0] reg_write_data;
    wire [7:0] memory_data_out;
    wire [7:0] alu_operand2;
    wire [1:0] flags_alu;
    
    wire reg_write;
    wire [1:0] reg_write_src;
    wire mem_read, mem_write;
    wire [3:0] alu_operation;
    wire alu_src;
    wire flag_write;
    wire is_branch;
    wire [3:0] branch_type;
    wire [15:0] branch_offset;
    
    wire [3:0] opcode = instruction[15:12];
    
    localparam ADD   = 4'b0000;
    localparam ADDI  = 4'b0001;
    localparam SUB   = 4'b0010;
    localparam AND   = 4'b0011;
    localparam OR    = 4'b0100;
    localparam XOR   = 4'b0101;
    localparam LOADI = 4'b0110;
    localparam LOAD  = 4'b0111;
    localparam STORE = 4'b1000;
    localparam JMP   = 4'b1001;
    localparam BRZ   = 4'b1010;
    localparam BRNZ  = 4'b1011;
    localparam BRNS  = 4'b1100;
    localparam SHL   = 4'b1101;
    localparam SHR   = 4'b1110;
    localparam CMP   = 4'b1111;
    
    reg [2:0] rs1_addr, rs2_addr, rd_addr;
    
    wire [2:0] dest_reg = instruction[11:9];
    wire [2:0] src1_reg = instruction[8:6]; 
    wire [2:0] src2_reg = instruction[5:3];
    wire [8:0] immediate_9 = instruction[8:0];
    wire [5:0] offset_6 = instruction[5:0];
    wire [7:0] immediate_8 = immediate_9[7:0];
    
    always @(*) begin
        case (opcode)
            ADD, SUB, AND, OR, XOR: begin
                rs1_addr = src1_reg;
                rs2_addr = src2_reg;
                rd_addr = dest_reg;
            end
            ADDI: begin
                rs1_addr = instruction[8:6];
                rs2_addr = 3'b000;
                rd_addr = dest_reg;
            end
            LOADI: begin
                rs1_addr = 3'b000;
                rs2_addr = 3'b000;
                rd_addr = dest_reg;
            end
            LOAD: begin
                rs1_addr = src1_reg;
                rs2_addr = 3'b000;
                rd_addr = dest_reg;
            end  
            STORE: begin
                rs1_addr = src1_reg;
                rs2_addr = instruction[11:9];
                rd_addr = 3'b000;
            end
            SHL, SHR: begin
                rs1_addr = instruction[11:9];
                rs2_addr = instruction[8:6];
                rd_addr = instruction[11:9];
            end
            CMP: begin
                rs1_addr = instruction[11:9];
                rs2_addr = instruction[8:6];
                rd_addr = 3'b000;
            end
            default: begin
                rs1_addr = 3'b000;
                rs2_addr = 3'b000;
                rd_addr = 3'b000;
            end
        endcase
    end

    assign pc_out = pc_current;
    assign current_instruction = instruction;
    assign alu_result_out = alu_result;

    assign alu_operand2 = alu_src ? immediate_8 : reg_data2;


    assign reg_write_data = (reg_write_src == 2'b01) ? memory_data_out : 
                           (reg_write_src == 2'b10) ? (pc_current + 1) : 
                           alu_result;

    ProgramCounter pc_inst(
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc_current(pc_current)
    );

    ProgramMemory prog_mem(
        .clk(clk),
        .address(pc_current),
        .instruction(instruction)
    );

    ControlUnit ctrl_unit(
        .instruction(instruction),
        .reg_write(reg_write),
        .reg_write_src(reg_write_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_operation(alu_operation),
        .alu_src(alu_src),
        .flag_write(flag_write),
        .is_branch(is_branch),
        .branch_type(branch_type),
        .branch_offset(branch_offset)
    );

    RegisterFile reg_file(
        .clk(clk),
        .rst(rst),
        .write(reg_write),
        .addr1_wr(rd_addr),
        .data_wr(reg_write_data),
        .addr1_r(rs1_addr),
        .addr2_r(rs2_addr),
        .out1_r(reg_data1),
        .out2_r(reg_data2)
    );

    ALU alu_inst(
        .operation(alu_operation),
        .operand1(reg_data1),
        .operand2(alu_operand2),
        .result(alu_result),
        .zero_flag(flags_alu[0]),
        .overflow_flag(flags_alu[1])
    );

    FlagRegister flag_reg(
        .clk(clk),
        .rst(rst),
        .write(flag_write),
        .flags_alu(flags_alu),
        .stored_flags(stored_flags)
    );

    DataMemory data_mem(
        .clk(clk),
        .we(mem_write),
        .addr(alu_result),
        .din(reg_data2),
        .dout(memory_data_out)
    );

    BranchUnit branch_unit(
        .branch_type(branch_type),
        .branch_offset(branch_offset),
        .stored_flags(stored_flags),
        .branch_enable(is_branch),
        .pc_current(pc_current),
        .pc_next(pc_next)
    );

endmodule