;Originally written by Dateranoth for use
;by https://gamercide.com on their server
;Distributed Under GNU GENERAL PUBLIC LICENSE

#include-once
#include <Date.au3>

#Region ;**** INI Settings - User Variables ****

Func ReadUini($sIniFile, $sLogFile)
	Local $iIniFail = 0
	Local $iniCheck = ""
	Local $aChar[3]
	For $i = 1 To 13
		$aChar[0] = Chr(Random(97, 122, 1)) ;a-z
		$aChar[1] = Chr(Random(48, 57, 1)) ;0-9
		$iniCheck &= $aChar[Random(0, 1, 1)]
	Next

	Global $BindIP = IniRead($sIniFile, "Use MULTIHOME to Bind IP? Disable if having connection issues (yes/no)", "BindIP", $iniCheck)
	Global $g_IP = IniRead($sIniFile, "Game Server IP", "ListenIP", $iniCheck)
	Global $GamePort = IniRead($sIniFile, "Game Server Port", "GamePort", $iniCheck)
	Global $QueryPort = IniRead($sIniFile, "Steam Query Port", "QueryPort", $iniCheck)
	Global $ServerName = IniRead($sIniFile, "Server Name", "ServerName", $iniCheck)
	Global $ServerPass = IniRead($sIniFile, "Server Password", "ServerPass", $iniCheck)
	Global $AdminPass = IniRead($sIniFile, "Admin Password", "AdminPass", $iniCheck)
	Global $MaxPlayers = IniRead($sIniFile, "Max Players", "MaxPlayers", $iniCheck)
	Global $serverdir = IniRead($sIniFile, "Server Directory. NO TRAILING SLASH", "serverdir", $iniCheck)
	Global $UseSteamCMD = IniRead($sIniFile, "Use SteamCMD To Update Server? yes/no", "UseSteamCMD", $iniCheck)
	Global $steamcmddir = IniRead($sIniFile, "SteamCMD Directory. NO TRAILING SLASH", "steamcmddir", $iniCheck)
	Global $validategame = IniRead($sIniFile, "Validate Files Every Time SteamCMD Runs? yes/no", "validategame", $iniCheck)
	Global $UseRemoteRestart = IniRead($sIniFile, "Use Remote Restart ?yes/no", "UseRemoteRestart", $iniCheck)
	Global $g_Port = IniRead($sIniFile, "Remote Restart Port", "ListenPort", $iniCheck)
	Global $RestartCode = IniRead($sIniFile, "Remote Restart Password", "RestartCode", $iniCheck)
	Global $sObfuscatePass = IniRead($sIniFile, "Hide Passwords in Log? yes/no", "ObfuscatePass", $iniCheck)
	Global $CheckForUpdate = IniRead($sIniFile, "Check for Update Every X Minutes? yes/no", "CheckForUpdate", $iniCheck)
	Global $UpdateInterval = IniRead($sIniFile, "Update Check Interval in Minutes 05-59", "UpdateInterval", $iniCheck)
	Global $g_sUpdateMods = IniRead($sIniFile, "Install Mods and Check for Update? yes/no", "CheckForModUpdate", $iniCheck)
	Global $g_sMods = IniRead($sIniFile, "Install Mods and Check for Update? yes/no", "ModList", $iniCheck)
	Global $RestartDaily = IniRead($sIniFile, "Restart Server Daily? yes/no", "RestartDaily", $iniCheck)
	Global $HotHour1 = IniRead($sIniFile, "Daily Restart Hours? 00-23", "HotHour1", $iniCheck)
	Global $HotHour2 = IniRead($sIniFile, "Daily Restart Hours? 00-23", "HotHour2", $iniCheck)
	Global $HotHour3 = IniRead($sIniFile, "Daily Restart Hours? 00-23", "HotHour3", $iniCheck)
	Global $HotHour4 = IniRead($sIniFile, "Daily Restart Hours? 00-23", "HotHour4", $iniCheck)
	Global $HotHour5 = IniRead($sIniFile, "Daily Restart Hours? 00-23", "HotHour5", $iniCheck)
	Global $HotHour6 = IniRead($sIniFile, "Daily Restart Hours? 00-23", "HotHour6", $iniCheck)
	Global $HotMin = IniRead($sIniFile, "Daily Restart Minute? 00-59", "HotMin", $iniCheck)
	Global $ExMem = IniRead($sIniFile, "Excessive Memory Amount?", "ExMem", $iniCheck)
	Global $ExMemRestart = IniRead($sIniFile, "Restart On Excessive Memory Use? yes/no", "ExMemRestart", $iniCheck)
	Global $SteamFix = IniRead($sIniFile, "Running Server with Steam Open? (yes/no)", "SteamFix", $iniCheck)
	Global $logRotate = IniRead($sIniFile, "Rotate X Number of Logs every X Hours? yes/no", "logRotate", $iniCheck)
	Global $logQuantity = IniRead($sIniFile, "Rotate X Number of Logs every X Hours? yes/no", "logQuantity", $iniCheck)
	Global $logHoursBetweenRotate = IniRead($sIniFile, "Rotate X Number of Logs every X Hours? yes/no", "logHoursBetweenRotate", $iniCheck)
	Global $sUseDiscordBot = IniRead($sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "UseDiscordBot", $iniCheck)
	Global $sDiscordWebHookURLs = IniRead($sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordWebHookURL", $iniCheck)
	Global $sDiscordBotName = IniRead($sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotName", $iniCheck)
	Global $bDiscordBotUseTTS = IniRead($sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotUseTTS", $iniCheck)
	Global $sDiscordBotAvatar = IniRead($sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotAvatarLink", $iniCheck)
	Global $iDiscordBotNotifyTime = IniRead($sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotTimeBeforeRestart", $iniCheck)
	Global $sUseTwitchBot = IniRead($sIniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "UseTwitchBot", $iniCheck)
	Global $sTwitchNick = IniRead($sIniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "TwitchNick", $iniCheck)
	Global $sChatOAuth = IniRead($sIniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "ChatOAuth", $iniCheck)
	Global $sTwitchChannels = IniRead($sIniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "TwitchChannels", $iniCheck)
	Global $iTwitchBotNotifyTime = IniRead($sIniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "TwitchBotTimeBeforeRestart", $iniCheck)
	Global $g_sEnableBuildingDmgSchedule = IniRead($sIniFile, "Enable Building Damage by Scheduled Time? yes/no", "EnableBuildingDamageSchedule", $iniCheck)
	Global $g_sBuildingDmgEnabledTimes = IniRead($sIniFile, "Enable Building Damage by Scheduled Time? yes/no", "BuildingDmgEnabledSchedule", $iniCheck)
	Global $g_sFlipBuildingDmgSchedule = IniRead($sIniFile, "Enable Building Damage by Scheduled Time? yes/no", "FlipBuildingDmgSchedule", $iniCheck)
	Global $g_sEnableAvatarSchedule = IniRead($sIniFile, "Disable Avatars by Scheduled Time? yes/no", "EnableAvatarSchedule", $iniCheck)
	Global $g_sAvatarsDisabledTimes = IniRead($sIniFile, "Disable Avatars by Scheduled Time? yes/no", "AvatarsDisabledSchedule", $iniCheck)
	Global $g_sFlipAvatarSchedule = IniRead($sIniFile, "Disable Avatars by Scheduled Time? yes/no", "FlipAvatarSchedule", $iniCheck)
	Global $g_sIniOverwriteFix = IniRead($sIniFile, "Bug Fix - Copy from then Delete Default Server Settings INI? yes/no", "IniOverwriteFix", $iniCheck)
	Global $g_sExtraServerCommands = IniRead($sIniFile, "Extra Command Line Options. Leave Blank if Not Using", "ExtraServerCommands", $iniCheck)
	Global $g_sEnableDebug = IniRead($sIniFile, "Enable Debug to Output More Log Detail? yes/no", "EnableDebug", $iniCheck)

	If $iniCheck = $BindIP Then
		$BindIP = "yes"
		$iIniFail += 1
	EndIf
	If $iniCheck = $g_IP Then
		$g_IP = "127.0.0.1"
		$iIniFail += 1
	EndIf
	If $iniCheck = $GamePort Then
		$GamePort = "7777"
		$iIniFail += 1
	EndIf
	If $iniCheck = $QueryPort Then
		$QueryPort = "27015"
		$iIniFail += 1
	EndIf
	If $iniCheck = $ServerName Then
		$ServerName = "Conan Server Utility Server"
		$iIniFail += 1
	EndIf
	If $iniCheck = $ServerPass Then
		$ServerPass = ""
		$iIniFail += 1
	EndIf
	If $iniCheck = $AdminPass Then
		$AdminPass &= "_noHASHsymbol"
		$iIniFail += 1
	EndIf
	If $iniCheck = $MaxPlayers Then
		$MaxPlayers = "20"
		$iIniFail += 1
	EndIf
	If $iniCheck = $serverdir Then
		$serverdir = "C:\Game_Servers\Conan_Exiles_Server"
		$iIniFail += 1
	EndIf
	If $iniCheck = $UseSteamCMD Then
		$UseSteamCMD = "yes"
		$iIniFail += 1
	EndIf
	If $iniCheck = $steamcmddir Then
		$steamcmddir = "C:\Game_Servers\SteamCMD"
		$iIniFail += 1
	EndIf
	If $iniCheck = $validategame Then
		$validategame = "no"
		$iIniFail += 1
	EndIf
	If $iniCheck = $UseRemoteRestart Then
		$UseRemoteRestart = "no"
		$iIniFail += 1
	EndIf
	If $iniCheck = $g_Port Then
		$g_Port = "57520"
		$iIniFail += 1
	EndIf
	If $iniCheck = $RestartCode Then
		$RestartCode = "Admin1_Pass:" & $RestartCode & "-AllowedCharacters=1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@$%^&*()+=-{}[]\|:;./?"
		$iIniFail += 1
	EndIf
	If $iniCheck = $sObfuscatePass Then
		$sObfuscatePass = "yes"
		$iIniFail += 1
	EndIf
	If $iniCheck = $CheckForUpdate Then
		$CheckForUpdate = "yes"
		$iIniFail += 1
	ElseIf $CheckForUpdate = "yes" And $UseSteamCMD <> "yes" Then
		$CheckForUpdate = "no"
		FileWriteLine($sLogFile, _NowCalc() & " SteamCMD disabled. Disabling CheckForUpdate. Update will not work without SteamCMD to update it!")
	EndIf
	If $iniCheck = $UpdateInterval Then
		$UpdateInterval = "15"
		$iIniFail += 1
	ElseIf $UpdateInterval < 5 Then
		$UpdateInterval = 5
	EndIf
	If $iniCheck = $g_sUpdateMods Then
		$g_sUpdateMods = "no"
		$iIniFail += 1
	ElseIf $g_sUpdateMods = "yes" And $CheckForUpdate <> "yes" Then
		$g_sUpdateMods = "no"
		FileWriteLine($sLogFile, _NowCalc() & " Server Update Check is Disabled. Disabling Mod Updates. Does not make sense to update Mods and Not Server!")
	EndIf
	If $iniCheck = $g_sMods Then
		$g_sMods = "#########,#########"
		$iIniFail += 1
	EndIf
	If $iniCheck = $RestartDaily Then
		$RestartDaily = "no"
		$iIniFail += 1
	EndIf
	If $iniCheck = $HotHour1 Then
		$HotHour1 = "00"
		$iIniFail += 1
	EndIf
	If $iniCheck = $HotHour2 Then
		$HotHour2 = "00"
		$iIniFail += 1
	EndIf
	If $iniCheck = $HotHour3 Then
		$HotHour3 = "00"
		$iIniFail += 1
	EndIf
	If $iniCheck = $HotHour4 Then
		$HotHour4 = "00"
		$iIniFail += 1
	EndIf
	If $iniCheck = $HotHour5 Then
		$HotHour5 = "00"
		$iIniFail += 1
	EndIf
	If $iniCheck = $HotHour6 Then
		$HotHour6 = "00"
		$iIniFail += 1
	EndIf
	If $iniCheck = $HotMin Then
		$HotMin = "01"
		$iIniFail += 1
	EndIf
	If $iniCheck = $ExMem Then
		$ExMem = "6000000000"
		$iIniFail += 1
	EndIf
	If $iniCheck = $ExMemRestart Then
		$ExMemRestart = "no"
		$iIniFail += 1
	EndIf
	If $iniCheck = $SteamFix Then
		$SteamFix = "no"
		$iIniFail += 1
	EndIf
	If $iniCheck = $logRotate Then
		$logRotate = "yes"
		$iIniFail += 1
	EndIf
	If $iniCheck = $logQuantity Then
		$logQuantity = "10"
		$iIniFail += 1
	EndIf
	If $iniCheck = $logHoursBetweenRotate Then
		$logHoursBetweenRotate = "24"
		$iIniFail += 1
	ElseIf $logHoursBetweenRotate < 1 Then
		$logHoursBetweenRotate = 1
	EndIf
	If $iniCheck = $sUseDiscordBot Then
		$sUseDiscordBot = "no"
		$iIniFail += 1
	EndIf
	If $iniCheck = $sDiscordWebHookURLs Then
		$sDiscordWebHookURLs = "https://discordapp.com/api/webhooks/XXXXXX/XXXX <- NO TRAILING SLASH AND USE FULL URL FROM WEBHOOK URL ON DISCORD"
		$iIniFail += 1
	EndIf
	If $iniCheck = $sDiscordBotName Then
		$sDiscordBotName = "Conan Exiles Discord Bot"
		$iIniFail += 1
	EndIf
	If $iniCheck = $bDiscordBotUseTTS Then
		$bDiscordBotUseTTS = "yes"
		$iIniFail += 1
	EndIf
	If $iniCheck = $sDiscordBotAvatar Then
		$sDiscordBotAvatar = ""
		$iIniFail += 1
	EndIf
	If $iniCheck = $iDiscordBotNotifyTime Then
		$iDiscordBotNotifyTime = "5"
		$iIniFail += 1
	ElseIf $iDiscordBotNotifyTime < 1 Then
		$iDiscordBotNotifyTime = 1
	EndIf
	If $iniCheck = $sUseTwitchBot Then
		$sUseTwitchBot = "no"
		$iIniFail += 1
	EndIf
	If $iniCheck = $sTwitchNick Then
		$sTwitchNick = "twitchbotusername"
		$iIniFail += 1
	EndIf
	If $iniCheck = $sChatOAuth Then
		$sChatOAuth = "oauth:1234 (Generate OAuth Token Here: https://twitchapps.com/tmi)"
		$iIniFail += 1
	EndIf
	If $iniCheck = $sTwitchChannels Then
		$sTwitchChannels = "channel1,channel2,channel3"
		$iIniFail += 1
	EndIf
	If $iniCheck = $iTwitchBotNotifyTime Then
		$iTwitchBotNotifyTime = "5"
		$iIniFail += 1
	ElseIf $iTwitchBotNotifyTime < 1 Then
		$iTwitchBotNotifyTime = 1
	EndIf
	If $iniCheck = $g_sEnableBuildingDmgSchedule Then
		$g_sEnableBuildingDmgSchedule = "no"
		$iIniFail += 1
	EndIf
	If $iniCheck = $g_sBuildingDmgEnabledTimes Then
		$g_sBuildingDmgEnabledTimes = "WDAY(Sunday1)-HHMMtoWDAY(Saturday7)-HHMM,1-0000to7-2359,6-2200to7-0500"
		$iIniFail += 1
	EndIf
	If $iniCheck = $g_sFlipBuildingDmgSchedule Then
		$g_sFlipBuildingDmgSchedule = "no"
		$iIniFail += 1
	EndIf
	If $iniCheck = $g_sEnableAvatarSchedule Then
		$g_sEnableAvatarSchedule = "no"
		$iIniFail += 1
	EndIf
	If $iniCheck = $g_sAvatarsDisabledTimes Then
		$g_sAvatarsDisabledTimes = "WDAY(Sunday1)-HHMMtoWDAY(Saturday7)-HHMM,1-0000to7-2359,6-2200to7-0500"
		$iIniFail += 1
	EndIf
	If $iniCheck = $g_sFlipAvatarSchedule Then
		$g_sFlipAvatarSchedule = "no"
		$iIniFail += 1
	EndIf
	If $iniCheck = $g_sIniOverwriteFix Then
		$g_sIniOverwriteFix = "yes"
		$iIniFail += 1
	EndIf
	If $iniCheck = $g_sExtraServerCommands Then
		$g_sExtraServerCommands = ""
		$iIniFail =+ 1
	EndIf
	If $iniCheck = $g_sEnableDebug Then
		$g_sEnableDebug = "no"
		$iIniFail =+ 1
	EndIf
	If $iIniFail > 0 Then
		iniFileCheck($sIniFile, $iIniFail)
	EndIf

	If $bDiscordBotUseTTS = "yes" Then
		$bDiscordBotUseTTS = True
	Else
		$bDiscordBotUseTTS = False
	EndIf

	If ($sUseDiscordBot = "yes") Then
		$g_iDelayShutdownTime = $iDiscordBotNotifyTime
		If ($sUseTwitchBot = "yes") And ($iTwitchBotNotifyTime > $g_iDelayShutdownTime) Then
			$g_iDelayShutdownTime = $iTwitchBotNotifyTime
		EndIf
	Else
		$g_iDelayShutdownTime = $iTwitchBotNotifyTime
	EndIf

	If $g_sFlipBuildingDmgSchedule = "yes" Then
		Global $g_bFlipBuildingDmgSchedule = True
	Else
		Global $g_bFlipBuildingDmgSchedule = False
	EndIf

	If $g_sFlipAvatarSchedule = "yes" Then
		Global $g_bFlipAvatarSchedule = True
	Else
		Global $g_bFlipAvatarSchedule = False
	EndIf

	If $g_sIniOverwriteFix = "yes" Then
		Global $g_bIniOverwriteFix = True ; This enables deleting the DefaultServerSettings.INI. Only way to make ServerSettings.ini work properly.
	Else
		Global $g_bIniOverwriteFix = False
	EndIf

	If $g_sEnableDebug = "yes" Then
		Global $g_bDebug = True ; This enables Debugging. Outputs more information to log file.
	Else
		Global $g_bDebug = False
	EndIf
EndFunc   ;==>ReadUini

Func iniFileCheck($sIniFile, $iIniFail)
	If FileExists($sIniFile) Then
		Local $aMyDate, $aMyTime
		_DateTimeSplit(_NowCalc(), $aMyDate, $aMyTime)
		Local $iniDate = StringFormat("%04i.%02i.%02i.%02i%02i", $aMyDate[1], $aMyDate[2], $aMyDate[3], $aMyTime[1], $aMyTime[2])
		FileMove($sIniFile, $sIniFile & "_" & $iniDate & ".bak", 1)
		UpdateIni($sIniFile)
		MsgBox(4096, "INI MISMATCH", "Found " & $iIniFail & " Missing Variables" & @CRLF & @CRLF & "Backup created and all existing settings transfered to new INI." & @CRLF & @CRLF & "Modify INI and restart.")
		Exit
	Else
		UpdateIni($sIniFile)
		MsgBox(4096, "Default INI File Made", "Please Modify Default Values and Restart Script")
		Exit
	EndIf
EndFunc   ;==>iniFileCheck


Func UpdateIni($sIniFile)
	IniWrite($sIniFile, "Use MULTIHOME to Bind IP? Disable if having connection issues (yes/no)", "BindIP", $BindIP)
	IniWrite($sIniFile, "Game Server IP", "ListenIP", $g_IP)
	IniWrite($sIniFile, "Game Server Port", "GamePort", $GamePort)
	IniWrite($sIniFile, "Steam Query Port", "QueryPort", $QueryPort)
	IniWrite($sIniFile, "Server Name", "ServerName", $ServerName)
	IniWrite($sIniFile, "Server Password", "ServerPass", $ServerPass)
	IniWrite($sIniFile, "Admin Password", "AdminPass", $AdminPass)
	IniWrite($sIniFile, "Max Players", "MaxPlayers", $MaxPlayers)
	IniWrite($sIniFile, "Server Directory. NO TRAILING SLASH", "serverdir", $serverdir)
	IniWrite($sIniFile, "Use SteamCMD To Update Server? yes/no", "UseSteamCMD", $UseSteamCMD)
	IniWrite($sIniFile, "SteamCMD Directory. NO TRAILING SLASH", "steamcmddir", $steamcmddir)
	IniWrite($sIniFile, "Validate Files Every Time SteamCMD Runs? yes/no", "validategame", $validategame)
	IniWrite($sIniFile, "Use Remote Restart ?yes/no", "UseRemoteRestart", $UseRemoteRestart)
	IniWrite($sIniFile, "Remote Restart Port", "ListenPort", $g_Port)
	IniWrite($sIniFile, "Remote Restart Password", "RestartCode", $RestartCode)
	IniWrite($sIniFile, "Hide Passwords in Log? yes/no", "ObfuscatePass", $sObfuscatePass)
	IniWrite($sIniFile, "Check for Update Every X Minutes? yes/no", "CheckForUpdate", $CheckForUpdate)
	IniWrite($sIniFile, "Update Check Interval in Minutes 05-59", "UpdateInterval", $UpdateInterval)
	IniWrite($sIniFile, "Install Mods and Check for Update? yes/no", "CheckForModUpdate", $g_sUpdateMods)
	IniWrite($sIniFile, "Install Mods and Check for Update? yes/no", "ModList", $g_sMods)
	IniWrite($sIniFile, "Restart Server Daily? yes/no", "RestartDaily", $RestartDaily)
	IniWrite($sIniFile, "Daily Restart Hours? 00-23", "HotHour1", $HotHour1)
	IniWrite($sIniFile, "Daily Restart Hours? 00-23", "HotHour2", $HotHour2)
	IniWrite($sIniFile, "Daily Restart Hours? 00-23", "HotHour3", $HotHour3)
	IniWrite($sIniFile, "Daily Restart Hours? 00-23", "HotHour4", $HotHour4)
	IniWrite($sIniFile, "Daily Restart Hours? 00-23", "HotHour5", $HotHour5)
	IniWrite($sIniFile, "Daily Restart Hours? 00-23", "HotHour6", $HotHour6)
	IniWrite($sIniFile, "Daily Restart Minute? 00-59", "HotMin", $HotMin)
	IniWrite($sIniFile, "Excessive Memory Amount?", "ExMem", $ExMem)
	IniWrite($sIniFile, "Restart On Excessive Memory Use? yes/no", "ExMemRestart", $ExMemRestart)
	IniWrite($sIniFile, "Running Server with Steam Open? (yes/no)", "SteamFix", $SteamFix)
	IniWrite($sIniFile, "Rotate X Number of Logs every X Hours? yes/no", "logRotate", $logRotate)
	IniWrite($sIniFile, "Rotate X Number of Logs every X Hours? yes/no", "logQuantity", $logQuantity)
	IniWrite($sIniFile, "Rotate X Number of Logs every X Hours? yes/no", "logHoursBetweenRotate", $logHoursBetweenRotate)
	IniWrite($sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "UseDiscordBot", $sUseDiscordBot)
	IniWrite($sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordWebHookURL", $sDiscordWebHookURLs)
	IniWrite($sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotName", $sDiscordBotName)
	IniWrite($sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotUseTTS", $bDiscordBotUseTTS)
	IniWrite($sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotAvatarLink", $sDiscordBotAvatar)
	IniWrite($sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotTimeBeforeRestart", $iDiscordBotNotifyTime)
	IniWrite($sIniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "UseTwitchBot", $sUseTwitchBot)
	IniWrite($sIniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "TwitchNick", $sTwitchNick)
	IniWrite($sIniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "ChatOAuth", $sChatOAuth)
	IniWrite($sIniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "TwitchChannels", $sTwitchChannels)
	IniWrite($sIniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "TwitchBotTimeBeforeRestart", $iTwitchBotNotifyTime)
	IniWrite($sIniFile, "Enable Building Damage by Scheduled Time? yes/no", "EnableBuildingDamageSchedule", $g_sEnableBuildingDmgSchedule)
	IniWrite($sIniFile, "Enable Building Damage by Scheduled Time? yes/no", "BuildingDmgEnabledSchedule", $g_sBuildingDmgEnabledTimes)
	IniWrite($sIniFile, "Enable Building Damage by Scheduled Time? yes/no", "FlipBuildingDmgSchedule", $g_sFlipBuildingDmgSchedule)
	IniWrite($sIniFile, "Disable Avatars by Scheduled Time? yes/no", "EnableAvatarSchedule", $g_sEnableAvatarSchedule)
	IniWrite($sIniFile, "Disable Avatars by Scheduled Time? yes/no", "AvatarsDisabledSchedule", $g_sAvatarsDisabledTimes)
	IniWrite($sIniFile, "Disable Avatars by Scheduled Time? yes/no", "FlipAvatarSchedule", $g_sFlipAvatarSchedule)
	IniWrite($sIniFile, "Bug Fix - Copy from then Delete Default Server Settings INI? yes/no", "IniOverwriteFix", $g_sIniOverwriteFix)
	IniWrite($sIniFile, "Extra Command Line Options. Leave Blank if Not Using", "ExtraServerCommands", $g_sExtraServerCommands)
	IniWrite($sIniFile, "Enable Debug to Output More Log Detail? yes/no", "EnableDebug", $g_sEnableDebug)
EndFunc   ;==>UpdateIni
#EndRegion ;**** INI Settings - User Variables ****