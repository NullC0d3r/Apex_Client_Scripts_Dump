#if UI
global function CombatRange_PopulateAboutText

string function GetPlaylist()
{
	if ( IsLobby() )
		return Lobby_GetSelectedPlaylist()
	else
		return GetCurrentPlaylistName()

	unreachable
}

array< featureTutorialTab > function CombatRange_PopulateAboutText()
{
	array< featureTutorialTab > tabs
	featureTutorialTab tab1
	featureTutorialTab tab2
	array< featureTutorialData > tab1Rules

	                                              
	tab1.tabName = 	"#COMBATRANGE_FEATURES_TABNAME"

	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#COMBATRANGE_CUSTOMIZE_HEADER", 	"#COMBATRANGE_CUSTOMIZE_BODY", 		$"rui/hud/gametype_icons/firingrange/about_combatrange_customize" ) )
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#COMBATRANGE_DUMMIES_HEADER", 		"#COMBATRANGE_DUMMIES_BODY", 		$"rui/hud/gametype_icons/firingrange/about_combatrange_dummies" ) )
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#COMBATRANGE_DYNAMICSTATS_HEADER", 	"#COMBATRANGE_DYNAMICSTATS_BODY", 	$"rui/hud/gametype_icons/firingrange/about_combatrange_dynamicstats" ) )

	tab1.rules = tab1Rules
	tabs.append( tab1 )

	array< featureTutorialData > tab2Rules

	                 
	tab2.tabName = 	"#COMBATRANGE_AREAS_TABNAME"

	tab2Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#COMBATRANGE_DUELZONE_HEADER", 		"#COMBATRANGE_DUELZONE_BODY", 		$"rui/hud/gametype_icons/firingrange/about_combatrange_duelingpit" ) )
	tab2Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#COMBATRANGE_COMBATZONE_HEADER", 	"#COMBATRANGE_COMBATZONE_BODY", 	$"rui/hud/gametype_icons/firingrange/about_combatrange_combatrange" ) )
	tab2Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#COMBATRANGE_MOVEMENTZONE_HEADER", 	"#COMBATRANGE_MOVEMENTZONE_BODY", 	$"rui/hud/gametype_icons/firingrange/about_combatrange_advancedmovement" ) )

	tab2.rules = tab2Rules
	tabs.append( tab2 )

	return tabs
}

#endif      