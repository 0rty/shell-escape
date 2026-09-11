# Shell Escape & Filter Bypass

---

## About the labs

In this section you'll find multiple exercise about shell escape and filter bypass.
The challenges increase in difficulty depending on the subject.
The techniques presented in these challenges are for educational purposes only. Only use them on systems you own or have explicit written permission to test. Unauthorized use is illegal and unethical.

**Flag format :** `HackUTT{...}`

---

## Prerequisites

- Docker
- Knowledge about linux 

```bash
docker --version  
```

---

## Challenges

| # | Name | Topic |
|---|-----|-------|
| 01 | `chall01_chaining` | Command chaining |
| 02 | `chall02_blacklist` | Blacklist bypass |
| 03 | `chall03_brace` | Bash Brace Expansion |
| 04 | `chall04_ifs` | using env var |
| 05 | `chall06_array` | Array Interpolation / Quoted Injection |

---

## Start a challenge

You can start each exercise independently using this command.  :

```bash
cd chall01_chaining

# Build the image
docker build -t chall01 .

# start
docker run -it --rm chall01
```

---

## Quick start

```bash
# Start the challenge x (1 to 6)
bash launch.sh 1   # start chall01
bash launch.sh 3   # start chall03
```

---

## Challenge structure

```
challXX_theme/
├── Dockerfile       # Docker image
├── wrapper.c        # Binary
├── wrapper.sh       # Bash script to understand
├── README.md        # Explaination (without spoilers)
└── SOLUTION.md      # Solve
```

---
