#if UI
global function TDM_PopulateAboutText
global function SWAT_PopulateAboutText
string function GetPlaylist()
{
	if ( IsLobby() )
		return Lobby_GetSelectedPlaylist()
	else
		return GetCurrentPlaylistName()

	unreachable
}

array< featureTutorialTab > function TDM_PopulateAboutText()
{
	array< featureTutorialTab > tabs
	featureTutorialTab tab1

	array< featureTutorialData > tab1Rules

	                                              
	tab1.tabName = 	"#GAMEMODE_RULES_OVERVIEW_TAB_NAME"
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#TDM_RULES_ABOUT_HEADER", "#TDM_RULES_ABOUT_BODY", $"rui/hud/gametype_icons/ltm/about_tdm_fight" ) )
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#TDM_RULES_ARMED_HEADER", "#TDM_RULES_ARMED_BODY", $"rui/hud/gametype_icons/ltm/about_tdm_armed" ) )
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#TDM_RULES_FROSTY_HEADER", "#TDM_RULES_FROSTY_BODY", $"rui/hud/gametype_icons/ltm/about_tdm_frosty" ) )

	tab1.rules = tab1Rules
	tabs.append( tab1 )

	return tabs
}

array< featureTutorialTab > function SWAT_PopulateAboutText()
{
	array< featureTutorialTab > tabs
	featureTutorialTab tab1

	array< featureTutorialData > tab1Rules

	                                              
	tab1.tabName = 	"#GAMEMODE_RULES_OVERVIEW_TAB_NAME"
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SWAT_RULES_ABOUT_HEADER", "#SWAT_RULES_ABOUT_BODY", $"rui/hud/gametype_icons/ltm/about_swat_safetyOff" ) )
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SWAT_RULES_AIM_HEADER", "#SWAT_RULES_AIM_BODY", $"rui/hud/gametype_icons/ltm/about_swat_aimHigh" ) )

	tab1.rules = tab1Rules
	tabs.append( tab1 )

	return tabs
}

#endif      