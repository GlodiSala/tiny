module ProgramMemory_SPI_RAM (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] address,
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
    reg [7:0] cmd_byte;
    reg [15:0] addr_buf;
    reg [15:0] data_buf;
    reg [15:0] last_addr;

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            ready <= 0;
            spi_cs <= 1;
            spi_sck <= 0;
            spi_mosi <= 0;
            last_addr <= 16'hFFFF;
            instruction <= 16'h0000;
            bit_cnt <= 0;
            cmd_byte <= 8'h00;
            addr_buf <= 16'h0000;
            data_buf <= 16'h0000;
        end else begin
            case (state)
                IDLE: begin
                    ready <= 0;
                    spi_sck <= 0;
                    if (address != last_addr) begin
                        spi_cs <= 0;
                        cmd_byte <= 8'h03;
                        addr_buf <= address;
                        bit_cnt <= 0;
                        state <= CMD;
                    end else begin
                        spi_cs <= 1;
                        ready <= 1;
                    end
                end

                CMD: begin
                    spi_mosi <= cmd_byte[7];
                    spi_sck <= ~spi_sck;
                    
                    if (spi_sck) begin
                        cmd_byte <= {cmd_byte[6:0], 1'b0};
                        bit_cnt <= bit_cnt + 1;
                        
                        if (bit_cnt == 7) begin
                            bit_cnt <= 0;
                            state <= ADDR;
                        end
                    end
                end

                ADDR: begin
                    spi_mosi <= addr_buf[15];
                    spi_sck <= ~spi_sck;
                    
                    if (spi_sck) begin
                        addr_buf <= {addr_buf[14:0], 1'b0};
                        bit_cnt <= bit_cnt + 1;
                        
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
                        data_buf <= {data_buf[14:0], spi_miso};
                        bit_cnt <= bit_cnt + 1;
                        
                        if (bit_cnt == 15) begin
                            instruction <= {data_buf[14:0], spi_miso};
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
