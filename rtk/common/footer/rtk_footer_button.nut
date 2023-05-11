global struct RTKFooterButton_Properties
{
	rtk_behavior button
	int onPressedEventID = RTKEVENT_INVALID
	int activateGUID = -1
}

global function RTKFooterButton_OnInitialize
global function RTKFooterButton_OnDestroy

void function RTKFooterButton_OnInitialize( rtk_behavior self )
{
	rtk_behavior btn = expect rtk_behavior( self.rtkprops.button )
	self.rtkprops.onPressedEventID = btn.AddEventListener( "onPressed", function ( rtk_behavior button, int keyCode, int prevState ) : ( self )
	{
		int activateGUID = expect int( self.rtkprops.activateGUID )
		printl( "Footer button pressed. keyCode:" + keyCode + ", activateGUID:" + activateGUID )

		RTKFooters_OnFooterActivate( activateGUID )
	} )
}

void function RTKFooterButton_OnDestroy( rtk_behavior self )
{
	if ( self.rtkprops.onPressedEventID == RTKEVENT_INVALID )
		return

	rtk_behavior btn = expect rtk_behavior( self.rtkprops.button )
	btn.RemoveEventListener( "onPressed", expect int( self.rtkprops.onPressedEventID ) )

	self.rtkprops.onPressedEventID = RTKEVENT_INVALID
}
