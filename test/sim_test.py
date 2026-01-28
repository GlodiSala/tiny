import os
from pathlib import Path
from cocotb_tools.runner import get_runner

def test_cpu_runner():
    # Définition des chemins
    proj_path = Path(os.getcwd()).parent
    src_path = proj_path / "src"
    test_path = proj_path / "test"

    # Liste des fichiers Verilog (ordre important pour la compilation)
    sources = [
        src_path / "ALU.v",
        src_path / "BranchUnit.v",
        src_path / "ControlUnit.v",
        src_path / "DataMemory.v",
        src_path / "FlagRegister.v",
        src_path / "ProgramCounter.v",
        src_path / "ProgramMemory_SPI.v",
        src_path / "register_file.v",
        src_path / "tt_um_cpu.v",
        test_path / "spi_flash_sim.v",  # ✅ AJOUTER CETTE LIGNE
        test_path / "tb.v",
    ]

    # Configuration du simulateur
    runner = get_runner("icarus")
    
    runner.build(
        sources=sources,
        hdl_toplevel="tb",
        includes=[src_path],
        build_dir=test_path / "sim_build",
    )

    runner.test(
        hdl_toplevel="tb",
        test_module="test",
    )

if __name__ == "__main__":
    test_cpu_runner()