FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y gcc bash && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash ctf

WORKDIR /challenge

# Le flag est dans un fichier secret lu par le script bash
RUN echo "HackUTT{4rr4y_1nj3ct10n_w0w}" > /flag.txt.txt && \
    chmod 400 /flag.txt && \
    chown root:root /flag.txt

# Copier et compiler le runner C
COPY runner.c .
RUN gcc -o runner runner.c && chmod 4755 runner && rm runner.c

# Copier le script bash (SUID n'aide pas ici — c'est le script qui lit le secret)
COPY wrapper.sh /challenge/wrapper.sh
RUN chmod 400 /challenge/wrapper.sh

COPY script.sh /challenge/script.sh
RUN chmod 755 /challenge/script.sh
# Rendre wrapper.sh accessible en lecture et exécution par le runner SUID
# Le runner tourne en root (SUID) et peut donc lire /secret_key.txt
# Le script wrapper.sh hérite des droits root via le runner SUID
RUN chown root:root /challenge/wrapper.sh

COPY README.md /challenge/README.md

USER ctf
CMD ["/bin/bash"]
