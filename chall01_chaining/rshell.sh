#!/bin/bash
# Shell restreint - Challenge 01 : Command Chaining
# Bloque | et & mais oublie d'autres séparateurs...

echo "============================================"
echo " Challenge 01 — Shell restreint v1.0"
echo " Objectif : lire /flag.txt"
echo "============================================"
echo ""

while true; do
    read -rep "$ " cmd
    [[ -z "$cmd" ]] && continue
    [[ "$cmd" == "exit" ]] && break

    if echo "$cmd" | grep -qP '[|&]'; then
        echo "Caractère interdit !"
        continue
    fi

    eval "$cmd"
done
