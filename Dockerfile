FROM netherkids/steamcmd
MAINTAINER NetherKidsDE <git@netherkids.de>

EXPOSE 27015/udp 7777/udp 7778/udp 32330/tcp

ENV GAME="ark" \
    SERVERNAME="ark_server" \
    SERVERDIR="/opt/server" \
    QUERYPORT="27015" \
    PORT="7777" \
    RCONPORT="32330" \
    MAXPLAYERS="12" \
    MAP="TheIsland" \
    RCON="True" \
    PASSWD="" \
    ADMINPASSWD=""

COPY --chown=steam:steam /entrypoint.sh /

RUN chmod 0775 /opt/ /entrypoint.sh && chown steam.steam /opt/ /entrypoint.sh && \
    su steam -c "mkdir -p ${SERVERDIR} && cd ${STEAMCMDDIR} && ${STEAMCMDDIR}/steamcmd.sh +login anonymous +quit" && \
    echo "fs.file-max=100000" >> /etc/sysctl.conf && \
    echo "* soft nofile 1000000" >> /etc/security/limits.conf && \
    echo "* hard nofile 1000000" >> /etc/security/limits.conf && \
    echo "session required pam_limits.so" >> /etc/pam.d/common-session

WORKDIR ${STEAMCMDDIR}
VOLUME ${SERVERDIR}
ENTRYPOINT ["/entrypoint.sh"]
