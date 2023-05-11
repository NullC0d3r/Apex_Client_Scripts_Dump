global function InitSurvivalInventoryMenu

global function OpenSurvivalInventoryMenu
global function CloseSurvivalInventoryMenu
global function IsSurvivalInventoryMenuOpen

global function SurvivalMenuSwapWeapon
global function SurvivalMenuSwapToMelee
global function SurvivalMenuSwapToOrdnance
global function IsSurvivalMenuEnabled

global function SurvivalMenu_OnAction
global function SurvivalMenu_AckAction

global function SurvivalInventoryMenu_SetInventoryLimit
global function SurvivalInventoryMenu_GetInventoryLimit
global function SurvivalInventoryMenu_SetInventoryLimitMax
global function SurvivalInventoryMenu_GetInventoryLimitMax
global function SurvivalInventoryMenu_GetMaxInventoryLimit
global function SurvivalInventoryMenu_BeginUpdate
global function SurvivalInventoryMenu_EndUpdate
global function SurvivalInventoryMenu_UpdateInventoryCharacter

global function TryCloseSurvivalInventory
global function TryCloseSurvivalInventoryFromDamage

global function SURVIVAL_GetMaxInventoryLimit
global function SURVIVAL_GetInventoryLimit

global function Survival_RegisterInventoryMenu

global function PROTO_Survival_DoInventoryMenusUseCommands
global function PROTO_ShouldInventoryFooterHack
global function Survival_AddPassthroughCommandsToMenu
global function SURVIVAL_IsAnInventoryMenuOpened

global function SurvivalInventory_SetBGVisible

struct
{
	var  menu

	var quickInventoryPanel
	var characterDetailsPanel

	int inventoryLimit
	int maxInventoryLimit

	float menuOpenTime

	array<var> inventoryMenus

	bool isOpen = false
} file

void function InitSurvivalInventoryMenu( var newMenuArg )
                                              
{
	var menu = GetMenu( "SurvivalInventoryMenu" )
	file.menu = menu

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnSurvivalInventoryMenu_Open )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, OnSurvivalInventoryMenu_NavBack )
	AddMenuEventHandler( menu, eUIEvent.MENU_SHOW, OnSurvivalInventoryMenu_Show )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnSurvivalInventoryMenu_Close )

	AddMenuEventHandler( menu, eUIEvent.MENU_INPUT_MODE_CHANGED, OnSurvivalInventory_OnInputModeChange )
	Survival_AddPassthroughCommandsToMenu( menu )
	Survival_RegisterInventoryMenu( menu )

	file.quickInventoryPanel = GetPanel( "SurvivalQuickInventoryPanel" )

	SetTabRightSound( menu, "UI_InGame_InventoryTab_Select" )
	SetTabLeftSound( menu, "UI_InGame_InventoryTab_Select" )


}


bool function PROTO_Survival_DoInventoryMenusUseCommands()
{
	return GetCurrentPlaylistVarBool( "survival_menus_use_commands", true )
}


bool function PROTO_ShouldInventoryFooterHack()
{
	return IsSurvivalMenuEnabled() && !PROTO_Survival_DoInventoryMenusUseCommands()
}


void function Survival_AddPassthroughCommandsToMenu( var menu )
{
	AddCommandForMenuToPassThrough( menu, "+forward" )
	AddCommandForMenuToPassThrough( menu, "+backward" )
	AddCommandForMenuToPassThrough( menu, "+moveleft" )
	AddCommandForMenuToPassThrough( menu, "+moveright" )
	AddCommandForMenuToPassThrough( menu, "+duck" )
	AddCommandForMenuToPassThrough( menu, "+toggle_duck" )
	AddCommandForMenuToPassThrough( menu, "+jump" )
	AddCommandForMenuToPassThrough( menu, "+speed" )
	AddCommandForMenuToPassThrough( menu, "+reload" )
	AddCommandForMenuToPassThrough( menu, "+weaponcycle" )
	AddCommandForMenuToPassThrough( menu, "+pushtotalk" )

	AddCommandForMenuToPassThrough( menu, "weaponSelectPrimary0" )
	AddCommandForMenuToPassThrough( menu, "weaponSelectPrimary1" )
	AddCommandForMenuToPassThrough( menu, "weaponSelectPrimary2" )
	AddCommandForMenuToPassThrough( menu, "weaponSelectOrdnance" )
	AddCommandForMenuToPassThrough( menu, "+scriptCommand4" )
	AddCommandForMenuToPassThrough( menu, "Sur_UseHealthPack" )
	AddCommandForMenuToPassThrough( menu, "weapon_inspect" )
	AddCommandForMenuToPassThrough( menu, "toggle_inventory" )
	AddCommandForMenuToPassThrough( menu, "toggle_map" )
	AddCommandForMenuToPassThrough( menu, "+scriptCommand3" )
	AddCommandForMenuToPassThrough( menu, "say_team" )
}


void function SurvivalInventoryMenu_Clear()
{
}


void function SurvivalMenu_OnAction()
{
	Hud_SetEnabled( GetPanel( "SurvivalQuickInventoryPanel" ), false )
	Hud_Show( Hud_GetChild( file.quickInventoryPanel, "BUSYBLOCKER" ) )
}


void function SurvivalMenu_AckAction()
{
	Hud_SetEnabled( GetPanel( "SurvivalQuickInventoryPanel" ), true )
	Hud_Hide( Hud_GetChild( file.quickInventoryPanel, "BUSYBLOCKER" ) )
}


TabData function SetUpTabs()
{
	TabData tabData = GetTabDataForPanel( file.menu )
	tabData.centerTabs = true
	SetTabDefsToSeasonal(tabData)
	SetTabBackground( tabData, Hud_GetChild( file.menu, "TabsBackground" ), eTabBackground.STANDARD )
	return tabData
}

void function OpenSurvivalInventoryMenu( int tabIndex = 0 )
{
	CloseAllMenus()
	AdvanceMenu( file.menu )

	TabData tabData = SetUpTabs()

	ActivateTab( tabData, tabIndex )
}


void function OnSurvivalInventoryMenu_Open()
{
	file.isOpen = true

	ClearTabs( file.menu )

	TabData tabData = SetUpTabs()

	bool isScoreboardEnabled = GetCurrentPlaylistVarBool( "enable_inventory_scoreboard", false )
	bool isScoreboardFirstTab = GetCurrentPlaylistVarBool( "inventory_scoreboard_first_tab", false )

	bool isInventoryTabDisabled = GetCurrentPlaylistVarBool( "inventory_tab_hidden", false )

	if ( isScoreboardEnabled && isScoreboardFirstTab )
	{
		TabDef tabdef = AddTab( file.menu, Hud_GetChild( file.menu, "GenericScoreboardPanel" ), "#TAB_SCOREBOARD" )
		SetTabBaseWidth( tabdef, 250 )
	}                   

	if( !isInventoryTabDisabled )
	{
		TabDef tabdef = AddTab( file.menu, file.quickInventoryPanel, "#INVENTORY_TITLE" )
		SetTabBaseWidth( tabdef, 220 )
	}

	if ( isScoreboardEnabled && !isScoreboardFirstTab )
	{
		TabDef tabdef = AddTab( file.menu, Hud_GetChild( file.menu, "GenericScoreboardPanel" ), "#TAB_SCOREBOARD" )
		SetTabBaseWidth( tabdef, 250 )
	}                        

	{
		TabDef tabdef = AddTab( file.menu, Hud_GetChild( file.menu, "SquadPanel" ), "BUG THIS" )
		SetTabBaseWidth( tabdef, 160 )
	}
                         
	if ( IsFiringRangeGameMode() )
	{
		TabDef tabdef = AddTab( file.menu, Hud_GetChild( file.menu, "FiringRangeSettingsPanel" ), "#BUTTON_RANGE_CUSTOMIZE" )
		tabdef.hideSubtabPips = true                                                                                      
		SetTabBaseWidth( tabdef, 320 )
	}
      
	{
		TabDef tabdef = AddTab( file.menu, Hud_GetChild( file.menu, "CharacterDetailsPanel" ), "#LEGEND" )
		SetTabBaseWidth( tabdef, 180 )
	}

	TabData squadData = GetTabDataForPanel( file.menu )
	TabDef squadDef   = Tab_GetTabDefByBodyName( squadData, "SquadPanel" )
	if ( IsSoloMode() )
		squadDef.title = "#STATS"
	else
		squadDef.title = "#SQUAD"

	SetTabBackground( tabData, Hud_GetChild( file.menu, "TabsBackground" ), eTabBackground.STANDARD )
	SetTabNavigationEnabled( file.menu, true )
	EmitUISound( "UI_InGame_Inventory_Open" )

	file.menuOpenTime = UITime()

	UISize screenSize = GetScreenSize()
	SetCursorPosition( <1920.0 * 0.5, 1080.0 * 0.5, 0> )
}


void function OnSurvivalInventoryMenu_Show()
{
	SurvivalInventoryMenu_UpdateInventoryCharacter()
	SetMenuReceivesCommands( file.menu, PROTO_Survival_DoInventoryMenusUseCommands() && !IsControllerModeActive() )
}

void function SurvivalInventoryMenu_UpdateInventoryCharacter()
{
	if( !file.isOpen )
		return

	ItemFlavor ornull character = null

	if ( LoadoutSlot_IsReady( ToEHI( GetLocalClientPlayer() ), Loadout_Character() ) )
	{
		character = LoadoutSlot_GetItemFlavor( ToEHI( GetLocalClientPlayer() ), Loadout_Character() )
	}

	if ( character == null )
		return

	expect ItemFlavor( character )

	SetCharacterSkillsPanelLegend( character, true )
}

void function OnSurvivalInventory_OnInputModeChange()
{
	SetMenuReceivesCommands( file.menu, PROTO_Survival_DoInventoryMenusUseCommands() && !IsControllerModeActive() )
}


void function OnSurvivalInventoryMenu_Close()
{
	file.isOpen = false

	HidePanel( GetPanel( "SurvivalQuickInventoryPanel" ) )
	SetBlurEnabled( false )
}

bool function IsSurvivalInventoryMenuOpen()
{
	return file.isOpen
}

void function OnSurvivalInventoryMenu_NavBack()
{
	var panel = GetPanel( "SurvivalQuickInventoryPanel" )
	if ( Hud_IsVisible( panel ) )
	{
		SurvivalQuickInventory_NavigateBack()
		return
	}

	CloseActiveMenu()
}


void function CloseSurvivalInventoryMenu()
{
	if ( GetActiveMenu() == file.menu )
	{
		CloseAllMenus()
	}
}


void function SurvivalMenuSwapWeapon( var button )
{
	if ( UITime() > file.menuOpenTime + 0.1 )
		RunClientScript( "Survival_SwapPrimary" )
}


void function SurvivalMenuSwapToMelee( var button )
{
	if ( UITime() > file.menuOpenTime + 0.1 )
		RunClientScript( "Survival_SwapToMelee" )
}


void function SurvivalMenuSwapToOrdnance( var button )
{
	if ( UITime() > file.menuOpenTime + 0.1 )
		RunClientScript( "Survival_SwapToOrdnance" )
}


bool function IsSurvivalMenuEnabled()
{
	return GetCurrentPlaylistVarInt( "survival_menu_enabled", 1 ) == 1
}


   
void function SurvivalInventoryMenu_SetInventoryLimit( int limit )
{
	file.inventoryLimit = limit
}


int function SurvivalInventoryMenu_GetInventoryLimit()
{
	return file.inventoryLimit
}


void function SurvivalInventoryMenu_SetInventoryLimitMax( int limitMax )
{
	file.maxInventoryLimit = limitMax
}


int function SurvivalInventoryMenu_GetInventoryLimitMax()
{
	return file.maxInventoryLimit
}


int function SurvivalInventoryMenu_GetMaxInventoryLimit()
{
	return SURVIVAL_GetMaxInventoryLimit( GetLocalClientPlayer() )
}


void function SurvivalInventoryMenu_BeginUpdate()
{
	if ( GetActiveMenu() == file.menu )
	{
		SurvivalInventoryMenu_Clear()
	}
}


void function SurvivalInventoryMenu_EndUpdate()
{
	if ( GetActiveMenu() == file.menu )
	{
		SurvivalQuickInventory_OnUpdate()

		                                                                                                    
		if ( !GetDpadNavigationActive() )

			ForceVGUIFocusUpdate()
	}

	UpdateQuickSwapMenu()
}


void function TryCloseSurvivalInventoryFromDamage( var button )
{
	if ( SURVIVAL_IsAnInventoryMenuOpened() )
	{
		CloseActiveMenu()
		if ( IsFullyConnected() )
		{
			RunClientScript( "UICallback_BlockPingForDuration", 0.5 )
		}
	}
}


void function TryCloseSurvivalInventory( var button )
{
	if ( SURVIVAL_IsAnInventoryMenuOpened() )
		CloseActiveMenu()
}


int function SURVIVAL_GetMaxInventoryLimit( entity player )
{
	return SurvivalInventoryMenu_GetInventoryLimitMax()
}


int function SURVIVAL_GetInventoryLimit( entity player )
{
	return SurvivalInventoryMenu_GetInventoryLimit()
}


void function Survival_RegisterInventoryMenu( var menu )
{
	file.inventoryMenus.append( menu )
}


bool function SURVIVAL_IsAnInventoryMenuOpened()
{
	foreach ( var wtf in file.inventoryMenus )
	{
		if ( wtf == GetActiveMenu() || IsPanelActive( wtf ) )
			return true
	}

	return false
}


void function SurvivalInventory_SetBGVisible( bool visible )
{
	Hud_SetVisible( Hud_GetChild( file.menu, "Blur" ), visible )
	Hud_SetVisible( Hud_GetChild( file.menu, "Cover" ), visible )
}