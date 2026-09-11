FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y python3 && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash ctf

RUN echo "HackUTT{1FS_4nd_PATH_sl1c1ng_byp4ss}" > /flag.txt && \
    chmod 444 /flag.txt && \
    chown root:root /flag.txt

COPY rshell.sh /rshell.sh
RUN chmod 755 /rshell.sh

COPY README.md /README.md

USER ctf
CMD ["/bin/bash", "/rshell.sh"]
