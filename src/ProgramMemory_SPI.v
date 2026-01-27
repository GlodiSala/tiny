module ProgramMemory_SPI (
    input  wire         clk,      
    input  wire         rst,      
    input  wire [15:0]  address,  
    output wire [15:0]  instruction, 
    output reg          ready,    
    
    output reg          spi_cs,   
    output reg          spi_sclk, 

    // MOSI (Sortie/Entrée bidirectionnelle)
    output wire         spi_io0_o,
    output wire         spi_io0_oe,
    input  wire         spi_io0_i,

    // MISO (Entrée uniquement) ✅ Pas de sortie !
    input  wire         spi_io1_i    
);

    // ========================================================================
    // SYNCHRONIZER POUR MISO
    // ========================================================================
    reg spi_io1_sync1, spi_io1_sync2;
    
    always @(posedge clk) begin
        if (rst) begin
            spi_io1_sync1 <= 1'b0;
            spi_io1_sync2 <= 1'b0;
        end else begin
            spi_io1_sync1 <= spi_io1_i;
            spi_io1_sync2 <= spi_io1_sync1;
        end
    end
    
    wire spi_io1_safe = spi_io1_sync2;

    // ========================================================================
    // ÉTATS
    // ========================================================================
    localparam STATE_IDLE  = 3'd0, 
               STATE_CMD   = 3'd1,
               STATE_ADDR  = 3'd2, 
               STATE_READ  = 3'd3, 
               STATE_READY = 3'd4;

    // REGISTRES
    reg [2:0]  state;
    reg [4:0]  bit_cnt;
    reg [23:0] shift_reg;
    reg [15:0] instr_buffer;
    reg [15:0] last_address;
    reg        spi_phase;

    // LOGIQUE I/O
    assign spi_io0_oe = (state == STATE_CMD || state == STATE_ADDR);
    assign spi_io0_o  = shift_reg[23];
    assign instruction = instr_buffer;

    // Suppression warning
    wire _unused_spi = &{spi_io0_i, 1'b0};

    // GÉNÉRATION HORLOGE SPI
    always @(posedge clk) begin
        if (rst || spi_cs) begin
            spi_sclk  <= 0;
            spi_phase <= 0;
        end else begin
            spi_phase <= ~spi_phase;        
            spi_sclk  <= spi_phase;
        end
    end

    // ========================================================================
    // MACHINE À ÉTATS
    // ========================================================================
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
                        if (spi_cs == 0) begin
                            spi_cs <= 1;
                        end else begin
                            spi_cs <= 0;
                            shift_reg <= {8'h03, 16'h0000}; 
                            state <= STATE_CMD;
                            bit_cnt <= 0;
                        end
                    end
                end

                STATE_CMD: begin
                    if (spi_phase) begin 
                        if (bit_cnt == 7) begin
                            bit_cnt <= 0;
                            shift_reg <= {8'h00, address};
                            state <= STATE_ADDR;
                        end else begin
                            shift_reg <= shift_reg << 1;
                            bit_cnt <= bit_cnt + 1;
                        end
                    end
                end

                STATE_ADDR: begin
                    if (spi_phase) begin 
                        if (bit_cnt == 15) begin
                            bit_cnt <= 0;
                            state <= STATE_READ;
                        end else begin
                            shift_reg <= shift_reg << 1;
                            bit_cnt <= bit_cnt + 1;
                        end
                    end
                end

                STATE_READ: begin
                    if (spi_phase) begin
                        instr_buffer <= {instr_buffer[14:0], spi_io1_safe}; 
                        
                        if (bit_cnt == 15) begin
                            state <= STATE_READY;
                        end else begin
                            bit_cnt <= bit_cnt + 1;
                        end
                    end
                end

                STATE_READY: begin
                    ready <= 1;
                    last_address <= address;
                    spi_cs <= 1;
                    state <= STATE_IDLE;
                end

                default: begin
                    state <= STATE_IDLE;
                end
            endcase
        end
    end
endmodule
