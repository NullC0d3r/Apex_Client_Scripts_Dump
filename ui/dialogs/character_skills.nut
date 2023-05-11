global function InitCharacterSkillsDialog
global function OpenCharacterSkillsDialog
global function ClientToUI_OpenCharacterSkillsDialog

struct
{
	var         menu
	ItemFlavor& character
} file

void function InitCharacterSkillsDialog( var newMenuArg )
                                              
{
	var menu = GetMenu( "CharacterSkillsDialog" )
	file.menu = menu

	SetDialog( menu, true )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, CharacterSkillsDialog_OnOpen )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, CharacterSkillsDialog_OnClose )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, CharacterSkillsDialog_OnNavigateBack )

	{
		TabDef tabDef = AddTab( menu, Hud_GetChild( menu, "CharacterAbilitiesPanel" ), "#ABILITIES" )
		SetTabBaseWidth( tabDef,  220 )
	}
	{
		TabDef tabDef = AddTab( menu, Hud_GetChild( menu, "CharacterRolesPanel" ), "#ALL_CLASSES" )
		SetTabBaseWidth( tabDef,  260 )
	}

	TabData tabData = GetTabDataForPanel( file.menu )

	tabData.centerTabs = true
	SetTabDefsToSeasonal(tabData)
	SetTabBackground( tabData, Hud_GetChild( file.menu, "TabsBackground" ), eTabBackground.STANDARD )

	HudElem_SetChildRuiArg( menu, "BG", "basicImage", $"rui/menu/character_skills/background", eRuiArgType.IMAGE )

}

void function OpenCharacterSkillsDialog( ItemFlavor character )
{
	file.character = character
	AdvanceMenu( file.menu )
}

void function ClientToUI_OpenCharacterSkillsDialog( int characterGUID )
{
	if ( !IsValidItemFlavorGUID( characterGUID ) )
		return
	GetItemFlavorByGUID( characterGUID )
	ItemFlavor character = GetItemFlavorByGUID( characterGUID )

	file.character = character

	AdvanceMenu( file.menu )
}

void function CharacterSkillsDialog_OnOpen()
{
	SetCharacterSkillsPanelLegend( file.character )
	TabData tabData = GetTabDataForPanel( file.menu )

	if ( GetLastMenuNavDirection() == MENU_NAV_FORWARD )
	{
		ActivateTab( tabData, 0 )
	}

	Lobby_AdjustScreenFrameToMaxSize( Hud_GetChild( file.menu, "BG" ), false )
}


void function CharacterSkillsDialog_OnClose()
{
}


void function CharacterSkillsDialog_OnNavigateBack()
{
	CloseActiveMenu()
}
