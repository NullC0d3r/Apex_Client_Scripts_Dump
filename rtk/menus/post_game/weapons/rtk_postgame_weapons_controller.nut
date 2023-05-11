global function InitRTKPostGameWeaponsPanel
global function RTKPostGameWeaponsPanel_OnInitialize
global function RTKPostGameWeaponsPanel_OnDestroy

global struct MasteryXpChangesActionsModel
{
	int index = 0
	string action = ""
	int xp = 0
}

global struct PostGameMasteryXpChangesModel
{
	int index = 0
	string name = ""
	string id = ""

	int lastXP = 0
	int lastLevel = 0
	int currentXP = 0
	int currentLevel = 0
	int xpChange = 0

	bool leveledUp = false

	array< MasteryXpChangesActionsModel > actions = []
}

global struct PostGameWeaponMasteryModel
{
	bool hasXpChanges 	 = false
	bool hasTrialChanges = false
}

global struct PostGameWeaponMasteryTrialsChangedModel
{
	string id = ""

	int totalUpdated = 0
	int totalRewards = 0

	array< MasteryWeapon_ChangedTrial > changedTrials
	array< MasteryWeapon_TrialQueryResult > allTrials

	string name = ""
	asset icon = $""

	string tooltipTitle = ""

	int totalTrials = 0
	int trialsCompleted = 0
	int trialsUnlocked = 0
}

struct PrivateData
{

}

void function RTKPostGameWeaponsPanel_OnInitialize( rtk_behavior self )
{
	var postGameWeaponModel = RTKDataModelType_CreateStruct( RTK_MODELTYPE_MENUS, "weapons", "", [ "postGame" ] )

	BuildWeaponXPDataModel( self, postGameWeaponModel )
	BuildWeaponTrialsDataModel( self, postGameWeaponModel )

	self.GetPanel().SetBindingRootPath( RTKDataModelType_GetDataPath( RTK_MODELTYPE_MENUS, "weapons", true, [ "postGame" ] ) )
}

void function BuildWeaponXPDataModel(  rtk_behavior self, var postGameWeaponModel  )
{
	array< PostGameMasteryXpChangesModel > weaponXpChanges = []


	table<ItemFlavor, MasteryWeapon_MatchXPPerWeapon> matchXPResult = Mastery_GetPreviousMatchXPUpdates()
	foreach ( weapon, matchXP in matchXPResult )
	{
		PostGameMasteryXpChangesModel weaponXp

		weaponXp.id           = WeaponItemFlavor_GetClassname( weapon )
		weaponXp.name         = ItemFlavor_GetShortName( weapon )
		weaponXp.lastXP       = matchXP.lastXP
		weaponXp.lastLevel    = Mastery_CalculateLevelFromXP( matchXP.lastXP )
		weaponXp.currentXP    = matchXP.currentXP
		weaponXp.currentLevel = Mastery_CalculateLevelFromXP( matchXP.currentXP )
		weaponXp.xpChange     = weaponXp.currentXP - weaponXp.lastXP
		weaponXp.leveledUp 	  = weaponXp.lastLevel < weaponXp.currentLevel

		array< MasteryXpChangesActionsModel > xpChangesActions = []
		int actionXPIndex = 0

		foreach ( actionType, actionXP in matchXP.actionXPMap )
		{
			MasteryXpChangesActionsModel xpChangesAction
			xpChangesAction.index = actionXPIndex
			xpChangesAction.action = actionXP.actionText
			xpChangesAction.xp = actionXP.xpValue
			actionXPIndex++

			xpChangesActions.push( xpChangesAction )
		}

		weaponXp.actions = xpChangesActions
		weaponXpChanges.push( weaponXp )

	}

	weaponXpChanges.sort( PostGame_SortXpChanges )


	int index = 0
	foreach( PostGameMasteryXpChangesModel weaponXp in weaponXpChanges )
	{
		weaponXp.index = index
		index++
	}


	var xpChangesModel = RTKStruct_GetOrCreateScriptArrayOfStructs( postGameWeaponModel, "xpChanges", "PostGameMasteryXpChangesModel" )
	RTKArray_SetValue( xpChangesModel, weaponXpChanges )

	var overviewStruct = RTKStruct_GetOrCreateScriptStruct(postGameWeaponModel, "overview", "PostGameWeaponMasteryModel")
	RTKStruct_SetBool( overviewStruct, "hasXpChanges", weaponXpChanges.len() > 0 )
}

void function BuildWeaponTrialsDataModel(  rtk_behavior self, var postGameWeaponModel  )
{
	table<ItemFlavor, MasteryWeapon_MatchTrialPerWeapon>  matchTrialResult = Mastery_GetPreviousMatchTrialUpdates()
	array<PostGameWeaponMasteryTrialsChangedModel> changedTrials           = []
	array<MasteryWeapon_TrialQueryResult> ornull allTrials                 = []

	foreach ( weapon, matchTrial in matchTrialResult )
	{
		PostGameWeaponMasteryTrialsChangedModel weaponTrials

		weaponTrials.id = WeaponItemFlavor_GetClassname( weapon )
		weaponTrials.totalUpdated = matchTrial.changedTrialList.len()
		weaponTrials.icon = WeaponItemFlavor_GetHudIcon( weapon )
		weaponTrials.name = ItemFlavor_GetShortName( weapon )

		weaponTrials.changedTrials = matchTrial.changedTrialList

		                                                                      
		matchTrial.changedTrialList.sort( PostGame_SortChangedTrial )

		                                                                     
		int rewardsRecieved = 0
		foreach( trial in matchTrial.changedTrialList )
		{
			if( trial.isComplete )
				rewardsRecieved += trial.trialConfig.rewards.len()
		}
		weaponTrials.totalRewards = rewardsRecieved

		                                                                                                              
		allTrials = Mastery_GetWeaponTrialList( weapon )
		if( allTrials != null )
		{
			expect array<MasteryWeapon_TrialQueryResult>( allTrials )
			allTrials.sort( Mastery_SortTrialQueryResult )

			int totalCompleted = 0
			int totalUnlocked = 0

			foreach( MasteryWeapon_TrialQueryResult trial in allTrials )
			{
				if( trial.trialData.isCompleted )
					totalCompleted++

				if( trial.trialData.isUnlocked )
					totalUnlocked++
			}
			weaponTrials.trialsCompleted = totalCompleted
			weaponTrials.trialsUnlocked = totalUnlocked

			weaponTrials.allTrials = allTrials
		}

		weaponTrials.totalTrials = weaponTrials.allTrials.len()
		weaponTrials.tooltipTitle = Localize( "#MASTERY_WEAPONS_TRIALS_TOOLTIP", Localize( weaponTrials.name ), weaponTrials.trialsCompleted, weaponTrials.totalTrials )

		changedTrials.push( weaponTrials )
	}

	var postGameTrialsModel = RTKStruct_GetOrCreateScriptArrayOfStructs(postGameWeaponModel, "trials", "PostGameWeaponMasteryTrialsChangedModel")
	RTKArray_SetValue( postGameTrialsModel, changedTrials )

	var overviewStruct = RTKStruct_GetOrCreateScriptStruct(postGameWeaponModel, "overview", "PostGameWeaponMasteryModel")
	RTKStruct_SetBool( overviewStruct, "hasTrialChanges", changedTrials.len() > 0 )
}

void function RTKPostGameWeaponsPanel_OnDestroy( rtk_behavior self )
{
	RTKDataModelType_DestroyStruct( RTK_MODELTYPE_MENUS, "weapons", ["postGame"] )
}

void function InitRTKPostGameWeaponsPanel( var panel )
{
	                                                                                         
}

int function PostGame_SortChangedTrial( MasteryWeapon_ChangedTrial a, MasteryWeapon_ChangedTrial b )
{
	if ( a.isComplete && !b.isComplete )
		return -1
	if ( b.isComplete && !a.isComplete )
		return 1

	int aChange = a.currentValue - a.lastValue
	int bChange = b.currentValue - b.lastValue

	if ( aChange < bChange )
		return -1
	if ( bChange < aChange )
		return 1

	return 0
}

int function PostGame_SortXpChanges( PostGameMasteryXpChangesModel a, PostGameMasteryXpChangesModel b )
{
	if ( a.xpChange < b.xpChange )
		return 1
	if ( b.xpChange < a.xpChange )
		return -1

	if ( a.leveledUp && !b.leveledUp )
		return -1
	if ( b.leveledUp && !a.leveledUp )
		return 1

	return 0
}