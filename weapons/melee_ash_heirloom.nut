                    

global function MeleeAshHeirloom_Init

global function OnWeaponActivate_melee_ash_heirloom
global function OnWeaponDeactivate_melee_ash_heirloom

const asset ASH_HOLO_FP = $"P_ash_hl_NC_holoCoil_script"
const asset ASH_HOLO_LONG_FP = $"P_ash_hl_NC_holoCoil_long_script"                                
const asset ASH_HOLO_3P = $"P_ash_hl_NC_holoGlow_3P"                                                       

                         
                                
      

void function MeleeAshHeirloom_Init()
{
		PrecacheParticleSystem( ASH_HOLO_FP )
		PrecacheParticleSystem( ASH_HOLO_LONG_FP )
		PrecacheParticleSystem( ASH_HOLO_3P )

                         
                                  
      

}

void function OnWeaponActivate_melee_ash_heirloom( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "nunchuck" )
	{
		weapon.PlayWeaponEffect( ASH_HOLO_FP, ASH_HOLO_3P, "fx_nc_top_1" )
		weapon.PlayWeaponEffect( ASH_HOLO_FP, ASH_HOLO_3P, "fx_nc_top_2" )
		weapon.PlayWeaponEffect( ASH_HOLO_FP, ASH_HOLO_3P, "fx_nc_top_3" )
		weapon.PlayWeaponEffect( ASH_HOLO_FP, ASH_HOLO_3P, "fx_nc_bttm_1" )
		weapon.PlayWeaponEffect( ASH_HOLO_FP, ASH_HOLO_3P, "fx_nc_bttm_2" )
		weapon.PlayWeaponEffect( ASH_HOLO_FP, ASH_HOLO_3P, "fx_nc_bttm_3" )
		weapon.PlayWeaponEffect( ASH_HOLO_LONG_FP, ASH_HOLO_3P, "fx_nc_top_4" )
		weapon.PlayWeaponEffect( ASH_HOLO_LONG_FP, ASH_HOLO_3P, "fx_nc_bttm_4" )
	}
                         
                                             
  
                              
  
      

}

void function OnWeaponDeactivate_melee_ash_heirloom( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "nunchuck" )
	{
		weapon.StopWeaponEffect( ASH_HOLO_FP, ASH_HOLO_3P )
		weapon.StopWeaponEffect( ASH_HOLO_LONG_FP, ASH_HOLO_3P )
	}
                         
                                             
  
                              
  
      

}

                         