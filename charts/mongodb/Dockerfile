FROM mongo:4.0.6

LABEL maintainer="Giacomo Longo <gabibbo97@gmail.com>"

RUN apt-get update && apt-get install --yes curl dnsutils openssl

WORKDIR /opt/mongoscripts
COPY scripts/ /opt/mongoscripts
RUN chmod --recursive 0755 /opt/mongoscripts
