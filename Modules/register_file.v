`timescale 1ns / 1ps
module RegisterFile (
input clk,
input rst,
input write,   // Signal pour autoriser ecriture
input [2:0] addr1_wr, // ecriture
input [7:0] data_wr,
input [2:0]addr1_r, // lecture
input [2:0]addr2_r, 
output [7:0]out1_r,
output [7:0]out2_r
);
reg [7:0] register_tab [0:7]; //  8 x 8-bit memory
integer  i; // declarer avant le always

assign out1_r = register_tab[addr1_r];
assign out2_r = register_tab[addr2_r];

always @ (posedge clk or posedge rst)
begin
    if (rst) begin
        for (i=0; i<=7; i=i+1) begin
            register_tab[i]<=0;
        end
    end else if (write && addr1_wr !=0) begin
    register_tab[addr1_wr] <=data_wr;
    end
end
endmodule