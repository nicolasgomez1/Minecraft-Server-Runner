#!/bin/bash

SERVER_MAX_MEMORY=4096M	# Max Minecraft Server RAM allocation.
SERVER_PORT=25565		# This check if server is running, have to change port in server.properties also.
RAM_MAX_WORLD_MEMORY=2G	# This should depend on world folder size, be careful, set enough to allocate your world folder.
BACKUP_INTERVAL=300		# 5 Minutes

echo Checking if World folder exists...

if [ ! -d world ]; then
    echo World folder doesnt exists. Creating...
    mkdir -p world
    echo Done!
fi

echo Checking if World folder is mounted in RAM...

if ! mount | grep -q "root/world"; then
    echo Mounting World folder in RAM...
    mount -t tmpfs -o size=$RAM_MAX_WORLD_MEMORY tmpfs /root/world
    echo "World folder mounted in RAM (RESERVED SPACE IN RAM: $RAM_MAX_WORLD_MEMORY)."
fi

if [ -z "$(find world -mindepth 1)" ]; then
    echo Decompressing the last Backup in the World folder...
    tar -xf "$(ls -t world_*.tar | head -n 1)" -C world/
    echo Done!
fi

(while true; do
	echo Checking if Server in Online...

	if lsof -i :"$SERVER_PORT" >/dev/null; then
		echo Creating Backup...

        tar -cf world_$(date +"%Y%m%d%H%M%S").tar -C world/ .

        echo Done!
    fi

    sleep $BACKUP_INTERVAL
done) &

BACKUP_PID=$!

echo Executing Server...
# Running in background
#java -Xmx4096M @libraries/net/minecraftforge/forge/1.20.1-47.2.20/unix_args.txt &

# Using screen
#screen -dmS mc_server java -Xmx4096M @libraries/net/minecraftforge/forge/1.20.1-47.2.20/unix_args.txt
java -Xmx${SERVER_MAX_MEMORY} @libraries/net/minecraftforge/forge/1.20.1-47.2.20/unix_args.txt

echo Done!

echo Unmounting the World folder from RAM...
umount /root/world
echo Done!

echo Stopping Backup Process...
kill $BACKUP_PID
echo Bye.
