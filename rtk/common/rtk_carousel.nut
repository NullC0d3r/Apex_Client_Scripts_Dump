global struct RTKCarouselPageEntry
{
	string titleText
	rtk_panel page
}

global struct RTKCarousel_Properties
{
	rtk_behavior nextButton
	rtk_behavior prevButton
	rtk_behavior title
	rtk_behavior animator
	array<RTKCarouselPageEntry> pages

	rtk_panel outPage
	rtk_panel inPage
}

global function RTKCarousel_InitMetaData
global function RTKCarousel_OnInitialize

struct PrivateData
{
	int currentPageIndex = 0
	int nextPageIndex = -1
}

void function RTKCarousel_InitMetaData( string behaviorType, string structType )
{
	RTKMetaData_SetAllowedBehaviorTypes( structType, "nextButton", [ "Button" ] )
	RTKMetaData_SetAllowedBehaviorTypes( structType, "prevButton", [ "Button" ] )
	RTKMetaData_SetAllowedBehaviorTypes( structType, "title", [ "Label" ] )
	RTKMetaData_SetAllowedBehaviorTypes( structType, "animator", [ "Animator" ] )
}

void function RTKCarousel_OnInitialize( rtk_behavior self )
{
	rtk_behavior ornull nextButton = self.PropGetBehavior( "nextButton" )
	rtk_behavior ornull prevButton = self.PropGetBehavior( "prevButton" )
	rtk_behavior ornull animator = self.PropGetBehavior( "animator" )

	if ( nextButton != null )
	{
		expect rtk_behavior( nextButton )
		self.AutoSubscribe( nextButton, "onPressed", function( rtk_behavior button, int keycode, int prevState ) : ( self ) {
			RTKCarousel_NextPage( self )
		} )
	}

	if ( prevButton != null )
	{
		expect rtk_behavior( prevButton )
		self.AutoSubscribe( prevButton, "onPressed", function( rtk_behavior button, int keycode, int prevState ) : ( self ) {
			RTKCarousel_PrevPage( self )
		} )
	}

	if ( animator != null )
	{
		expect rtk_behavior( animator )
		self.AutoSubscribe( animator, "onAnimationFinished", function ( rtk_behavior animator, string animName ) : ( self ) {
			RTKCarousel_OnAnimFinished( self, animName )
		} )
		self.AutoSubscribe( animator, "onAnimationEvent", function ( rtk_behavior animator, string event ) : ( self ) {
			if ( event == "TitleChange" )
				RTKCarousel_SetTitleForNextPage( self )
		} )
	}

	RTKCarousel_RefreshActivePage( self )
}

void function RTKCarousel_SetTitleForNextPage( rtk_behavior self )
{
	PrivateData p
	self.Private( p )
	if ( p.nextPageIndex < 0 )
		return

	var pages = self.PropGetArray( "pages" )
	var pageCount = RTKArray_GetCount( pages )
	if ( p.nextPageIndex >= pageCount )
		return

	var entry = RTKArray_GetStruct( pages, p.nextPageIndex )
	rtk_panel page = RTKStruct_GetPanel( entry, "page" )
	rtk_behavior ornull title = self.PropGetBehavior( "title" )
	if ( title != null )
	{
		expect rtk_behavior( title )
		title.PropSetString( "text", RTKStruct_GetString( entry, "titleText" ) )
	}
}

void function RTKCarousel_NextPage( rtk_behavior self )
{
	rtk_behavior ornull animator = self.PropGetBehavior( "animator" )
	if ( animator != null && RTKAnimator_IsPlaying( expect rtk_behavior( animator ) ) )
		return

	PrivateData p
	self.Private( p )
	var pages = self.PropGetArray( "pages" )
	int pageCount = RTKArray_GetCount( pages )
	if ( pageCount <= 0 )
	{
		p.currentPageIndex = -1
		return
	}

	int nextPage = (p.currentPageIndex + pageCount + 1) % pageCount
	p.nextPageIndex = nextPage

	if ( animator != null )
	{
		expect rtk_behavior( animator )
		RTKCarousel_SetInOutPages( self, nextPage, p.currentPageIndex )
		RTKAnimator_PlayAnimation( animator, "NextPage" )
	}
	else
	{
		RTKCarousel_RefreshActivePage( self )
	}
}

void function RTKCarousel_PrevPage( rtk_behavior self )
{
	rtk_behavior ornull animator = self.PropGetBehavior( "animator" )
	if ( animator != null && RTKAnimator_IsPlaying( expect rtk_behavior( animator ) ) )
		return

	PrivateData p
	self.Private( p )
	var pages = self.PropGetArray( "pages" )
	int pageCount = RTKArray_GetCount( pages )
	if ( pageCount <= 0 )
	{
		p.currentPageIndex = -1
		return
	}

	int prevPage = (p.currentPageIndex + pageCount - 1) % pageCount
	p.nextPageIndex = prevPage

	if ( animator != null )
	{
		expect rtk_behavior( animator )
		RTKCarousel_SetInOutPages( self, prevPage, p.currentPageIndex )
		RTKAnimator_PlayAnimation( animator, "PrevPage" )
	}
	else
	{
		RTKCarousel_RefreshActivePage( self )
	}
}

void function RTKCarousel_RefreshActivePage( rtk_behavior self )
{
	PrivateData p
	self.Private( p )
	if ( p.currentPageIndex < 0 )
		return

	var pages = self.PropGetArray( "pages" )
	rtk_behavior ornull title = self.PropGetBehavior( "title" )
	for ( int i = 0; i < RTKArray_GetCount( pages ); ++i )
	{
		var entry = RTKArray_GetStruct( pages, i )
		rtk_panel page = RTKStruct_GetPanel( entry, "page" )
		page.SetActiveAndVisible( i == p.currentPageIndex )
		if ( title != null && i == p.currentPageIndex )
		{
			expect rtk_behavior( title )
			title.PropSetString( "text", RTKStruct_GetString( entry, "titleText" ) )
		}
	}
}

                                               
void function RTKCarousel_SetInOutPages( rtk_behavior self, int inIndex, int outIndex )
{
	var pages = self.PropGetArray( "pages" )
	var inEntry = RTKArray_GetStruct( pages, inIndex )
	var outEntry = RTKArray_GetStruct( pages, outIndex )
	self.PropSetPanel( "inPage", RTKStruct_GetPanel( inEntry, "page" ) )
	self.PropSetPanel( "outPage", RTKStruct_GetPanel( outEntry, "page" ) )

	for ( int i = 0; i < RTKArray_GetCount( pages ); ++i )
	{
		var entry = RTKArray_GetStruct( pages, i )
		rtk_panel page = RTKStruct_GetPanel( entry, "page" )
		page.SetActiveAndVisible( i == inIndex || i == outIndex )
	}
}

void function RTKCarousel_OnAnimFinished( rtk_behavior self, string animName )
{
	PrivateData p
	self.Private( p )

	p.currentPageIndex = p.nextPageIndex
	p.nextPageIndex = -1
	RTKCarousel_RefreshActivePage( self )
}
