global function InitRTKArmoryCategoriesPanel

global function RTKArmoryCategoriesPanel_OnInitialize
global function RTKArmoryCategoriesPanel_OnDestroy
global function RTKMutator_CheckIfWeaponMasteryEnabled

global struct RTKArmoryCategoriesPanel_Properties
{
	rtk_panel arPanel
	rtk_panel smgPanel
	rtk_panel lmgPanel
	rtk_panel marksmanPanel
	rtk_panel sniperPanel
	rtk_panel pistolPanel
	rtk_panel shotgunPanel
}

global struct RTKArmoryButton_Properties
{
	string name = ""
	asset icon = $""
	int count = 0
	int flavGUID = 0
	bool hasNew = false
}

struct
{
	bool isButtonFocused = false
} file

void function RTKArmoryCategoriesPanel_OnInitialize( rtk_behavior self )
{
	RTKArmoryCategories_SetupButtonData()

	RTKArmoryCategories_SetupButton( self, "arPanel" )
	RTKArmoryCategories_SetupButton( self, "smgPanel" )
	RTKArmoryCategories_SetupButton( self, "lmgPanel" )
	RTKArmoryCategories_SetupButton( self, "marksmanPanel" )
	RTKArmoryCategories_SetupButton( self, "sniperPanel" )
	RTKArmoryCategories_SetupButton( self, "pistolPanel" )
	RTKArmoryCategories_SetupButton( self, "shotgunPanel" )
}

void function RTKArmoryCategoriesPanel_OnDestroy( rtk_behavior self )
{
	RTKDataModelType_DestroyStruct( RTK_MODELTYPE_MENUS, "weaponCategories", ["armory"] )
}

void function RTKArmoryCategories_SetupButtonData()
{
	var armoriesModel = RTKDataModelType_CreateStruct( RTK_MODELTYPE_MENUS, "weaponCategories", "",["armory"] )

	array<ItemFlavor> categories = GetAllWeaponCategories()
	foreach( category in categories )
	{
		var weaponCategoryStruct = RTKStruct_AddStructProperty( armoriesModel, WeaponCategoryFlavor_GetStatsKey( category ), "RTKArmoryButton_Properties" )

		RTKStruct_SetString( weaponCategoryStruct, "name", ItemFlavor_GetLongName( category ) )
		RTKStruct_SetAssetPath( weaponCategoryStruct, "icon", ItemFlavor_GetIcon( category ) )
		RTKStruct_SetInt( weaponCategoryStruct, "count", GetWeaponsInCategory( category ).len() )
		RTKStruct_SetInt( weaponCategoryStruct, "flavGUID", ItemFlavor_GetGUID( category ) )
		RTKStruct_SetBool( weaponCategoryStruct, "hasNew", Newness_ReverseQuery_GetNewCount( NEWNESS_QUERIES.WeaponCategoryButton[ category ] ) > 0 )
	}
}

void function RTKArmoryCategories_SetupButton( rtk_behavior self, string property )
{
	rtk_panel ornull panel = self.PropGetPanel( property )

	if( panel != null )
	{
		expect rtk_panel( panel )
		rtk_behavior ornull button = panel.FindBehaviorByTypeName( "Button" )
		if( button != null )
		{
			expect rtk_behavior( button )
			self.AutoSubscribe( button, "onPressed", function( rtk_behavior button, int keycode, int prevState ) : ( self, panel ) {
				var model = RTKDataModel_GetStruct( panel.GetBindingRootPath() )
				if( RTKStruct_HasProperty(model, "flavGUID" ) )
				{
					int flavGUID = RTKStruct_GetInt( model, "flavGUID" )
					if( IsValidItemFlavorGUID( flavGUID ) )  
					{
						SetTopLevelCustomizeContext( GetItemFlavorByGUID( flavGUID ) )
						AdvanceMenu( GetMenu( "CustomizeWeaponMenu" ) )
					}
				}
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

void function MarkAllArmoryMoreItemsAsViewed( var button )
{
	bool markSuccess = MarkAllItemsOfTypeAsViewed( eItemTypeUICategory.WEAPON_LOADOUT )

	if ( markSuccess )
	{
		EmitUISound( "UI_Menu_Accept" )
		RTKArmoryCategories_SetupButtonData()
	}
	else
		EmitUISound( "UI_Menu_Deny" )

}

void function InitRTKArmoryCategoriesPanel( var panel )
{
	AddPanelFooterOption( panel, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
	AddPanelFooterOption( panel, LEFT, BUTTON_A, false, "#A_BUTTON_SELECT", "", null, IsButtonFocused )
	AddPanelFooterOption( panel, LEFT, BUTTON_Y, true, "#BUTTON_MARK_ALL_AS_SEEN_GAMEPAD", "#BUTTON_MARK_ALL_AS_SEEN_MOUSE", MarkAllArmoryMoreItemsAsViewed )
}

bool function IsButtonFocused()
{
	return file.isButtonFocused
}

                  
bool function RTKMutator_CheckIfWeaponMasteryEnabled( int input )
{
	return ( GetCurrentPlaylistVarInt( "enable_mastery_weapon", 1 ) == 1 )
}
