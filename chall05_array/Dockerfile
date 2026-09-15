FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y gcc && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash ctf

RUN echo "HackUTT{4rr4y_1nj3ct10n_w0w}" > /flag.txt && \
    chmod 400 /flag.txt && \
    chown root:root /flag.txt

WORKDIR /challenge

COPY runner.c .
RUN gcc -o runner runner.c && chmod 4755 runner && rm runner.c

COPY wrapper.sh /challenge/wrapper.sh
RUN chmod 755 /challenge/wrapper.sh

COPY README.md /challenge/README.md

USER ctf
CMD ["/bin/bash"]
