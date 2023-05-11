global function InitArmoryPanel

struct
{
	var                       panel
	array<var>                allButtons
	table<var, ItemFlavor>    buttonToCategory

	int activeTabIndex = 0
} file


void function InitArmoryPanel( var panel )
{
	file.panel = panel

	SetPanelTabTitle( panel, "#LOADOUT" )

	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, ArmoryPanel_OnShow )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, ArmoryPanel_OnHide )

	{
		var childPanel = Hud_GetChild( file.panel, "ArmoryWeaponsPanel" )
		TabDef tab = AddTab( file.panel, childPanel, "#LOOT_CAT_MAINWEAPON" )
		SetTabBaseWidth( tab, 200 )
	}
	{
		var childPanel = Hud_GetChild( file.panel, "ArmoryMorePanel" )
		TabDef tab = AddTab( file.panel, childPanel, "#MORE" )
		SetTabBaseWidth( tab, 160 )
	}

	TabData tabData = GetTabDataForPanel( file.panel )
	tabData.centerTabs = true
	SetTabBackground( tabData, Hud_GetChild( file.panel, "TabsBackground" ), eTabBackground.STANDARD )
	SetTabDefsToSeasonal(tabData)
}


bool function IsButtonFocused()
{
	if ( file.allButtons.contains( GetFocus() ) )
		return true

	return false
}


bool function ButtonNotFocused()
{
	return !IsButtonFocused()
}


void function ArmoryPanel_OnShow( var panel )
{
	TabData tabData = GetTabDataForPanel( panel )

	DeactivateTab( tabData )
	SetTabNavigationEnabled( file.panel, false )
	SetTabNavigationEnabled( file.panel, true )

	if ( GetLastMenuNavDirection() == MENU_NAV_FORWARD )
	{
		ActivateTab( tabData, 0 )
		thread AnimateInSmallTabBar( tabData )
	}
	else
	{
		ActivateTab( tabData, file.activeTabIndex )
	}

	UI_SetPresentationType( ePresentationType.WEAPON_CATEGORY )

	{
		var childPanel = Hud_GetChild( file.panel, "ArmoryWeaponsPanel" )
		Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.ArmoryWeaponsTab, OnNewnessQueryChangedUpdatePanelTab, childPanel )
	}
	{
		var childPanel = Hud_GetChild( file.panel, "ArmoryMorePanel" )
		Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.ArmoryMoreTab, OnNewnessQueryChangedUpdatePanelTab, childPanel )
	}
}


void function ArmoryPanel_OnHide( var panel )
{

	file.activeTabIndex = GetMenuActiveTabIndex( panel )

	{
		var childPanel = Hud_GetChild( file.panel, "ArmoryWeaponsPanel" )
		Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.ArmoryWeaponsTab, OnNewnessQueryChangedUpdatePanelTab, childPanel )
	}
	{
		var childPanel = Hud_GetChild( file.panel, "ArmoryMorePanel" )
		Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.ArmoryMoreTab, OnNewnessQueryChangedUpdatePanelTab, childPanel )
	}

}
