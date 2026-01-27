`timescale 1ns / 1ps
module SimpleCPU_tb();

    reg clk;
    reg rst;
    wire [15:0] pc_out;
    wire [15:0] current_instruction;
    wire [7:0] alu_result_out;

    CPU cpu_inst(
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out),
        .current_instruction(current_instruction),
        .alu_result_out(alu_result_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("=== Loading Program ===");
        
        cpu_inst.prog_mem.memory[0] = {4'b0110, 3'd1, 9'd10};
        cpu_inst.prog_mem.memory[1] = {4'b0110, 3'd2, 9'd5};
        cpu_inst.prog_mem.memory[2] = {4'b0000, 3'd3, 3'd1, 3'd2, 3'b000};
        cpu_inst.prog_mem.memory[3] = {4'b0010, 3'd4, 3'd1, 3'd2, 3'b000};
        cpu_inst.prog_mem.memory[4] = {4'b1000, 3'd3, 3'd0, 6'd16};
        cpu_inst.prog_mem.memory[5] = {4'b0111, 3'd7, 3'd0, 6'd16};
        cpu_inst.prog_mem.memory[6] = {4'b1111, 3'd1, 3'd2, 6'b000000};
        cpu_inst.prog_mem.memory[7] = {4'b1011, 12'd2};
        cpu_inst.prog_mem.memory[8] = {4'b0110, 3'd0, 9'd255};
        cpu_inst.prog_mem.memory[9] = {4'b0000, 3'd0, 3'd0, 3'd0, 3'b000};
        
        $display("Program loaded !");
    end

    task display_cpu_state();
    begin
        $display("--- CPU State ---");
        $display("PC: %d, Instruction: %h", pc_out, current_instruction);
        $display("ALU Result: %d", alu_result_out);
        $display("R0=%d, R1=%d, R2=%d, R3=%d", 
                cpu_inst.reg_file.register_tab[0],
                cpu_inst.reg_file.register_tab[1],
                cpu_inst.reg_file.register_tab[2], 
                cpu_inst.reg_file.register_tab[3]);
        $display("R4=%d, R5=%d, R6=%d, R7=%d", 
                cpu_inst.reg_file.register_tab[4],
                cpu_inst.reg_file.register_tab[5],
                cpu_inst.reg_file.register_tab[6],
                cpu_inst.reg_file.register_tab[7]);
        $display("Memory[16] = %d", cpu_inst.data_mem.mem[16]);
        $display("mem_read=%b, mem_write=%b, addr=%d", 
         cpu_inst.mem_read, cpu_inst.mem_write, cpu_inst.alu_result);
        $display("");
    end
    endtask

    initial begin
        $display("=== Test CPU ===");
        
        rst = 1;
        #20 rst = 0;
        
        $display("=== Début exécution ===");
        
        repeat(15) begin
            #10;
            display_cpu_state();
            
            // REMPLACEMENT : Au lieu de break, utiliser $finish
            if (pc_out > 9) begin
                $display("Fin du programme");
                $finish;  // Termine la simulation
            end
        end
        
        $display("=== Vérifications ===");
        
        if (cpu_inst.reg_file.register_tab[1] == 10)
            $display("✓ R1 = 10");
        else
            $display("✗ R1 = %d", cpu_inst.reg_file.register_tab[1]);
            
        if (cpu_inst.reg_file.register_tab[3] == 15)
            $display("✓ R3 = 15 (ADD)");
        else
            $display("✗ R3 = %d", cpu_inst.reg_file.register_tab[3]);
            
        $display("=== Test terminé ===");
        $finish;
    end

endmodule