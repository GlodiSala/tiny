`timescale 1ns/1ps

module tt_um_CPU_tb;

    // Signaux
    reg [7:0] ui_in;
    wire [7:0] uo_out;
    wire [7:0] uio_in;   // Wire car assigné plus bas
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    reg ena;
    reg clk;
    reg rst_n;

    // Signaux SPI pour debug
    wire spi_cs, spi_sclk;
    
    // Simulation Flash
    reg flash_active;
    reg [15:0] current_instruction;
    reg f_io1; // MISO (Seule donnée renvoyée par la Flash)

    // CPU (Device Under Test)
    tt_um_cpu uut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    // ============================================================
    // MAPPING SINGLE SPI (Standard)
    // ============================================================
    assign spi_cs   = uio_out[0];  // CS sur Pin 0
    assign spi_sclk = uio_out[3];  // CLOCK sur Pin 3

    // Simulation des données rentrantes (MISO)
    // uio[2] = MISO (Master In Slave Out) -> C'est là que la Flash répond
    assign uio_in[2] = flash_active ? f_io1 : 1'bz;
    
    // uio[1] = MOSI (Master Out Slave In) -> C'est le CPU qui parle, donc 0 en entrée
    assign uio_in[1] = 1'b0;
    
    // Le reste à 0
    assign uio_in[0] = 1'b0;
    assign uio_in[7:3] = 5'b00000;
    // ============================================================

    // Horloge 50 MHz
    always #10 clk = ~clk;

    // Programme en Flash (Instruction à renvoyer selon l'adresse)
    function [15:0] get_instruction;
        input [15:0] addr;
        begin
            case (addr)
                16'h0000: get_instruction = 16'h620A; // LOADI R1, 10
                16'h0001: get_instruction = 16'h6414; // LOADI R2, 20
                16'h0002: get_instruction = 16'h0650; // ADD R3, R1, R2
                16'h0003: get_instruction = 16'h8600; // STORE R3, [R0+0]
                16'h0004: get_instruction = 16'h7800; // LOAD R4, [R0+0]
                16'h0005: get_instruction = 16'hF700; // CMP R3, R4
                16'h0006: get_instruction = 16'hA002; // BRZ +2
                16'h0007: get_instruction = 16'h6BFF; // LOADI R5, 255
                16'h0008: get_instruction = 16'h6C64; // LOADI R6, 100
                16'h0009: get_instruction = 16'h9FFF; // JMP -1
                default:  get_instruction = 16'h0000;
            endcase
        end
    endfunction

    // Simulateur Flash SINGLE SPI
    // On envoie 1 bit sur MISO (uio[2]) à chaque coup d'horloge
    always @(negedge spi_sclk or posedge spi_cs) begin
        if (spi_cs == 1) begin
            flash_active = 0;
            f_io1 = 1'b0;
        end else if (uut.program_mem.state == 3'd3) begin 
            // ATTENTION: Dans ton nouveau module Single SPI, STATE_READ vaut 3 !
            flash_active = 1;
            current_instruction = get_instruction(uut.pc_current);
            
            // Envoi du bit courant (MSB vers LSB)
            // bit_cnt va de 0 à 15 dans ton module
            f_io1 = current_instruction[15 - uut.program_mem.bit_cnt];
        end else begin
            flash_active = 0;
            f_io1 = 1'b0;
        end
    end

    // Compteurs de tests
    reg [7:0] test_count;
    reg [7:0] pass_count;

    task check_register;
        input [2:0] reg_num;
        input [7:0] expected;
        input [200*8:1] test_name;
        begin
            test_count = test_count + 1;
            if (uut.regfile.register_tab[reg_num] === expected) begin
                pass_count = pass_count + 1;
                $display("  [PASS] %s: R%0d = 0x%02h", test_name, reg_num, expected);
            end else begin
                $display("  [FAIL] %s: R%0d = 0x%02h (attendu 0x%02h)", 
                         test_name, reg_num, uut.regfile.register_tab[reg_num], expected);
            end
        end
    endtask

    task check_memory;
        input [7:0] addr;
        input [7:0] expected;
        input [200*8:1] test_name;
        begin
            test_count = test_count + 1;
            if (uut.data_mem.ram[addr] === expected) begin
                pass_count = pass_count + 1;
                $display("  [PASS] %s: Mem[0x%02h] = 0x%02h", test_name, addr, expected);
            end else begin
                $display("  [FAIL] %s: Mem[0x%02h] = 0x%02h (attendu 0x%02h)", 
                         test_name, addr, uut.data_mem.ram[addr], expected);
            end
        end
    endtask

    integer i;
    integer instr_count;
    
    // Scénario de test
    initial begin
        $dumpfile("cpu_simulation.vcd");
        $dumpvars(0, tt_um_CPU_tb);
        
        clk = 0;
        rst_n = 0;
        ena = 1;
        ui_in = 8'h00;
        flash_active = 0;
        f_io1 = 0;
        test_count = 0;
        pass_count = 0;

        $display("");
        $display("========================================");
        $display("  TESTBENCH CPU (Single SPI Mode)");
        $display("========================================");
        $display("");

        #100;
        rst_n = 1;
        $display("[%0t] Reset desactive, demarrage du CPU", $time);

        instr_count = 0;

        for (i = 0; i < 4000; i = i + 1) begin // Augmenté à 4000 car Single SPI est plus lent
            @(posedge clk);
            if (uut.mem_ready) begin
                $display("[%0t] PC=%04h I=%04h | R1=%02h R2=%02h R3=%02h | Flags=%b",
                        $time, uut.pc_current, uut.instruction, 
                        uut.regfile.register_tab[1],
                        uut.regfile.register_tab[2],
                        uut.regfile.register_tab[3],
                        uut.stored_flags);
                
                instr_count = instr_count + 1;
                if (instr_count >= 12) begin
                    i = 4000; // Sortie de boucle
                end
            end
        end

        $display("");
        $display("========================================");
        $display("  VERIFICATIONS FINALES");
        $display("========================================");

        check_register(3'd1, 8'd10,  "LOADI R1, 10");
        check_register(3'd2, 8'd20,  "LOADI R2, 20");
        check_register(3'd3, 8'd30,  "ADD R3, R1, R2");
        check_memory(8'h00, 8'd30,   "STORE R3, [R0+0]");
        check_register(3'd4, 8'd30,  "LOAD R4, [R0+0]");
        check_register(3'd6, 8'd100, "Branch pris -> R6 = 100");
        
        test_count = test_count + 1;
        if (uut.regfile.register_tab[5] === 8'h00) begin
            pass_count = pass_count + 1;
            $display("  [PASS] R5 non modifie (branch pris)");
        end else begin
            $display("  [FAIL] R5 = 0x%02h (devrait etre 0x00)", uut.regfile.register_tab[5]);
        end

        $display("");
        $display("Tests reussis : %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display(">>> TOUS LES TESTS PASSENT ! <<<");
        end else begin
            $display("!!! %0d TEST(S) ECHOUE(S) !!!", test_count - pass_count);
        end
        $display("");

        #1000;
        $finish;
    end

    initial begin
        #80000; // Timeout augmenté car simulation plus lente
        $display("!!! TIMEOUT !!!");
        $finish;
    end

endmodule