`timescale 1ns/1ps

module ProgramMemory_SPI_tb;

    reg clk;
    reg rst;
    reg [15:0] address;
    wire [15:0] instruction;
    wire ready;
    
    wire spi_cs;
    wire spi_sclk;
    wire spi_io0; // MOSI
    wire spi_io1; // MISO

    wire spi_io0_o, spi_io0_oe, spi_io0_i;
    wire spi_io1_o, spi_io1_oe, spi_io1_i;

    reg flash_active;
    reg [15:0] current_data;
    reg f_io1; // On ne pilote que MISO

    // Tri-state
    assign spi_io0 = spi_io0_oe ? spi_io0_o : 1'bz;
    // IO1 est piloté par le CPU (si besoin) OU par la Flash (MISO)
    assign spi_io1 = flash_active ? f_io1 : (spi_io1_oe ? spi_io1_o : 1'bz);

    assign spi_io0_i = spi_io0;
    assign spi_io1_i = spi_io1;

    // Module sous test (Ton CPU/Contrôleur)
    ProgramMemory_SPI uut (
        .clk(clk),
        .rst(rst),
        .address(address),
        .instruction(instruction),
        .ready(ready),
        .spi_cs(spi_cs),
        .spi_sclk(spi_sclk),
        .spi_io0_o(spi_io0_o),
        .spi_io0_oe(spi_io0_oe),
        .spi_io0_i(spi_io0_i),
        .spi_io1_o(spi_io1_o),
        .spi_io1_oe(spi_io1_oe),
        .spi_io1_i(spi_io1_i)
    );

    // Horloge
    always #25 clk = ~clk;

    // --- ROBOT FLASH (SIMULATEUR SINGLE SPI) ---
    always @(negedge spi_sclk or posedge spi_cs) begin
        if (spi_cs == 1) begin
            // Reset quand CS est inactif
            flash_active = 0;
            f_io1 = 1'b0;
        end else if (uut.state == 3'd3) begin  // STATE_READ (Vérifie que c'est bien 3 dans ton module)
            flash_active = 1;
            
            // Choix de la donnée (Memoire virtuelle)
            case (address)
                16'h1234: current_data = 16'hABCD;
                16'h1235: current_data = 16'h5566;
                16'h9000: current_data = 16'hDEAD;
                default:  current_data = 16'h0000;
            endcase

            // ENVOI SINGLE SPI (1 bit par coup d'horloge sur MISO)
            // bit_cnt va de 0 à 15
            f_io1 = current_data[15 - uut.bit_cnt]; 
            
        end else begin
            flash_active = 0;
            f_io1 = 1'b0;
        end
    end

    // Scénario de test
    initial begin
        $dumpfile("simulation.vcd");
        $dumpvars(0, ProgramMemory_SPI_tb);
        
        clk = 0; 
        rst = 1; 
        flash_active = 0;
        f_io1 = 0;
        address = 16'h1234;

        $display("--- DEMARRAGE SIMULATION SINGLE SPI ---");
        #100 rst = 0;
        
        // TEST 1
        $display("[%0t] TEST 1: Demande 0x1234 (attendu: 0xABCD)", $time);
        wait(ready == 1);
        #10;
        
        if (instruction == 16'hABCD)
            $display("  ✅ SUCCES ! Recu: %h", instruction);
        else
            $display("  ❌ ERREUR ! Attendu: ABCD, Recu: %h", instruction);

        // TEST 2
        #50; 
        $display("[%0t] TEST 2: Demande 0x1235 (attendu: 0x5566)", $time);
        address = 16'h1235;

        wait(ready == 0); 
        wait(ready == 1);
        #10;
        
        if (instruction == 16'h5566)
            $display("  ✅ SUCCES ! Recu: %h", instruction);
        else
            $display("  ❌ ERREUR ! Attendu: 5566, Recu: %h", instruction);

        $display("--- FIN DE SIMULATION ---");
        $finish;
    end

    initial begin
        #50000;
        $display("!!! TIMEOUT !!!");
        $finish;
    end

endmodule