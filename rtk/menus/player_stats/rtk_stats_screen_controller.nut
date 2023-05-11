global function RTKStatsScreen_PreCacheData_Thread

global function RTKStatsScreenController_OnInitialize
global function RTKStatsScreenController_OnDestroy


global struct RTKLabelValueModel
{
	string label
	string value
	string combined
}

global struct RTKBadgeModel
{
	asset badgeRuiAsset
	int   tier
}

global struct RTKRankedBadgeModel
{
	asset badgeRuiAsset
	string rankedIcon
	string badgeLabel
	string splitLabel

	bool isPlacementMode
	int completedMatches
	int startPip
	array<bool> wonMatches

	string emblemText
	int emblemDisplayMode
	int ladderPosition
	int rankScore
}

global struct RTKAccountProgressModel
{
	float          progressFrac
	string         earnedXP
	RTKBadgeModel& currentBadge
	RTKBadgeModel& nextBadge
}

global struct RTKRankedProgressModel
{
	RTKRankedBadgeModel& badge1
	RTKRankedBadgeModel& badge2
	bool                 isDoubleBadges
}

global struct RTKStatsPanelModel
{
	array<RTKLabelValueModel> headerStats
	array<RTKLabelValueModel> leftCircleStats
	array<RTKLabelValueModel> rightCircleStats
	array<RTKLabelValueModel> footerStats

	string headerTooltipText
	string leftCircleTooltipText
	string rightCircleTooltipText
	string leftFooterTooltipText
	string rightFooterTooltipText

	bool accountProgress
	bool battlepassProgress
	bool rankedProgress

	RTKAccountProgressModel& accountModel
	RTKBadgeModel&           battlepassModel
	RTKRankedProgressModel&  rankedModel
}

global struct RTKSeasonDataModel
{
	string label
	string guid
}

global struct RTKStatsScreenModel
{
	string                    profile
	array<RTKSeasonDataModel> modeOptions
	array<RTKSeasonDataModel> seasonOptions
	bool rightButtonInteractive = true
	RTKStatsPanelModel& 	  leftPanelModel
	RTKStatsPanelModel& 	  rightPanelModel
}

global struct RTKStatsScreenController_Properties
{
	int    mode
	string season
	string seasonGUID

	rtk_behavior leftButtonLabel
	rtk_behavior leftButtonTooltip

	rtk_behavior rightButtonLabel
	rtk_behavior rightButtonTooltip

	rtk_behavior leftDropDown
	rtk_behavior rightDropDown

	rtk_behavior leftPanelBindingRoot
	rtk_behavior rightPanelBindingRoot

	rtk_behavior decorationAnimator
}

struct PrivateData
{
	int menuGUID = -1
	int leftDropDownOnItemPressedEventID = RTKEVENT_INVALID
	int rightDropDownOnItemPressedEventID = RTKEVENT_INVALID
}


void function RTKStatsScreen_PreCacheData_Thread()
{
	                                                            
	var statsScreenModel = RTKDataModelType_CreateStruct( RTK_MODELTYPE_MENUS, "statsScreen", "RTKStatsScreenModel" )

	                                                                                                                 
	StatCard_ClearAvailableSeasonsCache( eStatCardGameMode.BATTLE_ROYALE )
	StatCard_ClearAvailableSeasonsCache( eStatCardGameMode.ARENAS )
	StatCard_ClearAvailableRankedPeriodsCache( eStatCardGameMode.BATTLE_ROYALE )
	StatCard_ClearAvailableRankedPeriodsCache( eStatCardGameMode.ARENAS )
	StatCard_ClearAvailableSeasonsAndRankedPeriodsCache( eStatCardGameMode.BATTLE_ROYALE )
	StatCard_ClearAvailableSeasonsAndRankedPeriodsCache( eStatCardGameMode.ARENAS )

	                                                                                           
	StatCard_GetAvailableSeasons( eStatCardGameMode.BATTLE_ROYALE )
	StatCard_GetAvailableRankedPeriods( eStatCardGameMode.BATTLE_ROYALE )
	StatCard_GetAvailableSeasons( eStatCardGameMode.ARENAS )
	StatCard_GetAvailableRankedPeriods( eStatCardGameMode.ARENAS )
	StatCard_GetAvailableSeasonsAndRankedPeriods( eStatCardGameMode.BATTLE_ROYALE )
	StatCard_GetAvailableSeasonsAndRankedPeriods( eStatCardGameMode.ARENAS )
}

struct RankData
{
	int score
	int ladderPosition
}

struct PlacementData
{
	int         completedMatches
	int         startPip
	array<bool> wonMatches
}

void function SetStatsData( var dataModelStruct, int gameMode, string seasonOrRankedPeriodGUID = "" )
{
	Assert( gameMode == eStatCardGameMode.BATTLE_ROYALE || gameMode == eStatCardGameMode.ARENAS )

	RTKStatsPanelModel statsData = GetStatsData( gameMode, seasonOrRankedPeriodGUID )
	string prependLabel          = seasonOrRankedPeriodGUID == "" ? "#PREPEND_CAREER" : "#PREPEND_TOTAL"

	var headerStats = RTKStruct_GetArray( dataModelStruct, "headerStats" )
	RTKArray_Clear( headerStats )
	foreach ( index, val in statsData.headerStats )
	{
		var model = RTKArray_PushNewStruct( headerStats )
		RTKStruct_SetString( model, "label", Localize( prependLabel, Localize( val.label ) ) )
		RTKStruct_SetString( model, "value", val.value )
	}

	var leftCircleStats = RTKStruct_GetArray( dataModelStruct, "leftCircleStats" )
	RTKArray_Clear( leftCircleStats )
	foreach ( index, val in statsData.leftCircleStats )
	{
		var model = RTKArray_PushNewStruct( leftCircleStats )

		if ( index == 0 )
		{
			RTKStruct_SetString( model, "label", Localize( prependLabel, Localize( val.label ) ) )
			RTKStruct_SetString( model, "value", val.value )
		}
		else
		{
			RTKStruct_SetString( model, "combined", Localize( "#VAL_SPACE_VAL", Localize( val.label ), val.value ) )
		}
	}

	var rightCircleStats = RTKStruct_GetArray( dataModelStruct, "rightCircleStats" )
	RTKArray_Clear( rightCircleStats )
	foreach ( index, val in statsData.rightCircleStats )
	{
		var model = RTKArray_PushNewStruct( rightCircleStats )

		if ( index == 0 )
		{
			RTKStruct_SetString( model, "label", Localize( prependLabel, Localize( val.label ) ) )
			RTKStruct_SetString( model, "value", val.value )
		}
		else
		{
			RTKStruct_SetString( model, "combined", Localize( "#VAL_SPACE_VAL", Localize( val.label ), val.value ) )
		}
	}

	var footerStats = RTKStruct_GetArray( dataModelStruct, "footerStats" )
	RTKArray_Clear( footerStats )
	foreach ( index, val in statsData.footerStats )
	{
		var model = RTKArray_PushNewStruct( footerStats )
		RTKStruct_SetString( model, "label", Localize( val.label ) )
		RTKStruct_SetString( model, "value", val.value )
	}

	RTKStruct_SetString( dataModelStruct, "headerTooltipText", statsData.headerTooltipText )
	RTKStruct_SetString( dataModelStruct, "leftCircleTooltipText", statsData.leftCircleTooltipText )
	RTKStruct_SetString( dataModelStruct, "rightCircleTooltipText", statsData.rightCircleTooltipText )
	RTKStruct_SetString( dataModelStruct, "leftFooterTooltipText", statsData.leftFooterTooltipText )
	RTKStruct_SetString( dataModelStruct, "rightFooterTooltipText", statsData.rightFooterTooltipText )

	entity player = GetLocalClientPlayer()

	if ( seasonOrRankedPeriodGUID == "" )
	{
		RTKStruct_SetBool( dataModelStruct, "accountProgress", true )
		RTKStruct_SetBool( dataModelStruct, "battlepassProgress", false )
		RTKStruct_SetBool( dataModelStruct, "rankedProgress", false )

		int accountXP             = GetPlayerAccountXPProgress( ToEHI( player ) )
		int accountLevel          = GetAccountLevelForXP( accountXP )
		int xpForAccountLevel     = GetTotalXPToCompleteAccountLevel( accountLevel - 1 )
		int xpForNextAccountLevel = GetTotalXPToCompleteAccountLevel( accountLevel )
		float progressFrac        = GraphCapped( accountXP, xpForAccountLevel, xpForNextAccountLevel, 0.0, 1.0 )

		int earnedXPForCurrentLevel = accountXP - xpForAccountLevel
		int maxXPForCurrentLevel    = xpForNextAccountLevel - xpForAccountLevel

		var accountModel = RTKStruct_GetStruct( dataModelStruct, "accountModel" )
		RTKStruct_SetFloat( accountModel, "progressFrac", progressFrac )
		RTKStruct_SetString( accountModel, "earnedXP", Localize( "#VAL_SLASH_VAL", string( earnedXPForCurrentLevel ), string( maxXPForCurrentLevel ) ) )

		var currentBadge = RTKStruct_GetStruct( accountModel, "currentBadge" )
		RTKStruct_SetAssetPath( currentBadge, "badgeRuiAsset", GetAccountBadgeRuiAssetAsAsset( accountLevel ) )
		RTKStruct_SetInt( currentBadge, "tier", accountLevel )

		var nextBadge = RTKStruct_GetStruct( accountModel, "nextBadge" )
		RTKStruct_SetAssetPath( nextBadge, "badgeRuiAsset", GetAccountBadgeRuiAssetAsAsset( accountLevel + 1 ) )
		RTKStruct_SetInt( nextBadge, "tier", accountLevel + 1 )
	}
	else
	{
		ItemFlavor seasonOrRankedPeriod = GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( seasonOrRankedPeriodGUID ) )

		if ( IsSeasonFlavor( seasonOrRankedPeriod ) )
		{
			RTKStruct_SetBool( dataModelStruct, "accountProgress", false )
			RTKStruct_SetBool( dataModelStruct, "battlepassProgress", true )
			RTKStruct_SetBool( dataModelStruct, "rankedProgress", false )

			SettingsAssetGUID seasonGUID = ConvertItemFlavorGUIDStringToGUID( seasonOrRankedPeriodGUID )
			ItemFlavor season            = GetItemFlavorByGUID( seasonGUID )
			ItemFlavor battlePass        = Season_GetBattlePass( season )

			int battlePassXP        = GetPlayerBattlePassXPProgress( ToEHI( player ), battlePass )
			int battlePassLevel     = GetBattlePassLevelForXP( battlePass, battlePassXP )
			ItemFlavor bpLevelBadge = GetBattlePassProgressBadge( battlePass )

			GladCardBadgeDisplayData gcbdd = GetBadgeData( ToEHI( player ), null, 0, bpLevelBadge, battlePassLevel + 1 )
			                                                                                      

			var battlepassModel = RTKStruct_GetStruct( dataModelStruct, "battlepassModel" )
			RTKStruct_SetAssetPath( battlepassModel, "badgeRuiAsset", gcbdd.ruiAsset )
			RTKStruct_SetInt( battlepassModel, "tier", gcbdd.dataInteger )
		}
		else                 
		{
			RTKStruct_SetBool( dataModelStruct, "accountProgress", false )
			RTKStruct_SetBool( dataModelStruct, "battlepassProgress", false )
			RTKStruct_SetBool( dataModelStruct, "rankedProgress", true )

			string rankedPeriodGUID     = seasonOrRankedPeriodGUID
			ItemFlavor rankedPeriodItem = GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( rankedPeriodGUID ) )
			int rankedPeriodItemType    = ItemFlavor_GetType( rankedPeriodItem )

			Assert( rankedPeriodItemType == eItemType.ranked_2pt0_period || rankedPeriodItemType == eItemType.calevent_rankedperiod || rankedPeriodItemType == eItemType.calevent_arenas_ranked_period )

			bool hasSplits            = SharedRankedPeriod_HasSplits( rankedPeriodItem )
			bool isRankedPeriodActive = rankedPeriodGUID == GetCurrentStatRankedPeriodRefOrNullByType( rankedPeriodItemType )

			bool isDoubleBadges
			if ( !hasSplits || (isRankedPeriodActive && SharedRankedPeriod_IsFirstSplitActive( rankedPeriodItem )) )
				isDoubleBadges = false
			else
				isDoubleBadges = true

			RankData badge1Rank
			if ( isDoubleBadges )
				badge1Rank = GetRankData( player, rankedPeriodGUID, true )
			else
				badge1Rank = GetRankData( player, rankedPeriodGUID, false )

			SharedRankedDivisionData badge1Division = GetRankedDivisionData( badge1Rank.score, badge1Rank.ladderPosition, rankedPeriodGUID )

			var rankedModel = RTKStruct_GetStruct( dataModelStruct, "rankedModel" )
			RTKStruct_SetBool( rankedModel, "isDoubleBadges", isDoubleBadges )

			                                                                                       
			                                                                             
			                                                                   
			                                                                                                                 
			                                                              
			                                                                
			                                                          
			                                                    

			var badge1 = RTKStruct_GetStruct( rankedModel, "badge1" )

			if ( rankedPeriodItemType == eItemType.ranked_2pt0_period && !Ranked_HasCompletedProvisionalMatches( player ) )
			{
				int matchesCompleted = Ranked_GetNumProvisionalMatchesCompleted( player )

				RTKStruct_SetAssetPath( badge1, "badgeRuiAsset", RANKED_PLACEMENT_BADGE )
				RTKStruct_SetString( badge1, "rankedIcon", string( badge1Division.tier.icon ) )

				RTKStruct_SetInt( badge1, "emblemDisplayMode", badge1Division.emblemDisplayMode )
				RTKStruct_SetString( badge1, "emblemText", badge1Division.emblemText )

				RTKStruct_SetInt( badge1, "ladderPosition", badge1Rank.ladderPosition )
				RTKStruct_SetInt( badge1, "rankScore", badge1Rank.score )

				RTKStruct_SetString( badge1, "badgeLabel", "" )
				RTKStruct_SetBool( badge1, "isPlacementMode", true )
				RTKStruct_SetInt( badge1, "completedMatches", matchesCompleted )
				RTKStruct_SetInt( badge1, "startPip", 0 )

				var wonMatches = RTKStruct_GetArray( badge1, "wonMatches" )
				RTKArray_Clear( wonMatches )
				for ( int i = 0; i < matchesCompleted; i++ )
					RTKArray_PushBool( wonMatches, true )

				return
			}

			RTKStruct_SetAssetPath( badge1, "badgeRuiAsset", badge1Division.tier.iconRuiAsset )
			RTKStruct_SetString( badge1, "rankedIcon", string( badge1Division.tier.icon ) )

			bool isBadge1PlacementMode = rankedPeriodItemType == eItemType.calevent_arenas_ranked_period && badge1Division.tier.scoreMin == ARENAS_RANKED_PLACEMENT_SCORE
			RTKStruct_SetBool( badge1, "isPlacementMode", isBadge1PlacementMode )

			if ( isBadge1PlacementMode )
			{
				PlacementData placement = GetArenasRankedPlacementData( player, rankedPeriodItem, true )

				RTKStruct_SetInt( badge1, "completedMatches", placement.completedMatches )
				RTKStruct_SetInt( badge1, "startPip", placement.startPip )

				var wonMatches = RTKStruct_GetArray( badge1, "wonMatches" )
				RTKArray_Clear( wonMatches )
				foreach ( val in placement.wonMatches )
					RTKArray_PushBool( wonMatches, val )
			}

			RTKStruct_SetString( badge1, "badgeLabel", GetRankEmblemText( badge1Division, badge1Rank.score, badge1Rank.ladderPosition ) )

			if ( isDoubleBadges )
			{
				RankData badge2Rank = GetRankData( player, rankedPeriodGUID, false )
				SharedRankedDivisionData badge2Division = GetRankedDivisionData( badge2Rank.score, badge2Rank.ladderPosition, rankedPeriodGUID )

				var badge2 = RTKStruct_GetStruct( rankedModel, "badge2" )
				RTKStruct_SetAssetPath( badge2, "badgeRuiAsset", badge2Division.tier.iconRuiAsset )
				RTKStruct_SetString( badge2, "rankedIcon", string( badge2Division.tier.icon ) )

				bool isBadge2PlacementMode = rankedPeriodItemType == eItemType.calevent_arenas_ranked_period && badge2Division.tier.scoreMin == ARENAS_RANKED_PLACEMENT_SCORE
				RTKStruct_SetBool( badge2, "isPlacementMode", isBadge2PlacementMode )

				if ( isBadge2PlacementMode )
				{
					PlacementData placement = GetArenasRankedPlacementData( player, rankedPeriodItem, false )

					RTKStruct_SetInt( badge2, "completedMatches", placement.completedMatches )
					RTKStruct_SetInt( badge2, "startPip", placement.startPip )

					var wonMatches = RTKStruct_GetArray( badge2, "wonMatches" )
					RTKArray_Clear( wonMatches )
					foreach ( val in placement.wonMatches )
						RTKArray_PushBool( wonMatches, val )
				}

				RTKStruct_SetString( badge2, "badgeLabel", GetRankEmblemText( badge2Division, badge2Rank.score, badge2Rank.ladderPosition ) )

				RTKStruct_SetString( badge1, "splitLabel", Localize( "#RANKED_SPLIT_1" ) )
				RTKStruct_SetString( badge2, "splitLabel", Localize( "#RANKED_SPLIT_2" ) )
			}
		}
	}
}

RankData function GetRankData( entity player, string rankedPeriodGUID, bool forFirstSplit )
{
	ItemFlavor rankedPeriodItemFlavor = GetItemFlavorByGUID( ConvertItemFlavorGUIDStringToGUID( rankedPeriodGUID ) )
	int rankedPeriodItemType          = ItemFlavor_GetType( rankedPeriodItemFlavor )

	Assert( rankedPeriodItemType == eItemType.ranked_2pt0_period || rankedPeriodItemType == eItemType.calevent_rankedperiod || rankedPeriodItemType == eItemType.calevent_arenas_ranked_period )

	RankData rank
	bool isRankedPeriodActive = rankedPeriodGUID == GetCurrentStatRankedPeriodRefOrNullByType( rankedPeriodItemType )

	if ( rankedPeriodItemType == eItemType.ranked_2pt0_period || rankedPeriodItemType == eItemType.calevent_rankedperiod )
	{
		var settingBlockForPeriod = ItemFlavor_GetSettingsBlock( rankedPeriodItemFlavor )
		bool rewardOnHighestWatermark = GetSettingsBlockBool( settingBlockForPeriod, "rewardOnHighestWatermark" )

		if ( forFirstSplit )
		{
			rank.score          = Ranked_GetHistoricalFirstSplitRankScore( player, rankedPeriodGUID, rewardOnHighestWatermark )
			rank.ladderPosition = Ranked_GetHistoricalLadderPosition( player, rankedPeriodGUID, forFirstSplit )
		}
		else
		{
			rank.score = Ranked_GetHistoricalRankScore( player, rankedPeriodGUID, rewardOnHighestWatermark )

			if ( isRankedPeriodActive )
				rank.ladderPosition = Ranked_GetLadderPosition( player )
			else
				rank.ladderPosition = Ranked_GetHistoricalLadderPosition( player, rankedPeriodGUID, forFirstSplit )
		}
	}
	else                                           
	{
		if ( forFirstSplit )
		{
			rank.score          = ArenasRanked_GetHistoricalFirstSplitRankScore( player, rankedPeriodGUID )
			rank.ladderPosition = ArenasRanked_GetHistoricalLadderPosition( player, rankedPeriodGUID, forFirstSplit )
		}
		else
		{
			rank.score = ArenasRanked_GetHistoricalRankScore( player, rankedPeriodGUID )

			if ( isRankedPeriodActive )
				rank.ladderPosition = ArenasRanked_GetLadderPosition( player )
			else
				rank.ladderPosition = ArenasRanked_GetHistoricalLadderPosition( player, rankedPeriodGUID, forFirstSplit )
		}
	}

	return rank
}

PlacementData function GetArenasRankedPlacementData( entity player, ItemFlavor rankedPeriodItem, bool forFirstSplit )
{
	PlacementData placement
	placement.completedMatches = ArenasRanked_GetNumPlacementMatchesCompleted( player )
	placement.wonMatches       = ArenasRanked_GetPlacementWinsAsArray( player )
	placement.startPip         = 0

	if ( SharedRankedPeriod_HasSplits( rankedPeriodItem ) && !forFirstSplit && SharedRankedPeriod_IsSecondSplitActive( rankedPeriodItem ) )
	{
		placement.completedMatches += ARENAS_RANKED_NUM_PLACEMENT_MATCHES - ARENAS_RANKED_SPLIT_NUM_PLACEMENT_MATCHES
		placement.startPip = ARENAS_RANKED_NUM_PLACEMENT_MATCHES - ARENAS_RANKED_SPLIT_NUM_PLACEMENT_MATCHES
	}

	                                                                                                                                                                       
	                                                                                                                      
	                                                                                                                                                                           
	                                                        
	                                                                  
	  	                              

	return placement
}

void function RTKStatsScreenController_OnModeChanged( rtk_behavior self, int newMode )
{
	Assert( newMode == eStatCardGameMode.BATTLE_ROYALE || newMode == eStatCardGameMode.ARENAS )
	self.rtkprops.mode = newMode

	rtk_behavior leftButtonLabel = self.PropGetBehavior( "leftButtonLabel" )
	leftButtonLabel.rtkprops.text = Localize( StatsCard_GetNameOfGameMode( newMode ) )

	RTKStatsScreenController_UpdateRightDropDown( self )
	RTKStatsScreenController_Refresh( self )
}

void function RTKStatsScreenController_OnSeasonChanged( rtk_behavior self, string newSeasonGUID, string newSeasonLabel )
{
	self.rtkprops.seasonGUID = newSeasonGUID

	rtk_behavior rightButtonLabel = self.PropGetBehavior( "rightButtonLabel" )
	rightButtonLabel.rtkprops.text = newSeasonLabel

	RTKStatsScreenController_Refresh( self )
}

void function RTKStatsScreenController_OnInitialize( rtk_behavior self )
{
	string profileString = GetProfileString()
	RTKDataModel_SetString( "&menus.statsScreen.profile", profileString )

	rtk_behavior ornull decorationAnimator = expect rtk_behavior ornull( self.rtkprops.decorationAnimator )
	if ( decorationAnimator )
	{
		expect rtk_behavior( decorationAnimator )
		string anim = "SlideIn"

		if ( RTKAnimator_HasAnimation( decorationAnimator, anim ) )
			RTKAnimator_PlayAnimation( decorationAnimator, anim )
	}

	int mode = eStatCardGameMode.BATTLE_ROYALE
	self.rtkprops.mode = mode

	array<ItemFlavor> seasons = StatCard_GetAvailableSeasons( mode )
	Assert( seasons.len() > 0 )
	ItemFlavor initalSeasonItem = seasons[seasons.len() - 1]
	self.rtkprops.seasonGUID = ItemFlavor_GetGUIDString( initalSeasonItem )

	RTKStatsScreenController_UpdateLeftDropDown( self )
	RTKStatsScreenController_UpdateRightDropDown( self )
	                                                                                                              

	rtk_behavior leftButtonTooltip = self.PropGetBehavior( "leftButtonTooltip" )
	leftButtonTooltip.rtkprops.textContent = Localize( "#STATS_TOOLTIP_SELECT_MODE" )

	rtk_behavior rightButtonTooltip = self.PropGetBehavior( "rightButtonTooltip" )
	rightButtonTooltip.rtkprops.textContent = Localize( "#STATS_TOOLTIP_SELECT_SEASON" )

	PrivateData p
	self.Private( p )

	rtk_behavior leftDropDown = self.PropGetBehavior( "leftDropDown" )
	p.leftDropDownOnItemPressedEventID = leftDropDown.AddEventListener( "onItemPressed", function ( rtk_behavior button, int index ) : ( self )
	{
		RTKStatsScreenController_OnModeChanged( self, index )
	} )

	rtk_behavior rightDropDown = self.PropGetBehavior( "rightDropDown" )
	p.rightDropDownOnItemPressedEventID = rightDropDown.AddEventListener( "onItemPressed", function ( rtk_behavior button, int index ) : ( self )
	{
		int mode = self.PropGetInt( "mode" )
		Assert( mode == eStatCardGameMode.BATTLE_ROYALE || mode == eStatCardGameMode.ARENAS )

		var seasonOptions  = RTKDataModel_GetArray( "&menus.statsScreen.seasonOptions" )
		var seasonData     = RTKArray_GetStruct( seasonOptions, index )
		string seasonGUID  = RTKStruct_GetString( seasonData, "guid" )
		string seasonLabel = RTKStruct_GetString( seasonData, "label" )

		RTKStatsScreenController_OnSeasonChanged( self, seasonGUID, seasonLabel )
	} )

	int menuGUID = AssignMenuGUID()
	p.menuGUID = menuGUID
	                                                                                                                                    
	                                                                                                                                                                          
	RTKFooters_Add( menuGUID, LEFT, BUTTON_B, "#B_BUTTON_BACK", BUTTON_INVALID, "#B_BUTTON_BACK", PCBackButton_Activate )
	#if NX_PROG
		RTKFooters_Add( menuGUID, LEFT, BUTTON_Y, "#Y_BUTTON_USER_PAGE", BUTTON_INVALID, "#USER_PAGE", OnViewProfile, ViewProfileAllowed )
	#else
		RTKFooters_Add( menuGUID, LEFT, BUTTON_Y, "#Y_BUTTON_VIEW_PROFILE", BUTTON_INVALID, "#VIEW_PROFILE", OnViewProfile, ViewProfileAllowed )
	#endif
	RTKFooters_Add( menuGUID, LEFT, BUTTON_X, "#X_BUTTON_UNFRIEND_EA_FRIEND", BUTTON_INVALID, "#UNFRIEND_EA_FRIEND", OnPlayerUnfriend, IsPlayerEADPFriend )
	RTKFooters_Add( menuGUID, LEFT, BUTTON_X, "#X_BUTTON_SEND_FRIEND_REQUEST", BUTTON_INVALID, "#SEND_FRIEND_REQUEST", OnPlayerSendFriendRequest, CanSendEADPFriendRequest )

	RTKFooters_Add( menuGUID, RIGHT, BUTTON_STICK_LEFT, "#LAST_SQUAD_BUTTON_CLUB_INVITE", BUTTON_INVALID, "#CLUB_INVITE_NO_KEY", OnClubSendInvite, CanSendClubInvite )
	RTKFooters_Add( menuGUID, RIGHT, BUTTON_STICK_RIGHT, "#BUTTON_REPORT_PLAYER", BUTTON_INVALID, "#REPORT_PLAYER_SHORT", OnUserReport, CanReportUser )
	RTKFooters_Update()

	RTKStatsScreenController_Refresh( self )
}

void function RTKStatsScreenController_OnDestroy( rtk_behavior self )
{
	PrivateData p
	self.Private( p )

	if ( p.leftDropDownOnItemPressedEventID != RTKEVENT_INVALID )
	{
		rtk_behavior leftDropDown = self.PropGetBehavior( "leftDropDown" )
		leftDropDown.RemoveEventListener( "onItemPressed", p.leftDropDownOnItemPressedEventID )
		p.leftDropDownOnItemPressedEventID = RTKEVENT_INVALID
	}

	if ( p.rightDropDownOnItemPressedEventID != RTKEVENT_INVALID )
	{
		rtk_behavior rightDropDown = self.PropGetBehavior( "rightDropDown" )
		rightDropDown.RemoveEventListener( "onItemPressed", p.rightDropDownOnItemPressedEventID )
		p.rightDropDownOnItemPressedEventID = RTKEVENT_INVALID
	}

	RTKFooters_RemoveAll( p.menuGUID )
	RTKFooters_Update()
}

void function RTKStatsScreenController_UpdateLeftDropDown( rtk_behavior self )
{
	var modeOptions = RTKDataModel_GetArray( "&menus.statsScreen.modeOptions" )

	if ( RTKArray_GetCount( modeOptions ) > 0 )
		RTKArray_Clear( modeOptions )

	for ( int i = 0; i < eStatCardGameMode._count; ++i )
	{
		var modeData = RTKArray_PushNewStruct( modeOptions )
		string label = Localize( StatsCard_GetNameOfGameMode( i ) )
		RTKStruct_SetString( modeData, "label", label )

		if ( i == 0 )
		{
			rtk_behavior leftButtonLabel = self.PropGetBehavior( "leftButtonLabel" )
			leftButtonLabel.rtkprops.text = label
		}
	}
}

void function RTKStatsScreenController_UpdateRightDropDown( rtk_behavior self )
{
	int mode                      = self.PropGetInt( "mode" )
	rtk_behavior rightButtonLabel = self.PropGetBehavior( "rightButtonLabel" )
	Assert( mode == eStatCardGameMode.BATTLE_ROYALE || mode == eStatCardGameMode.ARENAS )

	string seasonGUID         = self.PropGetString( "seasonGUID" )
	var seasonOptions         = RTKDataModel_GetArray( "&menus.statsScreen.seasonOptions" )
	array<ItemFlavor> seasons = StatCard_GetAvailableSeasonsAndRankedPeriods( mode )
	Assert( seasons.len() > 0 )

	if ( RTKArray_GetCount( seasonOptions ) > 0 )
		RTKArray_Clear( seasonOptions )

	string selectedLabel = ""
	string selectedGUID = ""

	foreach ( int index, ItemFlavor season in seasons )
	{
		var seasonData = RTKArray_PushNewStruct( seasonOptions )
		string label   = Localize( ItemFlavor_GetLongName( season ) )
		string guid    = ItemFlavor_GetGUIDString( season )

		RTKStruct_SetString( seasonData, "label", label )
		RTKStruct_SetString( seasonData, "guid", guid )

		if ( index == 0 )
		{
			selectedLabel = label
			selectedGUID = guid
		}
		else if ( seasonGUID == guid )
		{
			selectedLabel = label
			selectedGUID = guid
		}
	}

	if ( seasonGUID != selectedGUID )
		self.rtkprops.seasonGUID = selectedGUID

	rightButtonLabel.rtkprops.text = selectedLabel
}

void function RTKStatsScreenController_Refresh( rtk_behavior self )
{
	int mode = self.PropGetInt( "mode" )
	Assert( mode == eStatCardGameMode.BATTLE_ROYALE || mode == eStatCardGameMode.ARENAS )

	var leftPanelModel = RTKDataModel_GetStruct( "&menus.statsScreen.leftPanelModel" )
	var rightPanelModel = RTKDataModel_GetStruct( "&menus.statsScreen.rightPanelModel" )

	SetStatsData( leftPanelModel, mode, "" )
	SetStatsData( rightPanelModel, mode, self.PropGetString( "seasonGUID" ) )
}


