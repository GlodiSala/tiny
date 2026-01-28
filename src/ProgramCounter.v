// ProgramCounter.v optimisé pour 1x1 Tile
module ProgramCounter (
    input  wire clk,
    input  wire rst,
    input  wire mem_ready,    
    input  wire [9:0] next_pc,     
    output reg  [9:0] pc_current,
    output reg ready_q       
);

    always @(posedge clk) begin
        if (rst) begin
            pc_current <= 10'd0;
            ready_q    <= 1'b0;
        end else begin
            // On mémorise l'état de mem_ready
            ready_q <= mem_ready;  //Stabilisé un cycle
            if (ready_q) begin
                pc_current <= next_pc; 
            end
        end
    end
    
endmodule