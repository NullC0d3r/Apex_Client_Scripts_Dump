global function InitCustomizeConsumablesMenu
global function CustomizeConsumablesMenu_UpdatePreviewStyleButtonState

global function SetCustomizeConsumablesMenuDefaultTab

struct
{
	var        menu
	array<var> tabBodyPanelList

	array<int> consumableList

	int defaultTabIndex = 0
	var previewStyleToggle
} file


void function InitCustomizeConsumablesMenu( var newMenuArg )                                               
{
	var menu = GetMenu( "CustomizeConsumablesMenu" )
	file.menu = menu

	SetTabRightSound( menu, "UI_Menu_ArmoryTab_Select" )
	SetTabLeftSound( menu, "UI_Menu_ArmoryTab_Select" )

	file.tabBodyPanelList = [
		Hud_GetChild( menu, "StickersPanel0" )
		Hud_GetChild( menu, "StickersPanel1" )
		Hud_GetChild( menu, "StickersPanel2" )
		Hud_GetChild( menu, "StickersPanel3" )
	]

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, CustomizeConsumablesMenu_OnOpen )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, CustomizeConsumablesMenu_OnClose )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, CustomizeConsumablesMenu_OnNavigateBack )
	AddMenuEventHandler( menu, eUIEvent.MENU_SHOW, CustomizeConsumablesMenu_OnShow )
	AddMenuEventHandler( menu, eUIEvent.MENU_HIDE, CustomizeConsumablesMenu_OnHide )

	file.previewStyleToggle = Hud_GetChild( menu, "PreviewStyleToggle" )
	Hud_AddEventHandler( file.previewStyleToggle, UIE_CLICK, ConsumableStickersPanel_TogglePreviewStyle )
}


void function CustomizeConsumablesMenu_OnOpen()
{

	ConsumableStickersPanel_InitPreviewStyle()
	CustomizeConsumablesMenu_Update( file.menu )

	TabData tabData = GetTabDataForPanel( file.menu )
	tabData.centerTabs = true
	tabData.bannerTitle = Localize( "#STICKERS" ).toupper()
	tabData.bannerLogoImage = $"rui/menu/buttons/battlepass/sticker"
	tabData.bannerLogoScale = 0.8
	SetTabBackground( tabData, Hud_GetChild( file.menu, "TabsBackground" ), eTabBackground.CAPSTONE )

	if ( GetLastMenuNavDirection() == MENU_NAV_FORWARD )
		ActivateTab( tabData, file.defaultTabIndex )

	Lobby_AdjustScreenFrameToMaxSize( Hud_GetChild( file.menu, "ScreenFrame" ), true )
}


void function CustomizeConsumablesMenu_OnClose()
{
	CustomizeConsumablesMenu_Update( file.menu )
	file.defaultTabIndex = 0
}


void function CustomizeConsumablesMenu_Update( var menu )
{
	for ( int panelIdx = 0; panelIdx < file.tabBodyPanelList.len(); panelIdx++ )
	{
		var tabBodyPanel = file.tabBodyPanelList[panelIdx]
		ConsumableStickersPanel_SetConsumable( tabBodyPanel, -1 )

		if ( panelIdx < file.consumableList.len() )
			Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.Stickers, OnNewnessQueryChangedUpdatePanelTab, tabBodyPanel )
	}

	file.consumableList.clear()
	ClearTabs( menu )

	                                   
	if ( GetActiveMenu() == menu )
	{
		file.consumableList = GetAllStickerObjectTypes()

		foreach ( int consumableIdx in file.consumableList )                                                               
		{
			var tabBodyPanel = file.tabBodyPanelList[consumableIdx]

			TabDef tabdef = AddTab( menu, tabBodyPanel, Localize( GetStickerObjectName( consumableIdx ) ).toupper() )
			if( consumableIdx == 0 )
				SetTabBaseWidth( tabdef, 310 )
			else if( consumableIdx == 2 )
				SetTabBaseWidth( tabdef, 290 )
			else
				SetTabBaseWidth( tabdef, 240 )
			tabdef.isBannerLogoSmall = true
			ConsumableStickersPanel_SetConsumable( tabBodyPanel, consumableIdx )
			Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.Stickers, OnNewnessQueryChangedUpdatePanelTab, tabBodyPanel )
		}
	}
	TabData tabData = GetTabDataForPanel( file.menu )
	tabData.initialFirstTabButtonXPos = 50
	SetTabDefsToSeasonal( tabData )
	UpdateMenuTabs()
}


void function CustomizeConsumablesMenu_UpdatePreviewStyleButtonState( bool toggleState )
{
	HudElem_SetRuiArg( file.previewStyleToggle, "toggleState", toggleState )
}


void function CustomizeConsumablesMenu_OnNavigateBack()
{
	Assert( GetActiveMenu() == file.menu )

	CloseActiveMenu()
}


void function CustomizeConsumablesMenu_OnShow()
{
	RegisterButtonPressedCallback( BUTTON_Y, ButtonYPressed )
}


void function CustomizeConsumablesMenu_OnHide()
{
	DeregisterButtonPressedCallback( BUTTON_Y, ButtonYPressed )
}


void function ButtonYPressed( var unused )
{
	ConsumableStickersPanel_TogglePreviewStyle( file.previewStyleToggle )
}

void function SetCustomizeConsumablesMenuDefaultTab( int index )
{
	file.defaultTabIndex = index
}