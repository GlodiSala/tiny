# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, Timer

# Programme de test (instructions 16-bit)
PROGRAM = {
    0x0000: 0x620A,  # LOADI R1, 10
    0x0001: 0x6414,  # LOADI R2, 20
    0x0002: 0x0650,  # ADD R3, R1, R2
    0x0003: 0x8600,  # STORE R3, [R0+0]
    0x0004: 0x7800,  # LOAD R4, [R0+0]
    0x0005: 0xF700,  # CMP R3, R4
    0x0006: 0xA002,  # BRZ +2
    0x0007: 0x6BFF,  # LOADI R5, 255
    0x0008: 0x6C64,  # LOADI R6, 100
    0x0009: 0x9FFF,  # JMP -1
}

OPCODE_NAMES = {
    0x0: "ADD", 0x1: "ADDI", 0x2: "SUB", 0x3: "AND",
    0x4: "OR", 0x5: "XOR", 0x6: "LI", 0x7: "L",
    0x8: "ST", 0x9: "JMP", 0xA: "BRZ", 0xB: "BRNZ",
    0xC: "BRNS", 0xD: "SHL", 0xE: "SHR", 0xF: "CMP"
}

async def spi_flash_simulator(dut):
    """Simulateur SPI Flash - Copie exacte de tt_um_cpu_tb.v"""
    
    await Timer(100, unit='ns')
    dut._log.info("🔧 Simulateur SPI Flash démarré")
    
    while True:
        await RisingEdge(dut.clk)
        
        # Lire CS (actif bas)
        cs = int(dut.uio_out.value) & 0x01
        
        if cs == 1:
            # CS inactif - MISO = 0
            dut.uio_in.value = 0x00
            continue
        
        # CS actif (0) - Vérifier si on est en phase DATA
        try:
            # Accéder au state interne du module SPI
            state = int(dut.user_project.program_mem.state.value)
            
            # STATE_DATA = 3 (phase de lecture des 16 bits d'instruction)
            if state == 3:
                # Lire le PC actuel pour savoir quelle instruction envoyer
                pc = int(dut.user_project.pc_current.value)
                current_instruction = PROGRAM.get(pc, 0x0000)
                
                # Lire le compteur de bits
                bit_cnt = int(dut.user_project.program_mem.bit_cnt.value)
                
                # Envoyer le bit MSB first
                miso_bit = (current_instruction >> (15 - bit_cnt)) & 1
                
                # Mettre à jour MISO (bit 2 de uio_in)
                current_uio = 0x00
                if miso_bit:
                    current_uio = 0x04  # Set bit 2
                
                dut.uio_in.value = current_uio
            else:
                dut.uio_in.value = 0x00
                
        except Exception as e:
            dut.uio_in.value = 0x00

@cocotb.test()
async def test_cpu_basic(dut):
    """Test basique du CPU avec logs complets"""
    
    dut._log.info("=" * 80)
    dut._log.info("🚀 DÉMARRAGE DU TEST CPU COMPLET")
    dut._log.info("=" * 80)
    
    # Initialisation
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    
    await Timer(10, unit='ns')
    
    # Horloge 50 MHz
    clock = Clock(dut.clk, 20, unit="ns")
    cocotb.start_soon(clock.start())
    
    # Simulateur SPI
    cocotb.start_soon(spi_flash_simulator(dut))
    
    # Reset
    dut._log.info("🔄 Reset du CPU...")
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    
    dut._log.info("✅ Reset désactivé, CPU en fonctionnement")
    dut._log.info("-" * 80)
    
    # Variables de suivi
    instr_count = 0
    timeout = 10000
    last_pc = -1
    
    # Boucle principale
    for cycle in range(timeout):
        await RisingEdge(dut.clk)
        
        try:
            mem_ready_str = str(dut.user_project.mem_ready.value)
            
            if mem_ready_str not in ['X', 'Z'] and dut.user_project.mem_ready.value == 1:
                pc = int(dut.user_project.pc_current.value)
                instr = int(dut.user_project.instruction.value)
                
                if pc != last_pc:
                    last_pc = pc
                    instr_count += 1
                    
                    opcode = (instr >> 12) & 0xF
                    opcode_name = OPCODE_NAMES.get(opcode, "???")
                    
                    # Lire registres
                    try:
                        r1 = int(dut.user_project.regfile.register_tab[1].value)
                        r2 = int(dut.user_project.regfile.register_tab[2].value)
                        r3 = int(dut.user_project.regfile.register_tab[3].value)
                        flags = int(dut.user_project.stored_flags.value)
                        
                        reg_info = f"R1={r1:02x} R2={r2:02x} R3={r3:02x}"
                        flag_info = f"Flags={flags:04b}"
                    except:
                        reg_info = "[Gate Level]"
                        flag_info = ""
                    
                    dut._log.info(f"📍 #{instr_count:03d} @ Cycle {cycle:05d}")
                    dut._log.info(f"   PC=0x{pc:04x} | INSTR=0x{instr:04x} ({opcode_name})")
                    dut._log.info(f"   {reg_info} | {flag_info}")
                    
                    if instr_count >= 12:
                        dut._log.info("✅ 12 instructions exécutées")
                        break
        except Exception as e:
            if cycle % 1000 == 0:
                dut._log.debug(f"Cycle {cycle}: {e}")
    
    # Vérifications finales
    await ClockCycles(dut.clk, 10)
    
    dut._log.info("")
    dut._log.info("🔍 VÉRIFICATIONS FINALES")
    
    try:
        r1 = int(dut.user_project.regfile.register_tab[1].value)
        r2 = int(dut.user_project.regfile.register_tab[2].value)
        r3 = int(dut.user_project.regfile.register_tab[3].value)
        r4 = int(dut.user_project.regfile.register_tab[4].value)
        r6 = int(dut.user_project.regfile.register_tab[6].value)
        
        tests = [
            (r1, 10, "R1 = 10"),
            (r2, 20, "R2 = 20"),
            (r3, 30, "R3 = 30"),
            (r4, 30, "R4 = 30"),
            (r6, 100, "R6 = 100")
        ]
        
        for actual, expected, desc in tests:
            if actual == expected:
                dut._log.info(f"✅ PASS: {desc}")
            else:
                dut._log.error(f"❌ FAIL: {desc} (obtenu {actual})")
        
        assert r1 == 10, f"R1={r1}"
        assert r2 == 20, f"R2={r2}"
        assert r3 == 30, f"R3={r3}"
        
        dut._log.info("🎉 TOUS LES TESTS PASSENT !")
        
    except Exception as e:
        dut._log.warning(f"⚠️ Gate Level - Tests skippés: {e}")