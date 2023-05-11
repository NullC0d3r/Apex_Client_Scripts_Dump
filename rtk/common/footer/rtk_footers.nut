global function RTKFooters_Init
global function RTKFooters_Add
global function RTKFooters_RemoveAll
global function RTKFooters_Update
global function RTKFooters_UpdateDataModel
global function RTKFooters_OnFooterActivate
global function AssignMenuGUID

global struct RTKFooterData
{
	int                     gamepadButton
	string                  gamepadLabel
	int                     keyboardButton
	string                  keyboardLabel
	bool functionref()      validateFunc
	int						activateGUID = -1
}

struct FileStruct_LifetimeVM
{
	table<int, table< int, array<RTKFooterData> > > footers
	table<int, void functionref( var )> activateFuncs

	int                       lastAssignedMenuGUID = -1
	int                       lastAssignedActivateGUID = -1
}
FileStruct_LifetimeVM& fileVM

void function RTKFooters_Init()
{
	RTKDataModelType_CreateStruct( RTK_MODELTYPE_MENUS, "leftFooterGroup", "RTKFooterGroupModel" )
	RTKDataModelType_CreateStruct( RTK_MODELTYPE_MENUS, "rightFooterGroup", "RTKFooterGroupModel" )
	RTKDataModelType_CreateStruct( RTK_MODELTYPE_MENUS, "centerFooterGroup", "RTKFooterGroupModel" )
}

void function RTKFooters_Add( int menuGUID, int group, int gamepadButton, string gamepadLabel, int keyboardButton, string keyboardLabel, void functionref( var ) activateFunc = null, bool functionref() validateFunc = null )
{
	Assert( group == LEFT || group == RIGHT || group == CENTER )

	if ( !( menuGUID in fileVM.footers ) )
		fileVM.footers[menuGUID] <- {}

	if ( !( group in fileVM.footers[menuGUID] ) )
		fileVM.footers[menuGUID][group] <- []

	foreach ( groupArray in fileVM.footers[menuGUID] )
	{
		foreach ( entry in groupArray )
		{
			if ( entry.gamepadButton != BUTTON_INVALID && entry.gamepadButton == gamepadButton )
				Assert( entry.validateFunc != null, "Found duplicated footer gamepadButton value. Duplicates require a validateFunc to be defined. " )

			if ( entry.keyboardButton != BUTTON_INVALID && entry.keyboardButton == keyboardButton )
				Assert( entry.validateFunc != null, "Found duplicated footer keyboardButton value. Duplicates require a validateFunc to be defined. " )
		}
	}

	RTKFooterData fd
	fd.gamepadButton = gamepadButton
	fd.gamepadLabel = gamepadLabel
	fd.keyboardButton = keyboardButton
	fd.keyboardLabel = keyboardLabel
	fd.validateFunc = validateFunc
	if ( activateFunc != null )
		fd.activateGUID = AssignActivateGUID( activateFunc )

	fileVM.footers[menuGUID][group].append( fd )
}

void function RTKFooters_RemoveAll( int menuGUID )
{
	if ( menuGUID in fileVM.footers )
		delete fileVM.footers[menuGUID]
}

void function RTKFooters_Update()
{
	foreach ( menuGUID, val in fileVM.footers )
	{
		                                                                                                                                                                         
		                                                                                                                                                                       
		RTKFooters_UpdateDataModel( menuGUID )
	}
}

void function RTKFooters_UpdateDataModel( int menuGUID )
{
	RTKFooters_ClearDataModel()

	bool isControllerModeActive = IsControllerModeActive()

	foreach ( group, groupArray in fileVM.footers[menuGUID] )
	{
		Assert( group == LEFT || group == RIGHT || group == CENTER )

		var items
		switch ( group )
		{
			case LEFT:
				items = RTKDataModel_GetArray( "&" + RTK_MODELTYPE_MENUS + ".leftFooterGroup.items" )
				break

			case RIGHT:
				items = RTKDataModel_GetArray( "&" + RTK_MODELTYPE_MENUS + ".rightFooterGroup.items" )
				break

			case CENTER:
				items = RTKDataModel_GetArray( "&" + RTK_MODELTYPE_MENUS + ".centerFooterGroup.items" )
				break
		}

		for ( int i = 0; i < groupArray.len(); i++ )
		{
			RTKFooterData fd = groupArray[i]

			if ( fd.validateFunc != null && !fd.validateFunc() )
				continue

			var newItem = RTKArray_PushNewStruct( items )
			string labelText = isControllerModeActive ? fd.gamepadLabel : fd.keyboardLabel
			RTKStruct_SetString( newItem, "label", labelText )
			RTKStruct_SetInt( newItem, "gamepadButton", fd.gamepadButton )
			RTKStruct_SetInt( newItem, "keyboardButton", fd.keyboardButton )
			RTKStruct_SetInt( newItem, "activateGUID", fd.activateGUID )
			                                                   
		}
	}
}

void function RTKFooters_ClearDataModel()
{
	var leftItems = RTKDataModel_GetArray( "&" + RTK_MODELTYPE_MENUS + ".leftFooterGroup.items" )
	var rightItems = RTKDataModel_GetArray( "&" + RTK_MODELTYPE_MENUS + ".rightFooterGroup.items" )
	var centerItems = RTKDataModel_GetArray( "&" + RTK_MODELTYPE_MENUS + ".centerFooterGroup.items" )

	RTKArray_Clear( leftItems )
	RTKArray_Clear( rightItems )
	RTKArray_Clear( centerItems )
}

void function RTKFooters_OnFooterActivate( int activateGUID )
{
	Assert( activateGUID in fileVM.activateFuncs )

	void functionref( var ) activateFunc = fileVM.activateFuncs[activateGUID]
	printt( "Using activateGUID:", activateGUID, "to look up and execute activateFunc:", string( activateFunc ) )
	activateFunc( null )                                                                                                                                       
}

int function AssignMenuGUID()
{
	fileVM.lastAssignedMenuGUID++

	return fileVM.lastAssignedMenuGUID
}

int function AssignActivateGUID( void functionref( var ) activateFunc )
{
	foreach ( guid, func in fileVM.activateFuncs )
	{
		if ( func == activateFunc )
			return guid
	}

	fileVM.lastAssignedActivateGUID++
	fileVM.activateFuncs[fileVM.lastAssignedActivateGUID] <- activateFunc

	return fileVM.lastAssignedActivateGUID
}
