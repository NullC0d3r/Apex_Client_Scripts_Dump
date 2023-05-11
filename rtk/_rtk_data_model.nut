global function RTKDataModel_GetOrCreateEmptyStruct
global function RTKDataModel_GetOrCreateScriptStruct
global function RTKStruct_GetOrCreateEmptyStruct
global function RTKStruct_GetOrCreateScriptStruct
global function RTKStruct_GetOrCreateScriptArrayOfStructs

global function RTKDataModelType_CreateStruct
global function RTKDataModelType_DestroyStruct
global function RTKDataModelType_GetDataPath

global const string RTK_MODELTYPE_COMMON = "common"
global const string RTK_MODELTYPE_MENUS = "menus"
global const string RTK_MODELTYPE_GAMEPLAY = "gameplay"

string function GetFullDataModelPath( string pathToRoot, string propertyName )
{
	return pathToRoot + (pathToRoot == "&" ? "" : ".") +  propertyName
}

var function RTKDataModel_GetOrCreateEmptyStruct( string pathToRoot, string propertyName )
{
	string fullPath = GetFullDataModelPath( pathToRoot, propertyName )
	if ( RTKDataModel_HasDataModel( fullPath ) )
		return RTKDataModel_GetStruct( fullPath )
	else
		return RTKDataModel_CreateEmptyStruct( pathToRoot, propertyName )
}

var function RTKDataModel_GetOrCreateScriptStruct( string pathToRoot, string propertyName, string structTypeName )
{
	string fullPath = GetFullDataModelPath( pathToRoot, propertyName )
	if ( RTKDataModel_HasDataModel( fullPath ) )
		return RTKDataModel_GetStruct( fullPath )
	else
		return RTKDataModel_CreateStruct( pathToRoot, propertyName, structTypeName )
}

var function RTKStruct_GetOrCreateEmptyStruct( var props, string propertyName )
{
	if ( RTKStruct_HasProperty( props, propertyName ) )
		return RTKStruct_GetStruct( props, propertyName )
	else
		return RTKStruct_AddEmptyStructProperty( props, propertyName )
}

var function RTKStruct_GetOrCreateScriptStruct( var props, string propertyName, string structTypeName )
{
	if ( RTKStruct_HasProperty( props, propertyName ) )
		return RTKStruct_GetStruct( props, propertyName )
	else
		return RTKStruct_AddStructProperty( props, propertyName, structTypeName )
}

var function RTKStruct_GetOrCreateScriptArrayOfStructs( var props, string propertyName, string structTypeName )
{
	if( RTKStruct_HasProperty( props, propertyName ) )
		return RTKStruct_GetArray( props, propertyName )
	else
		return RTKStruct_AddArrayOfStructsProperty( props, propertyName, structTypeName )
}


                     
var function RTKDataModelType_CreateStruct( string type = "", string propertyName = "", string structType = "", array< string > parentPropertyNames = [] )
{
	string path = RTKDataModelType_GetDataPath( type, "", true )
	var data = RTKDataModel_GetOrCreateEmptyStruct( "&", RTKDataModelType_GetDataPath( type, "", false ) )

	foreach( string p in parentPropertyNames )
	{
		data = RTKDataModel_GetOrCreateEmptyStruct( path, p )
		path += "." + p
	}

	if( RTKStruct_HasProperty( data, propertyName ) )
		RTKStruct_RemoveProperty( data, propertyName )

	if( structType == "" )
		return RTKStruct_GetOrCreateEmptyStruct( data, propertyName )
	else
		return RTKDataModel_CreateStruct( path, propertyName, structType )
}

var function RTKDataModelType_DestroyStruct( string type = "", string propertyName = "", array< string > parentPropertyNames = [] )
{
	string path = RTKDataModelType_GetDataPath( type, "", true )
	var data = RTKDataModel_GetOrCreateEmptyStruct( "&", RTKDataModelType_GetDataPath( type, "", false ) )

	foreach( string p in parentPropertyNames )
	{
		data = RTKDataModel_GetOrCreateEmptyStruct( path, p )
		path += "." + p
	}

	if( RTKStruct_HasProperty( data, propertyName ) )
		RTKStruct_RemoveProperty( data, propertyName )
}

string function RTKDataModelType_GetDataPath( string type = "", string propertyName = "", bool includeRoot = true, array< string > parentPropertyNames = [] )
{
	string path = ( (includeRoot)? "&" : "" ) + type

	foreach( string p in parentPropertyNames )
		path += "." + p

	if( propertyName != "" )
		path += "." + propertyName

	return path
}
