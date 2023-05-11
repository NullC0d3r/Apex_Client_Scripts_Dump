global function RTKBadge_InitMetaData
global function RTKBadge_OnInitialize
global function RTKBadge_OnDrawBegin
global function RTKBadge_OnDestroy

global struct RTKBadge_Properties
{
	asset badgeRuiAsset
	int tier
}

void function RTKBadge_InitMetaData( string behaviorType, string structType )
{
	RTKMetaData_BehaviorIsRuiBehavior( behaviorType, true )
}

void function RTKBadge_OnInitialize( rtk_behavior self )
{
	self.AddPropertyCallback( "badgeRuiAsset", UpdateBadgeRuiAsset )

	UpdateBadgeRuiAsset( self )
}

void function RTKBadge_OnDrawBegin( rtk_behavior self )
{
	rtk_panel panel = self.GetPanel()

	if ( panel.HasRui() )
		panel.SetRuiArgInt( "tier", expect int( self.rtkprops.tier ) )
}

void function RTKBadge_OnDestroy( rtk_behavior self )
{
	rtk_panel panel = self.GetPanel()

	if ( panel.HasRui() )
		panel.DestroyRui()
}

void function UpdateBadgeRuiAsset( rtk_behavior self )
{
	rtk_panel panel = self.GetPanel()

	asset badgeRuiAsset = expect asset( self.rtkprops.badgeRuiAsset )
	if ( badgeRuiAsset != "" )
		panel.CreateRui( badgeRuiAsset )
	else if ( panel.HasRui() )
		panel.DestroyRui()
}
