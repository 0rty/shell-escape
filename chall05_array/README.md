# Challenge 06 — Array Interpolation ⭐⭐⭐⭐⭐

## Contexte

Un système de scores pour un jeu. Il stocke les scores dans un **tableau
associatif Bash** et les récupère via une clé (le nom d'utilisateur).

L'entrée est validée : uniquement des caractères alphanumériques.
La récupération dans le tableau est entre guillemets doubles.

Pourtant, une variable très sensible (`$PASS`) est définie dans le script...
et il y a une façon de la faire afficher.

## Objectif

Exfiltrer la valeur de la variable `$PASS` du script.

## Lancement

```bash
docker build -t chall06 .
docker run -it --rm chall06
```

```bash
./runner <username>
# ou directement :
bash wrapper.sh <username>
```

## Fonctionnement normal

```bash
./runner alice    # → Score : 100
./runner bob      # → Score : 85
./runner unknown  # → Utilisateur non trouvé
```

## La faille

La validation bloque `;`, `|`, `$`, `(`, `)` et tous les caractères spéciaux.
Seuls les caractères alphanumériques passent.

Pourtant, regardez comment le tableau est accédé dans le code source de `wrapper.sh`.
Y a-t-il un contexte où une chaîne alphanumérique peut devenir une expression évaluée ?

## Indice 1

<details>
<summary>Révéler</summary>
En Bash, `${array["key"]}` et `${array[key]}` sont différents.
Dans le second cas, `key` peut être une **expression arithmétique ou une substitution**.
</details>

## Indice 2

<details>
<summary>Révéler</summary>
La ligne vulnérable est : `SCORE="${scores["$USERNAME"]}"`

En Bash, à l'intérieur de `${array[...]}`, les guillemets doubles internes
ne protègent pas contre tout. Que se passe-t-il avec :
```
${scores[a[$(commande)]]}
```
</details>

## Indice 3

<details>
<summary>Révéler</summary>
`a[$(echo $PASS >&2)]` — si ceci est interprété comme une clé de tableau,
que se passe-t-il avec la substitution `$(echo $PASS >&2)` ?

Note : `>&2` redirige vers stderr pour que la sortie soit visible même si
stdout est capturé.
</details>

## Format du flag

`HackUTT{...}`
