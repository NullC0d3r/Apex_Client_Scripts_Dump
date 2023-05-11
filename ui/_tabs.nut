global function InitTabs
global function AddTab
global function ClearTabs
global function IsTabActive
global function ActivateTab
global function DeactivateTab
global function GetMenuActiveTabIndex
global function GetTabDataForPanel
global function GetMenuNumTabs
global function UpdateMenuTabs
global function RegisterTabNavigationInput
global function DeregisterTabNavigationInput
global function ShowPanel
global function ShowPanelInternal
global function AnimateInSmallTabBar
global function AnimateOutSmallTabBar
global function HidePanel
global function HidePanelInternal
global function ShutdownAllPanels
global function IsPanelTabbed
global function SetPanelTabEnabled
global function SetPanelTabNew
global function IsTabIndexVisible
global function IsTabIndexEnabled
global function IsTabPanelActive
global function _HasActiveTabPanel
global function _GetActiveTabPanel
global function _OnTab_NavigateBack
global function SetTabRightSound
global function SetTabLeftSound
global function Tab_GetTabIndexByBodyName
global function Tab_GetTabDefByBodyName
global function SetTabNavigationEnabled
global function SetTabNavigationEndCallback
global function SetTabNavigationCallback
global function AddCallback_OnTabChanged

global function GetTabBodyParent

global function SetTabBaseWidth
global function GetPanelTabs
global function SetTabDefVisible
global function SetTabDefEnabled
global function HideVisibleTabBodies

global function ActivateTabNext
global function ActivateTabPrev

global function GetTabForTabButton

global function RefreshTabsGRXData
global function SetTabDefsToSeasonal
global function SetTabBackground

global const int INVALID_TAB_INDEX = -1
global struct TabData
{
	var             parentPanel
	var             tabPanel
	array<var>      tabButtons
	array<TabDef>   tabDefs

	int             activeTabIdx = INVALID_TAB_INDEX
	string          tabRightSound = "UI_Menu_ApexTab_Select"
	string          tabLeftSound = "UI_Menu_ApexTab_Select"
	bool            tabNavigationDisabled = false
	bool            centerTabs = false
	int           	selectedExtraWidth = 0
	float           selectedScaleAnimationTime = 0.15
	bool            forcePrimaryNav = false

	table<int, void functionref()> tabNavigationEndCallbacks
	void functionref( TabDef ) tabNavigationCallbacks

	bool customFirstTabButton = false
	bool groupNavHints = false

	asset  bannerLogoImage = $""
	float  bannerLogoScale = 1.0
	float bannerLogoWidth = 1.0
	float bannerLogoHeight = 1.0
	string bannerTitle = ""
	string bannerHeader = ""
	string callToActionHeader = ""
	string callToActionTitle = ""
	#if NX_PROG || PC_PROG_NX_UI
		float callToActionWidth = 230.0
	#else
		float callToActionWidth = 190.0
	#endif


	vector bannerHeaderTextColor = <1.0, 1.0, 1.0>
	vector bannerTitleTextColor = <1.0, 1.0, 1.0>

	bool useGRXData  = false
	var  background	 = null

	void functionref( TabData tabData ) bannerUpdateCallback = null

	int initialFirstTabButtonWidth = -1
	int initialFirstTabButtonXPos = -1
	int initialSecondTabButtonXPos = -1

	float lastTapLeftTime = 0
	float lastTapRightTime = 0
}


global enum eTabBackground
{
	NONE,
	DEATH,
	STANDARD,
	CAPSTONE
}

struct
{
	string header = ""
	string title = ""


	string callToActionHeader = ""
	string callToActionTitle = ""
} GRXData

struct
{
	array<var> elements
	table<var, TabData> elementTabData
	table<var, var>     tabButtonParents

	table< TabDef, int > tabToWidth
	table< TabDef, int > tabToAdjustedWidth

	table<var, TabDef> tabBodyDefMap

	bool tabButtonsRegistered = false

	array<void functionref()> Callbacks_OnTabUpdated
} file

const MAX_TABS = 8
const MAX_SUBTABS = 8

global enum eTabDirection
{
	PREV
	NEXT
}

                                                                                                                                    
void function InitTabs()
{
	foreach ( menu in uiGlobal.allMenus )
	{
		array<var> tabButtonPanels = GetElementsByClassname( menu, "TabsCommonClass" )
		foreach ( tabButtonPanel in tabButtonPanels )
		{
			var parentPanel = Hud_GetParent( tabButtonPanel )
			Assert( !(parentPanel in file.elementTabData) )
			bool isMenu = parentPanel == GetParentMenu( parentPanel )
			Assert( isMenu || parentPanel in uiGlobal.panelData, "Panel " + Hud_GetHudName( parentPanel ) + " not initialized with AddPanel()" )
			TabData tabData
			tabData.parentPanel = parentPanel
			tabData.tabPanel = tabButtonPanel
			tabData.tabNavigationEndCallbacks[eTabDirection.PREV] <- null
			tabData.tabNavigationEndCallbacks[eTabDirection.NEXT] <- null
			tabData.tabNavigationCallbacks = null

			file.elementTabData[parentPanel] <- tabData
			file.elements.append(parentPanel)

			array<var> tabButtons = GetElementsByClassname( menu, "TabButtonClass" )
			foreach ( tabButton in tabButtons )
			{
				var tabButtonParent = Hud_GetParent( tabButton )
				if ( tabButtonParent != tabButtonPanel )
					continue

				tabData.tabButtons.append( tabButton )

				Hud_AddEventHandler( tabButton, UIE_CLICK, OnTab_Activate )
				Hud_AddEventHandler( tabButton, UIE_GET_FOCUS, OnTab_GetFocus )
				Hud_AddEventHandler( tabButton, UIE_LOSE_FOCUS, OnTab_LoseFocus )
				Hud_Hide( tabButton )

				file.tabButtonParents[tabButton] <- parentPanel
			}
		}
	}

	AddCallback_OnSeasonalDataUpdated( UpdateMenuTabs )
	AddUICallback_OnResolutionChanged( Tabs_OnResolutionChanged )
	AddMenuVarChangeHandler( "isFullyConnected", UpdateMenuTabs )
	AddMenuVarChangeHandler( "isGamepadActive", UpdateMenuTabs )
}

void function Tabs_OnResolutionChanged()
{
	for( int i = 0; i < file.elements.len(); i++ )
	{
		foreach(TabDef tabDef in file.elementTabData[file.elements[i]].tabDefs )
		{
			SetTabBaseWidth( tabDef, file.tabToWidth[ tabDef ] )
		}
	}
}

TabDef function GetTabForTabButton( var button )
{
	TabDef tabDef
	return tabDef
}

void function AddCallback_OnTabChanged( void functionref() callbackFunc )
{
	if( !file.Callbacks_OnTabUpdated.contains( callbackFunc ) )
		file.Callbacks_OnTabUpdated.append( callbackFunc )
}

void function OnTabChanged()
{
	foreach ( void functionref() cb in file.Callbacks_OnTabUpdated )
		cb()
}

TabDef function GetTabForTabBody( var body )
{
	return file.tabBodyDefMap[body]
}


array<TabDef> function GetPanelTabs( var panel )
{
	TabData tabData = GetTabDataForPanel( panel )

	return tabData.tabDefs
}

void function SetTabBackground( TabData tabData, var background, int backgroundEnum )
{
	if( backgroundEnum == eTabBackground.CAPSTONE )
	{
		tabData.background = background
		tabData.bannerUpdateCallback = BannerUpdate_Capstone
	}
	else if( backgroundEnum == eTabBackground.STANDARD )
	{
		tabData.background = background
		tabData.bannerUpdateCallback = BannerUpdate_Default
	}
	else if( backgroundEnum == eTabBackground.DEATH )
	{
		tabData.background = background
		tabData.bannerUpdateCallback = BannerUpdate_Default
	}
	else
	{
		tabData.bannerUpdateCallback = null
	}
}

void function BannerUpdate_Capstone( TabData tabData )
{
	SeasonStyleData seasonStyle = GetSeasonStyle()
	var tabBackgroundRUI = Hud_GetRui( tabData.background )
	if( tabData.bannerLogoImage == $"" )
		RuiSetImage( tabBackgroundRUI, "smallLogo", seasonStyle.seasonBannerLogo )
	else
		RuiSetImage( tabBackgroundRUI, "smallLogo", tabData.bannerLogoImage )

	RuiSetFloat( tabBackgroundRUI, "smallLogoScale", tabData.bannerLogoScale )
	RuiSetImage( tabBackgroundRUI, "smallLogoBg", seasonStyle.seasonBannerLogoBg )
	RuiSetFloat2( tabBackgroundRUI, "smallLogoSize", < tabData.bannerLogoWidth, tabData.bannerLogoHeight, 1.0 > )
	RuiSetImage( tabBackgroundRUI, "bannerLeftImage", seasonStyle.seasonBannerLeftImage )
	RuiSetImage( tabBackgroundRUI, "bannerRightImage", seasonStyle.seasonBannerRightImage )
	RuiSetBool( tabBackgroundRUI, "isLogoSmall", tabData.tabDefs[tabData.activeTabIdx].isBannerLogoSmall )
	RuiSetColorAlpha( tabBackgroundRUI, "titleTextColor", SrgbToLinear( seasonStyle.titleTextColor ), 1.0 )
	RuiSetColorAlpha( tabBackgroundRUI, "headerTextColor", SrgbToLinear( seasonStyle.headerTextColor ), 1.0 )
	RuiSetInt( tabBackgroundRUI, "totalWidth", GetTabsTotalWidth( tabData ) )

	if( tabData.useGRXData )
	{
		RuiSetString( tabBackgroundRUI, "title", GRXData.title )
		RuiSetString( tabBackgroundRUI, "header", GRXData.header )
		RuiSetString( tabBackgroundRUI, "callToActionHeader", GRXData.callToActionHeader )
		RuiSetString( tabBackgroundRUI, "callToActionTitle", GRXData.callToActionTitle )
	}
	else
	{
		RuiSetString( tabBackgroundRUI, "title", tabData.bannerTitle )
		RuiSetString( tabBackgroundRUI, "header", tabData.bannerHeader  )
		RuiSetString( tabBackgroundRUI, "callToActionHeader", tabData.callToActionHeader )
		RuiSetString( tabBackgroundRUI, "callToActionTitle", tabData.callToActionTitle )
		RuiSetFloat( tabBackgroundRUI, "callToActionWidth", tabData.callToActionWidth )
	}
}

void function BannerUpdate_Default( TabData tabData )
{
	SeasonStyleData seasonStyle = GetSeasonStyle()
	var tabBackgroundRUI = Hud_GetRui( tabData.background )

	RuiSetInt( tabBackgroundRUI, "totalWidth", GetTabsTotalWidth( tabData ) )
	RuiSetColorAlpha( tabBackgroundRUI, "gradientColor", SrgbToLinear( seasonStyle.seasonColor ), 1.0 )

	RuiSetString( tabBackgroundRUI, "title", tabData.bannerTitle )
	RuiSetString( tabBackgroundRUI, "header", tabData.bannerHeader  )
	RuiSetString( tabBackgroundRUI, "callToActionHeader", tabData.callToActionHeader )
	RuiSetString( tabBackgroundRUI, "callToActionTitle", tabData.callToActionTitle )
	RuiSetColorAlpha( tabBackgroundRUI, "titleTextColor", SrgbToLinear( seasonStyle.titleTextColor ), 1.0 )
	RuiSetColorAlpha( tabBackgroundRUI, "headerTextColor", SrgbToLinear( seasonStyle.headerTextColor ), 1.0 )
	RuiSetFloat( tabBackgroundRUI, "callToActionWidth", tabData.callToActionWidth )
}

int function GetTabsTotalWidth( TabData tabData )
{
	int totalWidth = tabData.selectedExtraWidth
	int numTabs = tabData.tabDefs.len()

	if( numTabs == 1 || !IsControllerModeActive() )
		totalWidth += 30

	if ( IsControllerModeActive() && numTabs > 1 )
	{
		var tabsPanel          = tabData.tabPanel
		var leftShoulder       = Hud_GetChild( tabsPanel, "LeftNavButton" )
		var rightShoulder      = Hud_GetChild( tabsPanel, "RightNavButton" )
		totalWidth += Hud_GetWidth( leftShoulder ) + Hud_GetWidth( leftShoulder )
	}

	foreach( TabDef tabdef in tabData.tabDefs)
	{
		if( tabdef.visible )
			totalWidth += file.tabToWidth[ tabdef ]
	}
	return totalWidth
}

void function RefreshTabsGRXData( TabData tabData )
{
	bool ready = GRX_IsInventoryReady() && GRX_AreOffersReady()

	ItemFlavor season = GetLatestSeason( GetUnixTimestamp() )

	GRXData.title = Season_GetShortName( season )
	GRXData.header = "#MENU_BADGE_SEASON"
	GRXData.callToActionHeader = "#SEASON_ENDS_IN"
	GRXData.callToActionTitle = Season_GetTimeRemainingText( season )
	if ( ready )
	{
		TabDef seasonTabDef = Tab_GetTabDefByBodyName( tabData, "SeasonPanel" )

		if ( ShouldShowPremiumCurrencyDialog() )
			ShowPremiumCurrencyDialog( false )

		ItemFlavor ornull activeCollectionEvent = GetActiveCollectionEvent( GetUnixTimestamp() )
		bool haveActiveCollectionEvent          = (activeCollectionEvent != null)
		ItemFlavor ornull activeThemedShopEvent = GetActiveThemedShopEvent( GetUnixTimestamp() )
		bool haveActiveThemedShopEvent          = (activeThemedShopEvent != null)

		if ( haveActiveCollectionEvent )
		{
			expect ItemFlavor( activeCollectionEvent )
			if ( CollectionEvent_HasLobbyTheme( activeCollectionEvent ) )
			{
				seasonTabDef.useSeasonalColors = false
				seasonTabDef.useCustomColors = true

				seasonTabDef.customDefaultTextCol = CollectionEvent_GetTabTextDefaultCol( activeCollectionEvent )

				seasonTabDef.customFocusedBGCol = CollectionEvent_GetTabBGFocusedCol( activeCollectionEvent )
				seasonTabDef.customFocusedBarCol = CollectionEvent_GetTabBarFocusedCol( activeCollectionEvent )

				seasonTabDef.customSelectedBGCol = CollectionEvent_GetTabBGSelectedCol( activeCollectionEvent )
				seasonTabDef.customSelectedBarCol = CollectionEvent_GetTabBarSelectedCol( activeCollectionEvent )
				seasonTabDef.customSelectedTextCol = CollectionEvent_GetTabTextSelectedCol( activeCollectionEvent )

				seasonTabDef.customGlowFocusedCol = CollectionEvent_GetTabGlowFocusedCol( activeCollectionEvent )
				seasonTabDef.leftSideImage = CollectionEvent_GetTabLeftSideImage( activeCollectionEvent )
				seasonTabDef.centerImage = CollectionEvent_GetTabCenterImage( activeCollectionEvent )
				seasonTabDef.rightSideImage = CollectionEvent_GetTabRightSideImage( activeCollectionEvent )

				seasonTabDef.imageSelectedAlpha = CollectionEvent_GetTabImageSelectedAlpha( activeCollectionEvent )
				seasonTabDef.imageUnselectedAlpha = CollectionEvent_GetTabImageUnselectedAlpha( activeCollectionEvent )

				seasonTabDef.centerRuiAsset = CollectionEvent_GetTabCenterRui( activeCollectionEvent )
			}
		}
		else if ( haveActiveThemedShopEvent )
		{
			expect ItemFlavor( activeThemedShopEvent )
			if ( ThemedShopEvent_HasLobbyTheme( activeThemedShopEvent ) )
			{
				seasonTabDef.useSeasonalColors = false
				seasonTabDef.useCustomColors = true

				seasonTabDef.customDefaultTextCol = ThemedShopEvent_GetTabTextDefaultCol( activeThemedShopEvent )

				seasonTabDef.customFocusedBGCol = ThemedShopEvent_GetTabBGFocusedCol( activeThemedShopEvent )
				seasonTabDef.customFocusedBarCol = ThemedShopEvent_GetTabBarFocusedCol( activeThemedShopEvent )

				seasonTabDef.customSelectedBGCol = ThemedShopEvent_GetTabBGSelectedCol( activeThemedShopEvent )
				seasonTabDef.customSelectedBarCol = ThemedShopEvent_GetTabBarSelectedCol( activeThemedShopEvent )
				seasonTabDef.customSelectedTextCol = ThemedShopEvent_GetTabTextSelectedCol( activeThemedShopEvent )

				seasonTabDef.customGlowFocusedCol = ThemedShopEvent_GetTabGlowFocusedCol( activeThemedShopEvent )
				seasonTabDef.leftSideImage = ThemedShopEvent_GetTabLeftSideImage( activeThemedShopEvent )
				seasonTabDef.centerImage = ThemedShopEvent_GetTabCenterImage( activeThemedShopEvent )
				seasonTabDef.rightSideImage = ThemedShopEvent_GetTabRightSideImage( activeThemedShopEvent )

				seasonTabDef.imageSelectedAlpha = ThemedShopEvent_GetTabImageSelectedAlpha( activeThemedShopEvent )
				seasonTabDef.imageUnselectedAlpha = ThemedShopEvent_GetTabImageUnselectedAlpha( activeThemedShopEvent )

				seasonTabDef.centerRuiAsset = ThemedShopEvent_GetTabCenterRui( activeThemedShopEvent )
			}
		}
		else       
		{
			seasonTabDef.leftSideImage = $""
			seasonTabDef.rightSideImage = $""
			seasonTabDef.centerRuiAsset = $""
		}
	}
}

void function SetTabDefsToSeasonal( TabData tabData )
{
	foreach( def in tabData.tabDefs )
	{
		def.useSeasonalColors = true
	}
}

TabDef function AddTab( var parentPanel, var panel, string tabTitle, asset icon = $"" )
{
	TabData tabData = GetTabDataForPanel( parentPanel )

	TabDef data
	data.button = tabData.tabButtons[tabData.tabDefs.len()]
	data.panel = panel
	data.title = tabTitle
	data.icon = icon
	data.parentPanel = parentPanel

	int width = 200
	file.tabToWidth[ data ] <- width

	float screenSizeXFrac =  GetScreenSize().width / 1920.0
	float screenSizeYFrac =  GetScreenSize().height / 1080.0
	float multiplicationRatio = ( screenSizeYFrac > 1.0 && screenSizeXFrac <= 1.0 )? screenSizeXFrac: screenSizeYFrac

	file.tabToAdjustedWidth[ data ] <- int( width * multiplicationRatio )

	if( panel != null )
		file.tabBodyDefMap[data.panel] <- data

	Hud_Show( data.button )

	file.elementTabData[parentPanel].tabDefs.append( data )
	file.elements.append(parentPanel)
	if ( file.elementTabData[parentPanel].tabDefs.len() == 1 )
		file.elementTabData[parentPanel].activeTabIdx = 0

	UpdateMenuTabs()

	return data
}


TabData function GetTabDataForPanel( var element )
{
	return file.elementTabData[element]
}


void function ClearTabs( var panel )
{
	TabData tabData = GetTabDataForPanel( panel )

	if ( tabData.activeTabIdx != INVALID_TAB_INDEX )
		DeactivateTab( tabData )

	tabData.tabDefs.clear()
	tabData.activeTabIdx = INVALID_TAB_INDEX

	UpdateMenuTabs()
}


int function Tab_GetTabIndexByBodyName( TabData tabData, string bodyName )
{
	foreach ( index, tabDef in tabData.tabDefs )
	{
		if ( Hud_GetHudName( tabDef.panel ) != bodyName )
			continue

		return index
	}

	return -1
}


TabDef function Tab_GetTabDefByBodyName( TabData tabData, string bodyName )
{
	foreach ( index, tabDef in tabData.tabDefs )
	{
		if ( Hud_GetHudName( tabDef.panel ) != bodyName )
			continue

		return tabDef
	}

	Assert( false )

	unreachable
}


void function SetTabNavigationEndCallback( TabData tabData, int tabSide, void functionref() callbackFunc )
{
	tabData.tabNavigationEndCallbacks[tabSide] <- callbackFunc
}

void function SetTabNavigationCallback( TabData tabData, void functionref( TabDef ) callbackFunc )
{
	tabData.tabNavigationCallbacks = callbackFunc
}

bool function IsTabActive( TabData tabData )
{
	if ( tabData.activeTabIdx == INVALID_TAB_INDEX )
		return false

	var panel = tabData.tabDefs[tabData.activeTabIdx].panel
	return uiGlobal.panelData[panel].isActive
}

                                                        
                                                                                     
                                                                                                                                                                              
void function ActivateTab( TabData tabData, int tabIndex )
{
	if ( !CanNavigateFromActiveTab( tabData, tabIndex ) )
		return

	SetLastMenuNavDirection( MENU_NAV_FORWARD )

	array<TabDef> tabDefs = tabData.tabDefs
	tabData.activeTabIdx = tabIndex

	UpdateMenuTabs()

	var panel = tabDefs[ tabIndex ].panel

	if ( tabData.tabNavigationCallbacks != null )
	{
		tabData.tabNavigationCallbacks( tabDefs[ tabIndex ] )
	}
	if ( panel != null )
	{
		HideVisibleTabBodies( tabData )
		ShowPanel( panel )
	}

	UpdateMenuTabs()                                                                                                                              

	OnTabChanged()
}


void function HideVisibleTabBodies( TabData tabData )
{
	foreach ( tabDef in tabData.tabDefs )
		HidePanel( tabDef.panel )
}


void function DeactivateTab( TabData tabData )
{
	if ( tabData.activeTabIdx == INVALID_TAB_INDEX )
		return

	if( tabData.tabDefs[tabData.activeTabIdx].panel == null )
		return

	HidePanel( tabData.tabDefs[tabData.activeTabIdx].panel )
}


int function GetMenuActiveTabIndex( var menu )
{
	return GetTabDataForPanel( menu ).activeTabIdx
}


int function GetMenuNumTabs( var menu )
{
	return GetTabDataForPanel( menu ).tabDefs.len()
}


void function ShowPanel( var panel )
{
	if ( uiGlobal.panelData[ panel ].isActive )
		return

	uiGlobal.panelData[ panel ].isActive = true

	if ( uiGlobal.panelData[ panel ].isCurrentlyShown )
		return

	if ( IsMenuVisible( panel ) )
		return

	ShowPanelInternal( panel )
}


void function ShowPanelInternal( var panel )
{
	Hud_Show( panel )

	uiGlobal.activePanels.append( panel )
	UpdateFooterOptions()

	var menu = GetParentMenu( panel )
	UpdateMenuBlur( menu )
	if ( uiGlobal.panelData[ panel ].panelClearBlur )
		ClearMenuBlur( menu )

	Assert( !uiGlobal.panelData[ panel ].isCurrentlyShown )
	uiGlobal.panelData[ panel ].isCurrentlyShown = true
	uiGlobal.panelData[ panel ].enterTime = UITime()

	foreach ( showFunc in uiGlobal.panelData[ panel ].showFuncs )
		showFunc( panel )
}

void function AnimateInSmallTabBar( TabData tabData )
{
	Hud_SetY( tabData.tabPanel, Hud_GetHeight( tabData.tabPanel ) )
	Hud_ReturnToBasePosOverTime( tabData.tabPanel, 0.25, INTERPOLATOR_DEACCEL )

	if( tabData.background != null )
	{
		Hud_SetY( tabData.background, Hud_GetHeight( tabData.background ) )
		Hud_ReturnToBasePosOverTime( tabData.background, 0.25, INTERPOLATOR_DEACCEL )
	}
}

void function AnimateOutSmallTabBar( TabData tabData )
{
	Hud_SetYOverTime( tabData.tabPanel, Hud_GetHeight( tabData.tabPanel ), 0.25, INTERPOLATOR_DEACCEL )

	if( tabData.background != null )
	{
		Hud_SetYOverTime( tabData.background, Hud_GetHeight( tabData.background ),0.25, INTERPOLATOR_DEACCEL )
	}
}

void function HidePanel( var panel )
{
	if ( !uiGlobal.panelData[ panel ].isActive )
		return

	uiGlobal.panelData[ panel ].isActive = false

	if ( !uiGlobal.panelData[ panel ].isCurrentlyShown )
		return

	HidePanelInternal( panel )
}


void function HidePanelInternal( var panel )
{
	Hud_Hide( panel )

	uiGlobal.activePanels.removebyvalue( panel )

	Assert( uiGlobal.panelData[ panel ].isCurrentlyShown )

	uiGlobal.panelData[ panel ].isCurrentlyShown = false
	SetLastMenuIDForPIN( Hud_GetHudName( panel ) )

	bool isMenu = false
	PIN_PageView( Hud_GetHudName( panel ), UITime() - uiGlobal.panelData[ panel ].enterTime, GetLastMenuIDForPIN(), isMenu, uiGlobal.panelData[ panel ].pin_metaData )                                                                                                      

	foreach ( hideFunc in uiGlobal.panelData[ panel ].hideFuncs )
		hideFunc( panel )
}


void function ShutdownAllPanels()
{
	uiGlobal.activePanels.clear()                         

	foreach ( var panel, PanelDef panelDef in uiGlobal.panelData )
		HidePanel( panel )
}


void function UpdateMenuTabs()
{
	var menu = GetActiveMenu()
	SeasonStyleData seasonStyle = GetSeasonStyle()

	if ( menu == null )
		return

	if( !seasonStyle.hasRefreshedOnce && IsConnected() )                                                  
	{
		RefreshTabsSeasonalData()
		seasonStyle = GetSeasonStyle()
	}


	float screenSizeXFrac =  GetScreenSize().width / 1920.0
	float screenSizeYFrac =  GetScreenSize().height / 1080.0
	float multiplicationRatio = ( screenSizeYFrac > 1.0 && screenSizeXFrac <= 1.0 )? screenSizeXFrac: screenSizeYFrac

	bool isNestedTabActive = Tab_GetActiveNestedTabData( menu ) != null

	array<var> tabButtonPanels = GetElementsByClassname( menu, "TabsCommonClass" )
	foreach ( tabButtonPanel in tabButtonPanels )
	{
		var parentPanel = Hud_GetParent( tabButtonPanel )
		TabData tabData = GetTabDataForPanel( parentPanel )

		array<TabDef> tabDefs           = tabData.tabDefs
		array<var> tabButtons           = tabData.tabButtons
		int numTabs                     = tabDefs.len()
		int numTabsEnabled              = 0

		int leftMostVisibleTabIndex  = -1
		int rightMostVisibleTabIndex = 0
		int firstTabXOffset          = 0
		int totalWidth               = 0
		int baseTotalWidth           = 0
		var previousPanelForPinning  = null

		foreach ( tabIndex, tabButton in tabButtons )
		{
			if ( tabIndex == 0 )
				continue

			Hud_SetPinSibling( tabButton, Hud_GetHudName( tabButtons[tabIndex - 1] ) )
		}

		Lobby_AdjustScreenFrameToMaxSize( tabData.background )

		for ( int tabIndex = 0; tabIndex < MAX_TABS; tabIndex++ )
		{
			var tabButton    = tabButtons[ tabIndex ]
			var tabButtonRUI = Hud_GetRui( tabButton )

			if ( previousPanelForPinning != null )
			{
				Hud_SetPinSibling( tabButton, Hud_GetHudName( previousPanelForPinning ) )
			}

			if ( tabIndex < numTabs )
			{
				TabDef tabDef = tabDefs[tabIndex]

				int forceAccessSetting = 0
				if ( IsConnected() && tabDef.panel != null )
					forceAccessSetting = GetCurrentPlaylistVarInt( format( "ui_tabs_force_access_%s", Hud_GetHudName( tabDef.panel ) ).tolower(), 0 )

				if ( forceAccessSetting == 1 )
				{
					tabDef.visible = true
					tabDef.enabled = true
				}
				else if ( forceAccessSetting == -1 )
				{
					tabDef.enabled = false
					tabDef.new = false
				}
			}

			if ( tabIndex >= numTabs || !tabDefs[tabIndex].visible )
			{
				RuiSetString( tabButtonRUI, "buttonText", "" )

				Hud_SetEnabled( tabButton, false )
				Hud_SetNew( tabButton, false )
				Hud_SetVisible( tabButton, false )
				Hud_SetWidth( tabButton, 0 )
				continue
			}

			previousPanelForPinning = tabButton
			Hud_SetVisible( tabButton, true )

			if ( leftMostVisibleTabIndex == -1 && (!tabData.customFirstTabButton || tabIndex > 0) )
				leftMostVisibleTabIndex = tabIndex
			rightMostVisibleTabIndex = tabIndex
			TabDef tabDef = tabDefs[tabIndex]

			bool isActiveTab = tabIndex == tabData.activeTabIdx
			Hud_SetSelected( tabButton, isActiveTab )

			int tabWidth = file.tabToAdjustedWidth[ tabDef ]

			float buttonScale = ( float( tabWidth ) + tabData.selectedExtraWidth) / float( tabWidth )
			int buttonWidth = int( buttonScale * tabWidth )
			if( tabData.selectedExtraWidth != 0.0 )
			{
				if( isActiveTab )
				{
					totalWidth += tabData.selectedExtraWidth
					Hud_ScaleOverTime( tabButton, buttonScale, 1.0,tabData.selectedScaleAnimationTime, INTERPOLATOR_DEACCEL )
				}
				else
				{
					Hud_ReturnToBaseScaleOverTime( tabButton, tabData.selectedScaleAnimationTime, INTERPOLATOR_DEACCEL )
				}
			}
			else
			{
				Hud_SetWidth( tabButton, tabWidth )
			}

			RuiSetString( tabButtonRUI, "buttonText", tabDef.title )
			RuiSetAsset( tabButtonRUI, "buttonIcon", tabDef.icon )
			RuiSetBool( tabButtonRUI, "useCustomColors", tabDef.useSeasonalColors || tabDef.useCustomColors )

			if( Tab_IsRootLevel( tabData ) )
			{
				TabData ornull childTabData = GetChildTabData( tabDef.panel )

				if( childTabData != null )
				{
					expect TabData(childTabData)
					int numSubTabs = childTabData.tabDefs.len()

					for ( int subTabIndex = 0; subTabIndex < MAX_SUBTABS; subTabIndex++ )
					{
						if ( subTabIndex >= numSubTabs || !childTabData.tabDefs[subTabIndex].visible || tabDef.hideSubtabPips )
						{
							RuiSetBool( tabButtonRUI, "subTab" + subTabIndex +  "Visible", false )
							continue
						}
						else
						{
							RuiSetBool( tabButtonRUI, "subTab" + subTabIndex +  "Visible", true )
						}
					}
					if( isActiveTab )
						RuiSetInt( tabButtonRUI, "subTabActive", childTabData.activeTabIdx )
					else
						RuiSetInt( tabButtonRUI, "subTabActive", -1 )
				}
			}


			                       

			RuiSetColorAlpha( tabButtonRUI, "customNewCol", SrgbToLinear( seasonStyle.seasonNewColor ), 1.0 )
			RuiSetAsset( tabButtonRUI, "leftSideImage", tabDef.leftSideImage )
			RuiSetAsset( tabButtonRUI, "rightSideImage", tabDef.rightSideImage )

			if( tabDef.centerRuiAsset != $"" )
			{
				if( tabDef.currentCenterRuiAsset != tabDef.centerRuiAsset )
				{
					RuiDestroyNestedIfAlive( tabButtonRUI, "centerRui" )
					tabDef.currentCenterRui =  RuiCreateNested( tabButtonRUI, "centerRui", tabDef.centerRuiAsset )
				}

				if( ( isActiveTab && !tabDef.isActive ) && tabDef.currentCenterRui != null )
				{
					RuiSetGameTime( tabDef.currentCenterRui, "startTime", ClientTime() )
				}

				tabDef.currentCenterRuiAsset = tabDef.centerRuiAsset
			}
			else
			{
				RuiDestroyNestedIfAlive( tabButtonRUI, "centerRui" )
				tabDef.currentCenterRuiAsset = $""
				tabDef.currentCenterRui = null
			}

			if( tabDef.useSeasonalColors )
			{
				if( Tab_IsRootLevel( tabData ) || tabData.forcePrimaryNav )
				{
					RuiSetColorAlpha( tabButtonRUI, "customDefaultTextCol", SrgbToLinear( seasonStyle.tabDefaultTextCol ), 1.0 )

					RuiSetColorAlpha( tabButtonRUI, "customFocusedBGCol", SrgbToLinear( seasonStyle.tabFocusedBGCol ), 1.0 )
					RuiSetColorAlpha( tabButtonRUI, "customFocusedBarCol", SrgbToLinear( seasonStyle.tabFocusedBarCol ), 1.0 )

					RuiSetColorAlpha( tabButtonRUI, "customSelectedBGCol", SrgbToLinear( seasonStyle.tabSelectedBGCol ), 1.0 )
					RuiSetColorAlpha( tabButtonRUI, "customSelectedBarCol", SrgbToLinear( seasonStyle.tabSelectedBarCol ), 1.0 )
					RuiSetColorAlpha( tabButtonRUI, "customSelectedTextCol", SrgbToLinear( seasonStyle.tabSelectedTextCol ), 1.0 )

					RuiSetColorAlpha( tabButtonRUI, "customGlowFocusedCol", SrgbToLinear( seasonStyle.tabGlowFocusedCol ), 1.0 )
				}
				else
				{
					RuiSetColorAlpha( tabButtonRUI, "customDefaultTextCol", SrgbToLinear( seasonStyle.subtabDefaultTextCol ), 1.0 )

					RuiSetColorAlpha( tabButtonRUI, "customFocusedBGCol", SrgbToLinear( seasonStyle.subtabFocusedBGCol ), 1.0 )
					RuiSetColorAlpha( tabButtonRUI, "customFocusedBarCol", SrgbToLinear( seasonStyle.subtabFocusedBarCol ), 1.0 )

					RuiSetColorAlpha( tabButtonRUI, "customSelectedBGCol", SrgbToLinear( seasonStyle.subtabSelectedBGCol ), 1.0 )
					RuiSetColorAlpha( tabButtonRUI, "customSelectedBarCol", SrgbToLinear( seasonStyle.subtabSelectedBarCol ), 1.0 )
					RuiSetColorAlpha( tabButtonRUI, "customSelectedTextCol", SrgbToLinear( seasonStyle.subtabSelectedTextCol ), 1.0 )

					RuiSetColorAlpha( tabButtonRUI, "customGlowFocusedCol", SrgbToLinear( seasonStyle.subtabGlowFocusedCol ), 1.0 )
				}
			}

			                                                                       
			if( tabDef.useCustomColors )
			{
				RuiSetColorAlpha( tabButtonRUI, "customDefaultTextCol", SrgbToLinear( tabDef.customDefaultTextCol ), 1.0 )

				RuiSetColorAlpha( tabButtonRUI, "customFocusedBGCol", SrgbToLinear( tabDef.customFocusedBGCol ), 1.0 )
				RuiSetColorAlpha( tabButtonRUI, "customFocusedBarCol", SrgbToLinear( tabDef.customFocusedBarCol ), 1.0 )

				RuiSetColorAlpha( tabButtonRUI, "customSelectedBGCol", SrgbToLinear( tabDef.customSelectedBGCol ), 1.0 )
				RuiSetColorAlpha( tabButtonRUI, "customSelectedBarCol", SrgbToLinear( tabDef.customSelectedBarCol ), 1.0 )
				RuiSetColorAlpha( tabButtonRUI, "customSelectedTextCol", SrgbToLinear( tabDef.customSelectedTextCol ), 1.0 )

				RuiSetColorAlpha( tabButtonRUI, "customGlowFocusedCol", SrgbToLinear( tabDef.customGlowFocusedCol ), 1.0 )
				RuiSetColorAlpha( tabButtonRUI, "customNewCol", SrgbToLinear( tabDef.customNewColor ), 1.0 )
			}

			if ( tabDef.enabled )
				numTabsEnabled++

			Hud_SetEnabled( tabButton, tabDef.enabled )
			Hud_SetNew( tabButton, tabDef.new )

			tabDef.isActive = isActiveTab

			totalWidth += tabWidth
			baseTotalWidth += Hud_GetBaseWidth( tabButton )

			if( tabData.bannerUpdateCallback != null )
				tabData.bannerUpdateCallback( tabData )
		}

		var tabsPanel          = tabData.tabPanel
		var leftMostTabButton  = tabButtons[ leftMostVisibleTabIndex != -1 ? leftMostVisibleTabIndex : 0 ]
		var rightMostTabButton = tabButtons[ rightMostVisibleTabIndex ]
		var leftShoulder       = Hud_GetChild( tabsPanel, "LeftNavButton" )
		var rightShoulder      = Hud_GetChild( tabsPanel, "RightNavButton" )

		if ( GetMenuVarBool( "isGamepadActive" ) && numTabs > 1 && numTabsEnabled > 1 )
		{
			string leftText
			string rightText

			if ( Tab_IsRootLevel( tabData ) || tabData.forcePrimaryNav )
			{
				leftText = "%L_SHOULDER%"
				rightText ="%R_SHOULDER%"
			}
			else
			{
				leftText = "%L_TRIGGER%"
				rightText = "%R_TRIGGER%"
			}

			SetLabelRuiText( leftShoulder, leftText )
			Hud_SetVisible( leftShoulder, true )

			SetLabelRuiText( rightShoulder, rightText )
			Hud_SetVisible( rightShoulder, true)

			if ( tabData.groupNavHints )
			{
				Hud_SetPinSibling( leftShoulder, Hud_GetHudName( rightMostTabButton ) )
				Hud_SetPinSibling( rightShoulder, Hud_GetHudName( leftShoulder ) )
			}
			else
			{
				Hud_SetPinSibling( leftShoulder, Hud_GetHudName( leftMostTabButton ) )
				Hud_SetPinSibling( rightShoulder, Hud_GetHudName( rightMostTabButton ) )
			}
		}
		else
		{
			SetLabelRuiText( leftShoulder, "" )
			Hud_SetVisible( leftShoulder, false )

			SetLabelRuiText( rightShoulder, "" )
			Hud_SetVisible( rightShoulder, false )
		}
		firstTabXOffset += int( tabData.initialFirstTabButtonXPos * multiplicationRatio )

		if ( tabData.centerTabs )
		{
			firstTabXOffset -= totalWidth / 2
		}

		Hud_SetX( tabButtons[0], firstTabXOffset )
	}
}

void function SetTabBaseWidth( TabDef tabDef, int width )
{
	file.tabToWidth[ tabDef ] <- width

	float screenSizeXFrac =  GetScreenSize().width / 1920.0
	float screenSizeYFrac =  GetScreenSize().height / 1080.0
	float multiplicationRatio = ( screenSizeYFrac > 1.0 && screenSizeXFrac <= 1.0 )? screenSizeXFrac: screenSizeYFrac

	file.tabToAdjustedWidth[ tabDef ] <- int( width * multiplicationRatio )
	Hud_SetBaseSize( tabDef.button, file.tabToAdjustedWidth[ tabDef ], Hud_GetHeight( tabDef.button ) )
}

TabData ornull function GetChildTabData( var parentToCheck )
{
	var menu = GetActiveMenu()
	array<TabDef> visibleTabs

	array<var> tabButtonPanels = GetElementsByClassname( menu, "TabsCommonClass" )
	foreach ( tabButtonPanel in tabButtonPanels )
	{
		var parentPanel = Hud_GetParent( tabButtonPanel )
		TabData tabData = GetTabDataForPanel( parentPanel )
		if( !Tab_IsRootLevel( tabData ) && parentToCheck == parentPanel )
		{
			return tabData
		}
	}

	return null
}

bool function Tab_IsRootLevel( TabData tabData )
{
	return tabData.parentPanel == GetParentMenu( tabData.parentPanel )
}


TabData function GetParentTabData( var button )
{
	return file.elementTabData[file.tabButtonParents[button]]
}


void function OnTab_GetFocus( var button )
{
	TabData tabData = GetParentTabData( button )
	int tabIndex    = int( Hud_GetScriptID( button ) )

	if ( !IsTabIndexEnabled( tabData, tabIndex ) )
		return

	UpdateMenuTabs()
}


void function OnTab_LoseFocus( var button )
{
}


bool function CanNavigateFromActiveTab( TabData tabData, int desinationTabIndex )
{
	TabDef tabDef = tabData.tabDefs[tabData.activeTabIdx]
	if ( tabDef.canNavigateFunc == null )
		return true

	return tabDef.canNavigateFunc( tabData.parentPanel, desinationTabIndex )
}


void function OnTab_Activate( var button )
{
	TabData tabData = GetParentTabData( button )
	int tabIndex    = int( Hud_GetScriptID( button ) )

	if ( !IsTabIndexEnabled( tabData, tabIndex ) )
		return

	if ( tabData.tabNavigationDisabled )
		return

	string animPrefix
	if ( tabIndex < tabData.activeTabIdx )
		animPrefix = "MoveRight_"
	else if ( tabIndex > tabData.activeTabIdx )
		animPrefix = "MoveLeft_"
	else
		return                       

	                                                                                            

	ActivateTab( tabData, tabIndex )

	                                                                                            
}


void function OnMenuTab_NavLeft( var unusedNull )
{
	var menu = GetActiveMenu()
	if ( menu == null )
		return


	TabData ornull tabData = Tab_GetActiveNestedTabData( menu )

	if ( tabData == null )              
	{
		if ( !IsPanelTabbed( menu ) )
			return

		tabData = GetTabDataForPanel( menu )
	}
	else                  
	{
		expect TabData( tabData )

		if( !Tab_IsRootLevel( tabData ) && !tabData.forcePrimaryNav )
			tabData = GetTabDataForPanel( menu )
	}

	expect TabData( tabData )

	if ( tabData.tabNavigationDisabled )
	{
		                                                   
		if ( tabData.tabNavigationEndCallbacks[eTabDirection.PREV] != null )
			tabData.tabNavigationEndCallbacks[eTabDirection.PREV]()

		return
	}

	ActivateTabPrev( tabData )
}


void function ActivateTabPrev( TabData tabData )
{
	int tabIndex = tabData.activeTabIdx

	int tabsChecked = 0

	while ( tabsChecked < tabData.tabDefs.len() )
	{

		tabIndex--
		if( tabIndex < 0 )
			tabIndex = tabData.tabDefs.len() - 1

		tabsChecked++
		if ( !IsTabIndexVisible( tabData, tabIndex ) || !IsTabIndexEnabled( tabData, tabIndex ) )
			continue

		if( tabIndex != tabData.activeTabIdx )
		{
			EmitUISound( tabData.tabLeftSound )
			ActivateTab( tabData, tabIndex )
		}



		return
	}

	UpdateMenuTabs()
}


void function ActivateTabNext( TabData tabData )
{
	int tabIndex = tabData.activeTabIdx

	int tabsChecked = 0

	while ( tabsChecked < tabData.tabDefs.len() )
	{
		tabIndex++
		if( tabIndex > tabData.tabDefs.len() - 1 )
			tabIndex = 0

		tabsChecked++
		if ( !IsTabIndexVisible( tabData, tabIndex ) || !IsTabIndexEnabled( tabData, tabIndex ) )
			continue
		if( tabIndex != tabData.activeTabIdx )
		{
			EmitUISound( tabData.tabRightSound )
			ActivateTab( tabData, tabIndex )
		}

		return
	}

	UpdateMenuTabs()
}


void function OnMenuTab_NavRight( var unusedNull )
{
	var menu = GetActiveMenu()
	if ( menu == null )
		return

	TabData ornull tabData = Tab_GetActiveNestedTabData( menu )
	if ( tabData == null )                       
	{
		if ( !IsPanelTabbed( menu ) )
			return

		tabData = GetTabDataForPanel( menu )
	}else                  
	{
		expect TabData( tabData )

		if( !Tab_IsRootLevel( tabData ) && !tabData.forcePrimaryNav )
			tabData = GetTabDataForPanel( menu )
	}

	expect TabData( tabData )

	if ( tabData.tabNavigationDisabled )
		return

	ActivateTabNext( tabData )
}


void function SetTabNavigationEnabled( var menu, bool state )
{
	GetTabDataForPanel( menu ).tabNavigationDisabled = !state
}


TabData ornull function Tab_GetActiveNestedTabData( var menu )
{
	array<var> tabButtonPanels = GetElementsByClassname( menu, "TabsCommonClass" )
	foreach ( tabButtonPanel in tabButtonPanels )
	{
		var parentPanel = Hud_GetParent( tabButtonPanel )
		TabData tabData = GetTabDataForPanel( parentPanel )

		if ( Tab_IsRootLevel( tabData ) )
			continue

		if ( !uiGlobal.panelData[ parentPanel ].isActive )
			continue

		return tabData
	}

	return null
}

float function Tab_GetHoldTimeToIgnoreTap()
{
	return 0.35
}

void function OnNestedTab_NavLeftOnPressed( var unusedNull )
{
	var menu = GetActiveMenu()
	if ( menu == null )
		return
	TabData ornull tabData = Tab_GetActiveNestedTabData( menu )
	if ( tabData == null )
		return

	expect TabData( tabData )

	if ( tabData.tabNavigationDisabled || tabData.forcePrimaryNav )
		return

	int tabIndex = tabData.activeTabIdx
	bool useTapHoldLogic  = tabData.tabDefs[tabIndex].useTapHoldLogic
	if( useTapHoldLogic )
	{
		RunClientScript( "LockCameraZoomModel", Tab_GetHoldTimeToIgnoreTap() )
		tabData.lastTapLeftTime = UITime()
	}
}

void function OnNestedTab_NavLeftOnReleased( var unusedNull )
{
	var menu = GetActiveMenu()
	if ( menu == null )
		return

	TabData ornull tabData = Tab_GetActiveNestedTabData( menu )
	if ( tabData == null )
		return

	expect TabData( tabData )
	int tabIndex = tabData.activeTabIdx


	if( tabData.tabDefs[tabIndex].useTapHoldLogic && tabData.lastTapLeftTime + Tab_GetHoldTimeToIgnoreTap() < UITime() )
		return

	if ( tabData.tabNavigationDisabled || tabData.forcePrimaryNav )
		return

	OnNestedTab_PreviousTab( tabData, tabIndex )
}

void function OnNestedTab_PreviousTab( TabData tabData, int tabIndex )
{
	int tabsChecked = 0
	while ( tabsChecked < tabData.tabDefs.len() )
	{
		tabIndex--

		tabsChecked++
		if( tabIndex < 0 )
			tabIndex = tabData.tabDefs.len() - 1

		if ( !IsTabIndexEnabled( tabData, tabIndex ) )
			continue

		EmitUISound( tabData.tabLeftSound )
		ActivateTab( tabData, tabIndex )
		break
	}
}

void function OnNestedTab_NavRightOnPressed( var unusedNull )
{
	var menu = GetActiveMenu()
	if ( menu == null )
		return

	TabData ornull tabData = Tab_GetActiveNestedTabData( menu )
	if ( tabData == null )
		return

	expect TabData( tabData )

	if ( tabData.tabNavigationDisabled || tabData.forcePrimaryNav )
		return

	int tabIndex = tabData.activeTabIdx
	bool useTapHoldLogic  = tabData.tabDefs[tabIndex].useTapHoldLogic

	if( useTapHoldLogic )
	{
		RunClientScript( "LockCameraZoomModel", Tab_GetHoldTimeToIgnoreTap() )
		tabData.lastTapRightTime = UITime()
	}
}

void function OnNestedTab_NavRightOnReleased( var unusedNull )
{
	var menu = GetActiveMenu()
	if ( menu == null )
		return

	TabData ornull tabData = Tab_GetActiveNestedTabData( menu )
	if ( tabData == null )
		return

	expect TabData( tabData )

	int tabIndex = tabData.activeTabIdx


	if( tabData.tabDefs[tabIndex].useTapHoldLogic && tabData.lastTapRightTime + Tab_GetHoldTimeToIgnoreTap() < UITime() )
		return

	if ( tabData.tabNavigationDisabled || tabData.forcePrimaryNav )
		return

	OnNestedTab_NextTab( tabData, tabIndex )
}

void function OnNestedTab_NextTab( TabData tabData, int tabIndex )
{
	int tabsChecked = 0
	while ( tabsChecked < tabData.tabDefs.len() )
	{
		tabIndex++
		tabsChecked++

		if( tabIndex > tabData.tabDefs.len() - 1 )
			tabIndex = 0

		if ( !IsTabIndexEnabled( tabData, tabIndex ) )
			continue

		EmitUISound( tabData.tabRightSound )
		ActivateTab( tabData, tabIndex )
		break
	}
}

bool function _HasActiveTabPanel( var menu )
{
	if ( menu == null )
		return false

	if ( !(menu in file.elementTabData) )
		return false

	TabData tabData = GetTabDataForPanel( menu )
	return tabData.activeTabIdx != INVALID_TAB_INDEX
}


var function _GetActiveTabPanel( var menu )
{
	if ( menu == null )
		return null

	TabData tabData = GetTabDataForPanel( menu )
	if ( tabData.activeTabIdx == INVALID_TAB_INDEX )
		return null
	return tabData.tabDefs[tabData.activeTabIdx].panel
}


void function _OnTab_NavigateBack( var unusedNull )
{
	if ( !_HasActiveTabPanel( GetActiveMenu() ) )
		return

	if ( Lobby_IsInputBlocked( BUTTON_B ) || Lobby_IsInputBlocked( KEY_ESCAPE ) )
		return

	var activeTabPanel = _GetActiveTabPanel( GetActiveMenu() )

	if ( activeTabPanel != null && uiGlobal.panelData[ activeTabPanel ].navBackFunc != null )
		uiGlobal.panelData[ activeTabPanel ].navBackFunc( activeTabPanel )
}


void function OnTab_DPadUp( var unusedNull )
{
	if ( !_HasActiveTabPanel( GetActiveMenu() ) )
		return

	var activeTabPanel = _GetActiveTabPanel( GetActiveMenu() )

	if ( uiGlobal.panelData[ activeTabPanel ].navUpFunc != null )
		uiGlobal.panelData[ activeTabPanel ].navUpFunc( activeTabPanel )
}


void function OnTab_DPadDown( var unusedNull )
{
	if ( !_HasActiveTabPanel( GetActiveMenu() ) )
		return

	var activeTabPanel = _GetActiveTabPanel( GetActiveMenu() )

	if ( uiGlobal.panelData[ activeTabPanel ].navDownFunc != null )
		uiGlobal.panelData[ activeTabPanel ].navDownFunc( activeTabPanel )
}

void function OnTab_InputHandler( var panel, int inputID )
{
	if( panel == null )
		return

	if ( !(inputID in uiGlobal.panelData[ panel ].panelInputs) )
		return

	if ( Lobby_IsInputBlocked( inputID ) )
		return

	if ( uiGlobal.panelData[ panel ].panelInputs[inputID] != null )
		uiGlobal.panelData[ panel ].panelInputs[inputID]( panel )
}


bool function IsPanelTabbed( var parentPanel )
{
	return parentPanel in file.elementTabData
}


void function SetPanelTabVisible( var panel, bool visible )
{
	TabDef tab = GetTabForTabBody( panel )

	if ( tab.visible != visible )
	{
		tab.visible = visible
		UpdateMenuTabs()
	}
}


void function SetPanelTabEnabled( var panel, bool enabled )
{
	TabDef tab = GetTabForTabBody( panel )

	if ( tab.enabled != enabled )
	{
		tab.enabled = enabled
		UpdateMenuTabs()
	}
}


void function SetTabDefVisible( TabDef tabDef, bool state )
{
	if ( state == tabDef.visible )
		return

	tabDef.visible = state

	               
	   
	  	                                                  
	  	                                                                                                   
	  	 
	  		                                                                                                           
	  		 
	  			                                                       
	  			                                                         
	  				        
	  
	  			                                      
	  			                                                   
	  		 
	  		                                                                                        
	  		 
	  			                                                       
	  			                                                         
	  				        
	  
	  			                                      
	  			                                                   
	  		 
	  
	  		                                                                                                                                       
	  	 
	   

	UpdateMenuTabs()
}


void function SetTabDefEnabled( TabDef tabDef, bool state )
{
	tabDef.enabled = state
	UpdateMenuTabs()
}


void function SetPanelTabNew( var panel, bool new )
{
	TabDef tab = GetTabForTabBody( panel )

	if ( tab.new != new )
	{
		tab.new = new
		UpdateMenuTabs()
	}
}


bool function IsTabIndexVisible( TabData tabData, int tabIndex )
{
	return tabIndex >= 0 && tabIndex < tabData.tabDefs.len() && tabData.tabDefs[ tabIndex ].visible
}


bool function IsTabIndexEnabled( TabData tabData, int tabIndex )
{
	return tabIndex >= 0 && tabIndex < tabData.tabDefs.len() && tabData.tabDefs[ tabIndex ].enabled
}


bool function IsTabPanelActive( var tabPanel )
{
	if ( !IsPanelTabbed( GetActiveMenu() ) )
	{
		if ( IsTabBody( tabPanel ) )
		{
			return _GetActiveTabPanel( GetTabForTabBody( tabPanel ).parentPanel ) == tabPanel
		}
		return false
	}

	return _GetActiveTabPanel( GetActiveMenu() ) == tabPanel
}

void function RegisterTabNavigationInput()
{
	if ( !file.tabButtonsRegistered )
	{
		RegisterButtonPressedCallback( BUTTON_SHOULDER_LEFT, OnMenuTab_NavLeft )
		RegisterButtonPressedCallback( BUTTON_SHOULDER_RIGHT, OnMenuTab_NavRight )

		RegisterButtonPressedCallback( BUTTON_TRIGGER_LEFT, OnNestedTab_NavLeftOnPressed )
		RegisterButtonPressedCallback( BUTTON_TRIGGER_RIGHT, OnNestedTab_NavRightOnPressed )
		RegisterButtonReleasedCallback( BUTTON_TRIGGER_LEFT, OnNestedTab_NavLeftOnReleased )
		RegisterButtonReleasedCallback( BUTTON_TRIGGER_RIGHT, OnNestedTab_NavRightOnReleased )

		                                                               
		                                                                   

		RegisterButtonPressedCallback( BUTTON_Y, OnTab_ButtonY )                                                                           
		RegisterButtonPressedCallback( BUTTON_X, OnTab_ButtonX )                                                                           
		file.tabButtonsRegistered = true
	}
}


void function DeregisterTabNavigationInput()
{
	if ( file.tabButtonsRegistered )
	{
		DeregisterButtonPressedCallback( BUTTON_SHOULDER_LEFT, OnMenuTab_NavLeft )
		DeregisterButtonPressedCallback( BUTTON_SHOULDER_RIGHT, OnMenuTab_NavRight )

		DeregisterButtonPressedCallback( BUTTON_TRIGGER_LEFT, OnNestedTab_NavLeftOnPressed )
		DeregisterButtonPressedCallback( BUTTON_TRIGGER_RIGHT, OnNestedTab_NavRightOnPressed )
		DeregisterButtonReleasedCallback( BUTTON_TRIGGER_LEFT, OnNestedTab_NavLeftOnReleased )
		DeregisterButtonReleasedCallback( BUTTON_TRIGGER_RIGHT, OnNestedTab_NavRightOnReleased )

		                                                                 
		                                                                     

		DeregisterButtonPressedCallback( BUTTON_Y, OnTab_ButtonY )
		DeregisterButtonPressedCallback( BUTTON_X, OnTab_ButtonX )

		file.tabButtonsRegistered = false
	}
}

void function OnTab_ButtonY( var unusedNull )
{
	if ( !_HasActiveTabPanel( GetActiveMenu() ) )
		return

	OnTab_InputHandler( _GetActiveTabPanel( GetActiveMenu() ), BUTTON_Y )
}

void function OnTab_ButtonX( var unusedNull )
{
	if ( !_HasActiveTabPanel( GetActiveMenu() ) )
		return

	OnTab_InputHandler( _GetActiveTabPanel( GetActiveMenu() ), BUTTON_X )
}

void function SetTabRightSound( var panel, string sound )
{
	GetTabDataForPanel( panel ).tabRightSound = sound
}


void function SetTabLeftSound( var panel, string sound )
{
	GetTabDataForPanel( panel ).tabLeftSound = sound
}


bool function IsTabBody( var panel )
{
	return panel in file.tabBodyDefMap
}


TabData function GetTabBodyParent( var panel )
{
	Assert( IsTabBody( panel ) )
	TabDef def = GetTabForTabBody( panel )
	return GetTabDataForPanel( def.parentPanel )
}