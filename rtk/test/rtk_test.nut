global function RTK_Test;

void function OnQuebecFoo( float val, float factor )
{
	printl( "OnQuebecFoo: val=" + val + ", factor=" + factor )
}

void function OnPanelDestroyed()
{
	printl( "Panel Destroyed" )
}

string function RTK_Test( rtk_panel root )
{
	root.DestroyAllChildren()

	rtk_panel papa = RTKPanel_Create( root, "papa" )
	papa.SetSizeWH( 500, 500 )
	papa.SetAnchor( RTKANCHOR_CENTER )
	papa.CreateRui( $"ui/badge_account_beasthunter_event.rpak" )

	rtk_panel quebec = RTKPanel_Create( papa, "quebec" )
	quebec.SetSizeWH( 200, 200 )
	quebec.SetAnchor( RTKANCHOR_TOP_RIGHT )
	quebec.CreateRui( $"ui/badge_long_shot.rpak" )
	rtk_behavior rot = quebec.AddBehavior( "RotateOverTime" )
	rot.rtkprops.speed = 100

	rtk_behavior test = quebec.AddBehavior( "TestScript" )
	test.AddEventListener( "onCrossThreshold", function () : ( rot )
	{
		printl( "OnQuebecCrossThreshold" )
		rot.PropSetBool( "paused", !rot.PropGetBool( "paused" ) )
	} )
	test.AddEventListener( "onDestroyed", OnPanelDestroyed )

	int listenerHandle = test.AddEventListener( "onFoo", OnQuebecFoo )
	RTKTestScript_Foo( test, 40 );
	test.RemoveEventListener( "onFoo", listenerHandle )

	rtk_panel romeo = RTKPanel_Create(root, "romeo")
	romeo.SetSizeWH(500, 500)
	romeo.SetAnchor( RTKANCHOR_CENTER )
	rtk_behavior image = romeo.AddBehavior( "Image" )
	image.rtkprops.assetPath = $"rui/gladiator_cards/badges/long_shot"
	image.rtkprops.colorRGB = <0.5, 0.8, 0.0 >
	image.rtkprops.alpha = 1.0
	image.rtkprops.hue = 0.0
	image.rtkprops.saturation = 1.0
	image.rtkprops.lightness = 0.0
	image.rtkprops.blend = 1.0
	image.rtkprops.premul = 0.0
	image.rtkprops.tintRGB = <1,1,1>
	image.rtkprops.tintAlpha = 1.0

	rtk_behavior selectorTest = romeo.AddBehavior( "SelectorTest" )
	selectorTest.AddEventListener( "testEvent", function( int a, int b, int c ) {
		printl( "testEvent: " + a + ", " + b + ", " + c )
	} )
	selectorTest.InvokeEvent( "testEvent", 1, 2, 3 )
	selectorTest.InvokeEvent( "testEvent", 99, -5000, 0 )

	return "";
}
