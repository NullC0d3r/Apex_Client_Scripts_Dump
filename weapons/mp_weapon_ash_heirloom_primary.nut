                    

global function MpWeaponAshHeirloomPrimary_Init
global function OnWeaponActivate_weapon_ash_heirloom_primary
global function OnWeaponDeactivate_weapon_ash_heirloom_primary
global function OnWeaponCustomActivityStart_weapon_ash_heirloom_primary
global function OnWeaponCustomActivityEnd_weapon_ash_heirloom_primary

const string INSPECT_REGULAR = $"animseq/weapons/ash_heirloom/ptpov_ash_heirloom/inspect.rseq"						                  
const string INSPECT_MASK = $"animseq/weapons/ash_heirloom/ptpov_ash_heirloom/inspect_mask.rseq" 				                         
const string INSPECT_PATHFINDER = $"animseq/weapons/ash_heirloom/ptpov_ash_heirloom/inspect_message.rseq" 		                                          	                                   
const string INSPECT_KATA = $"animseq/weapons/ash_heirloom/ptpov_ash_heirloom/inspect_kata.rseq" 				                                                                  
const string INSPECT_KATA_EE = $"animseq/weapons/ash_heirloom/ptpov_ash_heirloom/inspect_kata_easteregg.rseq" 	                                                    

const asset INSPECT_UI_MASK = $"ui/ash_heirloom_inspect_mask.rpak"
const asset INSPECT_UI_PATHFINDER = $"ui/ash_heirloom_inspect_pathfinder.rpak"

             
const asset ASH_HOLO_FP = $"P_ash_hl_NC_holoCoil_script"
const asset ASH_HOLO_LONG_FP = $"P_ash_hl_NC_holoCoil_long_script"                                
const asset ASH_HOLO_3P = $"P_ash_hl_NC_holoGlow_3P"

                         
                                
      

struct
{
	#if CLIENT
		var maskInspectRui = null
	#endif

} file

void function MpWeaponAshHeirloomPrimary_Init()
{
	PrecacheParticleSystem( ASH_HOLO_FP )
	PrecacheParticleSystem( ASH_HOLO_LONG_FP )
	PrecacheParticleSystem( ASH_HOLO_3P )

                         
                                 
      

}

#if CLIENT
void function TryDestroyInspectRUI()
{
	if( file.maskInspectRui != null )
		RuiDestroyIfAlive( file.maskInspectRui )

	file.maskInspectRui = null
}
#endif

void function OnWeaponActivate_weapon_ash_heirloom_primary( entity weapon )
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

void function OnWeaponDeactivate_weapon_ash_heirloom_primary( entity weapon )
{
	#if CLIENT
		TryDestroyInspectRUI()
	#endif

	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "nunchuck" )
	{
		weapon.StopWeaponEffect( ASH_HOLO_FP, ASH_HOLO_3P )
		weapon.StopWeaponEffect( ASH_HOLO_LONG_FP, ASH_HOLO_3P )
	}
                         
                                             
  
                              
  
      

}

void function OnWeaponCustomActivityStart_weapon_ash_heirloom_primary( entity weapon, int sequence )
{
	if( IsValid( weapon ) && weapon.GetWeaponActivity() == ACT_VM_WEAPON_INSPECT )
	{
		entity player = weapon.GetWeaponOwner()
		string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

#if CLIENT
		TryDestroyInspectRUI()
#endif
		string seqName = weapon.GetCurrentSequenceName()
		if ( seqName == INSPECT_PATHFINDER )
		{
#if CLIENT
			file.maskInspectRui = CreateCockpitPostFXRui( INSPECT_UI_PATHFINDER )
#endif
		}
		else if ( seqName == INSPECT_MASK )
		{
#if CLIENT
			file.maskInspectRui = CreateCockpitPostFXRui( INSPECT_UI_MASK )
#endif
		}
		else if ( seqName == INSPECT_REGULAR || seqName == INSPECT_KATA || seqName == INSPECT_KATA_EE )
		{
			if ( meleeSkinName == "nunchuck" )
			{
				weapon.StopWeaponEffect( ASH_HOLO_FP, ASH_HOLO_3P )
				weapon.StopWeaponEffect( ASH_HOLO_LONG_FP, ASH_HOLO_3P )
			}
                         
                                               
    
                                
    
      
		}
	}
}

void function OnWeaponCustomActivityEnd_weapon_ash_heirloom_primary( entity weapon, int activity  )
{
	#if CLIENT
		TryDestroyInspectRUI()
	#endif
	                                                                 
	string seqName = weapon.GetCurrentSequenceName()
	if( IsValid( weapon ) && activity == ACT_VM_WEAPON_INSPECT &&  ( seqName == INSPECT_REGULAR || seqName == INSPECT_KATA || seqName == INSPECT_KATA_EE ) )
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
}
                         