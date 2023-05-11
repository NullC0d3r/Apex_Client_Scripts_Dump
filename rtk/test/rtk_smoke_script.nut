global struct RTKSmokeTestSubStruct1
{
	int a = 9
	float b = 99.9
	string c = "nine"
	bool d = false
	vector e = < 9, 99, 999 >
}

global struct RTKSmokeTestSubStruct2
{
	RTKSmokeTestSubStruct1& testNestedStruct
}

global struct RTKSmokeTestBehavior_Properties
{
	array< RTKSmokeTestSubStruct2 > arrayOfStructs
	array< string > arrayOfStrings
	array< int > arrayOfInts
	array< bool > arrayOfBools
	array< float > arrayOfFloats
	array< vector > arrayOfVectors
	array< int > emptyArray
	rtk_panel somePanel
	rtk_behavior someBehavior
	int someInt

	void functionref( rtk_behavior self, rtk_panel panel, float dt ) onLifetimeTick
}

global function RTKSmokeTestBehavior_OnEnable
global function RTKSmokeTestBehavior_OnDisable
global function RTKSmokeTestBehavior_OnInitialize
global function RTKSmokeTestBehavior_OnDestroy
global function RTKSmokeTestBehavior_OnUpdate
global function RTKSmokeTestBehavior_OnPreDraw
global function RTKSmokeTestBehavior_OnDrawBegin
global function RTKSmokeTestBehavior_OnDrawEnd

global function RTKSmokeTestBehavior_OnMousePressed
global function RTKSmokeTestBehavior_OnMouseReleased
global function RTKSmokeTestBehavior_OnMouseWheeled
global function RTKSmokeTestBehavior_OnKeyCodePressed
global function RTKSmokeTestBehavior_OnKeyCodeReleased

global function RTKSmokeTestBehavior_OnHoverEnter
global function RTKSmokeTestBehavior_OnHoverLeave

global function RTKSmokeTestBehavior_InterfaceMethod
global function RTKSmokeTestBehavior_OnSomeIntChanged

struct PrivateData
{
	int test
	float foo
	vector bar
}

void function RTKSmokeTestBehavior_OnEnable( rtk_behavior self )
{
	self.Message( "RTKSmokeTestBehavior_OnEnable" )
}

void function RTKSmokeTestBehavior_OnDisable( rtk_behavior self )
{
	self.Message( "RTKSmokeTestBehavior_OnDisable" )
}

void function RTKSmokeTestBehavior_OnSomeIntChanged( rtk_behavior self )
{
	self.Message( "RTKSmokeTestBehavior_OnSomeIntChanged someInt=" + expect int( self.rtkprops.someInt ) )
}

void function RTKSmokeTestBehavior_OnTestPanelRuiRemoved( rtk_behavior self, rtk_panel removedFromThisPanel )
{
	self.Message( "RTKSmokeTestBehavior_OnTestPanelRuiRemoved panel=" + removedFromThisPanel.GetDisplayName() )
}

void function RTKSmokeTestBehavior_OnLifetimeTick( rtk_behavior self, rtk_panel panel, float dt )
{
}

void function RTKSmokeTestBehavior_OnInitialize( rtk_behavior self )
{
	printl( "RTKSmokeTestBehavior_OnInitialize" )

	PrivateData p
	self.Private( p )

	p.test = 42
	p.foo = 1.234
	p.bar = < 1, 2, 3 >

	self.AddPropertyCallback( "someInt", RTKSmokeTestBehavior_OnSomeIntChanged )
	self.rtkprops.someInt = 42

	self.AddEventListener( "onLifetimeTick", RTKSmokeTestBehavior_OnLifetimeTick )

	printl( "===== RTKBehavior Interface =====" )
	rtk_behavior behavior = expect rtk_behavior( self.rtkprops.someBehavior )
	rtk_panel panel = behavior.GetPanel()
	printl( "get panel: " + ( panel ) )
	printl( "active self: " + behavior.IsActiveSelf() )
	printl( "active in hierarchy: " + behavior.IsActiveInHierarchy() )
	printl( "setting inactive, setting active" )
	behavior.SetActive( false )
	behavior.SetActive( true )
	printl( "name:" + behavior.GetName() )
	printl( "display name: " + behavior.GetDisplayName() )
	behavior.SetName( "SmokeTestNameOverride" )
	printl( "changed name: " + behavior.GetName() )
	printl( "internal id: " + behavior.GetInternalId() )
	printl( "typename: " + behavior.GetTypeName() )
	RTKSmokeTestBehavior_InterfaceMethod( self )

	printl( "===== RTKBehavior Properties =====" )
	printl( "active: " + expect bool( behavior.rtkprops.active ) + "," + RTKStruct_GetBool( behavior.GetProperties(), "active" ) )
	printl( "name: " + expect string( behavior.rtkprops.name ) + "," + RTKStruct_GetString( behavior.GetProperties(), "name" ) )
	printl( "panel: " + expect rtk_panel( behavior.rtkprops.panel ) + "," + RTKStruct_GetPanel( behavior.GetProperties(), "panel" ) )

	printl( "===== RTKPanel Interface =====" )
	panel = expect rtk_panel( self.rtkprops.somePanel )
	printl( "name: " + panel.GetName() )
	printl( "display name: " + panel.GetDisplayName() )
	panel.SetName( "SmokeTestNameOverride_Panel" )
	printl( "changed name: " + panel.GetName() )
	printl( "internal id: " + panel.GetInternalId() )
	printl( "active self: " + panel.IsActiveSelf() )
	printl( "active in hierarchy: " + panel.IsActiveInHierarchy() )
	printl( "visible: " + panel.IsVisible() )
	panel.SetVisible( false )
	printl( "set invisible: visible=" + panel.IsVisible() )
	panel.SetVisible( true )
	var system = panel.GetSystem()
	printl( "system: " + system )
	printl( "parent: " + panel.GetParent() )
	printl( "child count: " + panel.GetChildCount() )
	rtk_panel child0 = panel.GetChildByIndex( 0 );
	rtk_panel child1 = panel.GetChildByIndex( 1 );
	printl( "child0: " + child0 + ", child1: " + child1 )
	child1.MoveToSystemRoot( RTKTRANSFORM_KEEPLOCAL )
	child1.SetParent( panel, RTKTRANSFORM_MAINTAINSCREEN )
	printl( "child1 moved to system root and pack to parent" )
	printl( "find child named 'Image1': " + panel.FindChildByName( "Image1" ) )
	rtk_panel panel2 = panel.FindDescendantByName( "Panel2" );
	printl( "find descendant named 'Panel2': " + panel2 )
	printl( "is Panel2 descendant of " + panel.GetName() + "?: " + panel2.IsDescendant( panel ) )
	printl( "Image1 sibling index: " + child1.GetSiblingIndex() )
	printl( "Setting Image1 as index 0:" )
	child1.SetSiblingIndex( 0 )
	printl( "Image1 new sibling index: " + child1.GetSiblingIndex() )
	printl( "behavior count: " + panel.GetBehaviorCount() );
	for ( int i = 0; i < panel.GetBehaviorCount(); ++i )
	{
		printl( "behavior[" + i + "]: " + panel.GetBehaviorByIndex( i ) )
	}

	printl( "adding Image behavior..." )
	rtk_behavior newBehavior = panel.AddBehavior( "Image" )

	printl( "destroying behavior[1]..." )
	panel.DestroyBehavior( panel.GetBehaviorByIndex( 1 ) )
	printl( "behavior of type 'Image': " + panel.FindBehaviorByTypeName( "Image" ) )
	printl( "behavior of name 'NamedBehavior': " + panel.FindBehaviorByName( "NamedBehavior" ) )
	array< rtk_behavior > behaviorArray = panel.FindBehaviorsByTypeName( "Image" )
	printl( "behaviors of type 'Image': array<rtk_behavior>[" + behaviorArray.len() + "]" )
	behaviorArray = panel.FindBehaviorsByName( "NamedBehavior" )
	printl( "behaviors of name 'NamedBehavior': array<rtk_behavior>[" + behaviorArray.len() + "]" )
	printl( "behavior of type in descendents: " + panel.FindBehaviorInDescendantsByTypeName( "Image" ) )
	printl( "behavior of name in descendents: " + panel.FindBehaviorInDescendantsByName( "NamedBehavior2" ) )
	printl( "behavior of type in parents: " + panel2.FindBehaviorInParentsByTypeName( "SmokeTestBehavior" ) )
	printl( "behavior of name in parents: " + panel2.FindBehaviorInParentsByName( "NamedBehavior" ) )

	panel.SetPosition( < 10, 10, 0 > )
	panel.SetPositionX( 20 )
	panel.SetPositionY( 25 )
	panel.SetPositionXY( 100, 100 )
	printl( "position: " + panel.GetPosition() )
	panel.SetRotationDegrees( 10 )
	printl( "rotation: " + panel.GetRotationDegrees() )
	panel.SetScale( < 0.99, 1.01, 0 > )
	printl( "scale: " + panel.GetScale() )
	panel.SetSize( < 500, 500, 0 > )
	panel.SetSizeWH( 501, 501 )
	vector size = panel.GetSize()
	printl( "size: w=" + size.x + " h=" + size.y )
	panel.SetWidth( 599 )
	printl( "width: " + panel.GetWidth() )
	panel.SetHeight( 699 )
	printl( "height: " + panel.GetHeight() )

	panel.SetAnchor( RTKANCHOR_CENTER_STRETCH_WIDTH_HEIGHT )
	printl( "anchor: " + panel.GetAnchor() )
	panel.SetSizeDelta( < -100, -100, 0 > )
	printl( "size delta: " + panel.GetSizeDelta() )
	panel.SetOffsetsHoriz( < 1, 2, 0 > )
	panel.SetOffsetsVert( < 3, 4, 0 > )
	printl( "offsets: l=" + panel.GetOffsetLeft() + " r=" + panel.GetOffsetRight() + " t=" + panel.GetOffsetTop() + " b=" + panel.GetOffsetBottom() )
	panel.SetOffsets( 10, 11, 12, 13 )
	printl( "new offsets: l=" + panel.GetOffsetLeft() + " r=" + panel.GetOffsetRight() + " t=" + panel.GetOffsetTop() + " b=" + panel.GetOffsetBottom() )

	panel.SetAnchor_MaintainLocalSizeAndPosition( RTKANCHOR_TOP_RIGHT )
	printl( "new anchor: " + panel.GetAnchor() )
	printl( "new size delta: " + panel.GetSizeDelta() )

	panel.SetPivot_MaintainLocalPosition( < 0.1, 0.1, 0 > )
	printl( "pivot: " + panel.GetPivot() )
	panel.SetPivot( < 0.5, 0.5, 0 > )
	printl( "new pivot: " + panel.GetPivot() )

	rtk_panel testChild = RTKPanel_Create( panel, "TestChild" )
	self.AutoSubscribe( testChild, "onRuiDestroyed", RTKSmokeTestBehavior_OnTestPanelRuiRemoved )
	int testEventID = testChild.AddEventListener( "onRuiDestroyed", RTKSmokeTestBehavior_OnTestPanelRuiRemoved )
	testChild.RemoveEventListener( "onRuiDestroyed", testEventID )
	testChild.CreateRui( $"ui/badge_s10_bplevel.rpak" )
	printl( "has rui: " + testChild.HasRui() )
	testChild.SetRuiArgInt( "tier", 42 )
	testChild.DestroyRui()

	printl( "===== RTKPanel Properties =====" )
	printl( "active: " + expect bool( panel.rtkprops.active ) + "," + RTKStruct_GetBool( panel.GetProperties(), "active" ) )
	printl( "visible: " + expect bool( panel.rtkprops.visible ) + "," + RTKStruct_GetBool( panel.GetProperties(), "visible" ) )
	                                
	printl( "name: " + expect string( panel.rtkprops.name ) + "," + RTKStruct_GetString( panel.GetProperties(), "name" ) )
	printl( "position: " + expect vector( panel.rtkprops.position ) + "," + RTKStruct_GetFloat2( panel.GetProperties(), "position" ) )
	printl( "rotation: " + expect float( panel.rtkprops.rotation ) + "," + RTKStruct_GetFloat( panel.GetProperties(), "rotation" ) )
	printl( "scale: " + expect vector( panel.rtkprops.scale ) + "," + RTKStruct_GetFloat2( panel.GetProperties(), "scale" ) )
	printl( "size: " + expect vector( panel.rtkprops.size ) + "," + RTKStruct_GetFloat2( panel.GetProperties(), "size" ) )
	printl( "sizeDelta: " + expect vector( panel.rtkprops.sizeDelta ) + "," + RTKStruct_GetFloat2( panel.GetProperties(), "sizeDelta" ) )
	printl( "pivot: " + expect vector( panel.rtkprops.scale ) + "," + RTKStruct_GetFloat2( panel.GetProperties(), "pivot" ) )
	printl( "anchor: " + expect int( panel.rtkprops.anchor ) + "," + RTKStruct_GetEnum( panel.GetProperties(), "anchor" ) )
	printl( "offsetLeft: " + expect float( panel.rtkprops.offsetLeft ) + "," + RTKStruct_GetFloat( panel.GetProperties(), "offsetLeft" ) )
	printl( "offsetRight: " + expect float( panel.rtkprops.offsetRight ) + "," + RTKStruct_GetFloat( panel.GetProperties(), "offsetRight" ) )
	printl( "offsetTop: " + expect float( panel.rtkprops.offsetTop ) + "," + RTKStruct_GetFloat( panel.GetProperties(), "offsetTop" ) )
	printl( "offsetBottom: " + expect float( panel.rtkprops.offsetBottom ) + "," + RTKStruct_GetFloat( panel.GetProperties(), "offsetBottom" ) )

	if ( RTKArray_GetCount( self.rtkprops.arrayOfStructs ) <= 0 )
		return

	var subStruct1 = RTKArray_GetStruct( self.rtkprops.arrayOfStructs, 0 )
	var subStruct2 = RTKStruct_GetStruct( subStruct1, "testNestedStruct" )
}

void function RTKSmokeTestBehavior_OnDestroy( rtk_behavior self )
{
	self.Message( "RTKSmokeTestBehavior_OnDestroy" )
}

void function RTKSmokeTestBehavior_OnUpdate( rtk_behavior self, float dt )
{
	PrivateData p
	self.Private( p )
	self.InvokeEvent( "onLifetimeTick", self, self.GetPanel(), dt )
}

void function RTKSmokeTestBehavior_OnPreDraw( rtk_behavior self )
{
}

void function RTKSmokeTestBehavior_OnDrawBegin( rtk_behavior self )
{
}

void function RTKSmokeTestBehavior_OnDrawEnd( rtk_behavior self )
{
}

bool function RTKSmokeTestBehavior_OnMousePressed( rtk_behavior self, int code )
{
	self.Message( "RTKSmokeTestBehavior_OnMousePressed " + code )
	return true
}

bool function RTKSmokeTestBehavior_OnMouseReleased( rtk_behavior self, int code )
{
	self.Message( "RTKSmokeTestBehavior_OnMouseReleased " + code )
	return true
}

bool function RTKSmokeTestBehavior_OnMouseWheeled( rtk_behavior self, float delta )
{
	self.Message( "RTKSmokeTestBehavior_OnMouseWheeled " + delta )
	return true
}

bool function RTKSmokeTestBehavior_OnKeyCodePressed( rtk_behavior self, int code )
{
	self.Message( "RTKSmokeTestBehavior_OnKeyCodePressed " + code )
	return true
}

bool function RTKSmokeTestBehavior_OnKeyCodeReleased( rtk_behavior self, int code )
{
	self.Message( "RTKSmokeTestBehavior_OnKeyCodeReleased " + code )
	return true
}

void function RTKSmokeTestBehavior_OnHoverEnter( rtk_behavior self )
{
	self.Message( "RTKSmokeTestBehavior_OnHoverEnter" )
}

void function RTKSmokeTestBehavior_OnHoverLeave( rtk_behavior self )
{
	self.Message( "RTKSmokeTestBehavior_OnHoverLeave" )
}

void function RTKSmokeTestBehavior_InterfaceMethod( rtk_behavior self )
{
	self.Message( "RTKSmokeTestBehavior_InterfaceMethod" )
}
