SuperStrict

Framework brl.standardio

?macos
	Import MaxGUI.CocoaMaxGui
?win32
	Import MaxGUI.Win32MaxGUIEx
	'Import MaxGUI.maxguitextareascintilla
?linux
	Import MaxGUI.gtk3maxgui
	'Import MaxGUI.gtk3webkitgtk
	'Import MaxGUI.gtk3webkit2gtk
	'Import MaxGUI.maxguitextareascintilla
?

Import brl.eventqueue
Import brl.filesystem
Import brl.system
Import brl.ramstream
Import brl.timer
Import brl.timerdefault
Import brl.retro
Import text.jconv
Import text.regex
Import brl.map
Import brl.wavloader
Import brl.oggloader
Import sdl.sdlfreeaudio

Global SoundChannel:TChannel
Global Sounds:TMap = New TMap
Global SoundsEnabled:Int = False

Global Settings:TJournalSettings = LoadSettings()

Global Window:TGadget = CreateWindow( "Ultima Online - Journal", ..
	Settings.Window.X, Settings.Window.Y, ..
	Settings.Window.Width, Settings.Window.Height )

Global Tabber:TGadget = CreateTabber( 0, 0, ClientWidth( Window ),ClientHeight( Window ) , Window )
SetGadgetLayout( tabber, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )

' Create text areas in tabs from settings
Global CurrentTab:TJournalTab
For Local i:Int = 0 Until Settings.tabs.Length
	Settings.tabs[i].textArea = CreateTabTextArea( Settings.tabs[i].name, Tabber, i )
	SelectGadgetItem( Tabber, i ) ' Fixes Linux lazy gadget action
Next
If Settings.tabs Then
	Local startTab:Int = Max( Min( Settings.tab, Settings.tabs.Length - 1 ), 0 )
	Settings.tab = startTab
	SelectGadgetItem( Tabber, Settings.tab ) ' Reset Linux lazy gadget action
	CurrentTab = Settings.tabs[Settings.tab]
	ShowGadget( CurrentTab.textArea )
	ActivateGadget( CurrentTab.textArea )
EndIf

If Settings.font Then
	For Local tab:TJournalTab = EachIn settings.tabs
		SetTextAreaFont( tab.textArea, settings.font )
	Next
EndIf

If Settings.foreground Then
	For Local tab:TJournalTab = EachIn settings.tabs
		SetGadgetColor( tab.textArea, ..
			Settings.foreground.red, Settings.foreground.green, Settings.foreground.blue, ..
			False )
	Next
EndIf

If Settings.background Then
	For Local tab:TJournalTab = EachIn settings.tabs
		SetGadgetColor( tab.textArea, ..
			Settings.background.red, Settings.background.green, Settings.background.blue, ..
			True )
	Next
EndIf

Global SelfNames:String[] = GetSelfNames( Settings )

OnEnd( Quit )

Global CurrentJournalFilename:String = LatestJournalFilename( Settings.JournalPath )
Global LastJournalUpdateTime:Long
'Global JournalLines:Int
Global NewJournalTimer:TTimer = CreateTimer( 0.2 )
Global UpdateTimer:TTimer = CreateTimer( 2 )
Global TimerTicks:Int

While WaitEvent()
	'Print CurrentEvent.ToString()
	'pRINT DoAutoScroll
	
	Select EventID()
		'Case EVENT_GADGETSELECT
		'	If EventSource() = CurrentTab.textArea Then DoAutoScroll = False
		
		'Case EVENT_GADGETLOSTFOCUS
		'	If EventSource() = CurrentTab.textArea Then DoAutoScroll = True
			
		Case EVENT_TIMERTICK
			'ScrollAllTabsToBottom(Settings)
			If EventSource() = UpdateTimer Then
				TimerTicks:+1
				
				Local journalTime:Long = JournalUpdateTime( CurrentJournalFilename )
				If journalTime <> LastJournalUpdateTime Then
					LastJournalUpdateTime = journalTime
					UpdateJournal( CurrentJournalFilename, Settings )
					'If DoAutoScroll Then ScrollAllTabsToBottom( Settings )
					ScrollAllTabsToBottom( Settings )
				EndIf
				
				If TimerTicks <= 2 Then
					ScrollAllTabsToBottom( Settings )
				EndIf
				If TimerTicks = 3 Then SoundsEnabled = True
			Else If EventSource() = NewJournalTimer
				Local newestJournalFilename:String = LatestJournalFilename( Settings.JournalPath )
				If newestJournalFilename <> CurrentJournalFilename Then
					Print( "Found newer journal" )
					ResetTabs( Settings )
					CurrentJournalFilename = newestJournalFilename
					LastJournalUpdateTime = 0
					SoundsEnabled = False
					TimerTicks = 0
				EndIf
			EndIf
			
		Case EVENT_GADGETACTION
			If EventSource() = Tabber Then
				Settings.tab = EventData()
				HideGadget( CurrentTab.textArea )
				CurrentTab = Settings.tabs[Settings.tab]
				ShowGadget( CurrentTab.textArea )
				'DoAutoScroll = True
				' Print "Showing tab: " + CurrentTab.name
			EndIf
			
		Case EVENT_WINDOWMOVE
			Settings.Window.X = EventX()
			Settings.Window.Y = EventY()
			
		Case EVENT_WINDOWSIZE
			Settings.Window.Width = EventX()
			Settings.Window.Height = EventY()
			
		Case EVENT_WINDOWCLOSE
			End
			
		Case EVENT_APPTERMINATE
			End
	EndSelect
Wend

Type TJournalSettings
	Field classicuopath:String
	Field journalpath:String { transient }
	Field window:TWindowSettings
	Field font:TGuiFont
	Field foreground:TJournalColor
	Field background:TJournalColor
	Field tab:Int
	Field tabs:TJournalTab[]
	
	Method AddTab:TJournalTab( name:String, showall:Int )
		
		Self.tabs = Self.tabs[..Self.tabs.Length + 1]
		Self.tabs[Self.tabs.length - 1] = New TJournalTab( name, showall )
		Return Self.tabs[Self.tabs.length - 1]
	EndMethod
EndType
Type TJournalTab
	Field name:String
	Field showall:Int
	Field filters:TJournalFilter[]
	Field textArea:TGadget { transient }
	Field lines:Int { transient }
	
	Method New( name:String, showall:Int )
		Self.name = name
		Self.showall = showall
	EndMethod
	
	Method AddFilter:TJournalFilter( regex:String )
		
		Self.filters = Self.filters[..Self.filters.Length + 1]
		Self.filters[Self.filters.length - 1] = New TJournalFilter( regex )
		Return Self.filters[Self.filters.length - 1]
	EndMethod
EndType
Type TWindowSettings
	Field width:Int = 320
	Field height:Int = 480
	Field x:Int
	Field y:Int
EndType
Type TJournalFilter
	Field regexString:String { serializedName = "match" }
	Field regex:TRegEx { transient }
	Field output:Int = True
	Field self:Int
	Field sound:String
	Field style:TJournalStyle
	
	Method New( regex:String )
		Self.regexString = regex
	EndMethod
EndType
Type TJournalStyle
	Field red:Int
	Field green:Int
	Field blue:Int
	Field bold:Byte
	Field italic:Byte
	Field underline:Byte
	Field strikethrough:Byte
	Field flags:Int { transient }
	
	Method New( r:Int, g:Int, b:Int, bold:Int = 0, italic:Int = 0, underline:Int = 0, strikethrough:Int = 0 )
		Self.red = r
		Self.green = g
		Self.blue = b
		Self.bold = bold
		Self.italic = italic
		Self.underline = underline
		Self.strikethrough = strikethrough
	EndMethod
EndType
Type TJournalColor
	Field red:Byte
	Field green:Byte
	Field blue:Byte
	
	Method New( r:Int, g:Int, b:Int )
		Self.red = r
		Self.green = g
		Self.blue = b
	EndMethod
EndType

Function GetSelfNames:String[]( settings:TJournalSettings )
	
	Local charPath:String = settings.classicuopath + "/Data/Profiles/lastcharacter.json"
	If Not FileType( charPath ) = 1 Then Return []
	Local lines:String[] = LoadString( charPath ).Replace( "~r", "" ).Trim().Split( "~n" )
	Local name:String
	
	Local names:String[]
	
	' We don't actually have to parse any JSON here
	' Just read line by line and look for "LastCharacterName"
	For Local line:String = EachIn lines
		line = line.Trim()
		If line.ToLower().StartsWith( "~qlastcharactername~q" ) Then
			name = line.Split( "~q" )[3].ToLower()
			
			names = names[..names.Length + 1]
			names[names.length - 1] = name
		EndIf
	Next
	
	Return names
EndFunction

Function ResetTabs( settings:TJournalSettings )
	
	For Local tab:TJournalTab = EachIn settings.tabs
		SetTextAreaText( tab.textArea, "", 0, TEXTAREA_ALL, TEXTAREA_CHARS ) 
		tab.lines = 0
	Next
EndFunction

Function ScrollAllTabsToBottom( settings:TJournalSettings )
	
	For Local tab:TJournalTab = EachIn settings.tabs
		SelectTextAreaText( tab.textArea, -1, TEXTAREA_ALL, TEXTAREA_LINES )
	Next
EndFunction

Function CreateTabTextArea:TGadget( name:String, tabber:TGadget, index:Int )
	
	Local textArea:TGadget
	textArea = CreateTextArea( 0, 0, ClientWidth( tabber ), ClientHeight( tabber ) , tabber, TEXTAREA_WORDWRAP )
	SetGadgetLayout( textArea, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED, EDGE_ALIGNED )
	If index = 0 Then
		Print name + " is default tab"
		AddGadgetItem( tabber, name, GADGETITEM_DEFAULT, -1, "" )
	Else
		AddGadgetItem( tabber, name, False, -1, "" )
	EndIf
	HideGadget( textArea )
	Return textArea
EndFunction

Function UpdateJournal( path:String, settings:TJournalSettings )
	
	Local text:String = LoadString( path )
	If Not text Then Return
	Local lines:String[] = text.Replace( "~r", "" ).Trim().Split( "~n" )
	
	'Print(lines.Length - curLines + " new lines" )
	Local output:Int
	Local style:TJournalStyle
	Local filter:TJournalFilter
	Local match:TRegExMatch
	Local date:String
	Local cleanLine:String
	Local owner:String
	Local msg:String
	Local tab:TJournalTab
	
	For tab = EachIn settings.tabs
		If tab.lines >= lines.Length Then Return
		
		For Local i:Int = tab.lines Until lines.Length
			If lines[i].Length <= 0 Then Continue
			output = tab.showall
			style = Null
			tab.lines:+1
			cleanLine = Right( lines[i], lines[i].Length - lines[i].Find( "]  " ) - 3 )
			owner = Left( cleanLine, cleanLine.Find( ": " ) )
			If owner.StartsWith( "[" ) Then
				owner = Mid( owner, owner.FindLast( "[" ) + 2 )
				owner = Left( owner, owner.Length - 1 )
			EndIf
			
			For filter = EachIn tab.filters
				
				If Not filter Or filter.regexString.Length <= 0 Then Continue
				
				If Not filter.regex And filter.regexString Then
					filter.regex = TRegEx.Create( filter.regexString )
				EndIf
				
				Try
					match = filter.regex.Find( cleanLine )
					'Print("Matching" + cleanLine + " against " + filter.regexString )
					
					If match And match.SubCount() Then
						
						output = filter.output
						If Not output Then Continue
						
						If filter.self = 1 Or filter.self = 3 Then
							For Local name:String = EachIn SelfNames
								If name = owner.ToLower() Then
									output = false
									Exit
								EndIf
							Next
						EndIf
						
						If filter.self = 2 Then
							Local isSelf:Int = False
							For Local name:String = EachIn SelfNames
								If name = owner.ToLower() Then
									isSelf = True
									Exit
								EndIf
							Next
							If Not isSelf Then output = false
						EndIf
						
						If filter.self = 3 Or filter.self = 4 Then
							msg = Right( cleanLine, cleanLine.Length - owner.Length - 2 ).ToLower()
							Local includesSelf:Int = False
							For Local name:String = EachIn SelfNames
								If msg.Contains( name ) Then
									includesSelf = True
									Exit
								EndIf
							Next
							If Not includesSelf Then output = false
						EndIf
						
						If Not output Then Continue
						
						If filter.sound Then
							If Not SoundChannel Then
								SetAudioDriver("FreeAudio SDL")
								SoundChannel = AllocChannel()
							EndIf
							
							Local snd:TSound = TSound( Sounds.ValueForKey( Lower( filter.sound ) ) )
							If Not snd Then
								snd = LoadSound( filter.sound )
								If snd Then Sounds.Insert( Lower( filter.sound ), snd )
							EndIf
							If snd And SoundsEnabled Then PlaySound( snd, SoundChannel )
						EndIf
						
						If Not output Then Continue
						
						If filter.style Then
							If Not filter.style.flags Then
								If filter.style.bold Then filter.style.flags:|TEXTFORMAT_BOLD
								If filter.style.italic Then filter.style.flags:|TEXTFORMAT_ITALIC
								If filter.style.underline Then filter.style.flags:|TEXTFORMAT_UNDERLINE
								If filter.style.strikethrough Then filter.style.flags:|TEXTFORMAT_STRIKETHROUGH
							EndIf
							style = filter.style
						EndIf
					EndIf
				Catch e:TRegExException
					
					Print( "Error : " + e.toString() )
					End
				EndTry
			Next
			
			If Not output Then Continue
			
			date = Left( lines[i], lines[i].Length - cleanLine.Length )
			date = Right( date, date.Length - date.Find( " " ) - 1)
			date = Left( date, date.Find( "]" ) )
			
			AddTextAreaText( tab.textArea, date + " ~t" + cleanLine + "~n" )
			If style Then
				'Print "Style: " + style.red + ", " + style.green + ", " + style.blue
				FormatTextAreaText( tab.textArea, ..
					style.red, style.green, style.blue, ..
					style.flags, tab.lines, TEXTAREA_ALL, TEXTAREA_LINES )
			EndIf
			
		Next
		
		'If scroll Then SelectTextAreaText( tab.textArea, -1, TEXTAREA_ALL, TEXTAREA_LINES )
		'SelectTextAreaText( tab.textArea, lines.Length + 1, TEXTAREA_ALL, TEXTAREA_LINES )
	Next
EndFunction

Function LoadSettings:TJournalSettings( file:String = "settings.json" )
	
	Local needsSave:Int
	Local settings:TJournalSettings
	If FileType( file ) = 1 Then
		Local jconv:TJConv = New TJConvBuilder.Build()
		settings = TJournalSettings( jconv.FromJson( LoadString( file ), "TJournalSettings" ) )
	Else
		settings = New TJournalSettings
		needsSave = True
		
		' Create example filters
		Local tab:TJournalTab = settings.AddTab( "All", True )
		Local filter:TJournalFilter
		
		tab = settings.AddTab( "System", False )
		filter = tab.AddFilter( "^System: " )
		filter.output = True
		
		tab = settings.AddTab( "Skills & Stats", False )
		filter = tab.AddFilter( "System:\sYour\s(skill\sin\s|intelligence|strength|dexterity)" )
		filter.output = True
		
		tab = settings.AddTab( "Party", False )
		filter = tab.AddFilter( "^\[Party\].*" )
		filter.output = True
		filter.self = 1
		filter.sound = "party.wav"
		filter.style = New TJournalStyle( 0, 90, 255 )
		
		filter = tab.AddFilter( "^\[Party\].*" )
		filter.output = True
		filter.self = 2
		filter.style = New TJournalStyle( 0, 90, 198 )
		
		tab = settings.AddTab( "Mentions", False )
		filter = tab.AddFilter( ".*" )
		filter.output = True
		filter.self = 3
		filter.sound = "mention.wav"
	EndIf

	If Not settings.ClassicUOPath Then
		settings.ClassicUOPath = RequestDir( "Select your ClassicUO path", "./" )
		needsSave = True
	EndIf
	If Not settings.ClassicUOPath Then End
	
	settings.JournalPath = settings.ClassicUOPath + "/Data/Client/JournalLogs/"
	
	If Not settings.window Then
		settings.window =  New TWindowSettings
		needsSave = True
	EndIf
	
	If Not settings.font Then
		settings.font = LookupGuiFont()
		needsSave = True
	EndIf
	
	If Not settings.background Then
		settings.background = New TJournalColor
		LookupGuiColor( GUICOLOR_GADGETBG, settings.background.red, settings.background.green, settings.background.blue )
		needsSave = True
	EndIf
	
	If Not settings.foreground Then
		settings.foreground = New TJournalColor
		LookupGuiColor( GUICOLOR_GADGETFG, settings.foreground.red, settings.foreground.green, settings.foreground.blue )
		needsSave = True
	EndIf
	
	If needsSave Then SaveSettings( settings )
	
	Return settings
EndFunction

Function JournalUpdateTime:Int( path:String )
	
	Return FileTime( path, FILETIME_MODIFIED )
EndFunction

Function LatestJournalFilename:String( path:String )
	
	Local newestFilename:String
	Local newestFileTime:Long
	Local completePath:String
	Local fTime:Long
	Local files:String[] = LoadDir( path )
	For Local f:String = EachIn files
		If f.ToLower().EndsWith( "_journal.txt" ) Then
			completePath = path + "/" + f
			fTime = FileTime( completePath, FILETIME_CREATED )
			If Not newestFilename Or newestFileTime < fTime Then
				newestFileTime = fTime
				newestFilename = completePath
			EndIf
		EndIf
	Next
	
	Return newestFilename
EndFunction

Function Quit()
	
	SaveSettings( Settings )
EndFunction

Function SaveSettings( settings:TJournalSettings )
	Local jconv:TJConv = New TJConvBuilder.WithIndent(4).Build()
	SaveString( jconv.ToJson( settings ) ,"settings.json" )
EndFunction