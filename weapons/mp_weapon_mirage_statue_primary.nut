
global function MpWeaponMirageStatuePrimary_Init

global function OnWeaponActivate_weapon_mirage_statue_primary
global function OnWeaponDeactivate_weapon_mirage_statue_primary

                                                                            

                         
                                
      

void function MpWeaponMirageStatuePrimary_Init()
{
	                                  

                         
                                  
      

}

void function OnWeaponActivate_weapon_mirage_statue_primary( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "statue" )
	{
		                            
	}
                         
                                           
  
                              
  
      

}

void function OnWeaponDeactivate_weapon_mirage_statue_primary( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "statue" )
	{
		                            
	}
                         
                                           
  
                              
  
      

}
