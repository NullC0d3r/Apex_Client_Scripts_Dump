global function InitCharacterCardsPanel
global function SetCardPropertyIndex
global function GetCardPropertyIndex

global function CharacterCardsPanel_CreateTabs
global function CharacterCardsPanel_DestroyTabs

struct
{
	var panel
	var headerRui
	var combinedCardRui

	int               propertyIndex = 0

	ItemFlavor ornull lastNewnessCharacter
} file

void function InitCharacterCardsPanel( var panel )
{
	file.panel = panel
	file.headerRui = Hud_GetRui( Hud_GetChild( panel, "Header" ) )

	SetPanelTabTitle( panel, "#BANNER" )
	RuiSetString( file.headerRui, "title", "" )
	RuiSetString( file.headerRui, "collected", "" )
	file.combinedCardRui = Hud_GetChild( panel, "CombinedCard" )

	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, CharacterCardsPanel_OnShow )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, CharacterCardsPanel_OnHide )

	AddCallback_OnTopLevelCustomizeContextChanged( panel, CharacterCardsPanel_OnCustomizeContextChanged )
}

void function CharacterCardsPanel_OnShow( var panel )
{
	UI_SetPresentationType( ePresentationType.CHARACTER_CARD )
	CharacterCardsPanel_Update()

	TabData tabData = GetTabDataForPanel( file.panel )

	if ( GetLastMenuNavDirection() == MENU_NAV_FORWARD )
	{
		ActivateTab( tabData, 0 )
		thread AnimateInSmallTabBar( tabData )
	}
}


void function CharacterCardsPanel_OnCustomizeContextChanged( var panel )
{
	if ( !IsPanelActive( file.panel ) )
		return

	CharacterCardsPanel_Update()
}


void function CharacterCardsPanel_Update()
{
	SetupMenuGladCard( file.combinedCardRui, "card", true )
	SendMenuGladCardPreviewCommand( eGladCardPreviewCommandType.CHARACTER, 0, GetTopLevelCustomizeContext() )

	UpdateNewnessCallbacks()
}


void function CharacterCardsPanel_OnHide( var panel )
{
	ClearNewnessCallbacks()
	TabData tabData = GetTabDataForPanel( panel )
	HideVisibleTabBodies( tabData )

	SetupMenuGladCard( null, "", true )
}

void function CharacterCardsPanel_CreateTabs()
{
	{
		var panel = Hud_GetChild( file.panel, "CardFramesPanel" )
		TabDef tabdef = AddTab( file.panel, panel, GetPanelTabTitle( panel ) )
		SetTabBaseWidth( tabdef, 140 )
	}
	{
		var panel = Hud_GetChild( file.panel, "CardPosesPanel" )
		TabDef tabdef = AddTab( file.panel, panel, GetPanelTabTitle( panel ) )
		SetTabBaseWidth( tabdef, 130 )
	}
	{
		var panel = Hud_GetChild( file.panel, "CardBadgesPanel" )
		TabDef tabdef = AddTab( file.panel, panel, GetPanelTabTitle( panel ) )
		SetTabBaseWidth( tabdef, 150 )
	}
	{
		var panel = Hud_GetChild( file.panel, "CardTrackersPanel" )
		TabDef tabdef = AddTab( file.panel, panel, GetPanelTabTitle( panel ) )
		SetTabBaseWidth( tabdef, 180 )
	}
	{
		var panel = Hud_GetChild( file.panel, "IntroQuipsPanel" )
		TabDef tabdef = AddTab( file.panel, panel, GetPanelTabTitle( panel ) )
		SetTabBaseWidth( tabdef, 170 )
	}
	{
		var panel = Hud_GetChild( file.panel, "KillQuipsPanel" )
		TabDef tabdef = AddTab( file.panel, panel, GetPanelTabTitle( panel ) )
		SetTabBaseWidth( tabdef, 170 )
	}

	TabData tabData = GetTabDataForPanel( file.panel )
	tabData.centerTabs = true
	SetTabDefsToSeasonal(tabData)

	SetTabBackground( tabData, Hud_GetChild( file.panel, "TabsBackground" ), eTabBackground.STANDARD )
}

void function CharacterCardsPanel_DestroyTabs()
{
	ClearTabs( file.panel )
}

void function SetCardPropertyIndex( int propertyIndex )
{
	file.propertyIndex = propertyIndex
}


int function GetCardPropertyIndex()
{
	return file.propertyIndex
}


void function UpdateNewnessCallbacks()
{
	if ( !IsTopLevelCustomizeContextValid() )
		return

	ClearNewnessCallbacks()

	ItemFlavor character = GetTopLevelCustomizeContext()
	Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.GCardFramesSectionButton[character], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "CardFramesPanel" ) )
	Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.GCardStancesSectionButton[character], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "CardPosesPanel" ) )
	Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.GCardBadgesSectionButton[character], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "CardBadgesPanel" ) )
	Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.GCardTrackersSectionButton[character], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "CardTrackersPanel" )  )
	Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterIntroQuipSectionButton[character], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "IntroQuipsPanel" )  )
	Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterKillQuipSectionButton[character], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "KillQuipsPanel" )  )
	file.lastNewnessCharacter = character
}


void function ClearNewnessCallbacks()
{
	if ( file.lastNewnessCharacter == null )
		return

	Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.GCardFramesSectionButton[expect ItemFlavor( file.lastNewnessCharacter )], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "CardFramesPanel" ) )
	Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.GCardStancesSectionButton[expect ItemFlavor( file.lastNewnessCharacter )], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "CardPosesPanel" )  )
	Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.GCardBadgesSectionButton[expect ItemFlavor( file.lastNewnessCharacter )], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "CardBadgesPanel" ) )
	Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.GCardTrackersSectionButton[expect ItemFlavor( file.lastNewnessCharacter )], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "CardTrackersPanel" ) )
	Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterIntroQuipSectionButton[expect ItemFlavor( file.lastNewnessCharacter )], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "IntroQuipsPanel" ) )
	Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterKillQuipSectionButton[expect ItemFlavor( file.lastNewnessCharacter )], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "KillQuipsPanel" )  )
	file.lastNewnessCharacter = null
}
