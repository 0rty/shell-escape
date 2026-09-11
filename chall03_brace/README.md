# Challenge 03 — Bash Brace Expansion ⭐⭐

## Contexte

Un outil de recherche de fichiers par extension. Le filtre est devenu plus
sérieux : la plupart des caractères spéciaux sont bloqués, ainsi que
certains mots-clés. Seules les extensions "normales" sont censées passer.

## Objectif

Lire le contenu du fichier `/flag.txt`.

## Lancement

```bash
docker build -t chall03 .
docker run -it --rm chall03
```

```bash
./wrapper <extension>
```

## Ce qui est bloqué

Caractères : `;` `|` `&` `` ` `` `$` `(` `)` `'` `"` `\` espace `/`

Mots-clés : `flag`, `root`, `etc`

## Indice 1

<details>
<summary>Révéler</summary>
La Bash Brace Expansion (`{a,b}`) est-elle affectée par les filtres sur les caractères ci-dessus ?
</details>

## Indice 2

<details>
<summary>Révéler</summary>
`{ls,/}` est interprété par Bash AVANT d'être passé au programme.
Que se passe-t-il si le wrapper reçoit plusieurs arguments au lieu d'un seul ?
</details>

## Indice 3

<details>
<summary>Révéler</summary>
`./wrapper {txt,/flag.txt}` — que reçoit `argv[1]` et `argv[2]` ?
</details>

## Format du flag

`HackUTT{...}`
