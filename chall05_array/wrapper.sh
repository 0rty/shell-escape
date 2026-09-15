#!/bin/bash
# Challenge 06 - Array Interpolation / Quoted Injection
#
# Ce script calcule un "score" basé sur le nom d'utilisateur fourni.
# Il utilise un tableau associatif bash pour stocker les scores.
# L'entrée utilisateur est "sécurisée" entre guillemets doubles...
# mais les guillemets doubles ne protègent pas contre TOUT.

PASS="$(cat /flag.txt 2>/dev/null || echo 'HackUTT{4rr4y_1nj3ct10n_w0w}')"

declare -A scores
scores["alice"]=100
scores["bob"]=85
scores["charlie"]=72

usage() {
    echo "Usage: $0 <username>"
    echo "Exemple: $0 alice"
}

if [ $# -ne 1 ]; then
    usage
    exit 1
fi

USERNAME="$1"

# Validation basique : uniquement alphanumérique
if [[ "$USERNAME" =~ [^a-zA-Z0-9] ]]; then
    echo "Nom d'utilisateur invalide : uniquement alphanumérique autorisé."
    exit 1
fi

# Récupération du score via le tableau associatif
# Notez l'utilisation des guillemets doubles — "sécurisé" ?
SCORE="${scores["$USERNAME"]}"

if [ -z "$SCORE" ]; then
    echo "Utilisateur '$USERNAME' non trouvé."
    echo "Score : 0"
else
    echo "Utilisateur : $USERNAME"
    echo "Score : $SCORE"
fi
