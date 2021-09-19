@ECHO OFF

REM	*****************************************************************
REM	*			By	NicolasG (Run Improved Batch v1)				*
REM *							 	🦘								*
REM	*****************************************************************

REM	======================================	Server Setup Guide	======================================
REM	Step 1) Configure next values...
REM		Define Max RAM(MB)
set		MAX_RAM=4096
REM		Define JAR Filename(Example: umommy.jar).
set		JAR_NAME=forge-1.12.2-14.23.5.2855.jar
REM		Enable or Disable World Backup On Startup.
set		backup=true
REM	Step 2) Now exec the batch file, A file(eula.txt) will be created on main folder.
REM	Step 3) Now open eula.txt and change the value from false to true.
REM	Step 4) Now exec the batch again and wait to server be online and type stop on server console.
REM	Step 5) Time to setup the server.properties file, open then & change...
REM														snooper-enabled from true to false
REM														view-distance 	from 10 to 8
REM														online-mode 	from true to false
REM														==========	Optionals	==========
REM																max-players
REM																motd (Server description)
REM	================================================================================================

REM	Get Actual Date and Time
for /f "tokens=3,2,4 delims=/- " %%x in ("%date%") do set d=%%x-%%y-%%z
for /f "tokens=1,2,3 delims=:. " %%x in ("%time%") do set t=%%x%%y

title Minecraft Server (RAM Allocated: %MAX_RAM%MB)

REM	Make a BACKUP of WORLD
if %backup% == true (
	echo Checking for World folder...
	if exist World (
		echo Starting World Security Backup...
		"C:\Program Files\7-Zip\7z.exe" a -tzip "World_%d%_%t%.zip" "world"
		echo Backup done!.
	) else (
		echo World Folder doesnt exist.
	)
)

REM	EXEC Jar
java -Xmx%MAX_RAM%M -Xms%MAX_RAM%M -jar %JAR_NAME% nogui

PAUSE
