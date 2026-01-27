`include "defines.vh"

module tt_um_cpu (
    input  wire [7:0] ui_in,    // Inputs dédiés (Reset, Clock...)
    output wire [7:0] uo_out,   // Outputs dédiés (LEDs, UART, Audio)
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path
    input  wire       ena,      // Enable (toujours 1)
    input  wire       clk,      // Horloge
    input  wire       rst_n     // Reset actif BAS
);

    wire rst = !rst_n;

    // --- SIGNAUX INTERNES CPU ---
    wire [15:0] pc_current;
    wire [15:0] instruction;
    wire        mem_ready;      // STALL

    // Signaux de Contrôle
    wire reg_write, mem_read, mem_write, flag_write, is_branch, alu_src;
    wire [1:0] reg_write_src;
    wire [3:0] alu_op;
    wire [3:0] branch_type;
    wire [15:0] branch_offset;
    wire [7:0] alu_immediate;
    wire [2:0] addr1_select, addr2_select;

    // Données
    wire [7:0] reg_data1, reg_data2;
    wire [7:0] alu_result;
    wire [7:0] mem_rdata;
    wire [7:0] reg_write_data;

    // Flags
    wire zero, overflow, carry, negative;
    wire [3:0] stored_flags;
    
    // Branchement
    wire branch_taken;
    wire [15:0] branch_target;

    // Signaux SPI (Eclatés) pour la mémoire
    wire spi_cs, spi_sclk;
    wire spi_io0_o, spi_io0_oe, spi_io0_i;
    wire spi_io1_o, spi_io1_oe, spi_io1_i;

    // ========================================================================
    //  FUTURS MODULES (UART, AUDIO, I2C)
    // ========================================================================
    
    // 1. UART (Transmission PC) - Pin uo_out[4]
    wire uart_tx;
    assign uart_tx = 1'b1; // Default IDLE

    // 2. AUDIO (PWM) - Pin uo_out[7]
    wire audio_pwm;
    assign audio_pwm = 1'b0; // Default Silence

    // 3. I2C (Capteurs / Ecran) - Pins uio[6] & uio[7]
    wire i2c_scl_out, i2c_scl_oe, i2c_scl_in;
    wire i2c_sda_out, i2c_sda_oe, i2c_sda_in;
    
    // Par défaut : Input mode
    assign i2c_scl_out = 1'b0; 
    assign i2c_scl_oe  = 1'b0; 
    assign i2c_sda_out = 1'b0; 
    assign i2c_sda_oe  = 1'b0; 
    
    // Connexion entrées
    assign i2c_scl_in = uio_in[6];
    assign i2c_sda_in = uio_in[7];

    // ========================================================================
    // 1. MEMOIRE PROGRAMME (SPI FLASH)
    // ========================================================================
    ProgramMemory_SPI program_mem (
        .clk(clk), .rst(rst),
        .address(pc_current),
        .instruction(instruction),
        .ready(mem_ready),
        .spi_cs(spi_cs), .spi_sclk(spi_sclk),
        .spi_io0_o(spi_io0_o), .spi_io0_oe(spi_io0_oe), .spi_io0_i(spi_io0_i),
        .spi_io1_o(spi_io1_o), .spi_io1_oe(spi_io1_oe), .spi_io1_i(spi_io1_i)
    );

    // ========================================================================
    // MAPPING DES PINS
    // ========================================================================

    // --- A. MAPPING SPI (Standard TT: uio 0-3) ---
    // uio[0] = CS
    assign uio_out[0] = spi_cs;
    assign uio_oe[0]  = 1'b1;

    // uio[1] = MOSI / IO0
    assign uio_out[1] = spi_io0_o;
    assign uio_oe[1]  = spi_io0_oe;
    assign spi_io0_i  = uio_in[1];

    // uio[2] = MISO / IO1
    assign uio_out[2] = spi_io1_o;
    assign uio_oe[2]  = spi_io1_oe;
    assign spi_io1_i  = uio_in[2];

    // uio[3] = SCLK (Horloge SPI)
    assign uio_out[3] = spi_sclk;
    assign uio_oe[3]  = 1'b1;

    // --- B. MAPPING I2C (uio 6-7) ---
    assign uio_out[6] = i2c_scl_out;
    assign uio_oe[6]  = i2c_scl_oe;
    
    assign uio_out[7] = i2c_sda_out;
    assign uio_oe[7]  = i2c_sda_oe;

    // Pins libres (4 et 5)
    assign uio_out[5:4] = 2'b00;
    assign uio_oe[5:4]  = 2'b00;

    // --- C. MAPPING SORTIES (LEDs + UART + AUDIO) ---
    assign uo_out[0] = pc_current[0];
    assign uo_out[1] = pc_current[1];
    assign uo_out[2] = pc_current[2];
    assign uo_out[3] = pc_current[3];
    
    assign uo_out[4] = uart_tx;       // UART
    
    assign uo_out[5] = pc_current[5];
    assign uo_out[6] = pc_current[6];
    
    assign uo_out[7] = audio_pwm;     // AUDIO

    // ========================================================================
    // MODULES INTERNES (PC, CU, Regs, ALU...)
    // ========================================================================
    ProgramCounter pc (
        .clk(clk), .rst(rst),
        .mem_ready(mem_ready),
        .branch_en(branch_taken),
        .branch_addr(branch_target),
        .pc_current(pc_current)
    );

    ControlUnit cu (
        .instruction(instruction),
        .reg_write(reg_write), .reg_write_src(reg_write_src),
        .mem_read(mem_read), .mem_write(mem_write),
        .addr1_select(addr1_select),
        .addr2_select(addr2_select),
        .alu_operation(alu_op), .alu_src(alu_src), .alu_immediate(alu_immediate),
        .flag_write(flag_write),
        .is_branch(is_branch), .branch_type(branch_type), .branch_offset(branch_offset)
    );

    assign reg_write_data = (reg_write_src == 2'b01) ? mem_rdata : alu_result;
    RegisterFile regfile (
        .clk(clk), .rst(rst),
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
        .clk(clk), .rst(rst),
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
        .mem_write(mem_write && mem_ready),
        .addr(alu_result),
        .wdata(reg_data2),
        .rdata(mem_rdata)
    );

endmodule