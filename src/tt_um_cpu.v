`include "defines.vh"

module tt_um_cpu (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    wire rst = !rst_n;

    // ========================================================================
    // TRIPLE BUFFER POUR MISO (3 REGISTRES POUR ROUTAGE ASIC)
    // ========================================================================
    reg uio_in_2_buf1, uio_in_2_buf2, uio_in_2_buf3;
    
    always @(posedge clk) begin
        if (rst) begin
            uio_in_2_buf1 <= 1'b0;
            uio_in_2_buf2 <= 1'b0;
            uio_in_2_buf3 <= 1'b0;
        end else begin
            uio_in_2_buf1 <= uio_in[2];       // 1er étage
            uio_in_2_buf2 <= uio_in_2_buf1;   // 2ème étage
            uio_in_2_buf3 <= uio_in_2_buf2;   // 3ème étage (final)
        end
    end

    // ========================================================================
    // SIGNAUX INTERNES
    // ========================================================================
    wire [15:0] pc_current;
    wire [15:0] instruction;
    wire        mem_ready;

    wire reg_write, mem_read, mem_write, flag_write, alu_src;
    wire [1:0] reg_write_src;
    wire [3:0] alu_op;
    wire [3:0] branch_type;
    wire [15:0] branch_offset;
    wire [7:0] alu_immediate;
    wire [2:0] addr1_select, addr2_select;

    wire [7:0] reg_data1, reg_data2;
    wire [7:0] alu_result;
    wire [7:0] mem_rdata;
    wire [7:0] reg_write_data;

    wire zero, overflow, carry, negative;
    wire [3:0] stored_flags;
    
    wire branch_taken;
    wire [15:0] branch_target;

    // Signaux SPI
    wire spi_cs, spi_sclk;
    wire spi_io0_o, spi_io0_oe, spi_io0_i;
    wire spi_io1_i;

    // ========================================================================
    // PROGRAM MEMORY (SPI - SANS SYNCHRONIZER INTERNE)
    // ========================================================================
    ProgramMemory_SPI program_mem (
        .clk(clk),
        .rst(rst | !ena),
        .address(pc_current),
        .instruction(instruction),
        .ready(mem_ready),
        .spi_cs(spi_cs),
        .spi_sclk(spi_sclk),
        .spi_io0_o(spi_io0_o),
        .spi_io0_oe(spi_io0_oe),
        .spi_io0_i(spi_io0_i),
        .spi_io1_i(spi_io1_i)
    );

    // ========================================================================
    // MAPPING SPI (STANDARD TINY TAPEOUT)
    // ========================================================================
    assign uio_out[0] = spi_cs;
    assign uio_oe[0]  = 1'b1;

    assign uio_out[1] = spi_io0_o;
    assign uio_oe[1]  = spi_io0_oe;
    assign spi_io0_i  = uio_in[1];

    assign uio_out[2] = 1'b0;
    assign uio_oe[2]  = 1'b0;
    assign spi_io1_i  = uio_in_2_buf3;  // ✅ Signal 3x bufférisé

    assign uio_out[3] = spi_sclk;
    assign uio_oe[3]  = 1'b1;

    assign uio_out[7:4] = 4'b0000;
    assign uio_oe[7:4]  = 4'b0000;

    // ========================================================================
    // SORTIES (LEDs = PC)
    // ========================================================================
    assign uo_out = pc_current[7:0];

    // ========================================================================
    // MODULES INTERNES
    // ========================================================================
    ProgramCounter pc (
        .clk(clk),
        .rst(rst | !ena),
        .mem_ready(mem_ready),
        .branch_en(branch_taken),
        .branch_addr(branch_target),
        .pc_current(pc_current)
    );

    ControlUnit cu (
        .instruction(instruction),
        .reg_write(reg_write),
        .reg_write_src(reg_write_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .addr1_select(addr1_select),
        .addr2_select(addr2_select),
        .alu_operation(alu_op),
        .alu_src(alu_src),
        .alu_immediate(alu_immediate),
        .flag_write(flag_write),
        .branch_type(branch_type),
        .branch_offset(branch_offset)
    );

    assign reg_write_data = (reg_write_src == 2'b01) ? mem_rdata : alu_result;
    
    RegisterFile regfile (
        .clk(clk),
        .rst(rst | !ena),
        .write_en(reg_write),
        .enable(mem_ready),
        .addr_wr(instruction[11:9]),
        .data_wr(reg_write_data),
        .addr1_r(addr1_select),
        .addr2_r(addr2_select),
        .out1_r(reg_data1),
        .out2_r(reg_data2)
    );

    wire [7:0] alu_operand_b = (alu_src) ? alu_immediate : reg_data2;
    
    ALU alu (
        .operation(alu_op),
        .operand1(reg_data1),
        .operand2(alu_operand_b),
        .result(alu_result),
        .zero_flag(zero),
        .overflow_flag(overflow),
        .carry_flag(carry),
        .negative_flag(negative)
    );

    FlagRegister flag_reg (
        .clk(clk),
        .rst(rst | !ena),
        .write(flag_write && mem_ready),
        .flags_alu({overflow, carry, negative, zero}),
        .stored_flags(stored_flags)
    );

    BranchUnit branch_unit (
        .branch_type(branch_type),
        .branch_offset(branch_offset),
        .stored_flags(stored_flags),
        .pc_current(pc_current),
        .branch_taken(branch_taken),
        .branch_target(branch_target)
    );

    DataMemory data_mem (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write && mem_ready && ena),
        .addr(alu_result),
        .wdata(reg_data2),
        .rdata(mem_rdata)
    );

    // ========================================================================
    // SUPPRESSION WARNINGS
    // ========================================================================
    /* verilator lint_off UNUSEDSIGNAL */
    wire _unused_ok = &{1'b0, ui_in, uio_in[7:3], uio_in[1:0], 1'b0};
    /* verilator lint_on UNUSEDSIGNAL */

endmodule
