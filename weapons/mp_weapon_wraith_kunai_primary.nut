global function MpWeaponWraithKunaiPrimary_Init

global function OnWeaponActivate_weapon_wraith_kunai_primary
global function OnWeaponDeactivate_weapon_wraith_kunai_primary

const asset KUNAI_FX_GLOW_FP = $"P_kunai_idle_FP"
const asset KUNAI_FX_GLOW_3P = $"P_kunai_idle_3P"

const asset KUNAI_RT01_FX_GLOW_FP = $"P_kunai_rt01_idle_FP"
const asset KUNAI_RT01_FX_GLOW_3P = $"P_kunai_rt01_idle_3P"

void function MpWeaponWraithKunaiPrimary_Init()
{
	PrecacheParticleSystem( KUNAI_FX_GLOW_FP )
	PrecacheParticleSystem( KUNAI_FX_GLOW_3P )
	
	PrecacheParticleSystem( KUNAI_RT01_FX_GLOW_FP )
	PrecacheParticleSystem( KUNAI_RT01_FX_GLOW_3P )
}

void function OnWeaponActivate_weapon_wraith_kunai_primary( entity weapon )
{
	                                                      
	
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "kunai" )
		weapon.PlayWeaponEffect( KUNAI_FX_GLOW_FP, KUNAI_FX_GLOW_3P, "knife_base", true )
	else if ( meleeSkinName == "kunai_rt01" )
		weapon.PlayWeaponEffect( KUNAI_RT01_FX_GLOW_FP, KUNAI_RT01_FX_GLOW_3P, "knife_base", true )
}

void function OnWeaponDeactivate_weapon_wraith_kunai_primary( entity weapon )
{
	                                                        
	
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "kunai" )
		weapon.StopWeaponEffect( KUNAI_FX_GLOW_FP, KUNAI_FX_GLOW_3P )
	else if ( meleeSkinName == "kunai_rt01" )
		weapon.StopWeaponEffect( KUNAI_RT01_FX_GLOW_FP, KUNAI_RT01_FX_GLOW_3P )
}