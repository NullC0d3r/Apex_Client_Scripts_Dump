global function InitCustomizeWeaponMenu

struct
{
	var        menu
	array<var> weaponTabBodyPanelList

	var skinsPanel
	var charmsPanel

	array<ItemFlavor> weaponList
} file


void function InitCustomizeWeaponMenu( var newMenuArg )                                               
{
	var menu = GetMenu( "CustomizeWeaponMenu" )
	file.menu = menu

	SetTabRightSound( menu, "UI_Menu_ArmoryTab_Select" )
	SetTabLeftSound( menu, "UI_Menu_ArmoryTab_Select" )

	file.weaponTabBodyPanelList = [
		Hud_GetChild( menu, "CategoryWeaponPanel0" )
		Hud_GetChild( menu, "CategoryWeaponPanel1" )
		Hud_GetChild( menu, "CategoryWeaponPanel2" )
		Hud_GetChild( menu, "CategoryWeaponPanel3" )
		Hud_GetChild( menu, "CategoryWeaponPanel4" )
		Hud_GetChild( menu, "CategoryWeaponPanel5" )
	]

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, CustomizeWeaponMenu_OnOpen )
	AddMenuEventHandler( menu, eUIEvent.MENU_SHOW, CustomizeWeaponMenu_OnShow )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, CustomizeWeaponMenu_OnClose )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, CustomizeWeaponMenu_OnNavigateBack )
}


void function CustomizeWeaponMenu_OnOpen()
{
	RunClientScript( "UIToClient_ResetWeaponRotation" )
	RunClientScript( "EnableModelTurn" )

	ItemFlavor category =  GetTopLevelCustomizeContext()

	AddCallback_OnTopLevelCustomizeContextChanged( file.menu, CustomizeWeaponMenu_Update )
	CustomizeWeaponMenu_Update( file.menu )

	TabData tabData = GetTabDataForPanel( file.menu )
	tabData.centerTabs = true
	AddCallback_OnTabChanged( CustomizeWeaponMenu_OnTabChanged )

	if ( GetLastMenuNavDirection() == MENU_NAV_FORWARD )
	{
		ActivateTab( tabData, 0 )
	}

	UpdateMenuTabs()
}

void function CustomizeWeaponMenu_OnShow()
{
                                  
		bool enableWeaponMastery =  Mastery_IsEnabled()
		var masteryLevel = Hud_GetChild( file.menu, "WeaponMasteryStats" )
		Hud_SetVisible( masteryLevel, enableWeaponMastery )
       
}

void function CustomizeWeaponMenu_OnClose()
{
	RemoveCallback_OnTopLevelCustomizeContextChanged( file.menu, CustomizeWeaponMenu_Update )
	CustomizeWeaponMenu_Update( file.menu )
}

void function CustomizeWeaponMenu_Update( var menu )
{
	for ( int panelIdx = 0; panelIdx < file.weaponTabBodyPanelList.len(); panelIdx++ )
	{
		var tabBodyPanel = file.weaponTabBodyPanelList[panelIdx]
		CategoryWeaponPanel_SetWeapon( tabBodyPanel, null )
		if ( panelIdx < file.weaponList.len() )
		{
			ItemFlavor weapon = file.weaponList[panelIdx]

			Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.WeaponTab[weapon], OnNewnessQueryChangedUpdatePanelTab, tabBodyPanel )
		}
	}
	file.weaponList.clear()

	ClearTabs( menu )

	                                   
	if ( GetActiveMenu() == menu )
	{
		ItemFlavor category = GetTopLevelCustomizeContext()
		file.weaponList = GetWeaponsInCategory( category )

		foreach ( int weaponIdx, ItemFlavor weapon in file.weaponList )
		{
			var tabBodyPanel = file.weaponTabBodyPanelList[weaponIdx]

			TabDef tabdef = AddTab( menu, tabBodyPanel, Localize( ItemFlavor_GetShortName( weapon ) ).toupper() )
			SetTabBaseWidth( tabdef, 220 )
			tabdef.isBannerLogoSmall = true

			CategoryWeaponPanel_SetWeapon( tabBodyPanel, weapon )
			Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.WeaponTab[weapon], OnNewnessQueryChangedUpdatePanelTab, tabBodyPanel )
		}

		TabData tabData = GetTabDataForPanel( menu )
		tabData.centerTabs = true
		SetTabBackground( tabData, Hud_GetChild( menu, "TabsBackground" ), eTabBackground.CAPSTONE )
		SetTabDefsToSeasonal(tabData)
	}

	UpdateMenuTabs()
}


void function CustomizeWeaponMenu_OnTabChanged()
{
	if ( GetActiveMenu() != file.menu )
		return

	TabData tabData = GetTabDataForPanel( file.menu )

	if( file.weaponList.len() <  tabData.activeTabIdx  )
		return

	tabData.bannerLogoImage = WeaponItemFlavor_GetHudIcon( file.weaponList[ tabData.activeTabIdx ] )
	float scale = 0.25

	switch( WeaponItemFlavor_GetClassname(file.weaponList[ tabData.activeTabIdx ] ) )
	{
		case "mp_weapon_sniper":
		case "mp_weapon_sentinel":
		case "mp_weapon_mastiff":
			scale = -0.2
			break
		case "mp_weapon_dmr":
		case "mp_weapon_defender":
		case "mp_weapon_energy_shotgun":
		case "mp_weapon_doubletake":
		case "mp_weapon_dragon_lmg":
		case "mp_weapon_3030":
			scale = 0.0
			break
		case "mp_weapon_esaw":
		case "mp_weapon_lstar":
		case "mp_weapon_lmg":
		case "mp_weapon_g2":
		case "mp_weapon_shotgun":
		case "mp_weapon_nemesis":
			scale = 0.1
			break

		case "mp_weapon_autopistol":
		case "mp_weapon_volt_smg":
			scale = 0.4
			break

		case "mp_weapon_pdw":
		case "mp_weapon_shotgun_pistol":
		case "mp_weapon_autopistol":
		case "mp_weapon_semipistol":
		case "mp_weapon_wingman":
			scale = 0.5
			break
		case "mp_weapon_alternator_smg":
			scale = 0.7
			break
		default:
			break

	}

	tabData.bannerLogoWidth = 640
	tabData.bannerLogoHeight = 320
	tabData.bannerLogoScale = scale
}

void function CustomizeWeaponMenu_OnNavigateBack()
{
	Assert( GetActiveMenu() == file.menu )

	CloseActiveMenu()
}


