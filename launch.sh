#!/bin/bash
# Script de lancement des challenges Shell Escape CTF

CHALLENGES=(
    "chall01_chaining:chall01:Command Chaining"
    "chall02_blacklist:chall02:Blacklist Bypass"
    "chall03_brace:chall03:Brace Expansion"
    "chall04_ifs:chall04:IFS & Variable Slicing"
    "chall05_shifting:chall05:Character Shifting"
    "chall06_array:chall06:Array Interpolation"
)

print_menu() {
    echo ""
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║     Shell Escape CTF — HackUTT                      ║"
    echo "╠══════════════════════════════════════════════════════╣"
    echo "║                                                      ║"
    for i in "${!CHALLENGES[@]}"; do
        IFS=':' read -r dir tag name <<< "${CHALLENGES[$i]}"
        printf "║  [%d] %-48s ║\n" "$((i+1))" "$name"
    done
    echo "║                                                      ║"
    echo "║  [0] Quitter                                         ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo ""
}

launch_challenge() {
    local num=$1
    local idx=$((num-1))

    if [ $idx -lt 0 ] || [ $idx -ge ${#CHALLENGES[@]} ]; then
        echo "Numéro invalide."
        return 1
    fi

    IFS=':' read -r dir tag name <<< "${CHALLENGES[$idx]}"

    echo ""
    echo "[*] Lancement : $name"
    echo "[*] Répertoire : $dir"
    echo ""

    # Vérifier que le répertoire existe
    if [ ! -d "$dir" ]; then
        echo "Erreur : répertoire '$dir' introuvable."
        echo "Lancez ce script depuis le répertoire racine du CTF."
        return 1
    fi

    # Build si l'image n'existe pas
    if ! docker image inspect "$tag" &>/dev/null; then
        echo "[*] Construction de l'image Docker (première fois)..."
        docker build -t "$tag" "$dir/" || {
            echo "Erreur lors du build."
            return 1
        }
    else
        echo "[*] Image '$tag' déjà présente."
    fi

    echo "[*] Démarrage du container..."
    echo "[*] Tapez 'exit' pour revenir au menu."
    echo ""
    docker run -it --rm "$tag"
}

# Mode non-interactif : argument en ligne de commande
if [ $# -eq 1 ] && [[ "$1" =~ ^[1-6]$ ]]; then
    launch_challenge "$1"
    exit 0
fi

# Mode interactif
while true; do
    print_menu
    read -p "Choisissez un challenge (0-6) : " choice

    if [ "$choice" = "0" ]; then
        echo "Au revoir !"
        exit 0
    elif [[ "$choice" =~ ^[1-6]$ ]]; then
        launch_challenge "$choice"
    else
        echo "Choix invalide."
    fi
done
