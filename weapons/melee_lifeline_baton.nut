global function MeleeLifelineBaton_Init

global function OnWeaponActivate_melee_lifeline_baton
global function OnWeaponDeactivate_melee_lifeline_baton

                                                                            

                         
                                
      

void function MeleeLifelineBaton_Init()
{
	                                  

                          
                                  
       

}

                                                                              
                                                          
void function OnWeaponActivate_melee_lifeline_baton( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "baton" )
	{
		                            
	}
                         
                                          
  
                              
  
      

}

void function OnWeaponDeactivate_melee_lifeline_baton( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "baton" )
	{
		                            
	}
                         
                                          
  
                              
  
      

}
