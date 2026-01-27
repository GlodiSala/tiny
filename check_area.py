import os
import subprocess

# 1. On réécrit le info.yaml STRICTEMENT avec tes fichiers existants
info_content = """--- 
project:
  title: "Microprocesseur 8-bit SPI"
  author: "GlodiSala"
  discord: ""
  description: "Un CPU 8-bit avec memoire externe SPI"
  language: "Verilog"
  clock_hz: 50000000 # 50MHz

  how_it_works: "CPU custom architecture"
  how_to_test: "Testbench via SPI"
  external_hw: ""

  # LA LISTE EXACTE DE TES FICHIERS (Sans Audio)
  source_files:
    - "src/tt_um_CPU.v"
    - "src/ALU.v"
    - "src/BranchUnit.v"
    - "src/ControlUnit.v"
    - "src/DataMemory.v"
    - "src/FlagRegister.v"
    - "src/ProgramCounter.v"
    - "src/ProgramMemory_SPI.v" 
    - "src/register_file.v"
    - "src/defines.vh"

  top_module:  "tt_um_cpu"

# Configuration des Pins standard
  inputs:
    - ui_in[0]
    - ui_in[1]
    - ui_in[2]
    - ui_in[3]
    - ui_in[4]
    - ui_in[5]
    - ui_in[6]
    - ui_in[7]
  outputs:
    - uo_out[0]
    - uo_out[1]
    - uo_out[2]
    - uo_out[3]
    - uo_out[4]
    - uo_out[5]
    - uo_out[6]
    - uo_out[7]
  bidirectional:
    - uio_out[0]
    - uio_out[1]
    - uio_out[2]
    - uio_out[3]
    - uio_out[4]
    - uio_out[5]
    - uio_out[6]
    - uio_out[7]
"""

# Écriture du fichier
with open("info.yaml", "w") as f:
    f.write(info_content)
print("[OK] info.yaml nettoyé (Version sans Audio).")

# 2. Envoi vers GitHub
def run_git(cmd):
    print(f"Exec: {cmd}")
    subprocess.run(cmd, shell=True, check=True)

print("-" * 30)
try:
    run_git("git add info.yaml")
    # On commit. Si rien n'a changé, git peut raler, donc on ignore l'erreur du commit
    subprocess.run('git commit -m "Fix: Config propre sans Audio"', shell=True)
    
    print("--> PUSH vers GitHub...")
    run_git("git push")
    print("\n✅ C'EST PARTI ! Va voir GitHub Actions.")
except Exception as e:
    print(f"Erreur : {e}")