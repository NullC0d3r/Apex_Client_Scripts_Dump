global function MeleePathfinderGloves_Init

global function OnWeaponActivate_melee_pathfinder_gloves
global function OnWeaponDeactivate_melee_pathfinder_gloves

                                                                            

                         
                                
      

void function MeleePathfinderGloves_Init()
{
	                                  

                          
                                  
       
}

                                                                              
                                                          
void function OnWeaponActivate_melee_pathfinder_gloves( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "gloves" )
	{
		                            
	}
                         
                                           
  
                              
  
      

}

void function OnWeaponDeactivate_melee_pathfinder_gloves( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "gloves" )
	{
		                            
	}
                         
                                           
  
                              
  
      

}
