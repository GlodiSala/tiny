import subprocess
import os
import sys

# ==========================================
# CONFIGURATION
# ==========================================
# L'URL exacte de ton dépôt GitHub
REPO_URL = "https://github.com/GlodiSala/tiny.git"

# Message du commit
COMMIT_MESSAGE = "Initial Upload: CPU Single SPI + Audio"

# Nom de la branche (TinyTapeout utilise 'main')
BRANCH = "main"
# ==========================================

def run_git_command(command, ignore_error=False):
    """Exécute une commande git et affiche le résultat."""
    print(f"Executing: {command}")
    try:
        result = subprocess.run(
            command,
            check=True,
            shell=True,
            text=True,
            capture_output=True
        )
        print(f"[SUCCÈS] {result.stdout.strip()}")
        return True
    except subprocess.CalledProcessError as e:
        if not ignore_error:
            print(f"[ERREUR] La commande a échoué : {e.stderr}")
        else:
            print(f"[INFO] Pas grave, on continue : {e.stderr.strip()}")
        return False

def full_setup_and_upload():
    print("="*50)
    print("   AUTOMATISATION GITHUB - SETUP & UPLOAD")
    print("="*50)

    # 1. Initialiser git si le dossier .git n'existe pas
    if not os.path.exists(".git"):
        print("--> Initialisation du dépôt...")
        run_git_command("git init")
    else:
        print("--> Dépôt git déjà détecté.")

    # 2. Renommer la branche actuelle en 'main'
    run_git_command(f"git branch -M {BRANCH}")

    # 3. Configurer l'URL distante (Remote)
    # On supprime l'ancienne origine pour être sûr de mettre la bonne
    run_git_command("git remote remove origin", ignore_error=True)
    
    print(f"--> Configuration de l'URL : {REPO_URL}")
    if not run_git_command(f"git remote add origin {REPO_URL}"):
        print("Impossible d'ajouter l'origine. Vérifie l'URL.")
        return

    # 4. TENTATIVE DE PULL (Synchronisation)
    # C'est ici que tu avais l'erreur. On va essayer, mais si le remote est vide,
    # on ignore l'erreur et on passera directement au push.
    print("--> Tentative de récupération des fichiers distants (Template)...")
    success_pull = run_git_command(f"git pull origin {BRANCH} --allow-unrelated-histories", ignore_error=True)
    
    if not success_pull:
        print("--> Le dépôt distant semble vide ou inaccessible. Ce n'est pas grave, on va le remplir.")

    # 5. Ajouter les fichiers locaux
    print("--> Ajout des fichiers locaux...")
    run_git_command("git add .")

    # 6. Créer le commit
    print(f"--> Création du commit : {COMMIT_MESSAGE}")
    # On ignore l'erreur ici car si rien n'a changé, git commit renvoie une erreur, mais ce n'est pas grave
    run_git_command(f'git commit -m "{COMMIT_MESSAGE}"', ignore_error=True)

    # 7. ENVOI FINAL (PUSH)
    print("--> ENVOI VERS GITHUB (PUSH)...")
    print("Une fenêtre de connexion GitHub peut s'ouvrir...")
    
    if run_git_command(f"git push -u origin {BRANCH}"):
        print("\n" + "="*50)
        print("✅ VICTOIRE ! Tes fichiers sont sur GitHub.")
        print("="*50)
    else:
        print("\n❌ ECHEC de l'envoi.")
        print("Vérifie :")
        print("1. Ta connexion internet.")
        print("2. Que l'URL du dépôt est correcte.")
        print("3. Que tu es bien connecté à GitHub.")

if __name__ == "__main__":
    full_setup_and_upload()