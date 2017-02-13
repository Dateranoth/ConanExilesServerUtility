# Conan Exiles Server Utility with Remote Restart
Utility for automating updates and remotely restarting [Conan Exiles](https://conanexiles.com/) server.
Created and Compiled with [AutoIT](https://www.autoitscript.com)
Originally written for use on [Gamercide's](https://gamercide.org) Server

 Automate your Conan Server Management with this Utility! Written using AutoIT with full Source available.
 
 **UPDATE CHECK REQUIRES THE SCRIPT CAN READ FROM** http://steamcommunity.com/games/440900/rss/
 
# Conan Server Utility Features
*   Manage Multiple servers with multiple Utilities (See Below)
*   Monitors for crashes and Restarts Server if process closes
*   Optionally Enable fix to close DLL error that comes up if Steam is open when starting server
*   Optionally Disable MULTIHOME to fix some connection problems
*   Optionally Check RSS feed from Conan Devs and Restart if Update Detected (In 5 to 59 minute intervals) 
*   Optionally Restart the server daily at a certain time (Up to 6 different times through the day)
*   Optionally Use Remote Restart Utility to Restart server remotely using unique password and port
*   Optionally Use SteamCMD to automatically update server
*   Optionally run verification every time SteamCMD is ran
*   Optionally restart server on excessive memory use.
*   Log Excessive memory use. Set to a very large number if you don't wish to log anything
*   Set Game Name, Game IP, Game port, max players, Server Password, and Admin Password
*   Rotate X number of logs created by utility every X hours
    
# Conan Remote Restart Features
*   If enabled on the server, use to remotely restart the server.
*   Set Password in INI file to save, or type each time.
*   Restart using IP or Domain Name

This utility, when SteamCMD and daily restarts are enabled, will keep the server up to date on a daily basis.  You can also use  SteamCMD and remote restart to update the server anytime you send the restart request. If CheckForUpdate is enabled this utility will parse the RSS for Conan to look for PATCH headers on an hourly basis (Using the Daily Restart Minute).  If it finds a new header it will restart to update the server.

A few things to note. The Game Server IP will be the IP you wish to bind to. This may be a local IP if your server is behind a router.  Also, the game can take a long time to gracefully shut down. So, when the restart is initiated, the utility attempts to gracefully shut down the server. If the server will not shut down gracefully after 1 minute the process is forcefully closed. When SteamCMD is used, a full cycle from the time the command is sent to the time the server is back on line can take 10 minutes or more.  Finally, the remote restart port needs to be allowed through your firewall. 

# Running Multiple Servers on the Same Machine
Place a copy of the EXE in a different Conan_Server directory, update the INI file to make sure you have no port conflicts, and run the script.  A couple of things you might want to do to help manage two or more running at once. Change the ConanServerUtility.exe names to something Utility1 and Utility2 or something like that. Also, you probably should set the Minute about 30 minutes apart from each so they are not restarting at the same time. 
