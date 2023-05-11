                                                              

global struct RTKTestScript_Properties
{
	float val = 0
	float factor = 1
	float threshold = 100
	string testString
	rtk_behavior testBehavior

	void functionref( void ) onCrossThreshold
	void functionref( float, float ) onFoo
}

global function RTKTestScript_InitMetaData
global function RTKTestScript_OnUpdate
global function RTKTestScript_Foo
global function RTKTestScript_ValidateString

void function RTKTestScript_InitMetaData( string behaviorType, string structType )
{
	RTKMetaData_SetAccessPermissions( structType, "threshold", RTKACCESS_READWRITE )
	RTKMetaData_SetAsVariant( structType, "val", true )
	RTKMetaData_SetEventArgDescriptions( structType, "onFoo", "float val, float factor" )
	RTKMetaData_SetStringValidation( structType, "testString", RTKTestScript_ValidateString, "String must be less than or equal to 5 characters long" )
	RTKMetaData_SetAllowedBehaviorTypes( structType, "testBehavior", [ "TestScript", "Label" ] )

	RTKMetaData_BehaviorIsLayoutBehavior( behaviorType, false )
	RTKMetaData_BehaviorIsUniquePerPanel( behaviorType, true )
	RTKMetaData_BehaviorRequiresBehaviorType( behaviorType, "RotateOverTime" )
}

bool function RTKTestScript_ValidateString( string s )
{
	return s.len() <= 5
}

void function RTKTestScript_OnUpdate( rtk_behavior self, float dt )
{
	float previousVal = expect float( self.rtkprops.val )
	float factor = expect float( self.rtkprops.factor )
	float threshold = expect float( self.rtkprops.threshold )

	float currentVal = previousVal + ( factor * dt )
	self.rtkprops.val = currentVal

	if ( previousVal < threshold && currentVal >= threshold )
		self.InvokeEvent( "onCrossThreshold" )
}

void function RTKTestScript_Foo( rtk_behavior self, float factor )
{
	if ( factor > 0 )
		self.rtkprops.factor = factor
	else
		self.rtkprops.factor = 1

	self.InvokeEvent( "onFoo", expect float( self.rtkprops.val ), expect float( self.rtkprops.factor ) )
}
