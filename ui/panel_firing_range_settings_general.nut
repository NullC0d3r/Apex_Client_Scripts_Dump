global function InitFiringRangeSettingsGeneralPanel

global function Firing_Range_SetIsRangeMaster
global function Firing_Range_SetRangeState
global function Firing_Range_SetFriendlyFire
global function Firing_Range_SetGeneralSetting
global function Firing_Range_SetDummieSetting

global function SettingsButton_SetShieldDescription

                   
global function Firing_Range_SetFullCombatDummies
global function Firing_Range_SetCombatRangeSetting
      

                                               
const float DEBOUNCEPERIOD_SELECTORSWITCHES = 0.25
const float DEBOUNCEPERIOD_RESETBUTTONS = 1.00

struct
{
	var panel
	var contentPanelParent
	var contentPanel

	var scrollBar
	var scrollFrame

	array< var > buttons = []

	string FRSettings
	string CRSettings

	table< int, var > generalSettingsToHud
	table< int, var > dummieBehaviorSettingsToHud

	table< int, float > generalSettings
	table< int, float > dummieBehaviorSettings
	
	                                                               
	table< int, bool > setting_DebounceLocked
	table< string, bool > resetButton_DebounceLocked
	
	table< int, float > lastInputTime_GeneralSettings
	table< string, float > lastInputTime_ResetButtons


	bool isRangeMaster = false
	int rangeState = eFiringRangeChallengeState.FR_CHALLENGE_INACTIVE

	bool friendlyFireOn = false

                    
		table< int, float > combatRangeSettings
		table< int, var > combatRangeSettingsToHud
		bool fullCombatDummiesOn = false
       

	bool isOpened = false
	bool autoUpdateIsOn = false
} file

void function InitFiringRangeSettingsGeneralPanel( var panel )
{
	file.panel = panel

	file.contentPanelParent = Hud_GetChild( panel, "ModeOptionsPanel" )
	file.contentPanel = Hud_GetChild( file.contentPanelParent, "ContentPanel" )
	file.scrollBar = Hud_GetChild( file.contentPanelParent, "ScrollBar" )
	file.scrollFrame = Hud_GetChild( file.contentPanelParent, "ScrollFrame" )

	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, OnFiringRangeSettingsGeneralPanel_Show )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, OnFiringRangeSettingsGeneralPanel_Hide )

	                                                                    
	var menu = GetMenu( "SurvivalInventoryMenu" )
	AddMenuEventHandler( menu, eUIEvent.MENU_PRECLOSE, CustomizeRangeMenu_Closed )

	SetupSettings()

	SettingsPanel_SetContentPanelHeight( file.contentPanel )
	ScrollPanel_InitPanel( file.contentPanelParent )
	ScrollPanel_InitScrollBar( file.contentPanelParent, file.scrollBar )

	AddPanelFooterOption( panel, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
	AddPanelFooterOption( panel, RIGHT, BUTTON_START, true, "#HINT_SYSTEM_MENU_GAMEPAD", "#HINT_SYSTEM_MENU_KB", TryOpenSystemMenu )

	#if DEV
		AddPanelFooterOption( panel, LEFT, BUTTON_STICK_LEFT, true, "#LEFT_STICK_DEV_MENU", "#DEV_MENU", OpenDevMenu )
	#endif
}

void function SetupSettings()
{
	                 
	for( int i = 0; i < eFRSettingType.COUNT_; i++ )
	{
		file.setting_DebounceLocked[ i ] <- false
	}

	file.generalSettingsToHud[ eFRSettingType.SHOWDYNSTATS ] <- Hud_GetChild( file.contentPanel, "SwitchDynamicStats" )
	file.generalSettingsToHud[ eFRSettingType.INFINITEMAGS ] <- Hud_GetChild( file.contentPanel, "SwitchInfiniteAmmo" )
	file.generalSettingsToHud[ eFRSettingType.SHOWHITMARKS ] <- Hud_GetChild( file.contentPanel, "SwitchHitIndicators" )
	file.generalSettingsToHud[ eFRSettingType.FRIENDLYFIRE ] <- Hud_GetChild( file.contentPanel, "SwitchFriendlyFire" )
	file.generalSettingsToHud[ eFRSettingType.TARGETSPEED ] <- Hud_GetChild( file.contentPanel, "SwitchTargetSpeed" )
	file.generalSettingsToHud[ eFRSettingType.FRDUMMIESHIELDLVL ] <- Hud_GetChild( file.contentPanel, "SwitchDummieShield" )
	file.generalSettingsToHud[ eFRSettingType.FRDUMMIESPEED ] <- Hud_GetChild( file.contentPanel, "SwitchDummieSpeed" )
	file.generalSettingsToHud[ eFRSettingType.FRDUMMIEMOVEMENT ] <- Hud_GetChild( file.contentPanel, "SwitchDummieMovement" )
	file.generalSettingsToHud[ eFRSettingType.FRDUMMIESTANCE ] <- Hud_GetChild( file.contentPanel, "SwitchDummieStance" )

                   
	file.generalSettingsToHud[ eFRSettingType.FRDUMMIESHOOTING ] <- Hud_GetChild( file.contentPanel, "SwitchDummieShooting" )
	file.generalSettingsToHud[ eFRSettingType.FRDUMMIESPAWNDISTS ] <- Hud_GetChild( file.contentPanel, "SwitchDummieSpawnDists" )
	file.generalSettingsToHud[ eFRSettingType.DYNAMICDUMMIESON ] <- Hud_GetChild( file.contentPanel, "SwitchDynDummieSpawn" )

                         

	          
	SetupSettingsButton( file.generalSettingsToHud[ eFRSettingType.SHOWDYNSTATS ], "#FRSETTING_SHOWDYNSTATS", "#FRSETTING_SHOWDYNSTATS_DESC", $"", false, false )
	AddButtonEventHandler( file.generalSettingsToHud[ eFRSettingType.SHOWDYNSTATS ], UIE_CHANGE, void function( var btn ){ Firing_Range_GeneralSettingChanged( eFRSettingType.SHOWDYNSTATS, btn ) } )

	SetupSettingsButton( file.generalSettingsToHud[ eFRSettingType.INFINITEMAGS ], "#FRSETTING_INFINITEMAGS", "#FRSETTING_INFINITEMAGS_DESC", $"", false, false )
	AddButtonEventHandler( file.generalSettingsToHud[ eFRSettingType.INFINITEMAGS ], UIE_CHANGE, void function( var btn ){ Firing_Range_GeneralSettingChanged( eFRSettingType.INFINITEMAGS, btn ) } )

	SetupSettingsButton( file.generalSettingsToHud[ eFRSettingType.SHOWHITMARKS ], "#FRSETTING_SHOWHITMARKS", "#FRSETTING_SHOWHITMARKS_DESC", $"", false, false )
	AddButtonEventHandler( file.generalSettingsToHud[ eFRSettingType.SHOWHITMARKS ], UIE_CHANGE, void function( var btn ){ Firing_Range_GeneralSettingChanged( eFRSettingType.SHOWHITMARKS, btn ) } )

	         
	SetupSettingsButton( file.generalSettingsToHud[ eFRSettingType.FRIENDLYFIRE ], "#HUD_FRSETTING_FRIENDLYFIRE", "#HUD_FRSETTING_FRIENDLYFIRE_DESC", $"", false, true )
	AddButtonEventHandler( file.generalSettingsToHud[ eFRSettingType.FRIENDLYFIRE ], UIE_CHANGE, void function( var btn ){ Firing_Range_GeneralSettingChanged( eFRSettingType.FRIENDLYFIRE, btn ) } )

	SetupSettingsButton( file.generalSettingsToHud[ eFRSettingType.TARGETSPEED ], "#FRSETTING_TARGETSPEED", "#FRSETTING_TARGETSPEED_DESC", $"", false, true  )
	AddButtonEventHandler( file.generalSettingsToHud[ eFRSettingType.TARGETSPEED ], UIE_CHANGE, void function( var btn ){ Firing_Range_GeneralSettingChanged( eFRSettingType.TARGETSPEED, btn ) } )

	                 

	SetupSettingsButton( file.generalSettingsToHud[ eFRSettingType.FRDUMMIESHIELDLVL ], "#FRSETTING_DUMMIESHIELD", "#FRSETTING_DUMMIESHIELD_DESC_UI", $"", false, true )
	AddButtonEventHandler( file.generalSettingsToHud[ eFRSettingType.FRDUMMIESHIELDLVL ], UIE_CHANGE, void function( var btn ){ Firing_Range_GeneralSettingChanged( eFRSettingType.FRDUMMIESHIELDLVL, btn ) } )

	SetupSettingsButton( file.generalSettingsToHud[ eFRSettingType.FRDUMMIESPEED ], "#FRSETTING_DUMMIESTRAFESPEED", "#FRSETTING_DUMMIESTRAFESPEED_DESC", $"", false, true  )
	AddButtonEventHandler( file.generalSettingsToHud[ eFRSettingType.FRDUMMIESPEED ], UIE_CHANGE, void function( var btn ){ Firing_Range_GeneralSettingChanged( eFRSettingType.FRDUMMIESPEED, btn ) } )

	SetupSettingsButton( file.generalSettingsToHud[ eFRSettingType.FRDUMMIEMOVEMENT ], "#FRSETTING_DUMMIEMOVEMENT", "#FRSETTING_DUMMIEMOVEMENT_DESC", $"", false, true  )
	AddButtonEventHandler( file.generalSettingsToHud[ eFRSettingType.FRDUMMIEMOVEMENT ], UIE_CHANGE, void function( var btn ){ Firing_Range_GeneralSettingChanged( eFRSettingType.FRDUMMIEMOVEMENT, btn ) } )

	SetupSettingsButton( file.generalSettingsToHud[ eFRSettingType.FRDUMMIESTANCE ], "#FRSETTING_DUMMIESTATE", "#FRSETTING_DUMMIESTATE_DESC", $"", false, true  )
	AddButtonEventHandler( file.generalSettingsToHud[ eFRSettingType.FRDUMMIESTANCE ], UIE_CHANGE, void function( var btn ){ Firing_Range_GeneralSettingChanged( eFRSettingType.FRDUMMIESTANCE, btn ) } )

                   
	SetupSettingsButton( file.generalSettingsToHud[ eFRSettingType.FRDUMMIESHOOTING ], "#FRSETTING_DUMMIESHOOTING", "#FRSETTING_DUMMIESHOOTING_DESC", $"", false, true  )
	AddButtonEventHandler( file.generalSettingsToHud[ eFRSettingType.FRDUMMIESHOOTING ], UIE_CHANGE, void function( var btn ){ Firing_Range_GeneralSettingChanged( eFRSettingType.FRDUMMIESHOOTING , btn ) } )

	SetupSettingsButton( file.generalSettingsToHud[ eFRSettingType.FRDUMMIESPAWNDISTS ], "#FRSETTING_DUMMIESPAWNDISTS", "#FRSETTING_DUMMIESPAWNDISTS_DESC", $"", false, true  )
	AddButtonEventHandler( file.generalSettingsToHud[ eFRSettingType.FRDUMMIESPAWNDISTS ], UIE_CHANGE, void function( var btn ){ Firing_Range_GeneralSettingChanged( eFRSettingType.FRDUMMIESPAWNDISTS , btn ) } )

	SetupSettingsButton( file.generalSettingsToHud[ eFRSettingType.DYNAMICDUMMIESON ], "#DYNDUMMIE_DYNSPAWN_LABEL", "#DYNDUMMIE_DYNSPAWN_DESC", $"", false, true  )
	AddButtonEventHandler( file.generalSettingsToHud[ eFRSettingType.DYNAMICDUMMIESON ], UIE_CHANGE, void function( var btn ){ Firing_Range_GeneralSettingChanged( eFRSettingType.DYNAMICDUMMIESON, btn ) } )

	                      

	file.resetButton_DebounceLocked[ "SwitchCombatRefreshDummies" ] <- false
	file.resetButton_DebounceLocked[ "SwitchCombatClearAndSpawnNewDummies" ] <- false

	FiringRangeOption option

	option = CreateFiringRangeOption( "#DYNDUMMIE_FUNC_REFRESH_LABEL", "#DYNDUMMIE_FUNC_REFRESH_DESC", CRng_RefreshDummies )
	SetUpOptionsButton( Hud_GetChild( file.contentPanel, "SwitchCombatRefreshDummies" ), option )

	option = CreateFiringRangeOption( "#DYNDUMMIE_FUNC_SPAWNNEW_LABEL", "#DYNDUMMIE_FUNC_SPAWNNEW_DESC", CRng_ClearAndSpawnNewDummies )
	SetUpOptionsButton( Hud_GetChild( file.contentPanel, "SwitchCombatClearAndSpawnNewDummies" ), option )

                      
                                                                
                                                                                                    
                                                                                     
                            
                         
}

void function OnFiringRangeSettingsGeneralPanel_Show( var panel )
{
	                               
	         
	  	                                                
	               

	CustomizeRangeMenu_Opened()

	if( !file.autoUpdateIsOn )
	{
		thread AutoUpdateDetails_Thread()
		file.autoUpdateIsOn = true
	}

	RunClientScript( "FRSettings_Client_Update" )

	ScrollPanel_SetActive( file.contentPanelParent, true )

	SettingsPanel_SetContentPanelHeight( file.contentPanel )
	ScrollPanel_Refresh( file.contentPanelParent )
}

void function OnFiringRangeSettingsGeneralPanel_Hide( var panel )
{
	                               
	         
	  	                                                
	               

	ScrollPanel_SetActive( file.contentPanelParent, false )
	CustomizeRangeMenu_Closed()
}

void function CustomizeRangeMenu_Opened()
{
	                               
	         
	  	                                                  
	               
	file.isOpened = true

	if( IsConnected() && GetCurrentPlaylistVarBool( "has_dummies_dontshoot_when_menuopen", false ))
	{
		Remote_ServerCallFunction( "UCB_CustomizeRangeMenu_TrackState", true )
	}
}

void function CustomizeRangeMenu_Closed()
{
	                               
	         
	  	                                                  
	               
	file.isOpened = false
	if( IsConnected() && GetCurrentPlaylistVarBool( "has_dummies_dontshoot_when_menuopen", false ))
	{
		Remote_ServerCallFunction( "UCB_CustomizeRangeMenu_TrackState", false )

		Remote_ServerCallFunction( "PIN_Record_CustomizeRangeSettings_ForMenuClose" )
	}
}

                                                            
void function AutoUpdateDetails_Thread()
{
	while( true )
	{
		if( file.isOpened )
		{
			UpdateDetails()
		}
		wait( DEBOUNCEPERIOD_SELECTORSWITCHES )
	}
}

void function UpdateDetails()
{
	                    
	Hud_SetEnabled( file.generalSettingsToHud[ eFRSettingType.SHOWDYNSTATS ], !file.setting_DebounceLocked[ eFRSettingType.SHOWDYNSTATS ] && file.rangeState == eFiringRangeChallengeState.FR_CHALLENGE_INACTIVE)
	Hud_SetEnabled( file.generalSettingsToHud[ eFRSettingType.INFINITEMAGS ], !file.setting_DebounceLocked[ eFRSettingType.INFINITEMAGS ] )
	Hud_SetEnabled( file.generalSettingsToHud[ eFRSettingType.SHOWHITMARKS ], !file.setting_DebounceLocked[ eFRSettingType.SHOWHITMARKS ] )

	int partySize = GetTeamSize( GetTeam() )
	bool isAlone = partySize < 2
	if( isAlone )
	{
		Hud_SetDialogListSelectionValue( file.generalSettingsToHud[ eFRSettingType.FRIENDLYFIRE ], string( false ))
	}

	Hud_SetEnabled( file.generalSettingsToHud[ eFRSettingType.FRIENDLYFIRE ], 		file.isRangeMaster && !isAlone && !file.setting_DebounceLocked[ eFRSettingType.FRIENDLYFIRE ])
	Hud_SetEnabled( file.generalSettingsToHud[ eFRSettingType.TARGETSPEED ], 		file.isRangeMaster && !file.setting_DebounceLocked[ eFRSettingType.TARGETSPEED ])
	Hud_SetEnabled( file.generalSettingsToHud[ eFRSettingType.FRDUMMIESHIELDLVL ], 	file.isRangeMaster && !file.setting_DebounceLocked[ eFRSettingType.FRDUMMIESHIELDLVL ])

	                                                                    
	bool fcOn
                   
	                                                                                                                          
	fcOn = int( Hud_GetDialogListSelectionValue( file.generalSettingsToHud[ eFRSettingType.FRDUMMIESHOOTING ] ) ) == eDummie_Selector_Shooting.FULLCOMBAT
     
             
      

	Hud_SetEnabled( file.generalSettingsToHud[ eFRSettingType.FRDUMMIESPEED ], 		file.isRangeMaster && !fcOn && !file.setting_DebounceLocked[ eFRSettingType.FRDUMMIESPEED ])
	Hud_SetEnabled( file.generalSettingsToHud[ eFRSettingType.FRDUMMIEMOVEMENT ], 	file.isRangeMaster && !fcOn && !file.setting_DebounceLocked[ eFRSettingType.FRDUMMIEMOVEMENT ])
	Hud_SetEnabled( file.generalSettingsToHud[ eFRSettingType.FRDUMMIESTANCE ], 	file.isRangeMaster && !fcOn && !file.setting_DebounceLocked[ eFRSettingType.FRDUMMIESTANCE ])

                   
	Hud_SetEnabled( file.generalSettingsToHud[ eFRSettingType.FRDUMMIESHOOTING ], 	file.isRangeMaster && !file.setting_DebounceLocked[ eFRSettingType.FRDUMMIESHOOTING ])
	Hud_SetEnabled( file.generalSettingsToHud[ eFRSettingType.FRDUMMIESPAWNDISTS ], file.isRangeMaster && !file.setting_DebounceLocked[ eFRSettingType.FRDUMMIESPAWNDISTS ])
	Hud_SetEnabled( file.generalSettingsToHud[ eFRSettingType.DYNAMICDUMMIESON ], 	file.isRangeMaster && !file.setting_DebounceLocked[ eFRSettingType.DYNAMICDUMMIESON ])

	                                                                                                            
	bool spawningOn = int( Hud_GetDialogListSelectionValue( file.generalSettingsToHud[ eFRSettingType.DYNAMICDUMMIESON ] ) ) == 1
	Hud_SetEnabled( Hud_GetChild( file.contentPanel, "SwitchCombatRefreshDummies" ), 			file.isRangeMaster && spawningOn && !file.resetButton_DebounceLocked[ "SwitchCombatRefreshDummies" ])
	Hud_SetEnabled( Hud_GetChild( file.contentPanel, "SwitchCombatClearAndSpawnNewDummies" ), 	file.isRangeMaster && spawningOn && !file.resetButton_DebounceLocked[ "SwitchCombatClearAndSpawnNewDummies" ])

                      
                                                                                                                                                      
                            
                         
}

void function Firing_Range_SetIsRangeMaster( bool value )
{
	file.isRangeMaster = value

	UpdateDetails()
}

void function Firing_Range_SetRangeState( int value )
{
	file.rangeState = value

	UpdateDetails()
}

void function Firing_Range_SetFriendlyFire( bool value )
{
	file.friendlyFireOn = value
	UpdateDetails()
}

void function Firing_Range_SetGeneralSetting( int setting, float value )
{
	if( setting in file.generalSettings && file.generalSettings[ setting ] == value )
		return

	if( setting in file.generalSettingsToHud )
	{
		                                                                                                                                          
		                                                                 
		   
		  	                                                                                        
		   
		                                                                                                                        
		   
		  	                                                                                        
		   
		Hud_SetDialogListSelectionValue( file.generalSettingsToHud[ setting ], string( value ) )
	}

	file.generalSettings[ setting ] <- value
	UpdateDetails()
}

void function Firing_Range_SetDummieSetting( int setting, float value )
{
	if( setting in file.dummieBehaviorSettings && file.dummieBehaviorSettings[ setting ] == value )
		return

	if( setting in file.dummieBehaviorSettingsToHud )
	{
		if( file.isRangeMaster && !( setting in file.dummieBehaviorSettings ))
		{
			Hud_SetDialogListSelectionValue( file.dummieBehaviorSettingsToHud[ setting ], string( value ) )
		}
		else if( !file.isRangeMaster && ( !( setting in file.dummieBehaviorSettings ) || value != file.dummieBehaviorSettings[ setting ] ) )
		{
			Hud_SetDialogListSelectionValue( file.dummieBehaviorSettingsToHud[ setting ], string( value ) )
		}
	}

	file.dummieBehaviorSettings[ setting ] <- value
	UpdateDetails()
}

                   

void function Firing_Range_SetFullCombatDummies( bool value )
{
	file.fullCombatDummiesOn = value
	UpdateDetails()
}

void function Firing_Range_SetCombatRangeSetting( int setting, float value )
{
	if( setting in file.combatRangeSettings && file.combatRangeSettings[ setting ] == value )
		return

	if( setting in file.combatRangeSettingsToHud )
	{
		if( file.isRangeMaster && !( setting in file.combatRangeSettings ))
		{
			Hud_SetDialogListSelectionValue( file.combatRangeSettingsToHud[ setting ], string( value ) )
		}
		else if( !file.isRangeMaster && ( !( setting in file.combatRangeSettings ) || value != file.combatRangeSettings[ setting ] ) )
		{
			Hud_SetDialogListSelectionValue( file.combatRangeSettingsToHud[ setting ], string( value ) )
		}
	}

	file.combatRangeSettings[ setting ] <- value
	UpdateDetails()
}

                                

void function CRng_RefreshDummies( var _ )
{
	string ctrlName = "SwitchCombatRefreshDummies"
	Remote_ServerCallFunction( "UICallback_RespawnDummiesInPlace" )
	thread DebounceLock_ResetButton_Thread( ctrlName )
}

void function CRng_ClearAndSpawnNewDummies( var _ )
{
	string ctrlName = "SwitchCombatClearAndSpawnNewDummies"
	Remote_ServerCallFunction( "UICallback_ClearAndSpawnNewDummies" )
	thread DebounceLock_ResetButton_Thread( ctrlName )
}

                     
                                      
 
                                     
                                              
                                                   
 
                           

void function DebounceLock_ResetButton_Thread( string resetName )
{
	file.resetButton_DebounceLocked[ resetName ] <- true
	wait( DEBOUNCEPERIOD_RESETBUTTONS )
	file.resetButton_DebounceLocked[ resetName ] <- false
}

                         

void function Firing_Range_GeneralSettingChanged( int setting, var btn )
{
	if( !file.isOpened )
		return

	int index = Hud_GetDialogListSelectionIndex( btn )
	int indexValue = int( Hud_GetDialogListSelectionValue( btn ) )
	bool boolValue = bool( index )

	switch( setting )
	{
		case eFRSettingType.SHOWDYNSTATS:
			file.generalSettings[ setting ] <- float( boolValue )
			Remote_ServerCallFunction( "UCB_SV_FRSetting_DynStats", boolValue )
			break
		case eFRSettingType.INFINITEMAGS:
			file.generalSettings[ setting ] <- float( boolValue )
			Remote_ServerCallFunction( "UCB_SV_FRSetting_InfiniteReloads", boolValue )
			break
		case eFRSettingType.SHOWHITMARKS:
			file.generalSettings[ setting ] <- float( boolValue )
			Remote_ServerCallFunction( "UCB_SV_FRSetting_HitMarks", boolValue )
			break
		default:
			break
	}

	                                       
	if( !file.isRangeMaster )
		return

	int selectionSwitchID = -1
	switch( setting )
	{
		case eFRSettingType.FRIENDLYFIRE:
			file.generalSettings[ setting ] <- float( boolValue )
			Remote_ServerCallFunction( "UCB_SV_FRSetting_FriendlyFire", boolValue, true )
			break
		case eFRSettingType.TARGETSPEED:
			file.generalSettings[ setting ] <- float( indexValue )
			                                                                                
			Remote_ServerCallFunction( "UCB_SV_FRSetting_Change_Int", eFRSettingType.TARGETSPEED, indexValue )
			selectionSwitchID = setting
			break
		case eFRSettingType.FRDUMMIESPEED:
			file.generalSettings[ setting ] <- float( indexValue )
			Remote_ServerCallFunction( "UCB_SV_FRSetting_Change_Int", eFRSettingType.FRDUMMIESPEED, indexValue )
			selectionSwitchID = setting
			break
		case eFRSettingType.FRDUMMIEMOVEMENT:
			file.generalSettings[ setting ] <- float( indexValue )
			Remote_ServerCallFunction( "UCB_SV_FRSetting_Change_Int", eFRSettingType.FRDUMMIEMOVEMENT, indexValue )
			selectionSwitchID = setting
			break
		case eFRSettingType.FRDUMMIESTANCE:
			file.generalSettings[ setting ] <- float( indexValue )
			Remote_ServerCallFunction( "UCB_SV_FRSetting_Change_Int", eFRSettingType.FRDUMMIESTANCE, indexValue )
			selectionSwitchID = setting
			break
		case eFRSettingType.FRDUMMIESHIELDLVL:
			file.generalSettings[ setting ] <- float( indexValue )
			Remote_ServerCallFunction( "UCB_SV_FRSetting_Change_Int", eFRSettingType.FRDUMMIESHIELDLVL, indexValue )
			selectionSwitchID = setting
			break
                    
		case eFRSettingType.FRDUMMIESHOOTING :
			file.generalSettings[ setting ] <- float( indexValue )
			Remote_ServerCallFunction( "UCB_SV_FRSetting_Change_Int", eFRSettingType.FRDUMMIESHOOTING, indexValue )
			selectionSwitchID = setting
			break
		case eFRSettingType.FRDUMMIESPAWNDISTS :
			file.generalSettings[ setting ] <- float( indexValue )
			Remote_ServerCallFunction( "UCB_SV_FRSetting_Change_Int", eFRSettingType.FRDUMMIESPAWNDISTS, indexValue )
			selectionSwitchID = setting
			break
		case eFRSettingType.DYNAMICDUMMIESON :
			file.generalSettings[ setting ] <- float( boolValue )
			Remote_ServerCallFunction( "UCB_SV_FRsetting_DynamicDummiesOn_Changed", boolValue, true )
			break
                          
		default:
			break
	}

	                                                                                                        
	thread DebounceLock_GeneralSetting_Thread( setting )

	UpdateDetails()
}

void function DebounceLock_GeneralSetting_Thread( int setting )
{
	file.setting_DebounceLocked[ setting ] <- true
	wait( DEBOUNCEPERIOD_SELECTORSWITCHES )
	file.setting_DebounceLocked[ setting ] <- false
}

                                      
void function SetUpOptionsButton( var button, FiringRangeOption option )
{
	HudElem_SetRuiArg( button, "buttonText", option.name )

	if( !file.buttons.contains( button ) )
	{
		                                                                     
		AddButtonEventHandler( button, UIE_CLICK,             
			void function( var button ) : ( option )
			{
				if(option.onChangeCallback != null )
					option.onChangeCallback( button )
			} )
	}

	ToolTipData toolTipData
	toolTipData.titleText = option.name
	toolTipData.descText = option.description
	Hud_SetToolTipData( button, toolTipData )

	file.buttons.append( button )
}

void function SettingsButton_SetShieldDescription ( string descText )
{
	SettingsButton_SetDescription( file.generalSettingsToHud[ eFRSettingType.FRDUMMIESHIELDLVL ], descText )
}

void function TryOpenSystemMenu( var panel )
{
	if ( InputIsButtonDown( BUTTON_START ) )
		return

	OpenSystemMenu()
}
