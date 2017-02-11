#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\resources\favicon.ico
#AutoIt3Wrapper_Outfile=..\..\build\ConanServerUtility(x86).exe
#AutoIt3Wrapper_Outfile_x64=..\..\build\ConanServerUtility(x64).exe
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=By Dateranoth - Feburary 10, 2017
#AutoIt3Wrapper_Res_Description=Utility for Running Conan Server
#AutoIt3Wrapper_Res_Fileversion=2.6.5
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

Global $mNextCheck = _NowCalc()
Global $sFile = ""
Global $Server_EXE = "ConanSandboxServer-Win64-Test.exe"
Global $PIDFile = @ScriptDir &"\ConanServerUtility_lastpid_tmp"
Global $hWndFile = @ScriptDir &"\ConanServerUtility_lasthwnd_tmp"
Global $logFile = @ScriptDir & "\ConanServerUtility.log"
Global $logStartTime = _NowCalc()

If FileExists($PIDFile) Then
	Global $ConanPID = FileRead($PIDFile)
	Global $ConanhWnd = HWnd(FileRead($hWndFile))
Else
	Global $ConanPID = "0"
	Global $ConanhWnd = "0"
EndIf

;User Variables
#include "includes\IniFunc.au3" ;Functions for reading user settings from INI and creating INI
ReadUini()

#include "includes\CsuFunc.au3" ;General Functions for Utility. Moved to make navigation of main script easier.
OnAutoItExitRegister("Gamercide")

If $UseSteamCMD = "yes" Then
	Local $sFileExists = FileExists($steamcmddir &"\steamcmd.exe")
	If $sFileExists = 0 Then
		MsgBox ( 0x0, "SteamCMD Not Found", "Could not find steamcmd.exe at "& $steamcmddir)
		Exit
	EndIf
	Local $sManifestExists = FileExists($steamcmddir &"\steamapps\appmanifest_443030.acf")
		If $sManifestExists = 1 Then
			Local $manifestFound = MsgBox (4100, "Warning", "Install manifest found at "& $steamcmddir &"\steamapps\appmanifest_443030.acf"& @CRLF & @CRLF &"Suggest moving file to "& _
			$serverdir &"\steamapps\appmanifest_443030.acf before running SteamCMD"& @CRLF & @CRLF &"Would you like to Exit Now?",20)
			If $manifestFound = 6 Then
				Exit
			EndIf
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
		 FileWriteLine($logFile, _NowCalc() &" --Work Memory:"& $MEM[0] &" --Peak Memory:"& $MEM[1] &" Restart Requested by Remote Host: "& $IP)
		 CloseServer()
		 Sleep (10000)
		 ExitLoop
	  EndIf
	  Else
	    Local $IP = _TCP_Server_ClientIP($ConnectedSocket)
		FileWriteLine($logFile, _NowCalc() &" Restart ATTEMPT by Remote Host: "& $IP &" WRONG PASSWORD: "& $RECV)
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
		If $validategame = "yes" Then
			RunWait(""& $steamcmddir &"\steamcmd.exe +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir "& $serverdir &" +app_update 443030 validate +quit")
		Else
			RunWait(""& $steamcmddir &"\steamcmd.exe +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir "& $serverdir &" +app_update 443030 +quit")
		EndIf
	EndIf
	If $CheckForUpdate = "yes" Then
		UpdateCheck()
	EndIf
	If $BindIP = "no" Then
		$ConanPID = Run(""& $serverdir &"\ConanSandbox\Binaries\Win64\"& $Server_EXE &" ConanSandBox -Port="& $GamePort &" -QueryPort="& $QueryPort &" -MaxPlayers="& $MaxPlayers &" -AdminPassword="& $AdminPass &" -ServerPassword="& $ServerPass &" -ServerName="""& $ServerName &""" -listen -nosteamclient -game -server -log")
	Else
		$ConanPID = Run(""& $serverdir &"\ConanSandbox\Binaries\Win64\"& $Server_EXE &" ConanSandBox -MULTIHOME="& $g_IP &" -Port="& $GamePort &" -QueryPort="& $QueryPort &" -MaxPlayers="& $MaxPlayers &" -AdminPassword="& $AdminPass &" -ServerPassword="& $ServerPass &" -ServerName="""& $ServerName &""" -listen -nosteamclient -game -server -log")
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
	  FileWriteLine($logFile, _NowCalc() &" --Work Memory:"& $MEM[0] &" --Peak Memory:"& $MEM[1])
	  Sleep (10000)
   ElseIf $MEM[0] > $ExMem And $ExMemRestart = "yes" Then
	  FileWriteLine($logFile, _NowCalc() &" --Work Memory:"& $MEM[0] &" --Peak Memory:"& $MEM[1] &" Excessive Memory Use - Restart Requested by ConanServerUtility Script")
	  CloseServer()
	  Sleep (10000)
   EndIf
EndIf

If ((@HOUR = $HotHour1 Or @HOUR = $HotHour2 Or @HOUR = $HotHour3 Or @HOUR = $HotHour4 Or @HOUR = $HotHour5 Or @HOUR = $HotHour6) And @MIN = $HotMin And $RestartDaily = "yes") Then
   Local $PID = ProcessExists($ConanPID)
	  If $PID Then
		 Local $MEM = ProcessGetStats($PID, 0)
		 FileWriteLine($logFile,  _NowCalc() &" --Work Memory:"& $MEM[0] &" --Peak Memory:"& $MEM[1] &" Daily Restart Requested by ConanServerUtility Script")
		 CloseServer()
	  EndIf
   Sleep (10000)
EndIf

If ($CheckForUpdate = "yes") And ((_DateDiff('n', $mNextCheck, _NowCalc())) >= $UpdateInterval) Then
	UpdateCheck()
	$mNextCheck = _NowCalc()
EndIf

If ($logRotate = "yes") And ((_DateDiff('h', $logStartTime, _NowCalc())) >= 1) Then
	If Not FileExists ($logFile) Then
		FileWriteLine($logFile, $logStartTime &" Log File Created")
	EndIf
	Local $logFileTime = FileGetTime($logFile,1)
	Local $logTimeSinceCreation = _DateDiff('h', $logFileTime[0] &"/"& $logFileTime[1] &"/"& $logFileTime[2] &" "& $logFileTime[3] &":"& $logFileTime[4] &":"& $logFileTime[5], _NowCalc())
	If $logTimeSinceCreation >= $logHoursBetweenRotate Then
		RotateLogs()
	EndIf
	$logStartTime = _NowCalc()
EndIf

Sleep (500)
WEnd