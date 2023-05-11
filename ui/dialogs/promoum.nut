global function InitPromoDialogUM
global function DialogFlow_ShouldOpenPromoDialog
global function OpenPromoDialogIfNewUM
global function OnDLPromoPakLoaded
global function OpenPromoDialogIfNewAfterPakLoadUM
global function PromoDialog_InitPages
global function PromoDialog_OpenHijackedUM
global function PromoDialog_OpenToPage
global function PromoDialog_CanShow
global function PromoDialog_GetAllGifts
global function PromoDialog_RemoveFromCache
#if DEV
global function DEV_SetHasViewedMOTDThisSession
#endif

global function UICodeCallback_UMRequestFinished
global function InitPromoPanel
global function InitInboxPanel
global function ReturnToInbox
const PROMO_DIALOG_MAX_PAGES = 4
const string PIN_MESSAGE_TYPE_PROMO = "motd"
const float PROMO_TRANS_DURATION = 0.5
const float PROMO_PREVIEW_BUTTON_WIDTH = 320
const string PROMO_PREVIEW_BUTTON_NAME = "PromoPreviewButton"
const float MIN_ACCEPTABLE_LOAD_TIME_SECONDS = 5
const float MAX_ACCEPTABLE_LOAD_TIME_SECONDS = 15
const float LOAD_TIME_INCREASE_FACTOR = 1.5
struct PromoDialogPageData
{
	asset  image = $""
	string imageName = ""
	string title = ""
	string desc = ""
	string link = ""
	string linkType = ""
	string linkText = ""
	string trackingId = ""
}

enum eTransType
{
	                                      
	NONE = 0,
	SLIDE_LEFT = 1,
	SLIDE_RIGHT = 2,

	_count,
}

struct RedemptionPopupContent
{
	string titleText
	string descText
	string imageName
}

struct
{
	var                 inboxButton
	var                 inboxTitle
	var                 inboxNestedPanel
	var                 inboxDisplayPanel
	var                 listPanel
	var                 redeemButton
	var                 activeButton
	var  				giftingInfo
	GRXScriptInboxMessage ornull activeInfo

	array<GRXScriptInboxMessage> gifts
	table<var, GRXScriptInboxMessage>  inboxItemButtons = {}

	TabDef& inboxTab
}inbox

struct
{
	var  menu
	var	 promoNestedPanel
	var  prevPageButton
	var  nextPageButton
	var	 viewButton
	var	 viewButtonRui
	var	 controlIndicator
	var  newsButton
	var  promoPreviewButtons
	var  promoPreviewActiveIndicatorRui
	var  promoPreviewActiveIndicator
	var  promoPageRui

	bool pageChangeInputsRegistered
	bool hasViewedMOTDThisSession = false

	bool hasHijackContent = false
	bool isPromoVisible = true

	array<PromoDialogPageData> pages
	array< var >			promoPreviewButtonsRui

	int         			activePageIndex = 0
	int         			updateID = 0
	int         			numPages = 0
	int         			pageIndexForJump = -1
	PromoDialogPageData& 	activePage
	RedemptionPopupContent  hijackContent

	var  tabsBackground
	bool isInboxEnabled

	int promoPaksLoaded = 0
	int promoPaksWanted = 0
	float acceptableLoadTimeSeconds = MIN_ACCEPTABLE_LOAD_TIME_SECONDS
} file

                      
                
                      

                                                                              
                                                                                                             
                                                                                                                             
void function InitPromoDialogUM( var newMenuArg )
{
	file.menu = newMenuArg

	file.promoNestedPanel = Hud_GetChild( newMenuArg, "PromoPanel" )
	file.promoPageRui =  Hud_GetRui( Hud_GetChild( file.promoNestedPanel, "PromoPage" ) )
	file.prevPageButton = Hud_GetChild( file.promoNestedPanel, "PrevPageButton" )
	file.nextPageButton = Hud_GetChild( file.promoNestedPanel, "NextPageButton" )
	file.viewButton = Hud_GetChild( file.promoNestedPanel, "ViewButton" )
	file.viewButtonRui = Hud_GetRui( file.viewButton )
	file.promoPreviewActiveIndicator = Hud_GetChild( file.promoNestedPanel, "PromoPreviewActiveIndicator" )
	file.promoPreviewActiveIndicatorRui = Hud_GetRui( file.promoPreviewActiveIndicator )
	file.promoPreviewButtons = Hud_GetChild( file.promoNestedPanel, "PromoPreviewButtons" )
	file.controlIndicator = Hud_GetChild( file.promoNestedPanel, "ControlIndicator" )

	Hud_AddEventHandler( file.prevPageButton, UIE_CLICK, Page_NavLeft )
	Hud_AddEventHandler( file.nextPageButton, UIE_CLICK, Page_NavRight )
	Hud_AddEventHandler( file.viewButton, UIE_CLICK, GoToActivePageLink )

	HudElem_SetRuiArg( file.prevPageButton, "flipHorizontal", true )
	for ( int index = 0; index < PROMO_DIALOG_MAX_PAGES; index++ )
	{
		string previewIndexName	= PROMO_PREVIEW_BUTTON_NAME + string( index )
		var previewButton = Hud_GetChild( file.promoPreviewButtons, previewIndexName )
		file.promoPreviewButtonsRui.append( Hud_GetRui( previewButton ) )
		Hud_AddEventHandler( previewButton, UIE_CLICK, PromoPreview_OnClick )
	}

	Hud_SetWidth( file.promoPreviewButtons, 0 )
	Hud_SetVisible( file.promoPreviewActiveIndicator, false )

	SetDialog( newMenuArg, true )
	SetClearBlur( newMenuArg, false )
	SetGamepadCursorEnabled( newMenuArg, false )

	AddMenuEventHandler( newMenuArg, eUIEvent.MENU_OPEN, PromoDialogUM_OnOpen )
	AddMenuEventHandler( newMenuArg, eUIEvent.MENU_CLOSE, PromoDialogUM_OnClose )
	AddMenuEventHandler( newMenuArg, eUIEvent.MENU_NAVIGATE_BACK, PromoDialog_OnNavigateBack )

	file.tabsBackground = Hud_GetChild( file.menu, "tabsBackground" )

	#if DEV
		AddMenuThinkFunc( file.menu, PromoDialogUMAutomationThink )
	#endif       
}

void function PromoDialogUM_OnOpen()
{
	PromoDialog_InitPages()

	file.isInboxEnabled = GetCurrentPlaylistVarBool( "grx_inbox_enabled", true )

	SetGamepadCursorEnabled( file.menu, true )
	UpdateNumPages()

	if ( !file.hasHijackContent )
	{
		file.hasViewedMOTDThisSession = true

		                                                                                                             
		if ( file.pageIndexForJump < 1 )
			SendImpressionPINMessage( file.activePageIndex )
	}

	if ( !file.isInboxEnabled )
		Hud_SetVisible( file.tabsBackground, false )

	if ( file.pageIndexForJump >= 0 )
	{
		JumpToPage( file.pageIndexForJump )
		file.pageIndexForJump = -1
	}

	TabData tabData = GetTabDataForPanel( file.menu )
	tabData.centerTabs = true
	tabData.forcePrimaryNav = true
	tabData.activeTabIdx = 0
	SetTabDefsToSeasonal(tabData)
	SetTabBackground( tabData, Hud_GetChild( file.menu, "TabsBackground" ), eTabBackground.STANDARD )

	if ( GetLastMenuNavDirection() == MENU_NAV_FORWARD )
		ActivateTab( tabData, 0 )

	UpdateInboxTab()
}

void function PromoDialogUM_OnClose()
{
	DeregisterPageChangeInput()

	Inbox_OnHide( inbox.inboxNestedPanel )

	file.activePageIndex = 0
	file.updateID = 0
	RuiSetInt( file.promoPreviewActiveIndicatorRui, "target", file.updateID )

	if ( file.hasHijackContent )
	{
		file.hasHijackContent = false
		RunClientScript( "SetIsPromoImageHijacked", false )
	}

	SocialEventUpdate()
}

void function PromoDialog_OnNavigateBack()
{
	CloseActiveMenu()
}

                      
                  
                      
void function InitPromoPanel( var panel )
{
	UpdatePageRui()
	UpdatePromoButtons()

	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, PromoDialog_OnShow )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, PromoDialog_OnHide )

	AddPanelFooterOption( panel, LEFT, BUTTON_BACK, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK", OnNavigateBackPanel )
	AddPanelFooterOption( panel, LEFT, BUTTON_Y, true, "#Y_GIFT_INFO_TITLE", "#GIFT_INFO_TITLE", OpenGiftInfoPopUp )
}

void function RegisterPageChangeInput()
{
	if ( file.pageChangeInputsRegistered )
		return

	RegisterButtonPressedCallback( BUTTON_DPAD_LEFT, Page_NavLeft )
	RegisterButtonPressedCallback( KEY_LEFT, Page_NavLeft )
	AddCallback_OnMouseWheelUp( Page_NavLeftOnInput )

	RegisterButtonPressedCallback( BUTTON_DPAD_RIGHT, Page_NavRight )
	RegisterButtonPressedCallback( KEY_RIGHT, Page_NavRight )
	AddCallback_OnMouseWheelDown( Page_NavRightOnInput )

	RegisterButtonPressedCallback( KEY_SPACE, GoToActivePageLink )
	RegisterButtonPressedCallback( BUTTON_X, GoToActivePageLink )

	file.pageChangeInputsRegistered  = true

	thread TrackDpadInput()
}

void function DeregisterPageChangeInput()
{
	if ( !file.pageChangeInputsRegistered  )
		return

	DeregisterButtonPressedCallback( BUTTON_DPAD_LEFT, Page_NavLeft )
	DeregisterButtonPressedCallback( KEY_LEFT, Page_NavLeft )
	RemoveCallback_OnMouseWheelUp( Page_NavLeftOnInput )

	DeregisterButtonPressedCallback( BUTTON_DPAD_RIGHT, Page_NavRight )
	DeregisterButtonPressedCallback( KEY_RIGHT, Page_NavRight )
	RemoveCallback_OnMouseWheelDown( Page_NavRightOnInput )

	DeregisterButtonPressedCallback( KEY_SPACE, GoToActivePageLink )
	DeregisterButtonPressedCallback( BUTTON_X, GoToActivePageLink )

	file.pageChangeInputsRegistered  = false
}

void function TrackDpadInput()
{
	bool canChangePage = false

	while ( file.pageChangeInputsRegistered )
	{
		float xAxis = InputGetAxis( ANALOG_RIGHT_X )

		if ( !canChangePage )
			canChangePage = fabs( xAxis ) < 0.5

		if ( canChangePage )
		{
			if ( xAxis > 0.9 )
			{
				ChangePage( 1 )
				canChangePage = false
			}
			else if ( xAxis < -0.9 )
			{
				ChangePage( -1 )
				canChangePage = false
			}
		}

		WaitFrame()
	}
}

void function Page_NavLeft( var button )
{
	ChangePage( -1 )
}

void function Page_NavLeftOnInput()
{
	ChangePage( -1 )
}

void function Page_NavRight( var button )
{
	ChangePage( 1 )
}

void function Page_NavRightOnInput()
{
	ChangePage( 1 )
}

void function ChangePage( int delta )
{
	Assert( delta == -1 || delta == 1 )

	if( GetActiveMenu() != GetMenu( "PromoDialogUM" ) )
		return
	if ( !file.isPromoVisible )
		return
	if ( file.hasHijackContent )
		return

	int newPageIndex = file.activePageIndex + delta
	if ( newPageIndex < 0 || newPageIndex >= file.numPages )
		return

	file.activePageIndex = newPageIndex
	SendImpressionPINMessage( file.activePageIndex )
	RuiSetInt( file.promoPreviewActiveIndicatorRui, "activePageIndex", file.activePageIndex )
	UpdatePageRui()
	TransitionPage( delta == 1 ? eTransType.SLIDE_LEFT : eTransType.SLIDE_RIGHT )
	thread TransitionViewButton( file.updateID )
	EmitUISound( "UI_Menu_MOTD_Tab" )

	UpdatePromoButtons()
}

void function JumpToPage( int pageIndex )
{
	if ( file.activePageIndex == pageIndex )
		return

	if ( pageIndex < 0 || pageIndex >= file.numPages )
		return

	int lastPageIndex = file.activePageIndex
	file.activePageIndex = pageIndex
	SendImpressionPINMessage( file.activePageIndex )

	RuiSetInt( file.promoPreviewActiveIndicatorRui, "activePageIndex", pageIndex )
	UpdatePageRui()
	TransitionPage( eTransType.NONE )
	RuiSetInt( file.promoPreviewActiveIndicatorRui, "target", file.updateID )
	UpdateViewButton()
	UpdatePromoButtons()
	EmitUISound( "UI_Menu_MOTD_Tab" )
}

void function TransitionViewButton( int updateID )
{
	Hud_Hide( file.viewButton )
	if ( !ActivePageHasLink() )
		return

	wait PROMO_TRANS_DURATION
	if ( file.updateID == updateID )
		UpdateViewButton()
}

                      
                 
                      
void function InitInboxPanel( var panel )
{
	inbox.inboxNestedPanel = panel
	inbox.listPanel = Hud_GetChild( inbox.inboxNestedPanel, "InboxList" )
	inbox.inboxTitle = Hud_GetChild( inbox.inboxNestedPanel, "InboxTitle" )
	inbox.inboxDisplayPanel = Hud_GetChild( inbox.inboxNestedPanel, "GiftDisplayPanel" )
	inbox.redeemButton = Hud_GetChild( inbox.inboxNestedPanel, "GiftButton" )

	inbox.gifts = GetGiftingInboxMessages()

	RuiSetString( Hud_GetRui( inbox.redeemButton ), "buttonText", Localize( "#INBOX_PANEL_BUTTON" ) )
	RuiSetString( Hud_GetRui( inbox.inboxTitle ), "titleText", Localize( "#INBOX_TITLE_N", inbox.gifts.len() ).toupper() )

	AddButtonEventHandler( inbox.redeemButton, UIE_CLICK, Redeem_OnClick )

	AddTab( file.menu, file.promoNestedPanel, "#PROMO_TAB_NEWS" )
	TabDef inboxTab = AddTab( file.menu, inbox.inboxNestedPanel, "#PROMO_TAB_INBOX" )
	inbox.inboxTab = inboxTab


	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, Inbox_OnShow )

	AddPanelFooterOption( panel, LEFT, BUTTON_BACK, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK", OnNavigateBackPanel )
	AddPanelFooterOption( panel, LEFT, BUTTON_Y, true, "#Y_GIFT_INFO_TITLE", "#GIFT_INFO_TITLE", OpenGiftInfoPopUp )
}


const asset gift_top = $"rui/borders/gifting_inbox_border_top"
const asset gift_empty = $"rui/borders/gifting_inbox_gift_empty_box"

void function UpdateInboxButtons()
{
	var scrollPanel = Hud_GetChild( inbox.listPanel, "ScrollPanel" )

	if ( inbox.inboxItemButtons.len() > 0 )
	{
		for ( int indicatorIndex = 0; indicatorIndex < inbox.inboxItemButtons.len(); indicatorIndex++ )
		{
			var button = Hud_GetChild( scrollPanel, "GridButton" + indicatorIndex )
			InboxRemoveItemButton( button )
		}

		Hud_InitGridButtons( inbox.listPanel, 0 )
		inbox.inboxItemButtons.clear()
	}

	Hud_InitGridButtons( inbox.listPanel, inbox.gifts.len() )
	UpdateInboxTab()

	if ( inbox.gifts.len() > 0 )
	{
		RuiSetBool( Hud_GetRui( inbox.inboxTitle ), "hasNotifications", true )
		scrollPanel = Hud_GetChild( inbox.listPanel, "ScrollPanel" )

		for ( int indicatorIndex = 0; indicatorIndex < inbox.gifts.len(); indicatorIndex++ )
		{
			var button = Hud_GetChild( scrollPanel, "GridButton" + string( indicatorIndex ) )
			var title = Localize( "#INBOX_GIFT_TITLE" )
			HudElem_SetRuiArg( button, "title", title )
			HudElem_SetRuiArg( button, "desc", Localize( "#INBOX_GIFT_DESC_N" , inbox.gifts[indicatorIndex].gifterName ) )
			HudElem_SetRuiArg( button, "date", GetDateTimeStringDayMonthYear( inbox.gifts[indicatorIndex].timestamp, 0 ) )
			HudElem_SetRuiArg( button, "isNew", inbox.gifts[indicatorIndex].isNew )
			RuiSetColorAlpha( Hud_GetRui( button ), "seasonColor",  GetSeasonStyle().seasonColor , 1.0 )
			InboxSetupItemButton( button, inbox.gifts[indicatorIndex] )
		}

		RuiSetString( Hud_GetRui( inbox.inboxTitle ), "titleText", Localize( "#INBOX_TITLE_N",  inbox.gifts.len() ).toupper() )

		inbox.activeButton = Hud_GetChild( scrollPanel, "GridButton0" )

		Hud_SetFocused( inbox.activeButton )
		Hud_SetSelected( inbox.activeButton, true )

		GRXScriptInboxMessage info = inbox.inboxItemButtons[inbox.activeButton]
		info.isNew = false
		inbox.activeInfo = info

		var panel = Hud_GetChild( inbox.inboxNestedPanel,  "GiftDisplayPanel" )

		RuiSetString( Hud_GetRui( panel ), "desc1", Localize( "#INBOX_PANEL_DESC", info.gifterName ).toupper() )
		RuiSetString( Hud_GetRui( panel ), "title", Localize( "#INBOX_PANEL_TITLE" ).toupper() )
		RuiSetImage( Hud_GetRui( panel ), "boxImg", gift_top )
	}
	else
	{
		RuiSetBool( Hud_GetRui( inbox.inboxTitle ), "hasNotifications", false )
		var panel = Hud_GetChild( inbox.inboxNestedPanel,  "GiftDisplayPanel" )
		RuiSetString( Hud_GetRui( panel ), "desc1", Localize( "#INBOX_PANEL_NO_MESSAGES_DESC" ))
		RuiSetString( Hud_GetRui( panel ), "title", Localize( "#INBOX_PANEL_NO_MESSAGES_TITLE" ).toupper() )
		RuiSetImage( Hud_GetRui( panel ), "boxImg", gift_empty )
		RuiSetString( Hud_GetRui( inbox.inboxTitle ), "titleText", Localize( "#INBOX_TITLE_N",  inbox.gifts.len() ).toupper() )
	}

	UpdateFooterOptions()

	if ( !Hud_HasChild( scrollPanel, "GridButton0" ) )
		return

	Hud_SetNavLeft( inbox.redeemButton, inbox.activeButton )
}

void function InboxSetupItemButton( var button, GRXScriptInboxMessage details )
{
	if ( button in inbox.inboxItemButtons )
		return

	Hud_SetNavRight( button, inbox.redeemButton )
	inbox.inboxItemButtons[button] <- details
	Hud_AddEventHandler( button, UIE_CLICK, ListButton_OnClick )
	Hud_AddEventHandler( button, UIE_DOUBLECLICK , ListButton_OnDoubleClick )
}

void function InboxRemoveItemButton( var button )
{
	if ( !( button in inbox.inboxItemButtons ) )
		return

	Hud_RemoveEventHandler( button, UIE_CLICK, ListButton_OnClick )
	Hud_RemoveEventHandler( button, UIE_DOUBLECLICK , ListButton_OnDoubleClick )
	delete inbox.inboxItemButtons[button]
}

void function UpdateInboxTab()
{
	if ( inbox.gifts.len() > 0 )
		inbox.inboxTab.new = true
	else
		inbox.inboxTab.new = false
}

void function ReturnToInbox()
{
	TabData tabData = GetTabDataForPanel( file.menu )
	ActivateTab( tabData, 1 )                                                                     
}

void function Inbox_SetVisible( bool isVisible )
{
	if ( isVisible )
		ShowPanel( inbox.inboxNestedPanel )

	Hud_SetVisible( inbox.listPanel, isVisible )
	Hud_SetVisible( inbox.inboxTitle, isVisible )
	Hud_SetVisible( inbox.inboxDisplayPanel, isVisible )

	if ( inbox.gifts.len() != 0 )
		Hud_SetVisible( inbox.redeemButton, isVisible )
	else
		Hud_SetVisible( inbox.redeemButton, false )
}

void function Promo_OnShow( var button )
{
	UpdatePromoButtons()
	Inbox_SetVisible( false )
	Inbox_OnHide( null )
}

void function Inbox_OnShow( var panel )
{
	UpdateInboxButtons()
	Inbox_SetVisible( true )
}

void function Inbox_OnHide( var panel )
{
	var scrollPanel = Hud_GetChild( inbox.listPanel, "ScrollPanel" )

	for ( int indicatorIndex = 0; indicatorIndex < inbox.inboxItemButtons.len(); indicatorIndex++ )
	{
		var button = Hud_GetChild( scrollPanel, "GridButton" + indicatorIndex )
		InboxRemoveItemButton( button )
	}
}

void function ListButton_OnClick( var button )
{
	if ( inbox.activeButton == button )
		return

	inbox.activeButton = button

	inbox.activeInfo = inbox.inboxItemButtons[button]


	var panel = Hud_GetChild( inbox.inboxNestedPanel, "GiftDisplayPanel" )

	RuiSetString( Hud_GetRui( panel ), "desc1", Localize( "#INBOX_PANEL_DESC", inbox.inboxItemButtons[button].gifterName ).toupper() )
	RuiSetString( Hud_GetRui( panel ), "title", Localize( "#INBOX_PANEL_TITLE" ).toupper() )

	Hud_SetNavLeft( inbox.redeemButton, inbox.activeButton )
}

void function ListButton_OnDoubleClick( var button )
{
	GiftRedemption()
}

void function Redeem_OnClick( var button )
{
	GiftRedemption()
}

void function GiftRedemption()
{
	GRXScriptInboxMessage info = expect GRXScriptInboxMessage ( inbox.activeInfo )

	array<ItemFlavor> items

	foreach( int index in info.itemIndex )
	{
		items.append( GetItemFlavorByGRXIndex( index ) )
	}

	array<BattlePassReward> RewardInput


	for( int i = 0; i < items.len(); i++ )
	{
		BattlePassReward tempReward
		tempReward.flav = items[i]
		tempReward.isPremium = false
		tempReward.quantity = info.itemCount[i]
		tempReward.level = -1

		RewardInput.append( tempReward )
	}

	CloseActiveMenu()

	ShowGiftCeremonyDialog(
		"",
		Localize( "#INBOX_REDEMPTION_HEADER",  1,  PromoDialog_GetAllGifts().len() ),
		"",
		RewardInput
	)
}

                      
                    
                      
void function OnNavigateBackPanel( var panel )
{
	CloseActiveMenu()
}

bool function DialogFlow_ShouldOpenPromoDialog()
{
	if ( IsFeatureSuppressed( eFeatureSuppressionFlags.PROMO_USER_MESSAGES_DIALOG ) )
		return false

	return IsFirstPromoDialogView()
}

void function OpenPromoDialogIfNewUM()
{
	if ( IsFeatureSuppressed( eFeatureSuppressionFlags.PROMO_USER_MESSAGES_DIALOG ) )
		return

	if ( GetConVarBool( "assetdownloads_enabled" ) )
	{
		PromoDialog_InitPages()
		if ( PromoDialog_HasPages() )
		{
			file.promoPaksLoaded = 0
			UpdateNumPages()
			UpdatePageRui()                                                                                                                
			UpdatePreviewButtonRui()
		}
		else
		{
			print( format( "%s no pages", FUNC_NAME() ) )
		}
	}
	else if ( IsFirstPromoDialogView() )   	                                                                                            
	{
		AdvanceMenu( file.menu )
	}
}

float function ElapsedTimeSinceLobbyOpened()
{
	float elapsedTime = UITime() - GetLobbyMenuOpenedTime()
	return elapsedTime
}

bool function WasLoadTimeTooLong()
{
	return ElapsedTimeSinceLobbyOpened() > file.acceptableLoadTimeSeconds
}
void function IncreaseAcceptableLoadTime()
{
	if( file.acceptableLoadTimeSeconds < MAX_ACCEPTABLE_LOAD_TIME_SECONDS )
	{
		file.acceptableLoadTimeSeconds = Clamp( file.acceptableLoadTimeSeconds * LOAD_TIME_INCREASE_FACTOR, MIN_ACCEPTABLE_LOAD_TIME_SECONDS, MAX_ACCEPTABLE_LOAD_TIME_SECONDS )
		printf( "PromoDialog Acceptable load time increased to %f ", file.acceptableLoadTimeSeconds )
	}
}

void function OnDLPromoPakLoaded()
{
	file.promoPaksLoaded++
	#if DEV
		printf( "%s: %i / %i paks loaded", FUNC_NAME(), file.promoPaksLoaded, file.promoPaksWanted )
	#endif
	if( file.promoPaksLoaded >= file.promoPaksWanted )
	{
		OpenPromoDialogIfNewAfterPakLoadUM()
	}
}
void function OpenPromoDialogIfNewAfterPakLoadUM()
{
	if ( IsFirstPromoDialogView() && !file.hasHijackContent )
	{
		if( WasLoadTimeTooLong() )
		{
			printf( "%s took longer to open than the acceptable time of %f seconds! Deferring until next attempt!", FUNC_NAME(), file.acceptableLoadTimeSeconds )
			IncreaseAcceptableLoadTime()
		}
		else
		{
			UpdatePageRui()
			DialogFlow_DidCausePotentiallyInterruptingPopup()                                                                     
			AdvanceMenu( file.menu )
		}
	}
}

void function PromoDialog_InitPages()
{
	file.pages.clear()

	UMData um = EADP_UM_GetPromoData()
	foreach ( int i, UMAction action in um.actions )
	{
		PromoDialogPageData newPage
		newPage.trackingId = action.trackingId
		foreach ( int j, UMItem item in action.items )
		{
			if ( item.name == "TitleText" )
			{
				newPage.title = item.value
			}
			else if ( item.name == "BodyText" )
			{
				newPage.desc = item.value
			}
			else if ( item.name == "Link" )
			{
				newPage.link = item.value
				foreach ( attr in item.attributes )
				{
					if ( attr.key == "LinkType" )
					{
						newPage.linkType = attr.value
						newPage.linkText = Localize( ViewButtonTextFromLinkType( newPage.linkType ) )
					}
				}
			}
			else if ( item.name == "ImageRef" )
			{
				newPage.imageName = item.value
				if ( file.hasHijackContent )
					newPage.image = GetPromoImage( newPage.imageName )
			}
		}
		file.pages.append( newPage )
	}
	Promo_OnShow( null )
}

int function PromoDialog_NumPages()
{
	return file.pages.len()
}

bool function PromoDialog_HasPages()
{
	return PromoDialog_NumPages() > 0
}

bool function PromoDialog_CanShow()
{
	return (PromoDialog_HasPages() && IsLobby() && IsFullyConnected() && GetActiveMenu() == GetMenu( "LobbyMenu" ) && IsTabPanelActive( GetPanel( "PlayPanel" ) ))
}

bool function IsFirstPromoDialogView()
{
	entity player = GetLocalClientPlayer()
	if ( player == null || !PromoDialog_CanShow() )
		return false

	return !file.hasViewedMOTDThisSession
}

void function PromoPreview_OnClick( var button )
{
	JumpToPage( int( Hud_GetScriptID( button ) ) )
}

void function PromoDialog_OpenHijackedUM( string titleText, string descText, string imageName )
{
	file.hasHijackContent = true
	file.hijackContent.titleText = titleText
	file.hijackContent.descText = descText
	file.hijackContent.imageName = imageName
	RunClientScript( "SetIsPromoImageHijacked", true )
	AdvanceMenu( file.menu )
}

#if DEV
void function PromoDialogUMAutomationThink( var menu )
{
	if ( AutomateUi() )
	{
		printt("PromoDialogUMAutomationThink CloseActiveMenu()")
		CloseActiveMenu()
	}
}
#endif       

void function PromoDialog_OnShow( var panel )
{
	file.isPromoVisible = true

	RegisterPageChangeInput()
	UpdatePageRui()
	UpdatePromoButtons()
	UpdatePreviewButtonRui()
	UpdateViewButton()
}

void function PromoDialog_OnHide( var panel )
{
	file.isPromoVisible = false

	DeregisterPageChangeInput()
}

string function ParseLinkText( string link )
{
	int separatorIndex = link.find( ":" )

	if ( separatorIndex >= 0 )
	{
		string linkDataSubstring = link.slice( separatorIndex + 1, link.len() )
		string linkType = link.slice( 0, separatorIndex )

		if ( linkType == "battlepass" )
		{
			return "#PROMO_PAGE_VIEW_UNLOCK"
		}
		else if ( linkType == "challenges" )
		{
			return "#PROMO_PAGE_VIEW_LINK"
		}
		else if ( linkType == "playapex" )
		{
			return "#PROMO_PAGE_VIEW_LINK"
		}
		else if ( linkType == "heirloom" )
		{
			return "#PROMO_PAGE_VIEW_LINK"
		}
		else if ( linkType == "storecharacter" )
		{
			return "#PROMO_PAGE_VIEW_UNLOCK"
		}
		else if ( linkType == "themedstoreskin" )
		{
			return "#PROMO_PAGE_VIEW_UNLOCK"
		}
		else if ( linkType == "collectionevent" )
		{
			return "#PROMO_PAGE_VIEW_LINK"
		}
		else if ( linkType == "url" )
		{
			return "#PROMO_PAGE_VIEW_LINK"
		}
		else if ( linkType == "storeoffer" )
		{
			return "#PROMO_PAGE_VIEW_BUY"
		}
		else
		{
			return "#PROMO_PAGE_VIEW_LINK"
		}
	}

	return "Invalid Link"
}


void function SendImpressionPINMessage( int pageIndex )
{
	PromoDialogPageData page = file.pages[pageIndex]
	PIN_UM_Message( page.title, page.trackingId, PIN_MESSAGE_TYPE_PROMO, ePINPromoMessageStatus.IMPRESSION, pageIndex )
}

void function UpdateViewButton()
{
	bool isLinkVisible = ActivePageHasLink()
	Hud_SetVisible( file.viewButton, isLinkVisible )

	if ( !isLinkVisible )
		return

	RuiSetString( file.viewButtonRui, "buttonText", file.activePage.linkText )
}

void function UpdatePromoImage( var promoRui, PromoDialogPageData activePage, asset image, bool isLoading )
{
	RuiSetImage( promoRui, "imageAsset", image )
	RuiSetBool( promoRui, "isImageLoading", isLoading )
	RuiSetString( promoRui, "titleText", activePage.title )
	RuiSetString( promoRui, "descText", activePage.desc )
}

void function UpdateLeftPromoImage( var promoRui, PromoDialogPageData activePage, asset image, bool isLoading )
{
	RuiSetImage( promoRui, "leftImageAsset", image )
	RuiSetBool( promoRui, "isLeftImageLoading", isLoading )
	RuiSetString( promoRui, "leftTitleText", activePage.title )
	RuiSetString( promoRui, "leftDescText", activePage.desc )
}

void function UpdateRightPromoImage( var promoRui, PromoDialogPageData activePage, asset image, bool isLoading )
{
	RuiSetImage( promoRui, "rightImageAsset", image )
	RuiSetBool( promoRui, "isRightImageLoading", isLoading )
	RuiSetString( promoRui, "rightTitleText", activePage.title )
	RuiSetString( promoRui, "rightDescText", activePage.desc )
}

void function UpdateNumPages()
{
	file.numPages = file.promoPreviewButtonsRui.len() < PromoDialog_NumPages() ? file.promoPreviewButtonsRui.len() : PromoDialog_NumPages()
}

void function UpdatePageRui()
{
	array<PromoDialogPageData> pages = file.pages

	var promoRui = file.promoPageRui

	if ( file.hasHijackContent )
	{
		RuiSetImage( promoRui, "imageAsset", GetPromoImage( file.hijackContent.imageName ) )
		RuiSetBool( promoRui, "isImageLoading", false )
		RuiSetString( promoRui, "titleText", file.hijackContent.titleText )
		RuiSetString( promoRui, "descText", file.hijackContent.descText )

		RuiSetBool( promoRui, "isRightImageLoading", true)
		RuiSetBool( promoRui, "isLeftImageLoading", true )
	}
	else
	{
		if ( pages.len() == 0 )
			return

		int pageIndex = file.activePageIndex
		PromoDialogPageData page = pages[pageIndex]
		file.activePage = page

		bool downloaded = GetConVarBool( "assetdownloads_enabled" )

		if ( downloaded )
		{
			var promoElem = Hud_GetChild( file.promoNestedPanel, "PromoPage" )
			UpdatePromoImage( promoRui, page, GetDownloadedImageAsset( page.imageName, page.imageName,
				ePakType.DL_PROMO, promoElem ), IsImagePakLoading( page.imageName ) )
		}
		else
		{
			UpdatePromoImage( promoRui, page , pages[pageIndex].image, false )
		}

		if ( pageIndex - 1 >= 0 )
		{
			if ( downloaded )
			{
				UpdateLeftPromoImage( promoRui, pages[pageIndex - 1] ,GetDownloadedImageAsset( page.imageName,
					pages[pageIndex - 1].imageName, ePakType.DL_PROMO ), IsImagePakLoading( page.imageName ) )
			}
			else
			{
				UpdateLeftPromoImage( promoRui, pages[pageIndex - 1] , pages[pageIndex - 1].image, false )
			}
		}
		else
		{
			RuiSetBool( promoRui, "isLeftImageLoading", true )
		}

		if ( pageIndex + 1 < file.numPages )
		{
			if ( downloaded )
			{
				UpdateRightPromoImage( promoRui, pages[pageIndex + 1] ,GetDownloadedImageAsset( page.imageName, pages[pageIndex + 1].imageName, ePakType.DL_PROMO ), IsImagePakLoading( page.imageName ) )
			}
			else
			{
				UpdateRightPromoImage( promoRui, pages[pageIndex + 1] , pages[pageIndex + 1].image, false )
			}
		}
		else
		{
			RuiSetBool( promoRui, "isRightImageLoading", true )
		}
	}
}

void function UpdatePreviewButtonRui()
{
	if ( !file.hasHijackContent )
	{
		RuiSetInt( file.promoPreviewActiveIndicatorRui, "activePageIndex", file.activePageIndex )
		RuiSetInt( file.promoPreviewActiveIndicatorRui, "updateID", file.updateID )
		RuiSetFloat(file.promoPreviewActiveIndicatorRui, "promoPageWidth", ContentScaledX( 240 ) )

		                                 
		Hud_SetWidth( file.promoPreviewButtons, ContentScaledXAsInt( 242 * file.numPages ) )
		Hud_SetVisible( file.promoPreviewActiveIndicator, bool( file.pages.len() ) )

		file.promoPaksWanted = file.numPages
		for ( int i = 0; i < file.numPages; i++ )
		{
			PromoDialogPageData page = file.pages[i]
			var rui = file.promoPreviewButtonsRui[i]
			RuiSetBool( rui, "isPageActive", true )

			if ( GetConVarBool( "assetdownloads_enabled" ) )
			{
				var previewButton = Hud_GetChild( file.promoPreviewButtons, PROMO_PREVIEW_BUTTON_NAME + string( i ) )
				RuiSetImage( rui, "imageAsset", GetDownloadedImageAsset( page.imageName, page.imageName, ePakType.DL_PROMO, previewButton ) )
				RuiSetBool( rui, "isImageLoading", IsImagePakLoading( page.imageName ) )
			}
			else
			{
				RuiSetImage( rui, "imageAsset", page.image )
			}
			RuiSetString( rui, "titleText", page.title )
		}
	}
	else
	{
		Hud_SetWidth( file.promoPreviewButtons, 0 )
		Hud_SetVisible( file.promoPreviewActiveIndicator, false )
	}
}

void function TransitionPage( int transType )
{
	file.updateID++
	RuiSetInt( file.promoPageRui, "transType", transType )
	RuiSetInt( file.promoPageRui, "updateID", file.updateID )
	RuiSetInt( file.promoPreviewActiveIndicatorRui, "updateID", file.updateID )

}

void function UpdatePromoButtons()
{
	if ( file.hasHijackContent )
	{
		Hud_Hide( file.prevPageButton )
		Hud_Hide( file.nextPageButton )
		UpdateFooterOptions()
		Hud_Hide( file.controlIndicator )
		return
	}
	Hud_SetVisible( file.controlIndicator, bool( file.numPages ) )

	if ( file.activePageIndex == 0 )
		Hud_Hide( file.prevPageButton )
	else
		Hud_Show( file.prevPageButton )

	if ( file.activePageIndex == file.numPages - 1 )
		Hud_Hide( file.nextPageButton )
	else
		Hud_Show( file.nextPageButton )

	UpdateFooterOptions()
}


bool function ActivePageHasLink()
{
	if ( file.hasHijackContent )
		return false

	return file.activePage.linkType != "" && file.activePage.linkText != ""
}

void function GoToActivePageLink( var button )
{
	PromoDialogPageData page = file.activePage

	if ( page.linkType == "" )
		return

	PIN_UM_Message( page.title, page.trackingId, PIN_MESSAGE_TYPE_PROMO, ePINPromoMessageStatus.CLICK, file.activePageIndex )
	OpenPromoLink( page.linkType, page.link )
}

string function ViewButtonTextFromLinkType( string linkType )
{
	if ( linkType == "battlepass" )
	{
		return "#PROMO_PAGE_VIEW_UNLOCK"
	}
	else if ( linkType == "challenges" )
	{
		return "#PROMO_PAGE_VIEW_LINK"
	}
	else if ( linkType == "playapex" )
	{
		return "#PROMO_PAGE_VIEW_LINK"
	}
	else if ( linkType == "heirloom" )
	{
		return "#PROMO_PAGE_VIEW_LINK"
	}
	else if ( linkType == "storecharacter" )
	{
		return "#PROMO_PAGE_VIEW_UNLOCK"
	}
	else if ( linkType == "themedstoreskin" )
	{
		return "#PROMO_PAGE_VIEW_UNLOCK"
	}
	else if ( linkType == "collectionevent" )
	{
		return "#PROMO_PAGE_VIEW_LINK"
	}
	else if ( linkType == "url" )
	{
		return "#PROMO_PAGE_VIEW_LINK"
	}
	else if ( linkType == "storeoffer" )
	{
		return "#PROMO_PAGE_VIEW_LINK"
	}
	else
	{
		return "#PROMO_PAGE_VIEW_LINK"
	}
	unreachable
}

void function PromoDialog_OpenToPage( int pageIndex )
{
	file.pageIndexForJump = pageIndex
	AdvanceMenu( file.menu )
}

void function UICodeCallback_UMRequestFinished( int result )
{
	SetNewsButtonTooltip( result )
}

array<GRXScriptInboxMessage> function PromoDialog_GetAllGifts()
{
	array<GRXScriptInboxMessage> list

	if( inbox.gifts.len() <= 0 )
		return list

	GRXScriptInboxMessage active

	if ( inbox.activeInfo == null )
	{
		active = inbox.gifts[0]
		list.append( active )
	}
	else
	{
		active = expect GRXScriptInboxMessage ( inbox.activeInfo )
		list.append( active )
	}

	for ( int i = 0; i < inbox.gifts.len(); i++ )
	{
		if ( active.itemIndex == inbox.gifts[i].itemIndex && active.timestamp == inbox.gifts[i].timestamp )
			continue

		list.append( inbox.gifts[i] )
	}

	return list
}

void function PromoDialog_RemoveFromCache( int viewedGifts )
{
	array<GRXScriptInboxMessage> sortedGifts = PromoDialog_GetAllGifts()

	for ( int i = 0; i <= viewedGifts; i++ )
	{
		RemoveGiftCacheMessage( sortedGifts[i].timestamp, sortedGifts[i].senderNucleusPid )
	}

	inbox.activeInfo = null
}


#if DEV
void function DEV_SetHasViewedMOTDThisSession( bool val )
{
	file.hasViewedMOTDThisSession = val
}
#endif