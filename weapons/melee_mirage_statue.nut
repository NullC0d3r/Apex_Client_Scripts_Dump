
global function MeleeMirageStatue_Init

global function OnWeaponActivate_melee_mirage_statue
global function OnWeaponDeactivate_melee_mirage_statue

                                                                            

                         
                                
      

void function MeleeMirageStatue_Init()
{
	                                  

                         
                                  
      

}

                                                                              
                                                          
void function OnWeaponActivate_melee_mirage_statue( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "statue" )
	{
		                            
	}
                         
                                           
  
                              
  
      

}

void function OnWeaponDeactivate_melee_mirage_statue( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "statue" )
	{
		                            
	}
                         
                                           
  
                              
  
      

}
