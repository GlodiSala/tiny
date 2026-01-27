`include "defines.vh"

module tt_um_cpu (
    input  wire [7:0] ui_in,    // Entrées dédiées
    output wire [7:0] uo_out,   // Sorties dédiées (LEDs)
    input  wire [7:0] uio_in,   // IOs bidirectionnelles (Entrée)
    output wire [7:0] uio_out,  // IOs bidirectionnelles (Sortie)
    output wire [7:0] uio_oe,   // IOs bidirectionnelles (Direction)
    input  wire       ena,      // Signal d'activation
    input  wire       clk,      // Horloge
    input  wire       rst_n     // Reset actif bas
);

    // --- LOGIQUE DE BASE ---
    wire rst = !rst_n;

    // --- SIGNAUX INTERNES CPU ---
    wire [15:0] pc_current;
    wire [15:0] instruction;
    wire        mem_ready;
    
    // Le CPU ne tourne que si le chip est activé (ena) et la mémoire prête
    wire global_en = ena && mem_ready;

    // Signaux de Contrôle
    wire reg_write, mem_read, mem_write, flag_write, is_branch, alu_src;
    wire [1:0] reg_write_src;
    wire [3:0] alu_op;
    wire [3:0] branch_type;
    wire [15:0] branch_offset;
    wire [7:0] alu_immediate;
    wire [2:0] addr1_select, addr2_select;
    wire [7:0] reg_data1, reg_data2, alu_result, mem_rdata, reg_write_data;
    wire zero, overflow, carry, negative;
    wire [3:0] stored_flags;
    wire branch_taken;
    wire [15:0] branch_target;

    // --- SIGNAUX SPI ---
    wire spi_cs, spi_sclk, spi_io0_o, spi_io0_oe, spi_io0_i, spi_io1_o, spi_io1_oe, spi_io1_i;

    // --- MAPPING SPI (uio[0:3]) ---
    assign uio_out[0] = spi_cs;
    assign uio_oe[0]  = 1'b1;
    assign uio_out[1] = spi_io0_o;
    assign uio_oe[1]  = spi_io0_oe;
    assign spi_io0_i  = uio_in[1];
    assign uio_out[2] = 1'b0;      // MISO est une entrée
    assign uio_oe[2]  = 1'b0;      // Mode entrée pour uio[2]
    assign spi_io1_i  = uio_in[2]; // Connexion MISO critique
    assign uio_out[3] = spi_sclk;
    assign uio_oe[3]  = 1'b1;

    // Pins uio[7:4] inutilisées (mises à 0)
    assign uio_out[7:4] = 4'b0000;
    assign uio_oe[7:4]  = 4'b0000;

    // ========================================================================
    // INSTANCIATIONS DES MODULES
    // ========================================================================

    ProgramMemory_SPI program_mem (
        .clk(clk), .rst(rst), .address(pc_current), .instruction(instruction), .ready(mem_ready),
        .spi_cs(spi_cs), .spi_sclk(spi_sclk), .spi_io0_o(spi_io0_o), .spi_io0_oe(spi_io0_oe), 
        .spi_io0_i(spi_io0_i), .spi_io1_o(spi_io1_o), .spi_io1_oe(spi_io1_oe), .spi_io1_i(spi_io1_i)
    );

    ProgramCounter pc_inst (
        .clk(clk), .rst(rst), .mem_ready(global_en),
        .branch_en(branch_taken), .branch_addr(branch_target), .pc_current(pc_current)
    );

    ControlUnit cu (
        .instruction(instruction), .reg_write(reg_write), .reg_write_src(reg_write_src),
        .mem_read(mem_read), .mem_write(mem_write), .addr1_select(addr1_select),
        .addr2_select(addr2_select), .alu_operation(alu_op), .alu_src(alu_src),
        .alu_immediate(alu_immediate), .flag_write(flag_write), .is_branch(is_branch),
        .branch_type(branch_type), .branch_offset(branch_offset)
    );

    assign reg_write_data = (reg_write_src == 2'b01) ? mem_rdata : alu_result;
    
    RegisterFile regfile (
        .clk(clk), .rst(rst), .write_en(reg_write), .enable(global_en),
        .addr_wr(instruction[11:9]), .data_wr(reg_write_data), .addr1_r(addr1_select),
        .addr2_r(addr2_select), .out1_r(reg_data1), .out2_r(reg_data2)
    );

    ALU alu_inst (
        .operation(alu_op), .operand1(reg_data1), .operand2(alu_src ? alu_immediate : reg_data2),
        .result(alu_result), .zero_flag(zero), .overflow_flag(overflow), 
        .carry_flag(carry), .negative_flag(negative)
    );

    FlagRegister flag_reg (
        .clk(clk), .rst(rst), .write(flag_write && global_en),
        .flags_alu({overflow, carry, negative, zero}), .stored_flags(stored_flags)
    );

    BranchUnit branch_unit (
        .branch_type(branch_type), .branch_offset(branch_offset), .stored_flags(stored_flags),
        .pc_current(pc_current), .branch_taken(branch_taken), .branch_target(branch_target)
    );

    DataMemory data_mem (
        .clk(clk), .mem_read(mem_read), .mem_write(mem_write && global_en),
        .addr(alu_result), .wdata(reg_data2), .rdata(mem_rdata)
    );

    // ========================================================================
    // ANCRAGE TOTAL DES PINS (Protection contre GRT-0076)
    // ========================================================================
    
    // On mappe DIRECTEMENT les entrées problématiques sur les sorties uo_out
    // Si l'entrée est branchée à une sortie physique, elle ne peut PAS être supprimée.
    
    assign uo_out[0] = ui_in[0];      // Sauve ui_in[0]
    assign uo_out[1] = ena;           // Sauve ena
    assign uo_out[2] = spi_io1_i;    // Sauve uio_in[2] (MISO)
    assign uo_out[3] = is_branch;     // Sauve le signal interne is_branch
    
    // On XOR le reste pour nettoyer les warnings UNUSEDSIGNAL du linter
    assign uo_out[4] = ^ui_in[7:1];   // Sauve le reste de ui_in
    assign uo_out[5] = ^uio_in[7:3] ^ uio_in[0]; // Sauve le reste de uio_in
    
    // On garde deux LEDs pour voir que le PC bouge quand même !
    assign uo_out[6] = pc_current[0];
    assign uo_out[7] = pc_current[1];

endmodule
