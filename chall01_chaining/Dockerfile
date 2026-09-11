FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y iputils-ping && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash ctf

RUN echo "HackUTT{ch41n1ng_s3m1c0l0n_ftw}" > /flag.txt && \
    chmod 400 /flag.txt && \
    chown root:root /flag.txt

COPY rshell.sh /rshell.sh
RUN chmod 755 /rshell.sh

COPY README.md /README.md

COPY wrapper.c /wrapper.c
RUN gcc -o wrapper wrapper.c && chmod 4755 wrapper && rm wrapper.c

USER ctf
CMD ["/bin/bash"]
