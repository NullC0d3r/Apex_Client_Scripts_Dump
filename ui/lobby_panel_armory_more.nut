global function InitArmoryMorePanel



struct
{
	var                       panel
	table<string, var > stickerSlotToButtonMap
	table<string, var > miscSlotToButtonMap
	array< var >		allButtons
} file



void function InitArmoryMorePanel( var panel )
{
	file.panel = panel

	SetPanelTabTitle( panel, "#MORE" )

	file.stickerSlotToButtonMap = {
		healthInjector = Hud_GetChild( panel, "HealthInjectorButton" ),
		ShieldCell = Hud_GetChild( panel, "ShieldCellButton" ),
		shieldBattery = Hud_GetChild( panel, "ShieldBatteryButton" ),
		phoenixKit = Hud_GetChild( panel, "PhoenixKitButton" )
	}

	file.miscSlotToButtonMap = {
		transitions = Hud_GetChild( panel, "TransitionsButton" ),
		music = Hud_GetChild( panel, "MusicButton" ),
		skydive = Hud_GetChild( panel, "SkydiveButton" )
	}

	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, ArmoryMorePanel_OnShow )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, ArmoryMorePanel_OnHide )

	AddPanelFooterOption( panel, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
	AddPanelFooterOption( panel, LEFT, BUTTON_Y, true, "#BUTTON_MARK_ALL_AS_SEEN_GAMEPAD", "#BUTTON_MARK_ALL_AS_SEEN_MOUSE", MarkAllArmoryWeaponItemsAsViewed, ButtonNotFocused )
	AddPanelFooterOption( panel, LEFT, BUTTON_A, false, "#A_BUTTON_SELECT", "", null, IsButtonFocused )
}


void function ArmoryMorePanel_OnShow( var panel )
{
	foreach(var button in file.stickerSlotToButtonMap )
	{
		ArmoryMorePanel_SetUpStickerButton( button )
	}

	foreach(var button in file.miscSlotToButtonMap )
	{
		ArmoryMorePanel_SetUpMiscButton( button )
	}
}

void function ArmoryMorePanel_SetUpStickerButton( var button )
{
	file.allButtons.append( button )

	SeasonStyleData seasonStyle = GetSeasonStyle()

	Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.Stickers, OnNewnessQueryChangedUpdateButton, button )
	Hud_AddEventHandler( button, UIE_CLICK, ArmoryMorePanel_OnClickStickerButton )

	var rui = Hud_GetRui( button )
	RuiSetColorAlpha( rui, "seasonColor", SrgbToLinear( seasonStyle.seasonNewColor ), 1.0 )
}

void function ArmoryMorePanel_SetUpMiscButton( var button )
{
	file.allButtons.append( button )

	SeasonStyleData seasonStyle = GetSeasonStyle()

	if( button == file.miscSlotToButtonMap["music"] )
		Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.MusicPackButton, OnNewnessQueryChangedUpdateButton, button )
	else if( button == file.miscSlotToButtonMap["skydive"] )
		Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.SkydiveTrailButton, OnNewnessQueryChangedUpdateButton, button )
	else if( button == file.miscSlotToButtonMap["transitions"] )
		Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.LoadscreenButton, OnNewnessQueryChangedUpdateButton, button )

	Hud_AddEventHandler( button, UIE_CLICK, ArmoryMorePanel_OnClickMiscButton )

	var rui = Hud_GetRui( button )
	RuiSetColorAlpha( rui, "seasonColor", SrgbToLinear( seasonStyle.seasonNewColor ), 1.0 )
}

void function ArmoryMorePanel_OnHide( var panel )
{
	foreach(var button in file.stickerSlotToButtonMap )
	{
		Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.Stickers, OnNewnessQueryChangedUpdateButton, button )
		Hud_RemoveEventHandler( button, UIE_CLICK, ArmoryMorePanel_OnClickStickerButton )
	}

	foreach(var button in file.miscSlotToButtonMap )
	{
		if( button == file.miscSlotToButtonMap["music"] )
			Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.MusicPackButton, OnNewnessQueryChangedUpdateButton, button )
		else if( button == file.miscSlotToButtonMap["skydive"] )
			Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.SkydiveTrailButton, OnNewnessQueryChangedUpdateButton, button )
		else if( button == file.miscSlotToButtonMap["transitions"] )
			Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.LoadscreenButton, OnNewnessQueryChangedUpdateButton, button )

		Hud_RemoveEventHandler( button, UIE_CLICK, ArmoryMorePanel_OnClickMiscButton )
	}
	file.allButtons.clear()
}

void function ArmoryMorePanel_OnClickStickerButton( var button )
{
	if ( !file.allButtons.contains( button ) )
		return

	int index = 0
	foreach( var b in file.stickerSlotToButtonMap )
	{
		if( b == button )
			SetCustomizeConsumablesMenuDefaultTab( index )

		index++
	}

	ItemFlavor character = LoadoutSlot_GetItemFlavor( LocalClientEHI(), Loadout_Character() )                                                                        
	SetTopLevelCustomizeContext( character )

	AdvanceMenu( GetMenu( "CustomizeConsumablesMenu" ) )
}

void function ArmoryMorePanel_OnClickMiscButton( var button )
{
	if ( !file.allButtons.contains( button ) )
		return

	int index = 0
	foreach( var b in file.miscSlotToButtonMap )
	{
		if( b == button )
			SetCustomizeMiscMenuDefaultTab( index )

		index++
	}

	AdvanceMenu( GetMenu( "MiscCustomizeMenu" ) )
}

void function MarkAllArmoryWeaponItemsAsViewed( var button )
{
	bool miscMarkSuccess = MarkAllItemsOfTypeAsViewed( eItemTypeUICategory.MISC_LOADOUT )

	if ( miscMarkSuccess )
		EmitUISound( "UI_Menu_Accept" )
	else
		EmitUISound( "UI_Menu_Deny" )
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

