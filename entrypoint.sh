#!/bin/sh

# ulimit -n 100000‬
cd ${STEAMCMDDIR}
chown ${USER}.${USER} -R /opt/

trap "/opt/rcon.py localhost ${QUERYPORT} ${RCONPASSWD} saveworld\\ndoexit" INT TERM

if [ -e "/home/steam/.steam/sdk32/steamclient.so" ]
then
    echo "steamclient.so found."
else
    echo "steamclient.so not found."
    su steam -c "ln -s ${STEAMCMDDIR}/linux32/steamclient.so ~/.steam/sdk32/steamclient.so"
    if [ -e "/home/steam/.steam/sdk32/steamclient.so" ]
    then
        echo "steamclient.so link created."
    fi
fi

${STEAMCMDDIR}/steamcmd.sh +@sSteamCmdForcePlatformType linux +login anonymous \
+force_install_dir ${SERVERDIR}/ark_server/ +app_update 376030 \
+quit

# server start
su ${USER} -c "cd ${SERVERDIR}/ark_server/ && ./ShooterGame/Binaries/Linux/ShooterGameServer ${MAP}?listen?Multihome=0.0.0.0?SessionName="${SERVERNAME}"?MaxPlayers=${MAXPLAYERS}?Port=${PORT}?QueryPort=${QUERYPORT}?RCONEnabled=${RCON}?RCONPort=${RCONPORT}?ServerAdminPassword=${RCONPASSWD}?ServerPassword=${PASSWD} -NoBattlEye -crossplay -server -log -servergamelog"
