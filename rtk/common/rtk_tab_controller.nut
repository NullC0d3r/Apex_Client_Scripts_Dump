global struct RTKTabControllerEntry
{
	rtk_behavior tabButton
	rtk_panel tabContent
}

global struct RTKTabController_Properties
{
	array< RTKTabControllerEntry > tabs
	int initialTab = 0
}

global function RTKTabController_OnInitialize
global function RTKTabController_OnTabButtonClick

void function RTKTabController_OnInitialize( rtk_behavior self )
{
	int initialTab = expect int( self.rtkprops.initialTab )
	var tabs = self.rtkprops.tabs
	int tabCount = RTKArray_GetCount( tabs )
	for ( int i = 0; i < tabCount; i++ )
	{
		var entry = RTKArray_GetStruct( tabs, i )
		rtk_behavior tabButton = RTKStruct_GetBehavior( entry, "tabButton" )
		rtk_panel tabContent = RTKStruct_GetPanel( entry, "tabContent" )

		bool selected = i == initialTab
		tabContent.rtkprops.active = selected
		tabContent.SetVisible( selected )

		RTKTabButton_Init( tabButton, i, selected, void function( int tabIndex ) : ( self )
		{
			RTKTabController_OnTabButtonClick( self, tabIndex )
		} )
	}
}

void function RTKTabController_OnTabButtonClick( rtk_behavior self, int tabIndex )
{
	var tabs = self.rtkprops.tabs
	int tabCount = RTKArray_GetCount( tabs )
	for ( int i = 0; i < tabCount; i++ )
	{
		var entry              = RTKArray_GetStruct( tabs, i )
		rtk_behavior tabButton = RTKStruct_GetBehavior( entry, "tabButton" )
		rtk_panel tabContent   = RTKStruct_GetPanel( entry, "tabContent" )

		bool selected = i == tabIndex
		tabContent.rtkprops.active = selected
		tabContent.SetVisible( selected )

		RTKTabButton_SetSelected( tabButton, selected )
	}
}
