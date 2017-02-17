#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\resources\favicon.ico
#AutoIt3Wrapper_Outfile=..\..\build\ConanServerUtility_x86_v2.8.6.2.exe
#AutoIt3Wrapper_Outfile_x64=..\..\build\ConanServerUtility_x64_v2.8.6.2.exe
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=By Dateranoth - Feburary 12, 2017
#AutoIt3Wrapper_Res_Description=Utility for Running Conan Server
#AutoIt3Wrapper_Res_Fileversion=2.8.6.1
#AutoIt3Wrapper_Res_LegalCopyright=Dateranoth @ https://gamercide.com
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;Originally written by Dateranoth for use
;by https://gamercide.com on their server
;Distributed Under GNU GENERAL PUBLIC LICENSE

Opt("WinTitleMatchMode", 1) ;1=start, 2=subStr, 3=exact, 4=advanced, -1 to -4=Nocase
#include <Date.au3>
#include <Process.au3>
#include <MsgBoxConstants.au3>
#include <File.au3>

#Region ;**** Global Variables ****
Global $mNextCheck = _NowCalc()
Global $timeCheck1 = _NowCalc()
Global $timeCheck2 = _NowCalc()
Global $sFile = ""
Global $Server_EXE = "ConanSandboxServer-Win64-Test.exe"
Global $PIDFile = @ScriptDir & "\ConanServerUtility_lastpid_tmp"
Global $hWndFile = @ScriptDir & "\ConanServerUtility_lasthwnd_tmp"
Global $logFile = @ScriptDir & "\ConanServerUtility.log"
Global $logStartTime = _NowCalc()
Global $iniFile = @ScriptDir & "\ConanServerUtility.ini"
Global $iniFail = 0
Global $iShutdown = 0
Global $iBeginDelayedShutdown = 0
Global $iDelayShutdownTime = 0

If FileExists($PIDFile) Then
	Global $ConanPID = FileRead($PIDFile)
Else
	Global $ConanPID = "0"
EndIf
If FileExists($hWndFile) Then
	Global $ConanhWnd = HWnd(FileRead($hWndFile))
Else
	Global $ConanhWnd = "0"
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

	Global $BindIP = IniRead($iniFile, "Use MULTIHOME to Bind IP? Disable if having connection issues (yes/no)", "BindIP", $iniCheck)
	Global $g_IP = IniRead($iniFile, "Game Server IP", "ListenIP", $iniCheck)
	Global $GamePort = IniRead($iniFile, "Game Server Port", "GamePort", $iniCheck)
	Global $QueryPort = IniRead($iniFile, "Steam Query Port", "QueryPort", $iniCheck)
	Global $ServerName = IniRead($iniFile, "Server Name", "ServerName", $iniCheck)
	Global $ServerPass = IniRead($iniFile, "Server Password", "ServerPass", $iniCheck)
	Global $AdminPass = IniRead($iniFile, "Admin Password", "AdminPass", $iniCheck)
	Global $MaxPlayers = IniRead($iniFile, "Max Players", "MaxPlayers", $iniCheck)
	Global $serverdir = IniRead($iniFile, "Server Directory. NO TRAILING SLASH", "serverdir", $iniCheck)
	Global $UseSteamCMD = IniRead($iniFile, "Use SteamCMD To Update Server? yes/no", "UseSteamCMD", $iniCheck)
	Global $steamcmddir = IniRead($iniFile, "SteamCMD Directory. NO TRAILING SLASH", "steamcmddir", $iniCheck)
	Global $validategame = IniRead($iniFile, "Validate Files Every Time SteamCMD Runs? yes/no", "validategame", $iniCheck)
	Global $UseRemoteRestart = IniRead($iniFile, "Use Remote Restart ?yes/no", "UseRemoteRestart", $iniCheck)
	Global $g_Port = IniRead($iniFile, "Remote Restart Port", "ListenPort", $iniCheck)
	Global $RestartCode = IniRead($iniFile, "Remote Restart Password", "RestartCode", $iniCheck)
	Global $sObfuscatePass = IniRead($iniFile, "Hide Passwords in Log? yes/no", "ObfuscatePass", $iniCheck)
	Global $RestartDaily = IniRead($iniFile, "Restart Server Daily? yes/no", "RestartDaily", $iniCheck)
	Global $CheckForUpdate = IniRead($iniFile, "Check for Update Every X Minutes? yes/no", "CheckForUpdate", $iniCheck)
	Global $UpdateInterval = IniRead($iniFile, "Update Check Interval in Minutes 05-59", "UpdateInterval", $iniCheck)
	Global $HotHour1 = IniRead($iniFile, "Daily Restart Hours? 00-23", "HotHour1", $iniCheck)
	Global $HotHour2 = IniRead($iniFile, "Daily Restart Hours? 00-23", "HotHour2", $iniCheck)
	Global $HotHour3 = IniRead($iniFile, "Daily Restart Hours? 00-23", "HotHour3", $iniCheck)
	Global $HotHour4 = IniRead($iniFile, "Daily Restart Hours? 00-23", "HotHour4", $iniCheck)
	Global $HotHour5 = IniRead($iniFile, "Daily Restart Hours? 00-23", "HotHour5", $iniCheck)
	Global $HotHour6 = IniRead($iniFile, "Daily Restart Hours? 00-23", "HotHour6", $iniCheck)
	Global $HotMin = IniRead($iniFile, "Daily Restart Minute? 00-59", "HotMin", $iniCheck)
	Global $ExMem = IniRead($iniFile, "Excessive Memory Amount?", "ExMem", $iniCheck)
	Global $ExMemRestart = IniRead($iniFile, "Restart On Excessive Memory Use? yes/no", "ExMemRestart", $iniCheck)
	Global $SteamFix = IniRead($iniFile, "Running Server with Steam Open? (yes/no)", "SteamFix", $iniCheck)
	Global $logRotate = IniRead($iniFile, "Rotate X Number of Logs every X Hours? yes/no", "logRotate", $iniCheck)
	Global $logQuantity = IniRead($iniFile, "Rotate X Number of Logs every X Hours? yes/no", "logQuantity", $iniCheck)
	Global $logHoursBetweenRotate = IniRead($iniFile, "Rotate X Number of Logs every X Hours? yes/no", "logHoursBetweenRotate", $iniCheck)
	Global $sUseDiscordBot = IniRead($iniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "UseDiscordBot", $iniCheck)
	Global $sDiscordWebHookURL = IniRead($iniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordWebHookURL", $iniCheck)
	Global $sDiscordBotName = IniRead($iniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotName", $iniCheck)
	Global $bDiscordBotUseTTS = IniRead($iniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotUseTTS", $iniCheck)
	Global $sDiscordBotAvatar = IniRead($iniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotAvatarLink", $iniCheck)
	Global $iDiscordBotNotifyTime = IniRead($iniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotTimeBeforeRestart", $iniCheck)
	Global $sUseTwitchBot = IniRead($iniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "UseTwitchBot", $iniCheck)
	Global $sTwitchNick = IniRead($iniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "TwitchNick", $iniCheck)
	Global $sChatOAuth = IniRead($iniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "ChatOAuth", $iniCheck)
	Global $sTwitchChannels = IniRead($iniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "TwitchChannels", $iniCheck)
	Global $iTwitchBotNotifyTime = IniRead($iniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "TwitchBotTimeBeforeRestart", $iniCheck)

	If $iniCheck = $BindIP Then
		$BindIP = "yes"
		$iniFail += 1
	EndIf
	If $iniCheck = $g_IP Then
		$g_IP = "127.0.0.1"
		$iniFail += 1
	EndIf
	If $iniCheck = $GamePort Then
		$GamePort = "7777"
		$iniFail += 1
	EndIf
	If $iniCheck = $QueryPort Then
		$QueryPort = "27015"
		$iniFail += 1
	EndIf
	If $iniCheck = $ServerName Then
		$ServerName = "Conan Server Utility Server"
		$iniFail += 1
	EndIf
	If $iniCheck = $ServerPass Then
		$ServerPass = ""
		$iniFail += 1
	EndIf
	If $iniCheck = $AdminPass Then
		$AdminPass &= "_noHASHsymbol"
		$iniFail += 1
	EndIf
	If $iniCheck = $MaxPlayers Then
		$MaxPlayers = "20"
		$iniFail += 1
	EndIf
	If $iniCheck = $serverdir Then
		$serverdir = "C:\Game_Servers\Conan_Exiles_Server"
		$iniFail += 1
	EndIf
	If $iniCheck = $UseSteamCMD Then
		$UseSteamCMD = "yes"
		$iniFail += 1
	EndIf
	If $iniCheck = $steamcmddir Then
		$steamcmddir = "C:\Game_Servers\SteamCMD"
		$iniFail += 1
	EndIf
	If $iniCheck = $validategame Then
		$validategame = "no"
		$iniFail += 1
	EndIf
	If $iniCheck = $UseRemoteRestart Then
		$UseRemoteRestart = "no"
		$iniFail += 1
	EndIf
	If $iniCheck = $g_Port Then
		$g_Port = "57520"
		$iniFail += 1
	EndIf
	If $iniCheck = $RestartCode Then
		$RestartCode = "Admin1_" & $RestartCode
		$iniFail += 1
	EndIf
	If $iniCheck = $sObfuscatePass Then
		$sObfuscatePass = "yes"
		$iniFail += 1
	EndIf
	If $iniCheck = $RestartDaily Then
		$RestartDaily = "no"
		$iniFail += 1
	EndIf
	If $iniCheck = $CheckForUpdate Then
		$CheckForUpdate = "yes"
		$iniFail += 1
	ElseIf $CheckForUpdate = "yes" And $UseSteamCMD <> "yes" Then
		$CheckForUpdate = "no"
		FileWriteLine($logFile, _NowCalc() & " SteamCMD disabled. Disabling CheckForUpdate. Update will not work without SteamCMD to update it!")
	EndIf
	If $iniCheck = $UpdateInterval Then
		$UpdateInterval = "15"
		$iniFail += 1
	ElseIf $UpdateInterval < 5 Then
		$UpdateInterval = 5
	EndIf
	If $iniCheck = $HotHour1 Then
		$HotHour1 = "00"
		$iniFail += 1
	EndIf
	If $iniCheck = $HotHour2 Then
		$HotHour2 = "00"
		$iniFail += 1
	EndIf
	If $iniCheck = $HotHour3 Then
		$HotHour3 = "00"
		$iniFail += 1
	EndIf
	If $iniCheck = $HotHour4 Then
		$HotHour4 = "00"
		$iniFail += 1
	EndIf
	If $iniCheck = $HotHour5 Then
		$HotHour5 = "00"
		$iniFail += 1
	EndIf
	If $iniCheck = $HotHour6 Then
		$HotHour6 = "00"
		$iniFail += 1
	EndIf
	If $iniCheck = $HotMin Then
		$HotMin = "01"
		$iniFail += 1
	EndIf
	If $iniCheck = $ExMem Then
		$ExMem = "6000000000"
		$iniFail += 1
	EndIf
	If $iniCheck = $ExMemRestart Then
		$ExMemRestart = "no"
		$iniFail += 1
	EndIf
	If $iniCheck = $SteamFix Then
		$SteamFix = "no"
		$iniFail += 1
	EndIf
	If $iniCheck = $logRotate Then
		$logRotate = "yes"
		$iniFail += 1
	EndIf
	If $iniCheck = $logQuantity Then
		$logQuantity = "10"
		$iniFail += 1
	EndIf
	If $iniCheck = $logHoursBetweenRotate Then
		$logHoursBetweenRotate = "24"
		$iniFail += 1
	ElseIf $logHoursBetweenRotate < 1 Then
		$logHoursBetweenRotate = 1
	EndIf
	If $iniCheck = $sUseDiscordBot Then
		$sUseDiscordBot = "no"
		$iniFail += 1
	EndIf
	If $iniCheck = $sDiscordWebHookURL Then
		$sDiscordWebHookURL = "https://discordapp.com/api/webhooks/XXXXXX/XXXX <- NO TRAILING SLASH AND USE FULL URL FROM WEBHOOK URL ON DISCORD"
		$iniFail += 1
	EndIf
	If $iniCheck = $sDiscordBotName Then
		$sDiscordBotName = "Conan Exiles Discord Bot"
		$iniFail += 1
	EndIf
	If $iniCheck = $bDiscordBotUseTTS Then
		$bDiscordBotUseTTS = "yes"
		$iniFail += 1
	EndIf
	If $iniCheck = $sDiscordBotAvatar Then
		$sDiscordBotAvatar = ""
		$iniFail += 1
	EndIf
	If $iniCheck = $iDiscordBotNotifyTime Then
		$iDiscordBotNotifyTime = "5"
		$iniFail += 1
	ElseIf $iDiscordBotNotifyTime < 1 Then
		$iDiscordBotNotifyTime = 1
	EndIf
	If $iniCheck = $sUseTwitchBot Then
		$sUseTwitchBot = "no"
		$iniFail += 1
	EndIf
	If $iniCheck = $sTwitchNick Then
		$sTwitchNick = "twitchbotusername"
		$iniFail += 1
	EndIf
	If $iniCheck = $sChatOAuth Then
		$sChatOAuth = "oauth:1234 (Generate OAuth Token Here: https://twitchapps.com/tmi)"
		$iniFail += 1
	EndIf
	If $iniCheck = $sTwitchChannels Then
		$sTwitchChannels = "channel1,channel2,channel3"
		$iniFail += 1
	EndIf
	If $iniCheck = $iTwitchBotNotifyTime Then
		$iTwitchBotNotifyTime = "5"
		$iniFail += 1
	ElseIf $iTwitchBotNotifyTime < 1 Then
		$iTwitchBotNotifyTime = 1
	EndIf
	If $iniFail > 0 Then
		iniFileCheck()
	EndIf

	If $bDiscordBotUseTTS = "yes" Then
		$bDiscordBotUseTTS = True
	Else
		$bDiscordBotUseTTS = False
	EndIf

	If ($sUseDiscordBot = "yes") Then
		$iDelayShutdownTime = $iDiscordBotNotifyTime
		If ($sUseTwitchBot = "yes") And ($iTwitchBotNotifyTime > $iDelayShutdownTime) Then
			$iDelayShutdownTime = $iTwitchBotNotifyTime
		EndIf
	Else
		$iDelayShutdownTime = $iTwitchBotNotifyTime
	EndIf

EndFunc   ;==>ReadUini

Func iniFileCheck()
	If FileExists($iniFile) Then
		Local $aMyDate, $aMyTime
		_DateTimeSplit(_NowCalc(), $aMyDate, $aMyTime)
		Local $iniDate = StringFormat("%04i.%02i.%02i.%02i%02i", $aMyDate[1], $aMyDate[2], $aMyDate[3], $aMyTime[1], $aMyTime[2])
		FileMove($iniFile, $iniFile & "_" & $iniDate & ".bak", 1)
		UpdateIni()
		MsgBox(4096, "INI MISMATCH", "Found " & $iniFail & " Missing Variables" & @CRLF & @CRLF & "Backup created and all existing settings transfered to new INI." & @CRLF & @CRLF & "Modify INI and restart.")
		Exit
	Else
		UpdateIni()
		MsgBox(4096, "Default INI File Made", "Please Modify Default Values and Restart Script")
		Exit
	EndIf
EndFunc   ;==>iniFileCheck

Func UpdateIni()
	IniWrite($iniFile, "Use MULTIHOME to Bind IP? Disable if having connection issues (yes/no)", "BindIP", $BindIP)
	IniWrite($iniFile, "Game Server IP", "ListenIP", $g_IP)
	IniWrite($iniFile, "Game Server Port", "GamePort", $GamePort)
	IniWrite($iniFile, "Steam Query Port", "QueryPort", $QueryPort)
	IniWrite($iniFile, "Server Name", "ServerName", $ServerName)
	IniWrite($iniFile, "Server Password", "ServerPass", $ServerPass)
	IniWrite($iniFile, "Admin Password", "AdminPass", $AdminPass)
	IniWrite($iniFile, "Max Players", "MaxPlayers", $MaxPlayers)
	IniWrite($iniFile, "Server Directory. NO TRAILING SLASH", "serverdir", $serverdir)
	IniWrite($iniFile, "Use SteamCMD To Update Server? yes/no", "UseSteamCMD", $UseSteamCMD)
	IniWrite($iniFile, "SteamCMD Directory. NO TRAILING SLASH", "steamcmddir", $steamcmddir)
	IniWrite($iniFile, "Validate Files Every Time SteamCMD Runs? yes/no", "validategame", $validategame)
	IniWrite($iniFile, "Use Remote Restart ?yes/no", "UseRemoteRestart", $UseRemoteRestart)
	IniWrite($iniFile, "Remote Restart Port", "ListenPort", $g_Port)
	IniWrite($iniFile, "Remote Restart Password", "RestartCode", $RestartCode)
	IniWrite($iniFile, "Hide Passwords in Log? yes/no", "ObfuscatePass", $sObfuscatePass)
	IniWrite($iniFile, "Restart Server Daily? yes/no", "RestartDaily", $RestartDaily)
	IniWrite($iniFile, "Check for Update Every X Minutes? yes/no", "CheckForUpdate", $CheckForUpdate)
	IniWrite($iniFile, "Update Check Interval in Minutes 05-59", "UpdateInterval", $UpdateInterval)
	IniWrite($iniFile, "Daily Restart Hours? 00-23", "HotHour1", $HotHour1)
	IniWrite($iniFile, "Daily Restart Hours? 00-23", "HotHour2", $HotHour2)
	IniWrite($iniFile, "Daily Restart Hours? 00-23", "HotHour3", $HotHour3)
	IniWrite($iniFile, "Daily Restart Hours? 00-23", "HotHour4", $HotHour4)
	IniWrite($iniFile, "Daily Restart Hours? 00-23", "HotHour5", $HotHour5)
	IniWrite($iniFile, "Daily Restart Hours? 00-23", "HotHour6", $HotHour6)
	IniWrite($iniFile, "Daily Restart Minute? 00-59", "HotMin", $HotMin)
	IniWrite($iniFile, "Excessive Memory Amount?", "ExMem", $ExMem)
	IniWrite($iniFile, "Restart On Excessive Memory Use? yes/no", "ExMemRestart", $ExMemRestart)
	IniWrite($iniFile, "Running Server with Steam Open? (yes/no)", "SteamFix", $SteamFix)
	IniWrite($iniFile, "Rotate X Number of Logs every X Hours? yes/no", "logRotate", $logRotate)
	IniWrite($iniFile, "Rotate X Number of Logs every X Hours? yes/no", "logQuantity", $logQuantity)
	IniWrite($iniFile, "Rotate X Number of Logs every X Hours? yes/no", "logHoursBetweenRotate", $logHoursBetweenRotate)
	IniWrite($iniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "UseDiscordBot", $sUseDiscordBot)
	IniWrite($iniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordWebHookURL", $sDiscordWebHookURL)
	IniWrite($iniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotName", $sDiscordBotName)
	IniWrite($iniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotUseTTS", $bDiscordBotUseTTS)
	IniWrite($iniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotAvatarLink", $sDiscordBotAvatar)
	IniWrite($iniFile, "Use Discord Bot to Send Message Before Restart? yes/no", "DiscordBotTimeBeforeRestart", $iDiscordBotNotifyTime)
	IniWrite($iniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "UseTwitchBot", $sUseTwitchBot)
	IniWrite($iniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "TwitchNick", $sTwitchNick)
	IniWrite($iniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "ChatOAuth", $sChatOAuth)
	IniWrite($iniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "TwitchChannels", $sTwitchChannels)
	IniWrite($iniFile, "Use Twitch Bot to Send Message Before Restart? yes/no", "TwitchBotNotifyTime", $iTwitchBotNotifyTime)
EndFunc   ;==>UpdateIni
#EndRegion ;**** INI Settings - User Variables ****

Func Gamercide()
	If @exitMethod <> 1 Then
		$Shutdown = MsgBox(4100, "Shut Down?", "Do you wish to shutdown Server " & $ServerName & "? (PID: " & $ConanPID & ")", 60)
		If $Shutdown = 6 Then
			FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Server Shutdown - Intiated by User when closing ConanServerUtility Script")
			CloseServer()
		EndIf
		MsgBox(4096, "Thanks for using our Application", "Please visit us at https://gamercide.com", 2)
		FileWriteLine($logFile, _NowCalc() & " ConanServerUtility Stopped by User")
	Else
		FileWriteLine($logFile, _NowCalc() & " ConanServerUtility Stopped")
	EndIf
	If $UseRemoteRestart = "yes" Then
		TCPShutdown()
	EndIf
	Exit
EndFunc   ;==>Gamercide

Func CloseServer()
	If WinExists($ConanhWnd) Then
		ControlSend($ConanhWnd, "", "", "I" & @CR)
		ControlSend($ConanhWnd, "", "", "I" & @CR)
		ControlSend($ConanhWnd, "", "", "^C")
		FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Server Window Found - Sending Ctrl+C for Clean Shutdown")
		WinWaitClose($ConanhWnd, "", 60)
	EndIf
	If ProcessExists($ConanPID) Then
		FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Server Did not Shut Down Properly. Killing Process")
		ProcessClose($ConanPID)
	EndIf
	If FileExists($PIDFile) Then
		FileDelete($PIDFile)
	EndIf
	If FileExists($hWndFile) Then
		FileDelete($hWndFile)
	EndIf
EndFunc   ;==>CloseServer

Func RotateLogs()
	Local $hCreateTime = _NowCalc()
	For $i = $logQuantity To 1 Step -1
		If FileExists($logFile & $i) Then
			$hCreateTime = FileGetTime($logFile & $i, 1)
			FileMove($logFile & $i, $logFile & ($i + 1), 1)
			FileSetTime($logFile & ($i + 1), $hCreateTime, 1)
		EndIf
	Next
	If FileExists($logFile & ($logQuantity + 1)) Then
		FileDelete($logFile & ($logQuantity + 1))
	EndIf
	If FileExists($logFile) Then
		$hCreateTime = FileGetTime($logFile, 1)
		FileMove($logFile, $logFile & "1", 1)
		FileSetTime($logFile & "1", $hCreateTime, 1)
		FileWriteLine($logFile, _NowCalc() & " Log Files Rotated")
		FileSetTime($logFile, @YEAR & @MON & @MDAY, 1)
	EndIf
EndFunc   ;==>RotateLogs

#Region ;**** Function to Send Message to Discord ****
Func _Discord_ErrFunc($oError)
	FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Error: 0x" & Hex($oError.number) & " While Sending Discord Bot Message.")
EndFunc   ;==>_Discord_ErrFunc

Func SendDiscordMsg($sHookURL, $sBotMessage, $sBotName = "", $sBotTTS = False, $sBotAvatar = "")
	Local $oErrorHandler = ObjEvent("AutoIt.Error", "_Discord_ErrFunc")
	Local $sJsonMessage = '{"content" : "' & $sBotMessage & '", "username" : "' & $sBotName & '", "tts" : "' & $sBotTTS & '", "avatar_url" : "' & $sBotAvatar & '"}'
	Local $oHTTPOST = ObjCreate("WinHttp.WinHttpRequest.5.1")
	$oHTTPOST.Open("POST", $sHookURL & "?wait=true", False)
	$oHTTPOST.SetRequestHeader("Content-Type", "application/json")
	$oHTTPOST.Send($sJsonMessage)
	Local $oStatusCode = $oHTTPOST.Status
	Local $oResponseText = $oHTTPOST.ResponseText
	FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] [Discord Bot] Message Status Code {" & $oStatusCode & "} Message Response " & $oResponseText)
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
		FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] [Twitch Bot] Successfully Connected to Twitch IRC")
		If $aTwitchIRC[1] Then
			FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] [Twitch Bot] Username and OAuth Accepted. [" & $aTwitchIRC[2] & "]")
			If $aTwitchIRC[3] Then
				FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] [Twitch Bot] Successfully sent ( " & $sT_Msg & " ) to all Channels")
			Else
				FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] [Twitch Bot] ERROR | Failed sending message ( " & $sT_Msg & " ) to one or more channels")
			EndIf
		Else
			FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] [Twitch Bot] ERROR | Username and OAuth Denied [" & $aTwitchIRC[2] & "]")
		EndIf
	Else
		FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] [Twitch Bot] ERROR | Could not connect to Twitch IRC. Is this URL or port blocked? [irc.chat.twitch.tv:6667]")
	EndIf
EndFunc   ;==>TwitchMsgLog
#EndRegion ;**** Post to Twitch Chat Function ****

#Region ;**** Functions to Check for Update ****
Func _GetRSS_ErrFunc($oError)
	If Not IsDeclared("iMsgBoxAnswer") Then Local $iMsgBoxAnswer
	$iMsgBoxAnswer = MsgBox(4, "Error: 0x" & Hex($oError.number), "Something went wrong checking for the Server Update." & @CRLF & @CRLF & "Check the Log files for more information" & @CRLF & @CRLF & "This window will close and script will continue in 60 seconds." & @CRLF & @CRLF & "Close Script Now?", 60)
	Select
		Case $iMsgBoxAnswer = 6 ;Yes
			FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Update Check Failed - ConanServerUtility Shutdown - Intiated by User")
			$iShutdown = 1
		Case $iMsgBoxAnswer = 7 ;No
			FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Update Check Failed - User Input - Script Continuing. Update check will be ran again at set interval.")
		Case $iMsgBoxAnswer = -1 ;Timeout
			FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Update Check Failed - No User Input - Script Continuing. Update check will be ran again at set interval.")
	EndSelect
EndFunc   ;==>_GetRSS_ErrFunc

Func GetRSS()
	Local $oErrorHandler = ObjEvent("AutoIt.Error", "_GetRSS_ErrFunc")
	Local $oXML = ObjCreate("Microsoft.XMLHTTP")
	If @error Then
		FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Error Creating HTTP XML Object")
		If $iShutdown = 1 Then Exit
		Return
	EndIf
	$oXML.Open("GET", "http://steamcommunity.com/games/440900/rss/", 0)
	$oXML.Send
	If @error Then
		FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Error Sending GET Request to http://steamcommunity.com/games/440900/rss/")
		If $iShutdown = 1 Then Exit
		Return
	EndIf
	$sFile = _TempFile(@ScriptDir, '~', '.xml')
	FileWrite($sFile, $oXML.responseText)
EndFunc   ;==>GetRSS

Func ParseRSS()
	$sXML = $sFile
	Local $oXML = ObjCreate("Microsoft.XMLDOM")
	$oXML.Load($sXML)
	Local $oNames = $oXML.selectNodes("//rss/channel/item/title")
	;Local $aMyDate, $aMyTime
	;_DateTimeSplit(_NowCalc(), $aMyDate, $aMyTime)
	;Local $cDate = "PATCH " & StringFormat("%02i.%02i.%04i", $aMyDate[3], $aMyDate[2], $aMyDate[1])
	Local $cFile = @ScriptDir & "\ConanServerUtility_LastUpdate.txt"
	Local $bReturn = False
	For $oName In $oNames
		If StringRegExp($oName.text, "(?i)PATCH(?i)") Then
			FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Update released today. Is the server up to date?")
			If FileRead($cFile) = $oName.text Then
				FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Server is Up to Date")
				ExitLoop
			Else
				FileDelete($cFile)
				FileWrite($cFile, $oName.text)
				If ProcessExists($ConanPID) Then
					FileWriteLine($logFile, _NowCalc() & " New Update [" & $oName.text & "] Found for Server [" & $ServerName & " (PID: " & $ConanPID & ")]")
					;CloseServer()
					$bReturn = True
				EndIf
				ExitLoop
			EndIf
		EndIf
	Next
	If $bReturn Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>ParseRSS

Func UpdateCheck()
	FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Update Check Starting. Will Log if Update Found.")
	GetRSS()
	If FileExists($sFile) Then
		Local $bUpdate = ParseRSS()
		FileDelete($sFile)
		If $bUpdate Then
			Return True
		Else
			Return False
		EndIf
	Else
		Return False
	EndIf
EndFunc   ;==>UpdateCheck
#EndRegion ;**** Functions to Check for Update ****

#Region ;**** Functions for Multiple Passwords and Hiding Password
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
#EndRegion ;**** Functions for Multiple Passwords and Hiding Password

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

OnAutoItExitRegister("Gamercide")
FileWriteLine($logFile, _NowCalc() & " ConanServerUtility Script V2.8.6.2 Started")
ReadUini()

If $UseSteamCMD = "yes" Then
	Local $sFileExists = FileExists($steamcmddir & "\steamcmd.exe")
	If $sFileExists = 0 Then
		MsgBox(0x0, "SteamCMD Not Found", "Could not find steamcmd.exe at " & $steamcmddir)
		Exit
	EndIf
	Local $sManifestExists = FileExists($steamcmddir & "\steamapps\appmanifest_443030.acf")
	If $sManifestExists = 1 Then
		Local $manifestFound = MsgBox(4100, "Warning", "Install manifest found at " & $steamcmddir & "\steamapps\appmanifest_443030.acf" & @CRLF & @CRLF & "Suggest moving file to " & _
				$serverdir & "\steamapps\appmanifest_443030.acf before running SteamCMD" & @CRLF & @CRLF & "Would you like to Exit Now?", 20)
		If $manifestFound = 6 Then
			Exit
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
		FileWriteLine($logFile, _NowCalc() & " Remote Restart Enabled. Could not bind to " & $g_IP & ":" & $g_Port)
		Exit
	Else
		FileWriteLine($logFile, _NowCalc() & " Remote Restart Enabled. Listening for Restart Request at " & $g_IP & ":" & $g_Port)
	EndIf
EndIf

While True
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
					If ProcessExists($ConanPID) Then
						Local $IP = _TCP_Server_ClientIP($ConnectedSocket)
						Local $MEM = ProcessGetStats($ConanPID, 0)
						FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] [Work Memory:" & $MEM[0] & " | Peak Memory:" & $MEM[1] & "] Restart Requested by Remote Host: " & $IP & " | User: " & $aPassCompare[1] & " | Pass: " & $aPassCompare[2])
						CloseServer()
						Sleep(10000)
						ExitLoop
					EndIf
				Else
					Local $IP = _TCP_Server_ClientIP($ConnectedSocket)
					FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Restart ATTEMPT by Remote Host: " & $IP & " | Unknown Restart Code: " & $sRECV)
					ExitLoop
				EndIf
				$Count += 1
				Sleep(1000)
			WEnd
			If $ConnectedSocket <> -1 Then TCPCloseSocket($ConnectedSocket)
		EndIf
	EndIf


	If Not ProcessExists($ConanPID) Then
		$iBeginDelayedShutdown = 0
		If $UseSteamCMD = "yes" Then
			If $validategame = "yes" Then
				FileWriteLine($logFile, _NowCalc() & " Running SteamCMD with validate. [steamcmd.exe +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir " & $serverdir & " +app_update 443030 validate +quit]")
				RunWait("" & $steamcmddir & "\steamcmd.exe +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir " & $serverdir & " +app_update 443030 validate +quit")
			Else
				FileWriteLine($logFile, _NowCalc() & " Running SteamCMD without validate. [steamcmd.exe +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir " & $serverdir & " +app_update 443030 +quit]")
				RunWait("" & $steamcmddir & "\steamcmd.exe +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir " & $serverdir & " +app_update 443030 +quit")
			EndIf
		EndIf
		If $CheckForUpdate = "yes" Then
			Local $bFirstCheck = UpdateCheck()
			If (Not $bFirstCheck) Then
				FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Server is Up to Date. ")
			EndIf
		EndIf
		If $BindIP = "no" Then
			$ConanPID = Run("" & $serverdir & "\ConanSandbox\Binaries\Win64\" & $Server_EXE & " ConanSandBox -Port=" & $GamePort & " -QueryPort=" & $QueryPort & " -MaxPlayers=" & $MaxPlayers & " -AdminPassword=" & $AdminPass & " -ServerPassword=" & $ServerPass & " -ServerName=""" & $ServerName & """ -listen -nosteamclient -game -server -log")
			If $sObfuscatePass = "yes" Then
				FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Started [" & $Server_EXE & " ConanSandBox -Port=" & $GamePort & " -QueryPort=" & $QueryPort & " -MaxPlayers=" & $MaxPlayers & " -AdminPassword=" & ObfPass($AdminPass) & " -ServerPassword=" & ObfPass($ServerPass) & " -ServerName=""" & $ServerName & """ -listen -nosteamclient -game -server -log]")
			Else
				FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Started [" & $Server_EXE & " ConanSandBox -Port=" & $GamePort & " -QueryPort=" & $QueryPort & " -MaxPlayers=" & $MaxPlayers & " -AdminPassword=" & $AdminPass & " -ServerPassword=" & $ServerPass & " -ServerName=""" & $ServerName & """ -listen -nosteamclient -game -server -log]")
			EndIf
		Else
			$ConanPID = Run("" & $serverdir & "\ConanSandbox\Binaries\Win64\" & $Server_EXE & " ConanSandBox -MULTIHOME=" & $g_IP & " -Port=" & $GamePort & " -QueryPort=" & $QueryPort & " -MaxPlayers=" & $MaxPlayers & " -AdminPassword=" & $AdminPass & " -ServerPassword=" & $ServerPass & " -ServerName=""" & $ServerName & """ -listen -nosteamclient -game -server -log")
			If $sObfuscatePass = "yes" Then
				FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Started [" & $Server_EXE & " ConanSandBox -MULTIHOME=" & $g_IP & " -Port=" & $GamePort & " -QueryPort=" & $QueryPort & " -MaxPlayers=" & $MaxPlayers & " -AdminPassword=" & ObfPass($AdminPass) & " -ServerPassword=" & ObfPass($ServerPass) & " -ServerName=""" & $ServerName & """ -listen -nosteamclient -game -server -log]")
			Else
				FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Started [" & $Server_EXE & " ConanSandBox -MULTIHOME=" & $g_IP & " -Port=" & $GamePort & " -QueryPort=" & $QueryPort & " -MaxPlayers=" & $MaxPlayers & " -AdminPassword=" & $AdminPass & " -ServerPassword=" & $ServerPass & " -ServerName=""" & $ServerName & """ -listen -nosteamclient -game -server -log]")
			EndIf
		EndIf
		If @error Or Not $ConanPID Then
			If Not IsDeclared("iMsgBoxAnswer") Then Local $iMsgBoxAnswer
			$iMsgBoxAnswer = MsgBox(262405, "Server Failed to Start", "The server tried to start, but it failed. Try again? This will automatically close in 60 seconds and try to start again.", 60)
			Select
				Case $iMsgBoxAnswer = 4 ;Retry
					FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Server Failed to Start. User Initiated a Restart Attempt.")
				Case $iMsgBoxAnswer = 2 ;Cancel
					FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Server Failed to Start - ConanServerUtility Shutdown - Intiated by User")
					Exit
				Case $iMsgBoxAnswer = -1 ;Timeout
					FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Server Failed to Start. Script Initiated Restart Attempt after 60 seconds of no User Input.")
			EndSelect
		EndIf
		$ConanhWnd = WinGetHandle(WinWait("" & $serverdir & "", "", 70))
		If $SteamFix = "yes" Then
			WinWait("" & $Server_EXE & " - Entry Point Not Found", "", 5)
			If WinExists("" & $Server_EXE & " - Entry Point Not Found") Then
				ControlSend("" & $Server_EXE & " - Entry Point Not Found", "", "", "{enter}")
			EndIf
			WinWait("" & $Server_EXE & " - Entry Point Not Found", "", 5)
			If WinExists("" & $Server_EXE & " - Entry Point Not Found") Then
				ControlSend("" & $Server_EXE & " - Entry Point Not Found", "", "", "{enter}")
			EndIf
		EndIf
		If FileExists($PIDFile) Then
			FileDelete($PIDFile)
		EndIf
		If FileExists($hWndFile) Then
			FileDelete($hWndFile)
		EndIf
		FileWrite($PIDFile, $ConanPID)
		FileWrite($hWndFile, String($ConanhWnd))
		FileSetAttrib($PIDFile, "+HT")
		FileSetAttrib($hWndFile, "+HT")
		FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Window Handle Found: " & $ConanhWnd)
	ElseIf ((_DateDiff('n', $timeCheck1, _NowCalc())) >= 5) Then
		Local $MEM = ProcessGetStats($ConanPID, 0)
		If $MEM[0] > $ExMem And $ExMemRestart = "no" Then
			FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] --Work Memory:" & $MEM[0] & " --Peak Memory:" & $MEM[1])
		ElseIf $MEM[0] > $ExMem And $ExMemRestart = "yes" Then
			FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] --Work Memory:" & $MEM[0] & " --Peak Memory:" & $MEM[1] & " Excessive Memory Use - Restart Requested by ConanServerUtility Script")
			CloseServer()
		EndIf
		$timeCheck1 = _NowCalc()
	EndIf

	If ((@HOUR = $HotHour1 Or @HOUR = $HotHour2 Or @HOUR = $HotHour3 Or @HOUR = $HotHour4 Or @HOUR = $HotHour5 Or @HOUR = $HotHour6) And @MIN = $HotMin And $RestartDaily = "yes" And ((_DateDiff('n', $timeCheck2, _NowCalc())) >= 1)) And ($iBeginDelayedShutdown = 0) Then
		If ProcessExists($ConanPID) Then
			Local $MEM = ProcessGetStats($ConanPID, 0)
			FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] --Work Memory:" & $MEM[0] & " --Peak Memory:" & $MEM[1] & " - Daily Restart Requested by ConanServerUtility Script")
			If ($sUseDiscordBot = "yes") Or ($sUseTwitchBot = "yes") Then
				$iBeginDelayedShutdown = 1
				$mNextCheck = _NowCalc
			Else
				CloseServer()
			EndIf
		EndIf
		$timeCheck2 = _NowCalc()
	EndIf

	If ($CheckForUpdate = "yes") And ((_DateDiff('n', $mNextCheck, _NowCalc())) >= $UpdateInterval) And ($iBeginDelayedShutdown = 0) Then
		Local $bRestart = UpdateCheck()
		If (Not $bRestart) Then
			FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Server is Up to Date")
		ElseIf $bRestart And ($sUseDiscordBot = "yes") Or ($sUseTwitchBot = "yes") Then
			$iBeginDelayedShutdown = 1
		Else
			CloseServer()
		EndIf
		$mNextCheck = _NowCalc()
	EndIf

	If ($sUseDiscordBot = "yes") Or ($sUseTwitchBot = "yes") Then
		If $iBeginDelayedShutdown = 1 Then
			FileWriteLine($logFile, _NowCalc() & " [" & $ServerName & " (PID: " & $ConanPID & ")] Bot in Use. Delaying Shutdown for " & $iDelayShutdownTime & " minutes. Notifying Channel")
			Local $sShutdownMessage = $ServerName & " Restarting in " & $iDelayShutdownTime & " minutes"
			If $sUseDiscordBot = "yes" Then
				SendDiscordMsg($sDiscordWebHookURL, $sShutdownMessage, $sDiscordBotName, $bDiscordBotUseTTS, $sDiscordBotAvatar)
			EndIf
			If $sUseTwitchBot = "yes" Then
				TwitchMsgLog($sShutdownMessage)
			EndIf
			$iBeginDelayedShutdown = 2
			$mNextCheck = _NowCalc()
		ElseIf ($iBeginDelayedShutdown >= 2 And ((_DateDiff('n', $mNextCheck, _NowCalc())) >= $iDelayShutdownTime)) Then
			Local $sShutdownMessage = $ServerName & " Restarting NOW"
			If $sUseDiscordBot = "yes" Then
				SendDiscordMsg($sDiscordWebHookURL, $sShutdownMessage, $sDiscordBotName, $bDiscordBotUseTTS, $sDiscordBotAvatar)
			EndIf
			If $sUseTwitchBot = "yes" Then
				TwitchMsgLog($sShutdownMessage)
			EndIf
			$iBeginDelayedShutdown = 0
			$mNextCheck = _NowCalc()
			CloseServer()
		ElseIf $iBeginDelayedShutdown = 2 And ((_DateDiff('n', $mNextCheck, _NowCalc())) >= ($iDelayShutdownTime - 1)) Then
			Local $sShutdownMessage = $ServerName & " Restarting in 1 minute. Final Warning"
			If $sUseDiscordBot = "yes" Then
				SendDiscordMsg($sDiscordWebHookURL, $sShutdownMessage, $sDiscordBotName, $bDiscordBotUseTTS, $sDiscordBotAvatar)
			EndIf
			If $sUseTwitchBot = "yes" Then
				TwitchMsgLog($sShutdownMessage)
			EndIf
			$iBeginDelayedShutdown = 3
		EndIf
	Else
		$iBeginDelayedShutdown = 0
	EndIf

	If ($logRotate = "yes") And ((_DateDiff('h', $logStartTime, _NowCalc())) >= 1) Then
		If Not FileExists($logFile) Then
			FileWriteLine($logFile, $logStartTime & " Log File Created")
			FileSetTime($logFile, @YEAR & @MON & @MDAY, 1)
		EndIf
		Local $logFileTime = FileGetTime($logFile, 1)
		Local $logTimeSinceCreation = _DateDiff('h', $logFileTime[0] & "/" & $logFileTime[1] & "/" & $logFileTime[2] & " " & $logFileTime[3] & ":" & $logFileTime[4] & ":" & $logFileTime[5], _NowCalc())
		If $logTimeSinceCreation >= $logHoursBetweenRotate Then
			RotateLogs()
		EndIf
		$logStartTime = _NowCalc()
	EndIf

	Sleep(1000)
WEnd
