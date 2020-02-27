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

# update
${STEAMCMDDIR}/steamcmd.sh +@sSteamCmdForcePlatformType linux +login anonymous \
+force_install_dir "${SERVERDIR}/gmod/" +app_update 4020 validate \
+force_install_dir "${SERVERDIR}/css" +app_update 232330 validate \
+force_install_dir "${SERVERDIR}/tf2" +app_update 232250 validate \
+quit

# edit mount.cfg 
echo "\"mountcfg\"" > "${SERVERDIR}/gmod/garrysmod/cfg/mount.cfg"
echo "{" >> "${SERVERDIR}/gmod/garrysmod/cfg/mount.cfg"
echo "	\"cstrike\"	\"${SERVERDIR}/css/cstrike\"" >> "${SERVERDIR}/gmod/garrysmod/cfg/mount.cfg"
echo "	\"tf\"		\"${SERVERDIR}/tf2/tf\"" >> "${SERVERDIR}/gmod/garrysmod/cfg/mount.cfg"
echo "}" >> "${SERVERDIR}/gmod/garrysmod/cfg/mount.cfg"

# edit mountdepots.txt
echo "\"gamedepotsystem\"" > "${SERVERDIR}/gmod/garrysmod/cfg/mountdepots.txt"
echo "{" >> "${SERVERDIR}/gmod/garrysmod/cfg/mountdepots.txt"
echo "	\"tf\"			\"1\"" >> "${SERVERDIR}/gmod/garrysmod/cfg/mountdepots.txt"
echo "	\"cstrike\"		\"1\"" >> "${SERVERDIR}/gmod/garrysmod/cfg/mountdepots.txt"
echo "}" >> "${SERVERDIR}/gmod/garrysmod/cfg/mountdepots.txt"

# edit server.cfg
echo "hostname \"${HOSTNAME}\"" > "${SERVERDIR}/gmod/garrysmod/cfg/server.cfg"
echo "sv_password \"${PASSWD}\"" >> "${SERVERDIR}/gmod/garrysmod/cfg/server.cfg"
echo "rcon_password \"${RCONPASSWD}\"" >> "${SERVERDIR}/gmod/garrysmod/cfg/server.cfg"
echo "sv_region 3" >> "${SERVERDIR}/gmod/garrysmod/cfg/server.cfg"
echo "sv_lan 0" >> "${SERVERDIR}/gmod/garrysmod/cfg/server.cfg"
echo "sv_pure 1" >> "${SERVERDIR}/gmod/garrysmod/cfg/server.cfg"
echo "sv_pausable 0" >> "${SERVERDIR}/gmod/garrysmod/cfg/server.cfg"
echo "fps_max 120" >> "${SERVERDIR}/gmod/garrysmod/cfg/server.cfg"
echo "" >> "${SERVERDIR}/gmod/garrysmod/cfg/server.cfg"
echo "log on" >> "${SERVERDIR}/gmod/garrysmod/cfg/server.cfg"
echo "sv_logbans 1" >> "${SERVERDIR}/gmod/garrysmod/cfg/server.cfg"
echo "sv_logecho 1" >> "${SERVERDIR}/gmod/garrysmod/cfg/server.cfg"
echo "sv_logfile 1" >> "${SERVERDIR}/gmod/garrysmod/cfg/server.cfg"
echo "sv_log_onefile 1" >> "${SERVERDIR}/gmod/garrysmod/cfg/server.cfg"
echo "lua_log_sv 1" >> "${SERVERDIR}/gmod/garrysmod/cfg/server.cfg"

# edit mountdepots.txt
echo "\"Users\"" > "${SERVERDIR}/gmod/garrysmod/settings/users.txt"
echo "{" >> "${SERVERDIR}/gmod/garrysmod/settings/users.txt"
echo "	\"tf\"			\"1\"" >> "${SERVERDIR}/gmod/garrysmod/settings/users.txt"
echo "	\"superadmin\"" > "${SERVERDIR}/gmod/garrysmod/settings/users.txt"
echo "	{" >> "${SERVERDIR}/gmod/garrysmod/settings/users.txt"
echo "		\"xWilliam\"" >> "${SERVERDIR}/gmod/garrysmod/settings/users.txt"
echo "	}" >> "${SERVERDIR}/gmod/garrysmod/settings/users.txt"
echo "}" >> "${SERVERDIR}/gmod/garrysmod/settings/users.txt"

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
