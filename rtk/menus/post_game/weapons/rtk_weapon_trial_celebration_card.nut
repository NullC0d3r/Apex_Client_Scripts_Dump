global function RTKWeaponTrialCelebrationCard_OnInitialize
global function RTKWeaponTrialCelebrationCard_OnDestroy

global struct RTKWeaponTrialCelebrationCard_Properties
{
	                       
	rtk_panel rewardButtonsContainer
}

struct PrivateData
{
}

void function RTKWeaponTrialCelebrationCard_OnInitialize( rtk_behavior self )
{
	rtk_panel ornull rewardButtonsContainer = self.PropGetPanel( "rewardButtonsContainer" )

	if ( rewardButtonsContainer != null )
	{
		expect rtk_panel( rewardButtonsContainer )

		self.AutoSubscribe( rewardButtonsContainer, "onChildAdded", function ( rtk_panel newChild, int newChildIndex ) : ( self ) {
			array<rtk_behavior> buttonBehaviors = newChild.FindBehaviorsByTypeName( "Button" )
			foreach ( button in buttonBehaviors )
				button.PropSetBool( "interactive", false )
		} )
	}
}

void function RTKWeaponTrialCelebrationCard_OnDestroy( rtk_behavior self )
{
}
