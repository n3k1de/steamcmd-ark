#!/bin/sh

ulimit -n 2048‬
cd ${STEAMCMDDIR}

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

# server start
su steam -c "cd ${SERVERDIR}/gmod/
  ./srcds_run \
  -game garrysmod \
  -console -nobreakpad -usercon -secure -debug \
  -authkey ${APIKEY} \
  -port ${PORT} \
  -ip "localhost" \
  +port ${PORT} \
  +clientport ${CLIENTPORT} \
  +maxplayers ${MAXPLAYERS} \
  +map ${MAP} \
  +sv_setsteamaccount ${SERVERACCOUNT} \
  +gamemode ${GAMEMODE} \
  +sv_password ${PASSWD} \
  +rcon_password ${RCONPASSWD} \
  +hostname ${HOSTNAME} \
  +host_workshop_collection ${WORKSHOPCOLLECTION} \
  -net_port_try 1 \
  -exec server.cfg"
