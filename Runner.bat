@ECHO OFF

REM	*****************************************************************
REM	*				By	NicolasG (Improved Batch v2)				*
REM *							 	🦘								*
REM	*****************************************************************

REM Features
REM		1)	Easy Server setup.
REM 	2)	Auto Backups on every Startup.
REM 	3)	Launch arguments for improve Server Performance.

REM v2(Because 1.16.5 Minecraft Server version now're in use) Path Notes
REM 	1)	Added new launch arguments.
REM 	2)	Convert to portable 7z for World folder Backups.
REM 	3)	Added code for delete old Logs(.log.gz).
REM 	4)	More recommendations to "Server Setup Guide" Section.

REM	======================================	Server Setup Guide	======================================
REM	Step 1) Configure next values...
REM		Define Max RAM(MB)
set		MAX_RAM=4096
REM		Define JAR Filename(Example: umommy.jar).
set		JAR_NAME=forge-1.16.5-36.2.4.jar
REM		Enable or Disable World Backup on Startup.
set		backup=true
REM 	Enable or Disable Delete All old Logs on Startup.
set 	deletelogs=true
REM	Step 2) Exec the batch file, A file(eula.txt) will be created on main folder.
REM	Step 3) Now open eula.txt and change the value from false to true.
REM	Step 4) Now exec the batch again and wait to server be online and type stop on server console.
REM	Step 5) Time to setup the server.properties file, open then & change...
REM														snooper-enabled from true to false
REM														view-distance 	from 10 to 8
REM														online-mode 	from true to false
REM														==========	Optionals	==========
REM 															allow-flight from false to true(Can causeplayer kick)
REM																max-players
REM																motd (Server description)
REM	==================================================================================================

REM	Get Actual Date & Time
for /f "tokens=3,2,4 delims=/- " %%x in ("%date%") do set d=%%x-%%y-%%z
for /f "tokens=1,2,3 delims=:. " %%x in ("%time%") do set t=%%x%%y

title Minecraft Server (RAM Allocated: %MAX_RAM%MB)

REM Delete old Logs
if %deletelogs% == true (
	echo Checking for Logs folder...
	if exist logs (
		echo Starting to Delete all old Logs...
		del /s logs\*.log.gz
		echo Old Logs has been deleted successfully.
	) else (
		echo Logs Folder doesnt exist.
	)
)

REM	Make a BACKUP of WORLD
if %backup% == true (
	echo Checking for World folder...
	if exist World (
		echo Starting World Security Backup...
		"7z.exe" a -tzip "World_%d%_%t%.zip" "world"
		echo Backup done!.
	) else (
		echo World Folder doesnt exist.
	)
)

REM	EXEC Jar
java -Xmx%MAX_RAM%M -Xms%MAX_RAM%M -server -XX:+ScavengeBeforeFullGC -XX:-UseConcMarkSweepGC -XX:-UseParallelGC -XX:+AggressiveOpts -XX:+OptimizeStringConcat -XX:+UseFastAccessorMethods -XX:GCPauseIntervalMillis=150 -XX:+UseAdaptiveGCBoundary -XX:-UseGCOverheadLimit -jar %JAR_NAME% nogui

PAUSE
