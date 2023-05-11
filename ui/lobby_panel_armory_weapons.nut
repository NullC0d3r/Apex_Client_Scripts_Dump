global function InitArmoryWeaponsPanel

struct
{
	var                       panel

	array<var>                weaponButtons
	array<var>                weaponCategoryButtons
	table<var, ItemFlavor>    buttonToCategory
	var                       listPanel

	array< var > 			  allButtons
} file


void function InitArmoryWeaponsPanel( var panel )
{
	file.panel = panel

	SetPanelTabTitle( panel, "#STATS_WEAPONS_TITLE" )

	file.weaponCategoryButtons = GetPanelElementsByClassname( panel, "WeaponCategoryButtonClass" )
	Assert( file.weaponCategoryButtons.len() == 7 )

	foreach ( button in file.weaponCategoryButtons )
	{
		Hud_AddEventHandler( button, UIE_CLICK, CategoryButton_OnActivate )
	}

	file.allButtons = clone( file.weaponCategoryButtons )

	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, ArmoryWeaponsPanel_OnShow )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, ArmoryWeaponsPanel_OnHide )

	AddPanelFooterOption( panel, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
	AddPanelFooterOption( panel, LEFT, BUTTON_Y, true, "#BUTTON_MARK_ALL_AS_SEEN_GAMEPAD", "#BUTTON_MARK_ALL_AS_SEEN_MOUSE", MarkAllArmoryWeaponItemsAsViewed, ButtonNotFocused )
	AddPanelFooterOption( panel, LEFT, BUTTON_A, false, "#A_BUTTON_SELECT", "", null, IsButtonFocused )
}


void function ArmoryWeaponsPanel_OnShow( var panel )
{
	array<ItemFlavor> categories = GetAllWeaponCategories()

	foreach ( index, button in file.weaponCategoryButtons )
		CategoryButton_Init( button, categories[index] )
}

void function ArmoryWeaponsPanel_OnHide( var panel )
{
	if ( NEWNESS_QUERIES.isValid )
	{
		foreach ( var button, ItemFlavor category in file.buttonToCategory )
		{
			if ( category in NEWNESS_QUERIES.WeaponCategoryButton )                                                    
				Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.WeaponCategoryButton[ category ], OnNewnessQueryChangedUpdateButton, button )
		}
	}

	file.buttonToCategory.clear()
}

void function CategoryButton_Init( var button, ItemFlavor category )
{
	SeasonStyleData seasonStyle = GetSeasonStyle()

	var rui = Hud_GetRui( button )
	RuiSetString( rui, "buttonText", Localize( ItemFlavor_GetLongName( category ) ).toupper() )
	RuiSetImage( rui, "buttonImage", ItemFlavor_GetIcon( category ) )
	RuiSetInt( rui, "numPips", GetWeaponsInCategory( category ).len() )
	RuiSetColorAlpha( rui, "seasonColor", SrgbToLinear( seasonStyle.seasonNewColor ), 1.0 )
	file.buttonToCategory[button] <- category

	Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.WeaponCategoryButton[ category ], OnNewnessQueryChangedUpdateButton, button )
}

void function CategoryButton_OnActivate( var button )
{
	if ( !( button in file.buttonToCategory ) )
		return

	ItemFlavor category = file.buttonToCategory[button]
	SetTopLevelCustomizeContext( category )

	AdvanceMenu( GetMenu( "CustomizeWeaponMenu" ) )
}

void function MarkAllArmoryWeaponItemsAsViewed( var button )
{
	bool weaponMarkSuccess = MarkAllItemsOfTypeAsViewed( eItemTypeUICategory.WEAPON_LOADOUT )

	if ( weaponMarkSuccess )
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


