#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=favicon.ico
#AutoIt3Wrapper_Res_Comment=By Dateranoth - Feburary 6, 2017
#AutoIt3Wrapper_Res_Description=Utility for Running Conan Server
#AutoIt3Wrapper_Res_Fileversion=2.2.2.0
#AutoIt3Wrapper_Res_LegalCopyright=Dateranoth @ https://gamercide.com
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;By Dateranoth - Feburary 6, 2017
;Used by https://gamercide.com on their server
;Feel free to change, adapt, and distribute

#include <Date.au3>
#include <Process.au3>
#include <MsgBoxConstants.au3>
#include <File.au3>
Opt("WinTitleMatchMode", 1) ;1=start, 2=subStr, 3=exact, 4=advanced, -1 to -4=Nocase

;User Variables
If FileExists("ConanServerUtility.ini") Then
   Local $BindIP = IniRead("ConanServerUtility.ini", "Use MULTIHOME to Bind IP? Disable if having connection issues (yes/no)", "BindIP", "yes")
   Local $g_IP = IniRead("ConanServerUtility.ini", "Game Server IP", "ListenIP", "127.0.0.1")
   Local $GamePort = IniRead("ConanServerUtility.ini", "Game Server Port", "GamePort", "27015")
   Local $AdminPass = IniRead("ConanServerUtility.ini", "Admin Password", "AdminPass", "yOuRpaSHeRe")
   Local $MaxPlayers = IniRead("ConanServerUtility.ini", "Max Players", "MaxPlayers", "20")
   Local $serverdir = IniRead("ConanServerUtility.ini", "Server Directory. NO TRAILING SLASH", "serverdir", "C:\Game_Servers\Conan_Exiles_Server")
   Local $UseSteamCMD = IniRead("ConanServerUtility.ini", "Use SteamCMD To Update Server? yes/no", "UseSteamCMD", "yes")
   Local $steamcmddir = IniRead("ConanServerUtility.ini", "SteamCMD Directory. NO TRAILING SLASH", "steamcmddir", "C:\Game_Servers\SteamCMD")
   Local $UseRemoteRestart = IniRead("ConanServerUtility.ini", "Use Remote Restart ?yes/no", "UseRemoteRestart", "no")
   Local $g_Port = IniRead("ConanServerUtility.ini", "Remote Restart Port", "ListenPort", "57520")
   Local $RestartCode = IniRead("ConanServerUtility.ini", "Remote Restart Password", "RestartCode", "FVtb2DXgp8SYwj7J")
   Local $RestartDaily = IniRead("ConanServerUtility.ini", "Restart Server Daily? yes/no", "RestartDaily", "no")
   Local $CheckForUpdate = IniRead("ConanServerUtility.ini", "Check for Update Every Hour? yes/no", "CheckForUpdate", "yes")
   Local $HotHour1 = IniRead("ConanServerUtility.ini", "Daily Restart Hours? 00-23", "HotHour1", "00")
   Local $HotHour2 = IniRead("ConanServerUtility.ini", "Daily Restart Hours? 00-23", "HotHour2", "00")
   Local $HotHour3 = IniRead("ConanServerUtility.ini", "Daily Restart Hours? 00-23", "HotHour3", "00")
   Local $HotHour4 = IniRead("ConanServerUtility.ini", "Daily Restart Hours? 00-23", "HotHour4", "00")
   Local $HotHour5 = IniRead("ConanServerUtility.ini", "Daily Restart Hours? 00-23", "HotHour5", "00")
   Local $HotHour6 = IniRead("ConanServerUtility.ini", "Daily Restart Hours? 00-23", "HotHour6", "00")
   Local $HotMin = IniRead("ConanServerUtility.ini", "Daily Restart Minute? 00-59", "HotMin", "01")
   Local $ExMem = IniRead("ConanServerUtility.ini", "Excessive Memory Amount?", "ExMem", "6000000000")
   Local $ExMemRestart = IniRead("ConanServerUtility.ini", "Restart On Excessive Memory Use? yes/no", "ExMemRestart", "no")
   Local $SteamFix = IniRead("ConanServerUtility.ini", "Running Server with Steam Open? (yes/no)", "SteamFix", "no")
Else
   IniWrite("ConanServerUtility.ini", "Use MULTIHOME to Bind IP? Disable if having connection issues (yes/no)", "BindIP", "yes")
   IniWrite("ConanServerUtility.ini", "Game Server IP", "ListenIP", "127.0.0.1")
   IniWrite("ConanServerUtility.ini", "Game Server Port", "GamePort", "27015")
   IniWrite("ConanServerUtility.ini", "Admin Password", "AdminPass", "yOuRpaSHeRe")
   IniWrite("ConanServerUtility.ini", "Max Players", "MaxPlayers", "20")
   IniWrite("ConanServerUtility.ini", "Server Directory. NO TRAILING SLASH", "serverdir", "C:\Game_Servers\Conan_Exiles_Server")
   IniWrite("ConanServerUtility.ini", "Use SteamCMD To Update Server? yes/no", "UseSteamCMD", "yes")
   IniWrite("ConanServerUtility.ini", "SteamCMD Directory. NO TRAILING SLASH", "steamcmddir", "C:\Game_Servers\SteamCMD")
   IniWrite("ConanServerUtility.ini", "Use Remote Restart ?yes/no", "UseRemoteRestart", "no")
   IniWrite("ConanServerUtility.ini", "Remote Restart Port", "ListenPort", "57520")
   IniWrite("ConanServerUtility.ini", "Remote Restart Password", "RestartCode", "FVtb2DXgp8SYwj7J")
   IniWrite("ConanServerUtility.ini", "Restart Server Daily? yes/no", "RestartDaily", "no")
   IniWrite("ConanServerUtility.ini", "Check for Update Every Hour? yes/no", "CheckForUpdate", "yes")
   IniWrite("ConanServerUtility.ini", "Daily Restart Hours? 00-23", "HotHour1", "00")
   IniWrite("ConanServerUtility.ini", "Daily Restart Hours? 00-23", "HotHour2", "00")
   IniWrite("ConanServerUtility.ini", "Daily Restart Hours? 00-23", "HotHour3", "00")
   IniWrite("ConanServerUtility.ini", "Daily Restart Hours? 00-23", "HotHour4", "00")
   IniWrite("ConanServerUtility.ini", "Daily Restart Hours? 00-23", "HotHour5", "00")
   IniWrite("ConanServerUtility.ini", "Daily Restart Hours? 00-23", "HotHour6", "00")
   IniWrite("ConanServerUtility.ini", "Daily Restart Minute? 00-59", "HotMin", "01")
   IniWrite("ConanServerUtility.ini", "Excessive Memory Amount?", "ExMem", "6000000000")
   IniWrite("ConanServerUtility.ini", "Restart On Excessive Memory Use? yes/no", "ExMemRestart", "no")
   IniWrite("ConanServerUtility.ini", "Running Server with Steam Open? (yes/no)", "SteamFix", "no")
   MsgBox(4096, "Default INI File Made", "Please Modify Default Values and Restart Script")
   Exit
EndIf

OnAutoItExitRegister("Gamercide")

Global $sFile = ""
Global $Server_EXE = "ConanSandboxServer-Win64-Test.exe"
Global $PIDFile = @ScriptDir &"\ConanServerUtility_lastpid_tmp"
Global $hWndFile = @ScriptDir &"\ConanServerUtility_lasthwnd_tmp"
If FileExists($PIDFile) Then
	Global $ConanPID = FileRead($PIDFile)
	Global $ConanhWnd = HWnd(FileRead($hWndFile))
Else
	Global $ConanPID = "0"
	Global $ConanhWnd = "0"
EndIf

Func Gamercide()
	If @exitMethod <> 1 Then
	$Shutdown = MsgBox(4100, "Shut Down?","Do you wish to shutdown the server?",10)
		If $Shutdown = 6 Then
			FileWriteLine(@ScriptDir & "\ConanServerUtility_RestartLog.txt", @YEAR &"-"& @MON &"-"& @MDAY &" "& @HOUR &":"& @MIN &" Server Shutdown by User Input from ConanServerUtility Script")
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
    Local $cDate = "PATCH "& StringFormat("%02d", $aMyDate[3]) &"."& StringFormat("%02d", $aMyDate[2]) &"."& StringFormat("%04d", $aMyDate[1])
	Local $cFile = @ScriptDir &"\ConanServerUtility_LastUpdate.txt"
	For $oName In $oNames

		If StringRegExp($oName.text,$cDate&"(?i)") Then
				If FileRead($cFile) = $oName.text Then
					;ConsoleWrite("No New Update" & @CRLF)
					ExitLoop
				Else
					FileDelete($cFile)
					FileWrite($cFile,$oName.text)
					Local $PID = ProcessExists($ConanPID)
					If $PID Then
						FileWriteLine(@ScriptDir & "\ConanServerUtility_RestartLog.txt", @YEAR &"-"& @MON &"-"& @MDAY &" "& @HOUR &":"& @MIN &" ["& $oName.text &"] Restart for Update Requested by ConanServerUtility Script")
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

If $UseSteamCMD = "yes" Then
	Local $sFileExists = FileExists($steamcmddir &"\steamcmd.exe")
	If $sFileExists = 0 Then
		MsgBox ( 0x0, "SteamCMD Not Found", "Could not find steamcmd.exe at "& $steamcmddir)
		Exit
	EndIf

Else
	Local $cFileExists = FileExists($serverdir &"\ConanSandboxServer.exe")
	If $cFileExists = 0 Then
		MsgBox ( 0x0, "Conan Server Not Found", "Could not find ConanSandboxServer.exe at "& $serverdir)
		Exit
	EndIf
Endif


If $UseRemoteRestart = "yes" Then
; Start The TCP Services
TCPStartup()
Local $MainSocket = TCPListen($g_IP, $g_Port, 100)
	If $MainSocket = -1 Then
		MsgBox ( 0x0, "TCP Error", "Could not bind to [" &  $g_IP & "] Is this the correct Server IP?")
		Exit
		EndIf
EndIf

While True
If $UseRemoteRestart = "yes" Then
Local $ConnectedSocket = TCPAccept($MainSocket)
If $ConnectedSocket >= 0 Then
$Count = 0
While $Count < 30
$RECV = TCPRecv($ConnectedSocket,512)
$PassCompare = StringCompare($RECV, $RestartCode, 1)
   If $PassCompare = 0 Then
	  Local $PID = ProcessExists($ConanPID) ; Will return the PID or 0 if the process isn't found.
	  If $PID Then
		 Local $IP = _TCP_Server_ClientIP($ConnectedSocket)
		 Local $MEM = ProcessGetStats($PID, 0)
		 FileWriteLine(@ScriptDir & "\ConanServerUtility_RestartLog.txt", @YEAR &"-"& @MON &"-"& @MDAY &" "& @HOUR &":"& @MIN &" --Work Memory:"& $MEM[0] & _
		 " --Peak Memory:"& $MEM[1] &" Restart Requested by Remote Host: "& $IP)
		 CloseServer()
		 Sleep (10000)
		 ExitLoop
	  EndIf
	  Else
	    Local $IP = _TCP_Server_ClientIP($ConnectedSocket)
		FileWriteLine(@ScriptDir & "\ConanServerUtility_RestartLog.txt", @YEAR &"-"& @MON &"-"& @MDAY &" "& @HOUR &":"& @MIN &" Restart ATTEMPT by Remote Host: "& $IP &" WRONG PASSWORD: "& $RECV)
		ExitLoop
   EndIf
$Count += 1
Sleep (1000)
WEnd
If $ConnectedSocket <> -1 Then TCPCloseSocket($ConnectedSocket)
EndIf
EndIf


Local $PID = ProcessExists($ConanPID)
If $PID = 0 Then
	If $UseSteamCMD = "yes" Then
		RunWait(""& $steamcmddir &"\steamcmd.exe +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir "& $serverdir &" +app_update 443030 validate +quit")
	EndIf
	If $CheckForUpdate = "yes" Then
		UpdateCheck()
	EndIf
	If $BindIP = "no" Then
		$ConanPID = Run(""& $serverdir &"\ConanSandbox\Binaries\Win64\"& $Server_EXE &" ConanSandBox?QueryPort="& $GamePort &"?MaxPlayers="& $MaxPlayers &"?AdminPassword="& $AdminPass &"?listen -nosteamclient -game -server -log")
	Else
		$ConanPID = Run(""& $serverdir &"\ConanSandbox\Binaries\Win64\ConanSandboxServer-Win64-Test.exe ConanSandBox?MULTIHOME="& $g_IP &"?QueryPort="& $GamePort &"?MaxPlayers="& $MaxPlayers &"?AdminPassword="& $AdminPass &"?listen -nosteamclient -game -server -log")
	EndIf
	$ConanhWnd = WinGetHandle(WinWait(""& $serverdir &"", "", 70))
	If $SteamFix = "yes" Then
		WinWait(""& $Server_EXE &" - Entry Point Not Found","",5)
		If WinExists(""& $Server_EXE &" - Entry Point Not Found") Then
			ControlSend(""& $Server_EXE &" - Entry Point Not Found", "", "", "{enter}")
		EndIf
		WinWait(""& $Server_EXE &" - Entry Point Not Found","",5)
		If WinExists(""& $Server_EXE &" - Entry Point Not Found") Then
			ControlSend(""& $Server_EXE &" - Entry Point Not Found", "", "", "{enter}")
		EndIf
	EndIf
	FileDelete($PIDFile)
	FileDelete($hWndFile)
	FileWrite($PIDFile,$ConanPID)
	FileWrite($hWndFile,String($ConanhWnd))
	FileSetAttrib($PIDFile,"+HT")
	FileSetAttrib($hWndFile,"+HT")
Else
   Local $MEM = ProcessGetStats($PID, 0)
   If $MEM[0] > $ExMem And $ExMemRestart = "no" Then
	  FileWriteLine(@ScriptDir & "\ConanServerUtility_ExcessiveMemoryLog.txt", @YEAR &"-"& @MON &"-"& @MDAY &" "& @HOUR &":"& @MIN &" --Work Memory:"& $MEM[0] & _
        " --Peak Memory:"& $MEM[1])
	  Sleep (10000)
   ElseIf $MEM[0] > $ExMem And $ExMemRestart = "yes" Then
	  FileWriteLine(@ScriptDir & "\ConanServerUtility_RestartLog.txt", @YEAR &"-"& @MON &"-"& @MDAY &" "& @HOUR &":"& @MIN &" --Work Memory:"& $MEM[0] & _
	  " --Peak Memory:"& $MEM[1] &" Excessive Memory Use - Restart Requested by ConanServerUtility Script")
	  CloseServer()
	  Sleep (10000)
   EndIf
EndIf

If ((@HOUR = $HotHour1 Or @HOUR = $HotHour2 Or @HOUR = $HotHour3 Or @HOUR = $HotHour4 Or @HOUR = $HotHour5 Or @HOUR = $HotHour6) And @MIN = $HotMin And $RestartDaily = "yes") Then
   Local $PID = ProcessExists($ConanPID)
	  If $PID Then
		 Local $MEM = ProcessGetStats($PID, 0)
		 FileWriteLine(@ScriptDir & "\ConanServerUtility_RestartLog.txt", @YEAR &"-"& @MON &"-"& @MDAY &" "& @HOUR &":"& @MIN &" --Work Memory:"& $MEM[0] & _
		 " --Peak Memory:"& $MEM[1] &" Daily Restart Requested by ConanServerUtility Script")
		 CloseServer()
	  EndIf
   Sleep (10000)
EndIf

If @MIN = $HotMin And $CheckForUpdate = "yes" Then
	UpdateCheck()
	Sleep(70000)
EndIf

Sleep (500)
WEnd