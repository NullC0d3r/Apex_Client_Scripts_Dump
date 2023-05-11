#if UI
global function Survival_Heatwave_PopulateAboutText

string function GetPlaylist()
{
	if ( IsLobby() )
		return Lobby_GetSelectedPlaylist()
	else
		return GetCurrentPlaylistName()

	unreachable
}

array< featureTutorialTab > function Survival_Heatwave_PopulateAboutText()
{
	array< featureTutorialTab > tabs
	featureTutorialTab tab1
	array< featureTutorialData > tab1Rules

	                                              
	tab1.tabName = 	"#SURVIVAL_HEATVWAVE_HCTS_TAB_NAME"

	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SURVIVAL_HEATVWAVE_1_HEADER", "#SURVIVAL_HEATVWAVE_1_BODY", $"rui/hud/gametype_icons/ltm/about_heatwave_heatwaves" ) )
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SURVIVAL_HEATVWAVE_2_HEADER", "#SURVIVAL_HEATVWAVE_2_BODY", $"rui/hud/gametype_icons/ltm/about_heatwave_indoor" ) )
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SURVIVAL_HEATVWAVE_3_HEADER", "#SURVIVAL_HEATVWAVE_3_BODY", $"rui/hud/gametype_icons/ltm/about_heatwave_sunglasses" ) )

	tab1.rules = tab1Rules
	tabs.append( tab1 )

	return tabs
}

#endif      