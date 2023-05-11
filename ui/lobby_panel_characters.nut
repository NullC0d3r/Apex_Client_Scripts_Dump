global function InitCharactersPanel

global function JumpToCharactersTab
global function JumpToCharacterCustomize
global function OpenPurchaseCharacterDialogFromTop
global function IsCharacterLocked

struct
{
	var                    	panel
	var                    	characterSelectInfoRui
	var					   	lobbyClassPerkInfoRui
	array<var>             	buttons
	var						topLegendRowAnchor
	var						botLegendRowAnchor
	var		   				assaultShelf
	var		   				skirmisherShelf
	var		   				reconShelf
	var		   				supportShelf
	var		   				controllerShelf
	var		   				assaultShelfRUI
	var		   				skirmisherShelfRUI
	var		   				reconShelfRUI
	var		   				supportShelfRUI
	var		   				controllerShelfRUI
	array<var>             	roleButtons_Assault
	array<var>             	roleButtons_Skirmisher
	array<var>             	roleButtons_Recon
	array<var>             	roleButtons_Defense
	array<var>             	roleButtons_Support
	table<var, ItemFlavor> 	buttonToCharacter
	ItemFlavor ornull	   	presentedCharacter
	int						filterTabIndex
	InputDef&				giftFooter
	bool 					featuredalwaysOwned
} file

void function InitCharactersPanel( var panel )
{
	file.panel = panel
                   
	file.characterSelectInfoRui = Hud_GetRui( Hud_GetChild( file.panel, "LobbyClassLegendInfo" ) )
	file.lobbyClassPerkInfoRui = Hud_GetRui( Hud_GetChild( file.panel, "LobbyClassPerkInfo" ) )
	file.assaultShelfRUI = Hud_GetRui(Hud_GetChild( file.panel, "assaultShelf" ))
	file.skirmisherShelfRUI = Hud_GetRui(Hud_GetChild( file.panel, "SkirmisherShelf" ))
	file.reconShelfRUI = Hud_GetRui(Hud_GetChild( file.panel, "reconShelf" ))
	file.supportShelfRUI = Hud_GetRui(Hud_GetChild( file.panel, "supportShelf" ))
	file.controllerShelfRUI = Hud_GetRui(Hud_GetChild( file.panel, "controllerShelf" ))
     
                                                                                              
      
	file.buttons = GetPanelElementsByClassname( panel, "CharacterButtonClass" )
	file.roleButtons_Assault = GetPanelElementsByClassname( panel, "AssaultCharacterRoleButtonClass" )
	file.roleButtons_Skirmisher = GetPanelElementsByClassname( panel, "SkirmisherCharacterRoleButtonClass" )
	file.roleButtons_Recon = GetPanelElementsByClassname( panel, "ReconCharacterRoleButtonClass" )
	file.roleButtons_Defense = GetPanelElementsByClassname( panel, "DefenseCharacterRoleButtonClass" )
	file.roleButtons_Support = GetPanelElementsByClassname( panel, "SupportCharacterRoleButtonClass" )
	file.topLegendRowAnchor = Hud_GetChild( panel, "Top_List_Anchor" )
	file.botLegendRowAnchor = Hud_GetChild( panel, "Bot_List_Anchor" )
	file.assaultShelf = Hud_GetChild( file.panel, "assaultShelf" )
	file.skirmisherShelf = Hud_GetChild( file.panel, "SkirmisherShelf" )
	file.reconShelf = Hud_GetChild( file.panel, "reconShelf" )
	file.supportShelf = Hud_GetChild( file.panel, "supportShelf" )
	file.controllerShelf = Hud_GetChild( file.panel, "controllerShelf" )

	SetPanelTabTitle( panel, "#LEGENDS" )
	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, CharactersPanel_OnShow )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, CharactersPanel_OnHide )
	AddPanelEventHandler_FocusChanged( panel, CharactersPanel_OnFocusChanged )

	foreach ( button in file.buttons )
	{
		Hud_AddEventHandler( button, UIE_CLICK, CharacterButton_OnActivate )
		Hud_AddEventHandler( button, UIE_CLICKRIGHT, CharacterButton_OnRightClick )
		Hud_AddEventHandler( button, UIE_MIDDLECLICK, CharacterButton_OnMiddleClick )
	}

	foreach ( button in file.roleButtons_Assault )
	{
		Hud_AddEventHandler( button, UIE_CLICK, CharacterButton_OnActivate )
		Hud_AddEventHandler( button, UIE_CLICKRIGHT, CharacterButton_OnRightClick )
		Hud_AddEventHandler( button, UIE_MIDDLECLICK, CharacterButton_OnMiddleClick )
	}

	foreach ( button in file.roleButtons_Skirmisher )
	{
		Hud_AddEventHandler( button, UIE_CLICK, CharacterButton_OnActivate )
		Hud_AddEventHandler( button, UIE_CLICKRIGHT, CharacterButton_OnRightClick )
		Hud_AddEventHandler( button, UIE_MIDDLECLICK, CharacterButton_OnMiddleClick )
	}

	foreach ( button in file.roleButtons_Recon )
	{
		Hud_AddEventHandler( button, UIE_CLICK, CharacterButton_OnActivate )
		Hud_AddEventHandler( button, UIE_CLICKRIGHT, CharacterButton_OnRightClick )
		Hud_AddEventHandler( button, UIE_MIDDLECLICK, CharacterButton_OnMiddleClick )
	}

	foreach ( button in file.roleButtons_Defense )
	{
		Hud_AddEventHandler( button, UIE_CLICK, CharacterButton_OnActivate )
		Hud_AddEventHandler( button, UIE_CLICKRIGHT, CharacterButton_OnRightClick )
		Hud_AddEventHandler( button, UIE_MIDDLECLICK, CharacterButton_OnMiddleClick )
	}

	foreach ( button in file.roleButtons_Support )
	{
		Hud_AddEventHandler( button, UIE_CLICK, CharacterButton_OnActivate )
		Hud_AddEventHandler( button, UIE_CLICKRIGHT, CharacterButton_OnRightClick )
		Hud_AddEventHandler( button, UIE_MIDDLECLICK, CharacterButton_OnMiddleClick )
	}

	AddPanelFooterOption( panel, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
	AddPanelFooterOption( panel, LEFT, BUTTON_Y, true, "#BUTTON_MARK_ALL_AS_SEEN_GAMEPAD", "#BUTTON_MARK_ALL_AS_SEEN_MOUSE", MarkAllCharacterItemsAsViewed, CharacterButtonNotFocused )
	AddPanelFooterOption( panel, LEFT, BUTTON_A, false, "#A_BUTTON_SELECT", "", null, IsCharacterButtonFocused )
	AddPanelFooterOption( panel, LEFT, BUTTON_X, false, "#X_BUTTON_TOGGLE_LOADOUT", "#X_BUTTON_TOGGLE_LOADOUT", OpenFocusedCharacterSkillsDialog, IsCharacterButtonFocused )
	AddPanelFooterOption( panel, LEFT, BUTTON_X, false, "#X_BUTTON_UNLOCK_LEGEND", "#X_BUTTON_UNLOCK_LEGEND", null, CustomizeMenus_IsFocusedItemParentItemLocked )

	file.giftFooter = AddPanelFooterOption( panel, LEFT, BUTTON_BACK, true, "", "", null )

	AddPanelFooterOption( panel, RIGHT, BUTTON_Y, false, "#Y_BUTTON_SET_FEATURED", "#Y_BUTTON_SET_FEATURED", SetFeaturedCharacterFromFocus, IsReadyAndNonfeaturedCharacterButtonFocused )
                   
	{
		TabDef tabDef = AddTab( panel, null, "#MENU_ALL", $"rui/menu/character_select/utility/filter_role_all" )
		SetTabBaseWidth( tabDef, 80 )
	}
	{
		TabDef tabDef = AddTab( panel, null, "#ROLE_ASSAULT", $"rui/menu/character_select/utility/role_offense"  )
		SetTabBaseWidth( tabDef, 80 )
	}
	{
		TabDef tabDef = AddTab( panel, null, "#ROLE_SKIRMISHER", $"rui/menu/character_select/utility/role_skirmisher"  )
		SetTabBaseWidth( tabDef, 80 )
	}
	{
		TabDef tabDef = AddTab( panel, null, "#ROLE_RECON", $"rui/menu/character_select/utility/role_recon"  )
		SetTabBaseWidth( tabDef, 80 )
	}
	{
		TabDef tabDef = AddTab( panel, null, "#ROLE_SUPPORT", $"rui/menu/character_select/utility/role_support"  )
		SetTabBaseWidth( tabDef, 80 )
	}
	{
		TabDef tabDef = AddTab( panel, null, "#ROLE_CONTROLLER", $"rui/menu/character_select/utility/role_defense"  )
		SetTabBaseWidth( tabDef, 80 )
	}

	TabData tabData = GetTabDataForPanel( panel )
	tabData.centerTabs = true
	tabData.selectedExtraWidth = 35
	SetTabDefsToSeasonal(tabData)
	SetTabBackground( tabData, Hud_GetChild( panel, "TabsBackground" ), eTabBackground.STANDARD )
	AddCallback_OnTabChanged( Characters_OnTabChanged )
      
}

                   
void function Characters_OnTabChanged()
{
	if ( !IsPanelActive( file.panel ) )
		return

	TabData tabData = GetTabDataForPanel( file.panel )
	file.filterTabIndex = tabData.activeTabIdx
	UpdateFilteredButtonState()
}
      

bool function IsFocusedCharacterLocked()
{
	var focus = GetFocus()

	if ( focus in file.buttonToCharacter )
		return !Character_IsCharacterOwnedByPlayer( file.buttonToCharacter[focus] )

	return false
}

bool function IsCharacterLocked( ItemFlavor character )
{
	return !Character_IsCharacterOwnedByPlayer( character )
}

bool function IsReadyAndNonfeaturedCharacterButtonFocused()
{
	if ( !GRX_IsInventoryReady() )
		return false

	var focus = GetFocus()

	if ( focus in file.buttonToCharacter )
		return file.buttonToCharacter[focus] != LoadoutSlot_GetItemFlavor( LocalClientEHI(), Loadout_Character() )

	return false
}

bool function CharacterButtonNotFocused()
{
	return !IsCharacterButtonFocused()
}


bool function IsCharacterButtonFocused()
{
	if ( file.buttons.contains( GetFocus() ) )
		return true

	if ( file.roleButtons_Assault.contains( GetFocus() )
			|| file.roleButtons_Skirmisher.contains( GetFocus() )
			|| file.roleButtons_Recon.contains( GetFocus() )
			|| file.roleButtons_Defense.contains( GetFocus() )
			|| file.roleButtons_Support.contains( GetFocus() ))
		return true

	return false
}


void function SetFeaturedCharacter( ItemFlavor character )
{
	if ( !Character_IsCharacterOwnedByPlayer( character ) )
		return

                    
		foreach ( button in file.roleButtons_Assault )
		{
			if ( button in file.buttonToCharacter )
				Hud_SetSelected( button, file.buttonToCharacter[button] == character )
		}
		foreach ( button in file.roleButtons_Skirmisher )
		{
			if ( button in file.buttonToCharacter )
				Hud_SetSelected( button, file.buttonToCharacter[button] == character )
		}
		foreach ( button in file.roleButtons_Recon )
		{
			if ( button in file.buttonToCharacter )
				Hud_SetSelected( button, file.buttonToCharacter[button] == character )
		}
		foreach ( button in file.roleButtons_Defense )
		{
			if ( button in file.buttonToCharacter )
				Hud_SetSelected( button, file.buttonToCharacter[button] == character )
		}
		foreach ( button in file.roleButtons_Support )
		{
			if ( button in file.buttonToCharacter )
				Hud_SetSelected( button, file.buttonToCharacter[button] == character )
		}
      
                                   
  
                                         
                                                                         
  
       

	Newness_IfNecessaryMarkItemFlavorAsNoLongerNewAndInformServer( character )
	RequestSetItemFlavorLoadoutSlot( LocalClientEHI(), Loadout_Character(), character )

	file.featuredalwaysOwned = ItemFlavor_GetGRXMode( character ) == eItemFlavorGRXMode.NONE
	UpdateFooterOptions()

	EmitUISound( "UI_Menu_Legend_SetFeatured" )
}

void function MarkAllCharacterItemsAsViewed( var button )
{
	if ( MarkAllItemsOfTypeAsViewed( eItemTypeUICategory.CHARACTER ) )
		EmitUISound( "UI_Menu_Accept" )
	else
		EmitUISound( "UI_Menu_Deny" )
}

void function OpenPurchaseCharacterDialogFromFocus( var button )
{
	if ( !GRX_IsInventoryReady() )
		return

	if ( IsSocialPopupActive() )
		return

	var focus = GetFocus()

	if( focus == null )
		OpenPurchaseCharacterDialogFromLoadout( focus )

	OpenPurchaseCharacterDialogFromButton( focus )
}

void function OpenPurchaseCharacterDialogFromTop( var button )
{
	if (  !GRX_IsInventoryReady() )
		return

	if ( IsSocialPopupActive() )
		return

	PurchaseDialogConfig pdc

	if ( !Character_IsCharacterOwnedByPlayer(GetTopLevelCustomizeContext() ) )
	{
		pdc.flav = GetTopLevelCustomizeContext()
		pdc.quantity = 1
		PurchaseDialog( pdc )
	}
	else
	{
		pdc.offer = GRX_GetItemDedicatedStoreOffers( GetTopLevelCustomizeContext(), "character" )[0]
		PurchaseDialog( pdc )
	}
}

void function OpenPurchaseCharacterDialogFromButton( var button )
{
	if ( button in file.buttonToCharacter )
	{
		PurchaseDialogConfig pdc

		if ( !Character_IsCharacterOwnedByPlayer( file.buttonToCharacter[button] ) )
		{
			pdc.flav = file.buttonToCharacter[button]
			pdc.quantity = 1
			pdc.onPurchaseResultCallback = void function( bool wasPurchaseSuccessful ) : ( button ) {
                       
					CharacterClassButton_Init( button, file.buttonToCharacter[button] , false )
          
			}

			PurchaseDialog( pdc )
		}
		else
		{
			pdc.offer = GRX_GetItemDedicatedStoreOffers( file.buttonToCharacter[button], "character" )[0]
			PurchaseDialog( pdc )
		}
	}

	EmitUISound( "menu_accept" )
}

void function OpenPurchaseCharacterDialogFromLoadout( var button )
{
	PurchaseDialogConfig pdc

	if ( !file.presentedCharacter )
		return

	if ( !Character_IsCharacterOwnedByPlayer( expect ItemFlavor ( file.presentedCharacter ) ) )
	{
		pdc.flav = Loadout_Character().defaultItemFlavor
		pdc.quantity = 1
		pdc.onPurchaseResultCallback = void function( bool wasPurchaseSuccessful ) : ( button ) {
                      
				CharacterClassButton_Init( button, expect ItemFlavor ( file.presentedCharacter ) , false )
         
		}

		PurchaseDialog( pdc )
	}
	else
	{
		pdc.offer = GRX_GetItemDedicatedStoreOffers( expect ItemFlavor ( file.presentedCharacter ), "character" )[0]
		PurchaseDialog( pdc )
	}

	EmitUISound( "menu_accept" )
}

void function SetFeaturedCharacterFromButton( var button )
{
	if ( button in file.buttonToCharacter )
		SetFeaturedCharacter( file.buttonToCharacter[button] )
}

void function SetFeaturedCharacterFromFocus( var button )
{
	if ( IsSocialPopupActive() )
		return

	var focus = GetFocus()

	SetFeaturedCharacterFromButton( focus )
}


void function OpenFocusedCharacterSkillsDialog( var button )
{
	var focus = GetFocus()

	if ( file.buttons.contains( focus ) )
		OpenCharacterSkillsDialog( file.buttonToCharacter[focus] )
}

void function InitCharacterButtons()
{
	file.buttonToCharacter.clear()

	foreach ( button in file.buttons )
	{
		Hud_SetVisible( button, false )
		Hud_ReturnToBaseScaleOverTime( button, 0.0, INTERPOLATOR_DEACCEL )
	}

	foreach ( button in file.roleButtons_Assault )
	{
		Hud_SetVisible( button, false )
		Hud_ReturnToBaseScaleOverTime( button, 0.0, INTERPOLATOR_DEACCEL )
	}

	foreach ( button in file.roleButtons_Skirmisher )
	{
		Hud_SetVisible( button, false )
		Hud_ReturnToBaseScaleOverTime( button, 0.0, INTERPOLATOR_DEACCEL )
	}

	foreach ( button in file.roleButtons_Recon )
	{
		Hud_SetVisible( button, false )
		Hud_ReturnToBaseScaleOverTime( button, 0.0, INTERPOLATOR_DEACCEL )
	}

	foreach ( button in file.roleButtons_Defense )
	{
		Hud_SetVisible( button, false )
		Hud_ReturnToBaseScaleOverTime( button, 0.0, INTERPOLATOR_DEACCEL )
	}

	foreach ( button in file.roleButtons_Support )
	{
		Hud_SetVisible( button, false )
		Hud_ReturnToBaseScaleOverTime( button, 0.0, INTERPOLATOR_DEACCEL )
	}

	array<ItemFlavor> characters
	foreach ( ItemFlavor itemFlav in GetAllCharacters() )
	{
		bool isAvailable = IsItemFlavorUnlockedForLoadoutSlot( LocalClientEHI(), Loadout_Character(), itemFlav )
		if ( !isAvailable )
		{
			if ( !ItemFlavor_ShouldBeVisible( itemFlav, GetLocalClientPlayer() ) )
				continue
		}

		characters.append( itemFlav )
	}

	array<ItemFlavor> orderedCharacters = GetCharacterButtonOrder( characters, file.buttons.len() )
	array<var> characterButtons

                   
	int listGap = 90
	int buttonGap = 6
	int buttonWidth = 77

	UISize screenSize = GetScreenSize()

	float screenSizeXFrac =  screenSize.width / 1920.0
	float screenSizeYFrac =  screenSize.height / 1080.0

	float scaleFrac = min(screenSizeXFrac, screenSizeYFrac)

	int assaultLegendsAmount = GetCharactersByRole( orderedCharacters, eCharacterClassRole.OFFENSE ).len()
	int skirmisherLegendsAmount = GetCharactersByRole( orderedCharacters, eCharacterClassRole.SKIRMISHER ).len()
	int reconLegendsAmount = GetCharactersByRole( orderedCharacters, eCharacterClassRole.RECON ).len()
	int supportLegendsAmount = GetCharactersByRole( orderedCharacters, eCharacterClassRole.SUPPORT ).len()
	int defenderLegendsAmount = GetCharactersByRole( orderedCharacters, eCharacterClassRole.DEFENSE ).len()

	foreach ( index, character in GetCharactersByRole( orderedCharacters, eCharacterClassRole.OFFENSE ) )
	{
		var button = file.roleButtons_Assault[index]
		CharacterClassButton_Init( button, character )
		int offset = (buttonWidth * index) + (buttonGap * index)
		Hud_SetX( button, offset * scaleFrac)
	}

	int topListOffset1 = (assaultLegendsAmount * buttonWidth) + ( (assaultLegendsAmount - 1) * buttonGap) + listGap

	foreach ( index, character in GetCharactersByRole( orderedCharacters, eCharacterClassRole.SKIRMISHER ) )
	{
		var button = file.roleButtons_Skirmisher[index]
		CharacterClassButton_Init( button, character )
		int offset = topListOffset1 + (buttonWidth * index) + (buttonGap * index)
		Hud_SetX( button, offset * scaleFrac)
	}

	foreach ( index, character in GetCharactersByRole( orderedCharacters, eCharacterClassRole.RECON ) )
	{
		var button = file.roleButtons_Recon[index]
		CharacterClassButton_Init( button, character )
		int offset = (buttonWidth * index) + (buttonGap * index)
		Hud_SetX( button, offset * scaleFrac)
	}

	int botListOffset1 = (reconLegendsAmount * buttonWidth) + ( (reconLegendsAmount - 1) * buttonGap) + listGap

	foreach ( index, character in GetCharactersByRole( orderedCharacters, eCharacterClassRole.SUPPORT ) )
	{
		var button = file.roleButtons_Support[index]
		CharacterClassButton_Init( button, character )
		int offset = botListOffset1 + (buttonWidth * index) + (buttonGap * index)
		Hud_SetX( button, offset * scaleFrac)
	}

	int botListOffset2 = botListOffset1 + (supportLegendsAmount * buttonWidth) + ( (supportLegendsAmount - 1) * buttonGap) + listGap

	foreach ( index, character in GetCharactersByRole( orderedCharacters, eCharacterClassRole.DEFENSE ) )
	{
		var button = file.roleButtons_Defense[index]
		CharacterClassButton_Init( button, character )
		int offset = botListOffset2 + (buttonWidth * index) + (buttonGap * index)
		Hud_SetX( button, offset * scaleFrac)
	}

	int topListFullWidth = (assaultLegendsAmount * buttonWidth) + ( (assaultLegendsAmount - 1) * buttonGap) + listGap + (skirmisherLegendsAmount * buttonWidth) + ( (skirmisherLegendsAmount - 1) * buttonGap)
	int botListFullWidth = botListOffset2 + (defenderLegendsAmount * buttonWidth) + ( (defenderLegendsAmount - 1) * buttonGap)

	Hud_SetX( file.topLegendRowAnchor, -(topListFullWidth/2) * scaleFrac)
	Hud_SetX( file.botLegendRowAnchor, -(botListFullWidth/2) * scaleFrac)

	RuiSetFloat( file.assaultShelfRUI, "shelfWidth", float((assaultLegendsAmount * buttonWidth) + ( (assaultLegendsAmount - 1) * buttonGap)))
	RuiSetColorAlpha( file.assaultShelfRUI, "shelfColor", SrgbToLinear(CharacterClass_GetRoleColor(1)), 1.0)
	RuiSetString( file.assaultShelfRUI, "roleString", "#ROLE_ASSAULT" )
	RuiSetImage( file.assaultShelfRUI, "roleIcon", $"rui/menu/character_select/utility/role_offense" )

	RuiSetFloat( file.skirmisherShelfRUI, "shelfWidth", float((skirmisherLegendsAmount * buttonWidth) + ( (skirmisherLegendsAmount - 1) * buttonGap)))
	RuiSetColorAlpha( file.skirmisherShelfRUI, "shelfColor", SrgbToLinear(CharacterClass_GetRoleColor(2)), 1.0)
	RuiSetString( file.skirmisherShelfRUI, "roleString", "#ROLE_SKIRMISHER" )
	RuiSetImage( file.skirmisherShelfRUI, "roleIcon", $"rui/menu/character_select/utility/role_skirmisher" )

	RuiSetFloat( file.reconShelfRUI, "shelfWidth", float((reconLegendsAmount * buttonWidth) + ( (reconLegendsAmount - 1) * buttonGap)))
	RuiSetColorAlpha( file.reconShelfRUI, "shelfColor", SrgbToLinear(CharacterClass_GetRoleColor(3)), 1.0)
	RuiSetString( file.reconShelfRUI, "roleString", "#ROLE_RECON" )
	RuiSetImage( file.reconShelfRUI, "roleIcon", $"rui/menu/character_select/utility/role_recon" )

	RuiSetFloat( file.supportShelfRUI, "shelfWidth", float((supportLegendsAmount * buttonWidth) + ( (supportLegendsAmount - 1) * buttonGap)))
	RuiSetColorAlpha( file.supportShelfRUI, "shelfColor", SrgbToLinear(CharacterClass_GetRoleColor(5)), 1.0)
	RuiSetString( file.supportShelfRUI, "roleString", "#ROLE_SUPPORT" )
	RuiSetImage( file.supportShelfRUI, "roleIcon", $"rui/menu/character_select/utility/role_support" )

	RuiSetFloat( file.controllerShelfRUI, "shelfWidth", float((defenderLegendsAmount * buttonWidth) + ( (defenderLegendsAmount - 1) * buttonGap)))
	RuiSetColorAlpha( file.controllerShelfRUI, "shelfColor", SrgbToLinear(CharacterClass_GetRoleColor(4)), 1.0)
	RuiSetString( file.controllerShelfRUI, "roleString", "#ROLE_CONTROLLER" )
	RuiSetImage( file.controllerShelfRUI, "roleIcon", $"rui/menu/character_select/utility/role_defense" )

	Hud_SetX( file.assaultShelf, (-buttonWidth/2) * scaleFrac)
	Hud_SetX( file.skirmisherShelf, (topListOffset1 -buttonWidth/2) * scaleFrac)
	Hud_SetX( file.reconShelf, (-buttonWidth/2) * scaleFrac)
	Hud_SetX( file.supportShelf, (botListOffset1 -buttonWidth/2) * scaleFrac)
	Hud_SetX( file.controllerShelf, (botListOffset2 -buttonWidth/2) * scaleFrac)

	SetPerkLayoutNav ( orderedCharacters )
     
                                                  
  
                                  
                                           
                                   
  


                               
                                                        

                                     
      
}

void function SetPerkLayoutNav (array<ItemFlavor> orderedCharacters)
{
	int assaultLegendsAmount = GetCharactersByRole( orderedCharacters, eCharacterClassRole.OFFENSE ).len()
	int skirmisherLegendsAmount = GetCharactersByRole( orderedCharacters, eCharacterClassRole.SKIRMISHER ).len()
	int reconLegendsAmount = GetCharactersByRole( orderedCharacters, eCharacterClassRole.RECON ).len()
	int supportLegendsAmount = GetCharactersByRole( orderedCharacters, eCharacterClassRole.SUPPORT ).len()
	int defenderLegendsAmount = GetCharactersByRole( orderedCharacters, eCharacterClassRole.DEFENSE ).len()

	                        

	                                   
	foreach ( index, character in GetCharactersByRole( orderedCharacters, eCharacterClassRole.OFFENSE ) )
	{
		var button = file.roleButtons_Assault[index]

		            
		if (index < assaultLegendsAmount -1)
			Hud_SetNavRight(button, file.roleButtons_Assault[index + 1])
		else
			Hud_SetNavRight(button, file.roleButtons_Skirmisher[0])

		           
		if (index != 0)
			Hud_SetNavLeft(button, file.roleButtons_Assault[index - 1])

		          
		if ( index <= reconLegendsAmount - 1 )
			Hud_SetNavDown(button, file.roleButtons_Recon[0])
		else
			Hud_SetNavDown(button, file.roleButtons_Support[0])
	}

	                                      
	foreach ( index, character in GetCharactersByRole( orderedCharacters, eCharacterClassRole.SKIRMISHER ) )
	{
		var button = file.roleButtons_Skirmisher[index]

		            
		if (index < skirmisherLegendsAmount -1)
			Hud_SetNavRight(button, file.roleButtons_Skirmisher[index + 1])

		           
		if (index != 0)
			Hud_SetNavLeft(button, file.roleButtons_Skirmisher[index - 1])
		else
			Hud_SetNavLeft(button, file.roleButtons_Assault[assaultLegendsAmount -1])

		          
		if ( index >= skirmisherLegendsAmount - defenderLegendsAmount )
			Hud_SetNavDown(button, file.roleButtons_Defense[0])
		else
			Hud_SetNavDown(button, file.roleButtons_Support[supportLegendsAmount - 1])
	}

	                                 
	foreach ( index, character in GetCharactersByRole( orderedCharacters, eCharacterClassRole.RECON ) )
	{
		var button = file.roleButtons_Recon[index]
		         
		if (reconLegendsAmount <= assaultLegendsAmount)
			Hud_SetNavUp(button, file.roleButtons_Assault[0])
		else
			Hud_SetNavUp(button, file.roleButtons_Assault[assaultLegendsAmount - 1])

		            
		if (index < reconLegendsAmount -1)
			Hud_SetNavRight(button, file.roleButtons_Recon[index + 1])
		else
			Hud_SetNavRight(button, file.roleButtons_Support[0])

		           
		if (index != 0)
			Hud_SetNavLeft(button, file.roleButtons_Recon[index - 1])
	}

	                                   
	foreach ( index, character in GetCharactersByRole( orderedCharacters, eCharacterClassRole.SUPPORT ) )
	{
		var button = file.roleButtons_Support[index]
		        
		if (index <= (supportLegendsAmount-1)/2)
			Hud_SetNavUp(button, file.roleButtons_Assault[assaultLegendsAmount -1])
		else
			Hud_SetNavUp(button, file.roleButtons_Skirmisher[0])

		            
		if (index < supportLegendsAmount -1)
			Hud_SetNavRight(button, file.roleButtons_Support[index + 1])
		else
			Hud_SetNavRight(button, file.roleButtons_Defense[0])

		           
		if (index != 0)
			Hud_SetNavLeft(button, file.roleButtons_Support[index - 1])
		else
			Hud_SetNavLeft(button, file.roleButtons_Recon[reconLegendsAmount -1])
	}

	                                     
	foreach ( index, character in GetCharactersByRole( orderedCharacters, eCharacterClassRole.DEFENSE ) )
	{
		var button = file.roleButtons_Defense[index]
		         
		if (defenderLegendsAmount <= skirmisherLegendsAmount)
			Hud_SetNavUp(button, file.roleButtons_Skirmisher[skirmisherLegendsAmount - 1])
		else
			Hud_SetNavUp(button, file.roleButtons_Skirmisher[0])

		            
		if (index < defenderLegendsAmount -1)
			Hud_SetNavRight(button, file.roleButtons_Defense[index + 1])

		           
		if (index != 0)
			Hud_SetNavLeft(button, file.roleButtons_Defense[index - 1])
		else
			Hud_SetNavLeft(button, file.roleButtons_Support[supportLegendsAmount -1])
	}
}

void function UpdateFilteredButtonState()
{
	array<ItemFlavor> characters
	foreach ( ItemFlavor itemFlav in GetAllCharacters() )
	{
		bool isAvailable = IsItemFlavorUnlockedForLoadoutSlot( LocalClientEHI(), Loadout_Character(), itemFlav )
		if ( !isAvailable )
		{
			if ( !ItemFlavor_ShouldBeVisible( itemFlav, GetLocalClientPlayer() ) )
				continue
		}

		characters.append( itemFlav )
	}
	array<ItemFlavor> orderedCharacters = GetCharacterButtonOrder( characters, file.buttons.len() )

	foreach ( index, character in GetCharactersByRole( orderedCharacters, eCharacterClassRole.OFFENSE ) )
	{
		var button = file.roleButtons_Assault[index]
		var buttonRui = Hud_GetRui(button)
		bool isFiltered = (file.filterTabIndex != 1 && file.filterTabIndex != 0) ? true : false
		RuiSetBool(buttonRui, "isFiltered", isFiltered)
		RuiSetBool(file.assaultShelfRUI, "isFiltered", isFiltered)
	}

	foreach ( index, character in GetCharactersByRole( orderedCharacters, eCharacterClassRole.SKIRMISHER ) )
	{
		var button = file.roleButtons_Skirmisher[index]
		var buttonRui = Hud_GetRui(button)
		bool isFiltered = (file.filterTabIndex != 2 && file.filterTabIndex != 0) ? true : false
		RuiSetBool(buttonRui, "isFiltered", isFiltered)
		RuiSetBool(file.skirmisherShelfRUI, "isFiltered", isFiltered)
	}

	foreach ( index, character in GetCharactersByRole( orderedCharacters, eCharacterClassRole.RECON ) )
	{
		var button = file.roleButtons_Recon[index]
		var buttonRui = Hud_GetRui(button)
		bool isFiltered = (file.filterTabIndex != 3 && file.filterTabIndex != 0) ? true : false
		RuiSetBool(buttonRui, "isFiltered", isFiltered)
		RuiSetBool(file.reconShelfRUI, "isFiltered", isFiltered)
	}

	foreach ( index, character in GetCharactersByRole( orderedCharacters, eCharacterClassRole.SUPPORT ) )
	{
		var button = file.roleButtons_Support[index]
		var buttonRui = Hud_GetRui(button)
		bool isFiltered = (file.filterTabIndex != 4 && file.filterTabIndex != 0) ? true : false
		RuiSetBool(buttonRui, "isFiltered", isFiltered)
		RuiSetBool(file.supportShelfRUI, "isFiltered", isFiltered)
	}

	foreach ( index, character in GetCharactersByRole( orderedCharacters, eCharacterClassRole.DEFENSE ) )
	{
		var button = file.roleButtons_Defense[index]
		var buttonRui = Hud_GetRui(button)
		bool isFiltered = (file.filterTabIndex != 5 && file.filterTabIndex != 0) ? true : false
		RuiSetBool(buttonRui, "isFiltered", isFiltered)
		RuiSetBool(file.controllerShelfRUI, "isFiltered", isFiltered)
	}
}

void function CharacterButton_Init( var button, ItemFlavor character )
{
	SeasonStyleData seasonStyle = GetSeasonStyle()

	file.buttonToCharacter[button] <- character

	                                                                                                   
	                                                    
	bool isLocked   = IsItemFlavorUnlockedForLoadoutSlot( LocalClientEHI(), Loadout_Character(), character )
	bool isSelected = LoadoutSlot_GetItemFlavor( LocalClientEHI(), Loadout_Character() ) == character

	Hud_SetVisible( button, true )
	Hud_SetLocked( button, !IsItemFlavorUnlockedForLoadoutSlot( LocalClientEHI(), Loadout_Character(), character ) )
	Hud_SetSelected( button, isSelected )

	RuiSetColorAlpha( Hud_GetRui( button ), "seasonColor", SrgbToLinear( seasonStyle.seasonNewColor ), 1.0 )
	RuiSetString( Hud_GetRui( button ), "buttonText", Localize( ItemFlavor_GetLongName( character ) ).toupper() )
	RuiSetImage( Hud_GetRui( button ), "buttonImage", CharacterClass_GetGalleryPortrait( character ) )
	RuiSetImage( Hud_GetRui( button ), "bgImage", CharacterClass_GetGalleryPortraitBackground( character ) )
	RuiSetImage( Hud_GetRui( button ), "roleImage", CharacterClass_GetCharacterRoleImage( character ) )
	                                                                                     

             
                                                                    
  
                             
                                                                                                      
                                                                                                   
                                                                                                     
                                                                                                        
                                                                                                   
                                                                                                         

                                         
                        
   
                                                                  
   
  
      

	Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterButton[character], OnNewnessQueryChangedUpdateButton, button )
}

                   
void function CharacterClassButton_Init( var button, ItemFlavor character, bool addNewness = true)
{
	Hud_SetVisible( button, true )
	file.buttonToCharacter[button] <- character

	bool isSelected = LoadoutSlot_GetItemFlavor( LocalClientEHI(), Loadout_Character() ) == character

	Hud_SetVisible( button, true )
	Hud_SetLocked( button, !IsItemFlavorUnlockedForLoadoutSlot( LocalClientEHI(), Loadout_Character(), character ) )
	Hud_SetSelected( button, isSelected )

	                              
	var buttonRui = Hud_GetRui( button )
	RuiSetImage( buttonRui, "portraitImage", CharacterClass_GetGalleryPortrait( character ) )
	RuiSetImage( buttonRui, "portraitBackground", CharacterClass_GetGalleryRoleBackground( character ) )
	RuiSetString( buttonRui, "portraitName", Localize( ItemFlavor_GetLongName( character ) ) )
	RuiSetImage( buttonRui, "roleImage", CharacterClass_GetCharacterRoleImage( character ) )

	if( addNewness )
		Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterButton[character], OnNewnessQueryChangedUpdateButton, button )
}
      


void function CharactersPanel_OnShow( var panel )
{
	UI_SetPresentationType( ePresentationType.CHARACTER_SELECT )

	ItemFlavor character = LoadoutSlot_GetItemFlavor( LocalClientEHI(), Loadout_Character() )
	SetTopLevelCustomizeContext( character )
#if NX_PROG || PC_PROG_NX_UI
	file.presentedCharacter = null
#endif
	PresentCharacter( character )

	InitCharacterButtons()
	UpdateFilteredButtonState()

                   
	TabData tabData = GetTabDataForPanel( file.panel )

#if NX_PROG || PC_PROG_NX_UI
	foreach( tabIndex, tabDef in tabData.tabDefs )
	{
		if(tabData.activeTabIdx != tabIndex)
		{
			SetTabBaseWidth( tabDef, 80 )
		}
		else
		{
			SetTabBaseWidth( tabDef, 115 )
		}
	}
#endif

	if ( GetLastMenuNavDirection() == MENU_NAV_FORWARD )
	{
		ActivateTab( tabData, 0 )
		thread AnimateInSmallTabBar( tabData )
	}

      
}


void function CharactersPanel_OnHide( var panel )
{
	if ( NEWNESS_QUERIES.isValid )
		foreach ( var button, ItemFlavor character in file.buttonToCharacter )
			if ( character in NEWNESS_QUERIES.CharacterButton )                            
				Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterButton[character], OnNewnessQueryChangedUpdateButton, button )

	SetTopLevelCustomizeContext( null )
	RunMenuClientFunction( "ClearAllCharacterPreview" )

	file.buttonToCharacter.clear()
}


void function CharactersPanel_OnFocusChanged( var panel, var oldFocus, var newFocus )
{
	if ( !IsValid( panel ) )                  
		return

	if ( !newFocus || GetParentMenu( panel ) != GetActiveMenu() )
		return

	ItemFlavor character
	if ( file.buttons.contains( newFocus )
			||file.roleButtons_Assault.contains( GetFocus() )
			|| file.roleButtons_Skirmisher.contains( GetFocus() )
			|| file.roleButtons_Recon.contains( GetFocus() )
			|| file.roleButtons_Defense.contains( GetFocus() )
			|| file.roleButtons_Support.contains( GetFocus() ) )
	{
		character = file.buttonToCharacter[newFocus]
		if (newFocus != null)
		{
#if NX_PROG || PC_PROG_NX_UI
			if ( IsNxHandheldMode() )
			{
				Hud_SetZ( newFocus, 700 )
				Hud_ScaleOverTime( newFocus, 1.85, 1.85,0.1, INTERPOLATOR_DEACCEL )
			}
#else
			Hud_ScaleOverTime( newFocus, 1.15, 1.15,0.1, INTERPOLATOR_DEACCEL )
#endif
		}
	}
	else
		character = LoadoutSlot_GetItemFlavor( LocalClientEHI(), Loadout_Character() )

	                                                                                                          
	                                                           
	foreach ( button in file.buttons )
	{
		if( newFocus != button )
			Hud_ReturnToBaseScaleOverTime( button, 0.1, INTERPOLATOR_DEACCEL )
	}

	foreach ( button in file.roleButtons_Assault )
	{
		if( newFocus != button )
			Hud_ReturnToBaseScaleOverTime( button, 0.1, INTERPOLATOR_DEACCEL )
	}

	foreach ( button in file.roleButtons_Skirmisher )
	{
		if( newFocus != button )
			Hud_ReturnToBaseScaleOverTime( button, 0.1, INTERPOLATOR_DEACCEL )
	}

	foreach ( button in file.roleButtons_Recon )
	{
		if( newFocus != button )
			Hud_ReturnToBaseScaleOverTime( button, 0.1, INTERPOLATOR_DEACCEL )
	}

	foreach ( button in file.roleButtons_Defense )
	{
		if( newFocus != button )
			Hud_ReturnToBaseScaleOverTime( button, 0.1, INTERPOLATOR_DEACCEL )
	}

	foreach ( button in file.roleButtons_Support )
	{
		if( newFocus != button )
			Hud_ReturnToBaseScaleOverTime( button, 0.1, INTERPOLATOR_DEACCEL )
	}
	           

	if ( file.buttons.contains( oldFocus )
			||file.roleButtons_Assault.contains( oldFocus )
			|| file.roleButtons_Skirmisher.contains( oldFocus )
			|| file.roleButtons_Recon.contains( oldFocus )
			|| file.roleButtons_Defense.contains( oldFocus )
			|| file.roleButtons_Support.contains( oldFocus ) )
	{
		if (oldFocus != null)
		{
			Hud_ReturnToBaseScaleOverTime( oldFocus, 0.1, INTERPOLATOR_DEACCEL )
#if NX_PROG || PC_PROG_NX_UI
			if ( IsNxHandheldMode() )
			{
				Hud_SetZ( oldFocus, 1 )
			}
#endif
		}
	}

	UpdatePanelCharacterGiftFooter( file.giftFooter )
	UpdateFooterOptions()

	printt( ItemFlavor_GetCharacterRef( character ) )
	PresentCharacter( character )
}


void function CharacterButton_OnActivate( var button )
{
	ItemFlavor character = file.buttonToCharacter[button]
	SetTopLevelCustomizeContext( character )
	CustomizeCharacterMenu_SetCharacter( character )
	if ( Character_IsCharacterOwnedByPlayer( character ) )
		RequestSetItemFlavorLoadoutSlot( LocalClientEHI(), Loadout_Character(), character )                                                                                                                                                                                            
	Newness_IfNecessaryMarkItemFlavorAsNoLongerNewAndInformServer( character )
	EmitUISound( "UI_Menu_Legend_Select" )
	AdvanceMenu( GetMenu( "CustomizeCharacterMenu" ) )
}


void function CharacterButton_OnRightClick( var button )
{
	if ( IsSocialPopupActive() && IsControllerModeActive() )
		return

	OpenCharacterSkillsDialog( file.buttonToCharacter[button] )
}


void function CharacterButton_OnMiddleClick( var button )
{
	bool needsToBuy = false                                                      
	if ( button in file.buttonToCharacter )
	{
		ItemFlavor character = file.buttonToCharacter[ button ]
		needsToBuy = ( ItemFlavor_GetGRXMode( character ) == GRX_ITEMFLAVORMODE_REGULAR && GRX_IsItemOwnedByPlayer( character ) == false )
	}

	if ( needsToBuy )
		OpenPurchaseCharacterDialogFromButton( button )
	else
		SetFeaturedCharacterFromButton( button )
}


void function PresentCharacter( ItemFlavor character )
{
	if ( file.presentedCharacter == character )
		return

	ItemFlavor characterSkin = LoadoutSlot_GetItemFlavor( LocalClientEHI(), Loadout_CharacterSkin( character ) )
	RunClientScript( "UIToClient_PreviewCharacterSkin", ItemFlavor_GetGUID( characterSkin ), ItemFlavor_GetGUID( character ) )

                   
	            
	RuiSetString( file.lobbyClassPerkInfoRui, "classNameString", Localize( CharacterClass_GetRoleTitle (CharacterClass_GetRole( character )).toupper() ) )
	RuiSetString( file.lobbyClassPerkInfoRui, "classFootnoteString", Localize( CharacterClass_GetRoleSubtitle (CharacterClass_GetRole( character )).toupper() ) )
	RuiSetString( file.lobbyClassPerkInfoRui, "perkDescriptionString1", Localize( CharacterClass_GetRolePerkShortDescriptionAtIndex(CharacterClass_GetRole( character ), 0).toupper() ))
	RuiSetString( file.lobbyClassPerkInfoRui, "perkDescriptionString2", Localize( CharacterClass_GetRolePerkShortDescriptionAtIndex(CharacterClass_GetRole( character ), 1).toupper() ))
	RuiSetImage( file.lobbyClassPerkInfoRui, "classIconImage", CharacterClass_GetRoleIcon(CharacterClass_GetRole( character ) ) )
	RuiSetImage( file.lobbyClassPerkInfoRui, "perkIconImage1", CharacterClass_GetRolePerkIconAtIndex(CharacterClass_GetRole( character ), 0 ) )
	RuiSetImage( file.lobbyClassPerkInfoRui, "perkIconImage2", CharacterClass_GetRolePerkIconAtIndex(CharacterClass_GetRole( character ), 1 ) )
	RuiSetFloat( file.lobbyClassPerkInfoRui, "startTime", ClientTime() )
	RuiSetBool ( file.lobbyClassPerkInfoRui, "showPerkInfo", GetCurrentPlaylistVarBool( "charSelect_show_perk_info", true ) )
	RuiSetBool ( file.lobbyClassPerkInfoRui, "showLegendInfo", false )

	RuiSetString( file.characterSelectInfoRui, "nameString", Localize( ItemFlavor_GetLongName( character ) ).toupper() )
	RuiSetString( file.characterSelectInfoRui, "footnoteString", Localize( ItemFlavor_GetShortDescription( character ) ).toupper() )
	RuiSetFloat( file.characterSelectInfoRui, "startTime", ClientTime() )

	ItemFlavor ornull passiveAbility = null
	foreach ( ItemFlavor ability in CharacterClass_GetPassiveAbilities( character ) )
	{
		if ( CharacterAbility_ShouldShowDetails( ability ) )
		{
			                                  
			passiveAbility = ability
			break
		}
	}
	expect ItemFlavor( passiveAbility )

	RuiSetString( file.characterSelectInfoRui, "passiveNameString", Localize( ItemFlavor_GetLongName( passiveAbility ) ) )
	RuiSetString( file.characterSelectInfoRui, "tacticalNameString", Localize( ItemFlavor_GetLongName( CharacterClass_GetTacticalAbility( character ) ) ) )
	RuiSetString( file.characterSelectInfoRui, "ultimateNameString", Localize( ItemFlavor_GetLongName( CharacterClass_GetUltimateAbility( character ) ) ) )

	RuiSetImage( file.characterSelectInfoRui, "passiveIconImage", ItemFlavor_GetIcon( passiveAbility ) )
	RuiSetImage( file.characterSelectInfoRui, "tacticalIconImage", ItemFlavor_GetIcon( CharacterClass_GetTacticalAbility( character ) ) )
	RuiSetImage( file.characterSelectInfoRui, "ultimateIconImage", ItemFlavor_GetIcon( CharacterClass_GetUltimateAbility( character ) ) )
     
                                                                                                                   
                                                                                                                     
                                                                        
      

	file.presentedCharacter = character
}

void function JumpToCharactersTab()
{
	while ( GetActiveMenu() != GetMenu( "LobbyMenu" ) )
		CloseActiveMenu()

	TabData lobbyTabData = GetTabDataForPanel( GetMenu( "LobbyMenu" ) )
	ActivateTab( lobbyTabData, Tab_GetTabIndexByBodyName( lobbyTabData, "CharactersPanel" ) )
}

void function JumpToCharacterCustomize( ItemFlavor character )
{
	JumpToCharactersTab()

	SetTopLevelCustomizeContext( character )
	CustomizeCharacterMenu_SetCharacter( character )
	if ( Character_IsCharacterOwnedByPlayer( character ) )
		RequestSetItemFlavorLoadoutSlot( LocalClientEHI(), Loadout_Character(), character )                                                                                                                                                                                            
	Newness_IfNecessaryMarkItemFlavorAsNoLongerNewAndInformServer( character )
	EmitUISound( "UI_Menu_Legend_Select" )
	AdvanceMenu( GetMenu( "CustomizeCharacterMenu" ) )
}

void function UpdatePanelCharacterGiftFooter( InputDef footer )
{
	var focus = GetFocus()

	if ( focus in file.buttonToCharacter )
	{
		bool alwaysOwnsChar = ( ItemFlavor_GetGRXMode( file.buttonToCharacter[focus] ) == eItemFlavorGRXMode.NONE )

		if ( alwaysOwnsChar )
		{
			footer.gamepadLabel = ""
			footer.mouseLabel = ""
			footer.activateFunc = null
			return
		}

		if ( IsControllerModeActive() )
		{
			footer.input = BUTTON_BACK
		}
		else
		{
			footer.input = KEY_H
		}

		if ( Character_IsCharacterOwnedByPlayer( file.buttonToCharacter[focus] ) == false )
		{
			footer.gamepadLabel = Localize( "#BACK_BUTTON_UNLOCK" )
			footer.mouseLabel = Localize( "#BACK_BUTTON_UNLOCK" )
			footer.activateFunc = OpenPurchaseCharacterDialogFromFocus
		}
		else
		{
			footer.gamepadLabel = Localize( "#BACK_BUTTON_GIFT" )
			footer.mouseLabel = Localize( "#BACK_BUTTON_GIFT" )
			footer.activateFunc = OpenPurchaseCharacterDialogFromFocus
		}
	}
	else
	{
		footer.gamepadLabel = ""
		footer.mouseLabel = ""
		footer.activateFunc = null
	}
}