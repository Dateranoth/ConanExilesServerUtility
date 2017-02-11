;Originally written by Dateranoth for use
;by https://gamercide.com on their server
;Distributed Under GNU GENERAL PUBLIC LICENSE
;General Functions for Utility. Moved to make navigation of main script easier.
Func Gamercide()
	If @exitMethod <> 1 Then
	$Shutdown = MsgBox(4100, "Shut Down?","Do you wish to shutdown the server?",10)
		If $Shutdown = 6 Then
			FileWriteLine($logFile,  _NowCalc() &" Server Shutdown by User Input from ConanServerUtility Script")
			CloseServer()
		EndIf
		MsgBox(4096, "Thanks for using our Application", "Please visit us at https://gamercide.com",2)
	EndIf
	If $UseRemoteRestart = "yes" Then
		TCPShutdown()
	EndIf
	Exit
EndFunc

Func CloseServer()
	Local $PID = ProcessExists($ConanPID)
	ControlSend($ConanhWnd, "", "", "I" & @CR)
	ControlSend($ConanhWnd, "", "", "I" & @CR)
	ControlSend($ConanhWnd, "", "", "^C")
	WinWaitClose($ConanhWnd, "", 60)
	If $PID Then
		ProcessClose($PID)
    EndIf
	FileDelete($PIDFile)
	FileDelete($hWndFile)
EndFunc

Func RotateLogs()
	For $i = $logQuantity To 1 Step -1
		ConsoleWrite($logFile & $i)
		ConsoleWrite(@CRLF)
		If FileExists($logFile & $i) Then
			FileMove($logFile & $i,$logFile & ($i+1),1)
		EndIf
	Next
	If FileExists($logFile & ($logQuantity+1)) Then
		FileDelete($logFile & ($logQuantity+1))
	EndIf
	If FileExists($logFile) Then
		FileMove($logFile,$logFile & "1",1)
		FileWriteLine($logFile, _NowCalc() &" Log Files Rotated")
	EndIf
EndFunc

Func GetRSS()
	Local $oXML = ObjCreate("Microsoft.XMLHTTP")
	$oXML.Open("GET", "http://steamcommunity.com/games/440900/rss/", 0)
	$oXML.Send

	$sFile = _TempFile(@ScriptDir, '~', '.xml')
	FileWrite($sFile, $oXML.responseText)
EndFunc

Func ParseRSS()
	$sXML = $sFile
	Local $oXML = ObjCreate("Microsoft.XMLDOM")
	$oXML.Load($sXML)
	Local $oNames = $oXML.selectNodes("//rss/channel/item/title")
	Local $aMyDate, $aMyTime
	_DateTimeSplit(_NowCalc(), $aMyDate, $aMyTime)
    Local $cDate = "PATCH "& StringFormat("%02i.%02i.%04i", $aMyDate[3], $aMyDate[2], $aMyDate[1])
	Local $cFile = @ScriptDir &"\ConanServerUtility_LastUpdate.txt"
	For $oName In $oNames

		If StringRegExp($oName.text,"(?i)"& $cDate &"(?i)") Then
				If FileRead($cFile) = $oName.text Then
					;ConsoleWrite("No New Update" & @CRLF)
					ExitLoop
				Else
					FileDelete($cFile)
					FileWrite($cFile,$oName.text)
					Local $PID = ProcessExists($ConanPID)
					If $PID Then
						FileWriteLine($logFile, _NowCalc() &" ["& $oName.text &"] Restart for Update Requested by ConanServerUtility Script")
						CloseServer()
					EndIf
					ExitLoop
				EndIf
		EndIf
	Next
EndFunc

Func UpdateCheck()
	GetRSS()
	ParseRSS()
	FileDelete($sFile)
EndFunc

Func _TCP_Server_ClientIP($hSocket)
   Local $pSocketAddress, $aReturn
   $pSocketAddress = DllStructCreate("short;ushort;uint;char[8]")
   $aReturn = DllCall("ws2_32.dll", "int", "getpeername", "int", $hSocket, "ptr", DllStructGetPtr($pSocketAddress), "int*", DllStructGetSize($pSocketAddress))
   If @error Or $aReturn[0] <> 0 Then Return $hSocket
	  $aReturn = DllCall("ws2_32.dll", "str", "inet_ntoa", "int", DllStructGetData($pSocketAddress, 3))
   If @error Then Return $hSocket
	  $pSocketAddress = 0
   Return $aReturn[0]
EndFunc ;==>_TCP_Server_ClientIP