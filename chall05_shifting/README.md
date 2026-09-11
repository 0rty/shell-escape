# Challenge 05 — Character Shifting ⭐⭐⭐⭐

## Contexte

Un système d'exécution de commandes "sécurisé" avec un encodage maison.
Les commandes doivent être encodées avant d'être envoyées : chaque caractère
est décalé de **+1 en ASCII**. Le système décode et exécute.

Le filtre analyse l'entrée **encodée** pour bloquer les caractères dangereux.
Mais le décodage modifie les valeurs ASCII...

## Principe du décalage ASCII

```
'a' (ASCII 97)  → encoder en → 'b' (ASCII 98)
'l' (ASCII 108) → encoder en → 'm' (ASCII 109)
's' (ASCII 115) → encoder en → 't' (ASCII 116)
```

Donc pour exécuter `ls`, on envoie `mt`.

## Objectif

Lire le contenu de `/flag.txt`.

## Lancement

```bash
docker build -t chall05 .
docker run -it --rm chall05
```

```bash
./wrapper <commande_encodée>

# Outil d'aide pour encoder :
python3 encode.py "votre commande"
```

## Ce qui est filtré (dans l'entrée ENCODÉE)

```
; | & ` $ ( ) { } [ ] < > \ " '
```

## Indice 1

<details>
<summary>Révéler</summary>
Le filtre bloque `;` dans l'entrée encodée. Mais si `;` est encodé en quoi ?
`ord(';') = 59`, donc le caractère encodé serait `chr(59+1) = '<'`...
Et `<` est aussi bloqué. Réfléchissez à l'envers.
</details>

## Indice 2

<details>
<summary>Révéler</summary>
Pour que le décodage produise `;` (ASCII 59), il faut envoyer `<` (ASCII 60).
Mais `<` est dans la liste des caractères interdits !

Pour produire `|` (ASCII 124), il faut envoyer `}` (ASCII 125).
`}` est aussi dans la liste...

Cherchez des caractères de chaînage dont le décalage +1 n'est PAS dans la liste.
</details>

## Indice 3

<details>
<summary>Révéler</summary>
Et les newlines ? `\n` a l'ASCII 10. Pour le produire, il faut envoyer ASCII 11 = `\v` (vertical tab).
`\v` n'est pas dans la liste des caractères interdits !
</details>

## Format du flag

`HackUTT{...}`
