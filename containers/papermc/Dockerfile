FROM alpine AS download-papermc
WORKDIR /opt
RUN wget https://papermc.io/api/v1/paper/1.15.2/143/download -O papermc.jar

FROM openjdk:11 AS papermc

RUN useradd \
  -M \
  -c "Minecraft server user" \
  -s /bin/false \
  -u 1000 -U \
  minecraft
WORKDIR /var/lib/papermc
RUN \
  mkdir -p /var/lib/papermc \
  && chown -R minecraft:minecraft /var/lib/papermc \
  && chmod -R 0660 /var/lib/papermc

COPY --from=download-papermc /opt/papermc.jar /opt/papermc.jar

COPY entrypoint.sh /entrypoint
RUN chmod +x /entrypoint

USER minecraft
ENTRYPOINT [ "/entrypoint" ]
