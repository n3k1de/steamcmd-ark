#!/bin/sh

ulimit -n 100000‬
cd ${STEAMCMDDIR}

chown steam.steam /opt/ ${STEAMCMDDIR}

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

su steam -c "${STEAMCMDDIR}/steamcmd.sh +@sSteamCmdForcePlatformType linux +login anonymous \
+force_install_dir ${SERVERDIR}/ark/ +app_update 376030 validate \
+quit"
echo "---"

# server start
su steam -c "cd ${SERVERDIR}/ark/
  ./ShooterGame/Binaries/Linux/ShooterGameServer ${MAP}?listen?Multihome=0.0.0.0?SessionName=${SERVERNAME}?MaxPlayers=${MAXPLAYERS}?QueryPort=${QUERYPORT}?RCONPort=${RCONPORT}?Port=${CLIENTPORT}?ServerPassword=${PASSWD}?ServerAdminPassword=${ADMINPASSWD} -server -log"
