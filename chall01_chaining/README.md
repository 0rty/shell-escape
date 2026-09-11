# Challenge 01 — Command Chaining ⭐

## Contexte

Un administrateur a développé un petit outil pour ping des adresses IP depuis un serveur.
Il a pensé à bloquer les caractères `|` et `&` pour éviter les injections... mais a-t-il pensé à tout ?

## Objectif

Lire le contenu du fichier `/flag.txt`.

## Lancement du challenge

```bash
docker build -t chall01 .
docker run -it --rm chall01
```

Une fois dans le container :
```bash
./wrapper <ip>
```

## Indice 1 (si vous bloquez)

<details>
<summary>Révéler l'indice</summary>
Il existe d'autres façons de chaîner des commandes en Bash que `|` et `&`...
</details>

## Indice 2

<details>
<summary>Révéler l'indice</summary>
Que fait le caractère `;` en Bash ? Et les sauts de ligne ?
</details>

## Format du flag

`HackUTT{...}`
