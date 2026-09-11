FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y python3 && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash ctf

RUN echo "HackUTT{4sc11_sh1ft1ng_byt3_by_byt3}" > /flag.txt && \
    chmod 400 /flag.txt && \
    chown root:root /flag.txt

COPY rshell.sh /rshell.sh
RUN chmod 755 /rshell.sh

COPY encode.py /encode.py
RUN chmod 755 /encode.py

COPY README.md /README.md

USER ctf
CMD ["/bin/bash", "/rshell.sh"]
