#!/bin/bash

SERVER_MAX_MEMORY=4096M	# Max Minecraft Server RAM allocation.
SERVER_PORT=25565		# This check if server is running, have to change port in server.properties also.
RAM_MAX_WORLD_MEMORY=3G	# This should depend on world folder size, be careful, set enough to allocate your world folder.
BACKUP_INTERVAL=300		# Value: 300 equals 5 Minutes 

echo ' ___      _             _                   _'
echo '| _ \_  _| |_ ___   ___| |  __ _ _  _ ___  | |___ ___'
echo '|  _/ || |  _/ _ \ / -_) | / _` | || / -_) | / -_) -_)'
echo '|_|  \_,_|\__\___/ \___|_| \__, |\_,_\___| |_\___\___|'
echo '                              |_|'

echo Checking if World folder exists...

if [ ! -d world ]; then
	echo "World folder doesn't exists. Creating..."
	mkdir -p world
	echo Done!
fi

echo Checking if World folder is mounted in RAM...

if ! mount | grep -q "root/world"; then
	echo Mounting World folder in RAM...
	mount -t tmpfs -o size=$RAM_MAX_WORLD_MEMORY tmpfs /root/world
	echo "Done! (RESERVED SPACE IN RAM: $RAM_MAX_WORLD_MEMORY)."
fi

if [ "$1" != "skip_recover_world" ] && [ -z "$(find world -mindepth 1)" ]; then
	echo Decompressing the last Backup in the World folder...
	tar -xf "$(ls -t world_*.tar | head -n 1)" -C world/
	echo Done!
fi

screen -dmS minecraft_server bash -c '
	DoBackup() {
		echo Creating Backup...
		screen -S minecraft_server -X stuff "say Creating Backup...\n"
		tar -cf world_$(date +"%Y%m%d%H%M%S").tar -C world/ .
		echo Done!
		screen -S minecraft_server -X stuff "say Done!\n"

		echo Searching old Backups...
		BACKUPS_COUNT=$(ls -1 world_*.tar 2>/dev/null | wc -l)

		if [ "$BACKUPS_COUNT" -gt 3 ]; then
			OLD_BACKUPS=$(ls -1tr world_*.tar | head -n -3)

			for OLD_BACKUP in $OLD_BACKUPS; do
				rm "$OLD_BACKUP"
				echo "Old Backup: $OLD_BACKUP was deleted."
			done
		fi
		echo Done!
	}
	
	BackupLoop() {
		while true; do
			if lsof -i :'"$SERVER_PORT"' >/dev/null; then
				DoBackup
			fi

			sleep '$BACKUP_INTERVAL'
		done
	}

	echo Starting Auto Backup Process...
	BackupLoop &

	BACKUP_PID=$!

	echo Starting Server...
	java -Xmx'"${SERVER_MAX_MEMORY}"' @libraries/net/minecraftforge/forge/1.20.1-47.2.20/unix_args.txt ;

	echo Stopping Auto Backup Process...
	kill $BACKUP_PID > /dev/null 2>&1

	echo Executing a last Backup...
	DoBackup

	#echo Unmounting the World folder from RAM...
	#umount /root/world
	#echo Done!

	# NOTE: Finally its is not good idea haha
	#shutdown now
'

echo "Minecraft Server and Backup process started. You can access to it using: screen -r minecraft_server"
