#!/bin/bash
# Shell restreint - Challenge 04 : Variable Expansion
# Bloque les espaces et slashes littéraux
# Mais $, {, } sont autorisés... les variables d'environnement sont tes amies

echo "============================================"
echo " Challenge 04 — Shell restreint v1.0"
echo " Objectif : lire /flag.txt"
echo "============================================"
echo ""

while true; do
    read -rep "$ " cmd
    [[ -z "$cmd" ]] && continue
    [[ "$cmd" == "exit" ]] && break

    if printf '%s' "$cmd" | grep -qP '[ \t/]'; then
        echo "Caractère interdit : espace ou slash"
        continue
    fi

    eval "$cmd"
done
