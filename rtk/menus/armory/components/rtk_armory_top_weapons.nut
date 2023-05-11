global function RTKArmoryTopWeapons_OnEnable
global function RTKArmoryTopWeapons_OnInitialize
global function RTKArmoryTopWeapons_OnDestroy

global struct RTKArmoryTopWeapons_Properties
{
	array< rtk_panel > topLevel
	array< rtk_panel > topProgress

	rtk_behavior pagination
}

struct
{
	int savedPage = 0
} file

void function RTKArmoryTopWeapons_OnEnable( rtk_behavior self )
{
	rtk_behavior ornull pagination = self.PropGetBehavior( "pagination" )
	if ( pagination != null )
	{
		expect rtk_behavior( pagination )
		pagination.PropSetInt( "startPageIndex", file.savedPage )
	}
}

void function RTKArmoryTopWeapons_OnInitialize( rtk_behavior self )
{
	bool enableWeaponMastery = Mastery_IsEnabled()
	if( !enableWeaponMastery )
		return

	string rootCommonPath = RTKDataModelType_GetDataPath( RTK_MODELTYPE_COMMON, "mastery", true, [ "weapons" ] )

	array< var > weaponOverviews
	foreach ( weapon in GetAllWeaponItemFlavors() )
	{
		string weaponId = WeaponItemFlavor_GetClassname( weapon )
		var weaponOverviewModel = RTKDataModel_GetStruct( rootCommonPath + "." + weaponId + ".overall" )

		weaponOverviews.push( weaponOverviewModel )
	}

	var topLevelPanels       = self.PropGetArray( "topLevel" )
	int topLevelPanelsCount  = RTKArray_GetCount( topLevelPanels )
	weaponOverviews.sort( SortWeaponOverallTopLevel )

	for ( int i = 0; i < topLevelPanelsCount; i++ )
	{
		if( weaponOverviews.len() <= i )
			break

		rtk_panel panel = RTKArray_GetPanel( topLevelPanels, i )
		string weaponId = RTKStruct_GetString( weaponOverviews[i], "weaponId" )
		if( weaponId != "" )
			panel.SetBindingRootPath( rootCommonPath + "." + weaponId + ".overall" )
	}

	var topProgressPanels      = self.PropGetArray( "topProgress" )
	int topProgressPanelsCount = RTKArray_GetCount( topProgressPanels )
	weaponOverviews.sort( SortWeaponOverallTopProgress )
	for ( int i = 0; i < topProgressPanelsCount; i++ )
	{
		if( weaponOverviews.len() <= i )
			break

		rtk_panel panel = RTKArray_GetPanel( topProgressPanels, i )
		string weaponId = RTKStruct_GetString( weaponOverviews[i], "weaponId" )
		if( weaponId != "" )
			panel.SetBindingRootPath( rootCommonPath + "." + weaponId + ".overall" )
	}
}

void function RTKArmoryTopWeapons_OnDestroy( rtk_behavior self )
{
	rtk_behavior ornull pagination = self.PropGetBehavior( "pagination" )
	if ( pagination != null )
	{
		expect rtk_behavior( pagination )
		file.savedPage = RTKPagination_GetCurrentPage( pagination )
	}
}

int function SortWeaponOverallTopLevel( var a, var b )
{
	int levelA = RTKStruct_GetInt( a, "level" )
	int levelB = RTKStruct_GetInt( b, "level" )

	if ( levelA > levelB )
		return -1
	if ( levelB > levelA )
		return 1

	return SortWeaponOverallTopProgress( a, b )                                                              
}

int function SortWeaponOverallTopProgress( var a, var b )
{
	float progressA = RTKStruct_GetFloat( a, "progress" )
	float progressB = RTKStruct_GetFloat( b, "progress" )

	if ( progressA > progressB )
		return -1
	if ( progressB > progressA )
		return 1

	return 0
}

