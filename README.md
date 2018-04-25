# Conan Exiles Server Utility with Remote Restart
Utility for automating updates and remotely restarting [Conan Exiles](https://conanexiles.com/) server.
Created and Compiled with [AutoIT](https://www.autoitscript.com)
Originally written for use on [Gamercide's](https://gamercide.org) Server

 Automate your Conan Server Management with this Utility! Written using AutoIT with full Source available.
 
 **UPDATE CHECK REQUIRES THE SCRIPT CAN WRITE TO SteamCMD directory**
 
# Conan Server Utility Features
*   Manage Multiple servers with multiple Utilities (See Below)
*   Monitors for crashes and Restarts Server if process closes
*   Optionally Enable fix to close DLL error that comes up if Steam is open when starting server
*   Optionally Disable MULTIHOME to fix some connection problems
*   Optionally Restart the server daily at a certain time (Up to 6 different times through the day)
*   Optionally Use Remote Restart Utility to Restart server remotely using unique passwords (Optionally Set Users) and port
*   Optionally Use SteamCMD for automatic updates ( SteamCMD will be downloaded if not found )
*   Optionally Compare running server version with released version for automatic Update (In 5 to XX minute intervals)
    * *UPDATE CHECK REQUIRES THE SCRIPT CAN WRITE TO SteamCMD directory*
*   Optionally run verification every time SteamCMD is ran
*   Optionally restart server on excessive memory use.
*   Optionally Notify Discord Channel before Restart using Webhook
*   Optionally Notify Multiple Twitch Channels using IRC
*   Log Excessive memory use. Set to a very large number if you don't wish to log anything
*   Set Game Name, Game IP, Game port, max players, Server Password, and Admin Password
*   Rotate X number of logs created by utility every X hours
*   Schedule when player buildings can be damaged and restart when needed.
*   Schedule when Avatars are allowed and restart when needed.
*   **Download and Update Mods Automatically!**
*   Automatically Sort Mods in modlist.txt by order you choose.

This utility, when SteamCMD and daily restarts are enabled, will keep the server up to date on a daily basis.  You can also use  SteamCMD and remote restart to update the server anytime you send the restart request. If CheckForUpdate is enabled this utility will pull the latest version from SteamCMD and compare it to the local app manifest.  If it finds a newer version, it will automatically restart to update the server.

A few things to note. The Game Server IP will be the IP you wish to bind to. This may be a local IP if your server is behind a router.  Also, the game can take a long time to gracefully shut down. So, when the restart is initiated, the utility attempts to gracefully shut down the server. If the server will not shut down gracefully after 1 minute the process is forcefully closed. When SteamCMD is used, a full cycle from the time the command is sent to the time the server is back on line can take 10 minutes or more.  Finally, the remote restart port needs to be allowed through your firewall. 

# Conan Remote Restart Utility Features
*   **Can Now Restart from any Web Browser. Seperate Utility Not Required**
    * *http://ip:port?restartkey=user_pass* 
*   If enabled on the server, use to remotely restart the server.
*   Set Password in INI file to save, or type each time.
*   Restart using IP or Domain Name

# Running Multiple Servers on the Same Machine
Place a copy of the EXE in a different Conan_Server directory, update the INI file to make sure you have no port conflicts, and run the script.  A couple of things you might want to do to help manage two or more running at once. Change the ConanServerUtility.exe names to something Utility1 and Utility2 or something like that. Also, you probably should set the Minute about 30 minutes apart from each so they are not restarting at the same time.

### Using Update Check on Multiple Servers
If you plan on running multiple servers on the same machine, I suggest you create different SteamCMD folders for each server. Due to the way the update is checked, if your servers checked at the same time, it could cause a conflict. This could result in an update being missed for all servers.  

# Automatic mod Installation and Updates.  

For it to work, you must have `CheckForUpdate=yes` so that the server stays up to date as well as the mods.  It will automatically download any mods you put in the list when the server first starts, move them to the Mods directory, and add them to the `Mods\modlist.txt` file. It will then check for updates every X minutes based on `UpdateInterval=X` This will be the same time the server is checked for updates.  If a new update is found it will notify ( if Twitch or Discord is enabled ) then restart the server. Before the server restarts, it will download each mod that needs to be updated, move them to the Mods directory, and update the modlist.txt .

The mods **WILL NOT** be deleted if you only remove them from the ModList. If you wish to remove a mod, you need to shutdown the server, remove the mod manually from the Mods folder and then remove the mod # from the ModList.

Finally, if you wish to start over with new mods, you should remove all mods from the mod folder AND delete `conan_exiles_server\steamapps\workshop\appworkshop_440900.acf` You will also want to delete this file if you remove a mod and later decide to add it again. The script uses this file generated by Steam to track mod versions.

* **CheckForModUpdate**
     * `yes` Will Install Mods listed below and keep them up to date. `CheckForUpdate=yes` Required
     * `no` Will Disable Mod Updates
* **ModList**
    * `#########, #########` Comma Separated list of mods (This is the Mod ID #) to install and keep up to date.
```
[Install Mods and Check for Update? yes/no]
CheckForModUpdate=no
ModList=#########,#########
```

# How to Use Discord Bot
* UseDiscordBot
 * Set to yes to notify Discord Channel before Server Restart
* DiscordWebHookURL
 * This is your Webhook  URL provided by discord. ( Instructions below for Desktop Application )
    1. Right Click on your server
    2. Open Server Settings > Webhooks
    3. Click Create Webhook
    4. Select which Channel you want the bot to announce to (Important)
    5. Under Webhook URL Click the Copy Button next to the URL
    6. Paste the entire Webhook to the INI after DiscordWebHookURL=
       * To use multiple webhooks, separate each full webhook URL with a comma `,`
* DiscordBotName
 * This will override the Name you setup in your webhook. Leave Blank to use default.
* DiscordBotUseTTS
 * Yes will make the bot announce with Text to Speech. No will turn off TTS
* DiscrodBotAvatarLink
 * This is a fully qualified URL to an Image for the Bot Avatar. Will override default. Leave blank for default.
* DiscordBotTimeBeforeRestart
 * Time in Minutes that the Bot will make the first announcement to the channel before Server Restart. If you also use Twitch, the setting with the HIGHEST notification time will be used

The Bot will announce immediately upon restart time. Notifying how long users have based on the time you set. The bot will then announce 1 minute before the server restarts. Finally, the bot will announce exactly as the restart command is sent. Announcements will be sent for Daily Restarts and Update Restarts. Remote Restarts are considered Admin controlled and immediately restart the server without notice.
```
[Use Discord Bot to Send Message Before Restart? yes/no]
UseDiscordBot=yes
DiscordWebHookURL=https://discordapp.com/api/webhooks/AAAAAAA/AAAAAA,https://discordapp.com/api/webhooks/BBBBBB/BBBBB
DiscordBotName=Conan Test Bot
DiscordBotUseTTS=yes
DiscordBotAvatarLink=
DiscordBotTimeBeforeRestart=5
```

# How to use Twitch Bot
* UseTwitchBot
 * Set to yes to notify Twitch Channels before Server Restart
* TwitchNick
 * This is your Twitch nickname. It can be an account created for a bot , or your personal account.
* ChatOAuth
 * This is the key needed to connect to chat over IRC. You need to generate one for this to work.
    1. Go to this URL https://twitchapps.com/tmi
    2. Connect to your account.
    3. Copy the generated key.
    4. Paste the entire key to the INI after ChatOAuth=
* TwitchChannels
  * These are the channels you wish to send the announcement to. You can send to just one or you can send to multiple channels. Separate each channel with a comma `,` `TwitchChannels=channel1,channel2`
* TwitchBotTimeBeforeRestart
 * Time in Minutes that the Bot will make the first announcement to the channel before Server Restart. If you also use Discord, the setting with the HIGHEST notification time will be used.

The Bot will announce immediately upon restart time. Notifying how long users have based on the time you set. The bot will then announce 1 minute before the server restarts. Finally, the bot will announce exactly as the restart command is sent. Announcements will be sent for Daily Restarts and Update Restarts. Remote Restarts are considered Admin controlled and immediately restart the server without notice.
```
[Use Twitch Bot to Send Message Before Restart? yes/no]
UseTwitchBot=no
TwitchNick=twitchbotusername
ChatOAuth=oauth:1234 (Generate OAuth Token Here: https://twitchapps.com/tmi)
TwitchChannels=channel1,channel2,channel3
TwitchBotTimeBeforeRestart=5
```

## Using Multiple Restart Codes

You can set multiple anonymous user passwords by separating each with a comma `,`
`RestartCode=pass1,pass2,pass3`

You can specify the user in the password string by separating user from password with underscore `_`
`RestartCode=User1_Pass1,User2_Pass2`

Or you can mix methods
`RestartCode=User1_Pass1,pass2,User2_Pass2`

On the Remote Restart Utility the user will enter the full string regardless of using the username or not. The user name is there mainly for logging purposes. To trigger a restart the full string between the comma , has to match.

## Examples:
`RestartCode=pass1,pass2,pass3,Admin1_pass4`
* User enters *pass1* in Restart Utility:
  * Server resets and Log displays: Anonymous user @ IP triggered restart using pass1 ( Hidden by default )
* User enters *Admin1_pass4* in Restart Utility
  * Server resets and Log displays: Admin1 @ IP triggered restart using pass4 ( Hidden by default )
* User enters *wrongpassword* in Restart Utility
  * Server does NOT reset and Log displays: Restart Attempt @ IP using string *wrongpassword* (failed attempts are always shown in full)
* User enters *Admin1_wrongpassword*
  * Server does NOT reset and Log displays: Restart Attempt @ IP using string *Admin1_wrongpassword* (failed attempts are always shown in full)

# Hide Passwords in Log
Additionally, I have added the option to Obfuscate passwords in the log files. Currently that is done by replacing all except 4 characters starting with the 4th character with *

`ObfuscatePass="no"` to display full passwords in log.

## Example:
`ObfuscatePass="yes"` and `AdminPass=aPasWd123`

Log displays `AdminPass=***sWd1**`

# How to use Building Damage and Avatar Schedule

## Settings and Examples
* **EnableBuildingDamageSchedule**
   * `yes` will turn on scheduling of Building Damage and automatically restart when changing state
   * `no` will leave setting at whatever state it was in on last run.
* **BuildingDmgEnabledSchedule**
   * This is an array that will determine when player owned buildings **CAN BE DAMAGED**
   * Format is `WDAY-HHMMtoWDAY-HHMM` 
       * `WDAY = 0 - 7, 0 is Everyday, 1 is Sunday and 7 is Saturday`
       * `HHMM = 0000 - 2359`
       * Example: To **Enable** Building Damage Friday Night at 06:00 to Saturday Morning at 10:00
          * `BuildingDmgEnabledSchedule=6-0600to7-1000`
       * Example: To **Enable** Building Damage Monday 11:50 to 17:00 and Tuesday 11:50 to 17:00
         * `BuildingDmgEnabledSchedule=2-1150to2-1700,3-1150to3-1700`
       * Example: To **Enable** Building Damage Everyday except Friday
          * `BuildingDmgEnabledSchedule=7-0000to5-2359`
       * Example: To **Enable** Building Damage Everyday Between 0500 and 1000
          * `BuildingDmgEnabledSchedule=0-0500to0-1000`
             * *For this to work both start and stop day must be 0. If one is 0 and the other is not, it will log the issue and the schedule will not work properly* 
* **FlipBuildingDmgSchedule**
	   * `yes` Will **Disable** building damage during scheduled times
	       * *This is the opposite of what is listed in the above examples*
	   * `no` Will **Enable** building damage during scheduled times
	   
* **EnableAvatarSchedule**
   * `yes` will turn on scheduling of Avatars and automatically restart when changing state
   * `no` will leave setting at whatever state it was in on last run.
* **AvatarsDisabledSchedule**
   * This is an array that will determine when Avatars **ARE DISABLED**
   * Format is `WDAY-HHMMtoWDAY-HHMM` 
       * `WDAY = 0 - 7, 0 is Everyday, 1 is Sunday and 7 is Saturday`
       * `HHMM = 0000 - 2359`
       * Example: To **Disable** Avatars Friday Night at 06:00 to Saturday Morning at 10:00
          * `AvatarsDisabledSchedule=6-0600to7-1000`
       * Example: To **Disable** Avatars Monday 11:50 to 17:00 and Tuesday 11:50 to 17:00
         * `AvatarsDisabledSchedule=2-1150to2-1700,3-1150to3-1700`
       * Example: To **Disable** Avatars Everyday except Friday
          * `AvatarsDisabledSchedule=7-0000to5-2359`
       * Example: To **Disable** Avatars Everyday Between 0500 and 1000
          * `AvatarsDisabledSchedule=0-0500to0-1000`
             * *For this to work both start and stop day must be 0. If one is 0 and the other is not, it will log the issue and the schedule will not work properly* 
* **FlipAvatarSchedule**
       * `yes` Will **Enable** Avatars during scheduled times
	       * *This is the opposite of what is listed in the above examples*
       * `no` Will **Disable** Avatars during scheduled times
	   
* **IniOverwriteFix**
       * `yes` Will move defaultserversettings.ini missing values to serversettings.ini then backup and delete defaultserversettings.ini
       * `no` Will disable this option. **SCHEDULES MAY NOT WORK WITH THIS DISABLED**
```
[Enable Building Damage by Scheduled Time? yes/no]
EnableBuildingDamageSchedule=no
BuildingDmgEnabledSchedule=WDAY(Sunday1)-HHMMtoWDAY(Saturday7)-HHMM,1-0000to7-2359,6-2200to7-0500
FlipBuildingDmgSchedule=no
[Disable Avatars by Scheduled Time? yes/no]
EnableAvatarSchedule=no
AvatarsDisabledSchedule=WDAY(Sunday1)-HHMMtoWDAY(Saturday7)-HHMM,1-0000to7-2359,6-2200to7-0500
FlipAvatarSchedule=no
[Bug Fix - Copy from then Delete Default Server Settings INI? yes/no]
IniOverwriteFix=yes
```

### General Information on Scheduling
These settings will be honored whether the server was online when the schedule started or not. If you start the server 10 minutes before a schedule ends, it **WILL** enable/disable the setting on startup and then **Restart** the server at the end of the schedule to switch it back.

If you are using Discord or Twitch for announcements, this will delay the start and stop times of your schedule by the length of the announcement. If you have the start time set for 0500 and a Time Before restart of 5 minutes, then it will announce the intent to restart at 0500 and will restart at 0505 with the setting enabled or disabled depending on the schedule.

Finally, Daily and Update Restarts do not care what is going on with the schedule.  If an update comes out 30 minutes before a schedule starts, the server will reboot to update,  and then reboot again to change the setting during the scheduled time. For updates, this is obviously necessary, but you should be very careful setting Daily Restarts too close to scheduled enable/ disable times unless you want multiple restarts close together.

If `IniOverwriteFix=yes`
The first time this is ran and a server is not running it will copy all missing settings from DefaultServerSettings.ini to ServerSettings.ini **NO** **CURRENT** **SETTINGS** **ARE** **OVERWRITTEN** . A backup will be created of both files and the *DefaultServerSettings.ini* will be deleted. This is necessary to prevent problems with settings in the default INI conflicting and often overwriting the normal settings. This will not hurt your game, and a backup will be available in the ConanSandbox\Config directory if you need it. 

If `IniOverwriteFix=no`
Schedules may or may not work, and it is possible that your server will be stuck in a restart loop. It is suggested that you leave this set to `yes`


### How to Sort Mods in Specific Order
To sort mods in a specific order, simply list them in the INI file in the order you wish them to load.

**Example**
I want to install mod ID 12345678 (conanstuff) & mod ID 87654321 (moreconanstuff) in order of moreconanstuff, conanstuff.

In the INI I fill out:
```
ModList=87654321,12345678
```
**DO NOT DELETE ConanServerUtility_modid2modname.ini**

# END
