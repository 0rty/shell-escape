# Challenge 04 — ${IFS}, ${PATH:0:1}, ${LS_COLORS:10:1}

## Contexte

Un "shell restreint" qui ne permet d'exécuter que des commandes composées
de caractères alphanumériques, tirets, underscores et points.
Pas d'espaces, pas de slashes, pas de caractères spéciaux.

Comment lire `/flag.txt` sans pouvoir taper d'espace ni de slash ?

## Objectif

Lire le contenu de `/flag.txt`.

## Lancement

```bash
docker build -t chall04 .
docker run -it --rm chall04
```

Dans le container :
```bash
./wrapper <commande>
# ou pour simuler le shell restreint interactif :
bash launch.sh
```

## Concept clé

Le wrapper passe l'argument directement à `system()`.
`system()` appelle `/bin/sh -c "cd /tmp && VOTRE_INPUT"`.
Le **shell** développe les variables **avant** l'exécution.

Donc si votre input contient `${IFS}`, le shell le remplace par... quoi ?

## Indice 1

<details>
<summary>Révéler</summary>

```bash
echo "${IFS}"   # Que contient cette variable ?
echo "${PATH:0:1}"  # Que retourne cette expression ?
```
</details>

## Indice 2

<details>
<summary>Révéler</summary>
`${IFS}` contient espace + tab + newline par défaut.
`${PATH:0:1}` retourne le premier caractère de `$PATH`, qui est...
</details>

## Indice 3

<details>
<summary>Révéler</summary>
`/usr/local/bin:/usr/bin:/bin` → le premier caractère est `/` !
`${PATH:0:1}` = `/`
Donc `${PATH:0:1}flag.txt` = `/flag.txt`... mais `flag` est blacklisté.

Cherchez d'autres variables ou d'autres slices...
</details>

## Format du flag

`HackUTT{...}`
