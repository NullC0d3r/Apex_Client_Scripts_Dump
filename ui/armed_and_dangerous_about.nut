#if UI
global function Armed_And_Dangerous_PopulateAboutText

string function GetPlaylist()
{
	if ( IsLobby() )
		return Lobby_GetSelectedPlaylist()
	else
		return GetCurrentPlaylistName()

	unreachable
}

array< featureTutorialTab > function Armed_And_Dangerous_PopulateAboutText()
{
	array< featureTutorialTab > tabs
	featureTutorialTab tab1
	array< featureTutorialData > tab1Rules

	                                              
	tab1.tabName = 	"#ABOUT_GAMEMODE"

	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#ARMED_AND_DANGEROUS_1_HEADER", "#ARMED_AND_DANGEROUS_1_BODY", $"rui/hud/gametype_icons/ltm/about_heatwave_heatwaves" ) )
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#ARMED_AND_DANGEROUS_2_HEADER", "#ARMED_AND_DANGEROUS_2_BODY", $"rui/hud/gametype_icons/ltm/about_heatwave_indoor" ) )

	tab1.rules = tab1Rules
	tabs.append( tab1 )

	return tabs
}

#endif      