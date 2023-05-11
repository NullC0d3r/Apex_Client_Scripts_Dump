                    
global function InitBattlepassMilestoneMenu
global function IsBattlepassMilestoneEnabled
global function IsBattlepassMilestoneMenuOpened

struct {
	var menu

	var awardHeader
	var awardPanel
	var awardHeaderText
	var awardDescText

	var purchaseButton
	var continueButton
	var premiumToggleButton
	var bundleToggleButton

	var rep2DImage

	bool isOpened = false
	bool isShowingBundle = false
	bool isBundleDisabled = false
	bool isShowingAltImage = false
	bool hasPurchasedBattlepass = false

	array<BattlePassReward> displayRewards = []
	table<var, BattlePassReward> buttonToItem
	array<int> rewardsClicked
	array<int> tierRepLevels
	array<int> bundleRepLevels

	array<int> milestones
	int milestoneIndex
	int currentBPLevel = 0
}file

void function InitBattlepassMilestoneMenu( var newMenuArg )
{
	file.menu = newMenuArg

	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, BattlepassMilestoneMenu_OnOpen )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_CLOSE, BattlepassMilestoneMenu_OnClose )

	file.awardHeader     = Hud_GetChild( file.menu, "Header" )
	file.awardPanel      = Hud_GetChild( file.menu, "AwardsList" )
	file.awardHeaderText = Hud_GetChild( file.menu, "AwardsHeaderText" )
	file.awardDescText   = Hud_GetChild( file.menu, "AwardsDescText" )
	file.rep2DImage      = Hud_GetChild( file.menu, "Rep2DImage" )

	file.purchaseButton      = Hud_GetChild( file.menu, "PassPurchaseButton" )
	file.continueButton      = Hud_GetChild( file.menu, "ContinueButton" )
	file.premiumToggleButton = Hud_GetChild( file.menu, "LeftToggleButton" )
	file.bundleToggleButton  = Hud_GetChild( file.menu, "RightToggleButton" )

	AddButtonEventHandler( file.purchaseButton, UIE_CLICK, PurchaseButton_OnClick )
	AddButtonEventHandler( file.continueButton, UIE_CLICK, ContinueButton_OnClick )
	AddButtonEventHandler( file.bundleToggleButton, UIE_GET_FOCUS, BundleButton_OnFocused )
	AddButtonEventHandler( file.bundleToggleButton, UIE_CLICK, BundleButton_OnClick )
	AddButtonEventHandler( file.premiumToggleButton, UIE_GET_FOCUS, PremiumButton_OnFocused )
	AddButtonEventHandler( file.premiumToggleButton, UIE_CLICK, PremiumButton_OnClick )
}

void function BattlepassMilestoneMenu_OnOpen()
{
	Lobby_AdjustScreenFrameToMaxSize( Hud_GetChild( file.menu, "ScreenFrame" ), true )

	ItemFlavor ornull activeBattlePass = GetActiveBattlePass()
	if ( activeBattlePass == null || !GRX_IsInventoryReady() )
		return

	expect ItemFlavor( activeBattlePass )

	HudElem_SetRuiArg( file.awardHeader, "titleText", "#BP_MILESTONE_HEADER_TITLE" )
	HudElem_SetRuiArg( file.awardHeader, "descText", "#BP_MILESTONE_HEADER_DESC" )
	HudElem_SetRuiArg( file.awardHeaderText, "textString", "#BP_MILESTONE_AWARDS_HEADER" )
	HudElem_SetRuiArg( file.awardHeaderText, "isTitleFont", true )
	HudElem_SetRuiArg( file.awardDescText, "textString", "#BP_MILESTONE_AWARDS_DESC_PREMIUM" )

	HudElem_SetRuiArg( file.purchaseButton, "offerTitle", "#BP_MILESTONE_PURCHASE_BUTTON" )
	HudElem_SetRuiArg( file.purchaseButton, "offerDesc", "#BP_MILESTONE_TOGGLE_PREMIUM" )
	HudElem_SetRuiArg( file.purchaseButton, "price", " %$rui/menu/common/currency_premium%" + " 9999" )

	HudElem_SetRuiArg( file.continueButton, "buttonText", "#B_BUTTON_CLOSE" )
	HudElem_SetRuiArg( file.continueButton, "processingState", 1 )

	HudElem_SetRuiArg( file.premiumToggleButton, "buttonText", "#BP_MILESTONE_TOGGLE_PREMIUM" )
	HudElem_SetRuiArg( file.premiumToggleButton, "isSelected", true )

	HudElem_SetRuiArg( file.bundleToggleButton, "buttonText", "#BP_MILESTONE_TOGGLE_BUNDLE" )
	HudElem_SetRuiArg( file.bundleToggleButton, "isSelected", false )

	HudElem_SetRuiArg( Hud_GetChild( file.menu, "LeftToggleIndicator" ), "textString", "#BP_MILESTONE_TOGGLE_INDICATOR_LEFT" )
	HudElem_SetRuiArg( Hud_GetChild( file.menu, "RightToggleIndicator" ), "textString", "#BP_MILESTONE_TOGGLE_INDICATOR_RIGHT" )

	HudElem_SetRuiArg( file.rep2DImage, "isShowingBundleImage", false )
	RuiSetImage( Hud_GetRui( file.rep2DImage ), "tierRepImage", GetGlobalSettingsAsset( ItemFlavor_GetAsset( activeBattlePass ), "milestoneTierRepImage" ) )
	RuiSetImage( Hud_GetRui( file.rep2DImage ), "bundleRepImage", GetGlobalSettingsAsset( ItemFlavor_GetAsset( activeBattlePass ), "milestoneBundleRepImage" ) )

	file.tierRepLevels = GetMilestoneRepImageLevelArray( activeBattlePass, "milestoneTierRepLevels", "tierRepLevels" )
	file.bundleRepLevels = GetMilestoneRepImageLevelArray( activeBattlePass, "milestoneBundleRepLevels", "bundleRepLevels" )

	RegisterButtonPressedCallback( BUTTON_SHOULDER_LEFT, PremiumButton_OnClick )
	RegisterButtonPressedCallback( BUTTON_SHOULDER_RIGHT, BundleButton_OnClick )

	file.isOpened = true
	file.isShowingBundle = false
	file.milestoneIndex  = 0

	var dataTable   = BattlePass_GetMilestoneDatatable( activeBattlePass )
	int numRows     = GetDataTableRowCount( dataTable )
	int levelColumn = GetDataTableColumnByName( dataTable, "milestone_level" )

	entity player 		  = GetLocalClientPlayer()
	int currentXPProgress = GetPlayerBattlePassXPProgress( ToEHI( player ), activeBattlePass, false )
	file.currentBPLevel   = GetBattlePassLevelForXP( activeBattlePass, currentXPProgress )

	for ( int i = 0; i < numRows; i++ )
	{
		file.milestones.append( GetDataTableInt( dataTable, i, levelColumn ) - 1 )                               

		if ( file.milestones[ i ] <= file.currentBPLevel )
			file.milestoneIndex = i
	}

	UI_SetPresentationType( ePresentationType.BATTLE_PASS )
	BattlepassMilestone_UpdatePurchaseButtons()
	BattlepassMilestoneMenu_Update( file.currentBPLevel )
}

void function BattlepassMilestoneMenu_Update( int level )
{
	const int BUTTON_OFFSET = 24
	const int BUNDLE_LEVELS = 25
	const int BUNDLE_PURCHASE_LIMIT = 75

	int targetLevel = level

	if ( targetLevel > BUNDLE_PURCHASE_LIMIT )
	{
		file.isBundleDisabled = true

		ToolTipData toolTip
		toolTip.titleText = "#BATTLE_PASS_BUNDLE_PROTECT"
		toolTip.descText = "#BP_MILESTONE_BUNDLE_PROTECT_DESC"
		Hud_SetToolTipData( file.bundleToggleButton, toolTip )
	}
	else
	{
		file.isBundleDisabled = false

		Hud_ClearToolTipData( file.bundleToggleButton )
	}

	HudElem_SetRuiArg( file.bundleToggleButton, "isBundleDisabled", file.isBundleDisabled )
	Hud_SetLocked( file.bundleToggleButton, file.isBundleDisabled )

	if ( file.isShowingBundle )
		targetLevel += BUNDLE_LEVELS

	HudElem_SetRuiArg( file.awardHeader, "level", level + 1 )

	entity player = GetLocalClientPlayer()
	ItemFlavor activeBattlePass = expect ItemFlavor( GetActiveBattlePass() )
	file.displayRewards = GetBattlePassPremiumRewards( activeBattlePass, targetLevel, player )

	file.displayRewards.sort( SortByQuality )
	AddUpStackableRewards( file.displayRewards )

	var scrollPanel = Hud_GetChild( file.awardPanel, "ScrollPanel" )
	foreach ( button, _ in file.buttonToItem )
	{
		Hud_RemoveEventHandler( button, UIE_GET_FOCUS, PassAwardButton_OnGetFocus )
		Hud_RemoveEventHandler( button, UIE_LOSE_FOCUS, PassAwardButton_OnLoseFocus )
	}
	file.buttonToItem.clear()
	file.rewardsClicked.clear()

	int numAwards = file.displayRewards.len()
	int numButtons = numAwards
	bool showButtons = true

	file.rewardsClicked.resize( numButtons, 0 )

	if ( !showButtons )
	{
		numButtons = 0
		PresentItem( file.displayRewards[0].flav, file.displayRewards[0].level )
	}

	Hud_InitGridButtonsDetailed( file.awardPanel, numButtons, 1, maxint( 1, minint( numButtons, 5 ) ) )
	Hud_SetHeight( file.awardPanel, Hud_GetHeight( file.awardPanel ) * 3 + BUTTON_OFFSET )

	for ( int index = 0; index < numButtons; index++ )
	{
		var awardButton = Hud_GetChild( scrollPanel, "GridButton" + index )

		BattlePassReward bpReward = file.displayRewards[index]
		file.buttonToItem[awardButton] <- bpReward

		HudElem_SetRuiArg( awardButton, "isOwned", false )
		HudElem_SetRuiArg( awardButton, "isPremium", bpReward.isPremium )

		int rarity = ItemFlavor_HasQuality( bpReward.flav ) ? ItemFlavor_GetQuality( bpReward.flav ) : 0
		HudElem_SetRuiArg( awardButton, "itemCountString", "" )
		if ( bpReward.quantity > 1 || ItemFlavor_GetType( bpReward.flav ) == eItemType.account_currency )
		{
			rarity = 0
			HudElem_SetRuiArg( awardButton, "itemCountString", FormatAndLocalizeNumber( "1", float( bpReward.quantity ), true ) )
		}
		HudElem_SetRuiArg( awardButton, "rarity", rarity )
		RuiSetImage( Hud_GetRui( awardButton ), "buttonImage", CustomizeMenu_GetRewardButtonImage( bpReward.flav ) )

		bool isRewardLootBox = (ItemFlavor_GetType( bpReward.flav ) == eItemType.account_pack)
		HudElem_SetRuiArg( awardButton, "isLootBox", isRewardLootBox )

		BattlePass_PopulateRewardButton( bpReward, awardButton, false, false )

		Hud_AddEventHandler( awardButton, UIE_GET_FOCUS, PassAwardButton_OnGetFocus )
		Hud_AddEventHandler( awardButton, UIE_LOSE_FOCUS, PassAwardButton_OnLoseFocus )

		ToolTipData toolTip
		toolTip.titleText = GetBattlePassRewardHeaderText( bpReward )
		toolTip.descText = GetBattlePassRewardItemName( bpReward )
		toolTip.tooltipFlags = eToolTipFlag.SOLID
		toolTip.rarity = ItemFlavor_GetQuality( bpReward.flav )
		Hud_SetToolTipData( awardButton, toolTip )

		if ( index == 0 )
			PassAwardButton_OnLoseFocus( awardButton )
	}

	HudElem_SetRuiArg( file.rep2DImage, "isShowingBundleImage", file.isShowingBundle )

	if ( file.isShowingBundle )
	{
		for( int i = 0; i < file.bundleRepLevels.len(); i++ )
		{
			HudElem_SetRuiArg( file.rep2DImage, format( "unlockLevel%d", i ), file.bundleRepLevels[i].tostring() )

			if ( targetLevel >= file.bundleRepLevels[i] - 1 )
			{
				HudElem_SetRuiArg( file.rep2DImage, format ( "isUnlocked%d", i ), true )
			}
			else
			{
				HudElem_SetRuiArg( file.rep2DImage, format ( "isUnlocked%d", i ), false )
			}
		}
	}
	else
	{
		for( int i = 0; i < file.tierRepLevels.len(); i++ )
		{
			HudElem_SetRuiArg( file.rep2DImage, format( "unlockLevel%d", i ), file.tierRepLevels[i].tostring() )

			if ( targetLevel >= file.tierRepLevels[i] - 1 )
			{
				HudElem_SetRuiArg( file.rep2DImage, format ( "isUnlocked%d", i ), true )
			}
			else
			{
				HudElem_SetRuiArg( file.rep2DImage, format ( "isUnlocked%d", i ), false )
			}
		}
	}
}

void function BattlepassMilestoneMenu_OnClose()
{
	DeregisterButtonPressedCallback( BUTTON_SHOULDER_LEFT, PremiumButton_OnClick )
	DeregisterButtonPressedCallback( BUTTON_SHOULDER_RIGHT, BundleButton_OnClick )

	foreach ( button, _ in file.buttonToItem )
	{
		Hud_RemoveEventHandler( button, UIE_GET_FOCUS, PassAwardButton_OnGetFocus )
		Hud_RemoveEventHandler( button, UIE_LOSE_FOCUS, PassAwardButton_OnLoseFocus )
	}

	ClearAwardsTooltips()
	RunClientScript( "ClearBattlePassItem" )

	array<string> rewardStringsForPIN = GetRewardStringsForPIN();

	PIN_BattlepassMilestonePageView (
		GetLastMenuIDForPIN(),
		UITime() - uiGlobal.menuData[file.menu].enterTime,
		file.milestones[file.milestoneIndex] + 1,
		file.hasPurchasedBattlepass,
		rewardStringsForPIN
	)

	file.isOpened = false
	file.displayRewards = []
	file.rewardsClicked = []
	file.buttonToItem.clear()
	file.milestones.clear()

	if ( file.hasPurchasedBattlepass )
	{
		JumpToSeasonTab( "PassPanel" )
	}
}

void function BattlepassMilestoneMenu_OnUpdate()
{

}

void function PassAwardButton_OnGetFocus( var button )
{
	ItemFlavor item = file.buttonToItem[button].flav
	int level       = file.buttonToItem[button].level

	HudElem_SetRuiArg( file.rep2DImage, "isVisible", false )

	file.rewardsClicked[file.displayRewards.find( file.buttonToItem[button] )]++

	PresentItem( item, level )
}

void function PassAwardButton_OnLoseFocus( var button )
{
	HudElem_SetRuiArg( file.rep2DImage, "isVisible", true )

	RunClientScript( "ClearBattlePassItem" )
}

void function PresentItem( ItemFlavor item, int level )
{
	if ( ItemFlavor_GetType( item ) == eItemType.character )
	{
		ItemFlavor overrideSkin = GetDefaultItemFlavorForLoadoutSlot( EHI_null, Loadout_CharacterSkin( item ) )
		item = overrideSkin
	}

	RunClientScript( "UIToClient_ItemPresentation", ItemFlavor_GetGUID( item ), level, 0.95, Battlepass_ShouldShowLow( item ), Hud_GetChild( file.menu, "LoadscreenImage" ), true, "battlepass_right_ref", false, false, true )
}

void function BattlepassMilestone_UpdatePurchaseButtons()
{
	entity player = GetLocalClientPlayer()
	ItemFlavor ornull activeBattlePass = GetPlayerActiveBattlePass( ToEHI( player ) )

	if ( activeBattlePass == null || !GRX_IsInventoryReady() )
	{
		Hud_SetEnabled( file.purchaseButton, false )
		Hud_SetVisible( file.purchaseButton, false )
		return
	}

	expect ItemFlavor( activeBattlePass )

	Hud_SetLocked( file.purchaseButton, DoesPlayerOwnBattlePass( player, activeBattlePass ) )

	if ( !file.isShowingBundle )
	{
		HudElem_SetRuiArg( file.awardDescText, "textString", "#BP_MILESTONE_AWARDS_DESC_PREMIUM" )
		HudElem_SetRuiArg( file.premiumToggleButton, "isSelected", true )
		HudElem_SetRuiArg( file.bundleToggleButton, "isSelected", false )

		ItemFlavor basicPurchaseFlav = BattlePass_GetBasicPurchasePack ( activeBattlePass )

		array<GRXScriptOffer> basicPurchaseOffers = GRX_GetItemDedicatedStoreOffers( basicPurchaseFlav, "battlepass" )
		GRXScriptOffer basicPurchaseOffer = basicPurchaseOffers[0]

		if ( basicPurchaseOffers.len() == 1 )
		{
			HudElem_SetRuiArg( file.purchaseButton, "offerDesc", "#BP_MILESTONE_TOGGLE_PREMIUM" )
			HudElem_SetRuiArg( file.purchaseButton, "price", " " + GRX_GetFormattedPrice ( basicPurchaseOffer.prices[0] ) )
		}
		else
		{
			Warning( "Expected 1 offer for basic pack of '%s'", string(ItemFlavor_GetAsset( activeBattlePass )) )
		}
	}
	else
	{
		HudElem_SetRuiArg( file.awardDescText, "textString", "#BP_MILESTONE_AWARDS_DESC_BUNDLE" )
		HudElem_SetRuiArg( file.premiumToggleButton, "isSelected", false )
		HudElem_SetRuiArg( file.bundleToggleButton, "isSelected", true )

		ItemFlavor bundlePurchaseFlav = BattlePass_GetBundlePurchasePack ( activeBattlePass )

		array<GRXScriptOffer> bundlePurchaseOffers = GRX_GetItemDedicatedStoreOffers( bundlePurchaseFlav, "battlepass" )
		GRXScriptOffer bundlePurchaseOffer = bundlePurchaseOffers[0]

		if ( bundlePurchaseOffers.len() == 1 )
		{
			HudElem_SetRuiArg( file.purchaseButton, "offerDesc", "#BP_MILESTONE_TOGGLE_BUNDLE" )
			HudElem_SetRuiArg( file.purchaseButton, "price", " " + GRX_GetFormattedPrice ( bundlePurchaseOffer.prices[0] ) )
		}
		else
		{
			Warning( "Expected 1 offer for basic pack of '%s'", string(ItemFlavor_GetAsset( activeBattlePass )) )
		}
	}
}

void function PremiumButton_OnClick( var button )
{
	if ( !file.isShowingBundle || !GRX_IsInventoryReady() )
		return

	ClearAwardsTooltips()
	file.isShowingBundle = false
	BattlepassMilestone_UpdatePurchaseButtons()
	BattlepassMilestoneMenu_Update( file.currentBPLevel )
}

void function PremiumButton_OnFocused( var button )
{
	HudElem_SetRuiArg( file.premiumToggleButton, "isFocused", true )
}

void function BundleButton_OnClick( var button )
{
	if ( file.isShowingBundle || !GRX_IsInventoryReady() )
		return

	if ( file.isBundleDisabled )
	{
		EmitUISound( "menu_deny" )
		return
	}

	file.isShowingBundle = true

	ClearAwardsTooltips()
	BattlepassMilestone_UpdatePurchaseButtons()
	BattlepassMilestoneMenu_Update( file.currentBPLevel )
}

void function BundleButton_OnFocused( var button )
{
	if ( file.isBundleDisabled )
		return

	HudElem_SetRuiArg( file.bundleToggleButton, "isFocused", true )
}

void function ContinueButton_OnClick( var button )
{
	CloseActiveMenu()

	if ( file.hasPurchasedBattlepass )
	{
		JumpToSeasonTab( "PassPanel" )
	}
}

void function PurchaseButton_OnClick( var button )
{
	if ( Hud_IsLocked( button ) )
	{
		EmitUISound( "menu_deny" )
		return
	}

	ItemFlavor ornull activeBattlePass = GetPlayerActiveBattlePass( ToEHI( GetLocalClientPlayer() ) )
	if ( activeBattlePass == null || !GRX_IsInventoryReady() )
		return

	expect ItemFlavor( activeBattlePass )

	ItemFlavor purchaseFlav

	if ( file.isShowingBundle )
		purchaseFlav = BattlePass_GetBundlePurchasePack( activeBattlePass )
	else
		purchaseFlav = BattlePass_GetBasicPurchasePack( activeBattlePass )

	if ( !GRX_GetItemPurchasabilityInfo( purchaseFlav ).isPurchasableAtAll )
		return

	GRXScriptOffer purchaseOffer = GRX_GetItemDedicatedStoreOffers( purchaseFlav, "battlepass" )[0]

	PurchaseDialogConfig pdc
	pdc.offer = purchaseOffer
	pdc.quantity = 1
	pdc.onPurchaseResultCallback = OnBattlePassPurchaseResults
	pdc.purchaseSoundOverride = "UI_Menu_BattlePass_Purchase"
	PurchaseDialog( pdc )
}

void function OnBattlePassPurchaseResults( bool wasSuccessful )
{
	if ( wasSuccessful )
	{
		file.hasPurchasedBattlepass = true
		Hud_SetLocked( file.purchaseButton, file.hasPurchasedBattlepass )
	}

	PIN_BattlepassPurchase(
		GetActiveMenuName(),
		file.isShowingBundle
	)
}

array<string> function GetRewardStringsForPIN( )
{
	const int MAX_REWARD_COUNT_FOR_PIN = 10

	array<string> result;

	for( int i = 0; i < file.rewardsClicked.len(); i++ )
	{
		if ( file.rewardsClicked[i] != 0 )
		{
			result.append( format( "%s:%d", ItemFlavor_GetHumanReadableRefForPIN_Slow( file.displayRewards[i].flav ), file.rewardsClicked[i] ) )
		}
	}

	result.sort( SortByClickedCount )

	if ( result.len() > MAX_REWARD_COUNT_FOR_PIN )
	{
		result.resize( MAX_REWARD_COUNT_FOR_PIN )
	}

	return result
}

#if UI
void function AddUpStackableRewards( array<BattlePassReward> rewards )
{
	int prevType = eItemType.INVALID

	for( int i = 0; i < rewards.len(); i++ )
	{
		int currType = ItemFlavor_GetType( rewards[i].flav )

		if ( currType == prevType )
		{
			if ( currType == eItemType.account_currency )
			{
				int quantityToAdd = 0;

				for( int j = i; j < rewards.len(); )
				{
					if ( ItemFlavor_GetType( rewards[j].flav ) != prevType )
						break

					quantityToAdd += rewards[j].quantity
					rewards.remove( j )
				}

				rewards[i - 1].quantity += quantityToAdd
			}
		}

		prevType = currType
	}
}
#endif

#if UI
int function SortByQuality( BattlePassReward a, BattlePassReward b )
{
	int a_quality = ItemFlavor_HasQuality( a.flav ) ? ItemFlavor_GetQuality( a.flav ) : 0
	int b_quality = ItemFlavor_HasQuality( b.flav ) ? ItemFlavor_GetQuality( b.flav ) : 0

	if ( a_quality < b_quality )
	{
		return 1
	}
	else if ( a_quality > b_quality )
	{
		return -1
	}
	else
	{
		int a_type = ItemFlavor_GetType( a.flav )
		int b_type = ItemFlavor_GetType( b.flav )

		if ( a_type == eItemType.account_currency )
		{
			return -1
		}
		else if ( b_type == eItemType.account_currency )
		{
			return 1
		}

		if ( a_type == eItemType.weapon_skin && WeaponSkin_DoesReactToKills ( a.flav ) )
		{
			return -1
		}
		else if ( b_type == eItemType.weapon_skin && WeaponSkin_DoesReactToKills ( b.flav ) )
		{
			return 1
		}

		                                                                                           
		if ( a_type == eItemType.skydive_emote || a_type == eItemType.skydive_trail )
		{
			a_type = eItemType.character_execution
		}

		if ( b_type == eItemType.skydive_emote || b_type == eItemType.skydive_trail )
		{
			b_type = eItemType.character_execution
		}

		if ( a_type < eItemType.character && b_type >= eItemType.character )
		{
			return 1
		}
		else if ( a_type >= eItemType.character && b_type < eItemType.character )
		{
			return -1
		}
		else
		{
			if ( a_type > b_type )
			{
				return 1
			}
			else if ( a_type < b_type )
			{
				return -1
			}
		}
	}

	return 0
}
#endif

#if UI
int function SortByClickedCount( string a, string b )
{
	int a_clicked = a.slice( a.find (":", 0) + 1, a.len() ).tointeger()
	int b_clicked = b.slice( b.find (":", 0) + 1, b.len() ).tointeger()

	if ( a_clicked < b_clicked )
		return 1
	else if ( a_clicked > b_clicked )
		return -1

	return 0
}
#endif

#if UI
void function ClearAwardsTooltips()
{
	var scrollPanel = Hud_GetChild( file.awardPanel, "ScrollPanel" )

	for ( int index = 0; index < file.displayRewards.len(); index++)
	{
		Hud_ClearToolTipData( Hud_GetChild( scrollPanel, "GridButton" + index ) )
	}
}
#endif

#if UI
bool function IsBattlepassMilestoneEnabled()
{
	return GetConVarBool( "lobby_battlepass_milestone_enabled" )
}
#endif

#if UI || CLIENT
bool function IsBattlepassMilestoneMenuOpened()
{
	return file.isOpened
}
#endif

                          