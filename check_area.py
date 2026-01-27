import os
import shutil
import subprocess

# 1. Création du dossier src
if not os.path.exists("src"):
    os.makedirs("src")
    print("[OK] Dossier 'src' créé.")

# 2. Liste des fichiers à déplacer
files_to_move = [
    "tt_um_CPU.v",
    "ALU.v",
    "BranchUnit.v",
    "ControlUnit.v",
    "DataMemory.v",
    "FlagRegister.v",
    "ProgramCounter.v",
    "ProgramMemory_SPI.v",
    "register_file.v",
    "AudioPWM.v",
    "defines.vh"
]

print("-" * 30)
print("Déplacement des fichiers vers src/...")
for file in files_to_move:
    if os.path.exists(file):
        try:
            shutil.move(file, os.path.join("src", file))
            print(f" -> {file} déplacé.")
        except Exception as e:
            print(f" -> Erreur déplacement {file}: {e}")
    elif os.path.exists(os.path.join("src", file)):
        print(f" -> {file} est déjà dans src.")
    else:
        print(f" [INFO] Fichier {file} introuvable (peut-être pas encore créé), ignoré.")

# 3. Mise à jour du info.yaml avec les nouveaux chemins
# On réécrit le fichier proprement
new_info_content = """--- 
project:
  title: "Microprocesseur 8-bit SPI"
  author: "GlodiSala"
  discord: ""
  description: "Un CPU 8-bit personnalisé avec mémoire externe SPI et Audio"
  language: "Verilog"
  clock_hz: 50000000 # 50MHz

  how_it_works: "CPU custom architecture"
  how_to_test: "Testbench via SPI"
  external_hw: ""

  # FICHIERS DANS LE DOSSIER SRC
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
    - "src/AudioPWM.v"
    - "src/defines.vh"

  top_module:  "tt_um_cpu"

# Pins
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
    f.write(new_info_content)
print("[OK] info.yaml mis à jour avec les chemins 'src/'.")

# 4. Git Push
def run_git(cmd):
    subprocess.run(cmd, shell=True, check=True)

print("-" * 30)
print("Envoi vers GitHub...")
try:
    run_git("git add .")
    # On commit les suppressions (fichiers déplacés) et les ajouts
    run_git('git add -u') 
    run_git('git commit -m "Refactor: Déplacement des sources dans src/"')
    run_git("git push")
    print("\n✅ RANGEMENT TERMINÉ ! Retourne voir GitHub Actions.")
except Exception as e:
    print(f"Erreur git : {e}")