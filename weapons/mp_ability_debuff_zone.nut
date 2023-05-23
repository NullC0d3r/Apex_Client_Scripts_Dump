global function MpWeaponDebuffZone_Init
global function OnWeaponTossReleaseAnimEvent_DebuffZone
global function OnWeaponTossPrep_DebuffZone
global function OnProjectileCollision_DebuffZone
global function OnWeaponToss_DebuffZone
global function OnWeaponDeactivate_DebuffZone
global function OnWeaponTossCancel_DebuffZone
global function DoesPlayerHaveOverheatDebuff
global function IsPlayerBeingTargetedByBallistic
global function DebuffZone_GetAllowableStickyEnts

#if CLIENT
global function OnClientAnimEvent_DebuffZone
global function CreateTargetingRui
global function DestroyTargetingRui
global function ServerCallback_CreateOverHeatIconRui
global function DebuffZone_GetOverheatDuration
#endif

int COCKPIT_DEBUFF_ZONE_SCREEN_FX
int COCKPIT_TACT_IDLE

const asset COCKPIT_DEBUFF_1P_SCREEN_FX = $"P_clbr_tac_screen_debuff"
const asset COCKPIT_TACT_IDLE_SCREEN_FX = $"P_clbr_tac_screen_idle"

const float MISSILE_HOMING_SPEED = 1500.0
const float MISSILE_NOTARGET_SPEED = 3000.0
const float MISSILE_LIFETIME = 5.0

const float BEST_TARGET_MAX_RANGE = 3000.0
const int BEST_TARGET_MAX_FOV = 5
const float LOCKON_DELAY = 0.3

const int DEBUFF_ZONE_RADIUS = 150
const float AOE_TIMEOUT = 5.0
const float AOE_HIT_EFFECT_TIMER = 0.5
const float AOE_SPAWN_DELAY = 1.0
const float DEBUFF_AOE_DAMAGE = 5.0
const float DIRECT_HIT_BUFF_DURATION = 12.0

const float MAX_DEBUFF_OVERHEAT = 100.0
const int OVERHEAT_DAMAGE = 30
const float AMOUNT_BETWEEN_THRESHOLDS = 20.0
const int NUMBER_OF_THRESHOLDS = int( MAX_DEBUFF_OVERHEAT / AMOUNT_BETWEEN_THRESHOLDS )
const float LOCKON_TIMEOUT_DURATION = 4

const asset DEBUFF_WEAPON_EFFECT_1P = $"P_clbr_tac_wpn_overheat_idle"
const asset AOE_RADIUS_FX = $"P_clbr_tac_imp_aoe"
const asset AOE_IMPACT_FX = $"P_clbr_tac_imp_aoe_end"
const asset AOE_WARNING_FX = $"P_clbr_tac_imp"
const asset DEBUFF_EXPLOSION = $"P_clbr_tac_wpn_overheat_exp"
const asset DEBUFF_EXPLOSION_3P = $"P_clbr_tac_wpn_overheat_exp_3p"
const asset DEBUFF_OVERHEAT_LHAND = $"P_clbr_tac_hand_overheat"

const asset DEBUFF_ZONE_HEART_MODEL = $"mdl/weapons/ballistic_pistol/w_ballistic_bullet.rmdl"
const asset OVERHEAT_DEBUFF_BODY_FX = $"P_clbr_tac_body_debuff_3p"

const asset LOCK_ON_INIT = $"P_clbr_tac_wpn_Lockon_init"
const asset LOCK_ON_MARKER = $"P_clbr_tac_wpn_Lockon"
const asset FX_TACTICAL_RANGE_INDICATOR = $"P_clbr_tac_distance_sensor"
const asset DEBUFF_ZONE_MUZZLE_FLASH_3P = $"P_clbr_tac_muzzleflash_3p"

const string HOMING_MISSILE_SFX_LOOP = "Ballistic_Tac_Projectile_3P"

const string MISSILE_FIRE_SCREEN_SHAKE = "ballistic_tact_screen_shake"
const float SHAKE_AMPLITUDE = 2.0
const float SHAKE_FREQUENCY = 10.0
const float SHAKE_DURATION = 0.2
const vector SHAKE_DIRECTION = < 0.0, 0.0, 1.0 >

const string PROJECTILE_WAITING_TO_TRIGGER_SOUND = "Ballistic_Tac_AOE_Electricity_3P"
const string PROJECTILE_TRIGGERED_AOE_SOUND = "Ballistic_Tac_AOE_Start_3P"
const string PROJECTILE_AOR_END_SOUND = "Ballistic_Tac_AOE_End_3P"
const string PROJECTILE_TRIGGERED_AOE_SOUND_ENEMY = "Ballistic_Tac_AOE_Start_3P_Enemy"
const string PROJECTILE_AOR_END_SOUND_ENEMY = "Ballistic_Tac_AOE_End_3P_Enemy"
const string PROJECTILE_DIRECT_IMPACT_ENEMY_3P = "Ballistic_Tac_Impact_Direct_Enemy_3P"
const string PROJECTILE_DIRECT_IMPACT_ENEMY_1P =  "Ballistic_Tac_Impact_Direct_Player_1P"
const string PROJECTILE_DIRECT_IMPACT_FRIENDLY_3P = "Ballistic_Tac_Impact_Direct_Friendly_3P"
const string OVERHEAT_HIGH_WARNING_1P = "Ballistic_Tac_Overheat_Warning_1P"
const string PLAYER_OVERHEATS_3P_ENEMY = "Ballistic_Tac_Overheat_3P_enemy"
const string PLAYER_OVERHEATS_3P_TEAM = "Ballistic_Tac_Overheat_3P"
const string BALLISTIC_LOCKED_ON_1P = "Ballistic_Tac_TargetLock_1p_to_3p"
const string TARGET_OF_BALLISTIC_LOCK_ON_1P = "Ballistic_Tac_TargetLock_3p_to_1p"
const string BALLISTIC_LOCKED_ON_LOST_1P = "Ballistic_Tac_TargetLock_1p_to_3p_Lost"
const string TARGET_OF_BALLISTIC_LOCK_ON_LOST_1P = "Ballistic_Tac_TargetLock_3p_to_1p_Lost"

const vector ZERO_THRESHOLD_COLOR = < 255, 100, 100 >
const vector FIRST_THRESHOLD_COLOR = < 255, 80, 100 >
const vector SECOND_THRESHOLD_COLOR = < 255, 60, 100 >
const vector THIRD_THRESHOLD_COLOR = < 255, 40, 100 >
const vector LAST_THRESHOLD_COLOR = < 255, 20, 100 >
const array<vector> THRESHOLD_COLORS = [ZERO_THRESHOLD_COLOR, FIRST_THRESHOLD_COLOR, SECOND_THRESHOLD_COLOR, THIRD_THRESHOLD_COLOR, LAST_THRESHOLD_COLOR]

const vector ZERO_THRESHOLD_ALPHA = < 0.3, 0, 0 >
const vector FIRST_THRESHOLD_ALPHA = < 0.6, 0, 0 >
const vector SECOND_THRESHOLD_ALPHA = < 0.8, 0, 0 >
const vector THIRD_THRESHOLD_ALPHA = < 0.9, 0, 0 >
const vector LAST_THRESHOLD_ALPHA = < 1, 0, 0 >
const array<vector> THRESHOLD_ALPHA = [ZERO_THRESHOLD_ALPHA, FIRST_THRESHOLD_ALPHA, SECOND_THRESHOLD_ALPHA, THIRD_THRESHOLD_ALPHA, LAST_THRESHOLD_ALPHA]

const float OVERHEAT_ICON_VISIBILITY_FOV = 110.0

const float MISSILE_FAR_DISTANCE_SQR = 800 * 800
const float MISSILE_CLOSE_DISTANCE_SQR = 200 * 200

const float HOMING_SHORT_DELAY = 0.15
const float HOMING_LONG_DELAY = 0.4

const string BALLISTIC_HAS_LOCKON_TARGET_NETVAR = "hasBallisticLockonTarget"
const string BALLISTIC_IS_BEING_TARGETED_NETVAR = "ballisticIsBeingTargeted"

struct
{
	float homingSpeed
	float noTargetSpeed
	float bestTargetRange
	float lockOnDelay
	int zoneRadius
	float aoeTimeout
	float aoeSpawnDelay
	float aoeDamage
	float debuffDuration
	int overheatDamage
	float lockoutTimeoutDuration

	#if SERVER
		                                           
		                                     
	#endif

	#if CLIENT
		var targetingRui
		table<entity, var> overheatIconRui
	#endif
} file

void function MpWeaponDebuffZone_Init()
{
	COCKPIT_TACT_IDLE = PrecacheParticleSystem( COCKPIT_TACT_IDLE_SCREEN_FX )
	COCKPIT_DEBUFF_ZONE_SCREEN_FX = PrecacheParticleSystem( COCKPIT_DEBUFF_1P_SCREEN_FX )
	PrecacheModel( DEBUFF_ZONE_HEART_MODEL )
	PrecacheParticleSystem( LOCK_ON_INIT )
	PrecacheParticleSystem( LOCK_ON_MARKER )
	PrecacheParticleSystem( DEBUFF_WEAPON_EFFECT_1P )
	PrecacheParticleSystem( AOE_RADIUS_FX )
	PrecacheParticleSystem( AOE_IMPACT_FX )
	PrecacheParticleSystem( AOE_WARNING_FX )
	PrecacheParticleSystem( DEBUFF_EXPLOSION )
	PrecacheParticleSystem( DEBUFF_EXPLOSION_3P )
	PrecacheParticleSystem( DEBUFF_OVERHEAT_LHAND )
	PrecacheParticleSystem( FX_TACTICAL_RANGE_INDICATOR )
	PrecacheParticleSystem( OVERHEAT_DEBUFF_BODY_FX )
	PrecacheParticleSystem( DEBUFF_ZONE_MUZZLE_FLASH_3P )

	RegisterSignal( "EndLockon" )
	RegisterSignal( "EndMissileHoming" )
	RegisterSignal( "EndTargeting" )
	RegisterSignal( "EndAOEThreads" )
	RegisterSignal( "EndDebuff" )
	RegisterSignal( "RemoveLockOnThreatIndicator" )

	file.homingSpeed 				= GetCurrentPlaylistVarFloat( "ballistic_tact_homing_speed", MISSILE_HOMING_SPEED )
	file.noTargetSpeed 				= GetCurrentPlaylistVarFloat( "ballistic_tact_no_target_speed", MISSILE_NOTARGET_SPEED )
	file.bestTargetRange 			= GetCurrentPlaylistVarFloat( "ballistic_tact_best_target_range", BEST_TARGET_MAX_RANGE )
	file.lockOnDelay 				= GetCurrentPlaylistVarFloat( "ballistic_tact_lock_on_delay", LOCKON_DELAY )
	file.zoneRadius 				= GetCurrentPlaylistVarInt( "ballistic_tact_zone_radius", DEBUFF_ZONE_RADIUS )
	file.aoeTimeout 				= GetCurrentPlaylistVarFloat( "ballistic_tact_aoe_timeout", AOE_TIMEOUT )
	file.aoeSpawnDelay 				= GetCurrentPlaylistVarFloat( "ballistic_tact_aoe_spawn_delay", AOE_SPAWN_DELAY )
	file.aoeDamage 					= GetCurrentPlaylistVarFloat( "ballistic_tact_aoe_damage", DEBUFF_AOE_DAMAGE )
	file.debuffDuration 			= GetCurrentPlaylistVarFloat( "ballistic_tact_debuff_duration", DIRECT_HIT_BUFF_DURATION )
	file.overheatDamage 			= GetCurrentPlaylistVarInt( "ballistic_tact_overheat_damages", OVERHEAT_DAMAGE )
	file.lockoutTimeoutDuration 	= GetCurrentPlaylistVarFloat( "ballistic_tact_lockout_timeout_duration", LOCKON_TIMEOUT_DURATION )

	#if SERVER
		                                                                                             
	#endif

	#if CLIENT
		StatusEffect_RegisterEnabledCallback( eStatusEffect.has_overheat_debuff, DebuffZone_OverheatDebuffEnabled )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.has_overheat_debuff, DebuffZone_OverheatDebuffDisabled )

		AddCallback_CreatePlayerPassiveRui( CreateTargetingRui )
		AddCallback_DestroyPlayerPassiveRui( DestroyTargetingRui )
	#endif

	Remote_RegisterClientFunction( "ServerCallback_CreateOverHeatIconRui", "entity" )

	AddCallback_OnPlayerOverheat( DebuffZone_OnPlayerOverheat )

	RegisterNetworkedVariable( BALLISTIC_HAS_LOCKON_TARGET_NETVAR, SNDC_PLAYER_EXCLUSIVE, SNVT_BOOL )
	RegisterNetworkedVariable( BALLISTIC_IS_BEING_TARGETED_NETVAR, SNDC_PLAYER_EXCLUSIVE, SNVT_BOOL )
	#if CLIENT
		RegisterNetVarBoolChangeCallback( BALLISTIC_HAS_LOCKON_TARGET_NETVAR, SetHasTargetForTargetingRui )
	#endif
}

bool function DoesPlayerHaveOverheatDebuff( entity player )
{
	return StatusEffect_HasSeverity( player, eStatusEffect.has_overheat_debuff )
}

bool function IsPlayerBeingTargetedByBallistic( entity player )
{
	return player.GetPlayerNetBool( BALLISTIC_IS_BEING_TARGETED_NETVAR )
}

void function OnWeaponDeactivate_DebuffZone( entity weapon )
{
	entity player = weapon.GetWeaponOwner()

	if( !IsValid( player ) )
		return

	player.Signal( "EndTargeting" )

	#if CLIENT
		if( player != GetLocalViewPlayer() )
			return

		if ( file.targetingRui != null )
		{
			RuiSetBool( file.targetingRui, "isVisible", false )
			RuiSetBool( file.targetingRui, "hasTarget", false )
		}
	#endif
}

void function OnWeaponTossPrep_DebuffZone( entity weapon, WeaponTossPrepParams prepParams )
{
	entity player = weapon.GetWeaponOwner()

	if( !IsValid( player ) )
		return

	#if CLIENT
		if ( file.targetingRui != null )
		{
			RuiSetBool( file.targetingRui, "isVisible", true )
		}

		thread CreateTacticalTargetingFX( player )
	#endif

	#if SERVER
		                                                  
	#endif
}

var function OnWeaponTossReleaseAnimEvent_DebuffZone( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	#if CLIENT
		if ( !(InPrediction() && IsFirstTimePredicted()) )
			return
	#endif

	entity player = weapon.GetWeaponOwner()
	player.Signal( "EndTargeting" )

	weapon.EmitWeaponSound_1p3p( GetGrenadeThrowSound_1p( weapon ), GetGrenadeThrowSound_3p( weapon ) )
	weapon.PlayWeaponEffect( $"", DEBUFF_ZONE_MUZZLE_FLASH_3P, "muzzle_flash" )
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	DebuffZone_FireMissileLogic( weapon, attackParams )

	PlayerUsedOffhand( player, weapon )

	return weapon.GetAmmoPerShot()
}

var function OnWeaponToss_DebuffZone( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetOwner()

	#if SERVER
		                             
			            

		                                                                   
	#endif

	#if CLIENT
		if ( file.targetingRui != null )
		{
			RuiSetBool( file.targetingRui, "isVisible", false )
			RuiSetBool( file.targetingRui, "hasTarget", false )
		}
	#endif

	return true
}

void function DebuffZone_FireMissileLogic( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetWeaponOwner()
	float missileSpeed = owner.GetPlayerNetBool( BALLISTIC_HAS_LOCKON_TARGET_NETVAR ) ? file.homingSpeed :  file.noTargetSpeed

	WeaponFireMissileParams fireMissileParams
	fireMissileParams.pos = attackParams.pos
	fireMissileParams.dir = attackParams.dir
	fireMissileParams.speed = missileSpeed
	fireMissileParams.scriptTouchDamageType = DF_GIB
	fireMissileParams.scriptExplosionDamageType = ( damageTypes.explosive | DF_NO_SELF_DAMAGE )
	fireMissileParams.doRandomVelocAndThinkVars = false
	fireMissileParams.clientPredicted = true
	entity firedMissile = weapon.FireWeaponMissile( fireMissileParams )

	#if SERVER
		                              
	#endif
	EmitSoundOnEntity( firedMissile, HOMING_MISSILE_SFX_LOOP )
	SetTeam( firedMissile, owner.GetTeam() )

	#if SERVER
		                                                                  
		                                      
		 
			                                                                        
		 
	#endif
}

void function OnProjectileCollision_DebuffZone( entity projectile, vector pos, vector normal, entity hitEnt, int hitBox, bool isCritical, bool isPassthrough )
{
	entity player = projectile.GetOwner()
	if( IsValid( player ) )
		player.Signal( "EndLockon" )
	projectile.Signal( "EndMissileHoming" )

	DeployableCollisionParams collisionParams
	collisionParams.pos = pos
	collisionParams.normal = normal
	collisionParams.hitEnt = hitEnt
	collisionParams.hitBox = 0
	collisionParams.isCritical = isCritical

	if( !PlantStickyEntity( projectile, collisionParams, ZERO_VECTOR, true ) )
	{
	#if SERVER
		                                                                      
		                                                     
		 
			                  
				 
				                         
				 
					                                          
					                                   
						                                               
				 

				                                                                    
				                    
			 
			    
			 
				                                                                                       
			 
		 
		                                                              
		 
			                                      
			                                                                                  

			                              
			  
				                         
				 
					                                             
					                                      
						                                                  
				 

				                                                                    
				                    
			  
		 
		                                  
		 
			                                                                    
			                    
		 
		    
		 
			                                   
		 
	#endif
	}
#if SERVER
	    
	 
		                                                              
		                                                                 
	 
#endif
}

bool function DebuffZone_GetAllowableStickyEnts( entity ent )
{
	string modelName = ent.GetModelName()

	if ( modelName == "mdl/Robots/mobile_hardpoint/mobile_hardpoint_static.rmdl" )
		return true

	if( modelName == "mdl/props/crafting_siphon/crafting_siphon.rmdl" )
		return true

	return false
}

var function OnWeaponTossCancel_DebuffZone( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity player = weapon.GetOwner()

	if( !IsValid( player ) )
		return

	#if SERVER
		                               
		                            
	#endif

	#if CLIENT
		if ( file.targetingRui != null )
		{
			RuiSetBool( file.targetingRui, "isVisible", false )
			RuiSetBool( file.targetingRui, "hasTarget", false )
		}
	#endif

	return 0
}

void function DebuffZone_OnPlayerOverheat( entity player, entity weapon )
{
	StatusEffect_StopAllOfType( player, eStatusEffect.has_overheat_debuff )
	player.Signal( "EndDebuff" )

	#if SERVER
		                      
		                                    
		 
			                                       
			                         
				                                                                               
			                                   
		 

		                                                                                                                                                    

		                                                                                 
		                                                                             

		                                                        

		                                        
	#endif

	weapon.PlayWeaponEffect( DEBUFF_EXPLOSION, $"", "muzzle_flash" )
}

#if SERVER
                                                                       
 
	                                                                                    
	                                

	                                            

	             
	 
		                                                                        

		                                                 
		                                                                      

		                         
		 
			                                                            
			                          

			        
			                                                                            
			                                

			    
			                                      
			                               

			                                                                            
			                             

			        
			                                                
			                                                                            
			                                 

			                                                              
		 

		                                                                                 
		 
			                            

			                                                 
			                                                        

			                                                       
			                                                            
		 

		           
	 
 

                                                                                          
 
	                                              

	                                      
	 
		                                                 
		                 
			        

		                                                                                   
			        

		                              
			        

		                                
			        

		                                       
			        

		                                                                      
		                                          
			        

		                    
		 
			                                                          
				        
		 

		                        
		                                                
		 
			                                                                                  
			                  
		 

		                                                                                 
		                                                                                               

		          
		                                       
			        

		                                                             
		                                                     
		 
			        
		 

		                                   
		                                               
		                                   
		                                   
		                                   
		                                                            
		                                  
		 
			                             
			                             
		 

		                                                          
		 
			                                                                              
			                                                                        
			                            
			 
				                   
				                   
				                          
			 
		 

		                                                                        
		 
			                                                                                   
			                                                                              
			                               
			 
				                   
				                   
				                             
			 
		 

		                    
		 
			        
		 

		                              
		                          
		                          

		                                        
	 

	                        
	                                    
	 
		                                                                                         
		                                       

		                              
		                   
		                                            
		 
                   
				                                                                                                                                                                                                          
					        
         

			                                                                                                                                                       
			                                     

			                                                                                                                                                  
			                             
			 
				                            
				                              
			 

			                                                               
			 
				                                                                                                                           
				                           
				 
					                            
					                              
				 
			 

			                        
			                                                         
			 
				                                                                                  
				                  
			 
			                                                                             
			 
				                                                                                                                             
				                            
				 
					                            
					                              
				 
			 

			                         
				     
		 
	 

	                 
 

                                                                            
 
	                                                                                                                                                                   
	                                                                  

	                                                              
	                                                                                                                                                                          
	                                                                        
	                                           
	                                 
	                                                           

	                                                                       

	            
		                               
		 
			                               
				                        
		 
	 

	                     

	                               
		                        

	                                                                
	                                                                                                                                                                          
	                                           
	                                 
	                                                           

	            
		                               
		 
			                               
				                        
		 
	 

	                                                                   

	                           
	 
		                                                                       
		                                                                                       

		            
			                           
			 
				                           
				 
					                                                                        
					                                                                                            
				 
			 
		 
	 

	                                                          

	            
		                       
		 
			                       
			 
				                                                                    
				                                                                            

				                                              
				                                           
			 
		 
	 

	                                                                      
	 
		                                                                                     
		                                                                                               
		                                                             

		                                                                                                       
		 
			                                                    
		 

		           
	 
 

                                                                                              
 
	                            
		           

	                                 
		           

	                                  
		           

	                                                                          
		           

	            
 

                                                                                 
 
	                                                                                                                                
	                                                                  

	                            
		      

	                                                                                                                                                                                                                  
	                                     
	                                                     
	                                   

	            
		                                
		 
			                                
				                         
		 
	 

	             
 

                                                                                                         
 
	                                                                                                                                   
	                         
	                                        
	                         
	                                   
	                                                                                                                   
	                
		                                                   
	    
	 
		                                                     
		                                               
	 
	                       

	               
		                          

	         
 

                                                                                
 
	                            
	                                                        
		      
	
	                                                     
	                                                              

	                                         
	                                                                                    
	                                      

	                                             
		                               
	                                                   
		               

	                                                                                                                                                                                                                       
	                                     
	                                                  
	                                    

	            
		                                                
		 
			                                
				                         

			                      
				                           

			                                           
		 
	 

	                

	                                           
	                                                             

	                                       
	 
		           
	 
 

                                                  
 
	                             
		           

	                              
		           

	            
 

                                                                   
 
	                                                       
	                                                        

	                                                                                                                           
	 
		                                     
		      
	 

	                                                                                
	 
		                                     
		      
	 

	                                                   
	 
		                                     
		      
	 

	                            
	 
		                                          
		                                   
		      
	 

	                                                       
	 
		                                     
		      
	 

	                                      
	 
		                                     
		      
	 

	                          
	 
		                                     
		      
	 

	                                                                  
	                                                                  
	 
		                                     
		                                                                 
		      
	 

	                                          


	                                            
	                                   
		                                                 

	                                   
 

                                                                                                             
 
	                                                        
	                                       
	                                                       
	                                      
	                                       
	                                     
	                                    
	                                              
	                                                       
	                                                                
	                                                                
	                                                
	                                
		                                               
	                                                                                         
	                                                                                                      
	                                    
	                                                  

	                                  
	          
		                                                                    
		                    
	      

	                             

	                                                            
	                       
	 
		                                      
		                             
	 



	                                                                                                                                                                                                          
	                                     
	                                                            
	                                              

	                                                               
	                                                                                                                                             
	                               
	                                                      
	                                        

	                                                                                                   

	                                                                                                                                                                             

	            
		                                                                      
		 
			                       
			 
				                                                                                                 
				                                                                                        
			 

			                          
				                   

			                                
				                         

			                                  
				                                                  
		 
	 
	                       

	                   

	                                                                                         

	                                
	 
		                                                                                                 
		                                                                                        
	 
	    
	 
		                                                                            
	 


	                                                                                                                  
	                                                                                                                

	                                        

	            
		                                                                     
		 
			                                  
				                           

			                               
				                        
		 
	 

	                          
	 
		             
			                                                                            
			                  
			                              
			               
			               
			                                
			                                
			                                                                                             
			                          
			                    
			              
			                                            

		           
	 
 

                                                            
 
	                           
		      

	                       
		      

	                               

	                                                                                                           
	                                                                                                         

	            
		                                                  
		 
			                                   
				                           

			                                
				                        
		 
	 

	                         

	      
 

                                                                    
 
	                            
	                                                                                

	                                     

	                       
	 
		                                                                                  
		                                                                                    
		                                   
	 
	    
	 
		                                                              
	 

	                                

	            
		                       
		 
			                       
			 
				                                                                       
				                            
				                                  
					                                      
			 
		 
	 

	                                               
		           
 

                                                                      
 
	                                      
		      

	                                                                                                 
	                                                                 
	                                      

	                                               

	                                                                                 
	                                 
	 
		                                                                                      
	 
 

                                              
 
	                                                                                 

	               
	                                                          
	                                                            

	                                                                                                          
	                           

	                                                                                
	                                       

	            
		                                 
		 
			                       
			 
				                                                              
				                                                              
			 

			                          
				                  
		 
	 

	                            
	 
		                                                         
			                                                       
		    
			                                       

		           
	 
 

                                                 
 
	                                                                                 

	                                        
	                                                                           

	            
		                       
		 
			                                                     
		 
	 

	              
	 
		                                                                 

		                                                      
		 
			                                  
				                                                                         

			                                    
		 
		                                         
		 
			                                                     
			                                   
		 

		           
	 
 

                                                             
 
	                        
		      

	                                                                   

	                       
	 
		                                                    
		                                 
		 
			                             
			                                                                         
			                                                                              
			                                                                                                                                                                                  
			                                            
			                                                        
			                                         
			                                                                   

			            
				                                       
				 
					                                        
						                                
				 
			 
		 
	 

	                        
	                                                                     
	                                                                               
	                                                                                                                                                     
	                                       
	                                                   
	                                    
	                                              
	                                                              

	            
		                                  
		 
			                                   
				                           
		 
	 

	        
 
#endif         

#if CLIENT
void function CreateTargetingRui( entity player )
{
	if ( file.targetingRui != null )
		return

	if ( DoesPlayerHaveWeaponSling( player ) )
	{
		file.targetingRui = CreateCockpitPostFXRui( $"ui/targeting_rui.rpak", FULLMAP_Z_BASE )
		RuiSetResolutionToScreenSize( file.targetingRui )
	}
}

void function DestroyTargetingRui( entity player )
{
	if ( !DoesPlayerHaveWeaponSling( player ) )
	{
		if ( file.targetingRui != null )
		{
			RuiDestroyIfAlive( file.targetingRui )
			file.targetingRui = null
		}
	}
}

void function CreateTacticalTargetingFX( entity player )
{
	EndSignal( player, "OnDeath", "OnDestroy", "EndTargeting" )

	int fxId = GetParticleSystemIndex( FX_TACTICAL_RANGE_INDICATOR )
	int pulseVFX = StartParticleEffectOnEntity( player, fxId, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	float adjustedRange = file.bestTargetRange
	EffectSetControlPointVector( pulseVFX, 1, <adjustedRange, 0, 0> )

	int cockpitVFX = StartParticleEffectOnEntityWithPos( player, COCKPIT_TACT_IDLE, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, player.EyePosition(), <0, 0, 0> )
	EffectSetIsWithCockpit( cockpitVFX, true )
	EffectSetControlPointVector( cockpitVFX, 2, <1, .25, 0> )

	OnThreadEnd(
		function() : ( pulseVFX, cockpitVFX, player )
		{
			if ( EffectDoesExist( pulseVFX ) )
				EffectStop( pulseVFX, false, true )

			if( EffectDoesExist( cockpitVFX ) )
				EffectStop( cockpitVFX, false, true )
		}
	)

	WaitForever()
}

void function SetHasTargetForTargetingRui( entity player, bool hasTarget )
{
	if (file.targetingRui  != null )
	{
		RuiSetBool( file.targetingRui, "hasTarget", hasTarget )
	}
}

void function OnClientAnimEvent_DebuffZone( entity weapon, string name )
{
	if ( !IsValid( weapon ) )
		return

	if ( name == MISSILE_FIRE_SCREEN_SHAKE )
		ClientScreenShake( SHAKE_AMPLITUDE, SHAKE_FREQUENCY, SHAKE_DURATION, SHAKE_DIRECTION )
}

void function DebuffZone_OverheatDebuffEnabled( entity ent, int statusEffect, bool actuallyChanged )
{
	if( !OverheatStatusChanged( ent, actuallyChanged ) )
		return

	ent.Signal( "EndDebuff" )
	if( !ent.IsPlayerOverheating() )
		ent.SetPlayerOverheatState( true )

	thread WeaponVFXThread( ent )
	thread StartDebuff1pFX( ent )
}

void function DebuffZone_OverheatDebuffDisabled( entity ent, int statusEffect, bool actuallyChanged )
{
	if( !OverheatStatusChanged( ent, actuallyChanged ) )
		return

	ent.Signal( "EndDebuff" )
	if( ent.IsPlayerOverheating() )
		ent.SetPlayerOverheatState( false )
}

bool function OverheatStatusChanged( entity ent, bool actuallyChanged )
{
	entity viewPlayer = GetLocalViewPlayer()
	if( ent != viewPlayer || !actuallyChanged )
		return false

	return true
}

void function StartDebuff1pFX( entity player )
{
	player.EndSignal( "OnDeath", "OnDestroy", "BleedOut_OnStartDying", "EndDebuff" )

	var debuffProgressRui = CreateFullscreenRui( $"ui/debuff_progress.rpak", 32000 )

	int fxHandle
	fxHandle = StartParticleEffectOnEntityWithPos( player, COCKPIT_DEBUFF_ZONE_SCREEN_FX, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, player.EyePosition(), <0, 0, 0> )
	EffectSetIsWithCockpit( fxHandle, true )
	EffectSetControlPointVector( fxHandle, 2, <0, 1, 0> )
	EffectSetControlPointVector( fxHandle, 3, <0.8,0.8,0.8> )

	OnThreadEnd(
		function() : ( fxHandle, debuffProgressRui )
		{
			RuiDestroyIfAlive( debuffProgressRui )

			if ( EffectDoesExist( fxHandle ) )
				EffectStop( fxHandle, false, true )
		}
	)

	while( debuffProgressRui != null )
	{
		float currentOverheatValue = player.GetPlayerOverheatValue()
		RuiSetFloat( debuffProgressRui, "progress", currentOverheatValue / MAX_DEBUFF_OVERHEAT )

		int currentOverheatThreshold = int( currentOverheatValue / AMOUNT_BETWEEN_THRESHOLDS )
		if( currentOverheatThreshold < NUMBER_OF_THRESHOLDS - 1 )
		{
			EffectSetControlPointVector( fxHandle, 2, THRESHOLD_COLORS[currentOverheatThreshold] )
			EffectSetControlPointVector( fxHandle, 3, THRESHOLD_ALPHA[currentOverheatThreshold] )
		}

		WaitFrame()
	}
}

void function WeaponVFXThread( entity player )
{
	EndSignal( player, "OnDeath", "OnDestroy", "BleedOut_OnStartDying", "EndDebuff" )

	entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if( IsValid( activeWeapon ) && IsBitFlagSet( activeWeapon.GetWeaponTypeFlags(), WPT_PRIMARY ) && activeWeapon.DoesWeaponPlayerOverheat() )
	{
		activeWeapon.PlayWeaponEffect( DEBUFF_WEAPON_EFFECT_1P, $"", "MENU_ROTATE" )

		WaitFrame()
	}

	OnThreadEnd(
		function() : ( player )
		{
			if( !IsValid( player ) )
				return

			entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
			if( IsValid( activeWeapon ) && IsBitFlagSet( activeWeapon.GetWeaponTypeFlags(), WPT_PRIMARY ) )
			{
				activeWeapon.StopWeaponEffect( DEBUFF_WEAPON_EFFECT_1P, $"" )
			}
		}
	)

	while( true )
	{
		entity currentActiveWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

		if ( !IsValid( currentActiveWeapon ) || currentActiveWeapon == activeWeapon || !IsBitFlagSet( currentActiveWeapon.GetWeaponTypeFlags(), WPT_PRIMARY ) )
		{
			if ( IsValid( currentActiveWeapon ) && !IsBitFlagSet( currentActiveWeapon.GetWeaponTypeFlags(), WPT_PRIMARY ) )
			{
				activeWeapon = null
			}

			WaitFrame()
			continue
		}

		if( currentActiveWeapon.DoesWeaponPlayerOverheat() )
		{
			currentActiveWeapon.PlayWeaponEffect( DEBUFF_WEAPON_EFFECT_1P, $"", "MENU_ROTATE" )
			activeWeapon = currentActiveWeapon
		}

		WaitFrame()
	}
}

void function ServerCallback_CreateOverHeatIconRui( entity target )
{
	if( target in file.overheatIconRui )
		return

	entity player = GetLocalClientPlayer()
	var rui = RuiCreate( $"ui/overheat_on_player.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, RuiCalculateDistanceSortKey( player.EyePosition(), target.GetOrigin() ) )

	InitHUDRui( rui, true )

	RuiTrackFloat3( rui, "pos", target, RUI_TRACK_OVERHEAD_FOLLOW )
	RuiKeepSortKeyUpdated( rui, true, "pos" )

	file.overheatIconRui[target] <- rui

	thread TrackOverheatIconLifeTimeAndVisibility( player, target )
}

void function TrackOverheatIconLifeTimeAndVisibility( entity player, entity target )
{
	EndSignal( target, "OnDeath", "OnDestroy", "BleedOut_OnStartDying", "EndDebuff" )
	EndSignal( player, "OnDeath", "OnDestroy" )

	OnThreadEnd(
		function() : ( target )
		{
			RuiDestroyIfAlive( file.overheatIconRui[target] )
			delete file.overheatIconRui[target]
		}
	)

	while( DoesPlayerHaveOverheatDebuff( target ) )
	{
		bool isVisible = OverheatIconShouldBeVisible( player, target )

		RuiSetBool( file.overheatIconRui[target], "isDetectedBySeer", StatusEffect_HasSeverity( target, eStatusEffect.seer_detected ) )
		RuiSetBool( file.overheatIconRui[target], "isVisible", isVisible )
		RuiSetFloat( file.overheatIconRui[target], "progress", target.GetPlayerOverheatValue() / MAX_DEBUFF_OVERHEAT )

		WaitFrame()
	}
}

bool function OverheatIconShouldBeVisible( entity player, entity target )
{
	if( target.IsCloaked( true ) )
		return false

	if( target.IsPhaseShiftedOrPending() )
		return false

	if( PlayerCanSee( player, target, true, OVERHEAT_ICON_VISIBILITY_FOV ) )
		return true

	return false
}

float function DebuffZone_GetOverheatDuration()
{
	return file.debuffDuration
}
#endif         

float function DebuffZone_GetRangeSqr()
{
	float rangeSqr = file.bestTargetRange * file.bestTargetRange
	return rangeSqr
}
