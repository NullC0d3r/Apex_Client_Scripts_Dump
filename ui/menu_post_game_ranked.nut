global function InitPostGameRankedMenu
global function OpenRankedSummary
global function InitRankedScoreBarRuiForDoubleBadge

const string POSTGAME_LINE_ITEM = "UI_Menu_MatchSummary_Ranked_XPBreakdown"
const string POSTGAME_XP_INCREASE = "UI_Menu_MatchSummary_Ranked_XPBar_Increase"
const asset RUI_PATH_RANKED_DIVISION_UP = $"ui/rank_division_up_anim.rpak"
const float PROGRESS_BAR_FILL_TIME = 5.0
const float PROGRESS_BAR_FILL_TIME_FAST = 2.0
const float LINE_DISPLAY_TIME = 0.4
const float RANK_UP_TIME = 3.6
const float DIALOGUE_DELAY = 1.6
const float ANIMATE_XP_BAR_DELAY = 0.25
const float START_DELAY_OFFSET = -50.0
const float BAD_GAME_TIME_OFFSET = -9999.0
const int NUM_SCORE_LINES_DEFAULT = 4

struct
{
	var  menu
	var  continueButton
	var  menuHeaderRui
	bool showQuickVersion
	bool skippableWaitSkipped = false
	bool disableNavigateBack = true
	bool isFirstTime = false
	bool buttonsRegistered = false
	bool canUpdateXPBarEmblem = false
	var  barRuiToUpdate = null
} file

struct scoreLine
{
	string keyString = ""
	string valueString = ""
	vector color = <1,1,1>
	float  alpha = 1.0
	float rowHeight = 1.0
}

void function InitPostGameRankedMenu( var newMenuArg )
{
	var menu = GetMenu( "PostGameRankedMenu" )
	file.menu = menu

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnPostGameRankedMenu_Open )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnPostGameRankedMenu_Close )
	AddMenuEventHandler( menu, eUIEvent.MENU_SHOW, OnPostGameRankedMenu_Show )
	AddMenuEventHandler( menu, eUIEvent.MENU_HIDE, OnPostGameRankedMenu_Hide )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, OnNavigateBack )

	file.continueButton = Hud_GetChild( menu, "ContinueButton" )

	Hud_AddEventHandler( file.continueButton, UIE_CLICK, OnContinue_Activate )

	AddMenuFooterOption( menu, LEFT, BUTTON_B, true, "#B_BUTTON_CLOSE", "#B_BUTTON_CLOSE", null, CanNavigateBack )
	AddMenuFooterOption( menu, LEFT, BUTTON_BACK, true, "", "", CloseRankedSummary, CanNavigateBack )

	RegisterSignal( "OnPostGameRankedMenu_Close" )

	file.menuHeaderRui = Hud_GetRui( Hud_GetChild( menu, "MenuHeader" ) )

	RuiSetString( file.menuHeaderRui, "menuName", "#MATCH_SUMMARY" )

#if DEV
	AddMenuThinkFunc( file.menu, PostGameRankedMenuAutomationThink )
#endif       
}

#if DEV
void function PostGameRankedMenuAutomationThink( var menu )
{
	if (AutomateUi())
	{
		printt("PostGameRankedMenuAutomationThink OnContinue_Activate()")
		OnContinue_Activate(null)
	}
}
#endif       

void function OnPostGameRankedMenu_Open()
{
	Hud_Hide( Hud_GetChild( file.menu, "RewardDisplay" ) )
	Hud_Show( Hud_GetChild( file.menu, "BlackOut" ) )
	AddCallbackAndCallNow_UserInfoUpdated( Ranked_OnUserInfoUpdatedInPostGame )
	Lobby_AdjustScreenFrameToMaxSize( Hud_GetChild( file.menu, "ScreenFrame" ), true )
}

void function OnPostGameRankedMenu_Show()
{
	thread _Show()
}

void function _Show()
{
	Signal( uiGlobal.signalDummy, "OnPostGameRankedMenu_Close" )
	EndSignal( uiGlobal.signalDummy, "OnPostGameRankedMenu_Close" )

	if ( !IsFullyConnected() )
		return

	UI_SetPresentationType( ePresentationType.WEAPON_CATEGORY )

	float maxTimeToWaitForLoadScreen = UITime() + LOADSCREEN_FINISHED_MAX_WAIT_TIME
	while(  UITime() < maxTimeToWaitForLoadScreen && !IsLoadScreenFinished()  )                                                                                         
		WaitFrame()

	bool isFirstTime = GetPersistentVarAsInt( "showGameSummary" ) != 0
	if ( isFirstTime && TryOpenSurvey( eSurveyType.POSTGAME ) )
	{
		while ( IsDialog( GetActiveMenu() ) )
			WaitFrame()
	}

	Hud_Hide( Hud_GetChild( file.menu, "BlackOut" ) )

	var rui = Hud_GetRui( Hud_GetChild( file.menu, "SummaryBox" ) )
	RuiSetString( rui, "titleText", "#RANKED_TITLE" )

	ItemFlavor ornull rankedPeriod = Ranked_GetCurrentActiveRankedPeriod()
	Assert( rankedPeriod != null )
	if ( rankedPeriod != null )
	{
		expect ItemFlavor( rankedPeriod )
		RuiSetString( rui, "subTitleText", ItemFlavor_GetShortName( rankedPeriod ) )
	}

	var hudElem = Hud_GetChild( file.menu, "RankedProgressBar" )
	var barRui = Hud_GetRui( hudElem )
	RuiSetGameTime( barRui, "animStartTime", RUI_BADGAMETIME )

	                                                                                                            

	if ( !file.buttonsRegistered )
	{
		RegisterButtonPressedCallback( BUTTON_A, OnContinue_Activate )
		RegisterButtonPressedCallback( KEY_SPACE, OnContinue_Activate )
		file.buttonsRegistered = true
	}

	var matchRankRui = Hud_GetRui( Hud_GetChild( file.menu, "MatchRank" ) )
	PopulateMatchRank( matchRankRui )

	thread DisplayRankLadderPointsBreakdown()
}

void function DisplayRankLadderPointsBreakdown()
{
	Assert( IsRankedInSeason() )
	if ( !IsRankedInSeason() )
		return

	EndSignal( uiGlobal.signalDummy, "OnPostGameRankedMenu_Close" )
	Hud_Show( file.continueButton )

	bool quick 				  = !(file.isFirstTime)
	file.canUpdateXPBarEmblem = false
	file.disableNavigateBack  = !quick
	file.showQuickVersion     = quick

	entity uiPlayer    = GetLocalClientPlayer()
	bool inProvisional = !Ranked_HasCompletedProvisionalMatches(uiPlayer)

	RankLadderPointsBreakdown scoreBreakdown
	LoadLPBreakdownFromPersistance ( scoreBreakdown, uiPlayer )

	int score          = scoreBreakdown.finalLP
	int ladderPosition = Ranked_GetLadderPosition( uiPlayer )                                                                   
	int previousScore  = scoreBreakdown.startingLP
	int netLP		   = scoreBreakdown.netLP

	Assert( netLP == score - previousScore )

	SharedRankedDivisionData currentRank  = GetCurrentRankedDivisionFromScoreAndLadderPosition( score, ladderPosition )
	SharedRankedDivisionData previousRank = GetCurrentRankedDivisionFromScore( previousScore )

	bool wasPromoted     = ( currentRank.index > previousRank.index ) && ( !previousRank.isLadderOnlyDivision ) && ( netLP > 0 )
	bool wasDemoted 	 = ( currentRank.index < previousRank.index ) && ( !previousRank.isLadderOnlyDivision )
	bool rankForgiveness = bool( GetRankedGameData( uiPlayer, "lastGameRankedForgiveness" ) ) ||
												bool( GetRankedGameData( uiPlayer, "lastGameAbandonForgiveness" ) )
	bool demotionProtect = ( GetRankedGameData( uiPlayer, "lastGameTierDerankingProtectionAdjustment" ) > 0 ) &&
												!wasDemoted && !rankForgiveness && !wasPromoted && currentRank.tier.allowsDemotion
												&& !inProvisional

	var demotionHudElem = Hud_GetChild( file.menu, "RankedDemotionProtection" )
	var progressBar     = Hud_GetChild( file.menu, "RankedProgressBar" )
	var scoreAdjustElem = Hud_GetChild( file.menu, "RankedScoreAdjustment" )
	var scoreAdjustRui  = Hud_GetRui( scoreAdjustElem )
	var barRui          = Hud_GetRui( progressBar )
	var protectionRui   = Hud_GetRui( demotionHudElem )
	var xpRui 			= Hud_GetRui( Hud_GetChild( file.menu, "XPEarned1" ) )

	RuiSetString( xpRui, "headerText", "#RANKED_TITLE_SCORE_REPORT" )

	if ( scoreBreakdown.wasAbandoned )
		RuiSetString( xpRui, "headerText", "#RANKED_TITLE_ABANDON" )

	RuiSetGameTime( barRui, "animStartTime", RUI_BADGAMETIME )
	RuiSetInt( scoreAdjustRui, "scoreAdjustment", netLP )
	RuiSetBool( scoreAdjustRui, "demoted", wasDemoted)
	RuiSetBool( scoreAdjustRui, "inSeason", true )

	                                                             

	if ( wasDemoted )
		RuiSetString( scoreAdjustRui, "demotedRank", currentRank.divisionName )

	if ( quick || ( netLP < 0 ) )
	{
		if ( inProvisional )
			InitRankedScoreBarRui( barRui, score, ladderPosition)
		else
			InitRankedScoreBarRuiForDoubleBadge( barRui, score, ladderPosition )
	}

	RuiDestroyNestedIfAlive( protectionRui, "rankedBadgeHandle0")
	CreateNestedRankedRui( protectionRui, currentRank.tier, "rankedBadgeHandle0", score, ladderPosition )

	SharedRankedTierData currentTier = currentRank.tier

	RuiSetImage( protectionRui, "rankedIcon" , currentTier.icon )
	RuiSetString( protectionRui, "emblemText" , currentRank.emblemText )
	RuiSetInt( protectionRui, "protectionCurrent" , GetDemotionProtectionBuffer ( uiPlayer ) )
	SharedRanked_FillInRuiEmblemText( protectionRui, currentRank, score, ladderPosition  )
	ColorCorrectRui( protectionRui, currentTier, score )

	                                                      
	waitthread DoRTKAnimationSyncSkippableWaitThread( xpRui, scoreBreakdown )

	ShowRelevantHudElem( demotionProtect )

	int numRanksEarned = ( currentRank.index - previousRank.index )
	if ( ( numRanksEarned > 0 ) && currentRank.isLadderOnlyDivision )                            
	{
		if( !(GetNextRankedDivisionFromScore( previousScore ) == null) )                                    
			numRanksEarned = 2                                                                                                             
	}

	ladderPosition = Ranked_GetLadderPosition( uiPlayer )                                                             
	if ( inProvisional )
		InitRankedScoreBarRui( barRui, score, ladderPosition)
	else
		InitRankedScoreBarRuiForDoubleBadge( barRui, score, ladderPosition )

	wait ANIMATE_XP_BAR_DELAY

	if ( !inProvisional )                                      
	{
		if  ( !quick && ( netLP > 0 ) && !wasDemoted )
			waitthread AnimateXPBar( numRanksEarned, barRui, score, previousScore, ladderPosition )
		else if ( !quick && ( netLP < 0 ) && wasDemoted )
			PlayLobbyCharacterDialogue( "glad_rankDown"  )

		                                                                                                     
		int finalLadderPos = Ranked_GetLadderPosition( uiPlayer )
		if ( finalLadderPos != ladderPosition )
			InitRankedScoreBarRuiForDoubleBadge( barRui, score, ladderPosition )
	}

	OnThreadEnd( function() : ( demotionProtect ) {
		CleanupRankLadderPointsBreakdown( demotionProtect )
	} )
}


void function ShowRelevantHudElem( bool isDemotionProtected )
{
	if ( isDemotionProtected )
		Hud_Show( Hud_GetChild( file.menu, "RankedDemotionProtection" ) )
	else
		Hud_Show( Hud_GetChild( file.menu, "RankedProgressBar" ) )
}


void function CleanupRankLadderPointsBreakdown( bool isDemotionProtected )
{
	Hud_Hide( Hud_GetChild( file.menu, "RewardDisplay" ) )
	Hud_Hide( Hud_GetChild( file.menu, "MovingBoxBG" ) )

	file.disableNavigateBack = false
	file.canUpdateXPBarEmblem = true

	ShowRelevantHudElem( isDemotionProtected )
	UpdateFooterOptions()
	StopUISoundByName( POSTGAME_XP_INCREASE )
}


int function BuildScoreLinesArray( RankLadderPointsBreakdown scoreBreakdown, SharedRankedDivisionData currentRank, SharedRankedDivisionData previousRank )
{
	array< scoreLine > scoreLines
	entity player                  = GetLocalClientPlayer()
	var rui 					   = Hud_GetRui( Hud_GetChild( file.menu, "XPEarned1" ) )
	int score					   = scoreBreakdown.finalLP
	int previousScore              = scoreBreakdown.startingLP
	bool previousGameWasAbandonded = scoreBreakdown.wasAbandoned

	   
	          
	         
	             
	       
	             
	                  
	             
	    
	                    
	                       
	    
	     
	   

	                                                            
	scoreLine entryCostLine
	if ( previousRank.isLadderOnlyDivision || GetNextRankedDivisionFromScore( previousScore ) == null  )
		entryCostLine.keyString = Localize( "#RANKED_ENTRY_COST", Localize( "#RANKED_ENTRY_COST_MASTER_APEX_PREDATOR" ) )
	else
		entryCostLine.keyString = Localize( "#RANKED_ENTRY_COST", Localize( previousRank.tier.name ) )

	int entryCost = Ranked_GetCostForEntry()
	entryCostLine.valueString = string( entryCost )
	scoreLines.append( entryCostLine )

	                                                           
	scoreLine placementLine

	int placement             = scoreBreakdown.placement
	int placementScore        = scoreBreakdown.placementScore + entryCost
	placementLine.keyString   = Localize( "#RANKED_MATCH_PLACEMENT" , placement )
	placementLine.valueString = previousGameWasAbandonded ? Localize( "#RANKED_SCORE_ABANDON", placementScore ) : string ( placementScore )
	scoreLines.append( placementLine )

	                                                       
	int bonusIdx = scoreLines.len()
	scoreLine bonusLine
	scoreLines.append( bonusLine )
	bonusLine.keyString = "TOTAL BONUS"
	int bonusTotal = 0

	if ( scoreBreakdown.killBonus > 0 )
	{
		bonusTotal += scoreBreakdown.killBonus
		scoreLine killScoreLine
		killScoreLine.keyString = "KILLS"
		killScoreLine.valueString = string( scoreBreakdown.killBonus )
		scoreLines.append( killScoreLine )
	}

	if ( scoreBreakdown.convergenceBonus > 0 )
	{
		bonusTotal += scoreBreakdown.convergenceBonus
		scoreLine convergenceScoreLine
		convergenceScoreLine.keyString = "CONVERGENCE"
		convergenceScoreLine.valueString = string( scoreBreakdown.convergenceBonus )
		scoreLines.append( convergenceScoreLine )
	}

	if ( scoreBreakdown.skillDiffBonus > 0 )
	{
		bonusTotal += scoreBreakdown.skillDiffBonus
		scoreLine skillScoreLine
		skillScoreLine.keyString = "SKILL DIFFERENTIAL"
		skillScoreLine.valueString = string( scoreBreakdown.skillDiffBonus )
		scoreLines.append( skillScoreLine )
	}

	if ( scoreBreakdown.provisionalMatchBonus > 0 )
	{
		bonusTotal += scoreBreakdown.provisionalMatchBonus
		scoreLine provScoreLine
		provScoreLine.keyString = "PROVISIONAL MATCH"
		provScoreLine.valueString = string( scoreBreakdown.provisionalMatchBonus )
		scoreLines.append( provScoreLine )
	}

	bonusLine.valueString = string( bonusTotal )

	                                                                                              
	bool tierDemotion    = ( currentRank.index < previousRank.index ) && ( currentRank.tier != previousRank.tier )
	                                                                               
	bool rankForgiveness = bool( GetRankedGameData( GetLocalClientPlayer(), "lastGameRankedForgiveness" ) ) ||
							bool( GetRankedGameData( GetLocalClientPlayer(), "lastGameAbandonForgiveness" ) )
	Assert( !( previousGameWasAbandonded && rankForgiveness ) )                                                   

	int lastGameLossProtectionAdjustment = scoreBreakdown.lossProtectionAdjustment
	if ( rankForgiveness && lastGameLossProtectionAdjustment != 0  )
	{
		scoreLine lossForgivenLine
		lossForgivenLine.keyString =  "#RANKED_FORGIVENESS"
		lossForgivenLine.valueString = string( lastGameLossProtectionAdjustment )
		                       
		if ( scoreLines.len() >= 7 )
			scoreLines.pop()
		scoreLines.append( lossForgivenLine )
	}
	else if ( previousGameWasAbandonded )
	{
		int abandonPenalty = scoreBreakdown.penaltyPointsForAbandoning

		scoreLine abandonPenalityLine
		abandonPenalityLine.keyString = "#RANKED_ABANDON_PENALTY"
		abandonPenalityLine.valueString = Localize( "#RANKED_SCORE_ABANDON", abandonPenalty )
		                       
		if ( scoreLines.len() >= 7 )
			scoreLines.pop()
		scoreLines.append( abandonPenalityLine )
	}

	int tierDerankingProtectionAdjustment = scoreBreakdown.demotionProtectionAdjustment
	bool wasPromoted = ( currentRank.index > previousRank.index ) && ( !previousRank.isLadderOnlyDivision ) && ( score > previousScore )

	if ( tierDerankingProtectionAdjustment > 0  )                                         
	{
		if ( tierDemotion )            
		{
			scoreLine abandonLine
			abandonLine.keyString = "#RANKED_TIER_DERANKING"
			abandonLine.valueString = string( score - previousScore + tierDerankingProtectionAdjustment )
			                       
			if ( scoreLines.len() >= 7 )
				scoreLines.pop()
			scoreLines.append(abandonLine)
		}
		else if ( wasPromoted )             
		{
			scoreLine promoteLine
			promoteLine.keyString = "#RANKED_TIER_PROMOTION_BONUS"
			promoteLine.valueString =  string( tierDerankingProtectionAdjustment )
			                       
			if ( scoreLines.len() >= 7 )
				scoreLines.pop()
			scoreLines.append(promoteLine)
		}
		else                       
		{
			scoreLine tierDemotionLine
			tierDemotionLine.keyString = "#RANKED_TIER_DERANKING_PROTECTION"
			tierDemotionLine.valueString =  string( tierDerankingProtectionAdjustment )
			                       
			if ( scoreLines.len() >= 7 )
				scoreLines.pop()
			scoreLines.append(tierDemotionLine)
		}
	}

	for ( int i = 0 ; i < scoreLines.len(); i++ )
	{
		RuiSetString ( rui, "line" + string ( i+1 ) + "KeyString", scoreLines[i].keyString )
		RuiSetString ( rui, "line" + string ( i+1 ) + "ValueString", scoreLines[i].valueString )
		RuiSetColorAlpha ( rui, "line" + string ( i+1 ) + "Color", scoreLines[i].color, scoreLines[i].alpha	 )
		RuiSetFloat ( rui, "line" + string ( i+1 ) + "RowHeight" , scoreLines[i].rowHeight )
	}

	return scoreLines.len()
}

void function DoRTKAnimationSyncSkippableWaitThread( var xpRui, RankLadderPointsBreakdown scoreBreakdown  )
{
	                                                                                                                                    

	int numLines = NUM_SCORE_LINES_DEFAULT
	if (scoreBreakdown.killBonus > 0)
		numLines++

	if (scoreBreakdown.convergenceBonus > 0)
		numLines++

	if (scoreBreakdown.skillDiffBonus > 0)
		numLines++

	if (scoreBreakdown.provisionalMatchBonus > 0)
		numLines++

	if (scoreBreakdown.promotionBonus > 0)
		numLines++

	if (scoreBreakdown.penaltyPointsForAbandoning > 0 || scoreBreakdown.lossProtectionAdjustment > 0)
		numLines++

	if (scoreBreakdown.demotionPenality > 0 || scoreBreakdown.demotionProtectionAdjustment > 0)
		numLines++

	var demotionHudElem = Hud_GetChild( file.menu, "RankedDemotionProtection" )
	var scoreAdjustElem = Hud_GetChild( file.menu, "RankedScoreAdjustment" )
	var progressBar     = Hud_GetChild( file.menu, "RankedProgressBar" )

	Hud_Hide( progressBar )
	Hud_Hide( scoreAdjustElem )
	Hud_Hide ( demotionHudElem )

	ResetSkippableWait()
	wait(0.5)

	for ( int lineIndex = 0; lineIndex < numLines; lineIndex++ )
	{
		if ( IsSkippableWaitSkipped() )
			continue

		waitthread SkippableWait( LINE_DISPLAY_TIME, "" )
	}

	Hud_Show( scoreAdjustElem )

	ResetSkippableWait()

	waitthread SkippableWait( LINE_DISPLAY_TIME, "UI_Menu_MatchSummary_Ranked_XPTotal" )
}

void function AnimateXPBar( int numRanksEarned, var barRui, int finalScore, int scoreStart, int ladderPosition )
{
	for ( int index = 0; index <= numRanksEarned; index++ )
	{
		int scoreEnd 					  = scoreStart
		file.canUpdateXPBarEmblem         = false                                                                    
		SharedRankedDivisionData rd_start = GetCurrentRankedDivisionFromScoreAndLadderPosition( scoreStart, ladderPosition )
		SharedRankedTierData startingTier = rd_start.tier
		SharedRankedDivisionData ornull nextDivision = GetNextRankedDivisionFromScore( scoreStart )                                                                   

		if ( nextDivision != null )                                           
		{
			InitRankedScoreBarRuiForDoubleBadge( barRui, scoreStart, ladderPosition )

			expect SharedRankedDivisionData( nextDivision )
			SharedRankedTierData nextDivisionTier = nextDivision.tier

			scoreEnd = minint( finalScore, nextDivision.scoreMin )

			float frac = float( abs( scoreEnd - scoreStart ) ) / float( abs( nextDivision.scoreMin - rd_start.scoreMin ) )
			float animDuration = PROGRESS_BAR_FILL_TIME_FAST * frac

			RuiSetGameTime( barRui, "animStartTime", ClientTime() + ANIMATE_XP_BAR_DELAY )
			RuiSetFloat( barRui, "animDuration", animDuration )                                                                                                                         
			RuiSetInt( barRui, "currentScore", scoreEnd )
			RuiSetInt( barRui, "animStartScore", scoreStart )

			waitthread SkippableWait( animDuration + 0.1, POSTGAME_XP_INCREASE )
			StopUISoundByName( POSTGAME_XP_INCREASE )

			if ( ( index < numRanksEarned ) && file.isFirstTime )
			{
				wait 0.1

				Hud_Show( Hud_GetChild( file.menu, "MovingBoxBG" ) )
				Hud_Show( Hud_GetChild( file.menu, "RewardDisplay" ) )
				var rewardDisplayRui = Hud_GetRui( Hud_GetChild( file.menu, "RewardDisplay" ) )
				RuiDestroyNestedIfAlive( rewardDisplayRui, "levelUpAnimHandle" )

				if ( startingTier != nextDivisionTier )
				{
					if ( GetNextRankedDivisionFromScore( finalScore ) == null )                              
						ladderPosition = Ranked_GetLadderPosition( GetLocalClientPlayer() )

					SharedRankedDivisionData promotedDivisionData = GetCurrentRankedDivisionFromScoreAndLadderPosition( finalScore, ladderPosition )
					SharedRankedTierData promotedTierData         = promotedDivisionData.tier                                                                             
					asset levelupRuiAsset                         = startingTier.levelUpRuiAsset

					if ( GetNextRankedDivisionFromScore( finalScore ) == null )                                                                          
					{
						if ( !promotedDivisionData.isLadderOnlyDivision )
							levelupRuiAsset = promotedTierData.levelUpRuiAsset                                   
					}

					var nestedRuiHandle = RuiCreateNested( rewardDisplayRui, "levelUpAnimHandle", levelupRuiAsset )

					RuiSetGameTime( nestedRuiHandle, "startTime", ClientTime() )
					RuiSetImage( nestedRuiHandle, "oldRank", startingTier.icon )
					RuiSetImage( nestedRuiHandle, "newRank", promotedTierData.icon )

					string sound = "UI_Menu_MatchSummary_Ranked_Promotion"
					if ( Ranked_GetNextTierData( nextDivisionTier ) == null )
						sound = "UI_Menu_MatchSummary_Ranked_PromotionApex"                                           

					if ( nextDivisionTier.promotionAnnouncement != "" )
						PlayLobbyCharacterDialogue(  promotedTierData.promotionAnnouncement, DIALOGUE_DELAY  )

					EmitUISound( sound )
				}
				else                                    
				{
					var nestedRuiHandle = RuiCreateNested( rewardDisplayRui, "levelUpAnimHandle", RUI_PATH_RANKED_DIVISION_UP )
					RuiSetGameTime( nestedRuiHandle, "startTime", ClientTime() )
					RuiSetString( nestedRuiHandle, "oldDivision", Localize(rd_start.emblemText))
					RuiSetString( nestedRuiHandle, "newDivision", Localize(nextDivision.emblemText))
					RuiSetImage( nestedRuiHandle, "rankEmblemImg", startingTier.icon )
					EmitUISound( "UI_Menu_MatchSummary_Ranked_RankUp" )

					PlayLobbyCharacterDialogue( "glad_rankUp", DIALOGUE_DELAY  )
				}                                           

				wait RANK_UP_TIME

				Hud_Hide( Hud_GetChild( file.menu, "MovingBoxBG" ) )
				Hud_Hide( Hud_GetChild( file.menu, "RewardDisplay" ) )
			}                                                         

			scoreStart = scoreEnd
		}                               

		InitRankedScoreBarRuiForDoubleBadge( barRui, scoreEnd, ladderPosition )
	}                                                           
}

void function ColorCorrectRui( var rui, SharedRankedTierData currentTier, int score )
{
	if ( currentTier.isLadderOnlyTier )                                             
	{
		SharedRankedDivisionData scoreDivisionData = GetCurrentRankedDivisionFromScore( score )
		SharedRankedTierData scoreCurrentTier      = scoreDivisionData.tier
		RuiSetInt( rui, "currentTierColorOffset", scoreCurrentTier.index + 1 )
	}
	else
	{
		RuiSetInt( rui, "currentTierColorOffset", currentTier.index )
	}
}

void function InitRankedScoreBarRuiForDoubleBadge( var rui, int score, int ladderPosition )
{
	for ( int i=0; i<5; i++ )
		RuiDestroyNestedIfAlive( rui, "rankedBadgeHandle" + i )

	RuiSetBool( rui, "forceDoubleBadge", true )

	SharedRankedDivisionData currentRank = GetCurrentRankedDivisionFromScoreAndLadderPosition( score, ladderPosition )
	SharedRankedTierData currentTier     = currentRank.tier

	RuiSetGameTime( rui, "animStartTime", RUI_BADGAMETIME )
	ColorCorrectRui( rui, currentTier, score )

	                                    
	RuiSetImage( rui, "icon0" , currentTier.icon )
	RuiSetString( rui, "emblemText0" , currentRank.emblemText )
	RuiSetInt( rui, "badgeScore0", score )
	SharedRanked_FillInRuiEmblemText( rui, currentRank, score, ladderPosition, "0"  )
	CreateNestedRankedRui( rui, currentRank.tier, "rankedBadgeHandle0", score, ladderPosition )
	bool shouldUpdateRuiWithCommunityUserInfo = Ranked_ShouldUpdateWithComnunityUserInfo( score, ladderPosition )
	if ( shouldUpdateRuiWithCommunityUserInfo )
		file.barRuiToUpdate = rui

	RuiSetImage( rui, "icon3" , currentTier.icon )
	RuiSetString( rui, "emblemText3" , currentRank.emblemText )
	RuiSetInt( rui, "badgeScore3", currentRank.scoreMin )
	SharedRanked_FillInRuiEmblemText( rui, currentRank, score, ladderPosition, "3"  )
	CreateNestedRankedRui( rui, currentRank.tier, "rankedBadgeHandle3", score, ladderPosition )

	SharedRankedDivisionData ornull nextRank = GetNextRankedDivisionFromScore( score )

	RuiSetInt( rui, "currentScore" , score )
	RuiSetInt( rui, "startScore" , currentRank.scoreMin )
	RuiSetBool( rui, "showSingleBadge", nextRank == null )

	if ( nextRank != null )
	{		
		expect SharedRankedDivisionData( nextRank )
		SharedRankedTierData nextTier = nextRank.tier

		RuiSetBool( rui, "showSingleBadge", nextRank == currentRank )
		RuiSetInt( rui, "endScore" , nextRank.scoreMin )
		RuiSetString( rui, "emblemText4" , nextRank.emblemText  )
		RuiSetInt( rui, "badgeScore4", nextRank.scoreMin )
		RuiSetImage( rui, "icon4", nextTier.icon )
		RuiSetInt( rui, "nextTierColorOffset", nextTier.index )

		SharedRanked_FillInRuiEmblemText( rui, nextRank, nextRank.scoreMin, SHARED_RANKED_INVALID_LADDER_POSITION, "4"  )
		CreateNestedRankedRui( rui, nextRank.tier, "rankedBadgeHandle4", nextRank.scoreMin, SHARED_RANKED_INVALID_LADDER_POSITION )                                                                                      
	}
}

void function OnPostGameRankedMenu_Close()
{
	file.barRuiToUpdate = null
	RemoveCallback_UserInfoUpdated( Ranked_OnUserInfoUpdatedInPostGame )
}

void function OnContinue_Activate( var button )
{
	                                  

	if ( !file.disableNavigateBack )
		CloseRankedSummary( null )

}

void function OnPostGameRankedMenu_Hide()
{
	Signal( uiGlobal.signalDummy, "OnPostGameRankedMenu_Close" )

	if ( file.buttonsRegistered )
	{
		DeregisterButtonPressedCallback( BUTTON_A, OnContinue_Activate )
		DeregisterButtonPressedCallback( KEY_SPACE, OnContinue_Activate )
		file.buttonsRegistered = false
	}
}

void function ResetSkippableWait()
{
	file.skippableWaitSkipped = false
}


bool function IsSkippableWaitSkipped()
{
	return file.skippableWaitSkipped || !file.disableNavigateBack
}


bool function SkippableWait( float waitTime, string uiSound = "" )
{
	if ( IsSkippableWaitSkipped() )
		return false

	if ( uiSound != "" )
		EmitUISound( uiSound )

	float startTime = UITime()
	while ( UITime() - startTime < waitTime )
	{
		if ( IsSkippableWaitSkipped() )
			return false

		WaitFrame()
	}

	return true
}


bool function CanNavigateBack()
{
	return file.disableNavigateBack != true
}


void function OnNavigateBack()
{
	if ( !CanNavigateBack() )
		return

	CloseRankedSummary( null )
}

void function CloseRankedSummary( var button )
{
	if ( GetActiveMenu() == file.menu )
		thread CloseActiveMenu()
}

void function OpenRankedSummary( bool firstTime )
{
	file.isFirstTime = firstTime
	AdvanceMenu( file.menu )
}

void function Ranked_OnUserInfoUpdatedInPostGame( string hardware, string id )
{
	if ( !IsConnected() )
		return

	if ( !IsLobby() )
		return

	if ( hardware == "" && id == "" )
		return

	CommunityUserInfo ornull cui = GetUserInfo( hardware, id )

	if ( cui == null )
		return

	if ( !file.canUpdateXPBarEmblem )                                                                                   
		return

	expect CommunityUserInfo( cui )

	entity uiPlayer    = GetLocalClientPlayer()
	bool inProvisional = !Ranked_HasCompletedProvisionalMatches(uiPlayer)

	if ( cui.hardware == GetUnspoofedPlayerHardware() && cui.uid == GetPlayerUID() )                                      
	{
		if ( file.barRuiToUpdate != null  )                                                                                                                                
		{
			if ( !inProvisional && cui.rankedLadderPos > 0 )                                                                                 
				InitRankedScoreBarRuiForDoubleBadge( file.barRuiToUpdate, cui.rankScore, cui.rankedLadderPos )
		}
	}
}