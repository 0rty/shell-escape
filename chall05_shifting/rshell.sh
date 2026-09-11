#!/bin/bash
# Shell restreint - Challenge 05 : Character Shifting
# Accepte uniquement du texte encodé (chaque char décalé de +1 en ASCII)
# Filtre les caractères dangereux AVANT décodage... mais pas après.

decode() {
    python3 -c "import sys; print(''.join(chr(ord(c)-1) for c in sys.argv[1]))" "$1"
}

echo "============================================"
echo " Challenge 05 — Shell restreint v1.0"
echo " Les commandes doivent être encodées (+1 ASCII)"
echo " Exemple : 'ls' s'encode en 'mt'"
echo " Objectif : lire /flag.txt"
echo "============================================"
echo ""

while true; do
    read -rep "encoded$ " cmd
    [[ -z "$cmd" ]] && continue
    [[ "$cmd" == "exit" ]] && break

    # Filtre sur l'input encodé
    if echo "$cmd" | grep -qP '[;|&`$()\{\}\[\]<>\\"'"'"']'; then
        echo "Caractère interdit dans l'entrée encodée !"
        continue
    fi

    decoded=$(decode "$cmd")
    echo "[decoded]: $decoded"
    eval "$decoded"
done
