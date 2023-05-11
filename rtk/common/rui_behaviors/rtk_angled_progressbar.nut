global function RTKAngledProgressBar_InitMetaData
global function RTKAngledProgressBar_OnInitialize
global function RTKAngledProgressBar_OnDrawBegin
global function RTKAngledProgressBar_OnDestroy

global struct RTKAngledProgressBar_Properties
{
	asset rui = $""

	float current = 0
	float max = 0

	vector progressBarColor
	vector progressBgColor

	float progressBarAlpha
	float progressBgAlpha

	float angle

	bool isDoubleSided = false
}

void function RTKAngledProgressBar_InitMetaData( string behaviorType, string structType )
{
	RTKMetaData_BehaviorIsRuiBehavior( behaviorType, true )
}

void function RTKAngledProgressBar_OnInitialize( rtk_behavior self )
{
	self.AddPropertyCallback( "rui", UpdateRuiAsset )

	UpdateRuiAsset( self )
}

void function RTKAngledProgressBar_OnDestroy( rtk_behavior self )
{
	rtk_panel panel = self.GetPanel()

	if ( panel.HasRui() )
		panel.DestroyRui()
}

void function UpdateRuiAsset( rtk_behavior self )
{
	rtk_panel panel = self.GetPanel()

	asset ruiAsset
	if( self.rtkprops.rui != $"" )
		ruiAsset = expect asset( self.rtkprops.rui )
	else if( self.PropGetBool( "isDoubleSided" ) )
		ruiAsset = $"ui/rtk_slanted_progressbar_double.rpak"
	else
		ruiAsset = $"ui/rtk_slanted_progressbar.rpak"


	if ( ruiAsset != "" )
		panel.CreateRui( ruiAsset )
	else if ( panel.HasRui() )
		panel.DestroyRui()
}

void function RTKAngledProgressBar_OnDrawBegin( rtk_behavior self )
{
	rtk_panel panel = self.GetPanel()

	if ( panel.HasRui() )
	{
		panel.SetRuiArgFloat( "width", panel.GetWidth() )
		panel.SetRuiArgFloat( "height", panel.GetHeight() )
		panel.SetRuiArgFloat( "current", self.PropGetFloat( "current" ) )
		panel.SetRuiArgFloat( "max", self.PropGetFloat( "max" ) )

		panel.SetRuiArgFloat3( "progressBarColor", self.PropGetFloat3( "progressBarColor" ) )
		panel.SetRuiArgFloat3( "progressBgColor", self.PropGetFloat3( "progressBgColor" ) )
		panel.SetRuiArgFloat( "progressBarAlpha", self.PropGetFloat( "progressBarAlpha" ) )
		panel.SetRuiArgFloat( "progressBgAlpha", self.PropGetFloat( "progressBgAlpha" ) )

		panel.SetRuiArgFloat( "angle", self.PropGetFloat( "angle" ) )
	}
}