#!/bin/bash
# Shell restreint - Challenge 04 : Variable Expansion
# Whitelist stricte : uniquement alphanumérique + tiret + underscore + point
# Mais system() appelle sh qui développe les variables APRÈS le filtre...

echo "============================================"
echo " Challenge 04 — Shell restreint v1.0"
echo " Objectif : lire /flag.txt"
echo "============================================"
echo ""

while true; do
    read -rep "$ " cmd
    [[ -z "$cmd" ]] && continue
    [[ "$cmd" == "exit" ]] && break

    if echo "$cmd" | grep -qP '[^a-zA-Z0-9\-_\.]'; then
        echo "Caractère non autorisé ! Uniquement : a-z A-Z 0-9 - _ ."
        continue
    fi

    if echo "$cmd" | grep -qiP '(flag|cat|root|passwd|shadow)'; then
        echo "Mot interdit !"
        continue
    fi

    # eval développe les variables d'environnement APRÈS le filtre
    eval "$cmd"
done
