<% Option Explicit
Dim cameraID, Filename
cameraID = Request("camera")

Filename = "/" & cameraID & ".sdp"    ' file to read
Const ForReading = 1, ForWriting = 2, ForAppending = 8
Const TristateUseDefault = -2, TristateTrue = -1, TristateFalse = 0

' Create a filesystem object
Dim FSO
set FSO = server.createObject("Scripting.FileSystemObject")

' Map the logical path to the physical system path
Dim Filepath
Filepath = Server.MapPath(Filename)

if FSO.FileExists(Filepath) Then

    Dim TextStream
    Set TextStream = FSO.OpenTextFile(Filepath, ForReading, False, TristateFalse)

    ' Read file in one hit
    Dim Contents
    Contents = TextStream.ReadAll
    Response.write Contents
    TextStream.Close
    Set TextStream = nothing
    
Else

    Response.Write "<h3><i><font color=red>SDP file for camera " & cameraID & " (" & Filename & ")" & _
                   " does not exist</font></i></h3>"
    Response.Write "<br>"
    Response.Write "Valid camera IDs are:<br><ul>"
    Dim folder, files, file
    Set folder = FSO.GetFolder(Server.MapPath("/"))
    Set files = folder.Files    
    For each file In files
        If Right(file.Name, 4) = ".sdp" Then
            Response.Write "<li>" & Left(file.Name, Len(file.Name) - 4) & "</li>"
        End If
    Next

End If

Set FSO = nothing
%>