global function MpWeaponOctaneKnifePrimary_Init

global function OnWeaponActivate_weapon_octane_knife_primary
global function OnWeaponDeactivate_weapon_octane_knife_primary

                                                                            

                         
                                
      

void function MpWeaponOctaneKnifePrimary_Init()
{
	                                  

                         
                                  
      

}

void function OnWeaponActivate_weapon_octane_knife_primary( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "knife" )
	{
		                            
	}
                         
                                          
  
                              
  
      
}

void function OnWeaponDeactivate_weapon_octane_knife_primary( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "knife" )
	{
		                            
	}
                         
                                          
  
                              
  
      
}
