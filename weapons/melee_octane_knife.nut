global function MeleeOctaneKnife_Init

global function OnWeaponActivate_melee_octane_knife
global function OnWeaponDeactivate_melee_octane_knife

const EFFECT_OCTANE_KNIFE_INSPECT = $"P_octane_knife_swipe_geo_FP"
const EFFECT_OCTANE_KNIFE_IMPACT = $"P_knife_impact_base"
const EFFECT_OCTANE_KNIFE_NEEDLE = $"P_octane_knife_needle_liquid"

                         
                                
      

void function MeleeOctaneKnife_Init()
{
	PrecacheParticleSystem( EFFECT_OCTANE_KNIFE_INSPECT )
	PrecacheParticleSystem( EFFECT_OCTANE_KNIFE_IMPACT )
	PrecacheParticleSystem( EFFECT_OCTANE_KNIFE_NEEDLE )

                         
                                  
      

}

                                                                              
                                                          
void function OnWeaponActivate_melee_octane_knife( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "knife" )
	{
		                            
	}
                         
                                          
  
                              
  
      

}

void function OnWeaponDeactivate_melee_octane_knife( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "knife" )
	{
		                            
	}
                         
                                          
  
                              
  
      

}
