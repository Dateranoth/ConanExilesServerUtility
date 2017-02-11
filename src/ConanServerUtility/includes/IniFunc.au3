;Originally written by Dateranoth for use
;by https://gamercide.com on their server
;Distributed Under GNU GENERAL PUBLIC LICENSE
;Functions for reading user settings from INI and creating INI
#include-once
#include <Date.au3>
Global $iniFile = @ScriptDir & "\ConanServerUtility.ini"
Global $iniFail = 0

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
		$RestartCode &= "_yourcode"
		$iniFail += 1
	EndIf
	If $iniCheck = $RestartDaily Then
		$RestartDaily = "no"
		$iniFail += 1
	EndIf
	If $iniCheck = $CheckForUpdate Then
		$CheckForUpdate = "yes"
		$iniFail += 1
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
	If $iniFail > 0 Then
		iniFileCheck()
	EndIf
EndFunc   ;==>ReadUini

Func iniFileCheck()
	If FileExists($iniFile) Then
		Local $aMyDate, $aMyTime
		_DateTimeSplit(_NowCalc(), $aMyDate, $aMyTime)
		Local $iniDate = StringFormat("%04i.%02i.%02i.%02i%02i", $aMyDate[1], $aMyDate[2], $aMyDate[3], $aMyTime[1], $aMyTime[2])
		FileMove($iniFile, $iniFile &"_"& $iniDate & ".bak", 1)
		UpdateIni()
		MsgBox(4096, "INI MISMATCH", "Found " & $iniFail & " Missing Variables" & @CRLF & @CRLF & "Backup created and all existing settings transfered to new INI." & @CRLF & @CRLF & "Modify INI and restart.")
	Else
		UpdateIni()
		MsgBox(4096, "Default INI File Made", "Please Modify Default Values and Restart Script")
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
EndFunc   ;==>UpdateIni

