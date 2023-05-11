global function MpWeaponLobaHeirloomPrimary_Init
global function OnWeaponActivate_weapon_loba_heirloom_primary
global function OnWeaponDeactivate_weapon_loba_heirloom_primary

             
                                                                            

                         
                                
      


void function MpWeaponLobaHeirloomPrimary_Init()
{
	                                  

                         
                                  
      

}

void function OnWeaponActivate_weapon_loba_heirloom_primary( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "fan" )
	{
		                            
	}
                         
                                        
  
                              
  
      

}

void function OnWeaponDeactivate_weapon_loba_heirloom_primary( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "fan" )
	{
		                            
	}
                         
                                        
  
                              
  
      

}