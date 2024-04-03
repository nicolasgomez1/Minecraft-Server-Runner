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

if [ -z "$(find world -mindepth 1)" ]; then
	if [ ! "$1" = "skip_recover_world" ]; then
		echo Decompressing the last Backup in the World folder...
		tar -xf "$(ls -t world_*.tar | head -n 1)" -C world/
		echo Done!
	fi

	echo Searching old Backups...
	recent_backups=$(ls -t world_*.tar | head -n 3)

	for backup in $(ls world_*.tar); do
		is_recent=false
		for recent_backup in $recent_backups; do
			if [ "$backup" = "$recent_backup" ]; then
				is_recent=true
				break
			fi
		done

		if [ "$is_recent" = false ]; then
			rm "$backup"
			echo "Old Backup: $backup was deleted."
		fi
	done

	echo Done!
fi

screen -dmS minecraft_server bash -c '
	DoBackup() {
		echo Creating Backup...
		tar -cf world_$(date +"%Y%m%d%H%M%S").tar -C world/ .
		echo Done!

		if [ -z "$(find world -mindepth 1)" ]; then
			echo Searching old Backups...
			recent_backups=$(ls -t world_*.tar | head -n 3)

			for backup in $(ls world_*.tar); do
				is_recent=false
				for recent_backup in $recent_backups; do
					if [ "$backup" = "$recent_backup" ]; then
						is_recent=true
						break
					fi
				done

				if [ "$is_recent" = false ]; then
					rm "$backup"
					echo "Old Backup: $backup was deleted."
				fi
			done

			echo Done!
		fi
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
	java -Xmx'${SERVER_MAX_MEMORY}' @libraries/net/minecraftforge/forge/1.20.1-47.2.20/unix_args.txt ;

	echo Stopping Auto Backup Process...
	kill $BACKUP_PID > /dev/null 2>&1

	echo Executing a last Backup...
	DoBackup

	echo Unmounting the World folder from RAM...
	umount /root/world
	echo Done!

	# NOTE: Finally its is not good idea haha
	#shutdown now
'

echo "Minecraft Server and Backup process started. You can access to it using: screen -r minecraft_server"
