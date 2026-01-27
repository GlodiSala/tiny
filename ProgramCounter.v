module ProgramCounter (
    input  wire clk,
    input  wire rst,
    input  wire mem_ready,    
    input  wire branch_en,    // 1 = Saut demandé par le Control Unit
    input  wire [15:0] branch_addr,  
    output reg [15:0]  pc_current   
);

    always @(posedge clk) begin
        if (rst) begin
            pc_current <= 16'h0000;
        end else begin
            if (mem_ready) begin
                if (branch_en) begin
                    // Cas du saut (JUMP)
                    pc_current <= branch_addr;
                end else begin
                    pc_current <= pc_current + 1;
                end
            end
        end
    end

endmodule