global function InitGiftingDialog
global function OpenGiftingDialog
global function GiftingDialog_UpdateEligibilityInformation

struct
{
	var menu
	var dialogContent
	var discountInfo
	var friendNameField
	var friendNameFieldFrame
	var friendNameFieldSearchButton
	var searchIcon
	var sortButton

	var friendListPanel
	table<var, GiftingFriend> activeFriendButtons = {}
	EadpPeopleList& friendsData

	array<GiftingFriend> originalFriendList
	array<GiftingFriend> searchFriendList

	GiftingFriend ornull actionFriend

	var actionButton
	var purchaseButton

	bool sortOnline = true
	bool isProcessingSelection = false
	bool isVirtualKeyboardOpen = false

	string originalPriceStr
	GRXScriptOffer& originalOffer
	GRXScriptOffer& elegibleFriendOffer

	table<string, string>        slowScriptLowercaseNameCache
	array<GiftingFriend> recentlyGiftedFriends
} file

enum eFriendGiftStatus
{
	ONLINE = 0,
	ELIGIBLE = 1,
	NON_ELIGIBLE = 2,
	OFFLINE = 3
}

table<int,string> ruiQualityPrefix = { [eRarityTier.LEGENDARY] = "`3" , [eRarityTier.EPIC] = "`2", [eRarityTier.RARE] = "`1" }
const float CURRENCY_UPDATE_DELAY_TIME = 5
void function InitGiftingDialog( var newMenuArg )
{
	file.menu            = newMenuArg
	file.dialogContent   = Hud_GetChild( file.menu, "DialogContent" )
	file.discountInfo    = Hud_GetChild( file.menu, "DiscountInfo" )
	file.friendListPanel = Hud_GetChild( file.menu, "FriendList" )
	file.sortButton      = Hud_GetChild( file.menu, "ToggleOnlineOffline" )
	file.purchaseButton  = Hud_GetChild( file.menu, "BuyGiftButton" )
	file.friendNameField = Hud_GetChild( file.menu, "FriendNameTextEntry" )
	file.friendNameFieldFrame = Hud_GetChild( file.menu, "FriendNameTextEntryFrame" )
	file.friendNameFieldSearchButton = Hud_GetChild( file.menu, "FriendNameTextEntrySearchButton" )
	file.searchIcon =  Hud_GetChild( file.menu, "SearchIcon" )

	HudElem_SetRuiArg( file.purchaseButton, "buttonText", Localize( "#BUY_GIFT" ) )

	SetDialog( newMenuArg, true )
	AddMenuFooterOption( newMenuArg, LEFT, BUTTON_B, true, "#B_BUTTON_CLOSE", "#B_BUTTON_CLOSE" )
	AddMenuFooterOption( newMenuArg, LEFT, BUTTON_X, true, "#X_GIFT_INFO_TITLE", "#GIFT_INFO_TITLE", OpenGiftInfoPopUp )

	ToolTipData giftTooltipData
	giftTooltipData.titleText = Localize( "#GIFT_TOOLTIP_TITLE" )
	giftTooltipData.descText = Localize( "#GIFT_TOOLTIP_DESC" )
	giftTooltipData.tooltipFlags = giftTooltipData.tooltipFlags | eToolTipFlag.SOLID
	giftTooltipData.tooltipStyle = eTooltipStyle.DEFAULT
	Hud_SetToolTipData( file.discountInfo, giftTooltipData )

	AddMenuEventHandler( file.menu, eUIEvent.MENU_CLOSE, GiftingMenu_OnClose )

	AddButtonEventHandler( file.sortButton, UIE_CLICK, ToggleButton_OnActive )
	AddButtonEventHandler( file.purchaseButton, UIE_CLICK, GiftPurchase_OnActive )
	AddButtonEventHandler( file.friendNameField, UIE_CHANGE, FriendName_OnChanged )
	AddButtonEventHandler( file.friendNameFieldSearchButton, UIE_CLICK, FocusSearchBar_OnClick )

	AddUICallback_InputModeChanged( UpdateSearchBar_OnInputChanged )
}

void function OpenGiftingDialog( GRXScriptOffer offer )
{
	Assert( offer.isGiftable, "Tried to open gift dialog on non giftable offer" )
	AdvanceMenu( file.menu )
	RunClientScript( "DisableModelTurn" )
	RegisterButtonPressedCallback( BUTTON_Y, FocusSearchBar_OnClick )
	HudElem_SetRuiArg( file.dialogContent, "qualityText", GetFormatedQualityStringFromOffer( offer ) )
	HudElem_SetRuiArg( file.dialogContent, "isBattlePass",  ItemFlavor_IsBattlepass( offer.output.flavors[0] ) )

	string offerTitle = Localize( offer.titleText )

	if  ( offer.items[0].itemQuantity > 1 && GRXOffer_ContainsOnlySinglePack( offer ) )
		offerTitle = Localize( "#GIFT_PACK_QUANTITY_S_N", offerTitle, offer.items[0].itemQuantity )

	HudElem_SetRuiArg( file.dialogContent, "messageText", offerTitle )
	HudElem_SetRuiArg( file.dialogContent, "friendSelectText", Localize( "#GIFT_DIALOG_SELECT_FRIEND" ) )
	string price = GetPremiumPriceString( offer )

	HudElem_SetRuiArg( file.discountInfo, "canAfford", true )
	HudElem_SetRuiArg( file.discountInfo, "isGiftable", true )
	Hud_SetVisible( file.discountInfo, true )
	HudElem_SetRuiArg( file.discountInfo, "hideDisclaimers", true )
	HudElem_SetRuiArg( file.discountInfo, "discountPct", "0" )

	Hud_SetLocked( file.purchaseButton, true )

	ItemFlavorBag originalPriceFlavBag
	if ( offer.originalPrice != null )
		originalPriceFlavBag = expect ItemFlavorBag( offer.originalPrice )
	file.originalPriceStr = GRX_GetFormattedPrice( originalPriceFlavBag, 1 )

	string displayDiscountStr = file.originalPriceStr
	if ( offer.items.len() == 1 )
	{
		displayDiscountStr = price
		HudElem_SetRuiArg( file.discountInfo, "discountPct", GetOfferDiscountPct( offer ) )
	}

	HudElem_SetRuiArg( file.discountInfo, "originalPrice", Localize( file.originalPriceStr ) )
	HudElem_SetRuiArg( file.discountInfo, "discountedPrice", Localize( displayDiscountStr ) )
	if ( file.originalPriceStr == "")
		HudElem_SetRuiArg( file.discountInfo, "discountedPrice", Localize( price ) )

	file.originalOffer       = offer
	file.elegibleFriendOffer = clone offer
	UpdateFriendsList()
	file.originalFriendList  = CreateNewFriendlistWithAllEntries()
	file.searchFriendList = clone file.originalFriendList
	file.isVirtualKeyboardOpen = false
	UpdateSearchBar_OnInputChanged( IsControllerModeActive() )
	FriendName_OnChanged( null )
	Gifting_MenuUpdate()
}

void function FriendButton_Init( var button, GiftingFriend friend )
{
	Gifting_SetupFriendButton( button, friend )

	if ( file.actionButton == button )
		return

	var rui = Hud_GetRui( button )
	EadpPresenceData presence = friend.activePresence

	string friendName = presence.name
	RuiSetString( rui, "buttonText", friendName )

	string platformString = CrossplayUserOptIn() ? PlatformIDToIconString( presence.hardware ) : ""
	RuiSetString( rui, "platformString", platformString )

	if ( friend.activePresence.online )
	{
		RuiSetString( rui, "statusText", "#PRESENSE_ONLINE" )
		RuiSetInt( rui, "status", eFriendGiftStatus.ONLINE )
	}
	else
	{
		RuiSetString( rui, "statusText", "#PRESENSE_OFFLINE" )
		RuiSetInt( rui, "status", eFriendGiftStatus.OFFLINE )
	}
}

void function Gifting_MenuUpdate()
{
	if ( !IsValid( file.menu ) )
		return

	var scrollPanel = Hud_GetChild( file.friendListPanel, "ScrollPanel" )
	int totalFriends = Gifting_GetTotalFriendCount()
	         
	foreach ( int friendIdx, GiftingFriend unused in file.searchFriendList )
	{
		if ( !Hud_HasChild( scrollPanel,  "GridButton" + friendIdx ) )
			continue

		var button = Hud_GetChild( scrollPanel, "GridButton" + friendIdx )
		Gifting_RemoveFriendButton( button )
	}

	HudElem_SetRuiArg( file.dialogContent, "friendFound", totalFriends > 0 )
	HudElem_SetRuiArg( file.dialogContent, "giftsLeftText", Localize( "#GIFTS_LEFT_FRACTION", Gifting_GetRemainingDailyGifts() ) )


	Hud_InitGridButtons( file.friendListPanel, totalFriends )

	if ( file.sortOnline )
		Gifting_SortFriendsOnline()
	else
		Gifting_AlphabetizeFriends()
	HudElem_SetRuiArg( file.sortButton, "showAll", file.sortOnline )

	foreach ( int friendIdx, GiftingFriend friend in file.searchFriendList )
	{
		if ( !Hud_HasChild( scrollPanel,  "GridButton" + friendIdx ) )
			continue

		var button = Hud_GetChild( scrollPanel, "GridButton" + friendIdx )
		FriendButton_Init( button, friend )
	}
}

string function GetFormatedQualityStringFromOffer( GRXScriptOffer offer )
{
	string formatedString = ""

	if ( ItemFlavor_IsBattlepass( offer.output.flavors[0] ) )
		return "`1" + Localize( ItemQuality_GetBattlePassQualityName( offer.output.flavors[0] ) )

	table<int,int> qualityCounter = { [eRarityTier.LEGENDARY] = 0 , [eRarityTier.EPIC] = 0 , [eRarityTier.RARE] = 0 }
	int quality = 0

	foreach ( ItemFlavor outputFlav in offer.output.flavors )
	{
		quality = ItemFlavor_GetQuality( outputFlav, 0 )
		if ( quality == eRarityTier.COMMON )
			continue
		Assert( quality < 4, format("Attempted to gift an item with unsupported quality enum %i.\nOffer Alias: %s", quality, offer.offerAlias ) )
		qualityCounter[quality] = qualityCounter[quality] + 1
	}

	for ( int i = 3; i > 0; i-- )
	{
		int itemQuantity = qualityCounter[i]
		if ( itemQuantity == 0 )
			continue

		string commaSeparator = ""

		if ( i - 1 > 0 )
			if ( qualityCounter[i - 1] != 0 )
				commaSeparator = ", "

		if ( i - 2 > 0 )
			if ( qualityCounter[i - 2] != 0 )
				commaSeparator = ", "

		string quantityDisplay = string( itemQuantity ) + " "
		if ( itemQuantity == 1 )
			quantityDisplay = ""

		formatedString += ruiQualityPrefix[i] + quantityDisplay + Localize ( ItemQuality_GetQualityName( i ) ) + commaSeparator
	}

	return formatedString
}

string function GetOfferDiscountPct( GRXScriptOffer offer )
{
	ItemFlavorBag originalPriceFlavBag
	if ( offer.originalPrice != null )
		originalPriceFlavBag = expect ItemFlavorBag( offer.originalPrice )

	int discountPct = 0
	if ( originalPriceFlavBag.quantities.len() > 0 )
	{
		int originalPrice = originalPriceFlavBag.quantities[0]
		int displayedPrice = offer.prices[0].quantities[0]
		float discount = 100 - ( offer.prices[0].quantities[0] / (originalPrice * 1.0) * 100 )
		discountPct = int( floor( discount ) )                                                      
	}
	return string(discountPct)
}

int function Gifting_GetTotalFriendCount()
{
	return file.searchFriendList.len()
}

void function Gifting_SortFriendsOnline()
{
	                                             
	file.searchFriendList.sort( SortGiftFriendGroupStatus )
}

void function Gifting_AlphabetizeFriends()
{
	                           
	file.searchFriendList.sort( SortGiftFriendAlphabetize )
}

void function GiftPurchase_OnActive( var button )
{
	if ( Hud_IsLocked( button ) )
	{
		EmitUISound( "menu_deny" )
		return
	}

	if ( !CanLocalPlayerGift() )
	{
		EmitUISound( "menu_deny" )
		CloseActiveMenu()
		return
	}

	GRXScriptOffer offer = file.elegibleFriendOffer
	if ( GRXOffer_ContainsOnlySinglePack( offer ) )
		HandleGiftPurchaseOperation( offer )
	else if ( GRXOffer_ContainsPack( offer ) )
		OpenPurchaseConfirmationDialog()
	else
		HandleGiftPurchaseOperation( offer )
}

void function FriendButton_OnActivate( var button )
{
	if ( file.actionButton == button )
		return

	if ( file.isProcessingSelection )
		return

	GiftingFriend activeFriend = file.activeFriendButtons[button]
	file.actionButton = button
	file.actionFriend = activeFriend

	foreach ( GiftingFriend friend in file.recentlyGiftedFriends )
	{
		if ( friend.activeNucleusId == activeFriend.activeNucleusId )
		{
			SetEligibilityDisplayNonEligible()
			return
		}
	}

	file.isProcessingSelection = true
	Hud_SetLocked( file.purchaseButton, true )
	HudElem_SetRuiArg( button, "isProcessing", file.isProcessingSelection )

	string alias = file.originalOffer.offerAlias

	if ( activeFriend.activePresence.hardware == HARDWARE_PC_STEAM )
		activeFriend.activePresence.hardware = HARDWARE_PC

	GetGiftOfferEligibility( alias, activeFriend.activePresence.hardware, activeFriend.activeNucleusId )
}

void function FriendName_OnChanged( var button )
{
	int unicodeLen = Hud_GetUnicodeLen( file.friendNameField )
	if ( unicodeLen > 0 )
	{
		HudElem_SetRuiArg( file.friendNameFieldSearchButton, "buttonText", "#Y_SEARCH_CLEAR" )
		Hud_Hide( file.searchIcon )
	}
	else
	{
		HudElem_SetRuiArg( file.friendNameFieldSearchButton, "buttonText", "#Y_SEARCH_FRIEND" )
		Hud_Show( file.searchIcon )
	}

	if ( unicodeLen > 0 && unicodeLen < 1 )
		return

	file.actionButton = null
	file.searchFriendList.clear()
	string friendName = strip( Hud_GetUTF8Text( file.friendNameField ) )

	foreach ( GiftingFriend friend in file.originalFriendList )
	{
		int stringIndex = friend.activePresence.name.find( friendName )
		if ( stringIndex == 0 )
			file.searchFriendList.append( friend )
	}
	thread function() : () {
		WaitFrame()
		Gifting_MenuUpdate()
	}()                                                                                                                     
}

void function Gifting_SetupFriendButton( var button, GiftingFriend friend )
{
#if DEV
	Assert( !( button in file.activeFriendButtons ) )
#endif
	if ( button in file.activeFriendButtons )
		return

	file.activeFriendButtons[button] <- friend
	Hud_AddEventHandler( button, UIE_CLICK, FriendButton_OnActivate )
}

void function Gifting_RemoveFriendButton( var button )
{
#if DEV
	Assert( button in file.activeFriendButtons )
#endif
	if ( !( button in file.activeFriendButtons ) )
		return

	delete file.activeFriendButtons[button]
	Hud_RemoveEventHandler( button, UIE_CLICK, FriendButton_OnActivate )
}

void function ToggleButton_OnActive( var button )
{
	if ( file.isProcessingSelection )
		return

	file.sortOnline = !file.sortOnline
	FriendDataReferenceReset()

	Gifting_MenuUpdate()
}

void function GiftingDialog_UpdateEligibilityInformation( GRXGetOfferInfo offerInfo )
{
	file.isProcessingSelection = false
	if ( GetActiveMenu() != file.menu )
		return

	if ( offerInfo.isEligible )
	{
		array<ItemFlavorBag> friendBags = clone GetBagFromOfferArrayPrice( offerInfo.prices )
		file.elegibleFriendOffer.prices = friendBags
	}

	Gifting_MenuUpdate()
	UpdateEligibilityDisplay( offerInfo )
}

void function UpdateEligibilityDisplay( GRXGetOfferInfo selectedOfferInfo )
{
	if ( file.isProcessingSelection )
		return
	if ( file.actionFriend == null )
		return
	else if ( file.actionButton == null )
		return

	GiftingFriend ornull friend = file.actionFriend
	expect GiftingFriend( friend )

	HudElem_SetRuiArg( file.actionButton, "isProcessing", file.isProcessingSelection )
	HudElem_SetRuiArg( file.dialogContent, "friendSelectText", Localize( "#GIFT_DIALOG_SELECT_FRIEND" ) )
	var buttonRui = Hud_GetRui( file.actionButton )
	var dialogRui = Hud_GetRui( file.dialogContent )
	if ( selectedOfferInfo.isEligible )
	{
		RuiSetString( dialogRui, "friendSelectText", Localize( "#GIFT_DIALOG_FRIEND_SELECTED", friend.activePresence.name ) )
		RuiSetString( buttonRui, "statusText", Localize( "#GIFT_ELEGIBLE" ) )
		RuiSetInt( buttonRui, "status", eFriendGiftStatus.ELIGIBLE )

		GRXScriptOffer offer = file.elegibleFriendOffer

		string displayPriceStr = GetPremiumPriceString( offer )
		HudElem_SetRuiArg( file.discountInfo, "originalPrice", Localize( file.originalPriceStr ) )
		HudElem_SetRuiArg( file.discountInfo, "discountedPrice", Localize( displayPriceStr ) )
		HudElem_SetRuiArg( file.discountInfo, "discountPct", GetOfferDiscountPct( offer ) )

		Hud_SetLocked( file.purchaseButton, false )
	}
	else
	{
		RuiSetString( dialogRui, "friendSelectText", Localize( "#GIFT_DIALOG_SELECT_ANOTHER_FRIEND" ) )
		RuiSetString( buttonRui, "statusText", Localize( "#GIFT_NOT_ELEGIBLE" ) )
		RuiSetInt( buttonRui, "status", eFriendGiftStatus.NON_ELIGIBLE )
	}
}

void function SetEligibilityDisplayNonEligible()
{
	var buttonRui = Hud_GetRui( file.actionButton )
	var dialogRui = Hud_GetRui( file.dialogContent )
	RuiSetString( dialogRui, "friendSelectText", Localize( "#GIFT_DIALOG_SELECT_ANOTHER_FRIEND" ) )
	RuiSetString( buttonRui, "statusText", Localize( "#GIFT_NOT_ELEGIBLE" ) )
	RuiSetInt( buttonRui, "status", eFriendGiftStatus.NON_ELIGIBLE )
}

int function SortGiftFriendAlphabetize( GiftingFriend a, GiftingFriend b )
{
	string tempNameA = a.activePresence.name
	string tempNameB = b.activePresence.name
	#if NX_PROG
		tempNameA = a.activePresence.name + a.eadpData.eaid
		tempNameB = b.activePresence.name + b.eadpData.eaid
	#endif
	if ( !(tempNameA in file.slowScriptLowercaseNameCache) )
		file.slowScriptLowercaseNameCache[tempNameA] <- tempNameA.tolower()
	if ( !(tempNameB in file.slowScriptLowercaseNameCache) )
		file.slowScriptLowercaseNameCache[tempNameB] <- tempNameB.tolower()

	if ( file.slowScriptLowercaseNameCache[tempNameA] > file.slowScriptLowercaseNameCache[tempNameB] )
		return 1

	if ( file.slowScriptLowercaseNameCache[tempNameA] < file.slowScriptLowercaseNameCache[tempNameB] )
		return -1

	return 0
}

int function SortGiftFriendGroupStatus( GiftingFriend a, GiftingFriend b )
{
	int statusA = 0
	int statusB = 0

	EadpPresenceData presenceA = a.activePresence
	EadpPresenceData presenceB = b.activePresence

	if ( presenceA.online )
		statusA = eFriendStatus.ONLINE
	else
		statusA = eFriendStatus.OFFLINE

	if ( presenceB.online )
		statusB = eFriendStatus.ONLINE
	else
		statusB = eFriendStatus.OFFLINE


	if ( statusA < statusB )
		return -1
	else if ( statusB < statusA )
		return 1

	string tempNameA = a.activePresence.name
	string tempNameB = b.activePresence.name
	#if NX_PROG
		tempNameA = a.activePresence.name + a.eadpData.eaid
		tempNameB = b.activePresence.name + b.eadpData.eaid
	#endif
	if ( !(tempNameA in file.slowScriptLowercaseNameCache) )
		file.slowScriptLowercaseNameCache[tempNameA] <- tempNameA.tolower()
	if ( !(tempNameB in file.slowScriptLowercaseNameCache) )
		file.slowScriptLowercaseNameCache[tempNameB] <- tempNameB.tolower()

	if ( file.slowScriptLowercaseNameCache[tempNameA] > file.slowScriptLowercaseNameCache[tempNameB] )
		return 1

	if ( file.slowScriptLowercaseNameCache[tempNameA] < file.slowScriptLowercaseNameCache[tempNameB] )
		return -1

	return 0
}

array<GiftingFriend> function CreateNewFriendlistWithAllEntries()
{
	EadpPeopleList eadFriendlist = EADP_GetFriendsListWithOffline()
	array<GiftingFriend> friendList

	foreach ( EadpPeopleData person in eadFriendlist.people )
	{
		bool wasXbox = false                             
		bool wasPSN = false

		if ( !HasFriendshipTenureBeenLongEnough( person.friendCreationTime ) )
			continue

		foreach ( EadpPresenceData presence in person.presences )
		{
			GiftingFriend newFriend
			newFriend.eadpData       = person
			newFriend.activePresence = presence

			bool isPSN = ( presence.hardware == HARDWARE_PS4 || presence.hardware == HARDWARE_PS5 )
			bool isXbox = ( presence.hardware == HARDWARE_XBOXONE || presence.hardware == HARDWARE_XB5 )

			if ( person.ea_pid != "0" && presence.hardware == HARDWARE_PC && person.ea_has_played != playedApexFalse )
			{
				newFriend.activeNucleusId = person.ea_pid
				friendList.push( newFriend )
			}
			else if ( person.psn_pid != "0" && isPSN && !wasPSN && person.psn_has_played != playedApexFalse )
			{
				bool isAnyOnline = false
				foreach ( EadpPresenceData activePresence in person.presences )
				{
					bool isAnyPSN = ( activePresence.hardware == HARDWARE_PS4 || activePresence.hardware == HARDWARE_PS5 )
					if ( isAnyPSN )
						if ( activePresence.online || activePresence.away || activePresence.ingame )
							isAnyOnline = true
				}

				newFriend.activePresence.online = isAnyOnline
				newFriend.activeNucleusId = person.psn_pid
				friendList.push( newFriend )
				wasPSN = true
			}
			else if ( person.steam_pid != "0" && presence.hardware == HARDWARE_PC_STEAM  && person.steam_has_played != playedApexFalse  )
			{
				newFriend.activeNucleusId = person.ea_pid                                                                                       
				friendList.push( newFriend )
			}
			else if ( person.xbox_pid != "0" && isXbox && !wasXbox && person.xbox_has_played != playedApexFalse )
			{
				bool isAnyOnline = false
				foreach ( EadpPresenceData activePresence in person.presences )
				{
					bool isAnyXbox = ( activePresence.hardware == HARDWARE_XBOXONE || activePresence.hardware == HARDWARE_XB5 )
					if ( isAnyXbox )
						if ( activePresence.online || activePresence.away || activePresence.ingame )
							isAnyOnline = true
				}

				newFriend.activePresence.online = isAnyOnline
				newFriend.activeNucleusId = person.xbox_pid
				friendList.push( newFriend )
				wasXbox = true
			}
			else if ( person.switch_pid != "0" && presence.hardware == HARDWARE_SWITCH && person.switch_has_played != playedApexFalse )
			{
				newFriend.activeNucleusId = person.switch_pid
				friendList.push( newFriend )
			}
		}
	}
	return friendList
}

array<ItemFlavorBag> function GetBagFromOfferArrayPrice( array< array< int > > prices )
{
	int quantity = INT_MAX

	foreach ( int priceIdx, array<int> currencyArray in prices )
	{
		if ( currencyArray[GRX_CURRENCY_PREMIUM] != 0 )
			quantity = minint( quantity, currencyArray[GRX_CURRENCY_PREMIUM] )
	}
	Assert( 0 < quantity && quantity < INT_MAX, "Price quantity is Invalid." )

	ItemFlavorBag price
	array<ItemFlavorBag> bagPrices

	price.flavors.append( GRX_CURRENCIES[GRX_CURRENCY_PREMIUM] )
	price.quantities.append( quantity )
	bagPrices.append( price )
	return bagPrices
}

void function GiftingMenu_OnClose()
{
	FriendDataReferenceReset()
	file.recentlyGiftedFriends.clear()
	DeregisterButtonPressedCallback( BUTTON_Y, FocusSearchBar_OnClick )
	RunClientScript( "EnableModelTurn" )
}

void function FriendDataReferenceReset()
{
	file.isProcessingSelection = false
	if ( file.actionButton != null )
		HudElem_SetRuiArg( file.actionButton, "isProcessing", file.isProcessingSelection )
	HudElem_SetRuiArg( file.dialogContent, "friendSelectText", Localize( "#GIFT_DIALOG_SELECT_FRIEND" ) )

	if ( file.originalPriceStr != "" )
	{
		HudElem_SetRuiArg( file.discountInfo, "originalPrice", Localize( file.originalPriceStr ) )
		HudElem_SetRuiArg( file.discountInfo, "discountPct", "0" )

		string displayDiscountStr = file.originalPriceStr
		string price = GetPremiumPriceString( file.originalOffer )
		if ( file.originalOffer.items.len() == 1 )
		{
			displayDiscountStr = price
			HudElem_SetRuiArg( file.discountInfo, "discountPct", GetOfferDiscountPct( file.originalOffer ) )
		}
		HudElem_SetRuiArg( file.discountInfo, "discountedPrice", Localize( displayDiscountStr ) )
	}

	Hud_SetLocked( file.purchaseButton, true )

	file.actionFriend = null
	file.actionButton = null
}

string function GetPremiumPriceString( GRXScriptOffer offer )
{
	ItemFlavorBag premiumBag
	foreach ( ItemFlavorBag price in offer.prices )
	{
		if ( price.flavors[0] != GRX_CURRENCIES[GRX_CURRENCY_PREMIUM] )
			continue

		premiumBag = price
	}
	return GRX_GetFormattedPrice( premiumBag, 1 )
}

void function Delayed_UpdateCurrency()
{
	wait CURRENCY_UPDATE_DELAY_TIME
	GRX_GetCurrencyBalances()                   
	UpdateActiveUserInfoPanels()
}

void function OpenPurchaseConfirmationDialog()
{
	PurchaseDialogConfig cfg
	cfg.offer =  file.elegibleFriendOffer
	cfg.friend =  file.actionFriend
	cfg.markAsNew = false
	cfg.onPurchaseResultCallback = void function( bool wasPurchaseSuccessful ) {
		if ( wasPurchaseSuccessful )
		{
			file.recentlyGiftedFriends.append( expect GiftingFriend( file.actionFriend ) )
			FriendDataReferenceReset()
			thread Delayed_UpdateCurrency()
		}
	}
	PurchaseDialog( cfg )
}

void function HandleGiftPurchaseOperation( GRXScriptOffer offer )
{
	int queryGoal = GRX_HTTPQUERYGOAL_GIFT_OFFER
	Hud_SetEnabled( file.purchaseButton, false )
	HudElem_SetRuiArg( file.purchaseButton, "isProcessing", true )
	HudElem_SetRuiArg( file.purchaseButton, "processingState", ePurchaseDialogStatus.WORKING )
	HudElem_SetRuiArg( file.purchaseButton, "buttonText", "" )

	ItemFlavorBag price = offer.prices[0]

	ScriptGRXOperationInfo operation
	operation.expectedQueryGoal = queryGoal
	operation.doOperationFunc = (void function( int opId ) : (queryGoal, offer, price ) {
		GRX_PurchaseOffer( opId, queryGoal, offer, price, 1, file.actionFriend )
	})

	operation.onDoneCallback = (void function( int status ) : ( offer, price )
	{
		bool wasSuccessful = (status == eScriptGRXOperationStatus.DONE_SUCCESS)
		int state
		string purchaseSound = GRXCurrency_GetPurchaseSound( GRX_CURRENCIES[GRX_CURRENCY_PREMIUM] )

		if ( wasSuccessful )
		{
			FriendDataReferenceReset()
			Remote_ServerCallFunction( "ClientCallback_lastSeenPremiumCurrency" )
			state = ePurchaseDialogStatus.FINISHED_SUCCESS
			thread Delayed_UpdateCurrency()
		}
		else
		{
			purchaseSound = "menu_deny"
			state = ePurchaseDialogStatus.FINISHED_FAILURE
		}
		HudElem_SetRuiArg( file.purchaseButton, "processingState", state )
		EmitUISound( purchaseSound )
		thread Delayed_CloseMenuAfterPurchase()
	})
	QueueGRXOperation( GetLocalClientPlayer(), operation )
}

void function Delayed_CloseMenuAfterPurchase()
{
	wait 1.0
	if ( file.menu == GetActiveMenu() )
		thread CloseActiveMenu()
	if ( GetActiveMenu() == GetMenu( "ConfirmPackPurchaseDialog" ) )
		thread CloseActiveMenu()

	HudElem_SetRuiArg( file.purchaseButton, "isProcessing", false )
	HudElem_SetRuiArg( file.purchaseButton, "buttonText", Localize( "#BUY_GIFT" ) )
	Hud_SetEnabled( file.purchaseButton, true )
}

void function UpdateSearchBar_OnInputChanged( bool isController )
{
	int width = 367                                          
	int buttonWidth = 126               
	int x = 0
	if ( isController )
	{
		width = 367 - 126
		x = -buttonWidth/2
	}
	Hud_SetWidth( file.friendNameField, ContentScaledXAsInt( width ) )
	Hud_SetWidth( file.friendNameFieldFrame, ContentScaledXAsInt( width ) )
	Hud_SetX( file.friendNameField, ContentScaledXAsInt( x ) )
	Hud_SetVisible( file.friendNameFieldSearchButton, isController )
}

void function FocusSearchBar_OnClick( var button )
{
	Hud_SetFocused( file.friendNameField )
	int unicodeLen = Hud_GetUnicodeLen( file.friendNameField )
	if ( unicodeLen > 0 )
	{
		Hud_SetUTF8Text( file.friendNameField, "" )
		FriendName_OnChanged( null )
	}
	else if ( button == null )
	{
		Hud_OpenTextEntryKeyboard( file.friendNameField )
	}
}