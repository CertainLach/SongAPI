Set objFSO = CreateObject( "Scripting.FileSystemObject" )
Set objHTTP = CreateObject( "WinHttp.WinHttpRequest.5.1" )
Set objCMD = WScript.CreateObject("WSCript.shell")
Set objRegExp = CreateObject("VBScript.RegExp")


cfound=0


Function dFile(url,file)
	objHTTP.Open "GET", url, False
	Set objFile = objFSO.OpenTextFile(file, 2, True )
	objHTTP.Send
	For i = 1 To LenB(objHTTP.ResponseBody)
		objFile.Write Chr(AscB(MidB(objHTTP.ResponseBody,i,1)))
	Next
	objFile.Close()
End Function


Function dSearchOnSongsterr(song)
	dFile "http://www.songsterr.com/a/ra/songs.xml?pattern="+song, "./temp_search.xml"
	objPattern = "<?xml.*"
	objRegExp.Pattern = objPattern 
	Set songs = objFSO.OpenTextFile("./temp_search.xml", 1)
	songstext = songs.ReadAll
	songlist=Split(songstext,"<Song id=" + Chr(34))
	songs.Close
	For Each CSong in songlist
		If objRegExp.Test(CSong) = 0 Then
			CSongID=Split(CSong, Chr(34)+" type=" + Chr(34))(0)
			CSongName=Split(Split(CSong, "<title>")(1), "</title>")(0)
			CSongAuthor=Split(Split(CSong, "<nameWithoutThePrefix>")(1), "</nameWithoutThePrefix>")(0)
			CSongS=CSongS+CSongID+vbTab+CSongAuthor+" - "+CSongName+vbcrlf 
			cfound=cfound+1
		End If
	Next
	dSearchOnSongsterr=CSongS+"||"+Join(songlist,":::")
	objFSO.DeleteFile "./temp_search.xml"
End Function


Function dAllSongsWithNameSongsterr(song)
	objPattern = "<?xml.*"
	objRegExp.Pattern = objPattern 
	For Each CSong in Split(dGetSArrElement(dSearchOnSongsterr(song),1),":::")
		If objRegExp.Test(CSong) = 0 Then
			CSongID=Split(CSong, Chr(34)+" type=" + Chr(34))(0)
			dSongId CSongID
		End If
	Next
End Function


Function dGetSArrElement(sarr,el)
	dGetSArrElement=Split(sarr,"||")(el)
End Function


Function dGetMagicSettings()
	Set scriptfile = objFSO.OpenTextFile(Wscript.ScriptFullName, 1)
	scriptfiletext = scriptfile.ReadAll
	settings=Split(scriptfiletext,"'Some fucking magic to save settings"+" in script file!")(1)
	scriptfile.Close
	setarr=Split(settings,vbcrlf+"'")
	dGetMagicSettings=Join(setarr,"||")
End Function


Function dSetMagicSettings(num,nsetting)
	Set scriptfile = objFSO.OpenTextFile(Wscript.ScriptFullName, 1)
	scriptfiletext = scriptfile.ReadAll
	script=Split(scriptfiletext,"'Some fucking magic to save settings"+" in script file!")(0)
	script=script+"'Some fucking magic to save settings"+" in script file!"
	settings=Split(scriptfiletext,"'Some fucking magic to save settings"+" in script file!")(1)
	scriptfile.Close
	currsetting=dGetSArrElement(dGetMagicSettings,num)
	settings=Replace(settings, currsetting, nsetting)
	Set tf = objFSO.CreateTextFile(Wscript.ScriptFullName, True)
  	tf.Write(script+settings) 
  	tf.Close
End Function


Function dSongId(id)
	Set objFSO = WScript.CreateObject("Scripting.FileSystemObject")
	Set objCMD = WScript.CreateObject("WSCript.shell")
	songid=id
	neededsong="temp_"+id
	songinfourl="http://www.songsterr.com/a/ra/player/song/" + songid + ".xml"
	songinfofileurl="./"+neededsong + ".xml"
	dFile songinfourl,songinfofileurl
	Set songinfofile = objFSO.OpenTextFile(songinfofileurl, 1)
	songinfofiletext = songinfofile.ReadAll
	gpturl=Split(Split(songinfofiletext,"<attachmentUrl>")(1),"</attachmentUrl>")(0)
	songinfofile.Close
	gptfileext=Split(Split(gpturl,".net/")(1),".")(1)
	gptauthor=Split(Split(songinfofiletext,"<name>")(1),"</name>")(0)
	gpttitle=Split(Split(songinfofiletext,"<title>")(1),"</title>")(0)
	If not objFSO.FolderExists("./Songs") Then
		objFSO.CreateFolder "./Songs"
	End if
	If not objFSO.FolderExists("./Songs/"+gptauthor) Then
		objFSO.CreateFolder "./Songs/"+gptauthor
	End if
	Set F = objFSO.GetFile(Wscript.ScriptFullName)
	path = objFSO.GetParentFolderName(F)
	dFile gpturl,path+"/Songs/"+gptauthor+"/"+gptauthor+" - "+gpttitle+"."+gptfileext
	objFSO.DeleteFile songinfofileurl
End Function


Function Main()
	lastsong=dGetSArrElement(dGetMagicSettings,1)
	lastid=dGetSArrElement(dGetMagicSettings,2)
	ssong=dGetSArrElement(dGetMagicSettings,3)
	URL=InputBox("Enter song to find (or ';sm' to enter settings):","Songsterr downloader by Creeplays",lastsong)
	If URL = ";sm" Then
		SettingsMenu
		WScript.Quit
	End If
	If URL = "" Then
		MsgBox "No song was specified or user cancelled, quitting.",0,"Songsterr downloader by Creeplays"
		WScript.Quit
	End If
	found=""
	if ssong="s1" Then 
		found=found+dGetSArrElement(dSearchOnSongsterr(URL),0)
	End If
	If not cfound = 0 Then 
		lastsong=URL
		dSetMagicSettings 1,lastsong
		If cfound = 1 Then
			result=MsgBox("Only one song was found: "+vbcrlf+vbcrlf+"ID"+vbTab+"Song"+vbcrlf+found+vbcrlf+"Do you want to download it?",4,"Songsterr downloader by Creeplays")
			If result = 6 Then
				dAllSongsWithNameSongsterr(URL)
				MsgBox "Song has been succesfully downloaded.",0,"Songsterr downloader by Creeplays"
				WScript.Quit
			Else
				MsgBox "User cancelled, quitting.",0,"Songsterr downloader by Creeplays"
				WScript.Quit	
			End if
		End if
		ID=InputBox("Found songs: "+vbcrlf+vbcrlf+"ID"+vbTab+"Song"+vbcrlf+found+vbcrlf+"Enter id to download (or ';da' to download all):","Songsterr downloader by Creeplays",lastid)
		If ID = ";da" Then
			dAllSongsWithNameSongsterr(URL)
		ElseIf ID = "" Then
			MsgBox "User cancelled, quitting.",0,"Songsterr downloader by Creeplays"
			WScript.Quit
		Else 
			dSongId ID
		End if
		lastid=ID
		dSetMagicSettings 2,lastid
		MsgBox "Song has been succesfully downloaded.",0,"Songsterr downloader by Creeplays"
		WScript.Quit
	Else
		MsgBox "No songs was found.",0,"Songsterr downloader by Creeplays"
		WScript.Quit
	End If
End Function


Function SettingsMenu()
	Selected=InputBox("Commands:"+vbcrlf+vbcrlf+"';rs' to reset settings"+vbcrlf+"';ss' to enable/disable search on songsterr","Songsterr downloader by Creeplays",lastsong)
	If Selected = ";rs" Then
		dSetMagicSettings 1,"Nino Rota - What Is A Youth"
		dSetMagicSettings 2,"48784"
		MsgBox "Settings has been resetted, restarting...",0,"Songsterr downloader by Creeplays"
		WScript.Quit
	End If
	WScript.Quit
End Function


Main
WScript.Quit
'Some fucking magic to save settings in script file!
'Nino Rota - What Is A Youth
'48784
's1
'
'
'
'
'
'
'
'
