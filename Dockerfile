FROM netherkids/steamcmd
MAINTAINER NetherKidsDE <git@netherkids.de>

EXPOSE 27015/tcp 27015/udp 27005/tcp 27005/udp 27020/udp

ENV GAME gmod \
    SERVERDIR /opt/server \
    PORT=27015 \
    CLIENTPORT=27005 \
    MAXPLAYERS=4 \
    GAMEMODE=sandbox \
    MAP=gm_construct \
    PASSWD="" \
    RCONPASSWD="" \
    WORKSHOPCOLLECTION="" \
    APIKEY="" \
    SERVERACCOUNT=""

COPY --chown=steam:steam /entrypoint.sh /

RUN chmod 0775 /opt/ /entrypoint.sh && chown steam.steam /opt/ /entrypoint.sh && \
    su steam -c "mkdir -p ${SERVERDIR} && cd ${STEAMCMDDIR} && ${STEAMCMDDIR}/steamcmd.sh +login anonymous +quit"

# RUN chmod 0775 /opt/entrypoint.sh && chown steam.steam /opt/entrypoint.sh

WORKDIR ${STEAMCMDDIR}
VOLUME ${SERVERDIR}
ENTRYPOINT ["/entrypoint.sh"]
