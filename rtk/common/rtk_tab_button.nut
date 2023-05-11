global struct RTKTabButton_Properties
{
	int index
	void functionref( int ) onClick
	rtk_panel activePanel
	rtk_panel inactivePanel
}

global function RTKTabButton_Click
global function RTKTabButton_Init
global function RTKTabButton_SetSelected

void function RTKTabButton_Click( rtk_behavior self )
{
	self.InvokeEvent( "onClick", self.PropGetInt( "index" ) )
}

void function RTKTabButton_Init( rtk_behavior self, int index, bool selected, void functionref( int ) clickHandler )
{
	self.rtkprops.index = index;
	self.AddEventListener( "onClick", clickHandler )

	RTKTabButton_SetSelected( self, selected )
}

void function RTKTabButton_SetSelected( rtk_behavior self, bool selected )
{
	if ( self.rtkprops.activePanel != null )
	{
		rtk_panel activePanel = expect rtk_panel( self.rtkprops.activePanel )
		activePanel.SetVisible( selected )
	}
	if ( self.rtkprops.inactivePanel != null )
	{
		rtk_panel inactivePanel = expect rtk_panel( self.rtkprops.inactivePanel )
		inactivePanel.SetVisible( !selected )
	}
}
