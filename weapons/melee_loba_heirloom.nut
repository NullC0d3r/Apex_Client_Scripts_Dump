global function MeleeLobaHeirloom_Init

global function OnWeaponActivate_melee_loba_heirloom
global function OnWeaponDeactivate_melee_loba_heirloom

                                                                            

                         
                                
      

void function MeleeLobaHeirloom_Init()
{
	                                  

	PrecacheImpactEffectTable( "melee_loba_fan_blunt" )

                         
                                  
      

}

                                                                              
                                                          
void function OnWeaponActivate_melee_loba_heirloom( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "fan" )
	{
		                            
	}
                         
                                        
  
                              
  
      

}

void function OnWeaponDeactivate_melee_loba_heirloom( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "fan" )
	{
		                            
	}
                         
                                        
  
                              
  
      

}