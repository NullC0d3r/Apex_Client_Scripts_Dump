global function InitCategoryWeaponPanel

global function CategoryWeaponPanel_SetWeapon
global function CategoryWeaponPanel_GetWeapon

struct PanelData
{
	var panel

	ItemFlavor ornull weaponOrNull
}


struct
{
	table<var, PanelData> panelDataMap

	var activePanel = null
	int lastTab = 0
} file

void function InitCategoryWeaponPanel( var panel )
{
	Assert( !(panel in file.panelDataMap) )
	PanelData pd
	file.panelDataMap[ panel ] <- pd

	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, CategoryWeaponPanel_OnShow )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, CategoryWeaponPanel_OnHide )

                                  
		{
			var childPanel = Hud_GetChild( panel, "WeaponMasteryPanel" )
			TabDef tabdef = AddTab( panel, childPanel, "#MASTERY_BUTTON" )
			SetTabBaseWidth( tabdef, 200 )
			tabdef.useTapHoldLogic = true
		}
       
	{
		var childPanel = Hud_GetChild( panel, "WeaponSkinsPanel" )
		TabDef tabdef = AddTab( panel, childPanel, "#SKINS_BUTTON" )
		SetTabBaseWidth( tabdef, 160 )
		tabdef.useTapHoldLogic = true
	}
	{
		var childPanel = Hud_GetChild( panel, "WeaponCharmsPanel" )
		TabDef tabdef = AddTab( panel, childPanel, "#CHARMS_BUTTON" )
		SetTabBaseWidth( tabdef, 160 )
	}

	TabData tabData = GetTabDataForPanel( panel )
	tabData.centerTabs = true

	SetTabBackground( tabData, Hud_GetChild( panel, "TabsBackground" ), eTabBackground.STANDARD )
	SetTabDefsToSeasonal(tabData)
	AddCallback_OnTabChanged( WeaponCategory_OnTabChanged )
}

void function WeaponCategory_OnTabChanged()
{
	if( file.activePanel == null )
		return

	TabData tabData = GetTabDataForPanel( file.activePanel )
	file.lastTab = tabData.activeTabIdx
}

void function CategoryWeaponPanel_OnShow( var panel )
{
	file.activePanel = panel
	TabData tabData = GetTabDataForPanel( panel )

                                  
		bool enableWeaponMastery =  Mastery_IsEnabled()
		TabDef seasonTabDef = Tab_GetTabDefByBodyName( tabData, "WeaponMasteryPanel" )

		seasonTabDef.visible = enableWeaponMastery
		seasonTabDef.enabled = enableWeaponMastery
       

	{
		var tabBodyPanel = Hud_GetChild( panel, "WeaponSkinsPanel" )
		ItemFlavor ornull weaponOrNull = CategoryWeaponPanel_GetWeapon(  panel  )

		if ( weaponOrNull != null )
		{
			expect ItemFlavor( weaponOrNull )

			Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.WeaponSkinsTab[ weaponOrNull ], OnNewnessQueryChangedUpdatePanelTab, tabBodyPanel )
		}
	}
	{
		var tabBodyPanel = Hud_GetChild( panel, "WeaponCharmsPanel" )
		Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.WeaponCharmButton, OnNewnessQueryChangedUpdatePanelTab, tabBodyPanel )
	}

	if ( GetLastMenuNavDirection() == MENU_NAV_FORWARD )
	{
                                   
			file.lastTab = ( enableWeaponMastery )? 0: 1
       
                   
        
	}

	ActivateTab( tabData, file.lastTab )
}


void function CategoryWeaponPanel_OnHide( var panel )
{
	{
		var tabBodyPanel = Hud_GetChild( panel, "WeaponSkinsPanel" )
		ItemFlavor ornull weaponOrNull = CategoryWeaponPanel_GetWeapon(  panel  )

		if ( weaponOrNull != null )
		{
			expect ItemFlavor( weaponOrNull )

			Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.WeaponSkinsTab[ weaponOrNull ], OnNewnessQueryChangedUpdatePanelTab, tabBodyPanel )
		}
	}

	{
		var tabBodyPanel = Hud_GetChild( panel, "WeaponCharmsPanel" )

		Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.WeaponCharmButton, OnNewnessQueryChangedUpdatePanelTab, tabBodyPanel )
	}

	TabData tabData = GetTabDataForPanel( panel )
	HideVisibleTabBodies( tabData )
}



                                           
                                           
                                           
                                           
                                           
                                           
                                                 

void function CategoryWeaponPanel_SetWeapon( var panel, ItemFlavor ornull weaponFlavOrNull )
{
	PanelData pd = file.panelDataMap[panel]
	pd.weaponOrNull = weaponFlavOrNull
}

ItemFlavor ornull function CategoryWeaponPanel_GetWeapon( var panel )
{
	PanelData pd = file.panelDataMap[panel]
	return pd.weaponOrNull
}
