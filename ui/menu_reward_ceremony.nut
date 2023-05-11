  

global function InitRewardCeremonyMenu
global function ShowRewardCeremonyDialog
global function ShowGiftCeremonyDialog

#if DEV
global function DEV_TestRewardCeremonyDialog
#endif


struct
{
	var menu
	var awardPanel
	var awardHeader
	var continueButton
	var prevGiftButton
	var nextGiftButton
	var controlIndicator

	string                  headerText
	string 					originalTitleText
	string                  titleText
	string                  descText

	array<BattlePassReward> displayAwards = []

	int						activeGiftIndex
	int						numGifts
	int						highestIndex

	bool                    isForBattlePass
	bool                    isForQuest
	bool                    noShowLow
	bool					isGift
	bool 					giftChangeInputsRegistered

	bool 					isCharacter
	bool 					isBattlepass
	ItemFlavor&				characterToJumpTo

	table<var, BattlePassReward> buttonToItem
} file


void function InitRewardCeremonyMenu( var newMenuArg )
                                              
{
	var menu = GetMenu( "RewardCeremonyMenu" )
	file.menu = menu

	file.awardHeader = Hud_GetChild( menu, "Header" )
	file.awardPanel = Hud_GetChild( menu, "AwardsList" )
	file.controlIndicator = Hud_GetChild( menu, "ControlIndicator" )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, PassAwardsDialog_OnOpen )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, PassAwardsDialog_OnClose )

	file.continueButton = Hud_GetChild( menu, "ContinueButton" )
	Hud_AddEventHandler( file.continueButton, UIE_CLICK, ContinueButton_OnActivate )

	AddMenuFooterOption( menu, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )

#if DEV
	AddMenuThinkFunc( newMenuArg, PassAwardsDialogAutomationThink )
#endif       

	file.prevGiftButton = Hud_GetChild( newMenuArg, "PrevGiftButton" )
	file.nextGiftButton = Hud_GetChild( newMenuArg, "NextGiftButton" )

	HudElem_SetRuiArg( file.prevGiftButton, "flipHorizontal", true )

	Hud_AddEventHandler( file.prevGiftButton, UIE_CLICK, Gift_NavLeft )
	Hud_AddEventHandler( file.nextGiftButton, UIE_CLICK, Gift_NavRight )

	Hud_Hide( file.prevGiftButton )
	Hud_Hide( file.nextGiftButton )
	Hud_Hide( file.controlIndicator )

}


void function ShowRewardCeremonyDialog( string headerText, string titleText, string descText, array<BattlePassReward> awards, bool isForBattlePass, bool isForQuest, bool noShowLow, bool playSound )
{
	file.headerText = headerText
	file.titleText = titleText
	file.descText = descText
	file.displayAwards = clone awards
	file.isForBattlePass = isForBattlePass
	file.isForQuest = isForQuest
	file.noShowLow = noShowLow
	file.isGift = false

	AdvanceMenu( GetMenu( "RewardCeremonyMenu" ) )

	if ( playSound )
	{
		ItemFlavor ornull activeBattlePass = GetActiveBattlePass()
		if ( activeBattlePass != null )
		{
			expect ItemFlavor( activeBattlePass )
			EmitUISound( GetGlobalSettingsString( ItemFlavor_GetAsset( activeBattlePass ), "levelUpSound" ) )
		}
	}
}

#if DEV
void function DEV_TestRewardCeremonyDialog( array<string> grxRefs, string headerText = "HEADER", string titleText = "TITLE", string descText = "DESC" )
{
	array<BattlePassReward> rewards
	foreach ( grxRef in grxRefs )
	{
		BattlePassReward info
		info.level = -1
		ItemFlavor flav = DEV_GetItemFlavorByGRXRef( grxRef )
		if ( ItemFlavor_GetType( flav ) == eItemType.character )
		{
			ItemFlavor overrideSkin = GetDefaultItemFlavorForLoadoutSlot( EHI_null, Loadout_CharacterSkin( flav ) )
			info.flav = overrideSkin
		}
		else
		{
			info.flav = DEV_GetItemFlavorByGRXRef( grxRef )
		}
		info.quantity = 1
		rewards.append( info )
	}

	bool isForBattlePass = true
	bool isForQuest = false

	ShowRewardCeremonyDialog(
		headerText,
		titleText,
		descText,
		rewards,
		isForBattlePass,
		isForQuest,
		true,
		true
	)
}
#endif

void function ShowGiftCeremonyDialog( string headerText, string titleText, string descText, array<BattlePassReward> awards )
{
	file.headerText = headerText
	file.originalTitleText = titleText
	file.titleText = titleText
	file.numGifts = PromoDialog_GetAllGifts().len()

	file.descText = descText
	file.displayAwards = clone awards

	file.activeGiftIndex = 0
	file.highestIndex = 0
	array<GRXScriptInboxMessage> AllGifts = PromoDialog_GetAllGifts()
	GRX_MarkGiftItemsAsSeen( AllGifts[0].timestamp, AllGifts[0].itemIndex )

	file.isGift = true
	file.isForBattlePass = true

	AdvanceMenu( GetMenu( "RewardCeremonyMenu" ) )

	Hud_Hide( file.prevGiftButton )
	Hud_Hide( file.nextGiftButton )
	Hud_Hide( file.controlIndicator )

	if ( file.numGifts > 1 )
	{
		Hud_Show( file.nextGiftButton )
		Hud_Show( file.controlIndicator )
	}

	ItemFlavor ornull activeBattlePass = GetActiveBattlePass()

	if ( activeBattlePass != null )
	{
		expect ItemFlavor( activeBattlePass )
		EmitUISound( GetGlobalSettingsString( ItemFlavor_GetAsset( activeBattlePass ), "levelUpSound" ) )
	}
}

void function Gift_NavLeft( var button )
{
	ChangeGift( -1 )
}

void function Gift_NavRight( var button )
{
	ChangeGift( 1 )
}

void function Gift_NavLeftOnInput()
{
	ChangeGift( -1 )
}

void function Gift_NavRightOnInput()
{
	ChangeGift( 1 )
}

void function ChangeGift( int delta )
{
	Assert( delta == -1 || delta == 1 )

	int newGiftIndex = file.activeGiftIndex + delta
	file.isCharacter = false
	file.isBattlepass = false

	if ( newGiftIndex < 0 || newGiftIndex >= file.numGifts )
		return

	if ( newGiftIndex <= 0 )
		Hud_Hide( file.prevGiftButton )

	if ( newGiftIndex >= file.numGifts -1 )
		Hud_Hide( file.nextGiftButton )

	if ( newGiftIndex > 0 )
		Hud_Show( file.prevGiftButton )

	if ( newGiftIndex < file.numGifts -1 )
		Hud_Show( file.nextGiftButton )

	file.activeGiftIndex = newGiftIndex

	EmitUISound( "UI_Menu_MOTD_Tab" )

	array<GRXScriptInboxMessage> AllGifts = PromoDialog_GetAllGifts()
	array<ItemFlavor> items

	foreach( int index in AllGifts[file.activeGiftIndex].itemIndex )
	{
		items.append( GetItemFlavorByGRXIndex( index ) )
	}

	array<BattlePassReward> RewardInput

	for ( int i = 0; i < items.len(); i++ )
	{
		BattlePassReward tempReward
		tempReward.flav = items[i]
		tempReward.isPremium = false
		tempReward.quantity = AllGifts[ file.activeGiftIndex ].itemCount[i]
		tempReward.level = -1
		RewardInput.append( tempReward )
	}

	file.displayAwards = clone RewardInput

	if ( newGiftIndex > file.highestIndex )
	{
		file.highestIndex = newGiftIndex
	}

	CheckForCharacterOrBattlepass()

	file.titleText =  Localize( "#INBOX_REDEMPTION_HEADER",  file.activeGiftIndex + 1,  PromoDialog_GetAllGifts().len() )

	GRX_MarkGiftItemsAsSeen( AllGifts[file.activeGiftIndex].timestamp, AllGifts[file.activeGiftIndex].itemIndex )

	PassAwardsDialog_UpdateAwards()
}

void function PassAwardsDialog_OnOpen()
{
	UI_SetPresentationType( ePresentationType.BATTLE_PASS )

	Assert( file.displayAwards.len() != 0 )

	if ( file.isForBattlePass )
	{
		ItemFlavor ornull bpFlav = GetPlayerLastActiveBattlePass( LocalClientEHI() )
		if ( bpFlav != null )
		{
			Remote_ServerCallFunction( "ClientCallback_UpdateBattlePassLastInfo", ItemFlavor_GetGUID( expect ItemFlavor(bpFlav) ) )
		}
	}

	RegisterButtonPressedCallback( BUTTON_A, ContinueButton_OnActivate )
	RegisterButtonPressedCallback( KEY_SPACE, ContinueButton_OnActivate )

	RegisterButtonPressedCallback( BUTTON_DPAD_LEFT, Gift_NavLeft )
	RegisterButtonPressedCallback( KEY_LEFT, Gift_NavLeft )

	RegisterButtonPressedCallback( BUTTON_DPAD_RIGHT, Gift_NavRight )
	RegisterButtonPressedCallback( KEY_RIGHT, Gift_NavRight)

	AddCallback_OnMouseWheelUp( Gift_NavLeftOnInput )
	AddCallback_OnMouseWheelDown( Gift_NavRightOnInput )

	PassAwardsDialog_UpdateAwards()

	file.giftChangeInputsRegistered  = true

	CheckForCharacterOrBattlepass()

	thread TrackDpadInput()
}

void function TrackDpadInput()
{
	bool canChangeGift = false

	while ( file.giftChangeInputsRegistered  )
	{
		float xAxis = InputGetAxis( ANALOG_RIGHT_X )

		if ( !canChangeGift )
			canChangeGift = fabs( xAxis ) < 0.5

		if ( canChangeGift )
		{
			if ( xAxis > 0.9 )
			{
				ChangeGift( 1 )
				canChangeGift = false
			}
			else if ( xAxis < -0.9 )
			{
				ChangeGift( -1 )
				canChangeGift = false
			}
		}

		WaitFrame()
	}
}

#if DEV
void function PassAwardsDialogAutomationThink( var menu )
{
	if (AutomateUi())
	{
		printt("PassAwardsDialogAutomationThink ContinueButton_OnActivate()")
		ContinueButton_OnActivate(null)
	}
}
#endif       

void function ContinueButton_OnActivate( var button )
{
	CloseActiveMenu()

	if ( file.isBattlepass )
	{
		JumpToSeasonTab()
		return
	}

	if ( file.isCharacter )
	{
		JumpToCharacterCustomize( file.characterToJumpTo )
		return
	}

	if ( file.isGift )
	{
		array<GRXScriptInboxMessage> tempGifts = GetGiftingInboxMessages()
		if ( tempGifts.len() > 0 )
		{
			AdvanceMenu( GetMenu( "PromoDialogUM" ) )
			ReturnToInbox()
		}
	}
}


void function PassAwardsDialog_OnClose()
{
	file.displayAwards = []

	DeregisterButtonPressedCallback( BUTTON_A, ContinueButton_OnActivate )
	DeregisterButtonPressedCallback( KEY_SPACE, ContinueButton_OnActivate )

	DeregisterButtonPressedCallback( BUTTON_DPAD_LEFT, Gift_NavLeft )
	DeregisterButtonPressedCallback( KEY_LEFT, Gift_NavLeft )

	DeregisterButtonPressedCallback( BUTTON_DPAD_RIGHT, Gift_NavRight )
	DeregisterButtonPressedCallback( KEY_RIGHT, Gift_NavRight )

	RemoveCallback_OnMouseWheelUp( Gift_NavLeftOnInput )
	RemoveCallback_OnMouseWheelDown( Gift_NavRightOnInput )

	if ( file.isGift )
	{
		PromoDialog_RemoveFromCache( file.highestIndex )
		                                                                                                              
		RunClientScript( "ClearBattlePassItem" )
	}

	file.giftChangeInputsRegistered  = false
	file.highestIndex = 0
}


void function PassAwardsDialog_UpdateAwards()
{
	HudElem_SetRuiArg( file.awardHeader, "headerText", file.headerText )
	HudElem_SetRuiArg( file.awardHeader, "titleText", file.titleText )
	HudElem_SetRuiArg( file.awardHeader, "descText", file.descText )
	var scrollPanel = Hud_GetChild( file.awardPanel, "ScrollPanel" )

	foreach ( button, _ in file.buttonToItem )
	{
		Hud_RemoveEventHandler( button, UIE_GET_FOCUS, PassAward_OnFocusAward )
	}

	file.buttonToItem.clear()
	int numAwards = file.displayAwards.len()

	bool showButtons = file.isForBattlePass || file.isForQuest

	if ( file.displayAwards.len() == 1 && ItemFlavor_GetType( file.displayAwards[0].flav ) == eItemType.account_currency )
		showButtons = true                                   

	int numButtons = numAwards
	if ( !showButtons )
	{
		numButtons = 0
		PresentItem( file.displayAwards[0].flav, file.displayAwards[0].level )
	}

	Hud_InitGridButtonsDetailed( file.awardPanel, numButtons, 1, maxint( 1, minint( numButtons, 8 ) ) )
	Hud_SetHeight( file.awardPanel, Hud_GetHeight( file.awardPanel ) * 1.3 )

	for ( int index = 0; index < numButtons; index++ )
	{
		var awardButton = Hud_GetChild( scrollPanel, "GridButton" + index )

		BattlePassReward bpReward = file.displayAwards[index]
		file.buttonToItem[awardButton] <- bpReward

		HudElem_SetRuiArg( awardButton, "isOwned", true )
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

		if ( ItemFlavor_GetType( bpReward.flav ) == eItemType.account_pack )
			HudElem_SetRuiArg( awardButton, "isLootBox", true )
		else
			HudElem_SetRuiArg( awardButton, "isLootBox", false )

		BattlePass_PopulateRewardButton( bpReward, awardButton, true, false )

		Hud_AddEventHandler( awardButton, UIE_GET_FOCUS, PassAward_OnFocusAward )


		if ( index == 0 )
			PassAward_OnFocusAward( awardButton )
	}
}


void function PassAward_OnFocusAward( var button )
{
	ItemFlavor item = file.buttonToItem[button].flav
	int level       = file.buttonToItem[button].level

	PresentItem( item, level )
}


void function PresentItem( ItemFlavor item, int level )
{
	if ( ItemFlavor_GetType( item ) == eItemType.character )
	{
		ItemFlavor overrideSkin = GetDefaultItemFlavorForLoadoutSlot( EHI_null, Loadout_CharacterSkin( item ) )
		item = overrideSkin
	}

	bool showLow = (!file.noShowLow && (!file.isForBattlePass || Battlepass_ShouldShowLow( item )))
	showLow = showLow || ItemFlavor_GetType( item ) == eItemType.emote_icon || ItemFlavor_GetType( item ) == eItemType.character_skin

	RunClientScript( "UIToClient_ItemPresentation", ItemFlavor_GetGUID( item ), level, 1.21, showLow, Hud_GetChild( file.menu, "LoadscreenImage" ), true, "battlepass_center_ref" )
}

void function CheckForCharacterOrBattlepass()
{
	foreach ( BattlePassReward bpr in file.displayAwards )
	{
		if ( ItemFlavor_GetType( bpr.flav ) == eItemType.character )
		{
			file.characterToJumpTo = bpr.flav
			file.isCharacter = true
			break
		}

		if ( ItemFlavor_GetType( bpr.flav ) == eItemType.image_2d )
		{
			file.isBattlepass = true
			break
		}
	}
}