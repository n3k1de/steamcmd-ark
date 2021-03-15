FROM netherkids/steamcmd

EXPOSE 27015/udp 7777/udp 7778/udp 27020/tcp

ENV GAME="ark" \
    SERVERNAME="ark_server" \
    SERVERDIR="/opt/server" \
    QUERYPORT="27015" \
    PORT="7777" \
    RCONPORT="27020" \
    MAXPLAYERS="12" \
    MAP="TheIsland" \
    RCON="True" \
    PASSWD="" \
    RCONPASSWD=""

COPY --chown=${USER}:${GROUP} /entrypoint.sh /
ADD https://raw.githubusercontent.com/NetherKids/steamcmd/master/manage/query.py /opt/query.py
ADD https://raw.githubusercontent.com/NetherKids/steamcmd/master/manage/rcon.py /opt/rcon.py

HEALTHCHECK  --interval=60s --timeout=60s CMD python3 /opt/query.py localhost ${QUERYPORT}

RUN chmod 0775 /opt/ /entrypoint.sh && chown ${USER}.${GROUP} /opt/ /entrypoint.sh && \
    su ${USER} -c "mkdir -p ${SERVERDIR} && cd ${STEAMCMDDIR} && ${STEAMCMDDIR}/steamcmd.sh +login anonymous +quit" && \
    su ${USER} -c "ln -s ${STEAMCMDDIR}/linux32/steamclient.so ~/.steam/sdk32/steamclient.so" && \
    echo "fs.file-max=100000" >> /etc/sysctl.conf && \
    echo "* soft nofile 1000000" >> /etc/security/limits.conf && \
    echo "* hard nofile 1000000" >> /etc/security/limits.conf && \
    echo "session required pam_limits.so" >> /etc/pam.d/common-session

WORKDIR ${STEAMCMDDIR}
VOLUME ${SERVERDIR}
ENTRYPOINT ["/entrypoint.sh"]
