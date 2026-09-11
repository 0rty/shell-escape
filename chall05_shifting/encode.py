#!/usr/bin/env python3
"""
Outil d'encodage pour le challenge 05.
Décale chaque caractère de +1 en ASCII.
Usage : python3 encode.py "votre commande"
"""
import sys

def encode(text):
    return ''.join(chr(ord(c) + 1) for c in text)

def decode(text):
    return ''.join(chr(ord(c) - 1) for c in text)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python3 encode.py <texte>")
        print("       python3 encode.py --decode <texte>")
        sys.exit(1)

    if sys.argv[1] == '--decode':
        text = ' '.join(sys.argv[2:])
        print(f"Décodé : {decode(text)}")
    else:
        text = ' '.join(sys.argv[1:])
        encoded = encode(text)
        print(f"Original : {text}")
        print(f"Encodé   : {encoded}")
        print(f"\nCommande : ./wrapper '{encoded}'")
