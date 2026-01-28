module ProgramMemory_SPI_RAM (
    input  wire        clk,
    input  wire        rst,
    input  wire [9:0]  address,      // PC réduit à 10 bits
    output reg  [15:0] instruction,
    output reg         ready,
    
    output reg         spi_cs,
    output reg         spi_sck,
    output reg         spi_mosi,
    input  wire        spi_miso
);

    localparam IDLE  = 2'd0,
               CMD   = 2'd1,
               ADDR  = 2'd2,
               DATA  = 2'd3;

    reg [1:0] state;
    reg [4:0] bit_cnt;
    reg [9:0] addr_shifter; // Réduit à 10 bits
    reg [9:0] last_addr;    // Réduit à 10 bits

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            ready <= 0;
            spi_cs <= 1;
            spi_sck <= 0;
            spi_mosi <= 0;
            last_addr <= 10'h3FF; // Adresse impossible au boot
            instruction <= 16'h0000;
            bit_cnt <= 0;
        end else begin
            case (state)
                IDLE: begin
                    ready <= 0;
                    spi_sck <= 0;
                    if (address != last_addr) begin
                        spi_cs <= 0;
                        addr_shifter <= address;
                        bit_cnt <= 0;
                        state <= CMD;
                    end
                end

                CMD: begin
                    // Commande 0x03 (00000011). 
                    // On envoie 0 pour les 6 premiers bits, 1 pour les 2 derniers.
                    spi_mosi <= (bit_cnt >= 6); 
                    spi_sck <= ~spi_sck;
                    if (spi_sck) begin
                        bit_cnt <= bit_cnt + 5'd1;
                        if (bit_cnt == 7) begin
                            bit_cnt <= 0;
                            state <= ADDR;
                        end
                    end
                end

                ADDR: begin
                    // L'adresse SPI fait 16 bits. PC = 10 bits.
                    // On envoie 6 zéros, puis les 10 bits du PC.
                    if (bit_cnt < 6) 
                        spi_mosi <= 0;
                    else 
                        spi_mosi <= addr_shifter[9];
                    
                    spi_sck <= ~spi_sck;
                    if (spi_sck) begin
                        if (bit_cnt >= 6)
                            addr_shifter <= {addr_shifter[8:0], 1'b0};
                        
                        bit_cnt <= bit_cnt + 5'd1;
                        if (bit_cnt == 15) begin
                            bit_cnt <= 0;
                            state <= DATA;
                        end
                    end
                end

                DATA: begin
                    spi_mosi <= 0;
                    spi_sck <= ~spi_sck;
                    if (spi_sck) begin
                        // On shift directement dans le registre de sortie
                        instruction <= {instruction[14:0], spi_miso};
                        bit_cnt <= bit_cnt + 5'd1;
                        if (bit_cnt == 15) begin
                            last_addr <= address;
                            ready <= 1;
                            spi_cs <= 1;
                            state <= IDLE;
                        end
                    end
                end
            endcase
        end
    end
endmodule