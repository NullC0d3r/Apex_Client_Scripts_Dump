global function InitRTKArmoryMorePanel

global function RTKArmoryMorePanel_OnInitialize

global struct RTKArmoryMorePanel_Properties
{
	rtk_panel healthInjectorPanel
	rtk_panel shieldCellPanel
	rtk_panel shieldBatteryPanel
	rtk_panel phoenixKidPanel
	rtk_panel transitionsPanel
	rtk_panel musicPanel
	rtk_panel skydiveTrailsPanel
}

struct
{
	bool isButtonFocused = false
} file

void function RTKArmoryMorePanel_OnInitialize( rtk_behavior self )
{
	RTKArmoryMore_SetupData()

	RTKArmoryMore_SetupStickerButton( self, "healthInjectorPanel", 0 )
	RTKArmoryMore_SetupStickerButton( self, "shieldCellPanel", 1 )
	RTKArmoryMore_SetupStickerButton( self, "shieldBatteryPanel", 2 )
	RTKArmoryMore_SetupStickerButton( self, "phoenixKidPanel", 3 )

	RTKArmoryMore_SetupGameCustomizationButton( self, "transitionsPanel", 0 )
	RTKArmoryMore_SetupGameCustomizationButton( self, "musicPanel", 1 )
	RTKArmoryMore_SetupGameCustomizationButton( self, "skydiveTrailsPanel", 2 )
}

void function RTKArmoryMorePanel_OnDestroy( rtk_behavior self )
{
	RTKDataModelType_DestroyStruct( RTK_MODELTYPE_MENUS, "moreCategories", ["armory"] )
}

void function RTKArmoryMore_SetupData()
{
	var moreModel = RTKDataModelType_CreateStruct( RTK_MODELTYPE_MENUS, "moreCategories", "",["armory"] )

	RTKArmoryMore_SetupButtonData( moreModel, "healthInjector", "#HEALTH_INJECTOR", $"rui/menu/buttons/weapon_categories/more_health_injector", NEWNESS_QUERIES.Stickers )
	RTKArmoryMore_SetupButtonData( moreModel, "shieldCell", "#SURVIVAL_PICKUP_HEALTH_COMBO_SMALL", $"rui/menu/buttons/weapon_categories/more_shield_cell", NEWNESS_QUERIES.Stickers )
	RTKArmoryMore_SetupButtonData( moreModel, "shieldBattery", "#SURVIVAL_PICKUP_HEALTH_COMBO_LARGE", $"rui/menu/buttons/weapon_categories/more_shield_battery", NEWNESS_QUERIES.Stickers )
	RTKArmoryMore_SetupButtonData( moreModel, "phoenixKit", "#SURVIVAL_PICKUP_HEALTH_COMBO_FULL", $"rui/menu/buttons/weapon_categories/more_phoenix_kit", NEWNESS_QUERIES.Stickers )

	RTKArmoryMore_SetupButtonData( moreModel, "loadscreen", "#TAB_CUSTOMIZE_LOADSCREEN", $"rui/menu/buttons/weapon_categories/more_transition_screen", NEWNESS_QUERIES.LoadscreenButton )
	RTKArmoryMore_SetupButtonData( moreModel, "music", "#TAB_CUSTOMIZE_MUSIC_PACK", $"rui/menu/buttons/weapon_categories/more_music_pack", NEWNESS_QUERIES.MusicPackButton )
	RTKArmoryMore_SetupButtonData( moreModel, "skydive", "#TAB_CUSTOMIZE_SKYDIVE_TRAIL", $"rui/menu/buttons/weapon_categories/more_skydive_trails", NEWNESS_QUERIES.SkydiveTrailButton )
}

void function RTKArmoryMore_SetupButtonData( var moreModel, string key, string name, asset assetPath, Newness_ReverseQuery newness_query )
{
	var moreCategoryStruct = RTKStruct_AddStructProperty( moreModel, key, "RTKArmoryButton_Properties" )

	RTKStruct_SetString( moreCategoryStruct, "name", name )
	RTKStruct_SetAssetPath( moreCategoryStruct, "icon", assetPath )
	RTKStruct_SetInt( moreCategoryStruct, "count", 0 )
	RTKStruct_SetInt( moreCategoryStruct, "flavGUID", 0 )
	RTKStruct_SetBool( moreCategoryStruct, "hasNew", Newness_ReverseQuery_GetNewCount( newness_query ) > 0 )
}

void function RTKArmoryMore_SetupStickerButton( rtk_behavior self, string property, int tab )
{
	rtk_panel ornull panel = self.PropGetPanel( property )

	if ( panel != null )
	{
		expect rtk_panel( panel )
		rtk_behavior ornull button = panel.FindBehaviorByTypeName( "Button" )
		if ( button != null )
		{
			expect rtk_behavior( button )

			self.AutoSubscribe( button, "onPressed", function( rtk_behavior button, int keycode, int prevState ) : ( tab ) {
				RTKArmoryMore_GoToStickerMenu( tab )
			} )

			self.AutoSubscribe( button, "onHighlighted", function( rtk_behavior button, int prevState ) : ( self ) {
				file.isButtonFocused = true
				UpdateFooterOptions()                                                                                        
			} )

			self.AutoSubscribe( button, "onIdle", function( rtk_behavior button, int prevState ) : ( self ) {
				file.isButtonFocused = false
				UpdateFooterOptions()                                                                                        
			} )
		}
	}
}

void function RTKArmoryMore_SetupGameCustomizationButton( rtk_behavior self, string property, int tab )
{
	rtk_panel ornull panel = self.PropGetPanel( property )

	if ( panel != null )
	{
		expect rtk_panel( panel )
		rtk_behavior ornull button = panel.FindBehaviorByTypeName( "Button" )
		if ( button != null )
		{
			expect rtk_behavior( button )

			self.AutoSubscribe( button, "onPressed", function( rtk_behavior button, int keycode, int prevState ) : ( tab ) {
				RTKArmoryMore_GoToGameCustomizationMenu( tab )
			} )

			self.AutoSubscribe( button, "onHighlighted", function( rtk_behavior button, int prevState ) : ( self ) {
				file.isButtonFocused = true
				UpdateFooterOptions()                                                                                        
			} )

			self.AutoSubscribe( button, "onIdle", function( rtk_behavior button, int prevState ) : ( self ) {
				file.isButtonFocused = false
				UpdateFooterOptions()                                                                                        
			} )
		}
	}
}

void function RTKArmoryMore_GoToStickerMenu( int tab )
{
	SetCustomizeConsumablesMenuDefaultTab( tab )

	ItemFlavor character = LoadoutSlot_GetItemFlavor( LocalClientEHI(), Loadout_Character() )
	SetTopLevelCustomizeContext( character )

	AdvanceMenu( GetMenu( "CustomizeConsumablesMenu" ) )
}

void function RTKArmoryMore_GoToGameCustomizationMenu( int tab )
{
	SetCustomizeMiscMenuDefaultTab( tab )
	AdvanceMenu( GetMenu( "MiscCustomizeMenu" ) )
}

void function MarkAllArmoryWeaponItemsAsViewed( var button )
{
	bool miscMarkSuccess = MarkAllItemsOfTypeAsViewed( eItemTypeUICategory.MISC_LOADOUT )

	if ( miscMarkSuccess )
	{
		EmitUISound( "UI_Menu_Accept" )
		RTKArmoryMore_SetupData()
	}
	else
		EmitUISound( "UI_Menu_Deny" )
}


void function InitRTKArmoryMorePanel( var panel )
{
	AddPanelFooterOption( panel, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
	AddPanelFooterOption( panel, LEFT, BUTTON_A, false, "#A_BUTTON_SELECT", "", null, IsButtonFocused )
	AddPanelFooterOption( panel, LEFT, BUTTON_Y, true, "#BUTTON_MARK_ALL_AS_SEEN_GAMEPAD", "#BUTTON_MARK_ALL_AS_SEEN_MOUSE", MarkAllArmoryWeaponItemsAsViewed )
}

bool function IsButtonFocused()
{
	return file.isButtonFocused
}
