module RegisterFile (
    input  wire       clk,
    input  wire       rst,
    input  wire       write_en,   
    input  wire       enable,     // (sera connecté à mem_ready)

    input  wire [2:0] addr_wr,    // Adresse écriture
    input  wire [7:0] data_wr,    // Donnée écriture
    
    input  wire [2:0] addr1_r,    // Adresse lecture 1
    input  wire [2:0] addr2_r,    // Adresse lecture 2
    
    output wire [7:0] out1_r,     // Sortie 1
    output wire [7:0] out2_r      // Sortie 2
);

    reg [7:0] register_tab [0:7]; // 8 registres de 8 bits
    integer i;

    // Lecture asynchrone (R0 est toujours 0, architecture standard RISC)
    assign out1_r = enable ? ((addr1_r == 3'b000) ? 8'b0 : register_tab[addr1_r]) : 8'b0;
    assign out2_r = enable ? ((addr2_r == 3'b000) ? 8'b0 : register_tab[addr2_r]) : 8'b0;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1) begin
                register_tab[i] <= 8'b0;
            end
        end else if (write_en && enable && (addr_wr != 3'b000)) begin
            // On écrit seulement si WriteEnable est actif ET qu'on n'essaie pas d'écrire dans R0
            register_tab[addr_wr] <= data_wr;
        end
    end

endmodule