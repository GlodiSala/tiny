`include "defines.vh"

module tt_um_cpu (
    input  wire [7:0] ui_in,    // Entrées dédiées
    output wire [7:0] uo_out,   // Sorties dédiées
    input  wire [7:0] uio_in,   // IOs bidirectionnelles (Entrée)
    output wire [7:0] uio_out,  // IOs bidirectionnelles (Sortie)
    output wire [7:0] uio_oe,   // IOs bidirectionnelles (Contrôle)
    input  wire       ena,      // Signal d'activation (LE COUPABLE !)
    input  wire       clk,      // Horloge
    input  wire       rst_n     // Reset actif bas
);

    wire rst = !rst_n;

    // --- SIGNAUX INTERNES CPU ---
    wire [15:0] pc_current;
    wire [15:0] instruction;
    wire        mem_ready;
    
    // ANCRAGE FONCTIONNEL : Le CPU ne fonctionne QUE si ena est à 1
    // On crée un signal global "enable" pour tout le processeur
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
    wire spi_cs, spi_sclk, spi_io0_o, spi_io0_oe, spi_io0_i, spi_io1_o, spi_io1_oe;
    
    // On garde l'attribut keep pour le MISO qui a été réglé au run précédent
    (* keep, dont_touch *) wire spi_io1_i; 

    // --- MAPPING SPI ---
    assign uio_out[0] = spi_cs;
    assign uio_oe[0]  = 1'b1;
    assign uio_out[1] = spi_io0_o;
    assign uio_oe[1]  = spi_io0_oe;
    assign spi_io0_i  = uio_in[1];
    assign uio_out[2] = spi_io1_o;
    assign uio_oe[2]  = spi_io1_oe;
    assign spi_io1_i  = uio_in[2]; 
    assign uio_out[3] = spi_sclk;
    assign uio_oe[3]  = 1'b1;
    assign uio_out[7:4] = 4'b0000;
    assign uio_oe[7:4]  = 4'b0000;

    // ========================================================================
    // INSTANCIATIONS (Note l'utilisation de global_en)
    // ========================================================================
    ProgramMemory_SPI program_mem (
        .clk(clk), .rst(rst), .address(pc_current), .instruction(instruction), 
        .ready(mem_ready), .spi_cs(spi_cs), .spi_sclk(spi_sclk),
        .spi_io0_o(spi_io0_o), .spi_io0_oe(spi_io0_oe), .spi_io0_i(spi_io0_i),
        .spi_io1_o(spi_io1_o), .spi_io1_oe(spi_io1_oe), .spi_io1_i(spi_io1_i)
    );

    ProgramCounter pc_inst (
        .clk(clk), .rst(rst), .mem_ready(global_en), // ANCRAGE ICI
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
        .clk(clk), .rst(rst), .write_en(reg_write), .enable(global_en), // ANCRAGE ICI
        .addr_wr(instruction[11:9]), .data_wr(reg_write_data),
        .addr1_r(addr1_select), .addr2_r(addr2_select), .out1_r(reg_data1), .out2_r(reg_data2)
    );

    ALU alu_inst (
        .operation(alu_op), .operand1(reg_data1), .operand2(alu_src ? alu_immediate : reg_data2),
        .result(alu_result), .zero_flag(zero), .overflow_flag(overflow), 
        .carry_flag(carry), .negative_flag(negative)
    );

    FlagRegister flag_reg (
        .clk(clk), .rst(rst), .write(flag_write && global_en), // ANCRAGE ICI
        .flags_alu({overflow, carry, negative, zero}), .stored_flags(stored_flags)
    );

    BranchUnit branch_unit (
        .branch_type(branch_type), .branch_offset(branch_offset), .stored_flags(stored_flags),
        .pc_current(pc_current), .branch_taken(branch_taken), .branch_target(branch_target)
    );

    DataMemory data_mem (
        .clk(clk), .mem_read(mem_read), .mem_write(mem_write && global_en), // ANCRAGE ICI
        .addr(alu_result), .wdata(reg_data2), .rdata(mem_rdata)
    );

   // ========================================================================
    // ANCRAGE TOTAL (Anti-Optimisation Nucléaire)
    // ========================================================================
    
    // uo_out[3:0] : Affichage des bits bas du PC
    assign uo_out[3:0] = pc_current[3:0];

    // uo_out[4] : On sort directement ENA (indispensable)
    assign uo_out[4] = ena;

    // uo_out[5] : On fait un XOR de tous les bits de ui_in (sauve les 8 pins ui_in)
    assign uo_out[5] = ^ui_in;

    // uo_out[6] : On fait un XOR de tous les bits de uio_in (sauve uio_in[2] et les autres)
    assign uo_out[6] = ^uio_in;

    // uo_out[7] : Signal de debug (par exemple is_branch ou PC bit haut)
    assign uo_out[7] = pc_current[4];

endmodule
