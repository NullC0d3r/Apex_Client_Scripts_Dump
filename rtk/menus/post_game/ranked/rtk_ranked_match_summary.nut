global function RTKRankedMatchSummary_OnInitialize
global function RTKRankedMatchSummary_OnDestroy
global function BuildRankedMatchSummaryDataModel


global struct BonusBreakdownInfo
{
	string bonusName 	 = ""
	int bonusValue 		 = 0
}

global struct ConditionalElement
{
	string 	stringL = ""
	int 	stringR = 0
	vector 	colorL = <1.0, 1.0, 1.0>
	vector 	colorR = <1.0, 1.0, 1.0>
	vector	bgColor = <0.16, 0.16, 0.16>
}

global struct RankedMatchSummaryExtraInfo
{
	int entryCost = 0
	int totalBonus = 0
	array< BonusBreakdownInfo > breakdownBonuses = []
	array< ConditionalElement > conditionals = []
}

void function RTKRankedMatchSummary_OnInitialize(rtk_behavior self)
{
	BuildRankedMatchSummaryDataModel()

	self.GetPanel().SetBindingRootPath( RTKDataModelType_GetDataPath( RTK_MODELTYPE_MENUS, "ranked", true, [ "postGame" ] ) )
}

void function RTKRankedMatchSummary_OnDestroy( rtk_behavior self )
{
	RTKDataModelType_DestroyStruct( RTK_MODELTYPE_MENUS, "ranked", ["postGame"] )
}

void function BuildRankedMatchSummaryDataModel()
{
	var rankedMatchSummary = RTKDataModelType_CreateStruct( RTK_MODELTYPE_MENUS, "ranked", "", [ "postGame" ] )

	entity player = GetLocalClientPlayer()

	RankLadderPointsBreakdown scoreBreakdown
	LoadLPBreakdownFromPersistance ( scoreBreakdown, player )

	RankedMatchSummaryExtraInfo extraInfo

	extraInfo.entryCost = ( GetConVarBool( "ranked_disable_point_gain" ) ) ? 0 : -1 * Ranked_GetCostForEntry()
	extraInfo.totalBonus = 0

	                                             
	if (scoreBreakdown.killBonus > 0)
	{
		BonusBreakdownInfo tempBonusBreakdownInfo
		tempBonusBreakdownInfo.bonusName	= "#RANKED_ELIMINATION_BONUS"
		tempBonusBreakdownInfo.bonusValue	= scoreBreakdown.killBonus
		extraInfo.totalBonus				+= scoreBreakdown.killBonus
		extraInfo.breakdownBonuses.push(tempBonusBreakdownInfo)
	}

	if (scoreBreakdown.convergenceBonus > 0)
	{
		BonusBreakdownInfo tempBonusBreakdownInfo
		tempBonusBreakdownInfo.bonusName	= "#RANKED_RATING_BONUS"
		tempBonusBreakdownInfo.bonusValue	= scoreBreakdown.convergenceBonus
		extraInfo.totalBonus				+= scoreBreakdown.convergenceBonus
		extraInfo.breakdownBonuses.push(tempBonusBreakdownInfo)
	}

	if (scoreBreakdown.skillDiffBonus > 0)
	{
		BonusBreakdownInfo tempBonusBreakdownInfo
		tempBonusBreakdownInfo.bonusName	= "#RANKED_SKILL_BONUS"
		tempBonusBreakdownInfo.bonusValue	= scoreBreakdown.skillDiffBonus
		extraInfo.totalBonus				+= scoreBreakdown.skillDiffBonus
		extraInfo.breakdownBonuses.push(tempBonusBreakdownInfo)
	}

	if (scoreBreakdown.provisionalMatchBonus > 0)
	{
		BonusBreakdownInfo tempBonusBreakdownInfo
		tempBonusBreakdownInfo.bonusName	= "#RANKED_PROVISIONAL_BONUS"
		tempBonusBreakdownInfo.bonusValue	= scoreBreakdown.provisionalMatchBonus
		extraInfo.totalBonus				+= scoreBreakdown.provisionalMatchBonus
		extraInfo.breakdownBonuses.push(tempBonusBreakdownInfo)
	}

	if (scoreBreakdown.promotionBonus > 0)
	{
		BonusBreakdownInfo tempBonusBreakdownInfo
		tempBonusBreakdownInfo.bonusName	= "#RANKED_TIER_PROMOTION_BONUS"
		tempBonusBreakdownInfo.bonusValue	= scoreBreakdown.promotionBonus
		extraInfo.totalBonus				+= scoreBreakdown.promotionBonus
		extraInfo.breakdownBonuses.push(tempBonusBreakdownInfo)
	}

	                                         
	if (scoreBreakdown.penaltyPointsForAbandoning > 0)
	{
		ConditionalElement tempCondEle
		tempCondEle.stringL	= "#RANKED_ABANDON_PENALTY"
		tempCondEle.stringR	= scoreBreakdown.penaltyPointsForAbandoning * -1
		tempCondEle.colorL	= <1, 0.26, 0.26>
		tempCondEle.colorR	= <1, 0.26, 0.26>
		extraInfo.conditionals.push(tempCondEle)
	}

	if (scoreBreakdown.lossProtectionAdjustment > 0)
	{
		ConditionalElement tempCondEle
		tempCondEle.stringL	= "#RANKED_LOSS_FORGIVENESS"
		tempCondEle.stringR	= scoreBreakdown.lossProtectionAdjustment
		extraInfo.conditionals.push(tempCondEle)
	}

	if (scoreBreakdown.demotionPenality > 0)
	{
		ConditionalElement tempCondEle
		tempCondEle.stringL	= "#RANKED_TIER_DERANKING"
		tempCondEle.stringR	= scoreBreakdown.demotionPenality * -1
		tempCondEle.colorL	= <1, 0.26, 0.26>
		tempCondEle.colorR	= <1, 0.26, 0.26>
		extraInfo.conditionals.push(tempCondEle)
	}

	if (scoreBreakdown.demotionProtectionAdjustment > 0)
	{
		ConditionalElement tempCondEle
		tempCondEle.stringL	= "#RANKED_DEMOTION_PROTECTION_LINE2"
		tempCondEle.stringR	= scoreBreakdown.demotionProtectionAdjustment
		extraInfo.conditionals.push(tempCondEle)
	}

	foreach(int index, conditional in extraInfo.conditionals)
	{
		if ( index % 2 == 0 )
			conditional.bgColor = <0.16, 0.16, 0.16>
		else
			conditional.bgColor = <0.35, 0.35, 0.35>
	}

	var summaryBreakdownStruct = RTKStruct_GetOrCreateScriptStruct(rankedMatchSummary, "breakdown", "RankLadderPointsBreakdown")
	var summaryExtraInfoStruct = RTKStruct_GetOrCreateScriptStruct(rankedMatchSummary, "extraInfo", "RankedMatchSummaryExtraInfo")

	RTKStruct_SetValue( summaryBreakdownStruct, scoreBreakdown )
	RTKStruct_SetValue( summaryExtraInfoStruct,  extraInfo )
}

