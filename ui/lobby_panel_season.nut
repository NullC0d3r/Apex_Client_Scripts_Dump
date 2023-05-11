global function InitSeasonPanel
global function JumpToSeasonTab
global function IsSeaonPanelCurrentlyTopLevel

global function OnGRXSeasonUpdate

global function SeasonPanel_GetLastMenuNavDirectionTopLevel

struct
{
	var panel

	bool callbacksAdded = false

	bool wasCollectionEventActive = false
	bool wasThemedShopEventActive = false
	bool wasWhatsNewEventActive = false

	bool isFirstSessionOpen = true

	bool lastMenuNavDirectionTopLevel = MENU_NAV_FORWARD
	bool isOpened = false
} file


void function InitSeasonPanel( var panel )
{
	file.panel = panel
	SetPanelTabTitle( panel, "#SEASON_HUB" )
	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, SeasonPanel_OnShow )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, SeasonPanel_OnHide )
}

bool function IsSeaonPanelCurrentlyTopLevel()
{
	return GetActiveMenu() == GetMenu( "LobbyMenu" ) && IsPanelActive( file.panel )
}

void function SeasonPanel_OnShow( var panel )
{
	file.isOpened = true

	SetCurrentHubForPIN( Hud_GetHudName( panel ) )
	TabData tabData = GetTabDataForPanel( panel )

	UI_SetPresentationType( ePresentationType.WEAPON_CATEGORY )

	if ( !file.callbacksAdded )
	{
		AddCallbackAndCallNow_OnGRXInventoryStateChanged( OnGRXSeasonUpdate )
		AddCallbackAndCallNow_OnGRXOffersRefreshed( OnGRXSeasonUpdate )
		file.callbacksAdded = true
	}

	entity player = GetLocalClientPlayer()

	if ( !IsValid( player ) )
		return

	ItemFlavor currentSeason = GetLatestSeason( GetUnixTimestamp() )
	string seasonString = ItemFlavor_GetCalEventRef( currentSeason )
	bool isNewSeason = player.GetPersistentVar( "lastHubResetSeason" ) != seasonString
	if ( isNewSeason )
	{
		AdvanceMenu( GetMenu("BattlePassAboutPage1") )
		Remote_ServerCallFunction( "ClientCallback_SetSeasonalHubButtonClickedSeason" )
	}

	if ( GetLastMenuNavDirection() == MENU_NAV_FORWARD )
		thread AnimateInSmallTabBar( tabData )
}


void function SeasonPanel_OnHide( var panel )
{
	TabData tabData = GetTabDataForPanel( panel )
	DeactivateTab( tabData )
	file.isOpened = false

	if ( file.callbacksAdded )
	{
		RemoveCallback_OnGRXInventoryStateChanged( OnGRXSeasonUpdate )
		RemoveCallback_OnGRXOffersRefreshed( OnGRXSeasonUpdate )
		file.callbacksAdded = false
	}
}


array<var> function GetAllMenuPanelsSorted( var menu )
{
	array<var> allPanels = GetAllMenuPanels( menu )
	foreach ( panel in allPanels )
		printt( Hud_GetHudName( panel ) )
	allPanels.sort( SortMenuPanelsByPlaylist )

	return allPanels
}


int function SortMenuPanelsByPlaylist( var a, var b )
{
	                                                                                                                                                       
	string playlistVal = GetCurrentPlaylistVarString( "season_panel_order", "CollectionEventPanel|ThemedShopPanel|PassPanel|QuestPanel|ChallengesPanel" )
	if ( playlistVal == "" )
		return 0

	array<string> tokens = split( playlistVal, "|" )
	if ( tokens.find( Hud_GetHudName( a ) ) > tokens.find( Hud_GetHudName( b ) ) )
		return 1
	else if ( tokens.find( Hud_GetHudName( b ) ) > tokens.find( Hud_GetHudName( a ) ) )
		return -1

	return 0
}


void function OnGRXSeasonUpdate()
{
	TabData tabData = GetTabDataForPanel( file.panel )

	if ( !GRX_IsInventoryReady() || !GRX_AreOffersReady() )
	{
		DeactivateTab( tabData )
		SetTabNavigationEnabled( file.panel, false )

		foreach ( tabDef in GetPanelTabs( file.panel ) )
		{
			SetTabDefEnabled( tabDef, false )
		}
	}
	else
	{
		ItemFlavor ornull activeCollectionEvent = GetActiveCollectionEvent( GetUnixTimestamp() )
		bool haveActiveCollectionEvent          = ( activeCollectionEvent != null )
		ItemFlavor ornull activeThemedShopEvent = GetActiveThemedShopEvent( GetUnixTimestamp() )
		bool hasThemedShopCalevent              = ( activeThemedShopEvent != null )

		bool haveActiveWhatsNewEvent			= false
		bool haveActiveThemedShopEvent			= false
		if ( hasThemedShopCalevent )
		{
			haveActiveWhatsNewEvent = ThemedShopEvent_HasWhatsNew( expect ItemFlavor( activeThemedShopEvent ) )
			haveActiveThemedShopEvent = ThemedShopEvent_HasThemedShopTab( expect ItemFlavor( activeThemedShopEvent ) )
		}

		if ( haveActiveCollectionEvent != file.wasCollectionEventActive || haveActiveThemedShopEvent != file.wasThemedShopEventActive || haveActiveWhatsNewEvent != file.wasWhatsNewEventActive || GetMenuNumTabs( file.panel ) == 0 )
		{
			ClearTabs( file.panel )
			array<var> nestedPanels = GetAllMenuPanelsSorted( file.panel )
			foreach ( nestedPanel in nestedPanels )
			{
				if ( Hud_GetHudName( nestedPanel ) == "CollectionEventPanel" && !haveActiveCollectionEvent )
					continue

				if ( Hud_GetHudName( nestedPanel ) == "ThemedShopPanel" && !haveActiveThemedShopEvent )
					continue

				if ( Hud_GetHudName( nestedPanel ) == "WhatsNewPanel" && !haveActiveWhatsNewEvent )
					continue

				switch ( Hud_GetHudName( nestedPanel ) )
				{
					case "ThemedShopPanel":
					case "CollectionEventPanel":
						                                       
						                                    
						break
				}

				AddTab( file.panel, nestedPanel, GetPanelTabTitle( nestedPanel ) )
			}

			file.wasCollectionEventActive = haveActiveCollectionEvent
			file.wasThemedShopEventActive = haveActiveThemedShopEvent
			file.wasWhatsNewEventActive = haveActiveWhatsNewEvent
		}
		SetTabNavigationEnabled( file.panel, true )
		ItemFlavor season = GetLatestSeason( GetUnixTimestamp() )

		int numTabs = tabData.tabDefs.len()
		tabData.centerTabs = true
		SetTabDefsToSeasonal(tabData)
		SetTabBackground( tabData, Hud_GetChild( file.panel, "TabsBackground" ), eTabBackground.STANDARD )

		                                                                                            
		foreach ( TabDef tabDef in GetPanelTabs( file.panel ) )
		{
			bool showTab   = true
			bool enableTab = true

			tabDef.title = GetPanelTabTitle( tabDef.panel )

			if ( Hud_GetHudName( tabDef.panel ) == "CollectionEventPanel" )
			{
				showTab = haveActiveCollectionEvent
				enableTab = true
				if ( haveActiveCollectionEvent )
				{
					expect ItemFlavor(activeCollectionEvent)

					tabDef.title = "#MENU_STORE_PANEL_COLLECTION"                                                           

					                               
					                                                                                         
					                                                                                           
					                                                                                           
					                                                                                             
				}
			}
			else if ( Hud_GetHudName( tabDef.panel ) == "ThemedShopPanel" )
			{
				showTab = haveActiveThemedShopEvent
				if ( haveActiveThemedShopEvent )
				{
					                                          

					tabDef.title = "#EVENT_EXCLUSIVE_OFFERS"                                                       

					                               
					                                                                 
					                                                                   
					                                                                   
					                                                                     
					                                                                                         
					                                                                                         
					                                                                                       
					                                                                                         
					                                                                                         
					                                                                                             
				}
			}

			SetTabDefVisible( tabDef, showTab )
			SetTabDefEnabled( tabDef, enableTab )
		}

		int activeIndex = tabData.activeTabIdx

		file.lastMenuNavDirectionTopLevel = GetLastMenuNavDirection()

		if ( GetCurrentPlaylistVarBool( "season_panel_reverse_nav", true ) || (file.isFirstSessionOpen && GetCurrentPlaylistVarBool( "season_panel_first_open_behavior", true )) )
		{
			if ( GetLastMenuNavDirection() == MENU_NAV_FORWARD )
				activeIndex = 0

			while( (!IsTabIndexEnabled( tabData, activeIndex ) || !IsTabIndexVisible( tabData, activeIndex ) || activeIndex == INVALID_TAB_INDEX) && activeIndex > numTabs )
				activeIndex++
		}
		else
		{
			if ( GetLastMenuNavDirection() == MENU_NAV_FORWARD )
				activeIndex = numTabs - 1

			while( (!IsTabIndexEnabled( tabData, activeIndex ) || !IsTabIndexVisible( tabData, activeIndex ) || activeIndex == INVALID_TAB_INDEX) && activeIndex < numTabs )
				activeIndex--
		}
		file.isFirstSessionOpen = false

		bool wasPanelActive = IsTabActive( tabData )
		if ( !wasPanelActive && file.isOpened  )
			ActivateTab( tabData, activeIndex )
	}
}


bool function SeasonPanel_GetLastMenuNavDirectionTopLevel()
{
	return file.lastMenuNavDirectionTopLevel
}

void function JumpToSeasonTab( string activateSubPanel = "" )
{
	while ( GetActiveMenu() != GetMenu( "LobbyMenu" ) )
		CloseActiveMenu()

	TabData lobbyTabData = GetTabDataForPanel( GetMenu( "LobbyMenu" ) )
	ActivateTab( lobbyTabData, Tab_GetTabIndexByBodyName( lobbyTabData, "SeasonPanel" ) )

	if ( activateSubPanel == "" )
		return

	TabData tabData = GetTabDataForPanel( file.panel )
	int tabIndex = Tab_GetTabIndexByBodyName( tabData, activateSubPanel )
	if ( tabIndex == -1 )
	{
		Warning( "JumpToSeasonTab() is ignoring unknown subpanel \"" + activateSubPanel + "\"" )
		return
	}

	ActivateTab( tabData, tabIndex )
}
