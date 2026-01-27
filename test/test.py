# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
from cocotb.types import LogicArray

# Programme de test (instructions 16-bit)
PROGRAM = {
    0x0000: 0x620A,  # LOADI R1, 10
    0x0001: 0x6414,  # LOADI R2, 20
    0x0002: 0x0650,  # ADD R3, R1, R2
    0x0003: 0x8600,  # STORE R3, [R0+0]
    0x0004: 0x7800,  # LOAD R4, [R0+0]
    0x0005: 0xF700,  # CMP R3, R4
    0x0006: 0xA002,  # BRZ +2
    0x0007: 0x6BFF,  # LOADI R5, 255 (skip si branch)
    0x0008: 0x6C64,  # LOADI R6, 100
    0x0009: 0x9FFF,  # JMP -1 (boucle)
}

async def spi_ram_simulator(dut):
    """Simule une RAM SPI qui répond aux lectures"""
    
    while True:
        # Attendre que CS soit actif (bas)
        while dut.uio_out.value[0] == 1:
            await RisingEdge(dut.clk)
        
        # Lire la commande + adresse (skip pour simplifier)
        for _ in range(8 + 16):  # 8 bits cmd + 16 bits addr
            await FallingEdge(dut.uio_out.value[3])  # SCK
        
        # Récupérer l'adresse du PC
        try:
            pc_addr = int(dut.user_project.pc_current.value)
        except:
            pc_addr = 0
        
        # Envoyer l'instruction correspondante
        instruction = PROGRAM.get(pc_addr, 0x0000)
        
        for bit_idx in range(16):
            # Bit MSB first
            miso_bit = (instruction >> (15 - bit_idx)) & 1
            dut.uio_in.value = LogicArray([0, 0, miso_bit, 0, 0, 0, 0, 0])
            await FallingEdge(dut.uio_out.value[3])  # SCK

@cocotb.test()
async def test_cpu_basic(dut):
    """Test basique du CPU avec SPI RAM simulé"""
    
    dut._log.info("Démarrage du test CPU")
    
    # Horloge 50 MHz (20ns période)
    clock = Clock(dut.clk, 20, units="ns")
    cocotb.start_soon(clock.start())
    
    # Simulateur SPI RAM en parallèle
    cocotb.start_soon(spi_ram_simulator(dut))
    
    # Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    
    dut._log.info("Reset désactivé, CPU démarre")
    
    # Attendre que le CPU exécute quelques instructions
    instr_count = 0
    for _ in range(5000):  # Timeout après 5000 cycles
        await RisingEdge(dut.clk)
        
        try:
            if dut.user_project.mem_ready.value == 1:
                pc = int(dut.user_project.pc_current.value)
                instr = int(dut.user_project.instruction.value)
                r1 = int(dut.user_project.regfile.register_tab[1].value)
                r2 = int(dut.user_project.regfile.register_tab[2].value)
                r3 = int(dut.user_project.regfile.register_tab[3].value)
                
                dut._log.info(f"PC={pc:04x} I={instr:04x} | R1={r1:02x} R2={r2:02x} R3={r3:02x}")
                
                instr_count += 1
                if instr_count >= 12:
                    break
        except:
            pass  # Ignorer les erreurs de lecture pendant la simulation
    
    # Vérifications finales
    await ClockCycles(dut.clk, 10)
    
    try:
        r1 = int(dut.user_project.regfile.register_tab[1].value)
        r2 = int(dut.user_project.regfile.register_tab[2].value)
        r3 = int(dut.user_project.regfile.register_tab[3].value)
        r4 = int(dut.user_project.regfile.register_tab[4].value)
        r6 = int(dut.user_project.regfile.register_tab[6].value)
        
        assert r1 == 10, f"R1 devrait être 10, obtenu {r1}"
        assert r2 == 20, f"R2 devrait être 20, obtenu {r2}"
        assert r3 == 30, f"R3 devrait être 30, obtenu {r3}"
        assert r4 == 30, f"R4 devrait être 30, obtenu {r4}"
        assert r6 == 100, f"R6 devrait être 100 (branch pris), obtenu {r6}"
        
        dut._log.info("✅ TOUS LES TESTS PASSENT !")
        
    except Exception as e:
        dut._log.error(f"❌ Test échoué : {e}")
        raise
