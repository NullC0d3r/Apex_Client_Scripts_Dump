global function InitMiscCustomizeMenu

global function SetCustomizeMiscMenuDefaultTab

struct
{
	var        menu
	array<var> tabBodyPanelList

	int defaultTabIndex = 0
} file


void function InitMiscCustomizeMenu( var newMenuArg )                                               
{
	var menu = GetMenu( "MiscCustomizeMenu" )
	file.menu = menu

	SetTabRightSound( menu, "UI_Menu_ArmoryTab_Select" )
	SetTabLeftSound( menu, "UI_Menu_ArmoryTab_Select" )

	file.tabBodyPanelList = [
		Hud_GetChild( menu, "LoadscreenPanel" )
		Hud_GetChild( menu, "MusicPackPanel" )
		Hud_GetChild( menu, "SkydiveTrailPanel" )
	]

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, MiscCustomizeMenu_OnOpen )
	AddMenuEventHandler( menu, eUIEvent.MENU_SHOW, MiscCustomizeMenu_OnShow )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, MiscCustomizeMenu_OnClose )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, MiscCustomizeMenu_OnNavigateBack )

	AddMenuFooterOption( menu, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
	AddMenuFooterOption( menu, LEFT, BUTTON_A, true, "#A_BUTTON_SELECT", "" )
}


void function MiscCustomizeMenu_OnOpen()
{
	AddCallback_OnTopLevelCustomizeContextChanged( file.menu, MiscCustomizeMenu_Update )
	MiscCustomizeMenu_Update( file.menu )

	TabData tabData = GetTabDataForPanel( file.menu )
	tabData.centerTabs = true
	tabData.bannerTitle = ""                                   
	SetTabBackground( tabData, Hud_GetChild( file.menu, "TabsBackground" ), eTabBackground.STANDARD )


	if ( GetLastMenuNavDirection() == MENU_NAV_FORWARD )
	{
		ActivateTab( tabData, file.defaultTabIndex )
	}

	Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.LoadscreenButton, OnNewnessQueryChangedUpdatePanelTab, GetPanel( "LoadscreenPanel" ) )
	Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.MusicPackButton, OnNewnessQueryChangedUpdatePanelTab, GetPanel( "MusicPackPanel" ) )
	Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.SkydiveTrailButton, OnNewnessQueryChangedUpdatePanelTab, GetPanel( "SkydiveTrailPanel" ) )

	SetTabDefsToSeasonal( tabData )
	UpdateMenuTabs()
}


void function MiscCustomizeMenu_OnShow()
{
	UI_SetPresentationType( ePresentationType.WEAPON_CATEGORY )
}


void function MiscCustomizeMenu_OnClose()
{
	Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.LoadscreenButton, OnNewnessQueryChangedUpdatePanelTab, GetPanel( "LoadscreenPanel" ) )
	Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.MusicPackButton, OnNewnessQueryChangedUpdatePanelTab, GetPanel( "MusicPackPanel" ) )
	Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.SkydiveTrailButton, OnNewnessQueryChangedUpdatePanelTab, GetPanel( "SkydiveTrailPanel" ) )

	RemoveCallback_OnTopLevelCustomizeContextChanged( file.menu, MiscCustomizeMenu_Update )
	MiscCustomizeMenu_Update( file.menu )

	file.defaultTabIndex = 0
}


void function MiscCustomizeMenu_Update( var menu )
{
	  
	                                                                                  
	 
		                                                        
		                                                
		                                       
		 
			                                             
			                                                                                                                                     
		 
	 
	                       
	  
	ClearTabs( menu )

	                                   
	if ( GetActiveMenu() == menu )
	{
		  
		                                                   
		                                                  

		                                                               
		 
			                                                         

			                                                                                     

			                                                  
			                                                                                                                                            
		 
		  

		{
			TabDef tabdef = AddTab( menu, file.tabBodyPanelList[0], Localize( "#TAB_CUSTOMIZE_LOADSCREEN" ).toupper() )
			SetTabBaseWidth( tabdef, 280 )
			tabdef.isBannerLogoSmall = true
		}
		{
			TabDef tabdef = AddTab( menu, file.tabBodyPanelList[1], Localize( "#TAB_CUSTOMIZE_MUSIC_PACK" ).toupper() )
			SetTabBaseWidth( tabdef, 260 )
			tabdef.isBannerLogoSmall = true
		}
		{
			TabDef tabdef = AddTab( menu, file.tabBodyPanelList[2], Localize( "#TAB_CUSTOMIZE_SKYDIVE_TRAIL" ).toupper() )
			SetTabBaseWidth( tabdef, 270 )
			tabdef.isBannerLogoSmall = true
		}


	}

	SetPanelTabNew( GetPanel( "LoadscreenPanel" ), (Newness_ReverseQuery_GetNewCount( NEWNESS_QUERIES.LoadscreenButton ) > 0) )
	SetPanelTabNew( GetPanel( "MusicPackPanel" ), (Newness_ReverseQuery_GetNewCount( NEWNESS_QUERIES.MusicPackButton ) > 0) )
	SetPanelTabNew( GetPanel( "SkydiveTrailPanel" ), (Newness_ReverseQuery_GetNewCount( NEWNESS_QUERIES.SkydiveTrailButton ) > 0) )

	UpdateMenuTabs()
}


void function MiscCustomizeMenu_OnNavigateBack()
{
	Assert( GetActiveMenu() == file.menu )

	CloseActiveMenu()
}

void function SetCustomizeMiscMenuDefaultTab( int index )
{
	file.defaultTabIndex = index
}
