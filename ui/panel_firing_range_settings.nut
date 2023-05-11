global function InitFiringRangeSettingsPanel

global function CreateFiringRangeOption

struct
{
	var panel

	var details
} file

global struct FiringRangeOption
{
	string setting
	string name
	string description
	void functionref( var button ) onChangeCallback = null
}

void function InitFiringRangeSettingsPanel( var panel )
{
	file.panel = panel
	file.details = Hud_GetChild( file.panel, "DetailsPanel" )

	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, OnModeSettingsPanel_Show )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, OnModeSettingsPanel_Hide )

	{
		TabDef tabDef = AddTab( panel, Hud_GetChild( panel, "FiringRangeSettingsGeneralPanel" ), "" )
		SetTabBaseWidth( tabDef, 220 )
	}
	TabData tabData = GetTabDataForPanel( panel )
	tabData.centerTabs = true
	SetTabDefsToSeasonal(tabData)
	SetTabBackground( tabData, Hud_GetChild( panel, "TabsBackground" ), eTabBackground.STANDARD )

	AddPanelFooterOption( panel, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
	AddPanelFooterOption( panel, RIGHT, BUTTON_START, true, "#HINT_SYSTEM_MENU_GAMEPAD", "#HINT_SYSTEM_MENU_KB", TryOpenSystemMenu )

	#if DEV
		AddPanelFooterOption( panel, LEFT, BUTTON_STICK_LEFT, true, "#LEFT_STICK_DEV_MENU", "#DEV_MENU", OpenDevMenu )
	#endif
}

const string BUTTONTEXT_INDENT = "    "

void function OnModeSettingsPanel_Show( var panel )
{
	if ( GetLastMenuNavDirection() == MENU_NAV_FORWARD )
	{
		TabData tabData = GetTabDataForPanel( panel )
		ActivateTab( tabData, 0 )
	}
}

void function OnModeSettingsPanel_Hide( var panel )
{

}

                 
FiringRangeOption function CreateFiringRangeOption( string name, string description, void functionref( var button ) onChangeCallback )
{
	FiringRangeOption option
	option.name = name
	option.description = description
	option.onChangeCallback = onChangeCallback
	return option
}

void function TryOpenSystemMenu( var panel )
{
	if ( InputIsButtonDown( BUTTON_START ) )
		return

	OpenSystemMenu()
}

