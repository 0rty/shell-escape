# Shell Escape & Filter Bypass — CTF Pédagogique
### HackUTT — Module Sécurité Bash

---

## Présentation

Série de 6 challenges de difficulté croissante sur les techniques de contournement
de filtres shell et d'injection de commandes. Chaque challenge est un container
Docker indépendant.

**Format des flags :** `HackUTT{...}`

---

## Prérequis

- Docker installé et démarré
- Connaissance de base de Linux et Bash (voir intro du cours)

```bash
docker --version   # vérifier que Docker est disponible
```

---

## Challenges

| # | Nom | Thème | Difficulté |
|---|-----|-------|-----------|
| 01 | `chall01_chaining` | Command chaining (`;`, `\n`, `$()`) | ⭐ |
| 02 | `chall02_blacklist` | Bypass de blacklist avec `c'a't`, `ca$@t` | ⭐⭐ |
| 03 | `chall03_brace` | Bash Brace Expansion `{a,b}` | ⭐⭐ |
| 04 | `chall04_ifs` | `${IFS}`, `${PATH:0:1}`, slicing de variables | ⭐⭐⭐ |
| 05 | `chall05_shifting` | Character Shifting ASCII | ⭐⭐⭐⭐ |
| 06 | `chall06_array` | Array Interpolation / Quoted Injection | ⭐⭐⭐⭐⭐ |

---

## Lancement d'un challenge

Chaque challenge se lance indépendamment. Allez dans le dossier du challenge :

```bash
cd chall01_chaining

# Construction de l'image (à faire une seule fois)
docker build -t chall01 .

# Lancement
docker run -it --rm chall01
```

Une fois dans le container, lisez le `README.md` :
```bash
cat README.md
```

---

## Script de lancement rapide

```bash
# Lancer le challenge N (1 à 6)
bash launch.sh 1   # lance chall01
bash launch.sh 3   # lance chall03
```

---

## Structure d'un challenge

```
challXX_theme/
├── Dockerfile       # Image Docker autonome
├── wrapper.c        # Binaire C vulnérable (code source)
├── wrapper.sh       # Équivalent script Bash (pour comprendre)
├── README.md        # Énoncé étudiant (sans spoiler)
└── SOLUTION.md      # Solution complète + explication (professeur)
```

---

## Concepts abordés

### 1. Command Chaining
Opérateurs pour exécuter plusieurs commandes : `;`, `&&`, `||`, `\n`, `$()`

### 2. Blacklist Bypass
Insérer des guillemets vides ou `$@` pour tromper les filtres par mots-clés :
`c'a't` → `cat`, `ca$@t` → `cat`, `w'h'o'am'i` → `whoami`

### 3. Bash Brace Expansion
`{a,b}` est développé par le shell AVANT l'exécution du programme.
Le programme ne voit jamais les accolades d'origine.

### 4. Variable Expansion
- `${IFS}` → espace/tab/newline (remplacer les espaces)
- `${PATH:0:1}` → `/` (premier caractère de PATH)
- `${HOME:0:1}` → `/` (alternative)
- `${var:N:1}` → N-ième caractère de var

### 5. Character Shifting
Décaler les valeurs ASCII pour passer un filtre qui vérifie avant transformation.
Filtrer `;` (59) ne bloque pas `<` (60) qui décode en `;`.

### 6. Array Interpolation
En Bash, les indices de tableaux sont évalués même entre guillemets doubles.
`${array["$user_input"]}` avec `user_input='x[$(cmd)]'` → exécute `cmd`.

---

## Ressources complémentaires

- [Bash Manual — Parameter Expansion](https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion)
- [GTFOBins](https://gtfobins.github.io/) — binaires exploitables
- [HackTricks — Bash Injection](https://book.hacktricks.xyz/linux-hardening/bypass-bash-restrictions)
- [OWASP — Command Injection](https://owasp.org/www-community/attacks/Command_Injection)
