#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\resources\favicon.ico
#AutoIt3Wrapper_Outfile=..\..\build\ConanServerRemoteRestart(x86)_v3.0.0.exe
#AutoIt3Wrapper_Outfile_x64=..\..\build\ConanServerRemoteRestart(x64)_v3.0.0.exe
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=By Dateranoth - April 24, 2018
#AutoIt3Wrapper_Res_Description=Utility to Remotely Restart Conan Server
#AutoIt3Wrapper_Res_Fileversion=3.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=Dateranoth @ https://gamercide.com
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;Originally written by Dateranoth for use
;by https://gamercide.com on their server
;Distributed Under GNU GENERAL PUBLIC LICENSE

#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
; Start The TCP Services
;==============================================
TCPStartup()

; Set Some reusable info
;--------------------------
Local $ConnectedSocket, $szData
If FileExists("ConanServerRemoteRestart.ini") Then
	Local $cIPorName = IniRead("ConanServerRemoteRestart.ini", "Use IP (x.x.x.x) or Name (myserver.com) (ip/name)", "cIPorName", "ip")
	Local $cSERVERADDRESS = IniRead("ConanServerRemoteRestart.ini", "GameServerIP (can be name or IP based on above setting)", "cSERVERADDRESS", "127.0.0.1")
	Local $cPORT = IniRead("ConanServerRemoteRestart.ini", "RestartServerPort", "cPORT", "57520")
	Local $g_sRKey = IniRead("ConanServerRemoteRestart.ini", "Remote Restart Request Key http://IP:Port?KEY=user_pass", "RestartKey", "restart")
	Local $RPassword = IniRead("ConanServerRemoteRestart.ini", "DefaultRestartPassword", "RPassword", "")

Else
	IniWrite("ConanServerRemoteRestart.ini", "Use IP (x.x.x.x) or Name (myserver.com) (ip/name)", "cIPorName", "ip")
	IniWrite("ConanServerRemoteRestart.ini", "GameServerIP (can be name or IP based on above setting)", "cSERVERADDRESS", "127.0.0.1")
	IniWrite("ConanServerRemoteRestart.ini", "RestartServerPort", "cPORT", "57520")
	IniWrite("ConanServerRemoteRestart.ini", "Remote Restart Request Key http://IP:Port?KEY=user_pass", "RestartKey", "restart")
	IniWrite("ConanServerRemoteRestart.ini", "DefaultRestartPassword", "RPassword", "")
	MsgBox(4096, "Default INI File Made", "Please Modify Default Values and Restart Script")
	TCPShutdown() ; Close the TCP service.
	Exit
EndIf

If $cIPorName = "name" Then
	Local $cIPAddress = TCPNameToIP($cSERVERADDRESS)
Else
	Local $cIPAddress = $cSERVERADDRESS
EndIf

OnAutoItExitRegister("Gamercide")
Func Gamercide()
	TCPShutdown() ; Close the TCP service.
	MsgBox(4096, "Thanks for using our Application", "Please visit us at https://gamercide.com", 1)
	Exit
EndFunc   ;==>Gamercide

Func RecvBuff($Socket, $iLength = 2048)

	Do ; wait for answer from server
		Local $iTimeout = 0
		Local $RecvBuffer = TCPRecv($Socket, $iLength) ; first part of receiving data goes in $RecvBuffer
		Sleep(100)
		$iTimeout =+ 1
		If $iTimeout >= 50 Then
			$RecvBuffer = "Response Time Out"
			Return $RecvBuffer
		EndIf
	Until $RecvBuffer ; stay here if nothing received yet

	While 1 ; read more dada if available
		Local $Recv = TCPRecv($Socket, $iLength) ; is there more data ?

		If $Recv = "" Then ; <--- if no more data to read then exit
			ExitLoop
		EndIf

		$RecvBuffer = $RecvBuffer & $Recv ; append new data to buffer

		Sleep(10)
	WEnd

	$Recv = $RecvBuffer ; complete output is in $Recv
	Return $Recv
EndFunc   ;==>RecvBuff


Func MyTCP_Client($sIPAddress, $iPort, $iData)
	; Assign a Local variable the socket and connect to a listening socket with the IP Address and Port specified.
	Local $iSocket = TCPConnect($sIPAddress, $iPort)
	Local $iError = 0
	;Local $cData = StringToBinary($iData, 4)

	; If an error occurred display the error code and return False.
	If @error Then
		; The server is probably offline/port is not opened on the server.
		$iError = @error
		MsgBox(BitOR($MB_SYSTEMMODAL, $MB_ICONHAND), "", "Client:" & @CRLF & "Could not connect, Error code: " & $iError)
		Return False
	EndIf

	; Send Restart Code to the Server.
	Local $bytes = TCPSend($iSocket, "GET /?" & $g_sRKey & "=" & $iData & " HTTP/1.1" & @CRLF)

	; If an error occurred display the error code and return False.
	If @error Then
		$iError = @error
		MsgBox(BitOR($MB_SYSTEMMODAL, $MB_ICONHAND), "", "Client:" & @CRLF & "Could not send the data, Error code: " & $iError)
		Return False
	Else
		Local $sData = RecvBuff($iSocket, 512)
		If $iSocket <> -1 Then TCPCloseSocket($iSocket)
		MsgBox(4096, "Success!", "Restart Code: " & $iData & " Sent to " & $sIPAddress & ":" & $iPort, 10)
		Local $aResponse = StringRegExp($sData, '^HTTP\/\d.\d[[:blank:]](\d+)[[:blank:]].*\R', 2)
		If Not @error Then
			If $aResponse[1] == "200" Then
				MsgBox(4096, "Pass Accepted!", "Server @  "& $sIPAddress & ":" & $iPort & " Restarting")
			ElseIf $aResponse[1] == "403" Then
				MsgBox(4096, "Pass Incorrect!", "Try Again. Maximum of 15 attempts in 10 minutes")
				RequestPass()
			ElseIf $aResponse[1] == "429" Then
				MsgBox(4096, "Limit Reached!", "15 Attempts Have Been Made. Please wait 10 minutes and try again")
			ElseIf $aResponse[1] == "404" Then
				MsgBox(4096, "Incorrect Key!", "Restart Key Does Not Match. Change RestartKey in INI and Try again")
			Else
				MsgBox(4096, "Response Not Understood", $sData)
			EndIf
		Else
			MsgBox(4096, "No Response", "The Server Did Not Respond. Try Again.")
		EndIf
	EndIf

	; Close the socket.
	If $iSocket <> -1 Then TCPCloseSocket($iSocket)
EndFunc   ;==>MyTCP_Client

;Loop forever asking for data to send to the SERVER
Func RequestPass()
	While 1
		; InputBox for data to transmit
		$cPass = InputBox("Restart The Conan Server", @LF & @LF & "Enter the code to Restart The Conan Server:", $RPassword)

		; If they cancel the InputBox or leave it blank we exit our forever loop
		If @error Or $cPass = "" Then
			;MsgBox(BitOR($MB_SYSTEMMODAL, $MB_ICONHAND), "", "No Restart Sent", 5)
			ExitLoop
		Else
			MyTCP_Client($cIPAddress, $cPORT, $cPass)

			ExitLoop
		EndIf
	WEnd
EndFunc   ;==>RequestPass

RequestPass()
