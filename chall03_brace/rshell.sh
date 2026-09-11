#!/bin/bash
# Shell restreint - Challenge 03 : Brace Expansion
# Bloque la plupart des caractères spéciaux, mais pas les accolades...

echo "============================================"
echo " Challenge 03 — Shell restreint v1.0"
echo " Objectif : lire /flag.txt"
echo "============================================"
echo ""

while true; do
    read -rep "$ " cmd
    [[ -z "$cmd" ]] && continue
    [[ "$cmd" == "exit" ]] && break

    if echo "$cmd" | grep -qP "[;|&\`\$()'\"\\\\ \t]"; then
        echo "Caractère interdit !"
        continue
    fi

    if echo "$cmd" | grep -qP "(flag|root|etc)"; then
        echo "Mot-clé interdit !"
        continue
    fi

    eval "$cmd"
done
