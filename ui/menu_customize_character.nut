global function InitCustomizeCharacterMenu
global function CustomizeCharacterMenu_NextButton_OnActivate
global function CustomizeCharacterMenu_PrevButton_OnActivate

global function CustomizeCharacterMenu_SetCharacter

struct
{
	var menu

	var prevButton
	var nextButton

	bool tabsInitialized = false

	ItemFlavor ornull characterOrNull = null
} file

const bool NEXT = true
const bool PREV = false

void function InitCustomizeCharacterMenu( var newMenuArg )                                               
{
	var menu = GetMenu( "CustomizeCharacterMenu" )
	file.menu = menu

	SetTabRightSound( menu, "UI_Menu_LegendTab_Select" )
	SetTabLeftSound( menu, "UI_Menu_LegendTab_Select" )

	file.prevButton = Hud_GetChild( menu, "PrevButton" )
	HudElem_SetRuiArg( file.prevButton, "flipHorizontal", true )
	Hud_AddEventHandler( file.prevButton, UIE_CLICK, CustomizeCharacterMenu_PrevButton_OnActivate )

	file.nextButton = Hud_GetChild( menu, "NextButton" )
	Hud_AddEventHandler( file.nextButton, UIE_CLICK, CustomizeCharacterMenu_NextButton_OnActivate )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, CustomizeCharacterMenu_OnOpen )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, CustomizeCharacterMenu_OnClose )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, CustomizeCharacterMenu_OnNavigateBack )
}


void function CustomizeCharacterMenu_SetCharacter( ItemFlavor character )
{
	file.characterOrNull = character
}


void function CustomizeCharacterMenu_OnOpen()
{
	SetCurrentHubForPIN( "menu_CustomizeCharacterMenu" )                                                

	if ( !file.tabsInitialized )
	{
		{
			var panel = Hud_GetChild( file.menu, "CharacterSkinsPanel" )
			TabDef tab = AddTab( file.menu, panel, GetPanelTabTitle( panel ) )
			tab.isBannerLogoSmall = true
			SetTabBaseWidth( tab, 160 )
		}
		{
			var panel = Hud_GetChild( file.menu, "CharacterCardsPanelV2" )
			TabDef tab = AddTab( file.menu, panel, GetPanelTabTitle( panel ) )
			tab.isBannerLogoSmall = true
			SetTabBaseWidth( tab, 210 )
		}
		{
			var panel = Hud_GetChild( file.menu, "CharacterEmotesPanel" )
			TabDef tab = AddTab( file.menu, panel, GetPanelTabTitle( panel ) )
			tab.isBannerLogoSmall = true
			SetTabBaseWidth( tab, 220 )
		}
		{
			var panel = Hud_GetChild( file.menu, "CharacterExecutionsPanel" )
			TabDef tab = AddTab( file.menu, panel, GetPanelTabTitle( panel ) )
			tab.isBannerLogoSmall = true
			SetTabBaseWidth( tab, 200 )
		}
		file.tabsInitialized = true
	}

	Assert( file.characterOrNull != null, "CustomizeCharacterMenu_SetCharacter must be called before advancing to " + Hud_GetHudName( file.menu ) )
	ItemFlavor character = expect ItemFlavor( file.characterOrNull )

	SetTopLevelCustomizeContext( character )

	if ( GetLastMenuNavDirection() == MENU_NAV_FORWARD )
	{
		TabData tabData = GetTabDataForPanel( file.menu )
		tabData.centerTabs = true
		tabData.bannerTitle = Localize( ItemFlavor_GetLongName( character ) ).toupper()
		tabData.bannerLogoImage = ItemFlavor_GetIcon( character )
		tabData.bannerLogoScale = 0.7
		SetTabBackground( tabData, Hud_GetChild( file.menu, "TabsBackground" ), eTabBackground.CAPSTONE )

		SetTabDefsToSeasonal(tabData)
		ActivateTab( tabData, 0 )
	}

	RegisterNewnessCallbacks( character )
	EmotesPanel_CreateTabs()
	CharacterCardsPanel_CreateTabs()
}


void function CustomizeCharacterMenu_OnClose()
{
	ItemFlavor character = expect ItemFlavor( file.characterOrNull )
	DeregisterNewnessCallbacks( character )

	EmotesPanel_DestroyTabs()
	CharacterCardsPanel_DestroyTabs()

	file.characterOrNull = null
	SetTopLevelCustomizeContext( null )

	RunMenuClientFunction( "ClearAllCharacterPreview" )
}


void function RegisterNewnessCallbacks( ItemFlavor character )
{
	Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterSkinsTab[character], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "CharacterSkinsPanel" ) )
	Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterCardTab[character], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "CharacterCardsPanelV2" ) )
	Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterQuipsTab[character], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "CharacterEmotesPanel" ) )
	Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterFinishersTab[character], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "CharacterExecutionsPanel" ) )
}


void function DeregisterNewnessCallbacks( ItemFlavor character )
{
	Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterSkinsTab[character], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "CharacterSkinsPanel" ) )
	Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterCardTab[character], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "CharacterCardsPanelV2" ) )
	Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterQuipsTab[character], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "CharacterEmotesPanel" ) )
	Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterFinishersTab[character], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "CharacterExecutionsPanel" ) )
}


void function CustomizeCharacterMenu_OnNavigateBack()
{
	Assert( GetActiveMenu() == file.menu )

	CloseActiveMenu()
}


void function CustomizeCharacterMenu_PrevButton_OnActivate( var button )
{
	SwitchCharacters( PREV )
}


void function CustomizeCharacterMenu_NextButton_OnActivate( var button )
{
	SwitchCharacters( NEXT )
}


void function SwitchCharacters( bool direction )
{
	Assert( direction == NEXT || direction == PREV )
	Assert( file.characterOrNull != null )
	ItemFlavor currentCharacter = expect ItemFlavor(file.characterOrNull)
	DeregisterNewnessCallbacks( currentCharacter )

	array<ItemFlavor> allCharacters = GetAllCharacters()
	int index = allCharacters.find( currentCharacter )
	ItemFlavor nextCharacter

	if ( direction == NEXT )
	{
		if ( index + 1 < allCharacters.len() )
			nextCharacter = allCharacters[index + 1]
		else
			nextCharacter = allCharacters[0]
	}
	else
	{
		if ( index - 1 >= 0 )
			nextCharacter = allCharacters[index - 1]
		else
			nextCharacter = allCharacters[allCharacters.len() - 1]
	}

	RegisterNewnessCallbacks( nextCharacter )
	file.characterOrNull = nextCharacter
	SetTopLevelCustomizeContext( nextCharacter )
	TabData tabData = GetTabDataForPanel( file.menu )
	tabData.bannerTitle = Localize( ItemFlavor_GetLongName( nextCharacter ) ).toupper()
}


