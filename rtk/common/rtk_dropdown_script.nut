                      
                                                                                                  
                     
                                                                                                 


                           
                                                                                       
                                                                                                   
  
                                                                                                 
                                                                                      
  
  	                 
  	 
  		                           
  	 
  
   	                                 
   	 
                                                   
  		                         
  	 

                                    
global struct RTKDropDownTestScriptSimple_Properties
{
	                                                                              
	rtk_behavior dropDown

	                                                                                     
	                                                                  
	                                                                                         
	                                                                                         
	                 
	int onItemPressedEventID = RTKEVENT_INVALID
}

global function RTKDropDownTestScriptSimple_OnInitialize
global function RTKDropDownTestScriptSimple_OnDestroy


                     
                                                                                               
                                           
                                                                                                   

                                                                                       
                                                                                  
global struct RTKDropDownTestItemModel
{
	                                     
	string label
	                                              
	bool selected
}

                                                              
global struct RTKDropDownTestModel
{
	                                                                                               
	                                                 
	string selectedLabel = ""

	                                                       
	int selectedIndex = 0

	                                                                                                     
	array< RTKDropDownTestItemModel > items
}

                                                                   
global struct RTKDropDownTestScript_Properties
{
	rtk_behavior dropDown
	int onItemPressedEventID = RTKEVENT_INVALID
}

global function RTKDropDownTestScript_OnInitialize
global function RTKDropDownTestScript_OnDestroy


                           
                                                                                                   

void function RTKDropDownTestScriptSimple_OnInitialize( rtk_behavior self )
{
	                                                                                          
	                                                                                 
	rtk_behavior ornull dropDown = expect rtk_behavior ornull( self.rtkprops.dropDown )
	if ( dropDown == null )
		return
	expect rtk_behavior( dropDown )

	                                                                                             
	                                                                                                          
	                                                  

	                                                                                                                       
	self.rtkprops.onItemPressedEventID = dropDown.AddEventListener( "onItemPressed", function ( rtk_behavior button, int index ) : ( self )
	{
		                                                                                                             
		                
		string panelName = self.GetPanel().GetDisplayName();
		string buttonName = button.GetDisplayName();
		printl( "Drop Down Item Pressed: index=" + index + ", button=" + buttonName + ", controlling panel=" + panelName )
	} )
}

                                                                                                                 
                                                 
                                                                                                                              
void function RTKDropDownTestScriptSimple_OnDestroy( rtk_behavior self )
{
	                                              
	if ( self.rtkprops.onItemPressedEventID == RTKEVENT_INVALID )
		return

	                                
	rtk_behavior dropDown = expect rtk_behavior( self.rtkprops.dropDown )
	              
	dropDown.RemoveEventListener( "onItemPressed", expect int( self.rtkprops.onItemPressedEventID ) )
	                        
	self.rtkprops.onItemPressedEventID = RTKEVENT_INVALID
}


                     
                                                                                                   

void function RTKDropDownTestScript_OnInitialize( rtk_behavior self )
{
	                                                              
	if ( !RTKDataModel_HasDataModel( "&dropDownTest" ) )
	{
		                                                                                                        
		                                         
		RTKDataModel_CreateStruct( "&", "dropDownTest", "RTKDropDownTestModel" )

		                                                                                 
		var items = RTKDataModel_GetArray( "&dropDownTest.items" );

		                                            
		array< string > labelNames = [ "First", "Second", "Third", "Fourth", "Fifth", "Sixth", "Seventh", "Eight" ]

		                            
		foreach ( index, value in labelNames )
		{
			                                  
			var newItem = RTKArray_PushNewStruct( items )

			                              
			RTKStruct_SetString( newItem, "label", value )

			                                                                                      
			RTKStruct_SetBool( newItem, "selected", index == 0 )
		}
	}

	                                                                                                  
	rtk_behavior ornull dropDown = expect rtk_behavior ornull( self.rtkprops.dropDown )
	if ( dropDown == null )
		return
	expect rtk_behavior( dropDown )

	self.rtkprops.onItemPressedEventID = dropDown.AddEventListener( "onItemPressed", function ( rtk_behavior button, int index )
	{
		                                                                                            
		                                                   

		                                            
		var items = RTKDataModel_GetArray( "&dropDownTest.items" );
		int count = RTKArray_GetCount( items )

		                                                                                              
		                                      
		if ( index < 0 || index >= count )
			index = 0

		                                                                                               
		                                              
		string newLabel = RTKDataModel_GetString( "&dropDownTest.items[" + index + "].label" )

		                                                                                                       
		RTKDataModel_SetString( "&dropDownTest.selectedLabel", newLabel )
		RTKDataModel_SetInt( "&dropDownTest.selectedIndex", index )

		                                                                                               
		                                                                                 
		for ( int i = 0; i < count; ++i )
		{
			RTKDataModel_SetBool( "&dropDownTest.items[" + i + "].selected", ( i == index ) )

			                                                                       
			  	                                         
			  	                                               
		}
	} )
}

void function RTKDropDownTestScript_OnDestroy( rtk_behavior self )
{
	                                                                                     
	if ( self.rtkprops.onItemPressedEventID == RTKEVENT_INVALID )
		return

	rtk_behavior dropDown = expect rtk_behavior( self.rtkprops.dropDown )
	dropDown.RemoveEventListener( "onItemPressed", expect int( self.rtkprops.onItemPressedEventID ) )
	self.rtkprops.onItemPressedEventID = RTKEVENT_INVALID
}
