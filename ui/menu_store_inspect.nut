global function InitStoreInspectMenu
global function StoreInspectMenu_SetStoreOfferData
global function StoreInspectMenu_IsItemPresentationSupported
global function StoreInspectMenu_AttemptOpenWithOffer
global function AddItemToFakeOffer
global function StoreInspectMenu_UpdatePrices
global function StoreInspectMenu_UpdatePurchaseButton
global function StoreInspectMenu_EquipOwnedItem

#if DEV
global function DEV_PrintInspectedOffer
global function DEV_DisplayAllInspectElements
global function DEV_AddFakeItemToOffer
global function DEV_AddFakeItemsToOffer
#endif

struct
{
	var menu
	var inspectPanel
	var mouseCaptureElem
	var purchaseLimit
	var pageHeader
	var itemGrid
	var itemInfo
	var giftingMenu
} file

global struct StoreInspectUIData
{
	var discountInfo
	var purchaseButton
	var giftablePurchaseButton
	var giftButton
}

global struct StoreInspectOfferData
{
	string originalPriceStr
	string displayedPriceStr
	string purchaseText
	string purchaseDescText
	string giftText
	string giftDescText
	string giftTooltipTitleText
	string giftTooltipDescText
	int discountPct
	int itemCount
	int originalPrice
	int displayedPrice
	int purchaseLimit
	bool isOwnedItemEquippable
	bool isPurchasable
	bool canAfford
	bool isDualCurrency

	array<GRXScriptOffer> currentOffers
	array<ItemFlavor> itemFlavors
	array<string> exclusiveItems
}

StoreInspectOfferData s_inspectOffers
StoreInspectUIData s_inspectUIData

const int ITEM_GRID_ROWS = 4
const int ITEM_GRID_COLUMNS = 6

void function InitStoreInspectMenu( var newMenuArg )
{
	var menu = GetMenu( "StoreInspectMenu" )
	file.menu = menu

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, StoreInspectMenu_OnOpen )
	AddMenuEventHandler( menu, eUIEvent.MENU_SHOW, StoreInspectMenu_OnShow )
	AddMenuEventHandler( menu, eUIEvent.MENU_GET_TOP_LEVEL,StoreInspectMenu_OnTopLevel )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, StoreInspectMenu_OnClose )
	AddMenuEventHandler( menu, eUIEvent.MENU_HIDE, StoreInspectMenu_OnHide )

	file.inspectPanel = Hud_GetChild( menu, "InspectPanel" )
	file.mouseCaptureElem = Hud_GetChild( menu, "ModelRotateMouseCapture" )
	file.itemInfo = Hud_GetChild( file.inspectPanel, "IndividualItemInfo" )
	file.pageHeader = Hud_GetChild( file.inspectPanel, "InspectHeader" )
	file.itemGrid = Hud_GetChild( file.inspectPanel, "ItemGridPanel" )
	file.purchaseLimit = Hud_GetChild( file.inspectPanel, "PurchaseLimit" )

	s_inspectUIData.discountInfo           = Hud_GetChild( file.inspectPanel, "DiscountInfo" )
	s_inspectUIData.purchaseButton         = Hud_GetChild( file.inspectPanel, "PurchaseOfferButton" )

	s_inspectUIData.giftablePurchaseButton = Hud_GetChild( file.inspectPanel, "GiftablePurchaseOfferButton" )
	s_inspectUIData.giftButton             = Hud_GetChild( file.inspectPanel, "GiftOfferButton" )
	file.giftingMenu = GetMenu( "GiftingFriendDialog" )

	AddButtonEventHandler( s_inspectUIData.purchaseButton, UIE_CLICK, PurchaseOfferButton_OnClick )
	AddButtonEventHandler( s_inspectUIData.giftablePurchaseButton, UIE_CLICK, PurchaseOfferButton_OnClick )
	AddButtonEventHandler( s_inspectUIData.giftButton, UIE_CLICK, GiftButton_OnClick )


	#if NX_PROG
		                                                                                     
		                                                   
	#endif
	GridPanel_Init( file.itemGrid, ITEM_GRID_ROWS, ITEM_GRID_COLUMNS, OnBindItemGridButton, ItemGridButtonCountCallback, ItemGridButtonInitCallback )
	GridPanel_SetFillDirection( file.itemGrid, eGridPanelFillDirection.RIGHT )
	GridPanel_SetButtonHandler( file.itemGrid, UIE_CLICK, OnStoreGridItemClicked )
	GridPanel_SetButtonHandler( file.itemGrid, UIE_GET_FOCUS, OnStoreGridItemHover )

	Hud_AddEventHandler( Hud_GetChild( newMenuArg, "CoinsPopUpButton" ), UIE_CLICK, OpenVCPopUp )

	AddMenuFooterOption( menu, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
	AddMenuFooterOption( menu, LEFT, BUTTON_X, true, "#X_GIFT_INFO_TITLE", "#GIFT_INFO_TITLE", OpenGiftInfoPopUp, CheckIsGiftable )
}
#if NX_PROG
void function StoreInspectMenuOnThink(var menu)
{
	                                                                                                          
	                                                                                                                                       
	                                                                                                                    
	                                                                                  
	                                                                                  
	                                    
}
#endif

void function StoreInspectMenu_OnOpen()
{
	AddCallback_OnGRXInventoryStateChanged( LockPurchaseButtonWhenInventoryIsNotReady )
	AddCallback_OnGRXInventoryStateChanged( LockGiftButtonsWhenInventoryIsNotReady )
	AddCallbackAndCallNow_OnGRXInventoryStateChanged( StoreInspectMenu_OnGRXUpdated )
	AddCallback_OnGRXOffersRefreshed( StoreInspectMenu_OnGRXUpdated )
	AddCallback_OnGRXBundlesRefreshed( StoreInspectMenu_OnGRXBundlesUpdated )
}

void function StoreInspectMenu_OnTopLevel()
{
	if ( !GRX_IsInventoryReady() )
		return

	StoreInspectMenu_UpdatePrices( s_inspectOffers, s_inspectOffers.currentOffers[0], false, s_inspectUIData )
	StoreInspectMenu_UpdatePurchaseButton( s_inspectOffers.currentOffers[0], s_inspectOffers, s_inspectUIData )
}

void function StoreInspectMenu_OnShow()
{
	UI_SetPresentationType( ePresentationType.STORE_INSPECT )

	StoreInspectMenu_OnUpdate()
	StoreInspectMenu_OnGRXUpdated()
	StoreInspectMenu_OnGRXBundlesUpdated()
	RegisterButtonPressedCallback( KEY_TAB, ToggleVCPopUp )
	RegisterButtonPressedCallback( BUTTON_BACK, ToggleVCPopUp )
	Lobby_AdjustScreenFrameToMaxSize( Hud_GetChild( file.menu, "ScreenFrame" ), true )
}

void function StoreInspectMenu_OnClose()
{
	RemoveCallback_OnGRXInventoryStateChanged( StoreInspectMenu_OnGRXUpdated )
	RemoveCallback_OnGRXInventoryStateChanged( LockPurchaseButtonWhenInventoryIsNotReady )
	RemoveCallback_OnGRXInventoryStateChanged( LockGiftButtonsWhenInventoryIsNotReady )
	RemoveCallback_OnGRXOffersRefreshed( StoreInspectMenu_OnGRXUpdated )
	RemoveCallback_OnGRXBundlesRefreshed( StoreInspectMenu_OnGRXBundlesUpdated )

	RunClientScript( "UIToClient_UnloadItemInspectPakFile" )
}

void function StoreInspectMenu_OnHide()
{
	DeregisterButtonPressedCallback( KEY_TAB, ToggleVCPopUp )
	DeregisterButtonPressedCallback( BUTTON_BACK, ToggleVCPopUp )
}

void function StoreInspectMenu_OnUpdate()
{
	if ( !IsFullyConnected() )
		return

	GridPanel_Refresh( file.itemGrid )
	RefreshTwoFactorAuthenticationStatus()
}

void function StoreInspectMenu_UpdatePrices( StoreInspectOfferData offerData ,GRXScriptOffer storeOffer, bool isBundlesRefresh, StoreInspectUIData uiData )
{
	if ( isBundlesRefresh && storeOffer.offerType != GRX_OFFERTYPE_BUNDLE )
		return

	bool isMarketplaceBundle = storeOffer.offerType == GRX_OFFERTYPE_BUNDLE
	bool hasMultipleItems = storeOffer.output.flavors.len() > 1
	bool isHeirloomPack = GRXOffer_IsHeirloomPack( storeOffer )
	bool isBundle = isMarketplaceBundle || (hasMultipleItems && !isHeirloomPack)

	bool isBundlePriceMissing = false
	string ineligibleReason = ""
	int purchaseCount = 0

	if ( isMarketplaceBundle )
	{
		if ( !isBundlesRefresh && !GRX_HasUpToDateBundleOffers() )
		{
			printt( "StoreInspectMenu: Client never received bundle offers but we're trying to display a bundle." )
			isBundlePriceMissing = true
		}
		else
		{
			                                                                                                       
			GRX_CheckBundleAndUpdateOfferPrices( storeOffer )

			GRXBundleOffer bundle = GRX_GetUserBundleOffer( storeOffer.offerAlias )
			purchaseCount = bundle.purchaseCount
		}
	}

	offerData.displayedPrice = storeOffer.prices[0].quantities[0]

	                                                                                                                 
	if ( storeOffer.prices.len() == 2 )
	{
		string firstPrice = GRX_GetFormattedPrice( storeOffer.prices[0], 1 )
		string secondPrice = GRX_GetFormattedPrice( storeOffer.prices[1], 1 )
		offerData.displayedPriceStr = Localize( "#STORE_PRICE_N_N", firstPrice, secondPrice )
		offerData.isDualCurrency = true
	}
	else
	{
		offerData.displayedPriceStr = GRX_GetFormattedPrice( storeOffer.prices[0], 1 )
		offerData.isDualCurrency = false
	}

	offerData.discountPct = 0

	ItemFlavorBag originalPriceFlavBag
	if ( storeOffer.originalPrice != null )
		originalPriceFlavBag = expect ItemFlavorBag( storeOffer.originalPrice )

	if ( originalPriceFlavBag.quantities.len() > 0 )
	{
		offerData.originalPrice = originalPriceFlavBag.quantities[0]
		offerData.originalPriceStr = GRX_GetFormattedPrice( originalPriceFlavBag, 1 )
		float discount = 100 - ( offerData.displayedPrice / (offerData.originalPrice * 1.0) * 100 )
		offerData.discountPct = int( floor( discount ) )                                                      
	}

	string bundleRestrictionsStr = GRXOffer_GetBundleOfferRestrictions( storeOffer )
	bool hasBundleRestrictions = bundleRestrictionsStr != ""

	bool isOfferFullyClaimed = GRXOffer_IsFullyClaimed( storeOffer )
	bool isPurchaseLimitReached = offerData.purchaseLimit > 0 && purchaseCount >= offerData.purchaseLimit

	int numOfferItemsOwned = GRXOffer_GetOwnedItemsCount( storeOffer )
	HudElem_SetRuiArg( uiData.discountInfo, "ownedItemsDesc", numOfferItemsOwned > 0 && !isOfferFullyClaimed ? Localize( "#BUNDLE_OWNED_ITEMS_DESC", numOfferItemsOwned ) : "" )

	offerData.isPurchasable = !isOfferFullyClaimed && !hasBundleRestrictions && !isPurchaseLimitReached && storeOffer.isAvailable
	offerData.purchaseText = isBundle ? Localize( "#PURCHASE_BUNDLE" ) : Localize( "#PURCHASE" )
	offerData.purchaseDescText = Localize( offerData.displayedPriceStr )

	if ( storeOffer.prices.len() == 1 )
		offerData.canAfford = GRX_CanAfford( storeOffer.prices[0], 1 )
	else if ( storeOffer.prices.len() == 2 )
		offerData.canAfford = GRX_CanAfford( storeOffer.prices[0], 1 ) || GRX_CanAfford( storeOffer.prices[1], 1 )
	bool isGiftable = storeOffer.isAvailable && storeOffer.isGiftable && IsPlayerLeveledForGifting() && IsGiftingEnabled()

	if ( !storeOffer.isAvailable )
	{
		                                                                           
		offerData.purchaseText = Localize( "#UNAVAILABLE" )
		offerData.purchaseDescText = ""
	}
	else if ( isMarketplaceBundle && isBundlePriceMissing )
	{
		offerData.purchaseText = Localize( "#UNAVAILABLE" )
		offerData.purchaseDescText = Localize( "#BUNDLE_UNABLE_TO_RETREIVE_DATA" )
	}
	else if ( isBundle && hasBundleRestrictions )
	{
		offerData.purchaseText = Localize( "#LOCKED" )
		offerData.purchaseDescText = Localize( bundleRestrictionsStr )
	}
	else if ( isBundle && isOfferFullyClaimed )
	{
		offerData.purchaseText = Localize( "#OWNED" )
		offerData.purchaseDescText = Localize( "#BUNDLE_OWNED_DESC" )
	}
	else if ( isPurchaseLimitReached )
	{
		offerData.purchaseText = Localize( "#UNAVAILABLE" )
		offerData.purchaseDescText = Localize( "#PURCHASE_LIMIT_REACHED" )
	}
	else if ( isOfferFullyClaimed )
	{
		offerData.purchaseText = Localize( "#OWNED" )
		offerData.purchaseDescText = hasBundleRestrictions ? bundleRestrictionsStr : ""
	}
	else if ( isGiftable )
	{
		offerData.purchaseText = offerData.canAfford ? offerData.purchaseText : Localize( "#CONFIRM_GET_PREMIUM" )
		offerData.purchaseDescText = ""
	}
	if ( isGiftable )
	{
		bool isTwoFactorEnabled = IsTwoFactorAuthenticationEnabled()
		int giftsLeft = Gifting_GetRemainingDailyGifts()

		string giftMainText = Localize( offerData.canAfford && isTwoFactorEnabled ? "#BUY_GIFT_STAR" : "#BUY_GIFT" )
		string giftDescText = Localize( "#GIFTS_LEFT_FRACTION", giftsLeft )

		bool canAffordWithAC = CanPlayerAffordWithPremiumCurrency( storeOffer )
		offerData.isOwnedItemEquippable = IsOwnedItemOfferEquippable( storeOffer )
		if ( offerData.isDualCurrency || offerData.isOwnedItemEquippable )
		{
			if ( !canAffordWithAC )
			{
				giftMainText = Localize( "#BUY_GIFT_STAR" )
				giftDescText = Localize( "#CONFIRM_GET_PREMIUM" ) + " >>"
				Hud_SetVisible( uiData.purchaseButton, false )
			}
		}
		offerData.giftText = giftMainText
		offerData.giftDescText = giftDescText
		offerData.giftTooltipTitleText =  Localize( "#GIFTS_LEFT", giftsLeft )

		DisplayTime dt = SecondsToDHMS( GRX_GetGiftingLimitResetDate() - GetUnixTimestamp() )
		if ( dt.hours > 0 )
			offerData.giftTooltipDescText =  Localize( "#GIFTS_MAXED_OUT_REASON_HOURS", string( GetGiftingMaxLimitPerResetPeriod() ), dt.hours )
		else if ( dt.minutes > 0 )
			offerData.giftTooltipDescText =  Localize( "#GIFTS_MAXED_OUT_REASON_MINUTES", string( GetGiftingMaxLimitPerResetPeriod() ), dt.minutes )
		else
			offerData.giftTooltipDescText =  Localize( "#GIFTS_MAXED_OUT_REASON_MINUTES", string( GetGiftingMaxLimitPerResetPeriod() ), "<1" )


		if ( !IsPlayerWithinGiftingLimit() )
			offerData.giftText = Localize( "#LOCKED_GIFT" )

		if ( !isTwoFactorEnabled )
		{
			offerData.giftText = Localize( "#LOCKED_GIFT" )
			offerData.giftDescText = Localize( "#TWO_FACTOR_NEEDED" )
			offerData.giftTooltipTitleText = Localize( "#ENABLE_TWO_FACTOR" )
			offerData.giftTooltipDescText = Localize( "#TWO_FACTOR_NEEDED_DETAILS" )
		}
		HudElem_SetRuiArg( uiData.discountInfo, "isBundle", isBundle )
		HudElem_SetRuiArg( uiData.discountInfo, "canAfford", offerData.canAfford )
	}
	                                                                                                                                       
	                                                                                                                               
}

void function StoreInspectMenu_UpdatePurchaseButton( GRXScriptOffer storeOffer, StoreInspectOfferData offerData, StoreInspectUIData uiData )
{
	bool isExtraInfoVisible = false
	bool isOfferFullyClaimed = GRXOffer_IsFullyClaimed( storeOffer )
	bool isGiftable = storeOffer.isGiftable && IsPlayerLeveledForGifting() && storeOffer.isAvailable && IsGiftingEnabled()
	if ( storeOffer.prereq != null )
	{
		ItemFlavor prereqFlav = expect ItemFlavor( storeOffer.prereq )

		int eventType = ItemFlavor_GetType( prereqFlav )

		if ( eventType == eItemType.calevent_collection || eventType == eItemType.calevent_themedshop )
		{
			offerData.isPurchasable = false
			if ( !isOfferFullyClaimed && HeirloomEvent_IsRewardMythicSkin( prereqFlav ) )
				offerData.purchaseText = Localize( GRX_IsItemOwnedByPlayer( storeOffer.output.flavors[0] ) ? "#OWNED" : "#LOCKED" )
			else
				offerData.purchaseText = Localize( isOfferFullyClaimed ? "#OWNED" : "#LOCKED" )

			string eventName = Localize( eventType == eItemType.calevent_themedshop ?  ThemedShopEvent_GetItemGroupHeaderText( prereqFlav, 1 ) : CollectionEvent_GetCollectionName( prereqFlav ) )
			offerData.purchaseDescText = Localize( ( isOfferFullyClaimed ? "#STORE_REQUIRES_OWNED" : "#STORE_REQUIRES_LOCKED" ), eventName )
		}
		else if ( !GRX_IsItemOwnedByPlayer( prereqFlav ) )
		{
			offerData.isPurchasable = false
			offerData.purchaseText = Localize( "#LOCKED" )
			offerData.purchaseDescText = Localize( "#STORE_REQUIRES_LOCKED", Localize( ItemFlavor_GetLongName( prereqFlav ) ) )
		}
	}

	HudElem_SetRuiArg( uiData.discountInfo, "discountPct", string(offerData.discountPct) )
	HudElem_SetRuiArg( uiData.discountInfo, "originalPrice", Localize( offerData.originalPriceStr ) )
	Hud_ClearToolTipData( uiData.giftablePurchaseButton )
	Hud_ClearToolTipData( uiData.purchaseButton )

	ItemFlavor ornull activeCollectionEvent = GetActiveCollectionEvent( GetUnixTimestamp() )
	if ( activeCollectionEvent != null )
	{
		expect ItemFlavor( activeCollectionEvent )
		int currentMaxEventPackPurchaseCount = CollectionEvent_GetCurrentMaxEventPackPurchaseCount( activeCollectionEvent, GetLocalClientPlayer() )
		if ( CollectionEvent_IsItemFlavorFromEvent( activeCollectionEvent, storeOffer.items[0].itemIdx ) )
		{
			                                                                     
			if ( !GRX_IsOfferRestricted( GetLocalClientPlayer()  ) )
			{
				offerData.isPurchasable = currentMaxEventPackPurchaseCount > 0
			}
			else
			{

				ItemFlavor packFlav = CollectionEvent_GetMainPackFlav( activeCollectionEvent )
				int ownedPackCount = GRX_GetPackCount( ItemFlavor_GetGRXIndex( packFlav ) )

				                                            
				                                              
				                                              
				                                                                                                                       
				offerData.isPurchasable = 	!isOfferFullyClaimed
											&& !GRX_IsOfferRestrictedByOfferAttributes( storeOffer )
											&& ( HeirloomEvent_GetCurrentRemainingItemCount( activeCollectionEvent, GetLocalClientPlayer() ) - ownedPackCount ) >= 1
			}
			if ( !offerData.isPurchasable )
			{
				ToolTipData toolTipData
				toolTipData.titleText = Localize( "#CANNOT_PURCHASE" ).toupper()
				toolTipData.tooltipFlags = toolTipData.tooltipFlags | eToolTipFlag.SOLID
				toolTipData.tooltipStyle = eTooltipStyle.STORE_CONFIRM
				toolTipData.descText = Localize( "#COLLECTION_CANNOT_PURCHASE_INSPECT_DESC", currentMaxEventPackPurchaseCount, HeirloomEvent_GetItemCount( activeCollectionEvent, false ) )
				Hud_SetToolTipData( isGiftable ? uiData.giftablePurchaseButton : uiData.purchaseButton, toolTipData )
			}
		}
	}
	HudElem_SetRuiArg( uiData.discountInfo, "discountedPrice", isGiftable ? Localize( offerData.displayedPriceStr ) : "" )
	HudElem_SetRuiArg( uiData.discountInfo, "isGiftable", isGiftable )
	isExtraInfoVisible = ( offerData.isPurchasable && offerData.discountPct > 0.0 ) || isGiftable

	Hud_SetVisible( uiData.discountInfo, isExtraInfoVisible )
	HudElem_SetRuiArg( uiData.purchaseButton, "buttonText", offerData.purchaseText )
	HudElem_SetRuiArg( uiData.purchaseButton, "buttonDescText", offerData.purchaseDescText )

	HudElem_SetRuiArg( uiData.purchaseButton, "buttonText", offerData.purchaseText )
	bool showPurchaseButton
	bool showDisclaimers = true
	if ( !offerData.canAfford )
	{
		if ( offerData.isDualCurrency )
		{
			showPurchaseButton = false
		}
		else
		{
			showPurchaseButton = true
			showDisclaimers = false
		}
	}

	if ( !isGiftable )
		showPurchaseButton = true
	Hud_SetVisible( uiData.purchaseButton, showPurchaseButton )

	if ( isGiftable )
	{
		HudElem_SetRuiArg( uiData.giftablePurchaseButton, "buttonText", offerData.purchaseText )
		HudElem_SetRuiArg( uiData.giftablePurchaseButton, "buttonDescText", offerData.purchaseDescText )
		HudElem_SetRuiArg( uiData.giftButton, "buttonText", offerData.giftText )
		HudElem_SetRuiArg( uiData.giftButton, "buttonDescText", offerData.giftDescText )
		Hud_SetVisible( uiData.giftButton, true )
		Hud_SetVisible( uiData.giftablePurchaseButton, true )
		bool TwoFactorEnabled = IsTwoFactorAuthenticationEnabled()
		bool PlayerHasGiftsLeft = IsPlayerWithinGiftingLimit()
		Hud_ClearToolTipData( uiData.giftButton )

		if ( !TwoFactorEnabled || !PlayerHasGiftsLeft )
		{
			showDisclaimers = false
			ToolTipData giftTooltipData
			giftTooltipData.titleText = offerData.giftTooltipTitleText
			giftTooltipData.descText = offerData.giftTooltipDescText
			giftTooltipData.tooltipFlags = giftTooltipData.tooltipFlags | eToolTipFlag.SOLID
			giftTooltipData.tooltipStyle = eTooltipStyle.DEFAULT
			Hud_SetToolTipData( uiData.giftButton, giftTooltipData )
		}
		HudElem_SetRuiArg( uiData.discountInfo, "hideDisclaimers", !showDisclaimers )
		Hud_SetLocked( uiData.giftButton, !PlayerHasGiftsLeft )
	}


	if ( offerData.itemCount == 1 && isOfferFullyClaimed )
	{
		StoreInspectMenu_UpdateButtonForEquips( offerData, uiData )
		Hud_SetLocked( uiData.purchaseButton, !offerData.isOwnedItemEquippable )
		HudElem_SetRuiArg( uiData.purchaseButton, "isDisabled", !offerData.isOwnedItemEquippable )
		if ( isGiftable )
		{
			Hud_SetLocked( uiData.giftablePurchaseButton, !offerData.isOwnedItemEquippable )
			HudElem_SetRuiArg( uiData.giftablePurchaseButton, "isDisabled", !offerData.isOwnedItemEquippable )
			Hud_SetVisible( uiData.purchaseButton, false )
		}
	}
	else
	{
		s_inspectOffers.isOwnedItemEquippable = false
		Hud_SetLocked( uiData.purchaseButton, !offerData.isPurchasable )
		HudElem_SetRuiArg( uiData.purchaseButton, "isDisabled", !offerData.isPurchasable )
		if ( isGiftable )
		{
			Hud_SetLocked( uiData.giftablePurchaseButton, !offerData.isPurchasable )
			HudElem_SetRuiArg( uiData.giftablePurchaseButton, "isDisabled", !offerData.isPurchasable )
		}
	}

                                                                 
         
  	                          
  	 
  		                                                                                    
  		                                                                                    
  	 
  	                                                                  
  	 
  		                                                                                    
  		                                                                              
  	 
        
}

void function StoreInspectMenu_UpdateButtonForEquips( StoreInspectOfferData offerData, StoreInspectUIData uiData )
{
	ItemFlavor itemFlav = offerData.itemFlavors[0]
	int itemType = ItemFlavor_GetType( itemFlav )
	var rui = Hud_GetRui( uiData.purchaseButton )
	bool isMythic = ItemFlavor_GetQuality( itemFlav ) == eRarityTier.MYTHIC
	var smallRui = null
	if ( !isMythic )
		smallRui = Hud_GetRui( uiData.giftablePurchaseButton )

	if ( itemType == eItemType.weapon_charm || itemType == eItemType.account_pack || itemType == eItemType.emote_icon || itemType == eItemType.skydive_emote || itemType == eItemType.sticker )
	{
		                           	                                
		                           	                  
		                           	                                                                      
		                     		                                                                                       
		offerData.isOwnedItemEquippable = false
	}
	else if ( IsItemEquipped( itemFlav ) )
	{
		int rarity = ItemFlavor_HasQuality( itemFlav ) ? ItemFlavor_GetQuality( itemFlav ) : 0

		RuiSetString( rui, "buttonText", "#EQUIPPED_LOOT_REWARD" )
		RuiSetString( rui, "buttonDescText", Localize( "#CURRENTLY_EQUIPPED_ITEM", Localize( ItemFlavor_GetLongName( itemFlav ) ) ) )
		RuiSetInt( rui, "buttonDescRarity", rarity )
		if ( smallRui != null )
		{
			RuiSetString( smallRui, "buttonText", "#EQUIPPED_LOOT_REWARD" )
			RuiSetString( smallRui, "buttonDescText", Localize( "#CURRENTLY_EQUIPPED_ITEM", Localize( ItemFlavor_GetLongName( itemFlav ) ) ) )
			RuiSetInt( smallRui, "buttonDescRarity", rarity )
		}
		offerData.isOwnedItemEquippable = false
	}
	else
	{
		                                                                                                                                                                                                  
		RuiSetString( rui, "buttonText", "#EQUIP_LOOT_REWARD" )
		RuiSetString( rui, "buttonDescText", Localize( "#CURRENTLY_EQUIPPED_ITEM", Localize( GetCurrentlyEquippedItemNameForItemTypeSlot( itemFlav ) ) ) )
		RuiSetInt( rui, "buttonDescRarity", GetCurrentlyEquippedItemRarityForItemTypeSlot( itemFlav ) )
		if ( smallRui != null )
		{
			RuiSetString( smallRui, "buttonText", "#EQUIP_LOOT_REWARD" )
			RuiSetString( smallRui, "buttonDescText", Localize( "#CURRENTLY_EQUIPPED_ITEM", Localize( GetCurrentlyEquippedItemNameForItemTypeSlot( itemFlav ) ) ) )
			RuiSetInt( smallRui, "buttonDescRarity", GetCurrentlyEquippedItemRarityForItemTypeSlot( itemFlav ) )
		}
		offerData.isOwnedItemEquippable = true
	}
}

void function StoreInspectMenu_OnGRXBundlesUpdated()
{
	if ( s_inspectOffers.currentOffers.len() == 0 )
		return

	if( !GRX_IsInventoryReady() )
		return

	StoreInspectMenu_UpdatePrices( s_inspectOffers, s_inspectOffers.currentOffers[0], true, s_inspectUIData )
	StoreInspectMenu_UpdatePurchaseButton( s_inspectOffers.currentOffers[0], s_inspectOffers, s_inspectUIData )
}

void function StoreInspectMenu_OnGRXUpdated()
{
	if( !GRX_IsInventoryReady() || !GRX_AreOffersReady() )
		return

	GRXScriptOffer storeOffer = s_inspectOffers.currentOffers[0]
	s_inspectOffers.itemFlavors.clear()

	                           
	var currMenu = GetActiveMenu()
	uiGlobal.menuData[ currMenu ].pin_metaData[ "tab_name" ] <- Hud_GetHudName( file.inspectPanel )

	printt( "StoreInspectMenu_OnGRXUpdated offer is from store:", storeOffer.offerAlias )
	uiGlobal.menuData[ currMenu ].pin_metaData[ "item_name" ] <- storeOffer.offerAlias

	foreach ( ItemFlavor flav in storeOffer.output.flavors )
		s_inspectOffers.itemFlavors.append( flav )

	s_inspectOffers.purchaseLimit = ( "purchaselimit" in storeOffer.attributes ? storeOffer.attributes["purchaselimit"].tointeger() : -1 )

	s_inspectOffers.exclusiveItems.clear()
	string exclusiveItemsAttr = ( "offerexclusives" in storeOffer.attributes ? storeOffer.attributes["offerexclusives"] : "" )
	s_inspectOffers.exclusiveItems = split( exclusiveItemsAttr, "," )

	StoreInspectMenu_UpdatePrices( s_inspectOffers, storeOffer, false, s_inspectUIData )
	StoreInspectMenu_UpdatePurchaseButton( storeOffer, s_inspectOffers, s_inspectUIData )

	HudElem_SetRuiArg( file.pageHeader, "offerName", storeOffer.titleText )
	HudElem_SetRuiArg( file.pageHeader, "isSingleItem", s_inspectOffers.itemCount == 1 )

	if ( s_inspectOffers.itemCount == 1 )
	{
		ItemFlavor itemFlav = s_inspectOffers.itemFlavors[0]

		HudElem_SetRuiArg( file.pageHeader, "singleItemRarity", ItemFlavor_GetQuality( itemFlav ) )
		HudElem_SetRuiArg( file.pageHeader, "singleItemRarityText", ItemFlavor_GetQualityName( itemFlav ) )
		HudElem_SetRuiArg( file.pageHeader, "singleItemTypeText", ItemFlavor_GetRewardShortDescription( itemFlav ) )
	}
	else
	{
		string offerDesc = Localize( storeOffer.descText )

		                                                                      
		foreach ( ItemFlavor item in s_inspectOffers.itemFlavors )
		{
			if ( ItemFlavor_GetType( item ) != eItemType.melee_skin )
				continue

			ItemFlavor character = MeleeSkin_GetCharacterFlavor( item )
			string characterName = Localize( ItemFlavor_GetLongName( character ) )
			offerDesc = Localize( "#CHARACTER_HEIRLOOM", characterName )
			break
		}

		HudElem_SetRuiArg( file.pageHeader, "offerDesc", offerDesc )
	}

	                                               
	OnStoreGridItemHover( null, null, 0 )
	GridPanel_Refresh( file.itemGrid )
	bool hasPurchaseLimit = s_inspectOffers.purchaseLimit > 0 && !storeOffer.isGiftable

	HudElem_SetRuiArg( file.purchaseLimit, "limitText", Localize( "#STORE_LIMIT_N", s_inspectOffers.purchaseLimit ) )
	Hud_SetVisible( file.purchaseLimit, hasPurchaseLimit )
	UpdateFooterOptions()
}

GRXStoreOfferItem function GetItemFromGridIndex( int index )
{
	GRXScriptOffer storeOffer = s_inspectOffers.currentOffers[0]
	return storeOffer.items[index]
}

void function OnBindItemGridButton( var panel, var button, int index )
{
	GRXStoreOfferItem item = GetItemFromGridIndex( index )

	ItemFlavor itemFlav
	itemFlav = GetItemFlavorByGRXIndex( item.itemIdx )
	asset itemThumbnail = CustomizeMenu_GetGenericRewardButtonImage( itemFlav )

	var rui = Hud_GetRui( button )
	if( ItemFlavor_GetGRXMode( itemFlav ) == eItemFlavorGRXMode.REGULAR )
		RuiSetBool( rui, "isOwned", GRX_IsItemOwnedByPlayer( itemFlav ) )
	else
		RuiSetBool( rui, "isOwned", false )

	RuiSetImage( rui, "itemThumbnail", itemThumbnail )
	RuiSetInt( rui, "rarity", ItemFlavor_GetQuality( itemFlav ) )
	RuiSetInt( rui, "itemQty", item.itemQuantity )

	string specialItemDesc = ""
	foreach ( string itemName in s_inspectOffers.exclusiveItems )
		if ( ItemFlavor_GetGRXAlias( itemFlav ) == itemName )
			specialItemDesc = "#BUNDLE_ITEM_DESC_EXCLUSIVE"

	if ( item.itemType == GRX_OFFERITEMTYPE_BONUS )
		specialItemDesc = "#BUNDLE_ITEM_DESC_BONUS"

	RuiSetString( rui, "specialItemDesc", Localize( specialItemDesc ) )

	if ( ItemFlavor_GetType( itemFlav ) == eItemType.loadscreen )
		RunClientScript( "UIToClient_LoadItemInspectPakFile", ItemFlavor_GetGUID( itemFlav ) )
}

int function ItemGridButtonCountCallback( var panel )
{
	return s_inspectOffers.itemCount
}

void function ItemGridButtonInitCallback( var button )
{
}

void function OnStoreGridItemClicked( var panel, var button, int index )
{
}

void function OnStoreGridItemHover( var panel, var button, int index )
{
	GRXStoreOfferItem item = GetItemFromGridIndex( index )
	ItemFlavor itemFlav = GetItemFlavorByGRXIndex( item.itemIdx )

#if DEV
	if ( ItemFlavor_GetType( itemFlav ) == eItemType.melee_skin )
	{
		int menuHeirloomOverrideGUID = DEV_GetMenuHeirloomOverrideGUID()
		if ( menuHeirloomOverrideGUID >= 0 )
			itemFlav = GetItemFlavorByGUID( menuHeirloomOverrideGUID )
	}
#endif       

	bool isOwned = false
	if ( ItemFlavor_GetGRXMode( itemFlav ) == GRX_ITEMFLAVORMODE_REGULAR )
		isOwned = GRX_IsItemOwnedByPlayer( itemFlav )

	int itemType = ItemFlavor_GetType( itemFlav )
	string rarityText = itemType == eItemType.character ? "" : ItemFlavor_GetQualityName( itemFlav )

	HudElem_SetRuiArg( file.itemInfo, "isOwned", isOwned )
	HudElem_SetRuiArg( file.itemInfo, "rarity", ItemFlavor_GetQuality( itemFlav ) )
	HudElem_SetRuiArg( file.itemInfo, "rarityText", rarityText )
	HudElem_SetRuiArg( file.itemInfo, "itemName", ItemFlavor_GetLongName( itemFlav ) )
	HudElem_SetRuiArg( file.itemInfo, "itemType", ItemFlavor_GetRewardShortDescription( itemFlav ) )

	RunClientScript( "UIToClient_PreviewStoreItem", ItemFlavor_GetGUID( itemFlav ), s_inspectOffers.currentOffers[0].items.len() == 1 )
}

void function LockPurchaseButtonWhenInventoryIsNotReady()
{
	bool shouldLockPurchaseButton = !GRX_IsInventoryReady()
	Hud_SetLocked( s_inspectUIData.purchaseButton, shouldLockPurchaseButton )
}

void function LockGiftButtonsWhenInventoryIsNotReady()
{
	bool shouldLockPurchaseButton = !GRX_IsInventoryReady()
	Hud_SetLocked( s_inspectUIData.giftablePurchaseButton, shouldLockPurchaseButton )
	Hud_SetLocked( s_inspectUIData.giftButton, shouldLockPurchaseButton )
}

void function PurchaseOfferButton_OnClick( var button )
{
	if ( Hud_IsLocked( button ) )
	{
		EmitUISound( "menu_deny" )
		return
	}

	GRXScriptOffer offer = s_inspectOffers.currentOffers[0]
	if ( offer.isGiftable && IsPlayerLeveledForGifting() )
	{

		bool canAfford
		if ( offer.prices.len() == 1 )
			canAfford = GRX_CanAfford( offer.prices[0], 1 )
		else if ( offer.prices.len() > 1 )
			canAfford = GRX_CanAfford( offer.prices[0], 1 ) || GRX_CanAfford( offer.prices[1], 1 )

		if ( !canAfford && !s_inspectOffers.isOwnedItemEquippable )
		{
			OpenVCPopUp( null )
			return
		}
	}

	if ( s_inspectOffers.isOwnedItemEquippable && offer.output.flavors.len() == 1 )
	{
		StoreInspectMenu_EquipOwnedItem( offer.output.flavors[0], s_inspectUIData )
		return
	}

	PurchaseDialogConfig pdc
	pdc.offer = offer
	pdc.quantity = 1
	PurchaseDialog( pdc )
}

void function GiftButton_OnClick( var button )
{
	if ( Hud_IsLocked( button ) )
	{
		EmitUISound( "menu_deny" )
		return
	}
	GRXScriptOffer offer = s_inspectOffers.currentOffers[0]
	bool isDualPriceOffer = offer.prices.len() == 2

	bool isEquipable = IsOwnedItemOfferEquippable( offer )

	if ( !IsTwoFactorAuthenticationEnabled() )
	{
		OpenTwoFactorInfoDialog( button )
		return
	}

	if ( !CanPlayerAffordWithPremiumCurrency( offer ) )
	{
		if ( isDualPriceOffer || isEquipable )
			OpenVCPopUp( null )
		return
	}

	OpenGiftingDialog( offer )
}

bool function CanPlayerAffordWithPremiumCurrency( GRXScriptOffer offer )
{
	foreach ( ItemFlavorBag price in offer.prices )
	{
		if ( price.flavors[0] != GRX_CURRENCIES[GRX_CURRENCY_PREMIUM] )
			continue

		if ( GRX_CanAfford( price, 1 ) )
			return true
	}
	return false
}

bool function IsOwnedItemOfferEquippable( GRXScriptOffer offer )
{
	if ( offer.output.flavors.len() == 1 && GRXOffer_IsFullyClaimed( offer ) )
	{
		ItemFlavor itemFlav = offer.output.flavors[0]
		int itemType = ItemFlavor_GetType( itemFlav )
		if ( itemType == eItemType.weapon_charm || itemType == eItemType.account_pack || itemType == eItemType.emote_icon || itemType == eItemType.skydive_emote || itemType == eItemType.sticker )
			return false
		else
			return true
	}
	return false
}

void function StoreInspectMenu_EquipOwnedItem( ItemFlavor itemFlavToEquip, StoreInspectUIData uiData )
{
	int itemType = ItemFlavor_GetType( itemFlavToEquip )
	array<LoadoutEntry> entries = EquipButton_GetItemLoadoutEntries( itemFlavToEquip, false )

	EmitUISound( "UI_Menu_Equip_Generic" )

	if ( entries.len() != 1 )
	{
		OpenSelectSlotDialog( entries, itemFlavToEquip, GetItemFlavorAssociatedCharacterOrWeapon( itemFlavToEquip ), void function( int slotIndex ) : ( entries, itemFlavToEquip ) {
			RequestSetItemFlavorLoadoutSlot_WithDuplicatePrevention( LocalClientEHI(), entries, itemFlavToEquip, slotIndex )
			PIN_Customization( null, itemFlavToEquip, "equip", slotIndex )
		} )
	}
	else
	{
		RequestSetItemFlavorLoadoutSlot_WithDuplicatePrevention( LocalClientEHI(), entries, itemFlavToEquip, 0 )
		PIN_Customization( null, itemFlavToEquip, "equip", 0 )
	}

	Newness_IfNecessaryMarkItemFlavorAsNoLongerNewAndInformServer( itemFlavToEquip )

	var rui = Hud_GetRui( uiData.purchaseButton )
	RuiSetString( rui, "buttonText", "#EQUIPPED_LOOT_REWARD" )
	RuiSetString( rui, "buttonDescText", Localize( "#CURRENTLY_EQUIPPED_ITEM", Localize( ItemFlavor_GetLongName( itemFlavToEquip ) ) ) )
	Hud_SetLocked( uiData.purchaseButton, true )
	bool isMythic = ItemFlavor_GetQuality( itemFlavToEquip ) == eRarityTier.MYTHIC
	if ( isMythic )
		return
	var ruiSmall = Hud_GetRui( uiData.giftablePurchaseButton )
	RuiSetString( ruiSmall, "buttonText", "#EQUIPPED_LOOT_REWARD" )
	RuiSetString( ruiSmall, "buttonDescText", Localize( "#CURRENTLY_EQUIPPED_ITEM", Localize( ItemFlavor_GetLongName( itemFlavToEquip ) ) ) )
	Hud_SetLocked( uiData.giftablePurchaseButton, true )
}

void function StoreInspectMenu_SetStoreOfferData( array<GRXScriptOffer> storeOffers )
{
	s_inspectOffers.currentOffers.clear()
	foreach ( GRXScriptOffer offer in storeOffers )
		s_inspectOffers.currentOffers.append( offer )

	GRXScriptOffer storeOffer = s_inspectOffers.currentOffers[0]

	Assert( storeOffer.output.flavors.len() == storeOffer.output.quantities.len() )

	s_inspectOffers.itemCount = storeOffer.output.flavors.len()

	Assert( s_inspectOffers.itemCount > 0 )

	Hud_SetVisible( file.itemGrid, s_inspectOffers.itemCount > 1 )
	Hud_SetVisible( file.itemInfo, s_inspectOffers.itemCount > 1 )
}

bool function StoreInspectMenu_IsItemPresentationSupported( ItemFlavor itemFlav )
{
	                                                                   
	switch ( ItemFlavor_GetType( itemFlav ) )
	{
		case eItemType.account_pack:
		case eItemType.apex_coins:
		case eItemType.character:
		case eItemType.character_emote:
		case eItemType.character_execution:
		case eItemType.character_skin:
		case eItemType.emote_icon:
		case eItemType.gladiator_card_badge:
		case eItemType.gladiator_card_frame:
		case eItemType.gladiator_card_intro_quip:
		case eItemType.gladiator_card_kill_quip:
		case eItemType.gladiator_card_stance:
		case eItemType.gladiator_card_stat_tracker:
		case eItemType.loadscreen:
		case eItemType.melee_skin:
		case eItemType.music_pack:
		case eItemType.skydive_emote:
		case eItemType.weapon_charm:
		case eItemType.weapon_skin:
		case eItemType.sticker:
			return true

		                            
		                                   
	}

	printf( "Offer has item '%s' [eItemType: %d] which is currently unsupported in bundle inspect view.",
		string(ItemFlavor_GetAsset( itemFlav )), ItemFlavor_GetType( itemFlav ) )
	return false
}

void function StoreInspectMenu_AttemptOpenWithOffer( GRXScriptOffer offer )
{
	bool canAllItemsBePresented = true
	foreach( ItemFlavor flav in offer.output.flavors )
	{
		if( !StoreInspectMenu_IsItemPresentationSupported( flav ) )
		{
			canAllItemsBePresented = false
			break
		}
	}

	if ( canAllItemsBePresented )
	{
		StoreInspectMenu_SetStoreOfferData( [offer] )
		AdvanceMenu( GetMenu( "StoreInspectMenu" ) )
	}
	else
	{
		PurchaseDialogConfig pdc
		pdc.offer = offer
		pdc.quantity = 1
		PurchaseDialog( pdc )
	}

}

void function AddItemToFakeOffer( GRXScriptOffer offer, ItemFlavor itemFlav )
{
	if ( !StoreInspectMenu_IsItemPresentationSupported( itemFlav ) )
	{
		Warning( "item is unsupported right now, skipping for now, support will be added later. item:", string(ItemFlavor_GetAsset( itemFlav )) )
		return
	}

	offer.output.flavors.append( itemFlav )
	offer.output.quantities.append( 1 )

	GRXStoreOfferItem item
	item.itemType = GRX_OFFERITEMTYPE_DEFAULT
	item.itemQuantity = 1
	item.itemIdx = ItemFlavor_GetGRXIndex( itemFlav )

	offer.items.append( item )
}

bool function CheckIsGiftable()
{
	if ( s_inspectOffers.currentOffers.len() > 0 )
		return s_inspectOffers.currentOffers[0].isGiftable

	return false
}

#if DEV
void function DEV_PrintInspectedOffer()
{
	if ( s_inspectOffers.currentOffers.len() == 0 )
	{
		printt( "Must be viewing the store inspect menu to see the inspected offer" )
		return
	}

	GRXScriptOffer offer = s_inspectOffers.currentOffers[0]

	printt( "DEV_PrintInspectedOffer" )
	printt( "------------------------------------" )
	printt( "Name:", Localize( offer.titleText ) )
	printt( "Desc:", Localize( offer.descText ) )
	printt( "Item Count:", s_inspectOffers.itemCount )
	printt( "Offer Type:", offer.offerType == GRX_OFFERTYPE_DEFAULT ? "Default" : "Bundle" )
	printt( "Displayed Price:", s_inspectOffers.displayedPrice )
	printt( "Original Price:", s_inspectOffers.originalPrice )
	printt( "Discount Pct:", s_inspectOffers.discountPct )
	printt( "Limit:", s_inspectOffers.purchaseLimit )
	printt( "IsAvailable:", offer.isAvailable )
	printt( "Unavailable Reason:", Localize( offer.unavailableReason ) )
	printt( "------------------------------------" )
	printt( "Item Flavors:" )
	foreach ( ItemFlavor flav in s_inspectOffers.itemFlavors )
	{
		printt( ItemFlavor_GetGRXAlias( flav ), "[", ItemFlavor_GetGRXIndex( flav ), "]" )
	}
	printt( "------------------------------------" )

	                                                                                                               
	                                                                                      
}

void function DEV_DisplayAllInspectElements( bool shouldShow )
{
	Hud_SetVisible( file.itemGrid, shouldShow )
	Hud_SetVisible( file.itemInfo, shouldShow )
	Hud_SetVisible( s_inspectUIData.discountInfo, shouldShow )
}

void function DEV_AddFakeItemToOffer( string grxRef )
{
	ItemFlavor flav = DEV_GetItemFlavorByGRXRef( grxRef )
	array<GRXScriptOffer> fakeOffers = clone s_inspectOffers.currentOffers
	fakeOffers[0].output.flavors.append( flav )
	fakeOffers[0].output.quantities.append( 1 )
	GRXStoreOfferItem item
	item.itemType = GRX_OFFERITEMTYPE_DEFAULT
	item.itemQuantity = 1
	item.itemIdx = ItemFlavor_GetGRXIndex( flav )
	fakeOffers[0].items.append( item )
	StoreInspectMenu_SetStoreOfferData( fakeOffers )
	StoreInspectMenu_OnGRXUpdated()
	                                                                                   
	                                                                      
}


void function DEV_AddFakeItemsToOffer()
{
	const array<string> fakeGRXRefs =
	[
		                       
		                       
		                       
		                       
		                       
		                            
		                                 
		                                 
		                                
		                                
		                                    
		                                     
		                                    
		                                  
		                                    
		                                      
		                                        
		                                                      
		                                       
		                                  
		                                     
		                                        
		                                  
		                                     
		                                    
		                                 

		"sticker_rare_01",
		"sticker_rare_02",
		"sticker_epic_01",
		"sticker_epic_02",
		"sticker_epic_bangalore",

		                                  
		                              
		                              
		                              
		                     
		                              
		                             
		                            
		                                 
		                              
		                              

		                  
		                                     
		                                    
		                                   
		                                     
		                                 
		                                    

		             
		                      
		                     
		                     
		                      
		                     
		                       
		                   
		                      
		                      
		                   
		                       

		             		
		                               

		               
		                        
		                        

                         
                                           

		            
		                                        

		              
		                            

                        
                                                

		         
		                                                

                
                                                 
                                                      

		              
		                                  
		                             

		                
		                          
		                                   
		                                  
		                              

		                   
		                                          
		                                         
		                                              
		                                              
		                                          
		                                            
		                                                
		                                         
		                                              
		                                     
		                                             
		                                               
		                                          
		                                                  
		                                          
		                                        
		                                      
		                                               
		                                           
		                                                
	]

	const int MAX_GRID_ITEMS = ITEM_GRID_ROWS * ITEM_GRID_COLUMNS
	array<GRXScriptOffer> fakeOffers = clone s_inspectOffers.currentOffers
	foreach ( string grxRef in fakeGRXRefs )
	{
		if ( fakeOffers[0].output.flavors.len() >= MAX_GRID_ITEMS )
			continue

		ItemFlavor flav = DEV_GetItemFlavorByGRXRef( grxRef )
		fakeOffers[0].output.flavors.append( flav )
		fakeOffers[0].output.quantities.append( 1 )
		GRXStoreOfferItem item
		item.itemType = GRX_OFFERITEMTYPE_DEFAULT
		item.itemQuantity = 1
		item.itemIdx = ItemFlavor_GetGRXIndex( flav )
		fakeOffers[0].items.append( item )
	}

	StoreInspectMenu_SetStoreOfferData( fakeOffers )
	StoreInspectMenu_OnGRXUpdated()
}
#endif       