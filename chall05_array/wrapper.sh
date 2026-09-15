#!/bin/bash
# Challenge 06 - Array Interpolation

declare -A scores
scores["alice"]=100
scores["bob"]=85
scores["charlie"]=72

if [ $# -ne 1 ]; then
    echo "Usage: $0 <username>"
    echo "Exemple: $0 alice"
    exit 1
fi

if [ ! -v "scores[$1]" ]; then
    echo "Utilisateur '$1' non trouvé."
    exit 1
fi

echo "Utilisateur : $1 — Score : ${scores[$1]}"
