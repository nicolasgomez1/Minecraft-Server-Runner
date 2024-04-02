# To use linux script
##### Require install default-jdk & screen
- Put the script and server files inside of root folder and execute it using sh ```Server_Runner.sh```. This script runs in a screen, so can access to it using ```screen -r minecraft_server```.
##### How to Configure the Script
- At the top of the Script have ```SERVER_MAX_MEMORY``` (To define max allocated ram memory available to be used by the minecraft server). Have ```SERVER_PORT``` (This value is used by the script to check if the Minecraft Server is online to start to do the backups). Have ```RAM_MAX_WORLD_MEMORY``` (To define max ram memory reserved to be used as World data store, because it script mount the World folder in ram memory, to have maximun IO Red/Write speed possible). And finally have ```BACKUP_INTERVAL``` (The backups interval in seconds).
 
