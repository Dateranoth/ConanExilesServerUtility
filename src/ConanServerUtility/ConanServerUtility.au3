#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\resources\favicon.ico
#AutoIt3Wrapper_Outfile=..\..\build\ConanServerUtility_x86_v3.1.1.exe
#AutoIt3Wrapper_Outfile_x64=..\..\build\ConanServerUtility_x64_v3.1.1.exe
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=By Dateranoth - April 24, 2018
#AutoIt3Wrapper_Res_Description=Utility for Running Conan Server
#AutoIt3Wrapper_Res_Fileversion=3.1.1
#AutoIt3Wrapper_Res_LegalCopyright=Dateranoth @ https://gamercide.com
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;Originally written by Dateranoth for use
;by https://gamercide.com on their server
;Distributed Under GNU GENERAL PUBLIC LICENSE

;RCON notifications will download external application mcrcon if enabled.
;Tiiffi/mcrcon is licensed under the zlib License
;https://github.com/Tiiffi/mcrcon/blob/master/LICENSE
;https://github.com/Tiiffi/mcrcon

#include <Date.au3>
#include "required\RemoteRestart.au3"
#include "required\UnZip.au3"
#include "required\UserSettingsIni.au3"

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
Global $g_iBeginDelayedShutdown = 0
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
		ControlSend($g_hConanhWnd, "", "", "^X" & @CR)
		ControlSend($g_hConanhWnd, "", "", "^X" & @CR)
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
		Local $sResponseText = ""
		If Not $g_bDebug Then
			$sResponseText = "Enable Debugging to See Full Response Message"
		Else
			$sResponseText = "Message Response: " & $oHTTPOST.ResponseText
		EndIf
		FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] [Discord Bot] Message Status Code {" & $oStatusCode & "} " & $sResponseText)
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

#Region ;*** MCRCON Commands
Func MCRCONcmd($l_sPath, $l_sIP, $l_sPort, $l_sPass, $l_sCommand, $l_sMessage = "")
	If $l_sCommand = "broadcast" Then
		RunWait('"' & @ComSpec & '" /c ' & $l_sPath & '\mcrcon.exe -c -s -H ' & $l_sIP & ' -P ' & $l_sPort & ' -p ' & $l_sPass & ' " broadcast ' & $l_sMessage & '"', $l_sPath, @SW_HIDE)
	EndIf
EndFunc   ;==>MCRCONcmd https://github.com/Tiiffi/mcrcon
#EndRegion ;*** MCRCON Commands


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

#Region ;**** Startup Checks. Initial Log, Read INI, Check for Correct Paths, Check Remote Restart is bound to port. ****
OnAutoItExitRegister("Gamercide")
FileWriteLine($g_c_sLogFile, _NowCalc() & " ConanServerUtility Script V3.1.1 Started")
ReadUini($g_c_sIniFile, $g_c_sLogFile)

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

If $g_sUseMCRCON = "yes" Then
	Local $sFileExists = FileExists($g_sMCrconPath & "\mcrcon.exe")
	If $sFileExists = 0 Then
		InetGet("https://github.com/Tiiffi/mcrcon/releases/download/v0.0.5/mcrcon-0.0.5-windows.zip", @ScriptDir & "\mcrcon.zip", 0)
		DirCreate($g_sMCrconPath) ; to extract to
		_ExtractZip(@ScriptDir & "\mcrcon.zip", "", "mcrcon.exe", $g_sMCrconPath)
		FileDelete(@ScriptDir & "\mcrcon.zip")
		If Not FileExists($g_sMCrconPath & "\mcrcon.exe") Then
			MsgBox(0x0, "MCRCON Not Found", "Could not find mcrcon.exe at " & $g_sMCrconPath)
			Exit
		EndIf
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
		Local $sRestart = _RemoteRestart($MainSocket, $RestartCode, $g_sRKey, $sObfuscatePass, $g_IP, $ServerName, $g_bDebug)
		Switch @error
			Case 0
				If ProcessExists($g_sConanPID) Then
					Local $MEM = ProcessGetStats($g_sConanPID, 0)
					FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] [Work Memory:" & $MEM[0] & " | Peak Memory:" & $MEM[1] & "] " & $sRestart)
					CloseServer()
				EndIf
			Case 1 To 4
				FileWriteLine($g_c_sLogFile, _NowCalc() & " " & $sRestart & @CRLF)
		EndSwitch
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
		If StringLen($g_sExtraServerCommands) > 0 Then
			$g_sExtraServerCommands = " " & $g_sExtraServerCommands
		EndIf
		If $BindIP = "no" Then
			$g_sConanPID = Run("" & $serverdir & "\ConanSandbox\Binaries\Win64\" & $g_c_sServerEXE & " ConanSandBox -Port=" & $GamePort & " -QueryPort=" & $QueryPort & " -RconEnabled=" & $g_iRconEnabled & " -RconPassword=" & $g_sRconPass & " -RconPort=" & $g_iRconPort & " -MaxPlayers=" & $MaxPlayers & " -ServerName=""" & $ServerName & """ -listen -nosteamclient -game -server -log" & $g_sExtraServerCommands)
			FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Started [" & $g_c_sServerEXE & " ConanSandBox -Port=" & $GamePort & " -QueryPort=" & $QueryPort & " -RconEnabled=" & $g_iRconEnabled & " -RconPassword=" & ObfPass($g_sRconPass) & " -RconPort=" & $g_iRconPort & " -MaxPlayers=" & $MaxPlayers & " -ServerName=""" & $ServerName & """ -listen -nosteamclient -game -server -log" & $g_sExtraServerCommands & "]")
		Else
			$g_sConanPID = Run("" & $serverdir & "\ConanSandbox\Binaries\Win64\" & $g_c_sServerEXE & " ConanSandBox -MULTIHOME=" & $g_IP & " -Port=" & $GamePort & " -QueryPort=" & $QueryPort & " -RconEnabled=" & $g_iRconEnabled & " -RconPassword=" & $g_sRconPass & " -RconPort=" & $g_iRconPort & " -MaxPlayers=" & $MaxPlayers & " -ServerName=""" & $ServerName & """ -listen -nosteamclient -game -server -log" & $g_sExtraServerCommands)
			FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Started [" & $g_c_sServerEXE & " ConanSandBox -MULTIHOME=" & $g_IP & " -Port=" & $GamePort & " -QueryPort=" & $QueryPort & " -RconEnabled=" & $g_iRconEnabled & " -RconPassword=" & ObfPass($g_sRconPass) & " -RconPort=" & $g_iRconPort & " -MaxPlayers=" & $MaxPlayers & " -ServerName=""" & $ServerName & """ -listen -nosteamclient -game -server -log" & $g_sExtraServerCommands & "]")
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

		$g_hConanhWnd = WinGetHandle(WinWait("" & $ServerName & "", "", 70))
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
		If $MEM[0] > $ExMem And $ExMemRestart = "no" And $g_bDebug Then
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
			If ($sUseDiscordBot = "yes") Or ($sUseTwitchBot = "yes") Or ($g_sUseMCRCON = "yes") Then
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
		If $bRestart And (($sUseDiscordBot = "yes") Or ($sUseTwitchBot = "yes") Or ($g_sUseMCRCON = "yes")) Then
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
	If ($sUseDiscordBot = "yes") Or ($sUseTwitchBot = "yes") Or ($g_sUseMCRCON = "yes") Then
		If $g_iBeginDelayedShutdown = 1 Then
			FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] Bot in Use. Delaying Shutdown for " & $g_iDelayShutdownTime & " minutes. Notifying Channel")
			Local $sShutdownMessage = $ServerName & " Restarting in " & $g_iDelayShutdownTime & " minutes"
			If $g_sUseMCRCON = "yes" Then
				MCRCONcmd($g_sMCrconPath, $g_IP, $g_iRconPort, $g_sRconPass, "broadcast", $sShutdownMessage)
				FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] [RCON] Sent ( " & $sShutdownMessage & " ) to Players")
			EndIf
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
			If $g_sUseMCRCON = "yes" Then
				MCRCONcmd($g_sMCrconPath, $g_IP, $g_iRconPort, $g_sRconPass, "broadcast", $sShutdownMessage)
				FileWriteLine($g_c_sLogFile, _NowCalc() & " [" & $ServerName & " (PID: " & $g_sConanPID & ")] [RCON] Sent ( " & $sShutdownMessage & " ) to Players")
			EndIf
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
