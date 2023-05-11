global function InitConsumableStickersPanel
global function ConsumableStickersPanel_SetConsumable
global function ConsumableStickersPanel_GetCurrentConsumable
global function ConsumableStickersPanel_InitPreviewStyle
global function ConsumableStickersPanel_TogglePreviewStyle

struct PanelData
{
	var panel
	var stickersOwnedRui
	var stickerListPanel
	var blurbPanel

	int               consumable = -1
	array<ItemFlavor> stickerItemList
}

struct
{
	table<var, PanelData> panelDataMap

	var activePanel = null
	int         currentConsumable
	bool        previewOnObject = true
	ItemFlavor& previewedItem
} file


void function InitConsumableStickersPanel( var panel )
{
	Assert( !(panel in file.panelDataMap) )
	PanelData pd
	file.panelDataMap[ panel ] <- pd

	pd.stickersOwnedRui = Hud_GetRui( Hud_GetChild( panel, "StickersOwned" ) )
	pd.stickerListPanel = Hud_GetChild( panel, "StickerListPanel" )

	pd.blurbPanel = Hud_GetChild( panel, "SkinBlurb" )

	Hud_SetVisible( pd.blurbPanel, false )

	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, ConsumableStickersPanel_OnShow )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, ConsumableStickersPanel_OnHide )
	AddPanelEventHandler_FocusChanged( panel, ConsumableStickersPanel_OnFocusChanged )

	AddPanelFooterOption( panel, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
	AddPanelFooterOption( panel, LEFT, BUTTON_A, false, "#A_BUTTON_SELECT", "", null, CustomizeMenus_IsFocusedItem )
	AddPanelFooterOption( panel, LEFT, BUTTON_X, false, "#X_BUTTON_EQUIP", "#X_BUTTON_EQUIP", null, CustomizeMenus_IsFocusedItemEquippable )
	AddPanelFooterOption( panel, LEFT, BUTTON_X, false, "#X_BUTTON_CLEAR", "#X_BUTTON_CLEAR", null, bool function () : ()
	{
		return ( CustomizeMenus_IsFocusedItemUnlocked() && !CustomizeMenus_IsFocusedItemEquippable() )
	} )
}


void function ConsumableStickersPanel_SetConsumable( var panel, int consumable )
{
	PanelData pd = file.panelDataMap[panel]
	pd.consumable = consumable
}

int function ConsumableStickersPanel_GetCurrentConsumable()
{
	return file.currentConsumable
}

void function ConsumableStickersPanel_OnShow( var panel )
{
	file.activePanel = panel
	RunClientScript( "EnableModelTurn" )

	thread TrackIsOverScrollBar( file.panelDataMap[panel].stickerListPanel )

	ConsumableStickersPanel_Update( panel )
}


void function ConsumableStickersPanel_OnHide( var panel )
{
	Signal( uiGlobal.signalDummy, "TrackIsOverScrollBar" )
	RunClientScript( "EnableModelTurn" )
	ConsumableStickersPanel_Update( panel )
}


void function ConsumableStickersPanel_Update( var panel )
{
	PanelData pd    = file.panelDataMap[panel]
	var scrollPanel = Hud_GetChild( pd.stickerListPanel, "ScrollPanel" )

	          
	foreach ( int stickerItemIdx, ItemFlavor unused in pd.stickerItemList )
	{
		var button = Hud_GetChild( scrollPanel, "GridButton" + stickerItemIdx )
		CustomizeButton_UnmarkForUpdating( button )
	}
	pd.stickerItemList.clear()

	                                  
	if ( IsPanelActive( panel ) && pd.consumable != -1 )
	{
		file.currentConsumable = pd.consumable
		LoadoutEntry entry = Loadout_Sticker( file.currentConsumable, 0 )
		pd.stickerItemList = GetLoadoutItemsSortedForMenu( entry, Sticker_GetSortOrdinal )

		for ( int i = pd.stickerItemList.len() - 1; i >= 0; i-- )
		{
			if ( Sticker_IsTheEmpty( pd.stickerItemList[i] ) )
				pd.stickerItemList.remove( i )
		}

		bool ignoreDefaultItemForCount = true
		bool shouldIgnoreOtherSlots = true
		int ownedCount = CustomizeMenus_GetOwnedCount( entry, pd.stickerItemList, ignoreDefaultItemForCount, shouldIgnoreOtherSlots )
		RuiSetInt( pd.stickersOwnedRui, "ownedCount", ownedCount )

		Hud_InitGridButtons( pd.stickerListPanel, pd.stickerItemList.len() )

		foreach ( int stickerItemIdx, ItemFlavor stickerItem in pd.stickerItemList )
		{
			var button = Hud_GetChild( scrollPanel, "GridButton" + stickerItemIdx )
			CustomizeButton_UpdateAndMarkForUpdating( button, [entry], stickerItem, PreviewConsumableSticker, CanEquipCanBuyCharacterItemCheck )

			Hud_ClearToolTipData( button )

			var rui = Hud_GetRui( button )
			RuiDestroyNestedIfAlive( rui, "badge" )
			RuiSetBool( rui, "displayQuality", true )

			var nestedRui = CreateNestedRuiForSticker( rui, stickerItem )

			ToolTipData toolTipData
			toolTipData.titleText = Localize( ItemFlavor_GetLongName( stickerItem ) )
			toolTipData.descText = Localize( ItemFlavor_GetTypeName( stickerItem ) )
			toolTipData.tooltipFlags = toolTipData.tooltipFlags | eToolTipFlag.INSTANT_FADE_IN
			Hud_SetToolTipData( button, toolTipData )
		}

		                                                                   
		ItemFlavor equippedStickerItem = LoadoutSlot_GetItemFlavor( ToEHI( GetLocalClientPlayer() ), entry )
		if ( Sticker_IsTheEmpty( equippedStickerItem ) )
			PreviewConsumableSticker( equippedStickerItem )

		Hud_ScrollToTop( pd.stickerListPanel )
		                                                       
		                               
	}
}


void function ConsumableStickersPanel_OnFocusChanged( var panel, var oldFocus, var newFocus )
{
	if ( !IsValid( panel ) )                  
		return

	if ( GetParentMenu( panel ) != GetActiveMenu() )
		return

	UpdateFooterOptions()
}


void function ConsumableStickersPanel_InitPreviewStyle()
{
	file.previewOnObject = true
	CustomizeConsumablesMenu_UpdatePreviewStyleButtonState( file.previewOnObject )
}


void function ConsumableStickersPanel_TogglePreviewStyle( var button )
{
	file.previewOnObject = !file.previewOnObject

	CustomizeConsumablesMenu_UpdatePreviewStyleButtonState( file.previewOnObject )
	PreviewConsumableSticker( file.previewedItem )
}


void function PreviewConsumableSticker( ItemFlavor stickerItem )
{
	#if DEV
		if ( InputIsButtonDown( KEY_LSHIFT ) )
		{
			string locedName = Localize( ItemFlavor_GetLongName( stickerItem ) )
			printt( "\"" + locedName + "\" grx ref is: " + GetGlobalSettingsString( ItemFlavor_GetAsset( stickerItem ), "grxRef" ) )
		}
	#endif       

	if ( file.previewOnObject )
	{
		int presentationType = GetStickerPresentationType( file.currentConsumable )
		UI_SetPresentationType( presentationType )
		RunClientScript( "UIToClient_PreviewAppliedSticker", ItemFlavor_GetGUID( stickerItem ), file.currentConsumable )
	}
	else
	{
		UI_SetPresentationType( ePresentationType.FLAT_STICKER )
		RunClientScript( "UIToClient_PreviewFlatSticker", ItemFlavor_GetGUID( stickerItem ) )
	}

	                   
	if ( file.activePanel != null )
	{
		var blurbPanel = file.panelDataMap[ file.activePanel ].blurbPanel
		if ( Sticker_HasStoryBlurb( stickerItem ) )
		{
			Hud_SetVisible( blurbPanel, true )
			int quality = 0
			if ( ItemFlavor_HasQuality( stickerItem ) )
				quality = ItemFlavor_GetQuality( stickerItem )

			var rui = Hud_GetRui( blurbPanel )
			RuiSetString( rui, "characterName", ItemFlavor_GetShortName( stickerItem ) )
			RuiSetString( rui, "skinNameText", ItemFlavor_GetLongName( stickerItem ) )
			RuiSetString( rui, "bodyText", Sticker_GetStoryBlurbBodyText( stickerItem ) )
			RuiSetFloat3( rui, "characterColor", SrgbToLinear( GetKeyColor( COLORID_TEXT_LOOT_TIER0, quality + 1 ) / 255.0 ) )
			RuiSetGameTime( rui, "startTime", ClientTime() )
		}
		else
		{
			Hud_SetVisible( blurbPanel, false )
		}
	}

	file.previewedItem = stickerItem
}
