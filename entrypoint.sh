#!/bin/bash

DATA_DIR=/app/data
SERVER_DIR=/app/server

DEFAULT_CONF="
# This serverconfig.txt was generated by environment variables
# More information about this file can be found here:
# https://terraria.gamepedia.com/Server#Server_config_file

world=worlds/${WORLD_FILE_NAME}
worldname=${WORLD_NAME}
autocreate=${AUTOCREATE}
difficulty=${DIFFICULTY}
maxplayers=${MAX_PLAYERS}
motd=${MOTD}
password=${PASSWORD}
worldpath=worlds
banlist=config/banlist.txt
language=${LANGUAGE}
"

# function to gracefully shut down server
function shut_down() {
        echo "[INFO] entrypoint.sh: executing shut down"
        screen -S terraria -X stuff "^Mexit^M"
	while [ -e /proc/$1 ]; do
		sleep .5
	done
        exit 0
}

# check if serverconfig.txt exists. If not, create one
mkdir -p /app/data/config
`ls ${DATA_DIR}/config/serverconfig.txt > /dev/null 2>&1`
if [ $? -ne 0 ]; then
	echo "[INFO] entrypoint.sh: serverconfig.txt does not exist, creating one"
        echo "${DEFAULT_CONF}" > "${DATA_DIR}"/config/serverconfig.txt
fi
touch "${DATA_DIR}"/config/banlist.txt

# run server
touch "${SERVER_DIR}"/server.log
cd "${DATA_DIR}"
screen -dmS terraria /bin/bash -c "mono --server --gc=sgen -O=all /app/server/TerrariaServer.exe -config config/serverconfig.txt | tee -a ${SERVER_DIR}/server.log"
TERRARIA_PID=`screen -ls | awk '/\.terraria\t/ {print $1}' | awk -F '.' '{print $1}'`

# handling container shutdown
trap "shut_down $TERRARIA_PID" SIGTERM SIGKILL

# prints log file to stdout, allowing it to be captured by "docker logs" command
tail -f ${SERVER_DIR}/server.log &

sleep infinity &
wait $!