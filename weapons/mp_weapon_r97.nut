global function OnWeaponActivate_weapon_r97
global function OnWeaponDeactivate_weapon_r97
global function OnWeaponPrimaryAttack_weapon_r97
global function OnProjectileCollision_weapon_r97

void function OnWeaponActivate_weapon_r97( entity weapon )
{
                      
                                         
       
}


void function OnWeaponDeactivate_weapon_r97( entity weapon )
{
                      
                                           
       
}


var function OnWeaponPrimaryAttack_weapon_r97( entity weapon, WeaponPrimaryAttackParams attackParams )
{
                      
                                        
                                                                    
       
	weapon.FireWeapon_Default( attackParams.pos, attackParams.dir, 1.0, 1.0, false )
	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}


void function OnProjectileCollision_weapon_r97( entity projectile, vector pos, vector normal, entity hitEnt, int hitBox, bool isCritical, bool isPassthrough )
{
                      
                                                                                                          
       
}