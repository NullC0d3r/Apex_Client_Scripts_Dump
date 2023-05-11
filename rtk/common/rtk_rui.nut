global function RTKRui_InitMetaData
global function RTKRui_OnInitialize
global function RTKRui_OnDestroy

global struct RTKRui_Properties
{
	asset ruiAsset
	var args           
}

struct PrivateData
{
	int propsListener = RTKEVENT_INVALID
	int argsListener = RTKEVENT_INVALID
}

void function RTKRui_InitMetaData( string behaviorType, string structType )
{
	RTKMetaData_BehaviorIsRuiBehavior( behaviorType, true )
	RTKMetaData_SetAsVariant( structType, "args", true )
}

void function RTKRui_OnInitialize( rtk_behavior self )
{
	PrivateData p
	self.Private( p )

	self.AddPropertyCallback( "ruiAsset", UpdateRuiAsset )
	p.propsListener = RTKStruct_AddStructListener( self.GetProperties(), void function( var rtkStruct, int eventType, string propertyName ) : ( self ) {
		if ( propertyName == "args" )
		{
			if ( eventType == RTKSTRUCTCHANGE_PROPERTYADDED )
				AddArgsListener( self )
			else if ( eventType == RTKSTRUCTCHANGE_PROPERTYREMOVED )
				RemoveArgsListener( self )
		}
	} )

	AddArgsListener( self )
	UpdateRuiAsset( self )
}

void function AddArgsListener( rtk_behavior self )
{
	var argsStruct = self.PropGetStruct( "args" )
	if ( argsStruct == null )
		return

	PrivateData p
	self.Private( p )

	p.argsListener = RTKStruct_AddStructListener( argsStruct, void function( var rtkStruct, int eventType, string propertyName ) : ( self ) {
		UpdateRuiArgs( self )
	} )
}

void function RemoveArgsListener( rtk_behavior self )
{
	var argsStruct = self.PropGetStruct( "args" )
	if ( argsStruct == null )
		return

	PrivateData p
	self.Private( p )

	if ( p.argsListener != RTKEVENT_INVALID )
		RTKStruct_RemoveStructListener( argsStruct, p.argsListener )
}

void function UpdateRuiAsset( rtk_behavior self )
{
	rtk_panel panel = self.GetPanel()
	asset ruiAsset = self.PropGetAssetPath( "ruiAsset" )
	if ( ruiAsset != "" )
	{
		panel.CreateRui( ruiAsset )
		UpdateRuiArgs( self )
	}
	else if ( panel.HasRui() )
	{
		panel.DestroyRui()
	}
}

void function UpdateRuiArgs( rtk_behavior self )
{
	rtk_panel panel = self.GetPanel()
	if ( !panel.HasRui() )
		return

	var argsStruct = self.PropGetStruct( "args" )
	if ( argsStruct == null )
		return

	RTKStruct_ForEachProperty( argsStruct, void function( var rtkStruct, string propertyName, int index, int type, var value ) : ( panel ) {
		switch ( type )
		{
			case RTKPROP_STRING:
				panel.SetRuiArgString( propertyName, expect string( value ) )
				break

			case RTKPROP_ASSETPATH:
				panel.SetRuiArgString( propertyName, expect asset( value ) )
				break

			case RTKPROP_BOOL:
				panel.SetRuiArgBool( propertyName, expect bool( value ) )
				break

			case RTKPROP_ENUM:
			case RTKPROP_INT:
				panel.SetRuiArgInt( propertyName, expect int( value ) )
				break

			case RTKPROP_FLOAT:
				panel.SetRuiArgFloat( propertyName, expect float( value ) )
				break

			case RTKPROP_FLOAT2:
				panel.SetRuiArgFloat2( propertyName, expect vector( value ) )
				break

			case RTKPROP_FLOAT3:
				panel.SetRuiArgFloat3( propertyName, expect vector( value ) )
				break

			case RTKPROP_FLOAT4:
				float w = RTKStruct_GetFloat4_W( rtkStruct, propertyName )
				panel.SetRuiArgFloat4( propertyName, expect vector( value ), w )
				break

			case RTKPROP_STRUCT:
			case RTKPROP_ARRAY:
			case RTKPROP_PANEL:
			case RTKPROP_BEHAVIOR:
			case RTKPROP_PROPERTY:
			case RTKPROP_EVENT:
			case RTKPROP_INVALID:
				Assert( false, "Invalid type for Rui behavior arg property: " + string( type ) )
				break
		}
	} )
}

void function RTKRui_OnDestroy( rtk_behavior self )
{
	RemoveArgsListener( self )

	PrivateData p
	self.Private( p )

	if ( p.propsListener != RTKEVENT_INVALID )
		RTKStruct_RemoveStructListener( self.GetProperties(), p.propsListener )

	rtk_panel panel = self.GetPanel()
	if ( panel.HasRui() )
		panel.DestroyRui()
}

