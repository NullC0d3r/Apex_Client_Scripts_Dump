global function InitGameModeSelectPrivatePanel

const int CUSTOM_MATCH_CODE_ENTRY_LENGTH = 8

const string MATCH_ROLE_TOKEN_CONVAR = "match_roleToken"
const string AUTO_CONNECT_CONVAR = "autoConnect"
const string CUSTOM_MATCH_ENABLED_CONVAR = "customMatch_enabled"

struct
{
	var panel
	var titleRui

	var createMatchPanel
	bool isJoinButtonTimedOut = false
	var joinMatchPanel
	var createOrJoinMatchPanel
	var header
	bool canCreateMatch = false
	bool canCreateOrJoinMatch = false
} file

void function InitGameModeSelectPrivatePanel( var newPanelArg )
{
	var panel = newPanelArg
	file.panel = panel

	file.titleRui = Hud_GetRui( Hud_GetChild( panel, "Title" ) )
	file.header = Hud_GetChild(panel,"Header" )

	AddUICallback_OnLevelInit( CustomMatchConnect_OnLevelInit )

	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, CustomMatchConnecPanel_OnShow )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, CustomMatchConnectPanel_OnHide )

	AddPanelFooterOption( panel, LEFT, BUTTON_B, true, "#B_BUTTON_CLOSE", "#B_BUTTON_CLOSE" )
	AddPanelFooterOption( panel, LEFT, BUTTON_X, true, "#CUSTOMMATCH_ENABLE_CROSSPLAY_GAMEPAD", "#CUSTOMMATCH_ENABLE_CROSSPLAY_MOUSE", CustomMatchEnableCrossplay, CustomMatchShouldCrossplayFooterBeVisible )

	RuiSetString( file.titleRui, "subtitleText", "" )

	file.createMatchPanel = Hud_GetChild( panel, "CreateMatch" )
	file.joinMatchPanel = Hud_GetChild( panel, "JoinMatch" )
	file.createOrJoinMatchPanel = Hud_GetChild( panel, "CreateOrJoinMatch" )

	Init_ConnectBoxPanel( file.createMatchPanel, "#TOURNAMENT_CREATE_MATCH", "#TOURNAMENT_CONNECT_DESC", "#TOURNAMENT_BUTTON_CREATE_MATCH", CreateMatchWithEntryCode )
	Init_ConnectBoxPanel( file.joinMatchPanel, "#TOURNAMENT_JOIN_MATCH", "#TOURNAMENT_JOIN_MATCH_DESC", "#TOURNAMENT_BUTTON_JOIN_MATCH", JoinMatchWithEntryCode )
	Init_ConnectBoxPanel( file.createOrJoinMatchPanel, "#TOURNAMENT_CREATE_JOIN_MATCH", "#TOURNAMENT_CREATE_JOIN_MATCH_DESC", "#TOURNAMENT_BUTTON_CREATE_JOIN_MATCH", JoinMatchWithEntryCode )
}

void function CustomMatchConnect_OnLevelInit()
{
	if ( !IsLobby() )
		return

	if ( !GetConVarBool( CUSTOM_MATCH_ENABLED_CONVAR ) )
		return

	if( GetConVarInt( AUTO_CONNECT_CONVAR ) == 2 )
	{
		printf( "Auto connecting to custom match lobby..." )
		string entryCode = GetConVarString( MATCH_ROLE_TOKEN_CONVAR )
		bool canAutoConnect = true

		if ( entryCode.len() < CUSTOM_MATCH_CODE_ENTRY_LENGTH )
		{
			canAutoConnect = false
			printf( "Unable to auto connect to match lobby. Invalid token: %s", entryCode )
		}

		if ( !CrossplayUserOptIn() )
		{
			canAutoConnect = false
			printf( "Unable to auto connect to match lobby. Crossplay must be enabled." )
		}

		if ( canAutoConnect )
		{
			file.canCreateOrJoinMatch = true
			JoinMatchWithEntryCode( entryCode )
		}

		                                                       
		SetConVarInt( AUTO_CONNECT_CONVAR, 1 )
	}
}

void function CustomMatchConnecPanel_OnShow( var panel )
{
	var textEntryJoin = Hud_GetChild( file.joinMatchPanel, "TextEntryCode" )
	var textEntryCreateOrJoin = Hud_GetChild( file.createOrJoinMatchPanel, "TextEntryCode" )
	string entryCode = GetConVarString( MATCH_ROLE_TOKEN_CONVAR )
	if ( entryCode != "" && entryCode.len() == CUSTOM_MATCH_CODE_ENTRY_LENGTH )
	{
		Hud_SetUTF8Text( textEntryJoin, entryCode )
		Hud_SetUTF8Text( textEntryCreateOrJoin, entryCode )
	}


	RuiSetString(Hud_GetRui( file.header ), "header", "")
	RuiSetString(Hud_GetRui( file.header ), "description", "#TOURNAMENT_CREATE_JOIN_MATCH")


	print( "CustomMatchConnectPanel_OnShow" )
	bool publicEnabled = GetConVarBool( "customMatch_public_enabled" )
	thread CustomMatchCreatePanel_Update( file.createMatchPanel, publicEnabled )
	thread CustomMatchConnectPanel_Update( file.joinMatchPanel, publicEnabled )
	thread CustomMatchConnectPanel_Update( file.createOrJoinMatchPanel, !publicEnabled )

	RegisterButtonPressedCallback( KEY_ENTER, CustomMatchConnectPanel_OnAttemptEnterCode )
}

void function CustomMatchConnectPanel_OnHide( var panel )
{
	print( "CustomMatchConnectPanel_OnHide" )
	Signal( uiGlobal.signalDummy, Hud_GetHudName( file.createMatchPanel ) )
	Signal( uiGlobal.signalDummy, Hud_GetHudName( file.joinMatchPanel ) )
	Signal( uiGlobal.signalDummy, Hud_GetHudName( file.createOrJoinMatchPanel ) )

	DeregisterButtonPressedCallback( KEY_ENTER, CustomMatchConnectPanel_OnAttemptEnterCode )
}

void function CustomMatchCanCreateOrJoinMatch( var connectButton, bool isCreateButton = false, string entryCode = "" )
{
	                                                
	if (CrossplayUserOptIn())
	{
		                                         
		Hud_ClearToolTipData( connectButton )

		                                                                                                               
		if ( isCreateButton )
		{
			file.canCreateMatch = true
		}
		file.canCreateOrJoinMatch = entryCode.len() >= CUSTOM_MATCH_CODE_ENTRY_LENGTH && !file.isJoinButtonTimedOut
	}
	else
	{
		                                                                                     
		ToolTipData crossplayTooltipData
		crossplayTooltipData.titleText = Localize( "#HUD_CROSSPLAY_OPT_IN" )
		crossplayTooltipData.descText = Localize( "#CUSTOMMATCH_CROSSPLAY_TOOLTIP_DESC" )
		Hud_SetToolTipData( connectButton, crossplayTooltipData )

		                                                                    
		file.canCreateOrJoinMatch = false
		file.canCreateMatch = false
	}

	                                                                     
	RuiSetBool( Hud_GetRui( connectButton ), "isLocked", isCreateButton ? !file.canCreateMatch : !file.canCreateOrJoinMatch )
}


void function CustomMatchCreatePanel_Update( var panel, bool showPanel )
{
	string signalName = Hud_GetHudName( panel )

	Signal( uiGlobal.signalDummy, signalName )
	EndSignal( uiGlobal.signalDummy, signalName )

	if ( showPanel )
	{
		Hud_Show( panel )
	}
	else
	{
		Hud_Hide( panel )
		                                                           
		return
	}

	var textEntry = Hud_GetChild( panel, "TextEntryCode" )
	var textEntryBG = Hud_GetChild( panel, "TextEntryBackground" )
	Hud_Hide( textEntry )
	Hud_Hide( textEntryBG )
	var connectButton = Hud_GetChild( panel, "ConnectButton" )

	while ( true )
	{
		CustomMatchCanCreateOrJoinMatch( connectButton, true )
		WaitFrame()
	}
}


void function CustomMatchConnectPanel_Update( var panel, bool showPanel )
{
	string signalName = Hud_GetHudName( panel )

	Signal( uiGlobal.signalDummy, signalName )
	EndSignal( uiGlobal.signalDummy, signalName )

	if ( showPanel )
	{
		Hud_Show( panel )
	}
	else
	{
		Hud_Hide( panel )
		                                                           
		return
	}

	var textEntry     = Hud_GetChild( panel, "TextEntryCode" )
	var connectButton = Hud_GetChild( panel, "ConnectButton" )

	while ( true )
	{
		CustomMatchCanCreateOrJoinMatch( connectButton, false, Hud_GetUTF8Text( textEntry ) )
		WaitFrame()
	}
}


void function CustomMatchConnectPanel_OnAttemptEnterCode( var button )
{
	bool publicEnabled = GetConVarBool( "customMatch_public_enabled" )
	var textEntry = Hud_GetChild( publicEnabled ? file.joinMatchPanel : file.createOrJoinMatchPanel, "TextEntryCode" )

	string entryCode = Hud_GetUTF8Text( textEntry )
	if ( entryCode.len() >= CUSTOM_MATCH_CODE_ENTRY_LENGTH )
	{
		JoinMatchWithEntryCode( entryCode )
	}
}


void function Init_ConnectBoxPanel( var panel, string title, string subtitle, string buttonTitle, void functionref( string entryCode ) activateCallback )
{
	RegisterSignal( Hud_GetHudName( panel ) )

	var frame = Hud_GetChild( panel, "ConnectBoxFrame" )

	InitButtonRCP( frame )

	HudElem_SetRuiArg( frame, "titleText", title )
	HudElem_SetRuiArg( frame, "subtitleText", subtitle )

	var textEntry     = Hud_GetChild( panel, "TextEntryCode" )
	var connectButton = Hud_GetChild( panel, "ConnectButton" )

	Hud_SetTextHidden( textEntry, true )
	HudElem_SetRuiArg( connectButton, "buttonText", buttonTitle )

	Hud_AddEventHandler( connectButton, UIE_CLICK, void function( var button ) : (textEntry, activateCallback) {
		string entryCode = Hud_GetUTF8Text( textEntry )
		activateCallback( entryCode )
	} )
}


void function CreateMatchWithEntryCode( string entryCode )
{
	                                                                                         
	if (file.canCreateMatch)
	{
		printt( "CreateMatchWithEntryCode", entryCode )
		CustomMatch_CreateLobby()
	}
}


void function JoinMatchButtonTimeout_Thread()
{
	var connectButton = Hud_GetChild( file.joinMatchPanel, "ConnectButton" )
	file.isJoinButtonTimedOut = true
	wait 2.0
	file.isJoinButtonTimedOut = false
}


void function JoinMatchWithEntryCode( string entryCode )
{
	                                                                                         
	if (file.canCreateOrJoinMatch)
	{
		printt( "JoinMatchWithEntryCode", entryCode )
		CustomMatch_JoinLobby( entryCode )
		thread JoinMatchButtonTimeout_Thread()
	}
}


void function CustomMatchEnableCrossplay( var button )
{
	                                             
	thread ToggleCrossplaySettingThread()

	                             
	UpdateFooterOptions()
}

#if UI
bool function CustomMatchShouldCrossplayFooterBeVisible()
{
	return !GetConVarBool( "CrossPlay_user_optin" )
}
#endif