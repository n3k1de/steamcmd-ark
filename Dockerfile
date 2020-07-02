FROM netherkids/steamcmd:stable

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

COPY --chown=${USER}:${GROUP} /entrypoint.sh /

RUN chmod 0775 /opt/ /entrypoint.sh && chown ${USER}.${GROUP} /opt/ /entrypoint.sh && \
    su ${USER} -c "mkdir -p ${SERVERDIR} && cd ${STEAMCMDDIR} && ${STEAMCMDDIR}/steamcmd.sh +login anonymous +quit" && \
    echo "fs.file-max=100000" >> /etc/sysctl.conf && \
    echo "* soft nofile 1000000" >> /etc/security/limits.conf && \
    echo "* hard nofile 1000000" >> /etc/security/limits.conf && \
    echo "session required pam_limits.so" >> /etc/pam.d/common-session

WORKDIR ${STEAMCMDDIR}
VOLUME ${SERVERDIR}
ENTRYPOINT ["/entrypoint.sh"]
