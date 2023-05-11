global function InitCustomMatchDashboardMenu
global function CustomMatch_CloseLobbyMenu
global function CustomMatch_MatchInProgress
global function CustomMatchDashboard_UpdateAutoCloseTimer

struct
{
	var menu
	var matchCountdown
	var autoCloseLobbyLabel
	var autoCloseLobbyTimer

	TabDef& adminSettings
	TabDef& matchSummary
	bool matchInProgress = false
} file

enum eDashboardTab
{
	MATCH_LOBBY,
	MATCH_SUMMARY,

	__count
}

void function InitCustomMatchDashboardMenu( var menu )
{
	file.menu = menu
	file.matchCountdown = Hud_GetChild( menu, "MatchCountdown" )
	file.autoCloseLobbyLabel = Hud_GetChild( menu, "AutoCloseLobbyLabel" )
	file.autoCloseLobbyTimer = Hud_GetChild( menu, "AutoCloseLobbyTimer" )

	SetTabNavigationEnabled( file.menu, true )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, CustomMatchDashboard_OnOpen )
	AddMenuEventHandler( menu, eUIEvent.MENU_SHOW, CustomMatchDashboard_OnShow )
	AddMenuEventHandler( menu, eUIEvent.MENU_HIDE, CustomMatchDashboard_OnHide )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, CustomMatchDashboard_OnNavigateBack )

	AddCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_PLAYLIST, Callback_OnLobbyPlaylistChanged )
	AddCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_MATCH_STATUS, Callback_OnMatchStatusChanged )
	AddCallback_OnCustomMatchLobbyDataChanged( Callback_OnLobbyDataChanged )
	AddCallback_OnCustomMatchPlayerDataChanged( Callback_OnPlayerDataChanged )

	{
		TabDef tabDef = AddTab( file.menu, Hud_GetChild( file.menu, "LobbyPanel" ), "#MATCH_LOBBY" )
		tabDef.isBannerLogoSmall = true
	}	                            

	{
		TabDef tabDef = AddTab( file.menu, Hud_GetChild( file.menu, "SummaryPanel" ), "#MATCH_SUMMARY" )
		SetTabBaseWidth( tabDef, 320 )
		tabDef.isBannerLogoSmall = true
		tabDef.enabled = false
		tabDef.visible = false

		file.matchSummary = tabDef
	}	                              

	{
		TabDef tabDef = AddTab( file.menu, Hud_GetChild( file.menu, "SettingsPanel" ), "#SETTINGS" )
		SetTabBaseWidth( tabDef, 210 )
		tabDef.enabled = false
		tabDef.visible = false

		file.adminSettings = tabDef
	}

	TabData tabData = GetTabDataForPanel( file.menu )
	tabData.centerTabs = true
	tabData.useGRXData = false
	tabData.bannerLogoScale = 0.1
	tabData.initialFirstTabButtonXPos = 50
	SetTabBackground( tabData, Hud_GetChild( file.menu, "TabsBackground" ), eTabBackground.CAPSTONE )
	SetTabDefsToSeasonal(tabData)
}

void function CustomMatch_CloseLobbyMenu( string leaveHeader = "", string leaveDesc = "" )
{
	if ( MenuStack_Contains( GetMenu( "CustomMatchLobbyMenu" ) ) )
	{
		CloseAllMenus()
		AdvanceMenu( GetMenu( "LobbyMenu" ) )

		if ( leaveHeader != "" )
		{
			ConfirmDialogData data
			data.headerText = leaveHeader
			data.messageText = leaveDesc
			OpenOKDialogFromData( data )
		}
	}
}

void function CustomMatchDashboard_OnOpen()
{
	CustomMatch_RefreshPlaylists()
	                                                    
	if ( CustomMatch_HasSetting( CUSTOM_MATCH_SETTING_MATCH_STATUS ) )
		Callback_OnMatchStatusChanged( CUSTOM_MATCH_SETTING_MATCH_STATUS, CustomMatch_GetSetting( CUSTOM_MATCH_SETTING_MATCH_STATUS ) )

}

void function CustomMatchDashboard_OnShow()
{
	UI_SetPresentationType( ePresentationType.WEAPON_CATEGORY )

	TabData tabData = GetTabDataForPanel( file.menu )
	SetTabDefVisible(file.adminSettings, CustomMatch_IsLocalAdmin())
	SetTabDefEnabled(file.adminSettings, CustomMatch_IsLocalAdmin())

	SetTabDefEnabled(file.matchSummary, false )
	SetTabDefVisible(file.matchSummary, false )

	ActivateTab( tabData, 0 )
}

void function CustomMatchDashboard_OnHide()
{

}

void function CustomMatchDashboard_OnNavigateBack()
{
	bool isMatchmaking = ( CustomMatch_GetSetting( CUSTOM_MATCH_SETTING_MATCH_STATUS ) == CUSTOM_MATCH_STATUS_MATCHMAKING )
	bool isReady = ( CustomMatch_GetLocalPlayerData().flags & CUSTOM_MATCH_PLAYER_BIT_IS_READY ) != 0
	TabData tabData = GetTabDataForPanel( file.menu )

	if ( tabData.activeTabIdx != eDashboardTab.MATCH_LOBBY )
		ActivateTab( tabData, eDashboardTab.MATCH_LOBBY )
	else if ( CustomMatch_IsLocalAdmin() && isMatchmaking )
		CustomMatch_SetMatchmaking( false )
	else if ( isReady )
		CustomMatch_SetReady( false )
	else
		AdvanceMenu( GetMenu( "SystemMenu" ) )
}

void function Callback_OnLobbyPlaylistChanged( string _, string value )
{
	CustomMatchPlaylist playlist = expect CustomMatchPlaylist( CustomMatch_GetPlaylist( value ) )
	CustomMatchMap map = expect CustomMatchMap( CustomMatch_GetMap( playlist.mapIndex ) )
	CustomMatchCategory category = expect CustomMatchCategory( CustomMatch_GetCategory( playlist.categoryIndex ) )

	     
	TabData tabData = GetTabDataForPanel( file.menu )
	tabData.bannerTitle = map.displayName.toupper()
	tabData.bannerHeader =category.displayName
	tabData.bannerLogoImage = category.displayLogo


	HudElem_SetRuiArg( file.matchCountdown, "map", map.displayName )
	HudElem_SetRuiArg( file.matchCountdown, "gamemode", category.displayName )
	HudElem_SetRuiArg( file.matchCountdown, "logo", category.displayLogo )
	                                

	UpdateMenuTabs()
}

void function Callback_OnMatchStatusChanged( string _, string value )
{
	switch ( value )
	{
		case CUSTOM_MATCH_STATUS_PREPARING:
			                                            
			Hud_SetVisible( file.matchCountdown, false )
			ToggleVisibilityShareToken( true )
			file.matchInProgress = false
			break
		case CUSTOM_MATCH_STATUS_MATCHMAKING:
			                                             
			Hud_SetVisible( file.matchCountdown, true )
			ToggleVisibilityShareToken( false )

			float startDelay = GetConVarFloat( "customMatch_startMatchmakingDelay" )
			HudElem_SetRuiArg( file.matchCountdown, "startTime", ClientTime() + startDelay, eRuiArgType.GAMETIME )
			HudElem_SetRuiArg( file.matchCountdown, "inProgress", false )
			file.matchInProgress = false
			break
		default:
			                                             
			Hud_SetVisible( file.matchCountdown, true )
			ToggleVisibilityShareToken( false )

			if ( IsFullyConnected() )
				HudElem_SetRuiArg( file.matchCountdown, "inProgress", !AreWeMatchmaking() )
				file.matchInProgress = true
			break
	}

}

void function CustomMatchDashboard_UpdateAutoCloseTimer( bool showTimer, float currentTime )
{
	                                                                     
	Hud_SetVisible( file.matchCountdown, false )
	ToggleVisibilityShareToken( !showTimer )

	                  
	Hud_SetVisible( file.autoCloseLobbyLabel, showTimer )
	Hud_SetVisible( file.autoCloseLobbyTimer, showTimer )

	               
	Hud_SetText( file.autoCloseLobbyTimer, Localize( FormatNumber( "1", currentTime ) ).toupper() )
}

void function Callback_OnPlayerDataChanged( CustomMatch_LobbyPlayer player )
{
	SetTabDefVisible(file.adminSettings, player.isAdmin)
	SetTabDefEnabled(file.adminSettings, player.isAdmin)
	UpdateMenuTabs()
	SetCustomMatchShareToken(player.isAdmin)
}

void function Callback_OnLobbyDataChanged( CustomMatch_LobbyState data )
{
	SetTabDefEnabled(file.matchSummary, data.matches.len() > 0 )
	SetTabDefVisible(file.matchSummary, data.matches.len() > 0 )
}

bool function CustomMatch_MatchInProgress()
{
	return file.matchInProgress
}

