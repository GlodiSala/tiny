import os
import subprocess

# 1. Création de l'arborescence pour GitHub Actions
workflows_dir = os.path.join(".github", "workflows")
os.makedirs(workflows_dir, exist_ok=True)

# 2. Création du fichier info.yaml (La carte d'identité de la puce)
# J'ai mis tes fichiers basés sur ton log git précédent
info_content = """--- 
project:
  title: "Microprocesseur 8-bit SPI"
  author: "Toi"
  discord: ""
  description: "Un CPU 8-bit personnalisé avec mémoire externe SPI et Audio"
  language: "Verilog"
  clock_hz: 50000000 # 50MHz

  # Comment ça marche (facultatif pour le test)
  how_it_works: "CPU custom architecture"
  how_to_test: "Testbench via SPI"
  external_hw: ""

  # LES FICHIERS SOURCES (C'est le plus important !)
  source_files:
    - "tt_um_CPU.v"          # Ton Top Module
    - "ALU.v"
    - "BranchUnit.v"
    - "ControlUnit.v"
    - "DataMemory.v"
    - "FlagRegister.v"
    - "ProgramCounter.v"
    - "ProgramMemory_SPI.v"  # Version SPI
    - "register_file.v"
    - "AudioPWM.v"           # Si tu l'as créé, sinon retire cette ligne
    - "defines.vh"

  # LE NOM DE TON MODULE PRINCIPAL
  # Attention : Doit correspondre exactement au nom 'module ...' dans tt_um_CPU.v
  top_module:  "tt_um_cpu"

# Configuration des Pins (Pour la documentation)
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

with open("info.yaml", "w") as f:
    f.write(info_content)
print("[OK] Fichier info.yaml créé.")

# 3. Création du Workflow GitHub (La recette de cuisine pour GDS)
workflow_content = """name: gds

on:
  push:
  workflow_dispatch:

jobs:
  gds:
    env:
      OPENLANE_TAG: 2024.01.27
      PDK_ROOT: /home/runner/pdk
      PDK: sky130A
    runs-on: ubuntu-latest
    steps:
      - name: checkout repo
        uses: actions/checkout@v4

      - name: GitHub Action for Tiny Tapeout
        uses: TinyTapeout/tt-gds-action@v2
        with:
          pdk_root: ${{ env.PDK_ROOT }}
          pdk_tag: sky130B
"""

with open(os.path.join(workflows_dir, "gds.yaml"), "w") as f:
    f.write(workflow_content)
print("[OK] Fichier .github/workflows/gds.yaml créé.")

# 4. Envoi automatique vers GitHub
def run_git(cmd):
    subprocess.run(cmd, shell=True, check=True)

print("-" * 30)
print("Envoi de la configuration vers GitHub...")
try:
    run_git("git add .")
    run_git('git commit -m "Setup: Ajout info.yaml et GDS workflow"')
    run_git("git push")
    print("\n✅ SUCCÈS TOTAL ! Va voir l'onglet 'Actions' sur GitHub maintenant.")
except Exception as e:
    print(f"Erreur git : {e}")
