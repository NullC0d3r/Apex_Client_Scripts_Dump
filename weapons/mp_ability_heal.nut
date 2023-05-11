global function OnWeaponChargeBegin_ability_heal
global function OnWeaponChargeEnd_ability_heal
global function OnWeaponAttemptOffhandSwitch_ability_heal

                    
                                                              
 
                                                                                  
 
      

int function GetOctanceHealthCost( entity weapon )
{
	int result = GetCurrentPlaylistVarInt( "octane_health_cost", 20 )

                     
                                                                                     
  
                                                                          
  
       

	return result
}

bool function OnWeaponChargeBegin_ability_heal( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	float duration     = weapon.GetWeaponSettingFloat( eWeaponVar.charge_time )
	StimPlayerWithOffhandWeapon( ownerPlayer, duration, weapon )
	#if SERVER
		                                                                   
		 
			                                               
			 
				                                                                  
				                                                                  
			 
		 

		                                              
		                                                     
		                                                                 
		                                                

		                                  
		                                     

		                                                                               
		                                                                                        
		                                                                                                                                                                                                                                     

		                                                 
	#endif
	PlayerUsedOffhand( ownerPlayer, weapon )

	#if SERVER
		                                       
		 
			                                                                   
			                                                                 
		 
	#else
		Rumble_Play( "rumble_stim_activate", {} )
	#endif
	return true
}


void function OnWeaponChargeEnd_ability_heal( entity weapon )
{
	#if SERVER
		                                                                                  
		                                                                
	#endif
}


bool function OnWeaponAttemptOffhandSwitch_ability_heal( entity weapon )
{
	return true
}