global function MpWeaponPathfinderGlovesPrimary_Init

global function OnWeaponActivate_weapon_pathfinder_gloves_primary
global function OnWeaponDeactivate_weapon_pathfinder_gloves_primary

                                                                            

                         
                                
      

void function MpWeaponPathfinderGlovesPrimary_Init()
{
	                                  

                          
                                  
       

}

void function OnWeaponActivate_weapon_pathfinder_gloves_primary( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "gloves" )
	{
		                            
	}
                         
                                           
  
                              
  
      

}

void function OnWeaponDeactivate_weapon_pathfinder_gloves_primary( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "gloves" )
	{
		                            
	}
                         
                                           
  
                              
  
      

}
