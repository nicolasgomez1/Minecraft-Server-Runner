@echo off
REM Max Minecraft Server RAM allocation.
SET SERVER_MAX_MEMORY=4096M
REM This checks if the server is running. You have to change the port in server.properties also.
SET SERVER_PORT=25565
REM This is for RCON server messages
set RCON_SERVER_PORT=25575
set RCON_SERVER_PWD=512
REM REM Value: 300 equals 5 Minutes.
SET BACKUP_INTERVAL=900
REM Vals declares (DO NOT TOUCH)
SET BACKUP_ELAPSED=0
SET IS_SERVER_ONLINE=0

echo  ^_^_^_      ^_             ^_                   ^_
echo ^| ^_ ^\^_  ^_^| ^|^_ ^_^_^_   ^_^_^_^| ^|  ^_^_ ^_ ^_  ^_ ^_^_^_  ^| ^|^_^_^_ ^_^_^_ 
echo ^|  ^_^/ ^|^| ^|  ^_^/ ^_ ^\ ^/ ^-^_^) ^| ^/ ^_^` ^| ^|^| ^/ ^-^_^) ^| ^/ ^-^_^) ^-^_^)
echo ^|^_^|  ^\^_^,^_^|^\^_^_^\^_^_^_^/ ^\^_^_^_^|^_^| ^\^_^_^, ^|^\^_^,^_^\^_^_^_^| ^|^_^\^_^_^_^\^_^_^_^|
echo                               ^|^_^|

title Server 1.20.1 (RAM: %SERVER_MAX_MEMORY%)

start "minecraft_server" /B java -Xmx%SERVER_MAX_MEMORY% @libraries/net/minecraftforge/forge/1.20.1-47.4.6/win_args.txt %* nogui

timeout /t 3 >nul

for /f "tokens=2" %%i in ('tasklist /FI "WINDOWTITLE eq minecraft_server" /NH 2^>nul') do (
    set "JAVA_PID=%%i"
)

:BACKUP_LOOP
	REM V1
	REM netstat -ano | findstr /R "%SERVER_PORT%.*LISTENING" >nul
	REM V2
	REM netstat -ano | findstr /R ":%SERVER_PORT% .*LISTENING" >nul
	REM V3
	Utils/mcrcon -H 127.0.0.1 -P %RCON_SERVER_PORT% -p %RCON_SERVER_PWD% "list" >nul 2>&1
	if %errorlevel% equ 0 (
		if %IS_SERVER_ONLINE% neq 1 (
			set IS_SERVER_ONLINE=1
		)

		if %BACKUP_ELAPSED% gtr %BACKUP_INTERVAL% (
			call :DoBackup

			set /a BACKUP_ELAPSED=0
		)
	) else (
		if %IS_SERVER_ONLINE% equ 1 (
			tasklist /FI "PID eq %JAVA_PID%" 2>nul | find /I "java.exe" >nul

			if %errorlevel% equ 1 (
				call :DoBackup

				goto :eof
			)
		)
	)

	set /a BACKUP_ELAPSED+=1

	timeout /t 1 >nul
goto BACKUP_LOOP

:DoBackup
	echo Creating Backup...
	Utils/mcrcon -H 127.0.0.1 -P %RCON_SERVER_PORT% -p %RCON_SERVER_PWD% "say Creando copia de seguridad (Se puede laguear)..."

	Utils/WinRAR.exe a -afzip -m0 -y -r -o+ -inul -ibck -x"world\session.lock" "world_%DATE:~-4%%DATE:~-7,2%%DATE:~-10,2%%time:~0,2%%time:~3,2%%time:~6,2%.zip" "world\*"

	echo Done!
	Utils/mcrcon -H 127.0.0.1 -P %RCON_SERVER_PORT% -p %RCON_SERVER_PWD% "say Copia de seguridad realizada."

	echo Searching old Backups...

	for /f "skip=3 delims=" %%A in ('dir /b /o-d world_*.zip') do (
		del "%%A"

		echo Old Backup: %%A was deleted.
	)

	echo Done!
goto :eof
