#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=favicon.ico
#AutoIt3Wrapper_Res_Comment=By Dateranoth - Feburary 9, 2017
#AutoIt3Wrapper_Res_Description=Utility to Remotely Restart Conan Server
#AutoIt3Wrapper_Res_Fileversion=2.4
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
   Local $RPassword = IniRead("ConanServerRemoteRestart.ini", "DefaultRestartPassword", "RPassword", "")

Else
   IniWrite("ConanServerRemoteRestart.ini", "Use IP (x.x.x.x) or Name (myserver.com) (ip/name)", "cIPorName", "ip")
   IniWrite("ConanServerRemoteRestart.ini", "GameServerIP (can be name or IP based on above setting)", "cSERVERADDRESS", "127.0.0.1")
   IniWrite("ConanServerRemoteRestart.ini", "RestartServerPort", "cPORT", "57520")
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
	MsgBox(4096, "Thanks for using our Application", "Please visit us at https://gamercide.com",2)
	Exit
EndFunc

Func MyTCP_Client($sIPAddress, $iPort, $iData)
    ; Assign a Local variable the socket and connect to a listening socket with the IP Address and Port specified.
    Local $iSocket = TCPConnect($sIPAddress, $iPort)
    Local $iError = 0
    Local $cData = StringToBinary($iData, 4)

    ; If an error occurred display the error code and return False.
    If @error Then
        ; The server is probably offline/port is not opened on the server.
        $iError = @error
        MsgBox(BitOR($MB_SYSTEMMODAL, $MB_ICONHAND), "", "Client:" & @CRLF & "Could not connect, Error code: " & $iError)
        Return False
    EndIf

    ; Send Restart Code to the Server.
    Local $bytes = TCPSend($iSocket, $cData)

    ; If an error occurred display the error code and return False.
    If @error Then
        $iError = @error
        MsgBox(BitOR($MB_SYSTEMMODAL, $MB_ICONHAND), "", "Client:" & @CRLF & "Could not send the data, Error code: " & $iError)
        Return False
	Else
		MsgBox(4096, "Success!", $iData &" Sent to "& $sIPAddress &":"& $iPort &" containing "& $bytes &" bytes of data",10)
    EndIf

    ; Close the socket.
    TCPCloseSocket($iSocket)
EndFunc   ;==>MyTCP_Client

        ;Loop forever asking for data to send to the SERVER
        While 1
            ; InputBox for data to transmit
            $cPass = InputBox("Restart The Conan Server", @LF & @LF & "Enter the code to Restart The Conan Server within 30 seconds:",$RPassword)

            ; If they cancel the InputBox or leave it blank we exit our forever loop
            If @error Or $cPass = "" Then
			   MsgBox(BitOR($MB_SYSTEMMODAL, $MB_ICONHAND), "", "No Restart Sent",5)
			   ExitLoop
			Else
			   MyTCP_Client($cIPAddress, $cPort, $cPass)
			   ExitLoop
			EndIf
        WEnd

Func OnAutoItExit()

EndFunc