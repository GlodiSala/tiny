module ProgramMemory_SPI (
    input  wire         clk,      
    input  wire         rst,      
    input  wire [15:0]  address,  
    output wire [15:0]  instruction, 
    output reg          ready,    
    
    output reg          spi_cs,   
    output reg          spi_sclk, 

    // MOSI (Sortie vers Mémoire)
    output wire         spi_io0_o,
    output wire         spi_io0_oe,
    input  wire         spi_io0_i, // Pas utilisé en Single Read

    // MISO (Entrée depuis Mémoire)
    output wire         spi_io1_o, // Pas utilisé en Single Read
    output wire         spi_io1_oe, 
    input  wire         spi_io1_i    
);

    // --- ÉTATS ---
    localparam STATE_IDLE  = 3'd0, 
               STATE_CMD   = 3'd1,
               STATE_ADDR  = 3'd2, 
               STATE_READ  = 3'd3, 
               STATE_READY = 3'd4;

    // --- REGISTRES ---
    reg [2:0]  state;
    reg [4:0]  bit_cnt;   // Suffisant pour compter jusqu'à 16
    reg [23:0] shift_reg; // Buffer d'envoi
    reg [15:0] instr_buffer; // Buffer de réception
    reg [15:0] last_address;
    reg        spi_phase;

    // --- LOGIQUE I/O (SINGLE SPI) ---
    // On pilote MOSI (IO0) uniquement pendant l'envoi Command + Address
    assign spi_io0_oe = (state == STATE_CMD || state == STATE_ADDR);
    assign spi_io0_o  = shift_reg[23]; // MSB first
    
    // On ne pilote jamais MISO (IO1), c'est l'entrée
    assign spi_io1_oe = 1'b0; 
    assign spi_io1_o  = 1'b0;

    assign instruction = instr_buffer;

    // --- GÉNÉRATION D'HORLOGE SPI (Mode 0) ---
    always @(posedge clk) begin
        if (rst || spi_cs) begin
            spi_sclk  <= 0;
            spi_phase <= 0;
        end else begin
            spi_phase <= ~spi_phase;        
            spi_sclk  <= spi_phase;
        end
    end

    // --- MACHINE À ÉTATS ---
    always @(posedge clk) begin
        if (rst) begin
            state <= STATE_IDLE;
            ready <= 0;
            spi_cs <= 1;
            last_address <= 16'hFFFF;
            instr_buffer <= 16'h0000;
        end else begin
            case (state)
                STATE_IDLE: begin
                    ready <= 0;
                    if (address != last_address) begin
                         // Démarrage transaction
                         if (spi_cs == 0) begin
                             spi_cs <= 1; // Reset CS si actif
                         end else begin
                             spi_cs <= 0; // Active CS (Low)
                             // CMD 0x03 (READ) + 16 bits Dummy pour aligner le shift
                             shift_reg <= {8'h03, 16'h0000}; 
                             state    <= STATE_CMD;
                             bit_cnt <= 0;
                        end
                    end
                end

                STATE_CMD: begin // Envoi Commande 8 bits
                    if (spi_phase) begin 
                        if (bit_cnt == 7) begin
                            bit_cnt <= 0;
                            shift_reg <= {8'h00, address}; // Charge l'adresse 16 bits
                            state <= STATE_ADDR;
                        end else begin
                            shift_reg <= shift_reg << 1;
                            bit_cnt   <= bit_cnt + 1;
                        end
                    end
                end

                STATE_ADDR: begin // Envoi Adresse 16 bits
                    if (spi_phase) begin 
                        if (bit_cnt == 15) begin
                            bit_cnt <= 0;
                            state <= STATE_READ; // Pas de Dummy Cycle ! Direct lecture.
                        end else begin
                            shift_reg <= shift_reg << 1;
                            bit_cnt   <= bit_cnt + 1;
                        end
                    end
                end

                STATE_READ: begin // Lecture 16 bits sur MISO
                    if (spi_phase) begin
                        // On échantillonne sur front montant (ou descendant selon mode, ici sample fin de cycle)
                        instr_buffer <= {instr_buffer[14:0], spi_io1_i}; 
                        
                        if (bit_cnt == 15) begin
                            state <= STATE_READY;
                        end else bit_cnt <= bit_cnt + 1;
                    end
                end

                STATE_READY: begin
                    ready <= 1;
                    last_address <= address;
                    spi_cs <= 1; // Fin de transaction
                    state <= STATE_IDLE;
                end
            default: next_state = IDLE;
            endcase
        end
    end
endmodule
