#if UI
global function ShadowRoyale_PopulateAboutText

string function GetPlaylist()
{
	if ( IsLobby() )
		return Lobby_GetSelectedPlaylist()
	else
		return GetCurrentPlaylistName()

	unreachable
}

array< featureTutorialTab > function ShadowRoyale_PopulateAboutText()
{
	array< featureTutorialTab > tabs
	featureTutorialTab tab1
	array< featureTutorialData > tab1Rules

	                                              
	tab1.tabName = 	"#GAMEMODE_RULES_OVERVIEW_TAB_NAME"
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SHADOWROYALE_RULES_ABOUT_HEADER", "#SHADOWROYALE_RULES_ABOUT_BODY", $"rui/hud/gametype_icons/ltm/about_shadowroyale_fears" ) )
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SHADOWROYALE_RULES_SHADOW_HEADER", "#SHADOWROYALE_RULES_SHADOW_BODY", $"rui/hud/gametype_icons/ltm/about_shadowroyale_form" ) )
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#SHADOWROYALE_RULES_RESPAWN_HEADER", "#SHADOWROYALE_RULES_RESPAWN_BODY", $"rui/hud/gametype_icons/ltm/about_shadowroyale_swinging" ) )

	tab1.rules = tab1Rules
	tabs.append( tab1 )

	return tabs
}

#endif      