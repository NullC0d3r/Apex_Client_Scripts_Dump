#if UI
global function Survival_Hardcore_PopulateAboutText

string function GetPlaylist()
{
	if ( IsLobby() )
		return Lobby_GetSelectedPlaylist()
	else
		return GetCurrentPlaylistName()

	unreachable
}

array< featureTutorialTab > function Survival_Hardcore_PopulateAboutText()
{
	array< featureTutorialTab > tabs
	featureTutorialTab tab1
	featureTutorialTab tab2
	array< featureTutorialData > tab1Rules

	                                              
	tab1.tabName = 	"#GAMEMODE_RULES_OVERVIEW_TAB_NAME"

	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SURVIVAL_HARDCORE_ABOUT_HEADER", "#SURVIVAL_HARDCORE_ABOUT_BODY", $"rui/hud/gametype_icons/ltm/about_hardcore_stay_frosty" ) )
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SURVIVAL_HARDCORE_SHIELDS_HEADER", "#SURVIVAL_HARDCORE_SHIELDS_BODY", $"rui/hud/gametype_icons/ltm/about_hardcore_blink" ) )
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SURVIVAL_HARDCORE_RING_HEADER", "#SURVIVAL_HARDCORE_RING_BODY", $"rui/hud/gametype_icons/ltm/about_hardcore_move" ) )

	tab1.rules = tab1Rules
	tabs.append( tab1 )

	array< featureTutorialData > tab2Rules

	                 
	tab2.tabName = 	"#SURVIVAL_HARDCORE_TIPS_TAB_NAME"

	tab2Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SURVIVAL_HARDCORE_AMMO_HEADER", "#SURVIVAL_HARDCORE_AMMO_BODY", $"rui/hud/gametype_icons/ltm/about_hardcore_mags" ) )
	tab2Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SURVIVAL_HARDCORE_BEACON_HEADER", "#SURVIVAL_HARDCORE_BEACON_BODY", $"rui/hud/gametype_icons/ltm/about_hardcore_scan_squads" ) )
	tab2Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SURVIVAL_HARDCORE_COMMS_HEADER", "#SURVIVAL_HARDCORE_COMMS_BODY", $"rui/hud/gametype_icons/ltm/about_hardcore_scan_communicate" ) )

	tab2.rules = tab2Rules
	tabs.append( tab2 )

	return tabs
}

#endif      