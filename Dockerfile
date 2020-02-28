FROM netherkids/steamcmd
MAINTAINER NetherKidsDE <git@netherkids.de>

EXPOSE 27015/udp 7777/udp 7778/udp 27020/tcp

ENV GAME gmod \
    SERVERDIR /opt/server \
    PORT=27015 \
    CLIENTPORT=7777 \
    RCONPORT=27020 \
    MAXPLAYERS=4 \
    MAP=TheIsland \
    PASSWD="" \
    ADMINPASSWD="" \
    WORKSHOPCOLLECTION="" \
    APIKEY="" \
    SERVERACCOUNT=""

COPY --chown=steam:steam /entrypoint.sh /

RUN apt-get install glibc.i686 libstdc++.i686 ncurses-libs.i686 && \
    chmod 0775 /opt/ /entrypoint.sh && chown steam.steam /opt/ /entrypoint.sh && \
    su steam -c "mkdir -p ${SERVERDIR} && cd ${STEAMCMDDIR} && ${STEAMCMDDIR}/steamcmd.sh +login anonymous +quit" && \
    echo "fs.file-max=100000" >> /etc/sysctl.conf && \
    echo "*               soft    nofile          1000000" >> /etc/security/limits.conf && \
    echo "*               hard    nofile          1000000" >> /etc/security/limits.conf && \
    echo "session required pam_limits.so" >> /etc/pam.d/common-session && \

# RUN chmod 0775 /opt/entrypoint.sh && chown steam.steam /opt/entrypoint.sh

WORKDIR ${STEAMCMDDIR}
VOLUME ${SERVERDIR}
ENTRYPOINT ["/entrypoint.sh"]
