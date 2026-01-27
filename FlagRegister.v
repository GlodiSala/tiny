

module FlagRegister(
    input clk,
    input rst,
    input write,
    input[3:0] flags_alu,
    output reg [3:0] stored_flags
);
always @(posedge clk)
begin 
    if (rst) begin
        stored_flags <= 0;
    end
    else if(write) begin
        stored_flags <= flags_alu;
    end
end
    
endmodule