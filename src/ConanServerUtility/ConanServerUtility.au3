#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\resources\favicon.ico
#AutoIt3Wrapper_Outfile=..\..\build\ConanServerUtility_x86_v2.15.0.exe
#AutoIt3Wrapper_Outfile_x64=..\..\build\ConanServerUtility_x64_v2.15.0.exe
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=By Dateranoth - June 28, 2017
#AutoIt3Wrapper_Res_Description=Utility for Running Conan Server
#AutoIt3Wrapper_Res_Fileversion=2.15.0
#AutoIt3Wrapper_Res_LegalCopyright=Dateranoth @ https://gamercide.com
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;Originally written by Dateranoth for use
;by https://gamercide.com on their server
;Distributed Under GNU GENERAL PUBLIC LICENSE

#include <Date.au3>

#Region ;**** UnZip Function by trancexx ****
; #FUNCTION# ;===============================================================================
;
; Name...........: _ExtractZip
; Description ...: Extracts file/folder from ZIP compressed file
; Syntax.........: _ExtractZip($sZipFile, $sFolderStructure, $sFile, $sDestinationFolder)
; Parameters ....: $sZipFile - full path to the ZIP file to process
;                  $sFolderStructure - 'path' to the file/folder to extract inside ZIP file
;                  $sFile - file/folder to extract
;                  $sDestinationFolder - folder to extract to. Must exist.
; Return values .: Success - Returns 1
;                          - Sets @error to 0
;                  Failure - Returns 0 sets @error:
;                  |1 - Shell Object creation failure
;                  |2 - Destination folder is unavailable
;                  |3 - Structure within ZIP file is wrong
;                  |4 - Specified file/folder to extract not existing
; Author ........: trancexx
; https://www.autoitscript.com/forum/topic/101529-sunzippings-zipping/#comment-721866
;
;==========================================================================================
Func _ExtractZip($sZipFile, $sFolderStructure, $sFile, $sDestinationFolder)

	Local $i
	Do
		$i += 1
		$sTempZipFolder = @TempDir & "\Temporary Directory " & $i & " for " & StringRegExpReplace($sZipFile, ".*\\", "")
	Until Not FileExists($sTempZipFolder) ; this folder will be created during extraction

	Local $oShell = ObjCreate("Shell.Application")

	If Not IsObj($oShell) Then
		Return SetError(1, 0, 0) ; highly unlikely but could happen
	EndIf

	Local $oDestinationFolder = $oShell.NameSpace($sDestinationFolder)
	If Not IsObj($oDestinationFolder) Then
		Return SetError(2, 0, 0) ; unavailable destionation location
	EndIf

	Local $oOriginFolder = $oShell.NameSpace($sZipFile & "\" & $sFolderStructure) ; FolderStructure is overstatement because of the available depth
	If Not IsObj($oOriginFolder) Then
		Return SetError(3, 0, 0) ; unavailable location
	EndIf

	;Local $oOriginFile = $oOriginFolder.Items.Item($sFile)
	Local $oOriginFile = $oOriginFolder.ParseName($sFile)
	If Not IsObj($oOriginFile) Then
		Return SetError(4, 0, 0) ; no such file in ZIP file
	EndIf

	; copy content of origin to destination
	$oDestinationFolder.CopyHere($oOriginFile, 4) ; 4 means "do not display a progress dialog box", but apparently doesn't work

	DirRemove($sTempZipFolder, 1) ; clean temp dir

	Return 1 ; All OK!

EndFunc   ;==>_ExtractZip
#EndRegion ;**** UnZip Function by trancexx ****


#Region ;**** Global Variables ****
Global $g_sTimeCheck0 = _NowCalc()
Global $g_sTimeCheck1 = _NowCalc()
Global $g_sTimeCheck2 = _NowCalc()
Global $g_sTimeCheck3 = _NowCalc()
Global $g_sTimeCheck4 = _NowCalc()
Global Const $g_c_sServerEXE = "ConanSandboxServer-Win64-Test.exe"
Global Const $g_c_sPIDFile = @ScriptDir & "\ConanServerUtility_lastpid_tmp"
Global Const $g_c_sHwndFile = @ScriptDir & "\ConanServerUtility_lasthwnd_tmp"
Global Const $g_c_sMODIDFile = @ScriptDir & "\ConanServerUtility_modid2modname.ini"
Global Const $g_c_sLogFile = @ScriptDir & "\ConanServerUtility.log"
Global Const $g_c_sIniFile = @ScriptDir & "\ConanServerUtility.ini"
Global $g_iIniFail = 0
Global $g_iBeginDelayedShutdown = 0
Global $g_iDelayShutdownTime = 0
Global $g_sServerSettingIniLoc = "\ConanSandbox\saved\Config\WindowsServer\ServerSettings.ini"

If FileExists($g_c_sPIDFile) Then
	Global $g_sConanPID = FileRead($g_c_sPIDFile)
Else
	Global $g_sConanPID = "0"
EndIf
If FileExists($g_c_sHwndFile) Then
	Global $g_hConanhWnd = HWnd(FileRead($g_c_sHwndFile))
Else
	Global $g_hConanhWnd = "0"
EndIf
#EndRegion ;**** Global Variables ****



#Region ;**** INI Settings - User Variables ****
Func ReadUini()
	Local $iniCheck = ""
	Local $aChar[3]
	For $i = 1 To 13
		$aChar[0] = Chr(Random(97, 122, 1)) ;a-z
		$aChar[1] = Chr(Random(48, 57, 1)) ;0-9
		$iniCheck &= $aChar[Random(0, 1, 1)]
	Next

	Global $BindIP = IniRead($g_c_sIniFile, "Use MULTIHOME to Bind IP? Disable if having connection issues (yes/no)", "BindIP", $iniCheck)
	Global $g_IP = IniRead($g_c_sIniFile, "Game Server IP", "ListenIP", $iniCheck)
	Global $GamePort = IniRead($g_c_sIniFile, "Game Server Port", "GamePort", $iniCheck)
	Global $QueryPort = IniRead($g_c_sIniFile, "Steam Query Port", "QueryPort", $iniCheck)
	Global $ServerName = IniRead($g_c_sIniFile, "Server Name", "ServerName", $iniCheck)
	Global $ServerPass = IniRead($g_c_sIniFile, "Server Password", "ServerPass", $iniCheck)
	Global $AdminPass = IniRead($g_c_sIniFile, "Admin Password", "AdminPass", $iniCheck)
	Global $MaxPlayers = IniRead($g_c_sIniFile, "Max Players", "MaxPlayers", $iniCheck)
	Global $serverdir = IniRead($g_c_sIniFile, "Server Directory. NO TRAILING SLASH", "serverdir", $iniCheck)
	Global $UseSteamCMD = IniRead($g_c_sIniFile, "Use SteamCMD To Update Server? yes/no", "UseSteamCMD", $iniCheck)
	Global $steamcmddir = IniRead($g_c_sIniFile, "SteamCMD Directory. NO TRAILING SLASH", "steamcmddir", $iniCheck)
	Global $validategame = IniRead($g_c_sIniFile, "Validate Files Every Time SteamCMD Runs? yes/no", "validategame", $iniCheck)
	Global $UseRemoteRestart = IniRead($g_c_sIniFile, "Use Remote Restart ?yes/no", "UseRemoteRestart", $iniCheck)
	Global $g_Port = IniRead($g_c_sIniFile, "Remote Restart Port", "ListenPort", $iniCheck)
	Global $RestartCode = IniRead($g_c_sIniFile, "Remote Restart Password", "RestartCode", $iniCheck)
	Global $sObfuscatePass = IniRead($g_c_sIniFile, "Hide Passwords in Log? yes/no", "ObfuscatePass", $iniCheck)
	Global $CheckForUpdate = IniRead($g_c_sIniFile, "Check for Update Every X Minutes? yes/no", "CheckForUpdate", $iniCheck)
	Global $UpdateInterval = IniRead($g_c_sIniFile, "Update Check Interval in Minutes 05-59", "UpdateInterval", $iniCheck)
	Global $g_sUpdateMods = IniRead($g_c_sIniFile, "Install Mods and Check for Update? yes/no", "CheckForModUpdate", $iniCheck)
	Global $g_sMods = IniRead($g_c_sIniFile, "Install Mods and Check for Update? yes/no", "ModList", $iniCheck)
	Global $RestartDaily = IniRead($g_c_sIniFile, "Restart Server Daily? yes/no", "RestartDaily", $iniCheck)
	Global $HotHour1 = IniRead($g_c_sIniFile, "Daily Restart Hours? 00-23", "HotHour1", $iniCheck)
	Global $HotHour2 = IniRead($g_c_sIniFile, "Daily Restart Hours? 00-23", "HotHour2", $iniCheck)
	Global $HotHour3 = IniRead($g_c_sIniFile, "Daily Restart Hours? 00-23", "HotHour3", $iniCheck)
	Global $HotHour4 = IniRead($g_c_sIniFile, "Daily Restart Hours? 00-23", "HotHour4", $iniCheck)
	Global $HotHour5 = IniRead($g_c_sIniFile, "Daily Restart Hours? 00-23", "HotHour5", $iniCheck)
	Global $HotHour6 = IniRead($g_c_sIniFile, "Daily Restart Hours? 00-23", "HotHour6", $iniCheck)
	Global $HotMin = IniRead($g_c_sIniFile, "Daily Restart Minute? 00-59", "HotMin", $iniCheck)
	Global $ExMem = IniRead($g_c_sIniFile, "Excessive Memory Amount?", "ExMem", $iniCheck)
	Global $ExMemRestart = IniRead($g_c_sIniFile, "Restart On Excessive Memory Use? yes/no", "ExMemRestart", $iniCheck)
	Global $SteamFix = IniRead($g_c_sIniFile, "Running Server with Steam Open? (yes/no)", "SteamFix", $iniCheck)
	Global $logRotate = IniRead($g_c_sIniFile, "Rotate X Number of Logs every X Hours? yes/no", "logRotate", $iniCheck)
	Global $logQuantity = IniRead($g_c_sIniFile, "Rotate X Number of Logs every X Hours? yes/no", "logQuantity", $iniCheck)
	Global $logHoursBetweenRotate = IniRead($g_c_sIniFile, "Rotate X Number of Logs every X Hours? yes/no", "logHoursBetweenRotate", $iniCheck)
	Global $sUseDiscordBot = IniRead($g_c_sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "UseDiscordBot", $iniCheck)
	Global $sDiscordWebHookURLs = IniRead($g_c_sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordWebHookURL", $iniCheck)
	Global $sDiscordBotName = IniRead($g_c_sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotName", $iniCheck)
	Global $bDiscordBotUseTTS = IniRead($g_c_sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotUseTTS", $iniCheck)
	Global $sDiscordBotAvatar = IniRead($g_c_sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotAvatarLink", $iniCheck)
	Global $iDiscordBotNotifyTime = IniRead($g_c_sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotTimeBeforeRestart", $iniCheck)
	Global $sUseTwitchBot = IniRead($g_c_sIniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "UseTwitchBot", $iniCheck)
	Global $sTwitchNick = IniRead($g_c_sIniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "TwitchNick", $iniCheck)
	Global $sChatOAuth = IniRead($g_c_sIniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "ChatOAuth", $iniCheck)
	Global $sTwitchChannels = IniRead($g_c_sIniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "TwitchChannels", $iniCheck)
	Global $iTwitchBotNotifyTime = IniRead($g_c_sIniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "TwitchBotTimeBeforeRestart", $iniCheck)
	Global $g_sEnableBuildingDmgSchedule = IniRead($g_c_sIniFile, "Enable Building Damage by Scheduled Time? yes/no", "EnableBuildingDamageSchedule", $iniCheck)
	Global $g_sBuildingDmgEnabledTimes = IniRead($g_c_sIniFile, "Enable Building Damage by Scheduled Time? yes/no", "BuildingDmgEnabledSchedule", $iniCheck)
	Global $g_sFlipBuildingDmgSchedule = IniRead($g_c_sIniFile, "Enable Building Damage by Scheduled Time? yes/no", "FlipBuildingDmgSchedule", $iniCheck)
	Global $g_sEnableAvatarSchedule = IniRead($g_c_sIniFile, "Disable Avatars by Scheduled Time? yes/no", "EnableAvatarSchedule", $iniCheck)
	Global $g_sAvatarsDisabledTimes = IniRead($g_c_sIniFile, "Disable Avatars by Scheduled Time? yes/no", "AvatarsDisabledSchedule", $iniCheck)
	Global $g_sFlipAvatarSchedule = IniRead($g_c_sIniFile, "Disable Avatars by Scheduled Time? yes/no", "FlipAvatarSchedule", $iniCheck)
	Global $g_sIniOverwriteFix = IniRead($g_c_sIniFile, "Bug Fix - Copy from then Delete Default Server Settings INI? yes/no", "IniOverwriteFix", $iniCheck)

	If $iniCheck = $BindIP Then
		$BindIP = "yes"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $g_IP Then
		$g_IP = "127.0.0.1"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $GamePort Then
		$GamePort = "7777"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $QueryPort Then
		$QueryPort = "27015"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $ServerName Then
		$ServerName = "Conan Server Utility Server"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $ServerPass Then
		$ServerPass = ""
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $AdminPass Then
		$AdminPass &= "_noHASHsymbol"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $MaxPlayers Then
		$MaxPlayers = "20"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $serverdir Then
		$serverdir = "C:\Game_Servers\Conan_Exiles_Server"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $UseSteamCMD Then
		$UseSteamCMD = "yes"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $steamcmddir Then
		$steamcmddir = "C:\Game_Servers\SteamCMD"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $validategame Then
		$validategame = "no"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $UseRemoteRestart Then
		$UseRemoteRestart = "no"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $g_Port Then
		$g_Port = "57520"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $RestartCode Then
		$RestartCode = "Admin1_" & $RestartCode
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $sObfuscatePass Then
		$sObfuscatePass = "yes"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $CheckForUpdate Then
		$CheckForUpdate = "yes"
		$g_iIniFail += 1
	ElseIf $CheckForUpdate = "yes" And $UseSteamCMD <> "yes" Then
		$CheckForUpdate = "no"
		FileWriteLine($g_c_sLogFile, _NowCalc() & " SteamCMD disabled. Disabling CheckForUpdate. Update will not work without SteamCMD to update it!")
	EndIf
	If $iniCheck = $UpdateInterval Then
		$UpdateInterval = "15"
		$g_iIniFail += 1
	ElseIf $UpdateInterval < 5 Then
		$UpdateInterval = 5
	EndIf
	If $iniCheck = $g_sUpdateMods Then
		$g_sUpdateMods = "no"
		$g_iIniFail += 1
	ElseIf $g_sUpdateMods = "yes" And $CheckForUpdate <> "yes" Then
		$g_sUpdateMods = "no"
		FileWriteLine($g_c_sLogFile, _NowCalc() & " Server Update Check is Disabled. Disabling Mod Updates. Does not make sense to update Mods and Not Server!")
	EndIf
	If $iniCheck = $g_sMods Then
		$g_sMods = "#########,#########"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $RestartDaily Then
		$RestartDaily = "no"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $HotHour1 Then
		$HotHour1 = "00"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $HotHour2 Then
		$HotHour2 = "00"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $HotHour3 Then
		$HotHour3 = "00"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $HotHour4 Then
		$HotHour4 = "00"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $HotHour5 Then
		$HotHour5 = "00"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $HotHour6 Then
		$HotHour6 = "00"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $HotMin Then
		$HotMin = "01"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $ExMem Then
		$ExMem = "6000000000"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $ExMemRestart Then
		$ExMemRestart = "no"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $SteamFix Then
		$SteamFix = "no"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $logRotate Then
		$logRotate = "yes"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $logQuantity Then
		$logQuantity = "10"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $logHoursBetweenRotate Then
		$logHoursBetweenRotate = "24"
		$g_iIniFail += 1
	ElseIf $logHoursBetweenRotate < 1 Then
		$logHoursBetweenRotate = 1
	EndIf
	If $iniCheck = $sUseDiscordBot Then
		$sUseDiscordBot = "no"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $sDiscordWebHookURLs Then
		$sDiscordWebHookURLs = "https://discordapp.com/api/webhooks/XXXXXX/XXXX <- NO TRAILING SLASH AND USE FULL URL FROM WEBHOOK URL ON DISCORD"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $sDiscordBotName Then
		$sDiscordBotName = "Conan Exiles Discord Bot"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $bDiscordBotUseTTS Then
		$bDiscordBotUseTTS = "yes"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $sDiscordBotAvatar Then
		$sDiscordBotAvatar = ""
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $iDiscordBotNotifyTime Then
		$iDiscordBotNotifyTime = "5"
		$g_iIniFail += 1
	ElseIf $iDiscordBotNotifyTime < 1 Then
		$iDiscordBotNotifyTime = 1
	EndIf
	If $iniCheck = $sUseTwitchBot Then
		$sUseTwitchBot = "no"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $sTwitchNick Then
		$sTwitchNick = "twitchbotusername"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $sChatOAuth Then
		$sChatOAuth = "oauth:1234 (Generate OAuth Token Here: https://twitchapps.com/tmi)"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $sTwitchChannels Then
		$sTwitchChannels = "channel1,channel2,channel3"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $iTwitchBotNotifyTime Then
		$iTwitchBotNotifyTime = "5"
		$g_iIniFail += 1
	ElseIf $iTwitchBotNotifyTime < 1 Then
		$iTwitchBotNotifyTime = 1
	EndIf
	If $iniCheck = $g_sEnableBuildingDmgSchedule Then
		$g_sEnableBuildingDmgSchedule = "no"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $g_sBuildingDmgEnabledTimes Then
		$g_sBuildingDmgEnabledTimes = "WDAY(Sunday1)-HHMMtoWDAY(Saturday7)-HHMM,1-0000to7-2359,6-2200to7-0500"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $g_sFlipBuildingDmgSchedule Then
		$g_sFlipBuildingDmgSchedule = "no"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $g_sEnableAvatarSchedule Then
		$g_sEnableAvatarSchedule = "no"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $g_sAvatarsDisabledTimes Then
		$g_sAvatarsDisabledTimes = "WDAY(Sunday1)-HHMMtoWDAY(Saturday7)-HHMM,1-0000to7-2359,6-2200to7-0500"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $g_sFlipAvatarSchedule Then
		$g_sFlipAvatarSchedule = "no"
		$g_iIniFail += 1
	EndIf
	If $iniCheck = $g_sIniOverwriteFix Then
		$g_sIniOverwriteFix = "yes"
		$g_iIniFail += 1
	EndIf
	If $g_iIniFail > 0 Then
		iniFileCheck()
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
EndFunc   ;==>ReadUini

Func iniFileCheck()
	If FileExists($g_c_sIniFile) Then
		Local $aMyDate, $aMyTime
		_DateTimeSplit(_NowCalc(), $aMyDate, $aMyTime)
		Local $iniDate = StringFormat("%04i.%02i.%02i.%02i%02i", $aMyDate[1], $aMyDate[2], $aMyDate[3], $aMyTime[1], $aMyTime[2])
		FileMove($g_c_sIniFile, $g_c_sIniFile & "_" & $iniDate & ".bak", 1)
		UpdateIni()
		MsgBox(4096, "INI MISMATCH", "Found " & $g_iIniFail & " Missing Variables" & @CRLF & @CRLF & "Backup created and all existing settings transfered to new INI." & @CRLF & @CRLF & "Modify INI and restart.")
		Exit
	Else
		UpdateIni()
		MsgBox(4096, "Default INI File Made", "Please Modify Default Values and Restart Script")
		Exit
	EndIf
EndFunc   ;==>iniFileCheck

Func UpdateIni()
	IniWrite($g_c_sIniFile, "Use MULTIHOME to Bind IP? Disable if having connection issues (yes/no)", "BindIP", $BindIP)
	IniWrite($g_c_sIniFile, "Game Server IP", "ListenIP", $g_IP)
	IniWrite($g_c_sIniFile, "Game Server Port", "GamePort", $GamePort)
	IniWrite($g_c_sIniFile, "Steam Query Port", "QueryPort", $QueryPort)
	IniWrite($g_c_sIniFile, "Server Name", "ServerName", $ServerName)
	IniWrite($g_c_sIniFile, "Server Password", "ServerPass", $ServerPass)
	IniWrite($g_c_sIniFile, "Admin Password", "AdminPass", $AdminPass)
	IniWrite($g_c_sIniFile, "Max Players", "MaxPlayers", $MaxPlayers)
	IniWrite($g_c_sIniFile, "Server Directory. NO TRAILING SLASH", "serverdir", $serverdir)
	IniWrite($g_c_sIniFile, "Use SteamCMD To Update Server? yes/no", "UseSteamCMD", $UseSteamCMD)
	IniWrite($g_c_sIniFile, "SteamCMD Directory. NO TRAILING SLASH", "steamcmddir", $steamcmddir)
	IniWrite($g_c_sIniFile, "Validate Files Every Time SteamCMD Runs? yes/no", "validategame", $validategame)
	IniWrite($g_c_sIniFile, "Use Remote Restart ?yes/no", "UseRemoteRestart", $UseRemoteRestart)
	IniWrite($g_c_sIniFile, "Remote Restart Port", "ListenPort", $g_Port)
	IniWrite($g_c_sIniFile, "Remote Restart Password", "RestartCode", $RestartCode)
	IniWrite($g_c_sIniFile, "Hide Passwords in Log? yes/no", "ObfuscatePass", $sObfuscatePass)
	IniWrite($g_c_sIniFile, "Check for Update Every X Minutes? yes/no", "CheckForUpdate", $CheckForUpdate)
	IniWrite($g_c_sIniFile, "Update Check Interval in Minutes 05-59", "UpdateInterval", $UpdateInterval)
	IniWrite($g_c_sIniFile, "Install Mods and Check for Update? yes/no", "CheckForModUpdate", $g_sUpdateMods)
	IniWrite($g_c_sIniFile, "Install Mods and Check for Update? yes/no", "ModList", $g_sMods)
	IniWrite($g_c_sIniFile, "Restart Server Daily? yes/no", "RestartDaily", $RestartDaily)
	IniWrite($g_c_sIniFile, "Daily Restart Hours? 00-23", "HotHour1", $HotHour1)
	IniWrite($g_c_sIniFile, "Daily Restart Hours? 00-23", "HotHour2", $HotHour2)
	IniWrite($g_c_sIniFile, "Daily Restart Hours? 00-23", "HotHour3", $HotHour3)
	IniWrite($g_c_sIniFile, "Daily Restart Hours? 00-23", "HotHour4", $HotHour4)
	IniWrite($g_c_sIniFile, "Daily Restart Hours? 00-23", "HotHour5", $HotHour5)
	IniWrite($g_c_sIniFile, "Daily Restart Hours? 00-23", "HotHour6", $HotHour6)
	IniWrite($g_c_sIniFile, "Daily Restart Minute? 00-59", "HotMin", $HotMin)
	IniWrite($g_c_sIniFile, "Excessive Memory Amount?", "ExMem", $ExMem)
	IniWrite($g_c_sIniFile, "Restart On Excessive Memory Use? yes/no", "ExMemRestart", $ExMemRestart)
	IniWrite($g_c_sIniFile, "Running Server with Steam Open? (yes/no)", "SteamFix", $SteamFix)
	IniWrite($g_c_sIniFile, "Rotate X Number of Logs every X Hours? yes/no", "logRotate", $logRotate)
	IniWrite($g_c_sIniFile, "Rotate X Number of Logs every X Hours? yes/no", "logQuantity", $logQuantity)
	IniWrite($g_c_sIniFile, "Rotate X Number of Logs every X Hours? yes/no", "logHoursBetweenRotate", $logHoursBetweenRotate)
	IniWrite($g_c_sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "UseDiscordBot", $sUseDiscordBot)
	IniWrite($g_c_sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordWebHookURL", $sDiscordWebHookURLs)
	IniWrite($g_c_sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotName", $sDiscordBotName)
	IniWrite($g_c_sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotUseTTS", $bDiscordBotUseTTS)
	IniWrite($g_c_sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotAvatarLink", $sDiscordBotAvatar)
	IniWrite($g_c_sIniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotTimeBeforeRestart", $iDiscordBotNotifyTime)
	IniWrite($g_c_sIniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "UseTwitchBot", $sUseTwitchBot)
	IniWrite($g_c_sIniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "TwitchNick", $sTwitchNick)
	IniWrite($g_c_sIniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "ChatOAuth", $sChatOAuth)
	IniWrite($g_c_sIniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "TwitchChannels", $sTwitchChannels)
	IniWrite($g_c_sIniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "TwitchBotTimeBeforeRestart", $iTwitchBotNotifyTime)
	IniWrite($g_c_sIniFile, "Enable Building Damage by Scheduled Time? yes/no", "EnableBuildingDamageSchedule", $g_sEnableBuildingDmgSchedule)
	IniWrite($g_c_sIniFile, "Enable Building Damage by Scheduled Time? yes/no", "BuildingDmgEnabledSchedule", $g_sBuildingDmgEnabledTimes)
	IniWrite($g_c_sIniFile, "Enable Building Damage by Scheduled Time? yes/no", "FlipBuildingDmgSchedule", $g_sFlipBuildingDmgSchedule)
	IniWrite($g_c_sIniFile, "Disable Avatars by Scheduled Time? yes/no", "EnableAvatarSchedule", $g_sEnableAvatarSchedule)
	IniWrite($g_c_sIniFile, "Disable Avatars by Scheduled Time? yes/no", "AvatarsDisabledSchedule", $g_sAvatarsDisabledTimes)
	IniWrite($g_c_sIniFile, "Disable Avatars by Scheduled Time? yes/no", "FlipAvatarSchedule", $g_sFlipAvatarSchedule)
	IniWrite($g_c_sIniFile, "Bug Fix - Copy from then Delete Default Server Settings INI? yes/no", "IniOverwriteFix", $g_sIniOverwriteFix)
EndFunc   ;==>UpdateIni
#EndRegion ;**** INI Settings - User Variables ****

Func Gamercide()
	If @exitMethod <> 1 Then
		$Shutdown = MsgBox(4100, "Shut Down?", "Do you wish to shutdown Server " & $ServerName & "? (PID: " & $g_sConanPID & ")", 60)
		If $Shutdown = 6 Then
			FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Server Shutdown - Intiated by User when closing ConanServerUtility Script")
			CloseServer()
		EndIf
		MsgBox(4096, "Thanks for using our Application", "Please visit us at https://gamercide.com", 2)
		FileWriteLine($g_c_sLogFile, _NowCalc() & " ConanServerUtility Stopped by User")
	Else
		FileWriteLine($g_c_sLogFile, _NowCalc() & " ConanServerUtility Stopped")
	EndIf
	If $UseRemoteRestart = "yes" Then
		TCPShutdown()
	EndIf
	Exit
EndFunc   ;==>Gamercide

Func CloseServer()
	If WinExists($g_hConanhWnd) Then
		ControlSend($g_hConanhWnd, "", "", "I" & @CR)
		ControlSend($g_hConanhWnd, "", "", "I" & @CR)
		ControlSend($g_hConanhWnd, "", "", "^C")
		FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Server Window Found - Sending Ctrl+C for Clean Shutdown")
		WinWaitClose($g_hConanhWnd, "", 60)
	EndIf
	If ProcessExists($g_sConanPID) Then
		FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Server Did not Shut Down Properly. Killing Process")
		ProcessClose($g_sConanPID)
	EndIf
	If FileExists($g_c_sPIDFile) Then
		FileDelete($g_c_sPIDFile)
	EndIf
	If FileExists($g_c_sHwndFile) Then
		FileDelete($g_c_sHwndFile)
	EndIf
EndFunc   ;==>CloseServer

Func LogWrite($sString)
	FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] " & $sString)
EndFunc   ;==>LogWrite

Func RotateFile($sFile, $sBackupQty, $bDelOrig = True) ;Pass File to Rotate and Quantity of Files to Keep for backup. Optionally Keep Original.
	Local $hCreateTime = @YEAR & @MON & @MDAY
	For $i = $sBackupQty To 1 Step -1
		If FileExists($sFile & $i) Then
			$hCreateTime = FileGetTime($sFile & $i, 1)
			FileMove($sFile & $i, $sFile & ($i + 1), 1)
			FileSetTime($sFile & ($i + 1), $hCreateTime, 1)
		EndIf
	Next
	If FileExists($sFile & ($sBackupQty + 1)) Then
		FileDelete($sFile & ($sBackupQty + 1))
	EndIf
	If FileExists($sFile) Then
		If $bDelOrig = True Then
			$hCreateTime = FileGetTime($sFile, 1)
			FileMove($sFile, $sFile & "1", 1)
			FileWriteLine($sFile, _NowCalc() & $sFile & " Rotated")
			FileSetTime($sFile & "1", $hCreateTime, 1)
			FileSetTime($sFile, @YEAR & @MON & @MDAY, 1)
		Else
			FileCopy($sFile, $sFile & "1", 1)
		EndIf
	EndIf
EndFunc   ;==>RotateFile

#Region ;**** Change Server Settings by Time and Day ****
Func CheckRange($sTimeSpan) ;Input Format WDAY-HHMMtoWDAY-HHMM <-Multiple Time ranges should be comma seperated
	Local $aReturn[3] = [False, True, ""]
	Local $aStartStop = StringSplit($sTimeSpan, ",")
	For $i = 1 To $aStartStop[0]
		$aStartStop[$i] = StringStripWS($aStartStop[$i], 8)
		If StringRegExp($aStartStop[$i], '^[0-7]-([01]\d|2[0-3])([0-5]\d)to[0-7]-([01]\d|2[0-3])([0-5]\d)$') Then
			Local $iTime = @HOUR & @MIN
			Local $aDayHourMinute = StringSplit($aStartStop[$i], "to", 1)
			Local $aStart = StringSplit($aDayHourMinute[1], "-")
			Local $aStop = StringSplit($aDayHourMinute[2], "-")
			If (($aStart[1] = "0") Or ($aStop[1] = "0")) And ($aStart[1] <> $aStop[1]) Then
				$aReturn[0] = False ;Return False - Not Currently within Date Range
				$aReturn[1] = False ;Return False - Incorrect String Format
				$aReturn[2] = $aStartStop[$i] ;Return Bad String
				ExitLoop
			ElseIf (($aStart[1] = "0") Or ($aStop[1] = "0")) And ($iTime >= $aStart[2]) And ($iTime <= $aStop[2]) Then
				$aReturn[0] = True ;Return True - Start and Stop Day set to Everyday '0', and it is currently within the time range
				ExitLoop
			ElseIf ($aStart[1] = $aStop[1]) And (((@WDAY = $aStart[1]) Or (@WDAY = $aStop[1])) And ($iTime >= $aStart[2]) And ($iTime <= $aStop[2])) Then
				$aReturn[0] = True ;Return True - Start Day is equal to Stop Day which is equal to Today, and it is currently within the time range
				ExitLoop
			ElseIf ($aStop[1] > $aStart[1]) And ((@WDAY > $aStart[1]) And (@WDAY < $aStop[1])) Then
				$aReturn[0] = True ;Return True - Start Day is less than Stop Day, and it is currently a day between those days.
				ExitLoop
			ElseIf ($aStop[1] < $aStart[1]) And ((@WDAY > $aStart[1]) Or (@WDAY < $aStop[1])) Then
				$aReturn[0] = True ;Return True - Start Day is Greater than Stop day, and it is currently a day between those days.
				ExitLoop
			ElseIf ($aStop[1] <> $aStart[1]) And ((@WDAY = $aStart[1] And $iTime >= $aStart[2]) Or (@WDAY = $aStop[1] And $iTime <= $aStop[2])) Then
				$aReturn[0] = True ;Return True - Start Day is not equal to Stop Day. However, one of those days is today and we are within the time range.
				ExitLoop
			Else
				$aReturn[0] = False ;Return False - Not Currently within Date Range
			EndIf
		Else
			$aReturn[1] = False ;Return False - Incorrect String Format
			$aReturn[2] = $aStartStop[$i] ;Return Bad String
			ExitLoop
		EndIf
	Next
	Return $aReturn
EndFunc   ;==>CheckRange

Func ChangeSetting($sINI, $sSection, $sKey, $sValue)
	$bReturn = False
	If FileExists($sINI) Then
		RotateFile($sINI, 4, False)
		IniWrite($sINI, $sSection, $sKey, $sValue)
		$bReturn = True
	Else
		$bReturn = False
	EndIf
	Return $bReturn
EndFunc   ;==>ChangeSetting

Func DeleteDefaultINI()
	Local $sINI = $serverdir & $g_sServerSettingIniLoc
	Local $sDefaultIni = $serverdir & "\ConanSandbox\Config\DefaultServerSettings.ini"
	If FileExists($sDefaultIni) Then
		RotateFile($sDefaultIni, 2, False)
		RotateFile($sINI, 4, False)
		Local $aDefaultIni = IniReadSection($sDefaultIni, "ServerSettings")
		If Not @error Then
			For $i = 1 To $aDefaultIni[0][0]
				Local $sCurrentValue = IniRead($sINI, "ServerSettings", $aDefaultIni[$i][0], "")
				If $sCurrentValue = "" Then
					IniWrite($sINI, "ServerSettings", $aDefaultIni[$i][0], $aDefaultIni[$i][1])
				EndIf
			Next
			FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & "] Copied any missing Keys from Default Server Settings to Runtime Server Settings.")
		EndIf
		FileDelete($sDefaultIni)
		FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & "] Backed up and Deleted " & $sDefaultIni)
	EndIf
EndFunc   ;==>DeleteDefaultINI

Func CheckSetting($sTimesAllowed, $sCheckINI, $sCheckSec, $sCheckKey, $bFlipSetting = False)
	Local $aReturn[3] = [False, False, False] ;In Range? Restart Needed? Setting Changed?
	Local $aInRange = CheckRange($sTimesAllowed)
	If $aInRange[1] Then
		If $bFlipSetting Then
			Local $sValforEnabled = "False"
			Local $sValforDisabled = "True"
			$aReturn[0] = True ;Flip Setting on. Make sure we notify the correct Change.
		Else
			Local $sValforEnabled = "True"
			Local $sValforDisabled = "False"
		EndIf

		Local $sCurrentSetting = IniRead($sCheckINI, $sCheckSec, $sCheckKey, "True")
		If $aInRange[0] And $sCurrentSetting = $sValforDisabled Then
			If $bFlipSetting Then
				$aReturn[0] = False ;In Range but Flip Setting True
			Else
				$aReturn[0] = True ;In Range
			EndIf
			If ProcessExists($g_sConanPID) Then
				$aReturn[1] = True ;Restart Needed
			Else
				Local $bSettingChanged = ChangeSetting($sCheckINI, $sCheckSec, $sCheckKey, $sValforEnabled)
				If $bSettingChanged Then
					$aReturn[2] = True ;Setting Changed
				EndIf
			EndIf
		ElseIf Not $aInRange[0] And $sCurrentSetting = $sValforEnabled Then
			If ProcessExists($g_sConanPID) Then
				$aReturn[1] = True ;Restart Needed
			Else
				Local $bSettingChanged = ChangeSetting($sCheckINI, $sCheckSec, $sCheckKey, $sValforDisabled)
				If $bSettingChanged Then
					$aReturn[2] = True ;Setting Changed
				EndIf
			EndIf
		EndIf
	Else
		FileWriteLine($g_c_sLogFile, _NowCalc() & "[" & $ServerName & "] [TIME FORMAT ERROR] Date Format Wrong. This was entered[ " & $aInRange[2] & " ]Proper Format is WDAY-HHMMtoWDAY-HHMM  (Sunday=1 Saturday=7 Everyday=0) It is currently " & @WDAY & "-" & @HOUR & @MIN & @CRLF)
	EndIf
	Return $aReturn
EndFunc   ;==>CheckSetting

Func RaidCheck($bFlipSetting = False)
	Local $sServerSettingsFile = $serverdir & $g_sServerSettingIniLoc
	Local $aRaidCheck = CheckSetting($g_sBuildingDmgEnabledTimes, $sServerSettingsFile, "ServerSettings", "CanDamagePlayerOwnedStructures", $bFlipSetting)
	If $aRaidCheck[1] Then ;Restart Needed
		If (($sUseDiscordBot = "yes") Or ($sUseTwitchBot = "yes")) Then
			$g_iBeginDelayedShutdown = 1
		Else
			CloseServer()
		EndIf
	ElseIf $aRaidCheck[0] And $aRaidCheck[2] Then ;In Time Range and Setting Changed to True
		FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & "] Player Owned Structure Damage Enabled!")
		Local $sMessage = $ServerName & " Player Owned Structures Can be Damaged!"
		If $sUseDiscordBot = "yes" Then
			SendDiscordMsg($sDiscordWebHookURLs, $sMessage, $sDiscordBotName, $bDiscordBotUseTTS, $sDiscordBotAvatar)
		EndIf
		If $sUseTwitchBot = "yes" Then
			TwitchMsgLog($sMessage)
		EndIf
	ElseIf Not $aRaidCheck[0] And $aRaidCheck[2] Then ;Not In Time Range and Setting Changed to False
		FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & "] Player Owned Structure Damage Disabled!")
		Local $sMessage = $ServerName & " Player Owned Structures Can NOT be Damaged!"
		If $sUseDiscordBot = "yes" Then
			SendDiscordMsg($sDiscordWebHookURLs, $sMessage, $sDiscordBotName, $bDiscordBotUseTTS, $sDiscordBotAvatar)
		EndIf
		If $sUseTwitchBot = "yes" Then
			TwitchMsgLog($sMessage)
		EndIf
	EndIf
EndFunc   ;==>RaidCheck

Func AvatarCheck($bFlipSetting = False)
	Local $sServerSettingsFile = $serverdir & $g_sServerSettingIniLoc
	Local $aAvatarCheck = CheckSetting($g_sAvatarsDisabledTimes, $sServerSettingsFile, "ServerSettings", "AvatarsDisabled", $bFlipSetting)
	If $aAvatarCheck[1] Then ;Restart Needed
		If (($sUseDiscordBot = "yes") Or ($sUseTwitchBot = "yes")) Then
			$g_iBeginDelayedShutdown = 1
		Else
			CloseServer()
		EndIf
	ElseIf $aAvatarCheck[0] And $aAvatarCheck[2] Then ;In Time Range and Setting Changed to True
		FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & "] Avatars Disabled!")
		Local $sMessage = $ServerName & " Avatars are now Disabled!"
		If $sUseDiscordBot = "yes" Then
			SendDiscordMsg($sDiscordWebHookURLs, $sMessage, $sDiscordBotName, $bDiscordBotUseTTS, $sDiscordBotAvatar)
		EndIf
		If $sUseTwitchBot = "yes" Then
			TwitchMsgLog($sMessage)
		EndIf
	ElseIf Not $aAvatarCheck[0] And $aAvatarCheck[2] Then ;Not In Time Range and Setting Changed to False
		FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & "] Avatars Enabled!")
		Local $sMessage = $ServerName & " Avatars are now Enabled!"
		If $sUseDiscordBot = "yes" Then
			SendDiscordMsg($sDiscordWebHookURLs, $sMessage, $sDiscordBotName, $bDiscordBotUseTTS, $sDiscordBotAvatar)
		EndIf
		If $sUseTwitchBot = "yes" Then
			TwitchMsgLog($sMessage)
		EndIf
	EndIf
EndFunc   ;==>AvatarCheck

#EndRegion ;**** Change Server Settings by Time and Day ****

#Region ;**** Function to Send Message to Discord ****
Func _Discord_ErrFunc($oError)
	FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Error: 0x" & Hex($oError.number) & " While Sending Discord Bot Message.")
EndFunc   ;==>_Discord_ErrFunc

Func SendDiscordMsg($sHookURLs, $sBotMessage, $sBotName = "", $sBotTTS = False, $sBotAvatar = "")
	Local $oErrorHandler = ObjEvent("AutoIt.Error", "_Discord_ErrFunc")
	Local $sJsonMessage = '{"content" : "' & $sBotMessage & '", "username" : "' & $sBotName & '", "tts" : "' & $sBotTTS & '", "avatar_url" : "' & $sBotAvatar & '"}'
	Local $oHTTPOST = ObjCreate("WinHttp.WinHttpRequest.5.1")
	Local $aHookURLs = StringSplit($sHookURLs, ",")
	For $i = 1 To $aHookURLs[0]
		$oHTTPOST.Open("POST", StringStripWS($aHookURLs[$i], 2) & "?wait=true", False)
		$oHTTPOST.SetRequestHeader("Content-Type", "application/json")
		$oHTTPOST.Send($sJsonMessage)
		Local $oStatusCode = $oHTTPOST.Status
		Local $oResponseText = $oHTTPOST.ResponseText
		FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] [Discord Bot] Message Status Code {" & $oStatusCode & "} Message Response " & $oResponseText)
	Next
EndFunc   ;==>SendDiscordMsg
#EndRegion ;**** Function to Send Message to Discord ****

#Region ;**** Post to Twitch Chat Function ****
Opt("TCPTimeout", 500)
Func SendTwitchMsg($sT_Nick, $sT_OAuth, $sT_Channels, $sT_Message)
	Local $aTwitchReturn[4] = [False, False, "", False]
	Local $sTwitchIRC = TCPConnect(TCPNameToIP("irc.chat.twitch.tv"), 6667)
	If @error Then
		TCPCloseSocket($sTwitchIRC)
		Return $aTwitchReturn
	Else
		$aTwitchReturn[0] = True ;Successfully Connected to irc
		TCPSend($sTwitchIRC, "PASS " & StringLower($sT_OAuth) & @CRLF)
		TCPSend($sTwitchIRC, "NICK " & StringLower($sT_Nick) & @CRLF)
		Local $sTwitchReceive = ""
		Local $iTimer1 = TimerInit()
		While TimerDiff($iTimer1) < 1000
			$sTwitchReceive &= TCPRecv($sTwitchIRC, 1)
			If @error Then ExitLoop
		WEnd
		Local $aTwitchReceiveLines = StringSplit($sTwitchReceive, @CRLF, 1)
		$aTwitchReturn[2] = $aTwitchReceiveLines[1] ;Status Line. Accepted or Not
		If StringRegExp($aTwitchReceiveLines[$aTwitchReceiveLines[0] - 1], "(?i):tmi.twitch.tv 376 " & $sT_Nick & " :>") Then
			$aTwitchReturn[1] = True ;Username and OAuth was accepted. Ready for PRIVMSG
			Local $aTwitchChannels = StringSplit($sT_Channels, ",")
			For $i = 1 To $aTwitchChannels[0]
				TCPSend($sTwitchIRC, "PRIVMSG #" & StringLower($aTwitchChannels[$i]) & " :" & $sT_Message & @CRLF)
				If @error Then
					TCPCloseSocket($sTwitchIRC)
					$aTwitchReturn[3] = False ;Check that all channels succeeded or none
					Return $aTwitchReturn
					ExitLoop
				Else
					$aTwitchReturn[3] = True ;Check that all channels succeeded or none
					If $aTwitchChannels[0] > 17 Then ;This is to make sure we don't break the rate limit
						Sleep(1600)
					Else
						Sleep(100)
					EndIf
				EndIf
			Next
			TCPSend($sTwitchIRC, "QUIT")
			TCPCloseSocket($sTwitchIRC)
		Else
			Return $aTwitchReturn
		EndIf
	EndIf
	Return $aTwitchReturn
EndFunc   ;==>SendTwitchMsg

Func TwitchMsgLog($sT_Msg)
	Local $aTwitchIRC = SendTwitchMsg($sTwitchNick, $sChatOAuth, $sTwitchChannels, $sT_Msg)
	If $aTwitchIRC[0] Then
		FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] [Twitch Bot] Successfully Connected to Twitch IRC")
		If $aTwitchIRC[1] Then
			FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] [Twitch Bot] Username and OAuth Accepted. [" & $aTwitchIRC[2] & "]")
			If $aTwitchIRC[3] Then
				FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] [Twitch Bot] Successfully sent ( " & $sT_Msg & " ) to all Channels")
			Else
				FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] [Twitch Bot] ERROR | Failed sending message ( " & $sT_Msg & " ) to one or more channels")
			EndIf
		Else
			FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] [Twitch Bot] ERROR | Username and OAuth Denied [" & $aTwitchIRC[2] & "]")
		EndIf
	Else
		FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] [Twitch Bot] ERROR | Could not connect to Twitch IRC. Is this URL or port blocked? [irc.chat.twitch.tv:6667]")
	EndIf
EndFunc   ;==>TwitchMsgLog
#EndRegion ;**** Post to Twitch Chat Function ****

#Region ;**** Functions to Check for Update ****
Func GetLatestVersion($sCmdDir)
	Local $aReturn[2] = [False, ""]
	If FileExists($sCmdDir & "\appcache") Then
		DirRemove($sCmdDir & "\appcache", 1)
	EndIf
	RunWait('"' & @ComSpec & '" /c ' & $sCmdDir & '\steamcmd.exe +login anonymous +app_info_update 1 +app_info_print 443030 +app_info_print 443030 +exit > app_info.tmp', $sCmdDir, @SW_HIDE)
	Local Const $sFilePath = $sCmdDir & "\app_info.tmp"
	Local $hFileOpen = FileOpen($sFilePath, 0)
	If $hFileOpen = -1 Then
		$aReturn[0] = False
	Else
		Local $sFileRead = FileRead($hFileOpen)
		Local $aAppInfo = StringSplit($sFileRead, '"branches"', 1)

		If UBound($aAppInfo) >= 3 Then
			$aAppInfo = StringSplit($aAppInfo[2], "AppID", 1)
		EndIf
		If UBound($aAppInfo) >= 2 Then
			$aAppInfo = StringSplit($aAppInfo[1], "}", 1)
		EndIf
		If UBound($aAppInfo) >= 2 Then
			$aAppInfo = StringSplit($aAppInfo[1], '"', 1)
		EndIf
		If UBound($aAppInfo) >= 7 Then
			$aReturn[0] = True
			$aReturn[1] = $aAppInfo[6]
		EndIf
		FileClose($hFileOpen)
		If FileExists($sFilePath) Then
			FileDelete($sFilePath)
		EndIf
	EndIf
	Return $aReturn
EndFunc   ;==>GetLatestVersion

Func GetInstalledVersion($sGameDir)
	Local $aReturn[2] = [False, ""]
	Local Const $sFilePath = $sGameDir & "\steamapps\appmanifest_443030.acf"
	Local $hFileOpen = FileOpen($sFilePath, 0)
	If $hFileOpen = -1 Then
		$aReturn[0] = False
	Else
		Local $sFileRead = FileRead($hFileOpen)
		Local $aAppInfo = StringSplit($sFileRead, '"buildid"', 1)

		If UBound($aAppInfo) >= 3 Then
			$aAppInfo = StringSplit($aAppInfo[2], '"buildid"', 1)
		EndIf
		If UBound($aAppInfo) >= 2 Then
			$aAppInfo = StringSplit($aAppInfo[1], '"LastOwner"', 1)
		EndIf
		If UBound($aAppInfo) >= 2 Then
			$aAppInfo = StringSplit($aAppInfo[1], '"', 1)
		EndIf
		If UBound($aAppInfo) >= 2 Then
			$aReturn[0] = True
			$aReturn[1] = $aAppInfo[2]
		EndIf

		If FileExists($sFilePath) Then
			FileClose($hFileOpen)
		EndIf
	EndIf
	Return $aReturn
EndFunc   ;==>GetInstalledVersion

Func UpdateCheck()
	If FileExists($steamcmddir & "\app_info.tmp") Then
		FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Delaying Update Check for 1 minute. | Found Existing " & $steamcmddir & "\app_info.tmp")
		Sleep(60000)
		If FileExists($steamcmddir & "\app_info.tmp") Then
			FileDelete($steamcmddir & "\app_info.tmp")
			FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Deleted " & $steamcmddir & "\app_info.tmp")
		EndIf
	EndIf

	FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Update Check Starting.")
	Local $bUpdateRequired = False
	Local $aLatestVersion = GetLatestVersion($steamcmddir)
	Local $aInstalledVersion = GetInstalledVersion($serverdir)

	If ($aLatestVersion[0] And $aInstalledVersion[0]) Then
		If StringCompare($aLatestVersion[1], $aInstalledVersion[1]) = 0 Then
			FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Server is Up to Date. Version: " & $aInstalledVersion[1])
		Else
			FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Server is Out of Date! Installed Version: " & $aInstalledVersion[1] & " Latest Version: " & $aLatestVersion[1])
			$bUpdateRequired = True
		EndIf
	ElseIf Not $aLatestVersion[0] And Not $aInstalledVersion[0] Then
		FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Something went wrong retrieving Latest Version")
		FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Something went wrong retrieving Installed Version")
	ElseIf Not $aInstalledVersion[0] Then
		FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Something went wrong retrieving Installed Version")
	ElseIf Not $aLatestVersion[0] Then
		FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Something went wrong retrieving Latest Version")
	EndIf
	Return $bUpdateRequired
EndFunc   ;==>UpdateCheck
#EndRegion ;**** Functions to Check for Update ****

#Region ;**** Functions to Check for Mod Updates ****
Func GetLatestModUpdateTime($sMod)
	Local $aReturn[3] = [False, False, ""]
	InetGet("http://steamcommunity.com/sharedfiles/filedetails/changelog/" & $sMod, @ScriptDir & "\mod_info.tmp", 1)
	Local Const $sFilePath = @ScriptDir & "\mod_info.tmp"
	Local $hFileOpen = FileOpen($sFilePath, 0)
	If $hFileOpen = -1 Then
		$aReturn[0] = False
	Else
		$aReturn[0] = True ;File Exists
		Local $sFileRead = FileRead($hFileOpen)
		Local $aAppInfo = StringSplit($sFileRead, 'Update:', 1)
		If UBound($aAppInfo) >= 3 Then
			$aAppInfo = StringSplit($aAppInfo[2], '">', 1)
		EndIf
		If UBound($aAppInfo) >= 2 Then
			$aAppInfo = StringSplit($aAppInfo[1], 'id="', 1)
		EndIf
		If UBound($aAppInfo) >= 2 And StringRegExp($aAppInfo[2], '^\d+$') Then
			$aReturn[1] = True ;Successfully Read numerical value at positition expected
			$aReturn[2] = $aAppInfo[2] ;Return Value Read
		EndIf
		FileClose($hFileOpen)
		If FileExists($sFilePath) Then
			FileDelete($sFilePath)
		EndIf
	EndIf
	Return $aReturn
EndFunc   ;==>GetLatestModUpdateTime

Func GetInstalledModUpdateTime($sServerDir, $sMod)
	Local $aReturn[3] = [False, False, ""]
	Local Const $sFilePath = $sServerDir & "\steamapps\workshop\appworkshop_440900.acf"
	Local $hFileOpen = FileOpen($sFilePath, 0)
	If $hFileOpen = -1 Then
		$aReturn[0] = False
	Else
		$aReturn[0] = True ;File Exists
		Local $sFileRead = FileRead($hFileOpen)
		Local $aAppInfo = StringSplit($sFileRead, '"WorkshopItemDetails"', 1)
		If UBound($aAppInfo) >= 3 Then
			$aAppInfo = StringSplit($aAppInfo[2], '"' & $sMod & '"', 1)
		EndIf
		If UBound($aAppInfo) >= 3 Then
			$aAppInfo = StringSplit($aAppInfo[2], '"timetouched', 1)
		EndIf
		If UBound($aAppInfo) >= 2 Then
			$aAppInfo = StringSplit($aAppInfo[1], '"', 1)
		EndIf
		If UBound($aAppInfo) >= 9 And StringRegExp($aAppInfo[8], '^\d+$') Then
			$aReturn[1] = True ;Successfully Read numerical value at positition expected
			$aReturn[2] = $aAppInfo[8] ;Return Value Read
		EndIf

		If FileExists($sFilePath) Then
			FileClose($hFileOpen)
		EndIf
	EndIf
	Return $aReturn
EndFunc   ;==>GetInstalledModUpdateTime

Func CheckMod($sMods, $sSteamCmdDir, $sServerDir)
	Local $aMods = StringSplit($sMods, ",")
	For $i = 1 To $aMods[0]
		$aMods[$i] = StringStripWS($aMods[$i], 8)
		Local $aLatestTime = GetLatestModUpdateTime($aMods[$i])
		Local $aInstalledTime = GetInstalledModUpdateTime($sServerDir, $aMods[$i])
		Local $bStopUpdate = False
		If Not $aLatestTime[0] Or Not $aLatestTime[1] Then
			LogWrite("Something went wrong downloading update information for mod [" & $aMods[$i] & "] Check your Mod List for incorrect Mod numbers.")
		ElseIf Not $aInstalledTime[0] Then
			$bStopUpdate = UpdateMod($aMods[$i], $sSteamCmdDir, $sServerDir, 0) ;No Manifest. Download First Mod
			If $bStopUpdate Then ExitLoop
		ElseIf Not $aInstalledTime[1] Then
			$bStopUpdate = UpdateMod($aMods[$i], $sSteamCmdDir, $sServerDir, 1) ;Mod does not exists. Download
			If $bStopUpdate Then ExitLoop
		ElseIf $aInstalledTime[1] And (StringCompare($aLatestTime[2], $aInstalledTime[2]) <> 0) Then
			$bStopUpdate = UpdateMod($aMods[$i], $sSteamCmdDir, $sServerDir, 2) ;Mod Out of Date. Update.
			If $bStopUpdate Then ExitLoop
		EndIf
	Next
	WriteModList($sServerDir)
EndFunc   ;==>CheckMod

Func WriteModList($sServerDir)
	Local $sModFile = $sServerDir & "\ConanSandbox\Mods\modlist.txt"
	FileMove($sModFile, $sModFile & ".BAK", 9)
	Local $aMods = StringSplit($g_sMods, ",")
	Local $sModName = ""
	For $i = 1 To $aMods[0]
		$aMods[$i] = StringStripWS($aMods[$i], 8)
		$sModName = IniRead($g_c_sMODIDFile, "MODID2MODNAME", $aMods[$i], $aMods[$i])
		If $aMods[$i] = $sModName Then
			LogWrite("Could not find Mod name for " & $aMods[$i] & " in " & $g_c_sMODIDFile & " Please refer to README and manually update list.")
		Else
			FileWriteLine($sModFile, $sModName)
		EndIf
	Next
EndFunc   ;==>WriteModList

Func UpdateModNameList($sSteamCmdDir, $sMod)
	Local $hSearch = FileFindFirstFile($sSteamCmdDir & "\steamapps\workshop\content\440900\" & $sMod & "\*.pak")
	If $hSearch = -1 Then
		LogWrite("Error: No Mod Files Found.")
		Return False
	Else
		Local $sFileName = FileFindNextFile($hSearch)
		IniWrite($g_c_sMODIDFile, "MODID2MODNAME", $sMod, $sFileName)
	EndIf
	FileClose($hSearch)
EndFunc   ;==>UpdateModNameList

Func UpdateMod($sMod, $sSteamCmdDir, $sServerDir, $iReason)
	Local $bReturn = False
	If ProcessExists("steamcmd.exe") And FileExists($sSteamCmdDir & "\inuse.tmp") Then
		LogWrite("A different Script is currently using SteamCMD in this directory. Skipping Mod " & $sMod & " Update for Now")
		$bReturn = True ;Tell Previous Function to Exit Loop.
	ElseIf ProcessExists($g_sConanPID) Then
		LogWrite("Mod Update Found but Server is Currently Running.")
		If (($sUseDiscordBot = "yes") Or ($sUseTwitchBot = "yes")) Then
			$g_iBeginDelayedShutdown = 1
		Else
			CloseServer()
		EndIf
		$bReturn = True ;Tell Previous Function to Exit Loop.
	Else
		FileWriteLine($sSteamCmdDir & "\inuse.tmp", "Conan Server Utility Using SteamCMD to Update Mod. If Steam Command is not running. Delete this file.")
		Local Const $sModManifest = "\steamapps\workshop\appworkshop_440900.acf"
		If FileExists($sSteamCmdDir & $sModManifest) Then
			FileMove($sSteamCmdDir & $sModManifest, $sSteamCmdDir & $sModManifest & ".BAK")
		EndIf
		If FileExists($sServerDir & $sModManifest) Then
			FileMove($sServerDir & $sModManifest, $sSteamCmdDir & $sModManifest, 1 + 8)
		EndIf
		RunWait("" & $sSteamCmdDir & "\steamcmd.exe +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +workshop_download_item 440900 " & $sMod & " +exit")
		If FileExists($sSteamCmdDir & "\steamapps\workshop\content\440900\" & $sMod) Then
			UpdateModNameList($sSteamCmdDir, $sMod)
			FileMove($sSteamCmdDir & "\steamapps\workshop\content\440900\" & $sMod & "\*.pak", $sServerDir & "\ConanSandbox\Mods\", 1 + 8)
			DirRemove($sSteamCmdDir & "\steamapps\workshop\content\440900\" & $sMod, 1)
		EndIf
		If FileExists($sSteamCmdDir & $sModManifest) Then
			FileMove($sSteamCmdDir & $sModManifest, $sServerDir & "\steamapps\workshop\appworkshop_440900.acf", 1 + 8)
		EndIf
		Switch $iReason
			Case 0
				LogWrite("No mod manifest existed. Downloaded First Mod " & $sMod & " to create Manifest. Should only see this once.")
			Case 1
				LogWrite("Mod " & $sMod & " did not exist. Downloaded.")
			Case 2
				LogWrite("Mod " & $sMod & " was out of date. Updated")
		EndSwitch
		$bReturn = False ;Tell Previous To Continue.
		Local $hTimeOutTimer = TimerInit()
		While FileExists($sSteamCmdDir & "\inuse.tmp")
			FileDelete($sSteamCmdDir & "\inuse.tmp")
			If @error Then ExitLoop
			If TimerDiff($hTimeOutTimer) > 10000 Then ExitLoop
		WEnd
	EndIf

	Return $bReturn
EndFunc   ;==>UpdateMod
#EndRegion ;**** Functions to Check for Mod Updates ****

#Region ;**** Functions for Multiple Passwords and Hiding Password ****
Func PassCheck($sPass, $sPassString)
	Local $aPassReturn[3] = [False, "", ""]
	Local $aPasswords = StringSplit($sPassString, ",")
	For $i = 1 To $aPasswords[0]
		If (StringCompare($sPass, $aPasswords[$i], 1) = 0) Then
			Local $aUserPass = StringSplit($aPasswords[$i], "_")
			If $aUserPass[0] > 1 Then
				$aPassReturn[0] = True
				$aPassReturn[1] = $aUserPass[1]
				$aPassReturn[2] = $aUserPass[2]
			Else
				$aPassReturn[0] = True
				$aPassReturn[1] = "Anonymous"
				$aPassReturn[2] = $aUserPass[1]
			EndIf
			ExitLoop
		EndIf
	Next
	Return $aPassReturn
EndFunc   ;==>PassCheck

Func ObfPass($sObfPassString)
	Local $sObfPass = ""
	For $i = 1 To (StringLen($sObfPassString) - 3)
		If $i <> 4 Then
			$sObfPass = $sObfPass & "*"
		Else
			$sObfPass = $sObfPass & StringMid($sObfPassString, 4, 4)
		EndIf
	Next
	Return $sObfPass
EndFunc   ;==>ObfPass
#EndRegion ;**** Functions for Multiple Passwords and Hiding Password ****

#Region ;**** Function to get IP from Restart Client ****
Func _TCP_Server_ClientIP($hSocket)
	Local $pSocketAddress, $aReturn
	$pSocketAddress = DllStructCreate("short;ushort;uint;char[8]")
	$aReturn = DllCall("ws2_32.dll", "int", "getpeername", "int", $hSocket, "ptr", DllStructGetPtr($pSocketAddress), "int*", DllStructGetSize($pSocketAddress))
	If @error Or $aReturn[0] <> 0 Then Return $hSocket
	$aReturn = DllCall("ws2_32.dll", "str", "inet_ntoa", "int", DllStructGetData($pSocketAddress, 3))
	If @error Then Return $hSocket
	$pSocketAddress = 0
	Return $aReturn[0]
EndFunc   ;==>_TCP_Server_ClientIP
#EndRegion ;**** Function to get IP from Restart Client ****

#Region ;**** Startup Checks. Initial Log, Read INI, Check for Correct Paths, Check Remote Restart is bound to port. ****
OnAutoItExitRegister("Gamercide")
FileWriteLine($g_c_sLogFile, _NowCalc() & " ConanServerUtility Script V2.15.0 Started")
ReadUini()

If $UseSteamCMD = "yes" Then
	Local $sFileExists = FileExists($steamcmddir & "\steamcmd.exe")
	If $sFileExists = 0 Then
		InetGet("https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip", @ScriptDir & "\steamcmd.zip", 0)
		DirCreate($steamcmddir) ; to extract to
		_ExtractZip(@ScriptDir & "\steamcmd.zip", "", "steamcmd.exe", $steamcmddir)
		FileDelete(@ScriptDir & "\steamcmd.zip")
		FileWriteLine($g_c_sLogFile, _NowCalc() & " Running SteamCMD with validate. [steamcmd.exe +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir " & $serverdir & " +app_update 443030 validate +quit]")
		RunWait("" & $steamcmddir & "\steamcmd.exe +quit")
		If Not FileExists($steamcmddir & "\steamcmd.exe") Then
			MsgBox(0x0, "SteamCMD Not Found", "Could not find steamcmd.exe at " & $steamcmddir)
			Exit
		EndIf
	EndIf
	Local $sManifestExists = FileExists($steamcmddir & "\steamapps\appmanifest_443030.acf")
	If $sManifestExists = 1 Then
		Local $manifestFound = MsgBox(4100, "Warning", "Install manifest found at " & $steamcmddir & "\steamapps\appmanifest_443030.acf" & @CRLF & @CRLF & "Suggest moving file to " & _
				$serverdir & "\steamapps\appmanifest_443030.acf before running SteamCMD" & @CRLF & @CRLF & "Would you like to Exit Now?", 20)
		If $manifestFound = 6 Then
			Exit
		EndIf
	EndIf
	If $g_sUpdateMods = "yes" Then
		Local Const $sModManifest = "\steamapps\workshop\appworkshop_440900.acf"
		If FileExists($serverdir & $sModManifest) And Not FileExists($g_c_sMODIDFile) Then
			Local $ModListNotFound = MsgBox(4100, "Warning", "Existing Mods found, but there is no Mod ID to Mod Name file. If you continue all of your mods will be downloaded again " & _
					"so modlist.txt can be ordered properly. Exit and refer to README if you don't wish to download mods again." & @CRLF & @CRLF & "Continue? (Press No to Exit)")
			If $ModListNotFound = 6 Then
				FileMove($serverdir & $sModManifest, $serverdir & $sModManifest & ".BAK", 9)
				FileWrite($g_c_sMODIDFile, "[File for Matching Mod to Name]")
				IniWrite($g_c_sMODIDFile, "MODID2MODNAME", "EXAMPLE_MODID", "EXAMPLE_MODNAME.pak")
			Else
				FileWrite($g_c_sMODIDFile, "[File for Matching Mod to Name]")
				IniWrite($g_c_sMODIDFile, "MODID2MODNAME", "EXAMPLE_MODID", "EXAMPLE_MODNAME.pak")
				Exit
			EndIf

		EndIf
	EndIf
Else
	Local $cFileExists = FileExists($serverdir & "\ConanSandboxServer.exe")
	If $cFileExists = 0 Then
		MsgBox(0x0, "Conan Server Not Found", "Could not find ConanSandboxServer.exe at " & $serverdir)
		Exit
	EndIf
EndIf


If $UseRemoteRestart = "yes" Then
	; Start The TCP Services
	TCPStartup()
	Local $MainSocket = TCPListen($g_IP, $g_Port, 100)
	If $MainSocket = -1 Then
		MsgBox(0x0, "TCP Error", "Could not bind to [" & $g_IP & "] Check server IP or disable Remote Restart in INI")
		FileWriteLine($g_c_sLogFile, _NowCalc() & " Remote Restart Enabled. Could not bind to " & $g_IP & ":" & $g_Port)
		Exit
	Else
		FileWriteLine($g_c_sLogFile, _NowCalc() & " Remote Restart Enabled. Listening for Restart Request at " & $g_IP & ":" & $g_Port)
	EndIf
EndIf
#EndRegion ;**** Startup Checks. Initial Log, Read INI, Check for Correct Paths, Check Remote Restart is bound to port. ****

While True ;**** Loop Until Closed ****
	#Region ;**** Listen for Remote Restart Request ****
	If $UseRemoteRestart = "yes" Then
		Local $ConnectedSocket = TCPAccept($MainSocket)
		If $ConnectedSocket >= 0 Then
			$Count = 0
			While $Count < 30
				Local $sRECV = TCPRecv($ConnectedSocket, 512)
				Local $aPassCompare = PassCheck($sRECV, $RestartCode)
				If $sObfuscatePass = "yes" Then
					$aPassCompare[2] = ObfPass($aPassCompare[2])
				EndIf
				If $aPassCompare[0] Then
					If ProcessExists($g_sConanPID) Then
						Local $IP = _TCP_Server_ClientIP($ConnectedSocket)
						Local $MEM = ProcessGetStats($g_sConanPID, 0)
						FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] [Work Memory:" & $MEM[0] & " | Peak Memory:" & $MEM[1] & "] Restart Requested by Remote Host: " & $IP & " | User: " & $aPassCompare[1] & " | Pass: " & $aPassCompare[2])
						CloseServer()
						Sleep(10000)
						ExitLoop
					EndIf
				Else
					Local $IP = _TCP_Server_ClientIP($ConnectedSocket)
					FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Restart ATTEMPT by Remote Host: " & $IP & " | Unknown Restart Code: " & $sRECV)
					ExitLoop
				EndIf
				$Count += 1
				Sleep(1000)
			WEnd
			If $ConnectedSocket <> -1 Then TCPCloseSocket($ConnectedSocket)
		EndIf
	EndIf
	#EndRegion ;**** Listen for Remote Restart Request ****

	#Region ;**** Keep Server Alive Check. ****
	If Not ProcessExists($g_sConanPID) Then
		$g_iBeginDelayedShutdown = 0
		If $UseSteamCMD = "yes" Then
			If $validategame = "yes" Then
				FileWriteLine($g_c_sLogFile, _NowCalc() & " Running SteamCMD with validate. [steamcmd.exe +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir " & $serverdir & " +app_update 443030 validate +quit]")
				RunWait("" & $steamcmddir & "\steamcmd.exe +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir " & $serverdir & " +app_update 443030 validate +quit")
			Else
				FileWriteLine($g_c_sLogFile, _NowCalc() & " Running SteamCMD without validate. [steamcmd.exe +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir " & $serverdir & " +app_update 443030 +quit]")
				RunWait("" & $steamcmddir & "\steamcmd.exe +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir " & $serverdir & " +app_update 443030 +quit")
			EndIf
		EndIf
		If $g_sUpdateMods = "yes" Then
			CheckMod($g_sMods, $steamcmddir, $serverdir)
		EndIf
		If $g_bIniOverwriteFix Then
			DeleteDefaultINI()
		EndIf
		Local $sCurrentAdminPass = IniRead($serverdir & $g_sServerSettingIniLoc, "ServerSettings", "AdminPassword", "")
		If $sCurrentAdminPass <> $AdminPass Then
			ChangeSetting($serverdir & $g_sServerSettingIniLoc, "ServerSettings", "AdminPassword", $AdminPass)
		EndIf
		Local $sCurrentServerPass = IniRead($serverdir & "\ConanSandbox\saved\Config\WindowsServer\Engine.ini", "OnlineSubsystemSteam", "ServerPassword", "")
		If $sCurrentServerPass <> $ServerPass Then
			ChangeSetting($serverdir & "\ConanSandbox\saved\Config\WindowsServer\Engine.ini", "OnlineSubsystemSteam", "ServerPassword", $ServerPass)
		EndIf
		If $g_sEnableBuildingDmgSchedule = "yes" Then
			RaidCheck($g_bFlipBuildingDmgSchedule)
		EndIf
		If $g_sEnableAvatarSchedule = "yes" Then
			AvatarCheck($g_bFlipAvatarSchedule)
		EndIf
		If $BindIP = "no" Then
			$g_sConanPID = Run("" & $serverdir & "\ConanSandbox\Binaries\Win64\" & $g_c_sServerEXE & " ConanSandBox -Port=" & $GamePort & " -QueryPort=" & $QueryPort & " -MaxPlayers=" & $MaxPlayers & " -AdminPassword=" & $AdminPass & " -ServerPassword=" & $ServerPass & " -ServerName=""" & $ServerName & """ -listen -nosteamclient -game -server -log")
			If $sObfuscatePass = "yes" Then
				FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Started [" & $g_c_sServerEXE & " ConanSandBox -Port=" & $GamePort & " -QueryPort=" & $QueryPort & " -MaxPlayers=" & $MaxPlayers & " -AdminPassword=" & ObfPass($AdminPass) & " -ServerPassword=" & ObfPass($ServerPass) & " -ServerName=""" & $ServerName & """ -listen -nosteamclient -game -server -log]")
			Else
				FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Started [" & $g_c_sServerEXE & " ConanSandBox -Port=" & $GamePort & " -QueryPort=" & $QueryPort & " -MaxPlayers=" & $MaxPlayers & " -AdminPassword=" & $AdminPass & " -ServerPassword=" & $ServerPass & " -ServerName=""" & $ServerName & """ -listen -nosteamclient -game -server -log]")
			EndIf
		Else
			$g_sConanPID = Run("" & $serverdir & "\ConanSandbox\Binaries\Win64\" & $g_c_sServerEXE & " ConanSandBox -MULTIHOME=" & $g_IP & " -Port=" & $GamePort & " -QueryPort=" & $QueryPort & " -MaxPlayers=" & $MaxPlayers & " -AdminPassword=" & $AdminPass & " -ServerPassword=" & $ServerPass & " -ServerName=""" & $ServerName & """ -listen -nosteamclient -game -server -log")
			If $sObfuscatePass = "yes" Then
				FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Started [" & $g_c_sServerEXE & " ConanSandBox -MULTIHOME=" & $g_IP & " -Port=" & $GamePort & " -QueryPort=" & $QueryPort & " -MaxPlayers=" & $MaxPlayers & " -AdminPassword=" & ObfPass($AdminPass) & " -ServerPassword=" & ObfPass($ServerPass) & " -ServerName=""" & $ServerName & """ -listen -nosteamclient -game -server -log]")
			Else
				FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Started [" & $g_c_sServerEXE & " ConanSandBox -MULTIHOME=" & $g_IP & " -Port=" & $GamePort & " -QueryPort=" & $QueryPort & " -MaxPlayers=" & $MaxPlayers & " -AdminPassword=" & $AdminPass & " -ServerPassword=" & $ServerPass & " -ServerName=""" & $ServerName & """ -listen -nosteamclient -game -server -log]")
			EndIf
		EndIf
		If @error Or Not $g_sConanPID Then
			If Not IsDeclared("iMsgBoxAnswer") Then Local $iMsgBoxAnswer
			$iMsgBoxAnswer = MsgBox(262405, "Server Failed to Start", "The server tried to start, but it failed. Try again? This will automatically close in 60 seconds and try to start again.", 60)
			Select
				Case $iMsgBoxAnswer = 4 ;Retry
					FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Server Failed to Start. User Initiated a Restart Attempt.")
				Case $iMsgBoxAnswer = 2 ;Cancel
					FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Server Failed to Start - ConanServerUtility Shutdown - Intiated by User")
					Exit
				Case $iMsgBoxAnswer = -1 ;Timeout
					FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Server Failed to Start. Script Initiated Restart Attempt after 60 seconds of no User Input.")
			EndSelect
		EndIf
		$g_hConanhWnd = WinGetHandle(WinWait("" & $serverdir & "", "", 70))
		If $SteamFix = "yes" Then
			WinWait("" & $g_c_sServerEXE & " - Entry Point Not Found", "", 10)
			If WinExists("" & $g_c_sServerEXE & " - Entry Point Not Found") Then
				ControlSend("" & $g_c_sServerEXE & " - Entry Point Not Found", "", "", "{enter}")
			EndIf
			WinWait("" & $g_c_sServerEXE & " - Entry Point Not Found", "", 10)
			If WinExists("" & $g_c_sServerEXE & " - Entry Point Not Found") Then
				ControlSend("" & $g_c_sServerEXE & " - Entry Point Not Found", "", "", "{enter}")
			EndIf
		EndIf
		If FileExists($g_c_sPIDFile) Then
			FileDelete($g_c_sPIDFile)
		EndIf
		If FileExists($g_c_sHwndFile) Then
			FileDelete($g_c_sHwndFile)
		EndIf
		FileWrite($g_c_sPIDFile, $g_sConanPID)
		FileWrite($g_c_sHwndFile, String($g_hConanhWnd))
		FileSetAttrib($g_c_sPIDFile, "+HT")
		FileSetAttrib($g_c_sHwndFile, "+HT")
		FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Window Handle Found: " & $g_hConanhWnd)
	ElseIf ((_DateDiff('n', $g_sTimeCheck1, _NowCalc())) >= 5) Then
		Local $MEM = ProcessGetStats($g_sConanPID, 0)
		If $MEM[0] > $ExMem And $ExMemRestart = "no" Then
			FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Work Memory:" & $MEM[0] & " Peak Memory:" & $MEM[1])
		ElseIf $MEM[0] > $ExMem And $ExMemRestart = "yes" Then
			FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Work Memory:" & $MEM[0] & " Peak Memory:" & $MEM[1] & " Excessive Memory Use - Restart Requested by ConanServerUtility Script")
			CloseServer()
		EndIf
		$g_sTimeCheck1 = _NowCalc()
	EndIf
	#EndRegion ;**** Keep Server Alive Check. ****

	#Region ;**** Restart Server Every X Hours ****
	If ((@HOUR = $HotHour1 Or @HOUR = $HotHour2 Or @HOUR = $HotHour3 Or @HOUR = $HotHour4 Or @HOUR = $HotHour5 Or @HOUR = $HotHour6) And @MIN = $HotMin And $RestartDaily = "yes" And ((_DateDiff('n', $g_sTimeCheck2, _NowCalc())) >= 1)) And ($g_iBeginDelayedShutdown = 0) Then
		If ProcessExists($g_sConanPID) Then
			Local $MEM = ProcessGetStats($g_sConanPID, 0)
			FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Work Memory:" & $MEM[0] & " Peak Memory:" & $MEM[1] & " - Daily Restart Requested by ConanServerUtility Script")
			If ($sUseDiscordBot = "yes") Or ($sUseTwitchBot = "yes") Then
				$g_iBeginDelayedShutdown = 1
				$g_sTimeCheck0 = _NowCalc
			Else
				CloseServer()
			EndIf
		EndIf
		$g_sTimeCheck2 = _NowCalc()
	EndIf
	#EndRegion ;**** Restart Server Every X Hours ****

	#Region ;**** Check for Update every X Minutes ****
	If ($CheckForUpdate = "yes") And ((_DateDiff('n', $g_sTimeCheck0, _NowCalc())) >= $UpdateInterval) And ($g_iBeginDelayedShutdown = 0) Then
		Local $bRestart = UpdateCheck()
		If $bRestart And (($sUseDiscordBot = "yes") Or ($sUseTwitchBot = "yes")) Then
			$g_iBeginDelayedShutdown = 1
		ElseIf $bRestart Then
			CloseServer()
		ElseIf $g_sUpdateMods = "yes" Then
			LogWrite("Checking for Mod Updates")
			CheckMod($g_sMods, $steamcmddir, $serverdir)
		EndIf
		$g_sTimeCheck0 = _NowCalc()
	EndIf
	#EndRegion ;**** Check for Update every X Minutes ****

	#Region ;**** Check if Building Damage or Avatars need to be Toggled
	If ((_DateDiff('n', $g_sTimeCheck3, _NowCalc())) >= 1) And ($g_iBeginDelayedShutdown = 0) Then
		If $g_sEnableBuildingDmgSchedule = "yes" Then
			RaidCheck($g_bFlipBuildingDmgSchedule)
		EndIf
		If $g_sEnableAvatarSchedule = "yes" Then
			AvatarCheck($g_bFlipAvatarSchedule)
		EndIf
		$g_sTimeCheck3 = _NowCalc()
	EndIf
	#EndRegion ;**** Check if Building Damage or Avatars need to be Toggled

	#Region ;**** Announce to Twitch or Discord or Both ****
	If ($sUseDiscordBot = "yes") Or ($sUseTwitchBot = "yes") Then
		If $g_iBeginDelayedShutdown = 1 Then
			FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Bot in Use. Delaying Shutdown for " & $g_iDelayShutdownTime & " minutes. Notifying Channel")
			Local $sShutdownMessage = $ServerName & " Restarting in " & $g_iDelayShutdownTime & " minutes"
			If $sUseDiscordBot = "yes" Then
				SendDiscordMsg($sDiscordWebHookURLs, $sShutdownMessage, $sDiscordBotName, $bDiscordBotUseTTS, $sDiscordBotAvatar)
			EndIf
			If $sUseTwitchBot = "yes" Then
				TwitchMsgLog($sShutdownMessage)
			EndIf
			$g_iBeginDelayedShutdown = 2
			$g_sTimeCheck0 = _NowCalc()
		ElseIf ($g_iBeginDelayedShutdown >= 2 And ((_DateDiff('n', $g_sTimeCheck0, _NowCalc())) >= $g_iDelayShutdownTime)) Then
			$g_iBeginDelayedShutdown = 0
			$g_sTimeCheck0 = _NowCalc()
			CloseServer()
		ElseIf $g_iBeginDelayedShutdown = 2 And ((_DateDiff('n', $g_sTimeCheck0, _NowCalc())) >= ($g_iDelayShutdownTime - 1)) Then
			Local $sShutdownMessage = $ServerName & " Restarting in 1 minute. Final Warning"
			If $sUseDiscordBot = "yes" Then
				SendDiscordMsg($sDiscordWebHookURLs, $sShutdownMessage, $sDiscordBotName, $bDiscordBotUseTTS, $sDiscordBotAvatar)
			EndIf
			If $sUseTwitchBot = "yes" Then
				TwitchMsgLog($sShutdownMessage)
			EndIf
			$g_iBeginDelayedShutdown = 3
		EndIf
	Else
		$g_iBeginDelayedShutdown = 0
	EndIf
	#EndRegion ;**** Announce to Twitch or Discord or Both ****

	#Region ;**** Rotate Logs ****
	If ($logRotate = "yes") And ((_DateDiff('h', $g_sTimeCheck4, _NowCalc())) >= 1) Then
		If Not FileExists($g_c_sLogFile) Then
			FileWriteLine($g_c_sLogFile, $g_sTimeCheck4 & " Log File Created")
			FileSetTime($g_c_sLogFile, @YEAR & @MON & @MDAY, 1)
		EndIf
		Local $g_c_sLogFileTime = FileGetTime($g_c_sLogFile, 1)
		Local $logTimeSinceCreation = _DateDiff('h', $g_c_sLogFileTime[0] & "/" & $g_c_sLogFileTime[1] & "/" & $g_c_sLogFileTime[2] & " " & $g_c_sLogFileTime[3] & ":" & $g_c_sLogFileTime[4] & ":" & $g_c_sLogFileTime[5], _NowCalc())
		If $logTimeSinceCreation >= $logHoursBetweenRotate Then
			RotateFile($g_c_sLogFile, $logQuantity)
		EndIf
		$g_sTimeCheck4 = _NowCalc()
	EndIf
	#EndRegion ;**** Rotate Logs ****
	Sleep(1000)
WEnd
