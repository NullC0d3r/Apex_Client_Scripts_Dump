global function RTKPagination_InitMetaData
global function RTKPagination_OnInitialize
global function RTKPagination_OnDrawEnd
global function RTKPagination_OnDestroy
global function RTKPagination_OnMouseWheeled
global function RTKPagination_OnKeyCodePressed
global function RTKPagination_OnHoverEnter
global function RTKPagination_OnHoverLeave
global function RTKPagination_GetCurrentPage

global struct RTKPagination_Properties
{
	rtk_panel 		container
	rtk_panel 		content

	rtk_behavior nextButton
	rtk_behavior prevButton
	rtk_panel paginationButtons
	rtk_panel hint

	int pages
	int pageSize
	int startPageIndex = 0

	array< string > pageNames = []

	bool vertical
	bool autoPagesByContainerContent
	bool panelsAlwaysStartNewPages = false

	rtk_behavior animator
}

struct PrivateData
{
	int currentPageIndex = 0
	int nextPageIndex = 0

	bool firstDrawComplete = false
}

global struct RTKPaginationPip
{
	bool isActive = false
	string name = ""
}

void function RTKPagination_InitMetaData( string behaviorType, string structType )
{
	RTKMetaData_SetAllowedBehaviorTypes( structType, "nextButton", [ "Button" ] )
	RTKMetaData_SetAllowedBehaviorTypes( structType, "prevButton", [ "Button" ] )
	RTKMetaData_SetAllowedBehaviorTypes( structType, "animator", [ "Animator" ] )
}

void function RTKPagination_OnInitialize( rtk_behavior self )
{
	rtk_behavior ornull nextButton = self.PropGetBehavior( "nextButton" )
	rtk_behavior ornull prevButton = self.PropGetBehavior( "prevButton" )
	rtk_behavior ornull animator = self.PropGetBehavior( "animator" )
	rtk_panel ornull paginationButtons = self.PropGetPanel( "paginationButtons" )

	if ( nextButton != null )
	{
		expect rtk_behavior( nextButton )
		self.AutoSubscribe( nextButton, "onPressed", function( rtk_behavior button, int keycode, int prevState ) : ( self ) {
			RTKPagination_NextPage( self )
		} )
	}

	if ( prevButton != null )
	{
		expect rtk_behavior( prevButton )
		self.AutoSubscribe( prevButton, "onPressed", function( rtk_behavior button, int keycode, int prevState ) : ( self ) {
			RTKPagination_PrevPage( self )
		} )
	}

	if ( animator != null )
	{
		expect rtk_behavior( animator )
		self.AutoSubscribe( animator, "onAnimationFinished", function ( rtk_behavior animator, string animName ) : ( self ) {
			RTKPagination_OnAnimFinished( self, animName )
		} )
	}

	if ( paginationButtons != null )
	{
		expect rtk_panel( paginationButtons )
		self.AutoSubscribe( paginationButtons, "onChildAdded", function ( rtk_panel newChild, int newChildIndex ) : ( self ) {
			array< rtk_behavior > buttonBehaviors = newChild.FindBehaviorsByTypeName( "Button" )
			foreach( button in buttonBehaviors )
			{
				self.AutoSubscribe( button, "onPressed", function( rtk_behavior button, int keycode, int prevState ) : ( self, newChildIndex ) {
					RTKPagination_GoToPage( self, newChildIndex )
				} )
			}
		} )
	}
}

void function RTKPagination_OnDestroy( rtk_behavior self )
{
	RTKPagination_ClearDataModel(self )
}

void function RTKPagination_OnDrawEnd( rtk_behavior self )
{
	PrivateData p
	self.Private( p )

	if( !p.firstDrawComplete )
	{
		p.nextPageIndex = self.PropGetInt( "startPageIndex" )
		RTKPagination_SetPositionToPageNoAnim( self  )
		RTKPagination_RefreshPaginationButtons( self )
		p.firstDrawComplete = true
	}
}

bool function RTKPagination_OnMouseWheeled( rtk_behavior self, float delta )
{
	if( IsControllerModeActive() && !self.PropGetBool( "vertical" ) )
		return false

	if( delta > 0)
	{
		RTKPagination_PrevPage( self, true )
		return true
	}
	else if( delta < 0)
	{
		RTKPagination_NextPage( self, true )
		return true
	}

	return false
}

bool function RTKPagination_OnKeyCodePressed( rtk_behavior self, int code )
{
	if( self.PropGetBool( "vertical" ) )
	{
		if( code == KEY_UP )           
		{
			RTKPagination_NextPage( self, true )
			return true
		}
		else if( code == KEY_DOWN )             
		{
			RTKPagination_PrevPage( self, true )
			return true
		}
	}
	else
	{
		if( code == STICK2_RIGHT || code == KEY_RIGHT )                                  
		{
			RTKPagination_NextPage( self, true )
			return true
		}
		else if( code == STICK2_LEFT  || code == KEY_LEFT )                                
		{
			RTKPagination_PrevPage( self, true )
			return true
		}
	}

	return false
}

void function RTKPagination_OnHoverEnter( rtk_behavior self )
{
	rtk_panel ornull hintPanel = self.PropGetPanel( "hint" )
	if( hintPanel != null )
	{
		expect rtk_panel( hintPanel )
		rtk_behavior animator = hintPanel.FindBehaviorByTypeName( "Animator" )

		if( animator != null )
		{
			if ( RTKAnimator_HasAnimation( animator, "FadeIn" ) )
				RTKAnimator_PlayAnimation( animator, "FadeIn" )
		}
	}
}

void function RTKPagination_OnHoverLeave( rtk_behavior self )
{
	rtk_panel ornull hintPanel = self.PropGetPanel( "hint" )
	if( hintPanel != null )
	{
		expect rtk_panel( hintPanel )
		rtk_behavior animator = hintPanel.FindBehaviorByTypeName( "Animator" )

		if( animator != null )
		{
			if ( RTKAnimator_HasAnimation( animator, "FadeOut" ) )
				RTKAnimator_PlayAnimation( animator, "FadeOut" )
		}
	}
}

void function RTKPagination_GoToPage( rtk_behavior self, int page )
{
	PrivateData p
	self.Private( p )

	rtk_behavior ornull animator = self.PropGetBehavior( "animator" )
	if ( animator != null )
	{
		if ( RTKAnimator_IsPlaying( expect rtk_behavior( animator ) ) )
			return
	}

	p.nextPageIndex = page
	RTKPagination_RefreshActivePage( self )
}

void function RTKPagination_NextPage( rtk_behavior self, bool emitSound = false )
{
	rtk_behavior ornull animator = self.PropGetBehavior( "animator" )
	if ( animator != null && RTKAnimator_IsPlaying( expect rtk_behavior( animator ) ) )
		return

	PrivateData p
	self.Private( p )

	int pageCount = RTKPagination_GetTotalPages( self  )
	if( pageCount <= p.currentPageIndex )
		return
	else if ( pageCount <= 0 )
	{
		p.currentPageIndex = 0
		return
	}

	if( emitSound )
		EmitUISound( "UI_Menu_BattlePass_LevelTab" )

	p.nextPageIndex = p.currentPageIndex + 1
	RTKPagination_RefreshActivePage( self )
}

void function RTKPagination_PrevPage( rtk_behavior self, bool emitSound = false )
{
	rtk_behavior ornull animator = self.PropGetBehavior( "animator" )
	if ( animator != null && RTKAnimator_IsPlaying( expect rtk_behavior( animator ) ) )
		return

	PrivateData p
	self.Private( p )

	int pageCount = RTKPagination_GetTotalPages( self  )
	if( 0 >= p.currentPageIndex )
		return
	else if ( pageCount <= 0 )
	{
		p.currentPageIndex = 0
		return
	}

	if( emitSound )
		EmitUISound( "UI_Menu_BattlePass_LevelTab" )

	p.nextPageIndex = p.currentPageIndex - 1
	RTKPagination_RefreshActivePage( self )
}


void function RTKPagination_RefreshActivePage( rtk_behavior self )
{
	PrivateData p
	self.Private( p )

	if ( p.currentPageIndex < 0 )
		return

	rtk_behavior ornull animator = self.PropGetBehavior( "animator" )
	if ( animator != null && RTKAnimator_IsPlaying( expect rtk_behavior( animator ) ) )
		return

	expect rtk_behavior( animator )

	var animations  = animator.PropGetArray( "tweenAnimations" )
	int tweensCount = RTKArray_GetCount( animations )
	var nextPageAnim = null

	for( int i = 0; i < tweensCount; i++ )
	{
		var animation = RTKArray_GetStruct( animations, i )
		string name = RTKStruct_GetString( animation, "name" )

		if( name == "NextPage" )
		{
			nextPageAnim = animation
			break
		}
	}
	if( nextPageAnim != null )
	{
		var tweens = RTKStruct_GetArray( nextPageAnim, "tweens" )
		var tween = RTKArray_GetStruct( tweens, 0 )

		RTKStruct_SetInt( tween, "startValue", RTKPagination_GetPagePosition( self, p.currentPageIndex ) )
		RTKStruct_SetInt( tween, "endValue", RTKPagination_GetPagePosition( self, p.nextPageIndex ) )

		RTKAnimator_PlayAnimation( animator, "NextPage" )
	}
	else                            
		RTKPagination_SetPositionToPageNoAnim( self  )

	RTKPagination_RefreshPaginationButtons( self )
}

void function RTKPagination_RefreshPaginationButtons( rtk_behavior self )
{
	PrivateData p
	self.Private( p )

	rtk_panel ornull paginationButtons = self.PropGetPanel( "paginationButtons" )
	rtk_behavior ornull nextButton = self.PropGetBehavior( "nextButton" )
	rtk_behavior ornull prevButton = self.PropGetBehavior( "prevButton" )
	int pageCount = RTKPagination_GetTotalPages( self  )

	if( nextButton != null )
	{
		expect rtk_behavior( nextButton )
		nextButton.PropSetBool( "interactive", p.currentPageIndex < pageCount )
	}

	if( prevButton != null )
	{
		expect rtk_behavior( prevButton )
		prevButton.PropSetBool( "interactive", p.currentPageIndex > 0 )
	}

	if ( paginationButtons != null )
	{
		expect rtk_panel( paginationButtons )

		int pages = RTKPagination_GetTotalPages( self )
		var screenPagination = RTKDataModel_GetOrCreateEmptyStruct( RTK_MODELTYPE_MENUS, "pagination" )
		array< RTKPaginationPip > pips

		for( int i = 0; i <= pages; i++ )
		{
			RTKPaginationPip pip
			pip.isActive = i == p.currentPageIndex
			var pageNames = self.PropGetArray( "pageNames" )
			if( RTKArray_GetCount( pageNames ) > i )
				pip.name = RTKArray_GetString( pageNames, i )

			pips.push( pip )
		}

		var paginationArray = RTKStruct_GetOrCreateScriptArrayOfStructs( screenPagination, string( self.GetInternalId() ), "RTKPaginationPip" )
		RTKArray_SetValue( paginationArray, pips )

		rtk_behavior ornull listBinder = paginationButtons.FindBehaviorByTypeName( "ListBinder" )

		if( listBinder == null )
			return

		expect rtk_behavior( listBinder )

		if( listBinder.PropGetString( "bindingPath" ) == "" )
		{
			listBinder.PropSetString( "bindingPath", RTKDataModelType_GetDataPath( RTK_MODELTYPE_MENUS, string( self.GetInternalId() ), true, [ "pagination" ] ) )
		}

	}
}

void function RTKPagination_ClearDataModel( rtk_behavior self  )
{
	var screenPagination = RTKDataModelType_CreateStruct( RTK_MODELTYPE_MENUS, "pagination" )
	var paginationArray = RTKStruct_AddArrayOfStructsProperty( screenPagination, string( self.GetInternalId() ), "RTKPaginationPip" )
	RTKArray_SetValue( paginationArray, [] )
}

void function RTKPagination_SetPositionToPageNoAnim( rtk_behavior self )
{
	PrivateData p
	self.Private( p )

	rtk_panel ornull content = self.PropGetPanel( "content" )

	if( content != null )
	{
		expect rtk_panel( content )
		if( self.PropGetBool( "vertical" ) )
			content.SetPositionY( RTKPagination_GetPagePosition( self, p.nextPageIndex ) )
		else
			content.SetPositionX( RTKPagination_GetPagePosition( self, p.nextPageIndex ) )

		RTKPagination_UpdateCurrentPage( self )
	}
}

void function RTKPagination_OnAnimFinished( rtk_behavior self, string animName )
{
	RTKPagination_UpdateCurrentPage( self )
	RTKPagination_RefreshPaginationButtons( self )
}

void function RTKPagination_UpdateCurrentPage( rtk_behavior self )
{
	PrivateData p
	self.Private( p )

	p.currentPageIndex = p.nextPageIndex
	p.nextPageIndex = -1
}

float function RTKPagination_GetContainerSize( rtk_behavior self )
 {
	 rtk_panel ornull container = self.PropGetPanel( "container" )
	 if( container != null )
	 {
		 expect rtk_panel( container )

		 if( self.PropGetBool( "vertical" ) )
			 return container.GetHeight()
		 else
			 return container.GetWidth()
	 }

	 return 0
 }

float function RTKPagination_GetContentSize( rtk_behavior self )
{
	rtk_panel ornull content = self.PropGetPanel( "content" )
	if( content != null )
	{
		expect rtk_panel( content )

		if( self.PropGetBool( "vertical" ) )
			return content.GetHeight()
		else
			return content.GetWidth()
	}

	return 0
}

struct PaginationPositionData
{
	float offset
	int pages
}

PaginationPositionData function RTKPagination_GetDynamicPaginationPositionData( rtk_behavior self , int searchForPage = -1)
{
	array< float >  contentSizes = RTKPagination_GetContentSizes( self )
	float containerSize = RTKPagination_GetContainerSize( self )
	float contentSpacing = RTKPagination_GetContentSpacing( self )
	bool panelsAlwaysStartNewPages = self.PropGetBool( "panelsAlwaysStartNewPages" )

	PaginationPositionData data

	float childContentUsedSpace      = 0
	int lastIndex                    = 0

	if( panelsAlwaysStartNewPages )
	{
		                                                                                         
		                                     
		for ( int i = 0; i < contentSizes.len(); i++ )
		{
			if( searchForPage == data.pages )
				break

			if( i != lastIndex )
			{
				childContentUsedSpace = 0
			}
			int savedIndex = i

			float childContentSize = contentSizes[i] - childContentUsedSpace
			float remainingContainerSize

			if( i == lastIndex )
				remainingContainerSize = data.offset - ( containerSize * max( data.pages - 1, 0 ) )
			else
				remainingContainerSize = containerSize

			if( childContentSize > containerSize )
			{
				                                                                           
				data.offset += containerSize
				data.pages++
				childContentUsedSpace += containerSize

				i--                                        
			}
			else if( remainingContainerSize + childContentSize >= containerSize )
			{
				                                                                   
				data.offset += childContentSize
				data.pages++

				childContentUsedSpace += min( containerSize, childContentSize )
			}
			else
			{
				                                                     
				data.offset += childContentSize + contentSpacing
				childContentUsedSpace = 0

				data.pages++
			}

			lastIndex = savedIndex
		}
	}
	else
	{
		                                                                                                              
		                           
		float totalSize = 0
		for ( int i = 0; i < contentSizes.len(); i++ )
		{
			totalSize += contentSizes[i]
		}

		data.offset = ( searchForPage == -1 )? totalSize: containerSize * float( searchForPage )
		data.pages = ( searchForPage == -1 )? int( ceil( totalSize / containerSize ) ): searchForPage
	}

	data.pages = int( max( data.pages - 1, 0 ) )

	return data
}

int function RTKPagination_GetTotalPages( rtk_behavior self )
{
	if( !self.PropGetBool( "autoPagesByContainerContent" ) )
		return self.PropGetInt( "pages" )

	PaginationPositionData data = RTKPagination_GetDynamicPaginationPositionData( self )
	return data.pages
}

int function RTKPagination_GetPagePosition( rtk_behavior self, int page )
{
	float contentSpacing = RTKPagination_GetContentSpacing( self )
	array< float >  contentSizes = RTKPagination_GetContentSizes( self )

	float contentSize = RTKPagination_GetContentSize( self )
	float containerSize = RTKPagination_GetContainerSize( self )

	rtk_panel ornull content = self.PropGetPanel( "content" )

	if( content != null )
	{
		expect rtk_panel( content )

		PaginationPositionData data = RTKPagination_GetDynamicPaginationPositionData( self, page )

		if( self.PropGetBool( "vertical" ) )
			return int(content.GetPivot().y * contentSize - data.offset)           
		else
			return int(content.GetPivot().x * contentSize - data.offset)             
	}

	return 0
}

array< float > function RTKPagination_GetContentSizes( rtk_behavior self )
{
	rtk_panel ornull content = self.PropGetPanel( "content" )
	array< float > sizes = []

	if( content != null )
	{
		expect rtk_panel( content )

		array< rtk_panel > children = content.GetChildren()
		foreach( panel in children )
		{
			if( self.PropGetBool( "vertical" ) )
				sizes.push( panel.GetHeight() )
			else
				sizes.push( panel.GetWidth() )
		}
	}

	return sizes
}

float function RTKPagination_GetContentSpacing( rtk_behavior self )
{
	rtk_panel ornull content = self.PropGetPanel( "content" )
	float spacing = 0
	if( content != null )
	{
		expect rtk_panel( content )

		if( content.HasLayoutBehavior() )
		{
			rtk_behavior behavior = content.GetLayoutBehavior()
			spacing = behavior.PropGetFloat( "spacing" )
		}
	}

	return spacing
}

int function RTKPagination_GetCurrentPage( rtk_behavior self )
{
	PrivateData p
	self.Private( p )

	return p.currentPageIndex
}