module DataMemory (
    input wire clk,
    input wire mem_read,   // Vient du ControlUnit
    input wire mem_write,  // Vient du ControlUnit
    input wire [7:0] addr, // Vient de l'ALU (Résultat du calcul Base + Offset)
    input wire [7:0] wdata,// Vient du RegisterFile (Registre R2 par exemple)
    output reg [7:0] rdata // Va vers le RegisterFile (Write Data)
);

    // 256 octets de RAM (Adressable par 8 bits)
    reg [7:0] ram [0:15];

    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            ram[i] = 8'h00;
        end
    end

    always @(posedge clk) begin
        if (mem_write) begin
            ram[addr[3:0]] <= wdata;
        end
    end

    // Lecture asynchrone ou synchrone ? 
    always @(*) begin
        if (mem_read) 
            rdata = ram[addr[3:0]];
        else 
            rdata = 8'b0;
    end

endmodule
