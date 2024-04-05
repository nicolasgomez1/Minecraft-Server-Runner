@echo off
REM Max Minecraft Server RAM allocation.
SET SERVER_MAX_MEMORY=4096M
REM This checks if the server is running. You have to change the port in server.properties also.
SET SERVER_PORT=25565
rem REM Value: 300 equals 5 Minutes.
SET BACKUP_INTERVAL=300
rem Vals declares (DO NOT TOUCH)
SET BACKUP_ELAPSED=0
SET IS_SERVER_ONLINE=0

echo  ^_^_^_      ^_             ^_                   ^_
echo ^| ^_ ^\^_  ^_^| ^|^_ ^_^_^_   ^_^_^_^| ^|  ^_^_ ^_ ^_  ^_ ^_^_^_  ^| ^|^_^_^_ ^_^_^_ 
echo ^|  ^_^/ ^|^| ^|  ^_^/ ^_ ^\ ^/ ^-^_^) ^| ^/ ^_^` ^| ^|^| ^/ ^-^_^) ^| ^/ ^-^_^) ^-^_^)
echo ^|^_^|  ^\^_^,^_^|^\^_^_^\^_^_^_^/ ^\^_^_^_^|^_^| ^\^_^_^, ^|^\^_^,^_^\^_^_^_^| ^|^_^\^_^_^_^\^_^_^_^|
echo                               ^|^_^|

title Server 1.20.1 (RAM: %SERVER_MAX_MEMORY%)

start "minecraft_server" /B java -Xmx%SERVER_MAX_MEMORY% @libraries/net/minecraftforge/forge/1.20.1-47.2.20/win_args.txt %* nogui

timeout /t 3 >nul

for /f "tokens=2" %%i in ('tasklist /FI "WINDOWTITLE eq minecraft_server" /NH 2^>nul') do (
    set "JAVA_PID=%%i"
)

:BACKUP_LOOP
	netstat -ano | findstr /R "%SERVER_PORT%.*LISTENING" >nul
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
	echo say Creating Backup...&echo(
	WinRAR.exe a -y -r -o+ -inul -ibck -x"world\session.lock" "world_%DATE:~-4%%DATE:~-7,2%%DATE:~-10,2%%time:~0,2%%time:~3,2%%time:~6,2%.tar" "world\*"
	echo Done!
	echo say Done!&echo(

	echo Searching old Backups...
	for /f "skip=3 delims=" %%A in ('dir /b /o-d world_*.tar') do (
		del "%%A"
		echo Old Backup: %%A was deleted.
	)
	echo Done!
goto :eof
