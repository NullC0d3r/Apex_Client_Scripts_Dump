global function InitPostGameMenu
global function IsPostGameMenuValid
global function PopulateMatchRank
global function OpenPostGameMenu
global function ClosePostGameMenu
global function PostGame_ToggleVisibilityContinueButton
global function PostGameGeneral_OnContinue_Activate

                                 
global function PostGame_EnableWeaponsTab
      

const POSTGAME_DATA_EXPIRATION_TIME = 30 * SECONDS_PER_MINUTE

struct
{
	var menu
	var matchRank
	var continueButton
	bool callbacksRegistered = false
} file

table<string,bool> gameModeIsHeadToHead = {
	survival = false,

                        
                
       

                         
		control = true,
                               
}

void function InitPostGameMenu( var newMenuArg )
{
	RegisterSignal( "PGDisplay" )

	file.menu = GetMenu( "PostGameMenu" )
	file.matchRank = Hud_GetRui( Hud_GetChild( file.menu, "MatchRank" ) )
	file.continueButton = Hud_GetChild( file.menu, "ContinueButton" )

	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnOpenPostGameMenu )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_SHOW, OnShowPostGameMenu )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_HIDE, OnHidePostGameMenu )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_CLOSE, OnClosePostGameMenu )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_NAVIGATE_BACK, OnNavigateBack )

	Hud_AddEventHandler( file.continueButton, UIE_CLICK, PostGameGeneral_OnContinue_Activate )
	{
		TabDef tabDef = AddTab( file.menu, Hud_GetChild( file.menu, "PostGameGeneral" ), "#MENU_GENERAL" )
		SetTabBaseWidth( tabDef, 250 )
	}
                                 
	{
		TabDef tabDef = AddTab( file.menu, Hud_GetChild( file.menu, "PostGameWeapons" ), "#MENU_WEAPONS" )
		SetTabBaseWidth( tabDef, 250 )
	}
      
	TabData tabData = GetTabDataForPanel( file.menu )

	tabData.centerTabs = true
	tabData.bannerHeader = ""
	tabData.bannerTitle = "#MATCH_SUMMARY"
	tabData.callToActionWidth = 700

	SetTabBackground( tabData, Hud_GetChild( file.menu, "TabsBackground" ), eTabBackground.STANDARD )

}

void function OnOpenPostGameMenu()
{
	if ( !IsFullyConnected() )
	{
		CloseActiveMenu()
		return
	}

	TabData tabData = GetTabDataForPanel( file.menu )

                                  
		bool enableWeaponMastery =  Mastery_IsEnabled()
		TabDef seasonTabDef = Tab_GetTabDefByBodyName( tabData, "PostGameWeapons" )

		seasonTabDef.visible = enableWeaponMastery
		seasonTabDef.enabled = enableWeaponMastery
       

	if ( GetLastMenuNavDirection() == MENU_NAV_FORWARD )
	{
		ActivateTab( tabData, 0 )
	}

	                  
	                  
	                  

	PopulateMatchRank( file.matchRank )
	Lobby_AdjustScreenFrameToMaxSize( Hud_GetChild( file.menu, "ScreenFrame" ), true )
}

                                 
void function PostGame_EnableWeaponsTab( bool enabled )
{
	TabData tabData = GetTabDataForPanel( file.menu )
	bool enableWeaponMastery =  Mastery_IsEnabled()
	TabDef seasonTabDef = Tab_GetTabDefByBodyName( tabData, "PostGameWeapons" )

	seasonTabDef.enabled = enabled

	UpdateMenuTabs()
}
      

void function OnShowPostGameMenu()
{
	if( !file.callbacksRegistered )
	{
		RegisterButtonPressedCallback( BUTTON_A, PostGameGeneral_OnContinue_Activate )
		RegisterButtonPressedCallback( KEY_SPACE, PostGameGeneral_OnContinue_Activate )
		file.callbacksRegistered = true
	}

                         
		UI_SetPresentationType( ePresentationType.WEAPON_CATEGORY )
      
                                   
   
                                                                
                                                            
                                                       
   
      
   
                                                              
                                                       
   
       

	#if DEV
		AddMenuThinkFunc( file.menu, PostGameMenuAutomationThink )
	#endif       
}

#if DEV
void function PostGameMenuAutomationThink( var menu )
{
	if (AutomateUi())
	{
		printt("PostGameMenuAutomationThink OnContinue_Activate()")
		PostGameGeneral_OnContinue_Activate(null)
	}
}
#endif       


void function PostGameGeneral_OnContinue_Activate( var button )
{
	var focusElement = GetFocus()

	if( focusElement != null )
	{
		var parentElement = Hud_GetParent( focusElement )

		if( Hud_GetHudName(parentElement) == "TabsCommon")
			return
	}

	PostGameGeneral_SetSkippableWait( true )

	if ( PostGameGeneral_CanNavigateBack() )
		CloseActiveMenu()
}

void function OnHidePostGameMenu()
{
	if( file.callbacksRegistered )
	{
		DeregisterButtonPressedCallback( BUTTON_A, PostGameGeneral_OnContinue_Activate )
		DeregisterButtonPressedCallback( KEY_SPACE, PostGameGeneral_OnContinue_Activate )
		file.callbacksRegistered = false
	}

	Signal( uiGlobal.signalDummy, "PGDisplay" )
}

void function OnClosePostGameMenu()
{
	Remote_ServerCallFunction( "ClientCallback_ViewedGameSummary" )
}

void function OnNavigateBack()
{
	PostGameGeneral_SetSkippableWait( true )

	if ( !PostGameGeneral_CanNavigateBack() )
		return

	ClosePostGameMenu( null )
}

bool function IsPostGameMenuValid( bool checkTime = false )
{
	if ( IsPrivateMatchLobby() )
		return false

	if ( checkTime && GetUnixTimestamp() - GetPersistentVarAsInt( "lastGameTime" ) > POSTGAME_DATA_EXPIRATION_TIME )
		return false

	if ( !IsPersistenceAvailable() )
		return false

	if ( GetPersistentVarAsInt( "lastGamePlayers" ) == 0 && GetPersistentVarAsInt( "lastGameSquads" ) == 0 )
		return false

	return true
}

void function OpenPostGameMenu( var button )
{
	Assert( IsPostGameMenuValid() )

	AdvanceMenu( file.menu )
}

void function ClosePostGameMenu( var button )
{
	printf( "postgame::ClosePostGameMenu" )
	if ( GetActiveMenu() == file.menu )
		CloseActiveMenu()
}

void function PopulateMatchRank( var matchRankRui )
{
	RuiSetInt( matchRankRui, "squadRank", GetPersistentVarAsInt( "lastGameRank" ) )
	RuiSetInt( matchRankRui, "totalPlayers", GetPersistentVarAsInt( "lastGameSquads" ) )
	int elapsedTime = GetUnixTimestamp() - GetPersistentVarAsInt( "lastGameTime" )
	RuiSetString( matchRankRui, "lastPlayedText", Localize( "#EOG_LAST_PLAYED", GetFormattedIntByType( elapsedTime, eNumericDisplayType.TIME_MINUTES_LONG ) ) )

	string lastGameMode = expect string( GetPersistentVar( "lastGameMode" ) )
	bool displayVictory = false
	if ( lastGameMode in gameModeIsHeadToHead )
	{
		displayVictory = gameModeIsHeadToHead[ lastGameMode ]
	}
	RuiSetBool( matchRankRui, "displayVictory", displayVictory )
}

void function PostGame_ToggleVisibilityContinueButton( bool isVisible )
{
	Hud_SetVisible( file.continueButton, isVisible )
}