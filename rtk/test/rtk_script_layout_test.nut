                                                                                                       
global struct RTKScriptLayoutTest_Properties
{
	float xOffset = 0
	float yOffset = 0
}

global function RTKScriptLayoutTest_InitMetaData
global function RTKScriptLayoutTest_OnLayout

void function RTKScriptLayoutTest_InitMetaData( string behaviorType, string structType )
{
	                                                                                                
	RTKMetaData_BehaviorIsLayoutBehavior( behaviorType, true )
}

                                                                                                                                         
void function RTKScriptLayoutTest_OnLayout( rtk_behavior self )
{
	                                                                                     
	if ( !self.IsLayoutInvalidated() )
		return;

	rtk_panel panel = self.GetPanel()
	int childCount = panel.GetChildCount()

	float x = expect float( self.rtkprops.xOffset )
	float y = expect float( self.rtkprops.yOffset )

	for ( int i = 0; i < childCount; ++i )
	{
		rtk_panel child = panel.GetChildByIndex( i )
		child.SetPositionXY( x, y )
	}

	                                                                                          
	                                                                                                    
	self.ClearInvalidatedLayoutFlag()
}
