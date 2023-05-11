global function InitTeamsScoreboardPanel

global function UI_SetScoreboardTeamData
global function UI_SetScoreboardTitle
global function UI_SetScoreboardAnimateIn
global function UI_SetScoreboardAnimateOut
global function UI_ClearLocalPlayerToolTip
global function UI_ToggleReportTooltip

global function ScoreboardMenu_CustomMatch_GetButtonTeamID
global function ScoreboardMenu_CustomMatch_GetHeaderForButton
global function CustomMatchTeamRoster_GetCorrectedTeamId
global function SetPlayerTooltipAfterCallback

enum eRosterAction
{
	RENAME_TEAM,
	SELF_ASSIGN,

	__count
}

struct PlayerButtonData
{
	int teamId
	int row
}

struct PanelGroupData
{
	array< var > playerButtons

	array< var > teamPlayers
	array< var > teamHeaders
	array< var > teamFrames

	int teams
	int playersPerTeam
	int localPlayersTeam
	int gamemode

	float teamWidth
	float teamHeight
	int teamsPerRow
	int maxFittableRows

	float firstTeamOffsetX
	float firstTeamOffsetY

	float vPadding
	float hPadding

	int lastLastPlayerRow = -1

	bool isOpen = false
	bool isMatchAdminSpectator = false
}

struct
{
	var menu
	var panel
	var activePanel

	array<int> teams
	table< var , PanelGroupData > panels
	table< var , PlayerButtonData > playerButtonData

	bool createdCallbacks = false
	bool deathScreenRegisteredCallbacks = false

	                   
	CustomMatch_LobbyState&                 customMatchData
	array< array<CustomMatch_LobbyPlayer> > customMatchDataPlayersSorted
	int                                     actionBitmask = 0
} file

enum scoreboardHeaderTypes
{
	DEFAULT,
	CONTROL,
	ARENA,
                         
		GUN_GAME,
       
	TINY,
                       
		WINTER_EXPRESS,
       
                     
		TDM
       
}

array< string > scoreboardHeaderClasses = [
	"TeamHeader",
	"ControlHeader",
	"ArenaHeader",
                         
		"GunGameHeader",
       
	"TinyHeader"
                       
		"WinterExpressHeader",
       
                       
		"TDMHeader"
       
]

const int PLAYERS_Y_PADDING_OFFSET = 1
  
                             
  

void function InitTeamsScoreboardPanel( var panel )
{
	file.panel = panel
	file.menu = GetParentMenu( panel )

	SetPanelTabTitle( file.panel, "#TAB_SCOREBOARD" )

	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, OnShowScoreboardPanel )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, OnHideScoreboardPanel )

	if( !file.createdCallbacks )
	{
		AddCallback_OnCustomMatchLobbyDataChanged( Callback_OnCustomMatchLobbyDataChanged )
		AddCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_SELF_ASSIGN, Callback_OnSelfAssignChanged )
		AddCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_RENAME_TEAM, Callback_OnRenameTeamChanged )
	}
	file.createdCallbacks = true

	array<var> teamPlayers = GetPanelElementsByClassname( panel, "TeamPlayer" )
	foreach( var teamPlayer in teamPlayers)
		Hud_AddKeyPressHandler( teamPlayer, PlayerButton_OnKeyPress )

	array<var> tinyTeamHeaders = GetPanelElementsByClassname( panel, "TinyHeader" )
	foreach( var teamHeader in tinyTeamHeaders )
		Hud_AddKeyPressHandler( teamHeader, TinyTeamHeaderButton_OnKeyPress )

	var parentMenu = GetParentMenu( panel )

	if( parentMenu == GetMenu( "DeathScreenMenu" ) )                                              
		InitDeathScreenPanelFooter( panel, eDeathScreenPanel.SCOREBOARD)
	else if(parentMenu == GetMenu( "SurvivalInventoryMenu" )  )
		InitLegendPanelInventory( panel )
	else if(parentMenu == GetMenu( "CustomMatchLobbyMenu" )  )
		InitCustomMatchPanelFooter( panel )
	else
		AddPanelFooterOption( panel, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
}

void function OnShowScoreboardPanel( var panel )
{
	PanelGroupData data
	data.isOpen = true
	file.panels[panel] <- data
	file.activePanel = panel

	RegisterEvents( panel )

	if ( IsCustomMatchLobbyMenu() )
	{
		HideAll( panel )
	}
	else
	{
		RunClientScript( "ClientCallback_Teams_SetScoreboardData", panel )
		RunClientScript( "ClientCallback_Teams_SetScoreboardTitle", panel )

		if( DeathScreenIsOpen() )
		{
			RunClientScript( "UICallback_ShowScoreboard", DeathScreenGetHeader() )
			DeathScreenUpdateCursor()
		}
	}
	
	RegisterButtonPressedCallback( KEY_F, HandleViewProfileScoreboardPlayer )

	UpdateFooterOptions()
}

void function OnHideScoreboardPanel( var panel )
{
	file.activePanel = null

	DeregisterEvents( panel )

	foreach( var playerButton in file.panels[panel].playerButtons)
	{
		Hud_ClearToolTipData( playerButton )
	}

	file.panels[panel].playerButtons.clear()                   
	file.panels[panel].isOpen = false
	file.playerButtonData.clear()

	if ( !IsCustomMatchLobbyMenu() )
	{
		RunClientScript( "ClientCallback_Teams_CloseScoreboard" )
	}
	
	DeregisterButtonPressedCallback( KEY_F, HandleViewProfileScoreboardPlayer )
}

void function RegisterEvents( var panel )
{
	array<var> tinyTeamHeaders = GetPanelElementsByClassname( panel, "TinyHeader" )
	foreach( var teamHeader in tinyTeamHeaders )
	{
		Hud_AddEventHandler( teamHeader, UIE_CLICK, TinyTeamHeader_OnLeftClick )
		Hud_AddEventHandler( teamHeader, UIE_CLICKRIGHT, TinyTeamHeader_OnRightClick )
	}

	if( DeathScreenIsOpen() && !file.deathScreenRegisteredCallbacks)
	{
		RegisterButtonPressedCallback( KEY_TAB, DeathScreenSkipRecap )
		RegisterButtonPressedCallback( KEY_SPACE, DeathScreenSkipRecap )
		file.deathScreenRegisteredCallbacks = true
	}
}

void function DeregisterEvents( var panel )
{
	array<var> tinyTeamHeaders = GetPanelElementsByClassname( panel, "TinyHeader" )
	foreach( var teamHeader in tinyTeamHeaders )
	{
		Hud_RemoveEventHandler( teamHeader, UIE_CLICK, TinyTeamHeader_OnLeftClick )
		Hud_RemoveEventHandler( teamHeader, UIE_CLICKRIGHT, TinyTeamHeader_OnRightClick )
	}

	if( file.deathScreenRegisteredCallbacks )
	{
		DeregisterButtonPressedCallback( KEY_TAB, DeathScreenSkipRecap )
		DeregisterButtonPressedCallback( KEY_SPACE, DeathScreenSkipRecap )
		file.deathScreenRegisteredCallbacks = false
	}
}

void function TinyTeamHeader_OnLeftClick( var button )
{
	if ( IsCustomMatchLobbyMenu() )
	{
		CustomMatchTeamHeader_OnLeftClick( button )
	}
}

void function TinyTeamHeader_OnRightClick( var button )
{
	if ( IsCustomMatchLobbyMenu() )
	{
		CustomMatchTeamRoster_OnRightClick( button )
	}
}

float function GetTeamMinWidth( var panel, float maxFillWidth )
{
	float hPadding = file.panels[panel].hPadding
	int teams = file.panels[panel].teams
	int playersPerTeam = file.panels[panel].playersPerTeam
	int maxFittableRows = file.panels[panel].maxFittableRows

	int teamsPerRow = GetTotalTeamsPerRow( panel )

	float screenSizeYFrac =  GetScreenSize().height / 1080.0
	return max( ( ( maxFillWidth - ( hPadding * teamsPerRow) ) / teamsPerRow), 190.0 * screenSizeYFrac )                                                              
}


int function GetTotalTeamsPerRow( var panel  )
{
	int teams = file.panels[panel].teams
	int playersPerTeam = file.panels[panel].playersPerTeam
	int maxFittableRows = file.panels[panel].maxFittableRows

	if( file.panels[panel].gamemode == 4 )
		return teams

	return int( max( ceil( float( teams ) / float( maxFittableRows ) ), 1.0 ) )
}

int function GetTotalFittableRows( var panel, int vSpaceTakenByHeaders, int vSpaceTakenByPlayers, float avialableHeight )
{
	float vPadding = file.panels[panel].vPadding
	int teamVerticalSpace = vSpaceTakenByHeaders + vSpaceTakenByPlayers + int( vPadding )

	int worstCase = int( max( floor( avialableHeight / teamVerticalSpace ), 1 ) )                                       

	if( IsCustomMatchLobbyMenu() && IsFullyConnected())
	{
		int max_alliances = GetPlaylistVarInt( file.customMatchData.playlist, "max_alliances", 0 )
		if( max_alliances > 1 )
			return int( min( max_alliances, worstCase ) )
	}

	return worstCase
}

float function GetTeamMaxFillWidth( var panel )
{
	int teams = file.panels[panel].teams
	int playersPerTeam = file.panels[panel].playersPerTeam
	int maxFittableRows = file.panels[panel].maxFittableRows
	int mode = file.panels[panel].gamemode

	float screenWidth = float( Hud_GetWidth( panel ) )
	float width = 0

	int teamsPerRow = GetTotalTeamsPerRow( panel )

	                            
	if(mode == 4)
		return screenWidth * 0.9

	switch( teamsPerRow )
	{
		case 1:
			width = screenWidth * 0.45
			break
		case 2:
			if( mode == 2 )
				width = screenWidth * 0.62                                                            
			else
				width = screenWidth * 0.70
			break
		case 3:
		default:
			width = IsCustomMatchLobbyMenu()? screenWidth * 0.95: screenWidth * 0.9
			break
	}
	return width
}

                                                                            
void function HideAll( var panel)
{
	                 
	array<var> items = GetPanelElementsByClassname( panel, scoreboardHeaderClasses[scoreboardHeaderTypes.DEFAULT] )
	foreach( var item in items)
		Hud_SetVisible( item, false )

	                 
	items = GetPanelElementsByClassname( panel, scoreboardHeaderClasses[scoreboardHeaderTypes.CONTROL] )
	foreach( var item in items)
		Hud_SetVisible( item, false )

	                
	items = GetPanelElementsByClassname( panel, scoreboardHeaderClasses[scoreboardHeaderTypes.ARENA] )
	foreach( var item in items)
		Hud_SetVisible( item, false )

	              
	items = GetPanelElementsByClassname( panel, scoreboardHeaderClasses[scoreboardHeaderTypes.TINY] )
	foreach( var item in items)
		Hud_SetVisible( item, false )

                         
	                 
		items = GetPanelElementsByClassname( panel, scoreboardHeaderClasses[scoreboardHeaderTypes.GUN_GAME] )
		foreach( var item in items)
			Hud_SetVisible( item, false )
       

                       
		                 
		items = GetPanelElementsByClassname( panel, scoreboardHeaderClasses[scoreboardHeaderTypes.WINTER_EXPRESS] )
		foreach( var item in items)
			Hud_SetVisible( item, false )
       

                     
		             
		items = GetPanelElementsByClassname( panel, scoreboardHeaderClasses[scoreboardHeaderTypes.TDM] )
		foreach( var item in items)
			Hud_SetVisible( item, false )
       


	         
	items = GetPanelElementsByClassname( panel, "TeamPlayer" )
	foreach( var item in items)
		Hud_SetVisible( item, false )

	        
	items = GetPanelElementsByClassname( panel, "TeamFrameGeneric" )
	foreach( var item in items)
		Hud_SetVisible( item, false )

	items = GetPanelElementsByClassname( panel, "TeamFrameTiny" )
	foreach( var item in items)
		Hud_SetVisible( item, false )
}

bool function ShouldUseTinyMode( var panel )
{
	int teams = file.panels[panel].teams
	return teams > 10
}

string function GetHeaderClassName( var panel )
{
	int gamemode = file.panels[panel].gamemode
	int teams = file.panels[panel].teams
	string className = scoreboardHeaderClasses[scoreboardHeaderTypes.DEFAULT]

	if( IsCustomMatchLobbyMenu() )
		return scoreboardHeaderClasses[scoreboardHeaderTypes.TINY]

	switch(gamemode)
	{
		case 0:
			if( ShouldUseTinyMode( panel ) )
				className = scoreboardHeaderClasses[scoreboardHeaderTypes.TINY]
			else
				className = scoreboardHeaderClasses[scoreboardHeaderTypes.DEFAULT]
			break
		case 1:
			className = scoreboardHeaderClasses[scoreboardHeaderTypes.ARENA]
			break
		case 2:
			className = scoreboardHeaderClasses[scoreboardHeaderTypes.CONTROL]
			break
                          
		case 3:
			className = scoreboardHeaderClasses[scoreboardHeaderTypes.GUN_GAME]
			break
        
                        
		case 4:
			className = scoreboardHeaderClasses[scoreboardHeaderTypes.WINTER_EXPRESS]
			break
        
                      
		case 5:
			className = scoreboardHeaderClasses[scoreboardHeaderTypes.TDM]
			break
        
	}

	return className
}

string function GetFrameClassName( var panel )
{
	if( ShouldUseTinyMode(panel ) )
		return "TeamFrameTiny"

	return "TeamFrameGeneric"
}

                                                               
void function CheckHeaderCountRestraints( var panel )
{
	array<var> teamHeaders = file.panels[panel].teamHeaders
	array<var> teamPlayers = file.panels[panel].teamPlayers
	array<var> teamFrames = file.panels[panel].teamFrames
	int teams = file.panels[panel].teams
	int playersPerTeam = file.panels[panel].playersPerTeam

	int playersNeeded = teams * playersPerTeam

	Assert( !( playersNeeded > teamPlayers.len() ), "To many players in mode for scoreboard to support. Add more Player Buttons in teams_scoreboard.res" )
	Assert( !( teams > teamHeaders.len() ), "To many teams in mode for scoreboard to support. Add more Team Headers in teams_scoreboard.res" )
	if( !ShouldUseTinyMode( panel ) )
		Assert( !( teams > teamFrames.len() ), "To many teams in mode for scoreboard to support. Add more Team Frames in teams_scoreboard.res" )
}

float function GetHPadding( var panel )
{

	float screenSizeFrac = GetScreenSize().height / 1080.0
	if( ShouldUseTinyMode(panel ) )
		return 22.0 * screenSizeFrac

	return 35.0 * screenSizeFrac
}

float function GetVPadding( var panel )
{
	int gamemode = file.panels[panel].gamemode

	float screenSizeFrac = GetScreenSize().height / 1080.0
	if( ShouldUseTinyMode(panel ) )
		return 22.0 * screenSizeFrac

	return 25.0 * screenSizeFrac
}

void function UI_ClearLocalPlayerToolTip( var panel, int localPlayersRow )
{
	array<var> teamPlayers = file.panels[panel].teamPlayers

	if( file.panels[panel].lastLastPlayerRow != -1 )
	{
		int previous = ( file.panels[panel].localPlayersTeam * file.panels[panel].playersPerTeam ) + file.panels[panel].lastLastPlayerRow
		SetPlayerTooltip( teamPlayers[previous] )
	}
	int new = ( file.panels[panel].localPlayersTeam * file.panels[panel].playersPerTeam ) + localPlayersRow
	Hud_ClearToolTipData( teamPlayers[ new ] )

	file.panels[panel].lastLastPlayerRow = localPlayersRow
}

void function UI_SetScoreboardTeamData( var panel, int teams, int playersPerTeam, int localPlayersTeam, int gamemode )
{
	if( panel == null )
		return

	if( !( panel in file.panels) )                                                            
	{
		PanelGroupData data
		file.panels[panel] <- data
	}

	file.panels[panel].teams = teams
	file.panels[panel].playersPerTeam = playersPerTeam
	file.panels[panel].localPlayersTeam = localPlayersTeam
	file.panels[panel].gamemode = gamemode
	file.panels[panel].vPadding = GetVPadding( panel )
	file.panels[panel].hPadding = GetHPadding( panel )
	HideAll( panel )

	file.panels[panel].teamFrames =  GetPanelElementsByClassname( panel, GetFrameClassName( panel ) )
	array<var> teamHeaders = GetPanelElementsByClassname( panel, GetHeaderClassName( panel ) )
	file.panels[panel].teamHeaders = teamHeaders
	array<var> teamPlayers = GetPanelElementsByClassname( panel, "TeamPlayer" )
	file.panels[panel].teamPlayers = teamPlayers

	CheckHeaderCountRestraints( panel )

	UISize screenSize = GetScreenSize()

	float screenSizeXFrac =  GetScreenSize().width / 1920.0
	float screenSizeYFrac =  GetScreenSize().height / 1080.0

	float tabsHeight = (( IsCustomMatchLobbyMenu() )? 0.0: 85.0 ) * screenSizeYFrac
	float buttonLegendHeight = (( IsCustomMatchLobbyMenu() )? 0.0: 65.0 ) * screenSizeYFrac
	float extraPadding = (( IsCustomMatchLobbyMenu() )? 0.0: 50.0 )

	float avialableHeight = Hud_GetHeight( panel ) - tabsHeight - buttonLegendHeight - extraPadding

	int headerHeight = Hud_GetHeight( teamHeaders[ 0 ] )
	int playersHeight = Hud_GetHeight( teamPlayers[ 0 ] ) * playersPerTeam + ( PLAYERS_Y_PADDING_OFFSET * ( playersPerTeam - 1 ) )

	                                                     
	int maxFittableRows = GetTotalFittableRows( panel, headerHeight, playersHeight, avialableHeight )
	file.panels[panel].maxFittableRows = maxFittableRows
	float totalPaddingsToUse = max(teams - 1, 0)
	float maxFillWidth = GetTeamMaxFillWidth( panel )
	float minTeamWidth = GetTeamMinWidth( panel, maxFillWidth )

	float teamWidth = clamp( maxFillWidth / teams , minTeamWidth, maxFillWidth )
	float teamHeight = float( headerHeight + playersHeight )
	file.panels[panel].teamWidth = teamWidth
	file.panels[panel].teamHeight = teamHeight

	int teamsPerRow = GetTotalTeamsPerRow( panel )
	float totalRows = ceil( float( teams ) / float( teamsPerRow ) )
	file.panels[panel].teamsPerRow = teamsPerRow                    
	file.panels[panel].firstTeamOffsetX = -1 * ( min( Hud_GetWidth( panel ) , 1920 * screenSizeYFrac ) - ( teamsPerRow * teamWidth ) - ( max(teamsPerRow - 1, 0) * file.panels[panel].hPadding  ) ) / 2.0

	float vSpaceTakenByHeaders = headerHeight * totalRows
	float vSpaceTakenByPlayers = playersHeight * totalRows
	float vSpaceTakenByPadding = max(totalRows - 1, 0) * file.panels[panel].vPadding
	file.panels[panel].firstTeamOffsetY = -1 * ( tabsHeight + ( ( avialableHeight - vSpaceTakenByHeaders - vSpaceTakenByPlayers - vSpaceTakenByPadding ) / 2 ) )
	int teamsAdded = 0

	if( localPlayersTeam >= 0)
	{
		var teamHeader = UpdateTeamHeader( panel, localPlayersTeam, teamsAdded )

		for( int playerRow = 0; playerRow <= playersPerTeam - 1; playerRow++ )
		{
			UpdateTeamPlayer( panel, teamHeader, teamsAdded, localPlayersTeam, playerRow )
		}
		teamsAdded++
	}

	for( int teamIndex = 0; teamIndex < teams; teamIndex++ )
	{
		if( teamIndex ==  localPlayersTeam )
			continue

		int correctedTeamIndex = CustomMatchTeamRoster_GetCorrectedTeamId( teamIndex, false )
		var teamHeader = UpdateTeamHeader( panel, correctedTeamIndex, teamsAdded )

		for( int playerRow = 0; playerRow <= playersPerTeam - 1; playerRow++ )
		{
			UpdateTeamPlayer( panel, teamHeader,teamsAdded, correctedTeamIndex, playerRow )
		}
		teamsAdded++
	}

}

var function UpdateTeamHeader( var panel, int teamIndex, int teamsAdded )
{
	array<var> teamPlayers = GetPanelElementsByClassname( panel, "TeamPlayer" )

	int playersPerTeam = file.panels[panel].playersPerTeam
	int teamsPerRow = file.panels[panel].teamsPerRow
	float firstTeamOffsetX = file.panels[panel].firstTeamOffsetX
	float firstTeamOffsetY = file.panels[panel].firstTeamOffsetY
	float teamWidth = file.panels[panel].teamWidth
	array<var> teamHeaders = file.panels[panel].teamHeaders
	float vPadding = file.panels[panel].vPadding
	float hPadding = file.panels[panel].hPadding

	var teamHeader = teamHeaders[ teamsAdded ]
	Hud_SetWidth( teamHeader, teamWidth )
	Hud_SetVisible( teamHeader, true )

	if( teamsAdded != 0 )
	{
		if( teamsAdded % teamsPerRow == 0 )                       
		{
			float onRowNumber = floor( teamsAdded / teamsPerRow )
			float pinToRow = max( onRowNumber - 1.0, 0)
			int previousPlayerRowIndex = int( pinToRow * ( teamsPerRow * playersPerTeam ) + playersPerTeam - 1 )
			if( previousPlayerRowIndex >= 0 )
			{
				var previousFirstItemLastPlayer = teamPlayers[ previousPlayerRowIndex ]
				Hud_SetPinSibling( teamHeader, Hud_GetHudName( previousFirstItemLastPlayer ) )
				Hud_SetX( teamHeader,  0 )
				Hud_SetY( teamHeader, -1 * ( Hud_GetHeight( previousFirstItemLastPlayer ) + vPadding ) )
			}
		}
		else
		{
			Hud_SetPinSibling( teamHeader, Hud_GetHudName( teamHeaders[ teamsAdded - 1 ] ) )
			Hud_SetX( teamHeader,  -1 * ( Hud_GetWidth( teamHeaders[ teamsAdded - 1 ] ) + hPadding ) )
			Hud_SetY( teamHeader, 0 )
		}
	}
	else
	{
		                                                                      
		Hud_SetX( teamHeader, firstTeamOffsetX )
		Hud_SetY( teamHeader, firstTeamOffsetY )
	}

	var teamFrame = UpdateTeamFrame( panel, teamHeader, teamsAdded )

	if( IsCustomMatchLobbyMenu() )
		ScoreboardMenu_CustomMatch_BindTeamHeader( teamHeader, teamFrame, teamIndex )
	else
		RunClientScript( "UICallback_ScoreboardMenu_BindTeamHeader", teamHeader, teamFrame, teamIndex, Hud_GetWidth( teamHeader ) )

	return teamHeader
}

var function UpdateTeamFrame( var panel, var teamHeader,  int teamIndex )
{
	array<var> teamFrames = file.panels[panel].teamFrames
	float teamHeight = file.panels[panel].teamHeight
	float teamWidth = file.panels[panel].teamWidth

	var treamFrame = teamFrames[ teamIndex ]

	Hud_SetVisible( treamFrame, true )
	Hud_SetPinSibling( treamFrame, Hud_GetHudName( teamHeader ) )
	Hud_SetWidth( treamFrame, teamWidth )
	Hud_SetHeight( treamFrame, teamHeight )

	return treamFrame
}

void function UpdateTeamPlayer( var panel, var teamHeader, int teamsAdded, int teamIndex, int playerRow )
{
	array<var> teamPlayers = GetPanelElementsByClassname( panel, "TeamPlayer" )
	int playersPerTeam = file.panels[panel].playersPerTeam
	float teamWidth = file.panels[panel].teamWidth

	int startAt = ( teamsAdded * playersPerTeam )
	int playerIndex = startAt + playerRow

	if( startAt + playerRow > teamPlayers.len() - 1 )
		return

	var teamPlayerButton = teamPlayers[ startAt + playerRow ]
	SetPlayerTooltip( teamPlayerButton )
	Hud_SetWidth( teamPlayerButton, teamWidth )
	Hud_SetVisible( teamPlayerButton, true )


	if( playerRow == 0 )
	{
		Hud_SetPinSibling( teamPlayerButton, Hud_GetHudName( teamHeader ) )
		Hud_SetX( teamPlayerButton, 0)
		Hud_SetY( teamPlayerButton,  ( -1 * Hud_GetHeight( teamHeader ) ) )
	}
	else
	{
		Hud_SetPinSibling( teamPlayerButton, Hud_GetHudName( teamPlayers[ playerIndex - 1 ] ) )
		Hud_SetX( teamPlayerButton, 0 )
		Hud_SetY( teamPlayerButton, ( -1 * Hud_GetHeight( teamPlayerButton ) ) - PLAYERS_Y_PADDING_OFFSET )
	}

	PlayerButtonData playerData
	playerData.row = playerRow
	playerData.teamId = teamIndex

	file.playerButtonData[ teamPlayerButton ] <- playerData
	file.panels[panel].playerButtons.append( teamPlayerButton )

	if( IsCustomMatchLobbyMenu() )
		ScoreboardMenu_CustomMatch_BindTeamRow( teamPlayerButton, teamIndex, playerRow, teamWidth )
	else
		RunClientScript( "UICallback_ScoreboardMenu_BindTeamRow", panel, teamPlayerButton, teamIndex, playerRow, teamWidth )
}

void function SetPlayerTooltip( var button )
{
	if( IsCustomMatchLobbyMenu() )
		return

	Hud_ClearToolTipData( button )

	int teamId = -1
	int row = -1 
	if( button in file.playerButtonData )
	{
		teamId = file.playerButtonData[button].teamId
		row = file.playerButtonData[button].row
	}
	
	
	RunClientScript( "IsLocalPlayerOnTeamSpectatorWithCallback", button, teamId, row )
}
void function SetPlayerTooltipAfterCallback( var button, bool isMatchAdminSpectator,  bool viewProfileAllowed )
{
	file.panels[file.activePanel].isMatchAdminSpectator = isMatchAdminSpectator
	ToolTipData toolTipData
	toolTipData.tooltipStyle = eTooltipStyle.BUTTON_PROMPT
	
	if( CustomMatch_IsInCustomMatch() && isMatchAdminSpectator )
	{
		toolTipData.actionHint1 = "#A_BUTTON_SPECTATE"
	}
	else
	{
		toolTipData.actionHint1 = "#X_BUTTON_REPORT"
	}
	
	if( viewProfileAllowed )
	{
#if NX_PROG
		toolTipData.actionHint2 = "#Y_BUTTON_USER_PAGE"
#else
		toolTipData.actionHint2 = IsControllerModeActive() ? "#Y_BUTTON_VIEW_PROFILE" : "#Y_BUTTON_VIEW_PROFILE_PC"
#endif
	}
	

	Hud_SetToolTipData( button, toolTipData )
}

void function UI_ToggleReportTooltip( var button, bool toggle )
{
	if( toggle )
		SetPlayerTooltip( button )
	else
		Hud_ClearToolTipData( button )
}

void function ShowPCPlatOverlayWarning()
{
	string platname = PCPlat_IsOrigin() ? "ORIGIN" : "STEAM"
	ConfirmDialogData dialogData
	dialogData.headerText   = ""
	dialogData.messageText  = "#" + platname + "_INGAME_REQUIRED"
	dialogData.contextImage = $"ui/menu/common/dialog_notice"


	OpenOKDialogFromData( dialogData )
}

void function HandleViewProfileScoreboardPlayer( var button )
{
	var teamPlayerButtonFocused = GetFocus()
	
	if( IsValid( teamPlayerButtonFocused ) && teamPlayerButtonFocused != null && teamPlayerButtonFocused in file.playerButtonData )
	{
		PlayerButton_OnKeyPress( teamPlayerButtonFocused, KEY_F, true )
	}
}

bool function PlayerButton_OnKeyPress( var button, int keyId, bool isDown )
{
	if ( !isDown )
		return false

	if( IsCustomMatchLobbyMenu() )
		return CustomMatchTeamRoster_OnKeyPress( button, keyId, isDown )

	if( !Hud_IsEnabled( button ) )
		return false

	bool isCustomMatchSpectator = CustomMatch_IsInCustomMatch() && file.panels[file.activePanel].isMatchAdminSpectator
	if ( ( keyId == MOUSE_RIGHT || keyId == BUTTON_X ) && !isCustomMatchSpectator )                                                        
	{
		RunClientScript( "UICallback_Scoreboard_OnReportClicked", button, file.playerButtonData[button].teamId, file.playerButtonData[button].row )

		return true
	}
	else if ( keyId == MOUSE_LEFT || keyId == BUTTON_A )
	{
		RunClientScript( "ClientCallback_Teams_OnPlayerClicked", file.playerButtonData[button].teamId, file.playerButtonData[button].row )
		return true
	}
	
	if ( keyId == KEY_F || keyId == BUTTON_Y )
	{
#if PC_PROG
		if ( !PCPlat_IsOverlayAvailable() )
		{
			ShowPCPlatOverlayWarning()
			return true
		}
#endif
		RunClientScript( "ClientCallback_Teams_OnPlayerViewProfile", file.playerButtonData[button].teamId, file.playerButtonData[button].row )
		return true
	}

	return false
}

void function UI_SetScoreboardTitle( var panel, string text )
{
	var rui = Hud_GetRui(Hud_GetChild(panel, "ScoreboardTitle"))
	RuiSetString( rui, "titleText", text )
}

void function UI_SetScoreboardAnimateIn( var panel, float duration = 0.25 )
{
	thread ScoreboardFadeThread( panel, duration, false )

	Hud_SetY( panel, 40 )
	Hud_ReturnToBasePosOverTime( panel, duration, INTERPOLATOR_DEACCEL )
}

void function UI_SetScoreboardAnimateOut( var panel, float duration = 0.25 )
{
	thread ScoreboardFadeThread( panel, duration, true )

	Hud_SetYOverTime( panel, 0, duration, INTERPOLATOR_DEACCEL )
}

void function ScoreboardFadeThread( var panel, float duration = 1.0, bool isBackwards = false )
{
	if( !( panel in file.panels ) )
		return

	float startTime = UITime()
	float currentTime = UITime()
	while( startTime + duration > currentTime && file.panels[panel].isOpen )
	{
		float percentage = (currentTime - startTime) / duration

		if( isBackwards )
			percentage = 1.0 - percentage

		ScoreboardSetAlpha( panel, percentage )

		currentTime = UITime()
		WaitFrame()
	}

	if( isBackwards )
		ScoreboardSetAlpha( panel, 0.0 )
	else
		ScoreboardSetAlpha( panel, 1.0 )
}

void function ScoreboardSetAlpha( var panel, float alpha )
{
	array<var> teamPlayers = GetPanelElementsByClassname( panel, "TeamPlayer" )
	foreach( teamPlayer in file.panels[panel].teamPlayers )
	{
		var rui = Hud_GetRui( teamPlayer )
		RuiSetFloat( rui, "alpha", alpha )
	}

	foreach( teamFrame in file.panels[panel].teamFrames )
	{
		var rui = Hud_GetRui( teamFrame )
		RuiSetFloat( rui, "alpha", alpha )
	}

	foreach( teamHeader in file.panels[panel].teamHeaders )
	{
		var rui = Hud_GetRui( teamHeader )
		RuiSetFloat( rui, "alpha", alpha )
	}

	var rui = Hud_GetRui(Hud_GetChild(panel, "ScoreboardTitle"))
	RuiSetFloat( rui, "alpha", alpha )
}

bool function TinyTeamHeaderButton_OnKeyPress ( var button, int keyId, bool isDown )
{
	if ( !isDown )
		return false

	if( IsCustomMatchLobbyMenu() )
		return CustomMatchTeamRoster_OnKeyPress( button, keyId, isDown )

	return false
}

int function ScoreboardMenu_CustomMatch_GetButtonTeamID( var button )
{
	int playerButtonIndex = file.panels[file.activePanel].teamPlayers.find( button )
	int headerIndex = file.panels[file.activePanel].teamHeaders.find( button )

	if( playerButtonIndex != -1 )
	{
		int playersPerTeam = file.customMatchData.maxPlayers / file.customMatchData.maxTeams
		return ( playerButtonIndex / playersPerTeam ) + TEAM_IMC
	}
	else if( headerIndex != -1 )
	{
		return headerIndex + TEAM_IMC
	}
	return -1
}

var function ScoreboardMenu_CustomMatch_GetHeaderForButton( var button )
{
	int headerIndex = ScoreboardMenu_CustomMatch_GetButtonTeamID( button ) - TEAM_IMC
	if( headerIndex >= 0 && file.panels[file.activePanel].teamHeaders.len() > headerIndex )
		return file.panels[file.activePanel].teamHeaders[ headerIndex ]

	return null
}

                                                                    
                              
                                                                    
bool function IsCustomMatchLobbyMenu()
{
	return IsLobby() && CustomMatch_IsInCustomMatch()
}

void function ScoreboardMenu_CustomMatch_BindTeamHeader( var header, var frame, int teamIndex )
{
	if( !IsCustomMatchLobbyMenu() )
		return

	if ( !IsFullyConnected() )
		return

	string match_type = GetPlaylistVarString( file.customMatchData.playlist, "pin_match_type", "" )
	int max_alliances = GetPlaylistVarInt( file.customMatchData.playlist, "max_alliances", 0 )
	int totalTeams =  file.customMatchData.maxTeams
	int playersPerTeam = file.customMatchData.maxPlayers / file.customMatchData.maxTeams

	var headerRui = Hud_GetRui( header )
	var frameRui = Hud_GetRui( frame )

	vector teamColor
	string teamName

	if (match_type != "survival" && ( totalTeams == 2  || max_alliances == 2) )                      
	{
		vector friendlyColor = SrgbToLinear( GetKeyColor( COLORID_CONTROL_FRIENDLY )/255 )
		vector enemyColor = SrgbToLinear( GetKeyColor( COLORID_CONTROL_ENEMY )/255 )

		if( max_alliances > 0 )
		{
			int teamsPerAlliance = totalTeams / max_alliances
			int alliance = ( teamIndex % max_alliances )
			teamName = Localize( "#TEAM_NUMBERED", (alliance + 1) )
			teamColor = ( alliance == 0 )? friendlyColor: enemyColor
		}
		else
		{
			teamName = Localize( "#TEAM_NUMBERED", (teamIndex + 1) )
			teamColor = ( teamIndex == 0 )? friendlyColor: enemyColor
		}
	}
	else if( match_type == "survival" || totalTeams > Squads_GetMax() )
	{
		teamName = Localize( "#TEAM_NUMBERED", (teamIndex + 1) )
		teamColor = SrgbToLinear( GetSkydiveSmokeColorForTeam( teamIndex + TEAM_IMC ) / 255.0 )
	}
	else
	{
		bool isWinterExpress = match_type == "winter_express"
		if( max_alliances > 0 )
		{
			int teamsPerAlliance = totalTeams / max_alliances
			int alliance = ( teamIndex % max_alliances )

			teamName = Localize( Squads_GetSquadName( alliance, isWinterExpress ) )
			teamColor = Squads_GetSquadColor( alliance, isWinterExpress )
		}
		else
		{
			teamName = Localize( Squads_GetSquadName( teamIndex, isWinterExpress ) )
			teamColor = Squads_GetSquadColor( teamIndex, isWinterExpress )
		}
	}

	if( (teamIndex + TEAM_IMC) in file.customMatchData.teamNames )
	{
		string customMatchName = file.customMatchData.teamNames[teamIndex + TEAM_IMC]
		
		if( customMatchName != "" )
			teamName += " (" + customMatchName + ")"
	}

	RuiSetString( headerRui, "headerText", teamName )
	RuiSetColorAlpha( headerRui, "teamColor", teamColor, 1 )
	RuiSetColorAlpha( frameRui, "teamColor", teamColor, 1 )
	RefreshTeamToolTip( header, teamIndex + TEAM_IMC, true, true )
}

void function ScoreboardMenu_CustomMatch_BindTeamRow( var button, int teamIndex, int row, float teamWidth )
{
	if( !IsCustomMatchLobbyMenu() )
		return

	CustomMatch_LobbyPlayer player
	string playerName = ""
	string hardware = ""
	bool enabled = false
	var buttonRui = Hud_GetRui( button )

	Hud_SetChecked( button, false )
	Hud_SetNew( button, false )

	if(file.customMatchDataPlayersSorted.len() > teamIndex )                     
	{
		if( file.customMatchDataPlayersSorted[ teamIndex ].len() > row )                      
		{
			player = file.customMatchDataPlayersSorted[ teamIndex ][row]

			playerName = player.name
			if(player.isAdmin)
				playerName = Localize( "`1%$rui/menu/lobby/party_leader_icon%`0 " ) + playerName

			hardware = PlatformIDToIconString( GetHardwareFromName( player.hardware ) )

			Hud_SetLocked( button, false )
			enabled = true

			Hud_SetChecked( button, ( player.flags & ( CUSTOM_MATCH_PLAYER_BIT_IS_READY | CUSTOM_MATCH_PLAYER_BIT_IS_MATCHMAKING ) ) != 0 )
			Hud_SetNew( button, ( player.flags & CUSTOM_MATCH_PLAYER_BIT_IS_PRELOADING ) != 0 )


		}
		Hud_ClearEventHandlers( button, UIE_CLICK )

		Hud_AddEventHandler( button, UIE_CLICK, void function( var _ ) : ( button, player, enabled ) {
			if( enabled && CustomMatch_IsLocalAdmin())
				CustomMatchLobby_OnDragPlayer( player )
			else
			{
				var header = ScoreboardMenu_CustomMatch_GetHeaderForButton( button )
				if( header != null )
					CustomMatchTeamHeader_OnLeftClick( ScoreboardMenu_CustomMatch_GetHeaderForButton ( header ) )
			}

		} )

		RefreshTeamToolTip( button, teamIndex + TEAM_IMC, !enabled, false )
	}

	RuiSetString( buttonRui, "playerName", playerName )
	RuiSetString( buttonRui, "platformIcon", hardware )
	RuiSetBool( buttonRui, "isEmpty", true )
	RuiSetInt( buttonRui, "bleedoutEndTime", 0 )

	RuiSetFloat( buttonRui, "rowWidth", teamWidth )
	RuiSetInt( buttonRui, "screenHeight", GetScreenSize().height )
	RuiSetInt( buttonRui, "screenWidth", GetScreenSize().width )

}
                                                                    
                       
                                                                    
bool function CanAction( int action )
{
	return ( ( file.actionBitmask & ( 1 << action ) ) != 0 )
}

void function SetAction( int action, bool enable )
{
	if( !IsCustomMatchLobbyMenu() )
		return

	if( enable )
		file.actionBitmask = file.actionBitmask | ( 1 << action )
	else
		file.actionBitmask = file.actionBitmask & ~( 1 << action )
}

bool function ActionsLocked()
{
	return CustomMatch_GetSetting( CUSTOM_MATCH_SETTING_MATCH_STATUS ) != CUSTOM_MATCH_STATUS_PREPARING
}

bool function ContainsPlayer( var button )
{
	if( button in file.playerButtonData )
	{
		
		int teamIndex = file.playerButtonData[button].teamId
		int row = file.playerButtonData[button].row
		
		return file.customMatchDataPlayersSorted.len() > teamIndex && file.customMatchDataPlayersSorted[teamIndex].len() > row	
	}
	
	return false
}

bool function TryDisplayInspect( var button )
{
	bool displayedInspect = false
	if( ContainsPlayer( button ) )
	{
		CustomMatch_LobbyPlayer player = file.customMatchDataPlayersSorted[ file.playerButtonData[ button ].teamId ][ file.playerButtonData[ button ].row ]

		Friend customMatchPlayerToFriend
		customMatchPlayerToFriend.name = player.name
		customMatchPlayerToFriend.id = player.uid
		customMatchPlayerToFriend.hardware = player.hardware
		customMatchPlayerToFriend.eadpData = CreateEADPDataFromEAID( player.eaid )

		InspectFriendForceEADP( customMatchPlayerToFriend, PCPlat_IsSteam() )

		displayedInspect = true
	}

	return displayedInspect
}


bool function CanKickTeam( int index )
{
	if( !IsCustomMatchLobbyMenu() )
		return false

	if ( !CustomMatch_IsLocalAdmin() )
		return false

	array<CustomMatch_LobbyPlayer> team = CustomMatch_GetTeam( index )
	switch( team.len() )
	{
		                                 
		case 0:
			return false

			                   
		case 1:
			return team[0].uid != GetPlayerUID()

		default:
			return true
	}
	unreachable
}

void function TryDisplayKickTeam( int index )
{
	if( !IsCustomMatchLobbyMenu() )
		return

	if ( InputIsButtonDown( MOUSE_LEFT ) || InputIsButtonDown( BUTTON_A ) )
		return

	if ( CanKickTeam( index ) )
		CustomMatch_ShowKickDialog( CustomMatch_GetTeam( index ) )
}

bool function CanRenameTeam( int teamIndex )
{
	if ( !CustomMatch_HasSpecialAccess() )
		return false

	if( !IsCustomMatchLobbyMenu() )
		return false

	if( CustomMatch_IsLocalAdmin() )
		return true

	return ( CustomMatch_GetLocalPlayerData().team == teamIndex )
	&& CanAction( eRosterAction.RENAME_TEAM )
}

                                                                    
                        
                                                                    
void function RefreshTeamToolTip( var button, int teamIndex, bool isValidJoin = true, bool renameTeam = false )
{
	ToolTipData toolTipData = Hud_GetToolTipData( button )
	UpdateTeamToolTip( button, teamIndex, toolTipData.customMatchData.isTeamFull, IsControllerModeActive(), isValidJoin, renameTeam )
}

void function UpdateTeamToolTip( var button, int teamIndex, bool teamFull, bool controllerModeActive, bool isValidJoin = true, bool renameTeam = false )
{
	if( !IsCustomMatchLobbyMenu() )
		return

	ToolTipData toolTipData
	toolTipData.tooltipStyle = eTooltipStyle.CUSTOM_MATCHES

	toolTipData.customMatchData.isAdmin = CustomMatch_IsLocalAdmin()
	toolTipData.customMatchData.isTeamFull = teamFull
	toolTipData.customMatchData.adminActions = 0
	toolTipData.customMatchData.actionEnabledMask = 0

	toolTipData.titleText = CustomMatch_IsLocalAdmin() ? Localize( "#CUSTOM_MATCH_TOOLTIP_ADMIN" ) : ""

	                                                                                                                   
	                                                                                                                            
	int actionCount = 0;

	bool canAction = !ActionsLocked()
	bool isOwnTeam = CustomMatch_GetLocalPlayerData().team == teamIndex
	if ( CanRenameTeam( teamIndex ) && renameTeam )
	{
		toolTipData.customMatchData.adminActions++
		SetTooltipAction( toolTipData, ++actionCount, "#CUSTOM_MATCH_CHANGE_TEAM_NAME_PROMPT", canAction && CanAction( eRosterAction.RENAME_TEAM ) )
	}

	if ( CanKickTeam( teamIndex ) )
	{
		toolTipData.customMatchData.adminActions++
		string text = controllerModeActive ? "#CUSTOM_MATCH_HOLD_KICK_PLAYERS" : "#CUSTOM_MATCH_KICK_PLAYERS"
		SetTooltipAction( toolTipData, ++actionCount, text, canAction )
	}

	if ( isOwnTeam )
	{
		if( controllerModeActive )
			SetTooltipAction( toolTipData, ++actionCount, "#CUSTOM_MATCH_HOLD_LEAVE_TEAM", canAction && CanAction( eRosterAction.SELF_ASSIGN ) )
	}
	else if ( teamFull )
	{
		SetTooltipAction( toolTipData, ++actionCount, "#CUSTOM_MATCH_TEAM_FULL", true )                             
	}
	else if( CustomMatch_GetLocalPlayerData().team == 0 || CustomMatch_GetLocalPlayerData().team == 1 )
	{
		SetTooltipAction( toolTipData, ++actionCount, "#CUSTOM_MATCH_JOIN_TEAM", canAction && CanAction( eRosterAction.SELF_ASSIGN ) )
	}
	else if( isValidJoin )
	{
		SetTooltipAction( toolTipData, ++actionCount, "#CUSTOM_MATCH_MOVE_TO_TEAM", canAction && CanAction( eRosterAction.SELF_ASSIGN ) )
	}
	
	                                                                                                      
	if( !renameTeam && ContainsPlayer( button ) )
	{
		SetTooltipAction( toolTipData, ++actionCount, "#Y_BUTTON_INSPECT", canAction )  
	}

	if( actionCount == 0 )
		Hud_ClearToolTipData( button )
	else
		Hud_SetToolTipData( button, toolTipData )
}

void function SetTooltipAction( ToolTipData toolTipData, int actionIndex, string text, bool enabled )
{
	if( !IsCustomMatchLobbyMenu() )
		return

	switch( actionIndex )
	{
		case 1:
			toolTipData.actionHint1 = Localize( text )
			break
		case 2:
			toolTipData.actionHint2 = Localize( text )
			break
		case 3:
			toolTipData.actionHint3 = Localize( text )
			break
		default:
			Assert( actionIndex < 3 )
			break
	}

	if ( enabled )
		toolTipData.customMatchData.actionEnabledMask = toolTipData.customMatchData.actionEnabledMask | ( 1 << actionIndex )
}

                                                                    
                              
                                                                    
void function Callback_OnCustomMatchLobbyDataChanged( CustomMatch_LobbyState data )
{
	if( !IsCustomMatchLobbyMenu() )
		return

	file.customMatchData = data

	array< array<CustomMatch_LobbyPlayer> > teams
	teams.resize( data.maxTeams )
	foreach ( CustomMatch_LobbyPlayer player in data.players )
	{

		int teamIndex = player.team - TEAM_MULTITEAM_FIRST
		if( 0 <= teamIndex && teamIndex < data.maxTeams )
			teams[ teamIndex ].append( player )
	}

	file.customMatchDataPlayersSorted = teams

	UI_SetScoreboardTeamData( file.activePanel, data.maxTeams, data.maxPlayers / data.maxTeams, -1, -1 )
}

const string ON = "1"
void function Callback_OnSelfAssignChanged( string _, string value )
{
	if ( !IsCustomMatchLobbyMenu() )
		return

	bool oldSetting = CanAction( eRosterAction.SELF_ASSIGN )
	bool newSetting = ( value == ON ) || CustomMatch_IsLocalAdmin()

	if ( oldSetting != newSetting )
	{
		SetAction( eRosterAction.SELF_ASSIGN, newSetting )
	}
}

void function Callback_OnRenameTeamChanged( string _, string value )
{
	if( !IsCustomMatchLobbyMenu() )
		return

	bool oldSetting = CanAction( eRosterAction.RENAME_TEAM )
	bool newSetting = ( value == ON ) || CustomMatch_IsLocalAdmin()

	if ( oldSetting != newSetting && CustomMatch_HasSpecialAccess())
	{
		SetAction( eRosterAction.RENAME_TEAM, newSetting )
	}
}

                                                                    
                       
                                                                    
void function CustomMatchTeamHeader_OnLeftClick( var button )
{
	if( !IsCustomMatchLobbyMenu() )
		return

	if ( ActionsLocked() || !CanAction( eRosterAction.SELF_ASSIGN ) )
		return

	int teamIndex = ScoreboardMenu_CustomMatch_GetButtonTeamID( button )
	int correctedTeamIndex = CustomMatchTeamRoster_GetCorrectedTeamId( teamIndex )

	if ( correctedTeamIndex != CustomMatch_GetLocalPlayerData().team )
		CustomMatch_SetTeam( correctedTeamIndex, GetPlayerHardware(), GetPlayerUID() )
}

void function CustomMatchTeamRoster_OnRightClick( var button )
{
	if( !IsCustomMatchLobbyMenu() )
		return

	if ( ActionsLocked() || InputIsButtonDown( MOUSE_LEFT ) || InputIsButtonDown( BUTTON_A ) )
		return

	int teamIndex = ScoreboardMenu_CustomMatch_GetButtonTeamID( button )
	int correctedTeamIndex = CustomMatchTeamRoster_GetCorrectedTeamId( teamIndex ) - 1

	if ( !CanRenameTeam( correctedTeamIndex + 1 ) )
		return

	ConfirmDialogData data
	data.headerText = "#CUSTOM_MATCH_CHANGE_TEAM_NAME"
	data.messageText = Localize( "#CUSTOM_MATCH_CHANGE_TEAM_NAME_DESC", correctedTeamIndex )
	data.resultCallback = void function( int result )
	{
		CustomMatchLobby_OnSetTeamNameOpenOrClose( false )
	}
	CustomMatchLobby_OnSetTeamNameOpenOrClose( true )
	OpenTextEntryDialogFromData( data, void function( string name ) : ( correctedTeamIndex )
	{
		string _name = strip( name )
		CustomMatch_SetTeamName( correctedTeamIndex + 1, _name )
	} )
}

int function CustomMatchTeamRoster_GetCorrectedTeamId( int teamIndex = 0, bool useIMCOffset = true )
{
	int maxAlliances = GetPlaylistVarInt( file.customMatchData.playlist, "max_alliances", 0 )
	int correctedTeamIndex = teamIndex

	if( useIMCOffset && correctedTeamIndex < TEAM_IMC )                                                             
		return correctedTeamIndex

	if( IsCustomMatchLobbyMenu() && maxAlliances > 1 )
	{
		if( useIMCOffset )
			correctedTeamIndex = correctedTeamIndex - TEAM_IMC

		int teamsPerAlliance = file.customMatchData.maxTeams / maxAlliances
		correctedTeamIndex = ( ( correctedTeamIndex % teamsPerAlliance ) * maxAlliances ) + ( correctedTeamIndex / teamsPerAlliance )

		if( useIMCOffset )
			correctedTeamIndex = correctedTeamIndex + TEAM_IMC
	}

	return correctedTeamIndex
}
bool function CustomMatchTeamRoster_OnKeyPress( var button, int keyIndex, bool isPressed )
{
	if ( ActionsLocked() )
		return false

	if( !IsCustomMatchLobbyMenu() )
		return false

	if ( isPressed )
		return CustomMatchTeamRoster_OnKeyDown( button, keyIndex ) || CustomMatchTeamRoster_OnKeyHold( button, keyIndex )
	return false
}

bool function CustomMatchTeamRoster_OnKeyDown( var button, int keyIndex )
{
	if( !IsCustomMatchLobbyMenu() )
		return false

	int teamIndex = ScoreboardMenu_CustomMatch_GetButtonTeamID( button )
	int correctedTeamIndex = CustomMatchTeamRoster_GetCorrectedTeamId( teamIndex )

	switch ( keyIndex )
	{
		case KEY_F:
		case BUTTON_Y:
			return TryDisplayInspect( button )
		case KEY_K:
			TryDisplayKickTeam( correctedTeamIndex )
			return true
		default:
			return false
	}
	return false
}

bool function CustomMatchTeamRoster_OnKeyHold( var button, int keyIndex )
{
	if( !IsCustomMatchLobbyMenu() )
		return false

	int teamIndex = ScoreboardMenu_CustomMatch_GetButtonTeamID( button )
	int correctedTeamIndex = CustomMatchTeamRoster_GetCorrectedTeamId( teamIndex )

	switch ( keyIndex )
	{
		case BUTTON_STICK_RIGHT:
			thread OnHold_internal( keyIndex, correctedTeamIndex, TryDisplayKickTeam )
			return true
		default:
			return false
	}
	return false
}

const float BUTTON_HOLD_DELAY = 0.3
void function OnHold_internal( int button, int teamIndex, void functionref( int teamIndex ) func )
{
	if( !IsCustomMatchLobbyMenu() )
		return

	float endTIme = UITime() + BUTTON_HOLD_DELAY

	while ( InputIsButtonDown( button ) && UITime() < endTIme )
	{
		WaitFrame()
	}

	if ( InputIsButtonDown( button ) )
		func( teamIndex )
}
