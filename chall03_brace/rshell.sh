#!/bin/bash
# Shell restreint - Challenge 03 : Brace Expansion
# Filtre les espaces sous toutes leurs formes
# La brace expansion {cmd,arg} permet de passer des arguments sans espace

echo "============================================"
echo " Challenge 03 — Shell restreint v1.0"
echo " Objectif : lire /flag.txt"
echo "============================================"
echo ""

while true; do
    read -rep "$ " cmd
    [[ -z "$cmd" ]] && continue
    [[ "$cmd" == "exit" ]] && break

    if echo "$cmd" | grep -qP '[ \t]'; then
        echo "Caractère interdit : espace"
        continue
    fi

    if echo "$cmd" | grep -qP '\$\{?IFS\}?'; then
        echo "Mot-clé interdit : IFS"
        continue
    fi

    eval "$cmd"
done
