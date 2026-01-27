/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_CPU_wrapper (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Output enable
    input  wire       ena,      // goes high when design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset (active low)
);

    // Internal signals from CPU
    wire [15:0] pc_out;
    wire [15:0] current_instruction;
    wire [7:0]  alu_result_out;

    // Instantiate your CPU core
    tt_um_CPU cpu_core (
        .clk(clk),
        .rst(~rst_n),   // active-high reset inside CPU
        .pc_out(pc_out),
        .current_instruction(current_instruction),
        .alu_result_out(alu_result_out)
    );

    // ---------------------------------------------------
    // Multiplexing logic
    // ui_in[1:0] chooses what appears on uio_out
    // 00 = PC[7:0]
    // 01 = PC[15:8]
    // 10 = Instruction[7:0]
    // 11 = Instruction[15:8]
    // ---------------------------------------------------
    reg [7:0] mux_out;
    always @(*) begin
        case (ui_in[1:0])
            2'b00: mux_out = pc_out[7:0];
            2'b01: mux_out = pc_out[15:8];
            2'b10: mux_out = current_instruction[7:0];
            2'b11: mux_out = current_instruction[15:8];
            default: mux_out = 8'h00;
        endcase
    end

    // ---------------------------------------------------
    // Output mapping
    // ---------------------------------------------------
    assign uo_out  = alu_result_out; // ALU result on dedicated outputs
    assign uio_out = mux_out;        // Selected data on IO pins
    assign uio_oe  = 8'hFF;          // Drive all IOs

endmodule

