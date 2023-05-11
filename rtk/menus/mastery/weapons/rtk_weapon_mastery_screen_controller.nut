global function RTKWeaponMasteryScreen_InitializeDataModelThread
global function RTKWeaponMasteryScreen_OnInitialize
global function RTKWeaponMasteryScreen_OnDestroy
global function InitRTKWeaponMasteryPanel

global function RTKMutator_PositionXPNotch

global struct RTKWeaponMasteryScreen_Properties
{
	rtk_behavior trialButton
}

global const string FEATURE_WEAPON_MASTERY_TUTORIAL = "weapon_mastery"
int MASTERY_RANGE_PER_LEVEL = 5

global struct RTKWeaponOverallModel
{
	string weaponId
	string name = ""
	asset icon = $""
	int level = 0
	int	xp = 0
	float progress = 0.0

	int totalTrials = 0
	int trialsCompleted = 0

	int trialsUnlocked = 0
	int nextTrialUnlockedAt = 0
	bool unlockedAllTrials = false
	bool completedAllTrials = false
}

global struct RTKWeaponStatsModel
{
	int kills
	int hits
	int shots
	float accuracy
	int damageDone
	int headshots
	int knocks
}

global struct RTKWeaponMasteryScreenLevelRange
{
	float progress = 0.0

	int	startLevel = 0
	int	endLevel = 0

	bool isLast = false

	int currentLevel = 0
	float currentLevelFrac = 0.0
	int xpToNextlevel = 0
	bool showLargeXpNotch = false
}

global struct RTKWeaponMasteryOverall
{
	int level = 0
}

struct PrivateData
{
	string rootCommonPath = ""
	array< string > weaponIds
}

struct
{
	string          weaponId = ""
} file


void function RTKWeaponMasteryScreen_InitMetaData( string behaviorType, string structType )
{
	RTKMetaData_SetAllowedBehaviorTypes( structType, "trialButton", [ "Button" ] )
}

void function RTKWeaponMasteryScreen_OnInitialize( rtk_behavior self )
{
	PrivateData p
	self.Private( p )

	UI_SetPresentationType( ePresentationType.WEAPON_OVERVIEW )

	rtk_behavior ornull trialButton = self.PropGetBehavior( "trialButton" )

	if ( trialButton != null )
	{
		expect rtk_behavior( trialButton )
		self.AutoSubscribe( trialButton, "onPressed", function( rtk_behavior button, int keycode, int prevState ) : ( self ) {
			WeaponMasteryTrials_Activate( null )
		} )
	}

	p.weaponIds.clear()
	foreach ( weapon in GetAllWeaponItemFlavors() )
	{
		p.weaponIds.push( WeaponItemFlavor_GetClassname( weapon ) )
	}

	p.rootCommonPath = RTKDataModelType_GetDataPath( RTK_MODELTYPE_COMMON, "mastery", true, [ "weapons" ] )
	ItemFlavor ornull weaponOrNull = GetScreenActiveWeapon()
	if ( weaponOrNull != null )
	{
		expect ItemFlavor( weaponOrNull )

		file.weaponId = WeaponItemFlavor_GetClassname(weaponOrNull )
		self.GetPanel().SetBindingRootPath( p.rootCommonPath + "." + file.weaponId )
		ItemFlavor ornull weaponSkinOrNull

		if ( LoadoutSlot_IsReady( LocalClientEHI(), Loadout_WeaponSkin( weaponOrNull  ) ) )
			weaponSkinOrNull = LoadoutSlot_GetItemFlavor( LocalClientEHI(), Loadout_WeaponSkin( weaponOrNull ) )

		if( weaponSkinOrNull != null )
		{
			expect ItemFlavor( weaponSkinOrNull )
			RunClientScript( "UIToClient_OverviewWeapon", ItemFlavor_GetGUID( weaponSkinOrNull ) )
		}

		UpdateScreenData( self )
	}

	int menuGUID = AssignMenuGUID()

	UpdateFooterOptions()
}

void function RTKWeaponMasteryScreen_OnDestroy( rtk_behavior self )
{
	RTKDataModelType_DestroyStruct( RTK_MODELTYPE_MENUS, "weaponMastery" )
}

void function UpdateScreenData( rtk_behavior self )
{
	var screenWeaponMastery = RTKDataModelType_CreateStruct( RTK_MODELTYPE_MENUS, "weaponMastery" )

	                                                                     
	UpdateScreenData_SelectedWeapon( self, screenWeaponMastery )
}

void function UpdateScreenData_SelectedWeapon( rtk_behavior self, var screenWeaponMastery )
{
	PrivateData p
	self.Private( p )

	int weaponLevel = 1
	int weaponXP = 1

	ItemFlavor ornull weaponOrNull = GetScreenActiveWeapon()
	if ( weaponOrNull != null )
	{
		expect ItemFlavor( weaponOrNull )
		string weaponId        = WeaponItemFlavor_GetClassname(weaponOrNull )
		var weaponOverallModel = RTKDataModel_GetStruct( p.rootCommonPath + "." + weaponId + ".overall" )
		weaponLevel             = RTKStruct_GetInt( weaponOverallModel, "level" )
		weaponXP                = RTKStruct_GetInt( weaponOverallModel, "xp" )
	}

	RunClientScript( "UIToClient_SetWeaponsOverviewBackgroundSkin", WeaponMastery_GetSmokeColor( weaponLevel ) )

	{
		array< RTKWeaponMasteryScreenLevelRange > levelRanges

		int NUM_RANGES = 4
		int totalRange = ( MASTERY_RANGE_PER_LEVEL * NUM_RANGES )

		int startRangeLevel = (int( floor( weaponLevel / totalRange ) ) * totalRange )

		int xpNeededForLevel = Mastery_GetTotalXPToCompleteWeaponLevel( weaponLevel )
		int xpNeededForCurrentLevel = Mastery_GetTotalXPToCompleteWeaponLevel( weaponLevel - 1 )

		int xpToNextLevel = int( max( xpNeededForLevel - weaponXP, 0 ) )

		float totalXPGainedForLevel = float( weaponXP ) - float( xpNeededForCurrentLevel )                                                 
		float currentLevelFrac = totalXPGainedForLevel / float( xpNeededForLevel - xpNeededForCurrentLevel )

		for ( int i = 0; i < NUM_RANGES ; i++ )
		{
			RTKWeaponMasteryScreenLevelRange range

			if( i == 0 )
			{
				range.startLevel = int( max( startRangeLevel + ( i * ( MASTERY_RANGE_PER_LEVEL - 1 ) ), 1) )
				range.progress = float( ( weaponLevel - range.startLevel ) ) / float( MASTERY_RANGE_PER_LEVEL - 1 )
			}
			else
			{
				range.startLevel = startRangeLevel + ( i * MASTERY_RANGE_PER_LEVEL )
				range.progress = float( ( weaponLevel - range.startLevel ) ) / float( MASTERY_RANGE_PER_LEVEL )
			}

			range.endLevel = startRangeLevel + ( ( i + 1 ) * MASTERY_RANGE_PER_LEVEL )
			range.isLast = i == NUM_RANGES - 1
			range.xpToNextlevel = xpToNextLevel
			range.currentLevelFrac = currentLevelFrac
			range.showLargeXpNotch = range.endLevel > weaponLevel && range.startLevel <= weaponLevel
			range.currentLevel = weaponLevel

			levelRanges.push( range )
		}

		var weaponMasteryLevelRangessArray = RTKStruct_AddArrayOfStructsProperty( screenWeaponMastery, "levelRanges", "RTKWeaponMasteryScreenLevelRange" )
		RTKArray_SetValue( weaponMasteryLevelRangessArray, levelRanges )
	}
}

ItemFlavor ornull function GetScreenActiveWeapon()
{
	return CategoryWeaponPanel_GetWeapon(  _GetActiveTabPanel( GetActiveMenu() )  )
}

void function PostGameFlow_Activate( var button )
{
	if ( IsPostGameMenuValid() )
	{
		PostGameFlow()
	}
}

void function WeaponMasteryTrials_Activate( var button )
{
	RTKWeaponMasteryTrialsScreen_SetWeapon( file.weaponId )
	AdvanceMenu( GetMenu( "WeaponMasteryTrialsMenu" ) )
}

  
                               
   

void function RTKWeaponMasteryScreen_InitializeDataModelThread()
{
	var weaponMastery              = RTKDataModelType_CreateStruct( RTK_MODELTYPE_COMMON, "mastery", "", [ "weapons" ] )
	var weaponMasteryOverallStruct = RTKStruct_GetOrCreateScriptStruct( weaponMastery, "overall", "RTKWeaponMasteryOverall" )

	int totalMasteryLevel = 0

	var allWeaponTrialsArray = RTKStruct_AddArrayOfStructsProperty( weaponMastery, "allWeaponsTrials", "MasteryWeapon_FinalRewardResult" )
	array< MasteryWeapon_FinalRewardResult > AllWeaponsTrials = [ Mastery_GetAllWeaponReward() ]
	RTKArray_SetValue( allWeaponTrialsArray, AllWeaponsTrials )

	foreach ( weapon in GetAllWeaponItemFlavors() )
	{
		array<MasteryWeapon_TrialQueryResult> ornull trialResultList = Mastery_GetWeaponTrialList( weapon )
		string weaponId                                              = WeaponItemFlavor_GetClassname( weapon )
		var weaponStruct                                             = RTKStruct_GetOrCreateEmptyStruct( weaponMastery, weaponId )

		var overallStruct           = RTKStruct_GetOrCreateScriptStruct( weaponStruct, "overall", "RTKWeaponOverallModel" )
		var statsStruct             = RTKStruct_GetOrCreateScriptStruct( weaponStruct, "stats", "RTKWeaponStatsModel" )
		var weaponTrialsArray       = RTKStruct_AddArrayOfStructsProperty( weaponStruct, "trials", "MasteryWeapon_TrialQueryResult" )
		var weaponBonusTrialsArray  = RTKStruct_AddArrayOfStructsProperty( weaponStruct, "bonusTrials", "MasteryWeapon_TrialQueryResult" )
		var weaponSortedTrialsArray = RTKStruct_AddArrayOfStructsProperty( weaponStruct, "sortedTrials", "MasteryWeapon_TrialQueryResult" )

		int weaponXP = Mastery_GetWeaponXP( weapon )
		int weaponLevel = Mastery_GetWeaponLevel( weapon )
		int weaponXPToComplete = Mastery_GetTotalXPToCompleteWeaponLevel( weaponLevel )
		int prevWeaponXPToComplete = Mastery_GetTotalXPToCompleteWeaponLevel( weaponLevel - 1 )
		int xpNeededForLevel = weaponXPToComplete - prevWeaponXPToComplete
		int xpToNextLevel = int( max( weaponXPToComplete - weaponXP, 0 ) )
		float progress = ( weaponLevel == 1 )? float( weaponXP / weaponXPToComplete )  : ( float( xpNeededForLevel - xpToNextLevel ) / float( xpNeededForLevel ) )
		string weaponName = ItemFlavor_GetShortName( weapon )
		totalMasteryLevel += weaponLevel

		RTKStruct_SetString( overallStruct, "weaponId", weaponId )
		RTKStruct_SetInt( overallStruct, "xp", weaponXP )
		RTKStruct_SetInt( overallStruct, "level", weaponLevel )
		RTKStruct_SetFloat( overallStruct, "progress", progress )
		RTKStruct_SetAssetPath( overallStruct, "icon", WeaponItemFlavor_GetHudIcon( weapon ) )
		RTKStruct_SetString( overallStruct, "name", ItemFlavor_GetShortName( weapon ) )

		if( weaponTrialsArray != null )
		{
			expect array<MasteryWeapon_TrialQueryResult>( trialResultList )
			RTKArray_SetValue( weaponTrialsArray, trialResultList )

			int totalUnlocked = 0
			int totalCompleted = 0
			MasteryWeapon_TrialQueryResult nextTrialToUnlock
			bool foundNextTrial = false

			foreach( MasteryWeapon_TrialQueryResult trial in trialResultList )
			{
				if( trial.trialData.isCompleted )
					totalCompleted++

				if( trial.trialData.isUnlocked )
				{
					totalUnlocked++
				}
				else if( !foundNextTrial )
				{
					nextTrialToUnlock = trial
					foundNextTrial = true
				}
			}

			trialResultList.sort( int function( MasteryWeapon_TrialQueryResult a, MasteryWeapon_TrialQueryResult b ) : ()
			{
				if ( a.trialData.isCompleted && !b.trialData.isCompleted )
					return 1

				else if ( !a.trialData.isCompleted && b.trialData.isCompleted )
					return -1

				else if ( a.trialData.isUnlocked && !b.trialData.isUnlocked )
					return 1

				else if ( !a.trialData.isUnlocked && b.trialData.isUnlocked )
					return -1

				return 0
			} )

			RTKArray_SetValue( weaponSortedTrialsArray, trialResultList )

			RTKStruct_SetInt( overallStruct, "totalTrials", trialResultList.len() )
			RTKStruct_SetInt( overallStruct, "trialsUnlocked", totalUnlocked )
			RTKStruct_SetInt( overallStruct, "trialsCompleted", totalCompleted )
			RTKStruct_SetInt( overallStruct, "nextTrialUnlockedAt", nextTrialToUnlock.trialConfig.displayLevel )
			RTKStruct_SetBool( overallStruct, "unlockedAllTrials", totalUnlocked == trialResultList.len() )
			RTKStruct_SetBool( overallStruct, "completedAllTrials", totalCompleted == trialResultList.len() )

			             
			array< MasteryWeapon_TrialQueryResult > bonusTrialsList
			MasteryWeapon_TrialQueryResult bonusTrial

			MasteryWeapon_FinalRewardResult ornull finalReward = Mastery_GetWeaponFinalReward( weapon, 1  )

			if( finalReward != null )
			{
				expect MasteryWeapon_FinalRewardResult( finalReward )
				if( finalReward.rewards.len() > 0)
				{
					bonusTrial.trialConfig.name = ItemFlavor_GetLongName(finalReward.rewards[0].flav )
				}
				bonusTrial.trialConfig.rewards = finalReward.rewards
				bonusTrial.trialConfig.goal = finalReward.goalVal
				bonusTrial.trialConfig.description = Localize( "#MASTERY_COMPLETE_ALL_TRIALS", Localize( weaponName ) )

				bonusTrial.trialData.isUnlocked = totalUnlocked == trialResultList.len()
				bonusTrial.trialData.isCompleted = finalReward.isCompleted
				bonusTrial.trialData.currentValue = finalReward.curVal

				bonusTrial.trialConfig.displayLevel = trialResultList.len() * 20

				bonusTrialsList.push( bonusTrial )
			}

			RTKArray_SetValue( weaponBonusTrialsArray, bonusTrialsList )

		}
		else
			printt("WARNING - RTKWeaponMasteryScreen_InitializeDataModelThread failed to populate weaponTrialsArray array as it was null")

		       
		if( IsLobby() )
		{
			string bakeryID = ItemFlavor_GetGUIDString( weapon )
			int hits = GetStat_Int( GetLocalClientPlayer(), ResolveStatEntry( CAREER_STATS.weapon_hits, bakeryID ), eStatGetWhen.CURRENT )
			int shots = GetStat_Int( GetLocalClientPlayer(), ResolveStatEntry( CAREER_STATS.weapon_shots, bakeryID ), eStatGetWhen.CURRENT )

			float accuracy
			if( shots == 0 )
				accuracy = 100.0
			else
				accuracy = ( float( hits ) / float( shots ) ) * 100

			RTKStruct_SetInt( statsStruct, "kills", GetStat_Int( GetLocalClientPlayer(), ResolveStatEntry( CAREER_STATS.weapon_kills, bakeryID ), eStatGetWhen.CURRENT ) )
			RTKStruct_SetInt( statsStruct, "hits", hits )
			RTKStruct_SetInt( statsStruct, "shots", shots )
			RTKStruct_SetFloat( statsStruct, "accuracy", accuracy )
			RTKStruct_SetInt( statsStruct, "damageDone", GetStat_Int( GetLocalClientPlayer(), ResolveStatEntry( CAREER_STATS.weapon_damage_done, bakeryID ), eStatGetWhen.CURRENT ) )
			RTKStruct_SetInt( statsStruct, "headshots", GetStat_Int( GetLocalClientPlayer(), ResolveStatEntry( CAREER_STATS.weapon_headshots, bakeryID ), eStatGetWhen.CURRENT ) )
			RTKStruct_SetInt( statsStruct, "knocks", GetStat_Int( GetLocalClientPlayer(), ResolveStatEntry( CAREER_STATS.weapon_dooms, bakeryID ), eStatGetWhen.CURRENT ) )
		}
	}

	RTKStruct_SetInt( weaponMasteryOverallStruct, "level", totalMasteryLevel )
}


array< featureTutorialTab > function WeaponMastery_PopulateAboutText()
{
	array< featureTutorialTab > tabs
	featureTutorialTab tab1
	featureTutorialTab tab2
	array< featureTutorialData > tab1Rules

	                                              
	tab1.tabName = 	"#GAMEMODE_RULES_OVERVIEW_TAB_NAME"

	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#MASTERY_PLAYING_HEADER", 	"#MASTERY_PLAYING_DESC", 		$"rui/menu/mastery/mastery_weaponxp_about_guns" ) )
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#MASTERY_KILLS_HEADER", 		"#MASTERY_KILLS_DESC", 		$"rui/menu/mastery/mastery_weaponxp_about_kills" ) )
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#MASTERY_DAMAGE_HEADER", 	"#MASTERY_DAMAGE_DESC", 	$"rui/menu/mastery/mastery_weaponxp_about_damage" ) )
	tab1Rules.append( UI_FeatureTutorialDialog_BuildDetailsData( "#MASTERY_HEADSHOTS_HEADER", 	"#MASTERY_HEADSHOTS_DESC", 	$"rui/menu/mastery/mastery_weaponxp_about_headshots" ) )

	tab1.rules = tab1Rules
	tabs.append( tab1 )

	return tabs
}

string function WeaponMastery_PopulateAboutTitle()
{
	return "#EARNING_WEAPON_XP"
}

void function InitRTKWeaponMasteryPanel( var panel )
{
	AddCallback_UI_FeatureTutorialDialog_PopulateTabsForMode( WeaponMastery_PopulateAboutText, FEATURE_WEAPON_MASTERY_TUTORIAL )
	AddCallback_UI_FeatureTutorialDialog_SetTitle( WeaponMastery_PopulateAboutTitle, FEATURE_WEAPON_MASTERY_TUTORIAL )

	AddPanelFooterOption( panel, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
	AddPanelFooterOption( panel, LEFT, BUTTON_X, true, "#X_BUTTON_SEEALLTRIALS", "#X_BUTTON_SEEALLTRIALS_MOUSE", WeaponMasteryTrials_Activate )
	AddPanelFooterOption( panel, LEFT, BUTTON_BACK,  true, "#BACK_BUTTON_SUMMARY", "#BACK_BUTTON_SUMMARY_MOUSE", PostGameFlow_Activate, bool function () : ()
	{
		return IsPostGameMenuValid()
	} )

	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, WeaponMasteryPanel_OnShow )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, WeaponMasteryPanel_OnHide )
}

void function WeaponMasteryPanel_OnShow( var panel )
{
	var parentMenu = Hud_GetParent( panel )

	Hud_SetVisible( Hud_GetChild( parentMenu, "WeaponMasteryPanelModelRotateMouseCapture"), true )
}


void function WeaponMasteryPanel_OnHide( var panel )
{
	var parentMenu = Hud_GetParent( panel )

	Hud_SetVisible( Hud_GetChild( parentMenu, "WeaponMasteryPanelModelRotateMouseCapture"), false )
}

int function RTKMutator_PositionXPNotch( int input, int offset, int width )
{
	int startRangeLevel = (int( floor( input / MASTERY_RANGE_PER_LEVEL ) ) * MASTERY_RANGE_PER_LEVEL )
	int normalizedLevel = input - startRangeLevel

	int distanceToTravel = int( max( normalizedLevel - 1, 0 ) ) * ( width / MASTERY_RANGE_PER_LEVEL )

	return distanceToTravel + offset
}

int function WeaponMastery_GetSmokeColor( int level = 1 )
{
	if( level < 20 )
		return 1
	else if( level >= 20 && level < 60 )
		return 2
	else if( level >= 60 && level < 100 )
		return 3
	else
		return 4

	unreachable
}
