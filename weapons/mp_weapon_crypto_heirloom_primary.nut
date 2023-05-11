global function MpWeaponCryptoHeirloomPrimary_Init
global function OnWeaponActivate_weapon_crypto_heirloom_primary
global function OnWeaponDeactivate_weapon_crypto_heirloom_primary

             
const asset CRYPTO_AMB_EXHAUST_FP = $"P_crypto_sword_exhaust"
const asset CRYPTO_AMB_EXHAUST_3P = $"P_crypto_sword_base_3P"                                

                         
                                
      

void function MpWeaponCryptoHeirloomPrimary_Init()
{

	PrecacheParticleSystem( CRYPTO_AMB_EXHAUST_FP )
	PrecacheParticleSystem( CRYPTO_AMB_EXHAUST_3P )

                         
                                  
      

}

void function OnWeaponActivate_weapon_crypto_heirloom_primary( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "heirloom" )
	{
		weapon.PlayWeaponEffect( CRYPTO_AMB_EXHAUST_FP, CRYPTO_AMB_EXHAUST_3P, "Fx_def_blade_01", true )
		weapon.PlayWeaponEffect( CRYPTO_AMB_EXHAUST_FP, CRYPTO_AMB_EXHAUST_3P, "Fx_def_blade_02", true )
		weapon.PlayWeaponEffect( CRYPTO_AMB_EXHAUST_FP, CRYPTO_AMB_EXHAUST_3P, "Fx_def_blade_03", true )
	}
                         
                                             
  
                              
  
      

}

void function OnWeaponDeactivate_weapon_crypto_heirloom_primary( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	string meleeSkinName = MeleeSkin_GetSkinNameFromPlayer( player )

	if ( meleeSkinName == "heirloom" )
	{
		weapon.StopWeaponEffect( CRYPTO_AMB_EXHAUST_FP, CRYPTO_AMB_EXHAUST_3P )
	}
                         
                                             
  
                              
  
      

}