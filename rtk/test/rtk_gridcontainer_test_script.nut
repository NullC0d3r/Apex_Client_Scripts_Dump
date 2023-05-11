                      
                                                                                          

                          
                                                                                           
                                           
                                                                                                   

                                                              
global struct RTKGridContainerTestModel
{
	                                                                               
	array< string > items
}

global function RTKGridContainerTestScript_OnInitialize

                                                                                                   
void function RTKGridContainerTestScript_OnInitialize( rtk_behavior self )
{
	                                                              
	if ( !RTKDataModel_HasDataModel( "&gridContainerTest" ) )
	{
		                                                                                                             
		                                         
		RTKDataModel_CreateStruct( "&", "gridContainerTest", "RTKGridContainerTestModel" )

		                                                                                 
		var items = RTKDataModel_GetArray( "&gridContainerTest.items" );

		                            
		for ( int i = 0; i < 32 ; i++ )
		{
			string name = format( "Item %i", i )
			RTKArray_PushString( items, name )
		}
	}
}
