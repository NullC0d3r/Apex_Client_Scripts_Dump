global function InitCustomMatchLobbyPanel
global function CustomMatchLobby_OnDragPlayer
global function CustomMatchLobby_OnSetTeamNameOpenOrClose
global function InitCustomMatchPanelFooter
struct
{
	var panel
	var startButton
	var dragIcon
	var dragTarget
	var chatTarget
	var chatInputLine
	var chatFrame

	bool setTeamNameIsOpen = false

	bool chatEnabled	= false
	bool isReady		= false
	bool isMatchmaking 	= false
	bool canAction		= false
	bool selfAssign		= false
	int teamIndex		= TEAM_UNASSIGNED
	bool isAutoClosing  = false
	int autoCloseRemainingTime = 0
	array<CustomMatch_LobbyPlayer> lobbyPlayers

	array<CustomMatch_LobbyPlayer> assignedPlayers
	bool hasRemainingPlayers = true
	bool hasRemainingAllianceOrTeam = true
	int remainingPlayers
	string gamemode

} file

const int AUTO_CLOSE_LOBBY_TIMER = 60

void function InitCustomMatchLobbyPanel( var panel )
{
	file.panel = panel
	file.dragIcon = Hud_GetChild( panel, "MouseDragIcon" )
	file.startButton = Hud_GetChild( panel, "StartButton" )
	file.chatTarget = Hud_GetChild( panel, "ChatPanel" )
	file.chatInputLine = Hud_GetChild( file.chatTarget, "ChatInputLine" )
	file.chatFrame = Hud_GetChild( panel, "ChatFrame" )

	AddUICallback_InputModeChanged( UICallback_InputModeChanged )

	AddButtonEventHandler( file.startButton, UIE_CLICK, StartMatch_OnClick )
	AddButtonEventHandler(file.chatFrame, UIE_CLICK, ChatBox_OnClick )

	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, CustomMatchLobby_OnShow )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, CustomMatchLobby_OnHide )

	InitCustomMatchPanelFooter( panel )

	AddCallback_OnCustomMatchPlayerDataChanged( Callback_OnPlayerDataChanged )
	AddCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_SELF_ASSIGN, Callback_OnSelfAssignChanged )
	AddCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_CHAT_PERMISSION, Callback_OnChatPermissionChanged )
	AddCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_MATCH_STATUS, Callback_OnMatchStatusChanged )
	AddCallback_OnCustomMatchLobbyDataChanged( Callback_OnLobbyDataChanged )
}

void function InitCustomMatchPanelFooter( var panel )
{
	AddPanelFooterOption( panel, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
	
	AddPanelFooterOption( panel, LEFT, BUTTON_TRIGGER_RIGHT_FULL, true, "#CUSTOM_MATCH_OPEN_CHAT_BUTTON", "", HandleOpenChat, OpenChatDialog_CanClick )
	
	AddPanelFooterOption( panel, LEFT, BUTTON_DPAD_LEFT, true, "#CUSTOM_MATCH_HOLD_LEAVE_TEAM", "#CUSTOM_MATCH_LEAVE_TEAM", JoinUnassigned_OnClick, JoinUnassigned_CanClick )
	AddPanelFooterOption( panel, LEFT, BUTTON_DPAD_RIGHT, true, "#CUSTOM_MATCH_HOLD_JOIN_OBSERVER", "#CUSTOM_MATCH_JOIN_OBSERVER", JoinSpectators_OnClick, JoinSpectators_CanClick )
	AddPanelFooterOption( panel, RIGHT, BUTTON_STICK_LEFT, true, "#DATACENTER_DOWNLOADING", "#DATACENTER_DOWNLOADING", CustomMatchOpenDataCenterDialog, CustomMatchDatacenter_CanClick, CustomMatchUpdateDataCenterFooter )
}

void function HandleOpenChat(var button)
{
#if PC_PROG
	FocusChat_OnActivate( button )
#else
	EnterText_OnActivate( button )
#endif
}

void function UICallback_InputModeChanged( bool controllerModeActive )
{
	if ( IsLobby() && CustomMatch_IsInCustomMatch() )
		InputModeChanged( controllerModeActive )
}

void function InputModeChanged( bool controllerModeActive )
{
	if ( CustomMatch_IsLocalAdmin() && !file.isMatchmaking )
		HudElem_SetRuiArg( file.startButton, "buttonText", controllerModeActive ? "#Y_BUTTON_START_MATCH" : "#START_MATCH" )
	else if ( !CustomMatch_IsLocalAdmin() && !file.isReady )
		HudElem_SetRuiArg( file.startButton, "buttonText", controllerModeActive ? "#Y_BUTTON_READY" : "#READY" )
	else
		HudElem_SetRuiArg( file.startButton, "buttonText", controllerModeActive ? "#B_BUTTON_CANCEL" : "#CANCEL" )
}

void function FocusChat_OnActivate( var button )
{
	Hud_SetFocused( file.chatInputLine )
}

void function EnterText_OnActivate( var button )
{
	if ( !HudChat_HasAnyMessageModeStoppedRecently() && Hud_IsVisible( file.chatTarget ) && file.chatEnabled && !file.setTeamNameIsOpen )
		Hud_StartMessageMode( file.chatTarget )
}

void function CustomMatchLobby_OnShow( var panel )
{
	Hud_Show( Hud_GetChild( panel, "LobbyRosterPanel" ) )
	DataDialog_AddCallback_OnClose( CustomMatchOnDataCenterDialog_Close )
	Hud_SetEnabled( file.startButton, true )
	SetMenuNavigationDisabled( false )


	ShowPanel( Hud_GetChild( file.panel, "PrivateMatchScoreboardPanel" ) )

	RegisterButtonPressedCallback( BUTTON_Y, StartMatch_OnClick )
	RegisterButtonPressedCallback( KEY_TAB, CustomMatchOpenDataCenterDialog )

	SetJoinTeamHelper()
}

void function CustomMatchLobby_OnHide( var panel )
{
	DeregisterButtonPressedCallback( BUTTON_Y, StartMatch_OnClick )
	DeregisterButtonPressedCallback( KEY_TAB, CustomMatchOpenDataCenterDialog )
}

bool function StartMatch_CanClick()
{
	return !IsDialog( GetActiveMenu() )
}

bool function CustomMatch_CanAdminStartMatch()
{
	                              
	           
	                                                                                                        
	                                           
	                           
	bool canStartMatch = CustomMatch_IsLocalAdmin() && !file.hasRemainingPlayers && file.teamIndex != TEAM_UNASSIGNED && !file.hasRemainingAllianceOrTeam && !CustomMatch_MatchInProgress()

	return canStartMatch
}

bool function CustomMatch_CanPlayerSetReady()
{
	return !CustomMatch_IsLocalAdmin() && file.teamIndex != TEAM_UNASSIGNED
}

void function StartMatch_OnClick( var button )
{
	if ( !StartMatch_CanClick() )
		return

	                                                                                   
	if ( CustomMatch_CanAdminStartMatch() )
	{
		CustomMatch_SetMatchmaking( !file.isMatchmaking )
	}
	                                                                   
	else if ( CustomMatch_CanPlayerSetReady() )
	{
		CustomMatch_SetReady( !file.isReady )
	}
}

bool function CanJoinTeam( int index )
{
	return !IsDialog( GetActiveMenu() )                                                                        
}

bool function JoinSpectators_CanClick()
{
	return CanJoinTeam( TEAM_SPECTATOR ) && file.teamIndex != TEAM_SPECTATOR
}

void function JoinSpectators_OnClick( var button )
{
	if ( !JoinSpectators_CanClick() )
		return

	if ( InputIsButtonDown( BUTTON_DPAD_RIGHT ) )
		thread OnHold_internal( BUTTON_DPAD_RIGHT, TEAM_SPECTATOR )
	else
		CustomMatch_SetTeam( TEAM_SPECTATOR, GetPlayerHardware(), GetPlayerUID() )
}

bool function JoinUnassigned_CanClick()
{
	return CanJoinTeam( TEAM_UNASSIGNED ) && file.teamIndex != TEAM_UNASSIGNED
}

void function JoinUnassigned_OnClick( var button )
{
	if ( !JoinUnassigned_CanClick() )
		return

	if ( InputIsButtonDown( BUTTON_DPAD_LEFT ) )
		thread OnHold_internal( BUTTON_DPAD_LEFT, TEAM_UNASSIGNED )
	else
		CustomMatch_SetTeam( TEAM_UNASSIGNED, GetPlayerHardware(), GetPlayerUID() )
}

void function Callback_OnPlayerDataChanged( CustomMatch_LobbyPlayer playerData )
{
	file.teamIndex = playerData.team
	file.isReady = ( playerData.flags & CUSTOM_MATCH_PLAYER_BIT_IS_READY ) != 0

	InputModeChanged( IsControllerModeActive() )
}

const string ON = "1"
void function Callback_OnSelfAssignChanged( string _, string value )
{
	file.selfAssign = ( value == ON ) || CustomMatch_IsLocalAdmin()

	SetJoinTeamHelper()
}

void function CustomMatchLobby_OnSetTeamNameOpenOrClose( bool open )
{
	file.setTeamNameIsOpen = open
	Callback_OnChatPermissionChanged( "", file.chatEnabled ? CUSTOM_MATCH_CHAT_PERMISSION_ALL : CUSTOM_MATCH_CHAT_PERMISSION_ADMIN_ONLY )
}

void function ChatBox_OnClick( var button )
{
	if ( file.chatEnabled )
	{
		Hud_SetFocused( file.chatInputLine )
	}
}

void function Callback_OnChatPermissionChanged( string _, string value )
{
	file.chatEnabled = ( value != CUSTOM_MATCH_CHAT_PERMISSION_ADMIN_ONLY ) || CustomMatch_IsLocalAdmin()
	bool chatEnabled = file.chatEnabled && !file.setTeamNameIsOpen

	Hud_SetEnabled( file.chatTarget, chatEnabled )
	Hud_SetEnabled( file.chatInputLine, chatEnabled )
	Hud_SetVisible( file.chatInputLine, chatEnabled )
	Hud_SetEnabled( Hud_GetChild( file.chatInputLine, "ChatInputPrompt" ), chatEnabled )
	Hud_SetVisible( Hud_GetChild( file.chatInputLine, "ChatInputPrompt" ), chatEnabled )
	Hud_SetEnabled( Hud_GetChild( file.chatInputLine, "ChatInputTextEntry" ), chatEnabled )
	Hud_SetVisible( Hud_GetChild( file.chatInputLine, "ChatInputTextEntry" ), chatEnabled )
}

void function Callback_OnMatchStatusChanged( string _, string value )
{
	file.canAction = ( value == CUSTOM_MATCH_STATUS_PREPARING )
	file.isMatchmaking = ( value == CUSTOM_MATCH_STATUS_MATCHMAKING )
	InputModeChanged( IsControllerModeActive() )
}

void function CustomMatch_SetStartMatchTooltip( CustomMatch_LobbyState data )
{
	if ( !IsConnected() )
		return

	                                                                                
	file.gamemode = GetPlaylistGamemodeByIndex( data.playlist, 0 )

	                                                                              
	if ( CustomMatch_IsLocalAdmin() )
	{
		                                                               
		file.assignedPlayers = []

		bool hasSpecialAccess = CustomMatch_HasSpecialAccess()

		int maxAlliancesOrTeams = GetPlaylistVarInt(  data.playlist, "max_alliances", 0 )
		maxAlliancesOrTeams = maxAlliancesOrTeams > 0 ? maxAlliancesOrTeams : data.maxTeams
		int firstFoundAllianceOrTeam = -1
		file.hasRemainingAllianceOrTeam = hasSpecialAccess ? false : true

		                                                 
		foreach( player in data.players )
		{
			                                                                                          
			if (player.team != TEAM_UNASSIGNED && player.team != TEAM_SPECTATOR)
			{
				                                                            
				file.assignedPlayers.push(player)

				                                                          
				if ( file.hasRemainingAllianceOrTeam )
				{
					int allianceOrSquadIndex = Squads_GetArrayIndexForTeam( player.team ) % maxAlliancesOrTeams
					if ( firstFoundAllianceOrTeam == -1 )
						firstFoundAllianceOrTeam = allianceOrSquadIndex
					else if ( allianceOrSquadIndex != firstFoundAllianceOrTeam )
						file.hasRemainingAllianceOrTeam = false
				}
			}
		}

		                                                                                                 
		file.remainingPlayers = hasSpecialAccess ? (1 - file.assignedPlayers.len()) : GetPlaylistVarInt( data.playlist, "cm_public_min_players", (file.gamemode == SURVIVAL || file.gamemode == GAMEMODE_SHADOW_ROYALE ) ? 30 : data.maxPlayers ) - file.assignedPlayers.len()
		file.hasRemainingPlayers = file.remainingPlayers > 0

		                     
		array<string> tooltipConditions = []

		                                                                             
		if (file.hasRemainingPlayers)
		{
			if (file.remainingPlayers > 1)
			{
				tooltipConditions.push( Localize( "#CUSTOMMATCH_MIN_PLAYERS_PLURAL", file.remainingPlayers ) )
			}
			else if (file.remainingPlayers == 1)
			{
				tooltipConditions.push( Localize( "#CUSTOMMATCH_MIN_PLAYERS_SINGULAR", file.remainingPlayers ) )
			}
		}
		else if ( file.hasRemainingAllianceOrTeam )
		{
			tooltipConditions.push( Localize( "#CUSTOMMATCH_MIN_TEAMS" ) )
		}

		                                                                      
		if (file.teamIndex == TEAM_UNASSIGNED)
		{
			tooltipConditions.push( Localize( "#CUSTOMMATCH_ADMIN_NOT_ASSIGNED" ) )
		}

		                                                     
		if ( file.hasRemainingPlayers || file.teamIndex == TEAM_UNASSIGNED || file.hasRemainingAllianceOrTeam )
		{
			ToolTipData startButtonTooltip

			                               
			string descText = ""
			for (int k = 0; k < tooltipConditions.len(); k++ )
			{
				descText += tooltipConditions[k]
				if (k != tooltipConditions.len() - 1)
				{
					descText += "\n"
				}
			}
			startButtonTooltip.descText = descText
			Hud_SetToolTipData( file.startButton, startButtonTooltip )
		}
		else
		{
			                                                       
			Hud_ClearToolTipData( file.startButton )
		}

		                                                    
		RuiSetBool( Hud_GetRui( file.startButton ), "isLocked", !CustomMatch_CanAdminStartMatch() )
	}
	else
	{
		                                                             
		Hud_ClearToolTipData( file.startButton )
		RuiSetBool( Hud_GetRui( file.startButton ), "isLocked", !CustomMatch_CanPlayerSetReady() )
	}
}

void function CustomMatch_AdminLeftRemoveAllPlayers()
{
	                                
	file.isAutoClosing = true

	                                      
	float startTime = UITime()
	float endTime = UITime() + AUTO_CLOSE_LOBBY_TIMER

	                                                
	while ( UITime() < endTime )
	{
		WaitFrame()

		                                                                  
		if ( !CustomMatch_IsAdminInLobby() )
		{
			                        
			file.autoCloseRemainingTime = int(UITime() - startTime)
			CustomMatchDashboard_UpdateAutoCloseTimer( true, float(AUTO_CLOSE_LOBBY_TIMER - file.autoCloseRemainingTime) )
		}
		else
		{
			                                        
			                                                                           
			break
		}
	}

	OnThreadEnd(
		function() : ( )
		{
			                               
			                                                                         
			                                                                 
			if (file.autoCloseRemainingTime >= AUTO_CLOSE_LOBBY_TIMER)
			{
				                            
				CustomMatch_LeaveLobby()
				CustomMatch_CloseLobbyMenu( "#CUSTOM_MATCH_REMOVED_FROM_MATCH", "#CUSTOM_MATCH_REMOVED_FROM_MATCH_DESC" )
			}
		}
	)
}

bool function CustomMatch_IsAdminInLobby()
{
	foreach ( player in file.lobbyPlayers)
	{
		if (player.isAdmin)
		{
			return true
		}
	}
	return false
}

void function Callback_OnLobbyDataChanged( CustomMatch_LobbyState data )
{
	CustomMatch_SetStartMatchTooltip( data )

	file.lobbyPlayers = data.players

	                                                                                             
	if (!file.isAutoClosing)
	{
		if (!CustomMatch_IsAdminInLobby() && !CustomMatch_MatchInProgress())
		{
			thread CustomMatch_AdminLeftRemoveAllPlayers()
		}
	}
	else
	{
		                                                          
		                                                                  
		if (CustomMatch_IsAdminInLobby())
		{
			file.autoCloseRemainingTime = 0
			file.isAutoClosing = false
			CustomMatchDashboard_UpdateAutoCloseTimer( false, AUTO_CLOSE_LOBBY_TIMER )
		}
	}

	UpdateFooterOptions()
}

const float BUTTON_HOLD_DELAY = 0.3
void function OnHold_internal( int button, int teamIndex )
{
	float endTIme = UITime() + BUTTON_HOLD_DELAY

	while ( InputIsButtonDown( button ) && UITime() < endTIme )
	{
		WaitFrame()
	}

	if ( CanJoinTeam( teamIndex ) && InputIsButtonDown( button ) )
		CustomMatch_SetTeam( teamIndex, GetPlayerHardware(), GetPlayerUID() )
}

bool function ActionsLocked()
{
	return !file.canAction
}

void function CustomMatchOpenDataCenterDialog(var button)
{
	if (CustomMatch_IsLocalAdmin())
	{
		                                
		Hud_Hide( file.panel )
		Hud_Hide(GetPanel("ShareTokenPanel" ) )
		Hud_Hide( Hud_GetChild( GetMenu("CustomMatchLobbyMenu" ), "TabsBackground" ) )

		TabData tabs = GetTabDataForPanel( GetMenu("CustomMatchLobbyMenu" ) )
		Hud_Hide( tabs.tabPanel )

		                                   
		OpenDataCenterDialog( button )
	}
}

void function CustomMatchUpdateDataCenterFooter( InputDef footerData )
{
	string label = "#DATACENTER_DOWNLOADING"
	if ( !IsDatacenterMatchmakingOk() )
	{
		if ( IsSendingDatacenterPings() )
			label = Localize( "#DATACENTER_CALCULATING" )
		else
			label = Localize( label, GetDatacenterDownloadStatusCode() )
	}
	else
	{
		label = Localize( "#CUSTOMMATCH_DATACENTER" )
	}

	var elem = footerData.vguiElem
	Hud_SetText( elem, label )
	Hud_Show( elem )
}

bool function OpenChatDialog_CanClick()
{
	return !IsDialog( GetActiveMenu() ) && !ActionsLocked() && file.chatEnabled && !file.setTeamNameIsOpen
}

bool function CustomMatchDatacenter_CanClick()
{
	return !IsDialog( GetActiveMenu() ) && !ActionsLocked() && CustomMatch_IsLocalAdmin()
}

void function CustomMatchOnDataCenterDialog_Close()
{
	TabData tabs = GetTabDataForPanel( GetMenu("CustomMatchLobbyMenu" ) )
	Hud_Show( tabs.tabPanel )
	Hud_Show( Hud_GetChild( GetMenu("CustomMatchLobbyMenu" ), "TabsBackground" ) )

	if (CustomMatch_IsLocalAdmin())
	{
		Hud_Show(GetPanel("ShareTokenPanel" ))
	}
	Hud_Show( file.panel )
}

                                                                    
             
                                                                    

void function CustomMatchLobby_OnDragPlayer( CustomMatch_LobbyPlayer player )
{
	if ( ActionsLocked() )
		return

	string platformString = PlatformIDToIconString( GetHardwareFromName( player.hardware ) )

	Hud_Show( file.dragIcon )
	HudElem_SetRuiArg( file.dragIcon, "buttonText", player.name )
	HudElem_SetRuiArg( file.dragIcon, "platformString", platformString )
	HudElem_SetRuiArg( file.dragIcon, "isAdmin", player.isAdmin )

	ToolTips_SetMenuTooltipVisible( file.panel, false )
	thread DragPlayer( player )
}

void function DragPlayer( CustomMatch_LobbyPlayer player )
{
	if ( !( InputIsButtonDown( MOUSE_LEFT ) || InputIsButtonDown( BUTTON_A ) ) )
	{
		DropPlayer( player )
		return
	}

	vector screenPos = ConvertCursorToScreenPos()
	UIPos parentPos = REPLACEHud_GetAbsPos( file.panel )
	Hud_SetPos( file.dragIcon,
		screenPos.x - ( Hud_GetWidth( file.dragIcon ) * 0.5 ) - parentPos.x,
		screenPos.y - ( Hud_GetHeight( file.dragIcon ) * 0.5 ) - parentPos.y )

	DragHover()
	WaitFrame()
	DragPlayer( player )
}

void function DragHover()
{
	var dragTarget = GetDragTarget()
	if ( dragTarget != file.dragTarget )
	{
		if( IsValid( file.dragTarget ) )
		{
			HudElem_SetRuiArg( file.dragTarget, "isDragTarget", false )
			var header = ScoreboardMenu_CustomMatch_GetHeaderForButton( file.dragTarget )
			if( header != null )
				HudElem_SetRuiArg( header, "isDragTarget", false )
		}

		                            

		file.dragTarget = dragTarget

		if( IsValid( file.dragTarget ) )
		{
			HudElem_SetRuiArg( file.dragTarget, "isDragTarget", true )

			var header = ScoreboardMenu_CustomMatch_GetHeaderForButton( file.dragTarget )
			if( header != null )
				HudElem_SetRuiArg( header, "isDragTarget", true )
		}
	}
}

void function DragStop()
{
	Hud_Hide( file.dragIcon )
	ToolTips_SetMenuTooltipVisible( file.panel, true )

	if( file.dragTarget != null )
	{
		HudElem_SetRuiArg( file.dragTarget, "isDragTarget", false )
		var header = ScoreboardMenu_CustomMatch_GetHeaderForButton( file.dragTarget )
		if( header != null )
			HudElem_SetRuiArg( header, "isDragTarget", false )
	}
}

void function DropPlayer( CustomMatch_LobbyPlayer player )
{
	var dropTarget = GetDropTarget()
	if ( dropTarget )
	{
		int teamIndex = ScoreboardMenu_CustomMatch_GetButtonTeamID( dropTarget )
		if( teamIndex < 0 )
			teamIndex = Hud_GetScriptID( dropTarget ).tointeger()

		int correctedTeamIndex = CustomMatchTeamRoster_GetCorrectedTeamId( teamIndex )
		if ( player.team != correctedTeamIndex )
			CustomMatch_SetTeam( correctedTeamIndex, player.hardware, player.uid )
	}
	DragStop()
}

var function GetDragTarget()
{
	var element = GetMouseFocus()
	while ( element && element != file.panel )
	{
		                                                                                    
		string name = Hud_GetHudName( element )
		name = name.slice( 0, name.len() - 2 )

		switch ( name )
		{
			case "Team":
				return Hud_GetChild( element, "TeamHeader" )
			case "LobbyRoster":
				return Hud_GetChild( Hud_GetParent( element ), format( "LobbyRosterButton%02u", Hud_GetScriptID( element ).tointeger() ))
			case "LobbyRosterButton":
			case "TeamPlayer":
				return element
			default:
				break
		}

		element = Hud_GetParent( element )
	}
	return null
}

var function GetDropTarget()
{
	var element = GetMouseFocus()
	while ( element && element != file.panel )
	{
		                                                                                    
		string name = Hud_GetHudName( element )
		name = name.slice( 0, name.len() - 2 )

		switch ( name )
		{
			case "Team":
			case "LobbyRoster":
			case "LobbyRosterButton":
			case "TeamPlayer":
			case "TinyHeader":
				return element
			default:
				break
		}

		element = Hud_GetParent( element )
	}
	return null
}

void function SetJoinTeamHelper()
{
	if( file.selfAssign )
		Hud_SetText( Hud_GetChild( file.panel, "JoinTeamHelper" ), Localize( "#TOURNAMENT_HINT_HOW_TO_JOIN" ) )
	else
		Hud_SetText( Hud_GetChild( file.panel, "JoinTeamHelper" ), "" )
}