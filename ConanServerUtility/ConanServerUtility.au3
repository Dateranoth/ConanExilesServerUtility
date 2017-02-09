#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=favicon.ico
#AutoIt3Wrapper_Res_Comment=By Dateranoth - Feburary 5, 2017
#AutoIt3Wrapper_Res_Description=Utility for Running Conan Server
#AutoIt3Wrapper_Res_Fileversion=2.2.0.0
#AutoIt3Wrapper_Res_LegalCopyright=Dateranoth @ https://gamercide.com
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;By Dateranoth - Feburary 4, 2017
;Used by https://gamercide.com on their server
;Feel free to change, adapt, and distribute

#include <Date.au3>
#include <Process.au3>
#include <MsgBoxConstants.au3>
#include <File.au3>
Opt("WinTitleMatchMode", 1) ;1=start, 2=subStr, 3=exact, 4=advanced, -1 to -4=Nocase

;User Variables
If FileExists("ConanServerUtility.ini") Then
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
   Local $HotHour = IniRead("ConanServerUtility.ini", "Daily Restart Hour? 00-23", "HotHour", "00")
   Local $HotMin = IniRead("ConanServerUtility.ini", "Daily Restart Minute? 00-59", "HotMin", "01")
   Local $ExMem = IniRead("ConanServerUtility.ini", "Excessive Memory Amount?", "ExMem", "6000000000")
   Local $ExMemRestart = IniRead("ConanServerUtility.ini", "Restart On Excessive Memory Use? yes/no", "ExMemRestart", "no")
Else
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
   IniWrite("ConanServerUtility.ini", "Daily Restart Hour? 00-23", "HotHour", "00")
   IniWrite("ConanServerUtility.ini", "Daily Restart Minute? 00-59", "HotMin", "01")
   IniWrite("ConanServerUtility.ini", "Excessive Memory Amount?", "ExMem", "6000000000")
   IniWrite("ConanServerUtility.ini", "Restart On Excessive Memory Use? yes/no", "ExMemRestart", "no")
   MsgBox(4096, "Default INI File Made", "Please Modify Default Values and Restart Script")
   Exit
EndIf

OnAutoItExitRegister("Gamercide")

Func Gamercide()
	If @exitMethod <> 1 Then
	$Shutdown = MsgBox(4100, "Shut Down?","Do you wish to shutdown the server?",10)
		If $Shutdown = 6 Then
			CloseServer()
		EndIf
		MsgBox(4096, "Thanks for using our Application", "Please visit us at https://gamercide.com",5)
	EndIf
	Exit
EndFunc

Func CloseServer()
	Local $PID = ProcessExists("ConanSandboxServer-Win64-Test.exe")
	ControlSend("Conan Exiles -", "", "", "I" & @CR)
	ControlSend("Conan Exiles -", "", "", "I" & @CR)
	ControlSend("Conan Exiles -", "", "", "^C")
	WinWaitClose("Conan Exiles -", "", 60)
	If $PID Then
		ProcessClose($PID)
    EndIf
EndFunc

Func UpdateCheck()
	Local $oXML = ObjCreate("Microsoft.XMLHTTP")
	$oXML.Open("GET", "http://steamcommunity.com/games/440900/rss/", 0)
	$oXML.Send

	Global $sFile = _TempFile(@ScriptDir, '~', '.xml')
	FileWrite($sFile, $oXML.responseText)

	$sXML = $sFile
	Local $oXML = ObjCreate("Microsoft.XMLDOM")
	$oXML.Load($sXML)
	Local $oNames = $oXML.selectNodes("//rss/channel/item/title")
	Local $aMyDate, $aMyTime
	_DateTimeSplit(_NowCalc(), $aMyDate, $aMyTime)
    Local $cDate = "PATCH "& StringFormat("%02d", $aMyDate[2]) &"."& StringFormat("%02d", $aMyDate[3]) &"."& StringFormat("%04d", $aMyDate[1])
	Local $cFile = @ScriptDir &"/ConanServerUtility_LastUpdate.txt"

	For $oName In $oNames

		If StringRegExp($oName.text,$cDate&"(?i)") Then
				If FileRead(FileOpen($cFile)) = $oName.text Then
					;ConsoleWrite("No New Update" & @CRLF)
					FileClose($cFile)
					ExitLoop
				Else
					FileClose($cFile)
					FileWrite(FileOpen($cFile,2),$oName.text)
					ConsoleWrite($oName.text & @CRLF)
					FileClose($cFile)
					Local $PID = ProcessExists("ConanSandboxServer-Win64-Test.exe")
					If $PID Then
						FileWriteLine(@ScriptDir & "\ConanServerUtility_RestartLog.txt", @MON &"-"& @MDAY &"-"& @YEAR &" "& @HOUR &":"& @MIN &"["& $oName.txt &"] Restart Requested by ConanServerUtility Script")
						CloseServer()
					EndIf
					ExitLoop
				EndIf
		EndIf
	Next
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
   If $RECV = $RestartCode Then
	  Local $PID = ProcessExists("ConanSandboxServer-Win64-Test.exe") ; Will return the PID or 0 if the process isn't found.
	  Local $IP = _TCP_Server_ClientIP($ConnectedSocket)
	  If $PID Then
		 Local $MEM = ProcessGetStats($PID, 0)
		 FileWriteLine(@ScriptDir & "\ConanServerUtility_RestartLog.txt", @MON &"-"& @MDAY &"-"& @YEAR &" "& @HOUR &":"& @MIN &" --Work Memory:"& $MEM[0] & _
		 " --Peak Memory:"& $MEM[1] &" Restart Requested by Remote Host: "& $IP)
		 CloseServer()
		 Sleep (10000)
		 ExitLoop
	  EndIf
	  Else
		FileWriteLine(@ScriptDir & "\ConanServerUtility_RestartLog.txt", @MON &"-"& @MDAY &"-"& @YEAR &" "& @HOUR &":"& @MIN &" Restart ATTEMPT by Remote Host: "& $IP &" WRONG PASSWORD")
		ExitLoop
   EndIf
$Count += 1
Sleep (1000)
WEnd
If $ConnectedSocket <> -1 Then TCPCloseSocket($ConnectedSocket)
EndIf
EndIf


Local $PID = ProcessExists("ConanSandboxServer-Win64-Test.exe")
If $PID = 0 Then
	If $UseSteamCMD = "yes" Then
		RunWait(""& $steamcmddir &"\steamcmd.exe +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir "& $serverdir &" +app_update 443030 validate +quit")
	EndIf
	If $CheckForUpdate = "yes" Then
		UpdateCheck()
	EndIf
	Run(""& $serverdir &"\ConanSandbox\Binaries\Win64\ConanSandboxServer-Win64-Test.exe ConanSandBox?MULTIHOME="& $g_IP &"?QueryPort="& $GamePort &"?MaxPlayers="& $MaxPlayers &"?AdminPassword="& $AdminPass &"?listen -nosteamclient -game -server -log")
	WinWait("Conan Exiles -", "", 70)
Else
   Local $MEM = ProcessGetStats($PID, 0)
   If $MEM[0] > $ExMem And $ExMemRestart = "no" Then
	  FileWriteLine(@ScriptDir & "\ConanServerUtility_ExcessiveMemoryLog.txt", @MON &"-"& @MDAY &"-"& @YEAR &" "& @HOUR &":"& @MIN &" --Work Memory:"& $MEM[0] & _
        " --Peak Memory:"& $MEM[1])
	  Sleep (10000)
   ElseIf $MEM[0] > $ExMem And $ExMemRestart = "yes" Then
	  FileWriteLine(@ScriptDir & "\ConanServerUtility_RestartLog.txt", @MON &"-"& @MDAY &"-"& @YEAR &" "& @HOUR &":"& @MIN &" --Work Memory:"& $MEM[0] & _
	  " --Peak Memory:"& $MEM[1] &" Excessive Memory Use - Restart Requested by ConanServerUtility Script")
	  CloseServer()
	  Sleep (10000)
   EndIf
EndIf

If @HOUR = $HotHour And @MIN = $HotMin And $RestartDaily = "yes" Then
   Local $PID = ProcessExists("ConanSandboxServer-Win64-Test.exe")
	  If $PID Then
		 Local $MEM = ProcessGetStats($PID, 0)
		 FileWriteLine(@ScriptDir & "\ConanServerUtility_RestartLog.txt", @MON &"-"& @MDAY &"-"& @YEAR &" "& @HOUR &":"& @MIN &" --Work Memory:"& $MEM[0] & _
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
