#!/bin/bash


if [ $# -ne 1 ]; then
    echo "Usage: $0 <ip>"
    echo "Exemple: $0 8.8.8.8"
    exit 1
fi

INPUT="$1"


if echo "$INPUT" | grep -qP '[|&]'; then
    echo "Caractère interdit détecté !"
    exit 1
fi

echo "[*] Exécution : ping -c 1 $INPUT"
ping -c 1 $INPUT
