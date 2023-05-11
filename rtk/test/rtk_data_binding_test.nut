global struct RTKTestModelBravo
{
	int a
	int b
	int c
}

global struct RTKTestModelCharlie
{
	int x
	float y
	string z
}

global struct RTKTestModelAlpha
{
	bool b
	int i
	float f
	vector v
	asset s
	RTKTestModelBravo& bravo
	array< RTKTestModelCharlie > charlieList
}

global function RTK_DataBindingTestInit
global function RTK_DataBindingTestShutdown
global function RTK_DataBindingTestPush
global function RTK_DataBindingTestPop

void function RTK_DataBindingTestInit()
{

	if ( RTKDataModel_HasDataModel( "&alpha" ) )
		RTKDataModel_DestroyModel( "&alpha" );

	var alpha = RTKDataModel_CreateStruct( "&", "alpha", "RTKTestModelAlpha" )

	RTKDataModel_CreateEmptyStruct( "&alpha", "foo" )
	RTKDataModel_CreateEmptyStruct( "&alpha.foo", "bar" )

	             
	RTKTestModelAlpha alphaModel
	RTKStruct_GetValue( alpha, alphaModel )

	                
	alphaModel.s = $"rui/menu/quest/quest_loba"

	             
	RTKStruct_SetValue( RTKDataModel_GetStruct("&alpha"), alphaModel )

	var charlieList_RTK = RTKDataModel_GetArray( "&alpha.charlieList" )
	var charlie0_RTK = RTKArray_PushNewStruct( charlieList_RTK )
	var charlie2_RTK = RTKArray_PushNewStruct( charlieList_RTK )
	var charlie1_RTK = RTKArray_InsertNewStruct( charlieList_RTK, 1 )

	            
	array< RTKTestModelCharlie > charlieList_Script
	RTKArray_GetValue( RTKDataModel_GetArray( "&alpha.charlieList" ), charlieList_Script )

	               
	for (int i = 0; i < charlieList_Script.len(); i++)
	{
		if (i == 0)
		{
			charlieList_Script[i].x = 1
		}
		else
		{
			charlieList_Script[i].x = 0
		}
	}

	            
	RTKArray_SetValue( charlieList_RTK, charlieList_Script )

	RTKTestModelCharlie charlie0_Script
	RTKTestModelCharlie charlie1_Script

	RTKStruct_GetValue( charlie0_RTK, charlie0_Script )
	RTKStruct_GetValue( charlie1_RTK, charlie1_Script )

	charlie0_Script.x = 0
	charlie1_Script.x = 1

	charlie0_Script.y = 0.1
	charlie1_Script.y = 0.5

	charlie0_Script.z = "First"
	charlie1_Script.z = "XYZ"

	RTKStruct_SetValue( charlie0_RTK, charlie0_Script )
	RTKStruct_SetValue( charlie1_RTK, charlie1_Script )

	RTKTestModelCharlie charlie2_Script
	charlie2_Script.z = "ABC"
	charlie2_Script.y = 1.0
	charlie2_Script.x = 2
	RTKArray_SetValueAt( charlieList_RTK, 2, charlie2_Script )

	RTKTestModelCharlie charlie4_Script
	charlie4_Script.x = 4
	charlie4_Script.y = 1.0
	charlie4_Script.z = "Last"
	RTKArray_PushValue( charlieList_RTK, charlie4_Script )

	RTKTestModelCharlie charlie3_Script
	charlie3_Script.x = 3
	charlie3_Script.y = 1.0
	charlie3_Script.z = "PQR"
	RTKArray_InsertValue( charlieList_RTK, 3, charlie3_Script )
}

void function RTK_DataBindingTestPush()
{
	if ( !RTKDataModel_HasDataModel( "&alpha.charlieList" ) )
		return;

	var charlieList = RTKDataModel_GetArray( "&alpha.charlieList" )
	var charlie = RTKArray_PushNewStruct( charlieList )
	RTKStruct_SetInt( charlie, "x", RandomIntRange( 0, 100 ) )
	RTKStruct_SetFloat( charlie, "y", RandomFloatRange( 0.0, 1.0 ) )
	RTKStruct_SetString( charlie, "z", "value" + string( RandomIntRange( 0, 100 ) ) )
}

void function RTK_DataBindingTestPop()
{
	if ( !RTKDataModel_HasDataModel( "&alpha.charlieList" ) )
		return;

	var charlieList = RTKDataModel_GetArray( "&alpha.charlieList" )
	int count = RTKArray_GetCount( charlieList )
	if ( count > 0 )
		RTKArray_RemoveAt( charlieList, count - 1 )
}

void function RTK_DataBindingTestShutdown()
{
	if ( RTKDataModel_HasDataModel( "&alpha" ) )
		RTKDataModel_DestroyModel( "&alpha" );
}
