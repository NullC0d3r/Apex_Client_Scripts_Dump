global function InitWeaponSkinsPanel

struct PanelData
{
	var panel
	var ownedRui
	var listPanel

	array<ItemFlavor> weaponSkinList
}

struct
{
	table<var, PanelData> panelDataMap

	var         currentPanel = null
	ItemFlavor& currentWeapon
	ItemFlavor& currentWeaponSkin
} file

                                    
                                     
                               
                                    
                                     
                                     
                                    

void function InitWeaponSkinsPanel( var panel )
{
	Assert( !(panel in file.panelDataMap) )
	PanelData pd
	file.panelDataMap[ panel ] <- pd

	pd.ownedRui = Hud_GetRui( Hud_GetChild( panel, "Owned" ) )
	RuiSetString( pd.ownedRui, "title", Localize( "#SKINS_OWNED" ).toupper() )

	pd.listPanel = Hud_GetChild( panel, "WeaponSkinList" )

	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, WeaponSkinsPanel_OnShow )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, WeaponSkinsPanel_OnHide )
	AddPanelEventHandler_FocusChanged( panel, WeaponSkinsPanel_OnFocusChanged )

	AddPanelFooterOption( panel, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
	AddPanelFooterOption( panel, LEFT, BUTTON_A, false, "#A_BUTTON_SELECT", "", null, CustomizeMenus_IsFocusedItem )

	#if NX_PROG || PC_PROG_NX_UI
		AddPanelFooterOption( panel, LEFT, BUTTON_X, false, "#X_BUTTON_EQUIP", "#X_BUTTON_EQUIP", null, CustomizeMenus_IsFocusedItemEquippable )
		AddPanelFooterOption( panel, LEFT, BUTTON_X, false, "#X_BUTTON_UNLOCK", "#X_BUTTON_UNLOCK", null, CustomizeMenus_IsFocusedItemLocked )
		AddPanelFooterOption( panel, LEFT, BUTTON_TRIGGER_LEFT, false, "#MENU_ZOOM_CONTROLS_GAMEPAD", "#MENU_ZOOM_CONTROLS", null )
	#else
		AddPanelFooterOption( panel, RIGHT, BUTTON_X, false, "#X_BUTTON_EQUIP", "#X_BUTTON_EQUIP", null, CustomizeMenus_IsFocusedItemEquippable )
		AddPanelFooterOption( panel, RIGHT, BUTTON_X, false, "#X_BUTTON_UNLOCK", "#X_BUTTON_UNLOCK", null, CustomizeMenus_IsFocusedItemLocked )
		AddPanelFooterOption( panel, RIGHT, BUTTON_TRIGGER_LEFT, false, "#MENU_ZOOM_CONTROLS_GAMEPAD", "#MENU_ZOOM_CONTROLS", null )
	#endif

	void functionref( var ) func = (
		void function( var button ) : ()
		{
			var listPanel = file.panelDataMap[ file.currentPanel ].listPanel
			SetOrClearFavoriteFromFocus( listPanel )
		}
	)

	#if NX_PROG || PC_PROG_NX_UI
		AddPanelFooterOption( panel, LEFT, BUTTON_Y, false, "#Y_BUTTON_SET_FAVORITE", "#Y_BUTTON_SET_FAVORITE", func, CustomizeMenus_IsFocusedItemFavoriteable )
		AddPanelFooterOption( panel, LEFT, BUTTON_Y, false, "#Y_BUTTON_CLEAR_FAVORITE", "#Y_BUTTON_CLEAR_FAVORITE", func, CustomizeMenus_IsFocusedItemFavorite )
	#else
		AddPanelFooterOption( panel, RIGHT, BUTTON_Y, false, "#Y_BUTTON_SET_FAVORITE", "#Y_BUTTON_SET_FAVORITE", func, CustomizeMenus_IsFocusedItemFavoriteable )
		AddPanelFooterOption( panel, RIGHT, BUTTON_Y, false, "#Y_BUTTON_CLEAR_FAVORITE", "#Y_BUTTON_CLEAR_FAVORITE", func, CustomizeMenus_IsFocusedItemFavorite )
	#endif
}



void function WeaponSkinsPanel_OnShow( var panel )
{
	UI_SetPresentationType( ePresentationType.WEAPON_SKIN )

	file.currentPanel = panel
	Hud_ScrollToTop( file.panelDataMap[panel].listPanel )
	thread TrackIsOverScrollBar( file.panelDataMap[panel].listPanel )
	WeaponSkinsPanel_Update( panel )
}


void function WeaponSkinsPanel_OnHide( var panel )
{
	WeaponSkinsPanel_Update( panel )
	Signal( uiGlobal.signalDummy, "TrackIsOverScrollBar" )
}

void function WeaponSkinsPanel_OnFocusChanged( var panel, var oldFocus, var newFocus )
{
	if ( !IsValid( panel ) )                  
		return
	if ( GetParentMenu( panel ) != GetActiveMenu() )
		return

	UpdateFooterOptions()

	if ( IsControllerModeActive() )
		CustomizeMenus_UpdateActionContext( newFocus )
}

void function WeaponSkinsPanel_Update( var panel )
{
	PanelData pd    = file.panelDataMap[panel]
	var scrollPanel = Hud_GetChild( pd.listPanel, "ScrollPanel" )

	          
	foreach ( int flavIdx, ItemFlavor unused in pd.weaponSkinList)
	{
		var button = Hud_GetChild( scrollPanel, "GridButton" + flavIdx )
		CustomizeButton_UnmarkForUpdating( button )
	}
	pd.weaponSkinList.clear()

	CustomizeMenus_SetActionButton( null )

	               
	RuiSetString( pd.ownedRui, "title", Localize( "#SKINS_OWNED" ).toupper() )

	ItemFlavor ornull weaponOrNull = CategoryWeaponPanel_GetWeapon( Hud_GetParent( panel )  )
	                                  
	if ( IsPanelActive( panel ) && weaponOrNull != null )
	{
		file.currentWeapon = expect ItemFlavor( weaponOrNull )
		LoadoutEntry entry
		array<ItemFlavor> itemList
		void functionref( ItemFlavor ) previewFunc
		void functionref( ItemFlavor, var ) customButtonUpdateFunc
		void functionref( ItemFlavor, void functionref() ) confirmationFunc
		bool ignoreDefaultItemForCount
		bool shouldIgnoreOtherSlots


		entry = Loadout_WeaponSkin( file.currentWeapon )
		pd.weaponSkinList = GetLoadoutItemsSortedForMenu( entry, WeaponSkin_GetSortOrdinal )
		FilterWeaponSkinList( pd.weaponSkinList )
		itemList = pd.weaponSkinList
		previewFunc = PreviewWeaponSkin
		confirmationFunc = null
		ignoreDefaultItemForCount = false
		shouldIgnoreOtherSlots = false

		customButtonUpdateFunc = (void function( ItemFlavor charmFlav, var rui )
		{
			RuiSetAsset( rui, "equippedCharmWeaponAsset", $"" )
		})

		RuiSetString( pd.ownedRui, "collected", CustomizeMenus_GetCollectedString( entry, itemList, ignoreDefaultItemForCount, shouldIgnoreOtherSlots ) )

		Hud_InitGridButtons( pd.listPanel, itemList.len() )

		foreach ( int flavIdx, ItemFlavor flav in itemList )
		{
			var button = Hud_GetChild( scrollPanel, "GridButton" + flavIdx )
			CustomizeButton_UpdateAndMarkForUpdating( button, [entry], flav, previewFunc, null, false, customButtonUpdateFunc, confirmationFunc )
		}

		CustomizeMenus_SetActionButton( Hud_GetChild( panel, "ActionButton" ) )
	}
}

void function PreviewWeaponSkin( ItemFlavor weaponSkinFlavor )
{
	#if DEV
		if ( InputIsButtonDown( KEY_LSHIFT ) )
		{
			string locedName = Localize( ItemFlavor_GetLongName( weaponSkinFlavor ) )
			printt( "\"" + locedName + "\" grx ref is: " + GetGlobalSettingsString( ItemFlavor_GetAsset( weaponSkinFlavor ), "grxRef" ) )
			printt( "\"" + locedName + "\" world model is: " + WeaponSkin_GetWorldModel( weaponSkinFlavor ) )
		}
	#endif       

	ItemFlavor charmFlavor = LoadoutSlot_GetItemFlavor( LocalClientEHI(), Loadout_WeaponCharm( WeaponSkin_GetWeaponFlavor( weaponSkinFlavor ) ) )
	int weaponCharmId      = ItemFlavor_GetGUID( charmFlavor )
	int weaponSkinId       = ItemFlavor_GetGUID( weaponSkinFlavor )
	file.currentWeaponSkin = weaponSkinFlavor

	                   
	if( file.currentPanel != null )
	{
		var blurbPanel = Hud_GetChild( file.currentPanel, "SkinBlurb" )
		if ( WeaponSkin_HasStoryBlurb( weaponSkinFlavor ) )
		{
			Hud_SetVisible( blurbPanel, true )
			int quality = 0
			if( ItemFlavor_HasQuality( weaponSkinFlavor  ) )
				quality = ItemFlavor_GetQuality( weaponSkinFlavor )

			var rui = Hud_GetRui( blurbPanel )
			RuiSetString( rui, "characterName", ItemFlavor_GetShortName( weaponSkinFlavor ) )
			RuiSetString( rui, "skinNameText", ItemFlavor_GetLongName( weaponSkinFlavor ) )
			RuiSetString( rui, "bodyText", WeaponSkin_GetStoryBlurbBodyText( weaponSkinFlavor ) )
			RuiSetFloat3( rui, "characterColor", SrgbToLinear( GetKeyColor( COLORID_TEXT_LOOT_TIER0, quality + 1 ) / 255.0 ) )
			RuiSetGameTime( rui, "startTime", ClientTime() )
		}
		else
		{
			Hud_SetVisible( blurbPanel, false )
		}
	}

	RunClientScript( "UIToClient_PreviewWeaponSkin", weaponSkinId, weaponCharmId, true )
}

void function FilterWeaponSkinList( array<ItemFlavor> weaponSkinList )
{
	for ( int i = weaponSkinList.len() - 1; i >= 0; i-- )
	{
		if ( !ShouldDisplayWeaponSkin( weaponSkinList[i] ) )
			weaponSkinList.remove( i )
	}
}

bool function ShouldDisplayWeaponSkin( ItemFlavor weaponSkin )
{
	if ( WeaponSkin_ShouldHideIfLocked( weaponSkin ) )
	{
		LoadoutEntry entry = Loadout_WeaponSkin( WeaponSkin_GetWeaponFlavor( weaponSkin ) )
		if ( !IsItemFlavorUnlockedForLoadoutSlot( LocalClientEHI(), entry, weaponSkin ) )
			return false
	}

	return true
}
