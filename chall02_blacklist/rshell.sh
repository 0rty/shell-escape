#!/bin/bash
# Shell restreint - Challenge 02 : Blacklist Bypass
# Bloque les commandes par leurs noms exacts

BLACKLIST=("cat" "head" "tail" "more" "less" "tac" "nl" "od" "xxd"
           "strings" "grep" "awk" "sed" "cut" "sort"
           "whoami" "id" "ls" "find" "which")

echo "============================================"
echo " Challenge 02 — Shell restreint v1.0"
echo " Objectif : lire /flag.txt"
echo "============================================"
echo ""

while true; do
    read -rep "$ " cmd
    [[ -z "$cmd" ]] && continue
    [[ "$cmd" == "exit" ]] && break

    blocked=0
    for word in "${BLACKLIST[@]}"; do
        if echo "$cmd" | grep -q "$word"; then
            echo "Commande interdite : '$word'"
            blocked=1
            break
        fi
    done

    [[ $blocked -eq 1 ]] && continue

    eval "$cmd"
done
