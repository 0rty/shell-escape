#!/bin/bash
# Version script (pour debug / compréhension)
# Équivalent fonctionnel du wrapper C

if [ $# -ne 1 ]; then
    echo "Usage: $0 <ip>"
    echo "Exemple: $0 8.8.8.8"
    exit 1
fi

INPUT="$1"

# Filtre basique
if echo "$INPUT" | grep -qP '[|&]'; then
    echo "Caractère interdit détecté !"
    exit 1
fi

echo "[*] Exécution : ping -c 1 $INPUT"
ping -c 1 $INPUT
