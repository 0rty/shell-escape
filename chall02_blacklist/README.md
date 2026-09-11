# Challenge 02 — Blacklist Bypass ⭐⭐

## Contexte

Un wrapper qui exécute des commandes shell, mais bloque une liste de
commandes jugées dangereuses : `cat`, `ls`, `whoami`, `id`...

Le développeur pense qu'en interdisant ces mots, personne ne pourra
les exécuter. Mais Bash interprète les commandes différemment de `strstr()`...

## Objectif

Lire le contenu du fichier `/flag.txt`.

## Lancement

```bash
docker build -t chall02 .
docker run -it --rm chall02
```

```bash
./wrapper <commande>
```

## Ce qui est bloqué (par mots-clés exacts)

```
cat  head  tail  more  less  tac  nl  od  xxd  strings
grep  awk  sed  cut  sort  whoami  id  ls  find  which
```

## Indice 1

<details>
<summary>Révéler</summary>
Le filtre cherche les mots avec `strstr()` — il cherche la sous-chaîne exacte.
Il voit `cat` dans `cat /flag.txt`. Mais voit-il `cat` dans `c''at` ?
</details>

## Indice 2

<details>
<summary>Révéler</summary>
En Bash, les guillemets vides `''` insérés au milieu d'un mot sont ignorés
à l'exécution. `c''at` est exécuté comme `cat`.
Même chose avec `$@` qui vaut une chaîne vide : `ca$@t` → `cat`.
</summary>
</details>

## Format du flag

`HackUTT{...}`
