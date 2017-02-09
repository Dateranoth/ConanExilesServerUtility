#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=favicon.ico
#AutoIt3Wrapper_Res_Comment=By Dateranoth - Feburary 4, 2017
#AutoIt3Wrapper_Res_Description=Utility to Remotely Restart Conan Server
#AutoIt3Wrapper_Res_Fileversion=2.0
#AutoIt3Wrapper_Res_LegalCopyright=Dateranoth @ https://gamercide.org
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;By Dateranoth - Feburary 4, 2017
;Used by https://gamercide.com on their server
;Feel free to change, adapt, and distribute
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
; Start The TCP Services
    ;==============================================
    TCPStartup()

   ; Set Some reusable info
   ;--------------------------
   Local $ConnectedSocket, $szData
If FileExists("ConanServerRemoteRestart.ini") Then
   Local $cIPADDRESS = IniRead("ConanServerRemoteRestart.ini", "GameServerIP", "cIPADDRESS", "127.0.0.1")
   Local $cPORT = IniRead("ConanServerRemoteRestart.ini", "RestartServerPort", "cPORT", "57520")
   Local $RPassword = IniRead("ConanServerRemoteRestart.ini", "DefaultRestartPassword", "RPassword", "")

Else
   IniWrite("ConanServerRemoteRestart.ini", "GameServerIP", "cIPADDRESS", "127.0.0.1")
   IniWrite("ConanServerRemoteRestart.ini", "RestartServerPort", "cPORT", "57520")
   IniWrite("ConanServerRemoteRestart.ini", "DefaultRestartPassword", "RPassword", "")
   MsgBox(4096, "Default INI File Made", "Please Modify Default Values and Restart Script")
   Exit
EndIf

OnAutoItExitRegister("Gamercide")
Func Gamercide()
	MsgBox(4096, "Thanks for using our Application", "Please visit us at https://gamercide.com",5)
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
    TCPSend($iSocket, $cData)

    ; If an error occurred display the error code and return False.
    If @error Then
        $iError = @error
        MsgBox(BitOR($MB_SYSTEMMODAL, $MB_ICONHAND), "", "Client:" & @CRLF & "Could not send the data, Error code: " & $iError)
        Return False
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

TCPShutdown()