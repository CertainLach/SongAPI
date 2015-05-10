Set objFSO = CreateObject( "Scripting.FileSystemObject" )
Set objHTTP = CreateObject( "WinHttp.WinHttpRequest.5.1" )
Set objCMD = CreateObject("WSCript.shell")
Set objRegExp = CreateObject("VBScript.RegExp")


cfound=0
cdownloaded=0


Function dEncode(SourceText, KeyText)
 dEncode=""
 KeyL = Len(KeyText)
 for i = 1 to Len(SourceText)
  dEncode = dEncode & chr(Circle(Asc(Mid(SourceText, i, 1)),Asc(Mid(KeyText, NumbKT(i,KeyL), 1)),255,0))
 next
End Function


Function dDecode(CrText, KeyText)
 dDecode=""
 KeyL = Len(KeyText)
 for i = 1 to Len(CrText)
  dDecode = dDecode & chr(Circle(Asc(Mid(CrText, i, 1)),Asc(Mid(KeyText, NumbKT(i,KeyL), 1)),255,1))
 next
End Function


Function NumbKT(position, Length)
 NumbKt = position-Length*(position\Length)
 if NumbKT = 0 then NumbKT = Length
End Function


Function Circle(Code1, Code2, Max, Sign)
 if Sign = 1 then Circle = Code1 + Code2
 if Sign = 0 then Circle = Code1 - Code2
 if Circle > Max then Circle = Circle - Max*(Circle\Max)
 if Circle < 1 then Circle = Max + Circle
End Function


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
			CSongS=CSongS+"s"+CSongID+vbTab+vbTab+CSongAuthor+" - "+CSongName+vbcrlf 
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
			dSongIdSongsterr "s"+CSongID
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
	curritem=0
	For Each setting in setarr
		setarr(curritem)=dDecode(setarr(curritem),curritem)
		curritem=curritem+1
	Next
	dGetMagicSettings=Join(setarr,"||")
End Function


Function dSetMagicSettings(num,nsetting)
	nsetting=dEncode(nsetting,num)
	Set scriptfile = objFSO.OpenTextFile(Wscript.ScriptFullName, 1)
	scriptfiletext = scriptfile.ReadAll
	script=Split(scriptfiletext,"'Some fucking magic to save settings"+" in script file!")(0)
	script=script+"'Some fucking magic to save settings"+" in script file!"
	settings=Split(scriptfiletext,"'Some fucking magic to save settings"+" in script file!")(1)
	scriptfile.Close
	currsetting=dEncode(dGetSArrElement(dGetMagicSettings,num),num)
	settings=Replace(settings, currsetting, nsetting)
	Set tf = objFSO.CreateTextFile(Wscript.ScriptFullName, True)
  	tf.Write(script+settings) 
  	tf.Close
End Function


Function dSongIdSongsterr(id)
	objPattern = "s[0-9]*"
	objRegExp.Pattern = objPattern
	if objRegExp.test(id)=0 Then
		Exit Function
	End if
	id=Split(id,"s")(1)
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
	ssong=dGetSArrElement(dGetMagicSettings,4)
	If ssong="sortauthors" Then
		If not objFSO.FolderExists("./Songs/"+gptauthor) Then
			objFSO.CreateFolder "./Songs/"+gptauthor
		End if
	End If
	Set F = objFSO.GetFile(Wscript.ScriptFullName)
	path = objFSO.GetParentFolderName(F)
	If ssong="sortauthors" Then
		dFile gpturl,path+"/Songs/"+gptauthor+"/"+gptauthor+" - "+gpttitle+"."+gptfileext
	Else
		dFile gpturl,path+"/Songs/"+gptauthor+" - "+gpttitle+"."+gptfileext
	End if
	objFSO.DeleteFile songinfofileurl
	cdownloaded=cdownloaded+1
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
	if ssong="searchonsongsterr" Then 
		found=found+dGetSArrElement(dSearchOnSongsterr(URL),0)
	End If
	If not cfound = 0 Then 
		lastsong=URL
		dSetMagicSettings 1,lastsong
		If cfound = 1 Then
			result=MsgBox("Only one song was found: "+vbcrlf+vbcrlf+"ID"+vbTab+vbTab+"Song"+vbcrlf+found+vbcrlf+"Do you want to download it?",4,"Songsterr downloader by Creeplays")
			If result = 6 Then
				dAllSongsWithNameSongsterr(URL)
				if cdownloaded=0 Then
					MsgBox "Song has been not downloaded.",0,"Songsterr downloader by Creeplays"
					WScript.Quit
				Else
					MsgBox "Song has been succesfully downloaded.",0,"Songsterr downloader by Creeplays"
					WScript.Quit
				End If
			Else
				MsgBox "User cancelled, quitting.",0,"Songsterr downloader by Creeplays"
				WScript.Quit	
			End if
		End if
		ID=InputBox("Found songs: "+vbcrlf+vbcrlf+"ID"+vbTab+vbTab+"Song"+vbcrlf+found+vbcrlf+"Enter id to download (or ';da' to download all):","Songsterr downloader by Creeplays",lastid)
		If ID = ";da" Then
			if ssong="searchonsongsterr" Then 
				dAllSongsWithNameSongsterr(URL)
			End if
		ElseIf ID = "" Then
			MsgBox "User cancelled, quitting.",0,"Songsterr downloader by Creeplays"
			WScript.Quit
		Else 
			if ssong="searchonsongsterr" Then 
				dSongIdSongsterr ID
			End If
		End if
		lastid=ID
		dSetMagicSettings 2,lastid
		if cdownloaded=0 Then
			MsgBox "Song has been not downloaded.",0,"Songsterr downloader by Creeplays"
			WScript.Quit
		ElseIf cdownloaded<cfound and id=";da" Then
			MsgBox "Not all songs has been downloaded",0,"Songsterr downloader by Creeplays"
			WScript.Quit
		Else
			MsgBox "Song has been succesfully downloaded.",0,"Songsterr downloader by Creeplays"
			WScript.Quit
		End If
	Else
		MsgBox "No songs was found.",0,"Songsterr downloader by Creeplays"
		WScript.Quit
	End If
End Function


Function SettingsMenu()
	Selected=InputBox("Commands:"+vbcrlf+vbcrlf+"';rs' to reset settings"+vbcrlf+"';sa' to enable/disable sorting by authors"+vbcrlf+"';ss' to enable/disable search on songsterr","Songsterr downloader by Creeplays",lastsong)
	If Selected = ";rs" Then
		dSetMagicSettings 1,"Nino Rota - What Is A Youth"
		dSetMagicSettings 2,"s48784"
		dSetMagicSettings 3,"searchonsongsterr"
		dSetMagicSettings 4,"sortauthors"
		MsgBox "Settings has been resetted, quitting.",0,"Songsterr downloader by Creeplays"
		WScript.Quit
	End If
	If Selected = ";ss" Then
		ssong=dGetSArrElement(dGetMagicSettings,3)
		if not ssong = "searchonsongsterr" Then
			dSetMagicSettings 3,"searchonsongsterr"
			MsgBox "Search on songsterr enabled, quitting.",0,"Songsterr downloader by Creeplays"
			WScript.Quit
		Else
			dSetMagicSettings 3,"dsearchoonsongnsterrt"
			MsgBox "Search on songsterr disabled, quitting.",0,"Songsterr downloader by Creeplays"
			WScript.Quit
		End if
	End If
	If Selected = ";sa" Then
		ssong=dGetSArrElement(dGetMagicSettings,4)
		if not ssong = "sortauthors" Then
			dSetMagicSettings 4,"sortauthors"
			MsgBox "Sorting by authors enabled, quitting.",0,"Songsterr downloader by Creeplays"
			WScript.Quit
		Else
			dSetMagicSettings 4,"dsoortaunthorst"
			MsgBox "Sorting by authors disabled, quitting.",0,"Songsterr downloader by Creeplays"
			WScript.Quit
		End if
	End If
	WScript.Quit
End Function


Main
WScript.Quit
'Some fucking magic to save settings in script file!
'8=>î!>C0îûî&70CîBîî(>DC7
'A
'@2.?05<;@<;4@A2??
'?;>@-A@4;>?
'
'
'
'
'
'
'
