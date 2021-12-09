Const Err1="Ошибка параметра"
Const Err2="Не найден файл"
Const Err3="Неизвестный параметр"
Const Err4="Много параметров"

pass=""
kb=0
disp=0
dispauto=0
plink=False
audio=False
debug0=False

Set WshShell = CreateObject("WScript.Shell")
ProgramFiles_x86=WshShell.ExpandEnvironmentStrings("%ProgramFiles(x86)%")
If ProgramFiles_x86="" Then ProgramFiles_x86=WshShell.ExpandEnvironmentStrings("%ProgramFiles%")
x2gopath=ProgramFiles_x86 & "\x2goclient"

xsrvpath=x2gopath & "\VcXsrv\vcxsrv.exe"
nxpath=x2gopath & "\nxproxy.exe"
plinkpath=x2gopath & "\plink.exe"
pulsepath=x2gopath & "\pulse\pulseaudio.exe"
privatekey=""
StrErr=""

With WScript
  If .Arguments.Count=0 Then
    StrErr = "Команда:" & vbCrLf
    StrErr = StrErr & WScript.ScriptName & " [options] <login> <host> <linuxapp>" & vbCrLf & vbCrLf
    StrErr = StrErr & "Параметры:" & vbCrLf
    StrErr = StrErr & "-pw <password>" & vbTab & "Пароль входа" & vbCrLf
    StrErr = StrErr & "-i <privatekey>" & vbTab & "Файл закрытого ключа" & vbCrLf
    StrErr = StrErr & "-kb <kbmode>" & vbTab & "Переключение раскладки" & vbCrLf
    StrErr = StrErr & vbTab & vbTab & "0 - Alt+Shift, 1 - Ctrl+Shift" & vbCrLf
    StrErr = StrErr & "-disp <display>" & vbTab & "Номер X дисплея" & vbCrLf
    StrErr = StrErr & vbTab & vbTab & "-1 - Определяет дисплей по SID" & vbCrLf
    StrErr = StrErr & vbTab & vbTab & "-2 - Новый дисплей под каждый процесс" & vbCrLf
    StrErr = StrErr & "-xsrvpath <path>" & vbTab & "Путь к приложению VcXsrv" & vbCrLf
    StrErr = StrErr & "-nxpath <path>" & vbTab & "Путь к приложению nxproxy" & vbCrLf
    StrErr = StrErr & "-plinkpath <path" & vbTab & "Путь к приложению plink" & vbCrLf
    StrErr = StrErr & "-pulsepath <path" & vbTab & "Путь к приложению PulseAudio" & vbCrLf
    StrErr = StrErr & "-plink" & vbTab & vbTab & "Не использовать OpenSSH" & vbCrLf
    StrErr = StrErr & "-audio" & vbTab & vbTab & "Включить канал передачи аудио" & vbCrLf
    StrErr = StrErr & "-d" & vbTab & vbTab & "Режим отладки" & vbCrLf
  End If
  Set fso=CreateObject("Scripting.FileSystemObject")
  j=0
  For i=0 To .Arguments.Count-1
    Do
      Select Case .Arguments(i)
        Case "-d"
          debug0=True
        Case "-plink"
          plink=True
        Case "-audio"
          audio=True
        Case "-pw"
          If i=.Arguments.Count-1 Then StrErr = StrErr & Err1 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          If Left(.Arguments(i+1),1)="-" Then StrErr = StrErr & Err1 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          i=i+1
          pass=.Arguments(i)
        Case "-kb"
          If (i=.Arguments.Count-1) Then StrErr = StrErr & Err1 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          If Left(.Arguments(i+1),1)="-" Then StrErr = StrErr & Err1 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          If Not IsNumeric(.Arguments(i+1)) Then StrErr = StrErr & Err1 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          If CInt(.Arguments(i+1))<0 or CInt(.Arguments(i+1))>1 Then StrErr = StrErr & Err1 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          i=i+1
          kb=CInt(.Arguments(i))
        Case "-disp"
          If (i=.Arguments.Count-1) Then StrErr = StrErr & Err1 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          If Left(.Arguments(i+1),1)="-" And Not (.Arguments(i+1)="-1" Or .Arguments(i+1)="-2") Then StrErr = StrErr & Err1 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          If Not IsNumeric(.Arguments(i+1)) Then StrErr = StrErr & Err1 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          If CInt(.Arguments(i+1))<-2 or CInt(.Arguments(i+1))>999 Then StrErr = StrErr & Err1 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          i=i+1
          disp=CInt(.Arguments(i))
          If disp<0 Then dispauto=disp
        Case "-i"
          If (i=.Arguments.Count-1) Then StrErr = StrErr & Err1 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          If Left(.Arguments(i+1),1)="-" Then StrErr = StrErr & Err1 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          i=i+1
          If Not fso.FileExists(.Arguments(i)) Then StrErr = StrErr & Err2 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          privatekey=.Arguments(i)
        Case "-xsrvpath"
          If (i=.Arguments.Count-1) Then StrErr = StrErr & Err1 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          If Left(.Arguments(i+1),1)="-" Then StrErr = StrErr & Err1 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          i=i+1
          If Not fso.FileExists(.Arguments(i)) Then StrErr = StrErr & Err2 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          xsrvpath=.Arguments(i)
        Case "-nxpath"
          If (i=.Arguments.Count-1) Then StrErr = StrErr & Err1 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          If Left(.Arguments(i+1),1)="-" Then StrErr = StrErr & Err1 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          i=i+1
          If Not fso.FileExists(.Arguments(i)) Then StrErr = StrErr & Err2 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          nxpath=.Arguments(i)
        Case "-plinkpath"
          If (i=.Arguments.Count-1) Then StrErr = StrErr & Err1 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          If Left(.Arguments(i+1),1)="-" Then StrErr = StrErr & Err1 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          i=i+1
          If Not fso.FileExists(.Arguments(i)) Then StrErr = StrErr & Err2 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          plinkpath=.Arguments(i)
        Case "-pulsepath"
          If (i=.Arguments.Count-1) Then StrErr = StrErr & Err1 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          If Left(.Arguments(i+1),1)="-" Then StrErr = StrErr & Err1 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          i=i+1
          If Not fso.FileExists(.Arguments(i)) Then StrErr = StrErr & Err2 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          pulsepath=.Arguments(i)
        Case Else
          If Left(.Arguments(i),1)="-" Then StrErr = StrErr & Err3 & " <" & .Arguments(i) & ">" & vbCrLf:Exit Do
          j=j+1
          Select Case j
            Case 1
              login=.Arguments(i)
            Case 2
              host=.Arguments(i)
            Case 3
              linuxapp=.Arguments(i)
            Case Else
              StrErr = StrErr & Err4 & vbCrLf:Exit Do
          End Select
      End Select
    Loop While False
  Next
  Set fso=Nothing
  If StrErr<>"" Then .Echo StrErr:.Quit 1

  If debug0 Then winstyle=1 Else winstyle=0
  If isWScript Then
    CScript = Left(.FullName, Len(.FullName)-11) & "cscript.exe"

    ReDim Args(.Arguments.Count-1)
    For i=0 To .Arguments.Count-1
      Args(i)=MarkQuot(.Arguments(i))
    Next
    ArgsStr=Join(Args)
    If Len(ArgsStr)>0 Then ArgsStr=" " & ArgsStr
    .Quit WshShell.Run(MarkQuot(CScript) & " " & MarkQuot(.ScriptFullName) & ArgsStr, winstyle, True)
  End If

End With

If (pass<>"") Or (Not IsOpenSSH) Then plink=True
If privatekey="" Then
  privatekey = "%USERPROFILE%\.nxuserprivatekey"
  If plink Then privatekey = privatekey & ".ppk"
End If

Select Case LCase(linuxapp)
  Case "sbis"
    linuxapp="/opt/sbis3plugin/sbis3plugin %U --autostart & google-chrome https:\\online.sbis.ru --window-size=1600,990 --window-position=160,40 --ignore-gpu-blacklist --use-gl=egl --enable-gpu-rasterization;killall -u " & login & " sbis3plugin"
  Case "1c"
    linuxapp="/opt/1cv8/common/1cestart"
  Case "chrome"
    linuxapp="google-chrome --start-maximized --ignore-gpu-blacklist --use-gl=egl --enable-gpu-rasterization"
End Select

If (dispauto=-2) Then
  Set oXsrv = WshShell.Exec(MarkQuot(xsrvpath) & " -multiwindow -notrayicon -clipboard -displayfd 1 -silent-dup-error")
  Do While not oXsrv.StdErr.AtEndofStream
    strOutput = oXsrv.StdErr.ReadLine
    WScript.Echo strOutput
    p1=InStr(strOutput,"DISPLAY=")
    If p1>0 Then
      p1=InStr(p1+8,strOutput,":")
      If p1>0 Then
        p1=p1+1
        p2=InStr(p1,strOutput,".")
        If p2>0 Then
          disp=CInt(Mid(strOutput,p1,p2-p1))
          Exit Do
        End If
      End If
    End If
  Loop
ElseIf (dispauto=-1) Then
  sid = GetSIDFromUser(CreateObject("WScript.Network").UserName)
  If sid="" Then 
    disp=0
  Else
    disp=CInt(Right(sid,3))
  End If
  WshShell.Run MarkQuot(xsrvpath) & " :" & disp & " -multiwindow -notrayicon -clipboard -silent-dup-error", 1, false
Else
  WshShell.Run MarkQuot(xsrvpath) & " :" & disp & " -multiwindow -notrayicon -clipboard -silent-dup-error", 1, false
End If

With WshShell.Environment("Process")
    .Item("DISPLAY") = "localhost:" & disp
    .Item("NX_HOME") = WshShell.ExpandEnvironmentStrings("%USERPROFILE%")
End With

pulsecookiestrhex=""
If audio Then
  pulseconfpath = WshShell.ExpandEnvironmentStrings("%TEMP%") & "\config.pa"
  pulsecookiepath = WshShell.ExpandEnvironmentStrings("%TEMP%") & "\.pulse-cookie"
  Set fso = CreateObject("Scripting.FileSystemObject")
  Result = WshShell.Run(MarkQuot(pulsepath) & " --check", 0, true)
  If Result<>0 Then
    Set pulseconf = fso.CreateTextFile(pulseconfpath, True)
    pulseconf.WriteLine("load-module module-native-protocol-tcp port=4713 auth-cookie=" & Replace(pulsecookiepath,"\","\\"))
    pulseconf.WriteLine("load-module module-waveout sink_name=output source_name=input record=0")
    pulseconf.Close
    Set pulseconf = Nothing
    WshShell.Run MarkQuot(pulsepath) & " --exit-idle-time -1 -D -F " & MarkQuot(pulseconfpath), winstyle, false
    For i=1 To 300
      If fso.FileExists(pulsecookiepath) Then Exit For
      WScript.Sleep 10
    Next
  End If
  If fso.FileExists(pulsecookiepath) Then
    Set pulsecookie = fso.GetFile(pulsecookiepath)
    pulsecookiestr = pulsecookie.OpenAsTextStream(1).ReadAll
    Set pulsecookie = Nothing
    For i=1 To Len(pulsecookiestr)
      s = LCase(Hex(Asc(Mid(pulsecookiestr,i,1))))
      If Len(s)=1 Then s = "0" & s
      pulsecookiestrhex = pulsecookiestrhex & s
    Next
    pulsecookiestrhex = " " & pulsecookiestrhex
  End If
  Set fso = Nothing
End If

nxstart="/usr/local/bin/nxstart"
If kb=0 Then kbstr="alt" Else kbstr="ctrl"
If login="root" Then kbstrd=" -print | xkbcomp - $DISPLAY" Else kbstrd=""
kbstr="setxkbmap -model pc105 -layout ru,us -option grp:" & kbstr & "_shift_toggle" & kbstrd & ";"

If plink Then
  key=""
  Set oExec = WshShell.Exec(MarkQuot(plinkpath) & " -v -batch " & host)
  Do While not oExec.StdErr.AtEndofStream
    strOutput = oExec.StdErr.ReadLine
    If Left(strOutput, 4)="ssh-" Then
      key = Right(strOutput, Len(strOutput) - InStrRev(strOutput, " "))
    End If
  Loop
  If key="" Then WScript.Quit 1
  If pass<>"" Then pass=" -pw """ & pass & """"
  Set oExec = WshShell.Exec(MarkQuot(plinkpath) & " -C -batch -hostkey " & key & " " & login & "@" & host & pass & " -i " & privatekey & " " & nxstart & " '" & kbstr & linuxapp & "'" & pulsecookiestrhex)
Else
  Set oExec = WshShell.Exec("ssh -C -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null " & login & "@" & host & " -i " & privatekey & " " & nxstart & " '" & kbstr & linuxapp & "'" & pulsecookiestrhex)
End If

Do While not oExec.StdErr.AtEndofStream
  strOutput = oExec.StdErr.ReadLine
  WScript.Echo strOutput
  If InStr(strOutput, "Info: Waiting for connection from any host on socket")>0 Then
    portpos1=0
    portpos2=InStrRev(strOutput, "'")
    If portpos2>0 Then portpos1=InStrRev(strOutput, ":", portpos2)
    If portpos1>0 Then
      portstr=Mid(strOutput, portpos1+1, portpos2-portpos1-1)
      If IsNumeric(portstr) Then
        port=CLng(portstr)
        WshShell.Run MarkQuot(nxpath) & " -S " & host & ":" & (port-4000), winstyle, false
      End If
    End If
  End If
Loop

'If (dispauto=-2) Then oXsrv.Terminate
If (dispauto=-2) Then
  Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
  Set colProcessList = objWMIService.ExecQuery("SELECT * FROM Win32_Process WHERE ProcessID = " & oXsrv.ProcessID)
  For Each objProcess in colProcessList 
    objProcess.Terminate() 
  Next  
End If

'------------------------------
' FUNCTIONS
'------------------------------
Function isWScript()
  isWScript = False
  If LCase(Right(WScript.FullName, 11)) = "wscript.exe" Then isWScript = True
End Function

Function IsOpenSSH()
  Dim WshShell, Result
  IsOpenSSH=False
  Set WshShell = CreateObject("WScript.Shell")
  On Error Resume Next
  Result=WshShell.Run("ssh -V", 0, True)
  If Err.Number=0 And Result=0 Then IsOpenSSH=True
End Function

Function MarkQuot(Str)
  If InStr(Str, " ")>0 Then MarkQuot = """" & Str & """" Else MarkQuot = Str
End Function

Function GetSIDFromUser(UserName)
  Dim DomainName, Result, WMIUser
  If InStr(UserName, "\") > 0 Then
    DomainName = Mid(UserName, 1, InStr(UserName, "\") - 1)
    UserName = Mid(UserName, InStr(UserName, "\") + 1)
  Else
    DomainName = CreateObject("WScript.Network").UserDomain
  End If
  On Error Resume Next
  Set WMIUser = GetObject("winmgmts:{impersonationlevel=impersonate}!" _
    & "/root/cimv2:Win32_UserAccount.Domain='" & DomainName & "'" _
    & ",Name='" & UserName & "'")
  If Err.Number = 0 Then
    Result = WMIUser.SID
  Else
    Result = ""
  End If
  On Error GoTo 0
  GetSIDFromUser = Result
End Function
