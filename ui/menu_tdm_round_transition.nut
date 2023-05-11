global function InitTDMRoundTransition
global function TDM_ShowScoreboard
global function TDM_HideScoreboard

                                                                               
struct
{
	var menu
	                
	var screenBlur
}
file

void function InitTDMRoundTransition( var newMenuArg )
{
	var menu = newMenuArg
	file.menu = menu
	                                                     
	file.screenBlur = Hud_GetRui(Hud_GetChild( file.menu, "ScreenBlur" ) )
}

void function TDM_ShowScoreboard_Internal()
{
	CloseAllMenus()
	AdvanceMenu( file.menu )
	                              
	RunClientScript("TDM_SetIsRoundTransition", true )
	RuiSetWallTimeWithNow( file.screenBlur, "animateStartTime" )
	                                                    
}

void function TDM_ShowScoreboard()
{
	thread TDM_ShowScoreboard_Internal()
}

void function TDM_HideScoreboard()
{
	                                                     
	RuiSetWallTimeBad( file.screenBlur, "animateStartTime" )

	thread function() : ()
	{
		EndSignal( uiGlobal.signalDummy, "LevelShutdown" )

		wait 10.0

		RunClientScript("TDM_SetIsRoundTransition", false )
	}()
}