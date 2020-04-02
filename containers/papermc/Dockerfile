FROM alpine AS download-papermc

ARG PAPERMC_MINECRAFT_VERSION
ARG PAPERMC_VERSION

LABEL "papermc.io/minecraft-version" ${PAPERMC_MINECRAFT_VERSION}
LABEL "papermc.io/version" ${PAPERMC_VERSION}

WORKDIR /opt
RUN wget https://papermc.io/api/v1/paper/$PAPERMC_MINECRAFT_VERSION/$PAPERMC_VERSION/download -O papermc.jar

FROM openjdk:11 AS papermc

RUN \
  groupadd -g 1000 minecraft \
    && \
  useradd \
  -c "Minecraft server user" \
  -s /bin/false \
  -u 1000 -g 1000 \
  minecraft

WORKDIR /var/lib/papermc
RUN \
  mkdir -p /var/lib/papermc \
  && chown -R 1000:1000 /var/lib/papermc \
  && chmod -R 0750 /var/lib/papermc

COPY --from=download-papermc /opt/papermc.jar /opt/papermc.jar

COPY entrypoint.sh /entrypoint
RUN chmod +x /entrypoint

COPY healthcheck.sh /healthcheck
RUN chmod +x /healthcheck

USER minecraft

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "/healthcheck" ]
ENTRYPOINT [ "/entrypoint" ]
