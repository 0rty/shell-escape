FROM debian:bookworm-slim

RUN useradd -m -s /bin/bash ctf

RUN echo "HackUTT{bl4ckl1st_byp4ss_qu0t3s_w1n}" > /flag.txt && \
    chmod 444 /flag.txt && \
    chown root:root /flag.txt

COPY rshell.sh /rshell.sh
RUN chmod 755 /rshell.sh

COPY README.md /README.md

USER ctf
CMD ["/bin/bash", "/rshell.sh"]
