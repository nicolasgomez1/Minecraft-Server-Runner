@echo off
REM Max Minecraft Server RAM allocation.
SET SERVER_MAX_MEMORY=4096M
REM This checks if the server is running. You have to change the port in server.properties also.
SET SERVER_PORT=25565
REM This should depend on the size of the world folder. Be careful, set enough to allocate your world folder.
SET RAM_MAX_WORLD_MEMORY=3G
REM Value: 300 equals 5 Minutes.
SET BACKUP_INTERVAL=300

echo  ^_^_^_      ^_             ^_                   ^_
echo ^| ^_ ^\^_  ^_^| ^|^_ ^_^_^_   ^_^_^_^| ^|  ^_^_ ^_ ^_  ^_ ^_^_^_  ^| ^|^_^_^_ ^_^_^_ 
echo ^|  ^_^/ ^|^| ^|  ^_^/ ^_ ^\ ^/ ^-^_^) ^| ^/ ^_^` ^| ^|^| ^/ ^-^_^) ^| ^/ ^-^_^) ^-^_^)
echo ^|^_^|  ^\^_^,^_^|^\^_^_^\^_^_^_^/ ^\^_^_^_^|^_^| ^\^_^_^, ^|^\^_^,^_^\^_^_^_^| ^|^_^\^_^_^_^\^_^_^_^|
echo                               ^|^_^|

title Server 1.20.1 (RAM: %SERVER_MAX_MEMORY%)

start "minecraft_server" /B java -Xmx%SERVER_MAX_MEMORY% @libraries/net/minecraftforge/forge/1.20.1-47.2.20/win_args.txt %* nogui

:loop
	netstat -ano | findstr /R "%SERVER_PORT%.*LISTENING" >nul
	if %errorlevel% equ 0 (
		echo Creating Backup...

		echo say Creating Backup...&echo(

		"7z.exe" a -ttar -ssw -x!"world\session.lock" "world_%DATE:~-4%%DATE:~-7,2%%DATE:~-10,2%%time:~0,2%%time:~3,2%%time:~6,2%.tar" "world"

		echo Done!
		echo say Done!&echo(

		echo Searching old Backups...

		for /f "skip=3 delims=" %%A in ('dir /b /o-d world_*.tar') do (
			del "%%A"
			echo Old Backup: %%A was deleted.
		)
		
		echo Done!
	)

	timeout /t %BACKUP_INTERVAL% >nul
goto loop
