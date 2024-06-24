FROM debian:trixie-20231009-slim

RUN apt update && apt install -y openssl && \
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

WORKDIR /app

ADD bin/create_all.sh create_all.sh

RUN chmod u+x *.sh

ENTRYPOINT [ "./create_all.sh" ]
