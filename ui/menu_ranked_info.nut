global function InitRankedInfoMenu
global function OpenRankedInfoPage
global function InitRankedScoreBarRui

#if DEV
global function TestScoreBar
#endif

struct
{
	table<var, bool > rankedRuisToUpdate
	var menu
	var moreInfoButton
	var infoButtonRank

	var panelRankInfo
	var closeButtonRankInfo

} file

void function InitRankedInfoMenu( var newMenuArg )                                               
{
	var menu = GetMenu( "RankedInfoMenu" )
	file.menu = menu

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnRankedInfoMenu_Open )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnRankedInfoMenu_Close )

	AddMenuEventHandler( menu, eUIEvent.MENU_SHOW, OnRankedInfoMenu_Show )
	AddMenuEventHandler( menu, eUIEvent.MENU_HIDE, OnRankedInfoMenu_Hide )

	AddMenuFooterOption( menu, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
	AddMenuFooterOption( menu, LEFT, BUTTON_Y, true, "#Y_BUTTON_VIEW_REWARDS", "#VIEW_REWARDS", OnViewRewards, ShouldShowRewards )
	
	                                            
	var moreInfoButton = Hud_GetChild( menu, "MoreInfoButton" )
	file.moreInfoButton = moreInfoButton

	var infoButtonRank = Hud_GetChild ( menu, "RankMoreInfoButton" )
	file.infoButtonRank = infoButtonRank

	var panelRankInfo = Hud_GetChild ( menu, "MoreInfoPanel" )
	file.panelRankInfo = panelRankInfo

	var closeButtonRankInfo = Hud_GetChild ( menu, "MoreInfoCloseButton" )
	file.closeButtonRankInfo = closeButtonRankInfo

	HideRankedInfoPanel ( null )

	Hud_AddEventHandler( moreInfoButton, UIE_CLICK, OpenRankedInfoMorePage )
	Hud_AddEventHandler( infoButtonRank, UIE_CLICK, ShowRankedAboutPanel )
	Hud_AddEventHandler( closeButtonRankInfo, UIE_CLICK, HideRankedInfoPanel )
}

void function OpenRankedInfoPage( var button )
{
	AdvanceMenu( file.menu )
}

void function ShowRankedAboutPanel( var button )
{
	Hud_Show( file.panelRankInfo )
	Hud_Show( file.closeButtonRankInfo )
}

void function HideRankedInfoPanel( var button )
{
	Hud_Hide( file.panelRankInfo )
	Hud_Hide( file.closeButtonRankInfo )
}

void function OnRankedInfoMenu_Open()
{
	PrintFunc()
	UI_SetPresentationType( ePresentationType.WEAPON_CATEGORY )

	Lobby_AdjustScreenFrameToMaxSize( Hud_GetChild( file.menu, "ScreenFrame" ), true )
	entity player = GetLocalClientPlayer()

	bool inProvisional 					 = !Ranked_HasCompletedProvisionalMatches(player)
	int currentScore                     = GetPlayerRankScore( player )
	array<SharedRankedTierData> tiers    = Ranked_GetTiers()
	int ladderPosition                   = Ranked_GetLadderPosition( player  )
	SharedRankedDivisionData currentRank = GetCurrentRankedDivisionFromScoreAndLadderPosition( currentScore, ladderPosition )
	SharedRankedTierData currentTier     = currentRank.tier

	array< SharedRankedDivisionData > divisionData =  Ranked_GetRankedDivisionDataForTier( currentRank.tier )

	array<var> panels = GetElementsByClassname( file.menu, "RankedInfoPanel" )

	foreach ( panel in panels )
	{
		InitRankedInfoPanel( panel, tiers )
	}

	var mainRui = Hud_GetRui( Hud_GetChild( file.menu, "InfoMain" ) )
	if ( currentTier.isLadderOnlyTier  )                                                        
	{
		SharedRankedDivisionData scoreDivisionData = GetCurrentRankedDivisionFromScore( currentScore )
		SharedRankedTierData scoreCurrentTier      = scoreDivisionData.tier
		RuiSetInt( mainRui, "currentTierColorOffset", scoreCurrentTier.index + 1 )
	}
	else
	{
		RuiSetInt( mainRui, "currentTierColorOffset", currentTier.index )
	}

	RuiSetInt( mainRui, "currentScore", currentScore )
	RuiSetBool( mainRui, "inSeason", IsRankedInSeason() )
	RuiSetBool( mainRui, "inProvisional", inProvisional )
	RuiSetString( mainRui, "currentRankString", currentRank.divisionName )
	RuiSetString( mainRui, "provisionalCount", string (player.GetPersistentVarAsInt( "rankedProvisionalMatchesCompleted" ) ) )
	RuiSetString( mainRui, "provisionalCountMax", string (Ranked_GetNumProvisionalMatchesRequired() ) )
	RuiSetString( mainRui, "currentRankBracketString", (currentRank.emblemDisplayMode == emblemDisplayMode.DISPLAY_DIVISION) ? currentRank.emblemText : "" )

	int entryCost = Ranked_GetCostForEntry()
	RuiSetString( mainRui, "currentEntryFeeString", ( entryCost == 0 )? "#RANKED_FREE": string( entryCost ) )


	for ( int i=0; i<tiers.len(); i++ )
	{
		int idx                = i+1
		SharedRankedTierData d = tiers[i]

		RuiSetInt( mainRui, "entryFee" + i, d.entryCost )
	}

	Assert( Ranked_GetCurrentActiveRankedPeriod() != null )
	if ( Ranked_GetCurrentActiveRankedPeriod() == null )
		return

	ItemFlavor latestRankedPeriod = expect ItemFlavor( Ranked_GetCurrentActiveRankedPeriod() )
	string rankedPeriodGUIDString = ItemFlavor_GetGUIDString( latestRankedPeriod  )
	if( Ranked_PeriodHasLadderOnlyDivision( rankedPeriodGUIDString) )
	{
		SharedRankedDivisionData ladderOnlyDivision = Ranked_GetHistoricalLadderOnlyDivision( rankedPeriodGUIDString  )
		SharedRankedTierData ladderOnlyTier         = ladderOnlyDivision.tier
		int index                                   = tiers.len()

		RuiSetInt( mainRui, "entryFee" + ( index - 1 ), ladderOnlyTier.entryCost )
	}

	var scoreBarRui = Hud_GetRui( Hud_GetChild( file.menu, "RankedProgressBar" ) )
	if (inProvisional)
		InitRankedScoreBarRui( scoreBarRui, currentScore, Ranked_GetLadderPosition( GetLocalClientPlayer() ))
	else
		InitRankedScoreBarRuiForDoubleBadge( scoreBarRui, currentScore, Ranked_GetLadderPosition( GetLocalClientPlayer() ))

	var rankedScoringTableRui = Hud_GetRui( Hud_GetChild( file.menu, "RankedScoringTable" ) )
	RuiSetInt( rankedScoringTableRui, "fourteenthPlaceRP", Ranked_GetPointsForPlacement( 14 ) )
	RuiSetInt( rankedScoringTableRui, "eleventhPlaceRP", Ranked_GetPointsForPlacement( 11 ) )
	RuiSetInt( rankedScoringTableRui, "tenthPlaceRP", Ranked_GetPointsForPlacement( 10 ) )
	RuiSetInt( rankedScoringTableRui, "ninthPlaceRP", Ranked_GetPointsForPlacement( 9 ) )
	RuiSetInt( rankedScoringTableRui, "eighthPlaceRP", Ranked_GetPointsForPlacement( 8 ) )
	RuiSetInt( rankedScoringTableRui, "seventhPlaceRP", Ranked_GetPointsForPlacement( 7 ) )
	RuiSetInt( rankedScoringTableRui, "sixthPlaceRP", Ranked_GetPointsForPlacement( 6 ) )
	RuiSetInt( rankedScoringTableRui, "fifthPlaceRP", Ranked_GetPointsForPlacement( 5 ) )
	RuiSetInt( rankedScoringTableRui, "fourthPlaceRP", Ranked_GetPointsForPlacement( 4 ) )
	RuiSetInt( rankedScoringTableRui, "thirdPlaceRP", Ranked_GetPointsForPlacement( 3 ) )
	RuiSetInt( rankedScoringTableRui, "secondPlaceRP", Ranked_GetPointsForPlacement( 2 ) )
	RuiSetInt( rankedScoringTableRui, "firstPlaceRP", Ranked_GetPointsForPlacement( 1 ) )

}

void function InitRankedScoreBarRui( var rui, int score, int ladderPosition )
{
	array<SharedRankedTierData> divisions = Ranked_GetTiers()
	SharedRankedDivisionData currentRank  = GetCurrentRankedDivisionFromScoreAndLadderPosition( score, ladderPosition )
	SharedRankedTierData currentTier      = currentRank.tier
	SharedRankedTierData ornull nextTier  = Ranked_GetNextTierData( currentRank.tier )

	array< SharedRankedDivisionData > divisionData = Ranked_GetRankedDivisionDataForTier ( currentRank.tier )

	RuiSetGameTime( rui, "animStartTime", RUI_BADGAMETIME )

	if ( currentTier.isLadderOnlyTier  )                                                        
	{
		SharedRankedDivisionData scoreDivisionData = GetCurrentRankedDivisionFromScore( score )
		SharedRankedTierData scoreCurrentTier      = scoreDivisionData.tier
		RuiSetInt( rui, "currentTierColorOffset", scoreCurrentTier.index + 1 )
	}
	else
	{
		RuiSetInt( rui, "currentTierColorOffset", currentTier.index )
	}

	                                                                                            
	if ( !Ranked_HasCompletedProvisionalMatches(GetLocalClientPlayer() ) )
	{
		RuiDestroyNestedIfAlive( rui, "rankedBadgeHandle0" )

		SharedRankedDivisionData data = divisionData[ 0 ]
		for ( int i=1; i<divisionData.len(); i++ )
		{
			if ( divisionData[ i ].scoreMin > score )
				break

			data = divisionData[ i ]
		}

		SharedRanked_FillInRuiEmblemText( rui, data, score, ladderPosition, string(0)  )
		CreateNestedRankedRui( rui, data.tier, "rankedBadgeHandle0", score, SHARED_RANKED_INVALID_LADDER_POSITION  )

		RuiSetInt( rui, "currentScore" , score )
		RuiSetInt( rui, "startScore" , score )
		RuiSetImage( rui, "icon0" , currentTier.icon )
		RuiSetInt( rui, "badgeScore0", score )
		RuiSetBool( rui, "showSingleBadge", true )

		return
	}

	                                  
	for ( int i=0; i<5; i++ )
	{
		RuiDestroyNestedIfAlive( rui, "rankedBadgeHandle" + i )
	}

	for ( int i=0; i<divisionData.len(); i++ )
	{
		SharedRankedDivisionData data = divisionData[ i ]
		RuiSetImage( rui, "icon" + i , currentTier.icon )
		RuiSetInt( rui, "badgeScore" + i, data.scoreMin )

		SharedRanked_FillInRuiEmblemText( rui, data, score, ladderPosition, string(i)  )
		CreateNestedRankedRui( rui, data.tier, "rankedBadgeHandle" + i, data.scoreMin, SHARED_RANKED_INVALID_LADDER_POSITION  )
	}

	RuiSetInt( rui, "currentScore" , score )
	RuiSetInt( rui, "startScore" , divisionData[0].scoreMin )

	if ( nextTier != null )
	{
		expect SharedRankedTierData( nextTier )

		if ( !nextTier.isLadderOnlyTier )
		{
			SharedRankedDivisionData firstRank = Ranked_GetRankedDivisionDataForTier( nextTier )[0]

			RuiSetInt( rui, "endScore" , firstRank.scoreMin  )
			RuiSetString( rui, "emblemText4" , firstRank.emblemText  )
			RuiSetInt( rui, "badgeScore4", firstRank.scoreMin )
			RuiSetImage( rui, "icon4", nextTier.icon )
			SharedRanked_FillInRuiEmblemText( rui, firstRank, firstRank.scoreMin, ladderPosition, "4"  )
			CreateNestedRankedRui( rui, firstRank.tier, "rankedBadgeHandle4", firstRank.scoreMin, SHARED_RANKED_INVALID_LADDER_POSITION )
		}
	}

	RuiSetBool( rui, "showSingleBadge", true )
}

void function InitRankedInfoPanel( var panel, array<SharedRankedTierData> tiers )
{
	array<SharedRankedTierData> infoTiers = clone tiers
	int scriptID                          = int( Hud_GetScriptID( panel ) )

	Assert( Ranked_GetCurrentActiveRankedPeriod() != null )
	if ( Ranked_GetCurrentActiveRankedPeriod() == null )
		return

	ItemFlavor currentRankedPeriod = expect ItemFlavor( Ranked_GetCurrentActiveRankedPeriod() )
	string rankedGUIDString = ItemFlavor_GetGUIDString( currentRankedPeriod )
	if ( Ranked_PeriodHasLadderOnlyDivision( rankedGUIDString )  )
	{
		SharedRankedDivisionData ladderOnlyDivision = Ranked_GetHistoricalLadderOnlyDivision( rankedGUIDString  )
		SharedRankedTierData ladderOnlyTier         = ladderOnlyDivision.tier
		infoTiers.append( ladderOnlyTier  )
	}
	if ( scriptID >= infoTiers.len() )
	{
		Hud_Hide( panel )
		return
	}

	Hud_Show( panel )

	SharedRankedTierData rankedTier = infoTiers[scriptID]
	var rui                         = Hud_GetRui( panel )

	int ladderPosition = Ranked_GetLadderPosition( GetLocalClientPlayer() )

	SharedRankedDivisionData currentRank = GetCurrentRankedDivisionFromScoreAndLadderPosition( GetPlayerRankScore( GetLocalClientPlayer() ), ladderPosition )

	RuiSetString( rui, "name", rankedTier.name )
	RuiSetInt( rui, "minScore", rankedTier.scoreMin )
	RuiSetInt( rui, "rankTier", scriptID )
	RuiSetImage( rui, "bgImage", rankedTier.bgImage )
	RuiSetImage( rui, "glowImage", rankedTier.glowImage )
	RuiSetBool( rui, "isLocked", rankedTier.index > currentRank.tier.index )
	RuiSetBool( rui, "isProvisional", !Ranked_HasCompletedProvisionalMatches(GetLocalClientPlayer()) )

	RuiSetBool( rui, "isCurrent", currentRank.tier == rankedTier )

	if (  rankedTier.isLadderOnlyTier )
	{
		RuiSetBool( rui, "isLadderOnlyTier", rankedTier.isLadderOnlyTier  )
		RuiSetInt( rui, "numPlayersOnLadder", Ranked_GetNumPlayersOnLadder()  )
	}

	var myParent = Hud_GetParent( panel )

	for ( int i=0; i<rankedTier.rewards.len(); i++ )
	{
		SharedRankedReward reward = rankedTier.rewards[i]
		var button                = Hud_GetChild( myParent, "RewardButton" + scriptID + "_" + i )

		var btRui = Hud_GetRui( button )
		RuiSetImage( btRui, "buttonImage", reward.previewIcon )
		RuiSetInt( btRui, "tier", scriptID )
		RuiSetBool( btRui, "showBox", reward.previewIconShowBox )
		RuiSetBool( btRui, "isLocked", rankedTier.index > currentRank.tier.index )

		ToolTipData ttd
		ttd.titleText = reward.previewName
		ttd.descText = "#RANKED_REWARD"
		Hud_SetToolTipData( button, ttd )

		if ( GetCurrentPlaylistVarBool( "ranked_reward_show_button", false ) )
			Hud_Show( button )
		else
			Hud_Hide( button )

		int idx = (i+1)

		if ( GetCurrentPlaylistVarBool( "ranked_reward_show_text", true ) )
		{
			string tierName = string( rankedTier.index )
			string rewardString = GetCurrentPlaylistVarString( "ranked_reward_override_" + tierName + "_" + idx, reward.previewName )
			RuiSetString( rui, "rewardString" + idx, rewardString )
		}
		else
			RuiSetString( rui, "rewardString" + idx, "" )
	}
}

void function OnRankedInfoMenu_Close()
{
}

void function OnRankedInfoMenu_Show()
{
#if NX_PROG || PC_PROG_NX_UI
	HideRankedInfoPanel ( null )
#endif
}

void function OnRankedInfoMenu_Hide()
{
}

void function TestScoreBar( int startScore = 370, int endScore = 450  )
{
	var scoreBarRui = Hud_GetRui( Hud_GetChild( file.menu, "RankedProgressBar" ) )
	RuiSetGameTime( scoreBarRui, "animStartTime", ClientTime() )
	RuiSetInt( scoreBarRui, "animStartScore", startScore )
	RuiSetInt( scoreBarRui, "currentScore", endScore )

}

void function OnViewRewards( var button )
{
	string creditsURL = Localize( GetCurrentPlaylistVarString( "show_ranked_rewards_link", "https://www.ea.com/games/apex-legends" ) )
	LaunchExternalWebBrowser( creditsURL, WEBBROWSER_FLAG_NONE )
}

bool function ShouldShowRewards()
{
	return GetCurrentPlaylistVarString( "show_ranked_rewards_link", "" ) != ""
}

void function moreInfoButton_OnActivate( var button )
{
	if ( IsDialog( GetActiveMenu() ) )
		return

	thread OnRankedMenu_RankedMoreInfo( button )
}

void function OnRankedMenu_RankedMoreInfo( var button )
{
	var savedMenu = GetActiveMenu()

	if ( savedMenu == GetActiveMenu() )
	{		
		thread ShowMoreInfo( button )		
	}
}


void function ShowMoreInfo( var button )
{
	OpenRankedInfoMorePage( button )
}
