
global function InitPlayVideoMenu
global function PlayVideoMenu
global function SetVideoCompleteFunc
global function TriggerVideoEnd
global function IsPlayVideoMenuPlayingVideo

#if NX_PROG
	global const string INTRO_VIDEO = "intro_720p"
	global const string WELCOME_VIDEO = "ftu_intro_720p"
	global const string WELCOME_INT_VIDEO = "ftu_intro_int_720p"
#else
	global const string INTRO_VIDEO = "intro"
	global const string WELCOME_VIDEO = "ftu_intro"
	global const string WELCOME_INT_VIDEO = "ftu_intro_int"
#endif

global const string INTRO_AUDIO_EVENT = "Apex_Opening_Movie"
global const string WELCOME_AUDIO_EVENT =  "Apex_Opening_Tutorial"


global enum eVideoSkipRule
{
	INSTANT,
	HOLD,
	NO_SKIP
}

global struct VideoPlaySettings
{
	string video = ""
	string milesAudio = ""
	bool forceSubtitles = false
	int skipRule = eVideoSkipRule.INSTANT
	void functionref() videoCompleteFunc = null
}


struct
{
	var               menu
	VideoPlaySettings videoSettings
	var               ruiSkipLabel
	bool              holdInProgress = false
	bool              playingVideo = false
} file

void function InitPlayVideoMenu( var newMenuArg )                                               
{
	RegisterSignal( "PlayVideoMenuClosed" )
	RegisterSignal( "SkipVideoHoldReleased" )

	var menu = GetMenu( "PlayVideoMenu" )
	file.menu = menu

	SetGamepadCursorEnabled( menu, false )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnPlayVideoMenu_Open )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnPlayVideoMenu_Close )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, OnPlayVideoMenu_NavigateBack )

	var vguiSkipLabel = Hud_GetChild( menu, "SkipLabel" )
	Hud_SetAboveBlur( vguiSkipLabel, true )
	file.ruiSkipLabel = Hud_GetRui( vguiSkipLabel )
}

void function PlayVideoMenu( bool isDialog, VideoPlaySettings settings )
{
	Assert( file.videoSettings.video == "" )

	SetDialog( file.menu, isDialog )                                                                                                                           
	file.videoSettings.video = settings.video
	file.videoSettings.milesAudio = settings.milesAudio
	file.videoSettings.forceSubtitles = settings.forceSubtitles
	file.videoSettings.skipRule = settings.skipRule
	file.videoSettings.videoCompleteFunc = settings.videoCompleteFunc
	AdvanceMenu( file.menu )
}

void function SetVideoCompleteFunc( void functionref() func )
{
	file.videoSettings.videoCompleteFunc = func
}

void function OnPlayVideoMenu_Open()
{
	EndSignal( uiGlobal.signalDummy, "PlayVideoMenuClosed" )

	Assert( file.videoSettings.video != "" )

	DisableBackgroundMovie()
	SetMouseCursorVisible( false )
	StopVideos( eVideoPanelContext.UI )
	file.playingVideo = true
	UIMusicUpdate()
	PlayVideoFullScreen( file.videoSettings.video, file.videoSettings.milesAudio, file.videoSettings.forceSubtitles )

	if ( file.videoSettings.skipRule == eVideoSkipRule.HOLD )
		thread WaitForSkipInput()

	WaitSignal( uiGlobal.signalDummy, "PlayVideoEnded" )

	if ( GetActiveMenu() == file.menu )
		thread CloseActiveMenu()
}

void function OnPlayVideoMenu_Close()
{
	Signal( uiGlobal.signalDummy, "PlayVideoMenuClosed" )

	StopVideos( eVideoPanelContext.UI )
	if ( file.videoSettings.milesAudio != "" )
		StopUISoundByName( file.videoSettings.milesAudio )

	file.videoSettings.video = ""
	file.videoSettings.milesAudio = ""
	EnableBackgroundMovie()
	SetMouseCursorVisible( true )
	file.playingVideo = false
	UIMusicUpdate()

	if ( file.videoSettings.videoCompleteFunc != null )
		thread file.videoSettings.videoCompleteFunc()
}

void function OnPlayVideoMenu_NavigateBack()
{
	if ( file.videoSettings.skipRule == eVideoSkipRule.INSTANT )
		CloseActiveMenu()
}

void function WaitForSkipInput()
{
	EndSignal( uiGlobal.signalDummy, "PlayVideoEnded" )

	array<int> inputs

	          
	inputs.append( BUTTON_A )
	inputs.append( BUTTON_B )
	inputs.append( BUTTON_X )
	inputs.append( BUTTON_Y )
	inputs.append( BUTTON_SHOULDER_LEFT )
	inputs.append( BUTTON_SHOULDER_RIGHT )
	inputs.append( BUTTON_TRIGGER_LEFT )
	inputs.append( BUTTON_TRIGGER_RIGHT )
	inputs.append( BUTTON_BACK )
	inputs.append( BUTTON_START )

	                 
	inputs.append( KEY_SPACE )
	inputs.append( KEY_ESCAPE )
	inputs.append( KEY_ENTER )
	inputs.append( KEY_PAD_ENTER )

	WaitFrame()                                                                                                                         
	foreach ( input in inputs )
	{
		if ( input == BUTTON_A || input == KEY_SPACE )
		{
			RegisterButtonPressedCallback( input, ThreadSkipButton_Press )
			RegisterButtonReleasedCallback( input, SkipButton_Release )
		}
		else
		{
			RegisterButtonPressedCallback( input, NotifyButton_Press )
		}
	}

	OnThreadEnd(
		function() : ( inputs )
		{
			foreach ( input in inputs )
			{
				if ( input == BUTTON_A || input == KEY_SPACE )
				{
					DeregisterButtonPressedCallback( input, ThreadSkipButton_Press )
					DeregisterButtonReleasedCallback( input, SkipButton_Release )
				}
				else
				{
					DeregisterButtonPressedCallback( input, NotifyButton_Press )
				}
			}
		}
	)

	WaitSignal( uiGlobal.signalDummy, "PlayVideoEnded" )
}

void function ThreadSkipButton_Press( var button )
{
	thread SkipButton_Press()
}

void function NotifyButton_Press( var button )
{
	ShowAndFadeSkipLabel()
}

void function SkipButton_Press()
{
	if ( file.holdInProgress )
		return

	file.holdInProgress = true

	float holdStartTime = UITime()
	table hold                                        
	hold.completed <- false

	EndSignal( uiGlobal.signalDummy, "SkipVideoHoldReleased" )
	EndSignal( uiGlobal.signalDummy, "PlayVideoEnded" )

	OnThreadEnd(
		function() : ( hold )
		{
			if ( hold.completed )
				Signal( uiGlobal.signalDummy, "PlayVideoEnded" )

			file.holdInProgress = false
		}
	)

	ShowAndFadeSkipLabel()

	float holdDuration = 0
	while ( holdDuration < 1.5 )
	{
		WaitFrame()
		holdDuration = UITime() - holdStartTime
	}

	hold.completed = true
}

void function TriggerVideoEnd()
{

	Signal( uiGlobal.signalDummy, "PlayVideoEnded" )
	#if NX_PROG
		                                                                                            
		                                                                                         
		                                                                                               
		if ( GetActiveMenu() == file.menu )
			thread CloseActiveMenu()
	#endif
}

void function SkipButton_Release( var button )
{
	Signal( uiGlobal.signalDummy, "SkipVideoHoldReleased" )
}

void function ShowAndFadeSkipLabel()
{
	if ( GetBugReproNum() == 5555 )
		printt( "IsControllerModeActive():", IsControllerModeActive() )

	RuiSetGameTime( file.ruiSkipLabel, "initTime", UITime() )
	RuiSetGameTime( file.ruiSkipLabel, "startTime", UITime() )
}

bool function IsPlayVideoMenuPlayingVideo()
{
	return file.playingVideo
}