FROM debian:bookworm-slim

RUN useradd -m -s /bin/bash ctf

RUN echo "HackUTT{br4c3_3xp4ns10n_1s_sh3ll_m4g1c}" > /flag.txt && \
    chmod 400 /flag.txt && \
    chown root:root /flag.txt

COPY rshell.sh /rshell.sh
RUN chmod 755 /rshell.sh

COPY README.md /README.md

USER ctf
CMD ["/bin/bash", "/rshell.sh"]
