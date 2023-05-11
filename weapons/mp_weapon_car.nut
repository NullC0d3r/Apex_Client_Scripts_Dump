global function MpWeaponCar_Init
global function OnWeaponActivate_Car
global function OnWeaponDeactivate_Car
global function OnWeaponPrimaryAttack_weapon_Car
global function OnWeaponReadyToFire_Car
global function OnWeaponReloadFailed_Car

global const string CMDNAME_CAR_AMMO_SWAP = "ClientCallback_CarHandleAmmoSwap"

#if SERVER
                                     
                                                
                                                         
#endif

#if CLIENT
global function Weapon_CAR_TryApplyAmmoSwap
#endif

const string CAR_ALT_AMMO_MOD = "alt_ammo"
const string CAR_AMMO_SWAP_MOD_FOR_RELOAD = "ammo_type_swap"
const string CAR_AMMO_SWAP_FAIL_SFX = "weapon_car_CantSwapAmmo"

const vector CAR_AMMO_EMISSIVE_LIGHT_COLOR = <0.953125, 0.6015625, 0.2890625>                
const vector CAR_AMMO_EMISSIVE_HEAVY_COLOR = <0.41796875, 0.8046875, 0.65625>                 

const VFX_COCKPIT_HEALTH = $"VFX_NAME_"


void function MpWeaponCar_Init()
{
#if SERVER
	                                                                     
#endif
	Remote_RegisterServerFunction( CMDNAME_CAR_AMMO_SWAP )

	PrecacheParticleSystem( $"P_car_reac_spinners_small" )
	PrecacheParticleSystem( $"P_car_reac_spinners_small_2" )
	PrecacheParticleSystem( $"P_car_reac_spinners_small_3" )
	PrecacheParticleSystem( $"P_car_reac_spinners_small_4" )
	PrecacheParticleSystem( $"P_car_rt01_reac_spinners_small" )
	PrecacheParticleSystem( $"P_car_rt01_reac_spinners_small_2" )
	PrecacheParticleSystem( $"P_car_rt01_reac_spinners_small_3" )
	PrecacheParticleSystem( $"P_car_rt01_reac_spinners_small_4" )
	PrecacheParticleSystem( $"P_car_lvl2_kill_reac_spinners" )
	PrecacheParticleSystem( $"P_car_reac_spinners_kill_all_small" )
	PrecacheParticleSystem( $"P_car_rt01_reac_spinners_kill_all_small" )
	PrecacheParticleSystem( $"p_car_rear_reactor_glow" )
	PrecacheParticleSystem( $"p_car_rt01_rear_reactor_glow" )
	PrecacheParticleSystem( $"p_car_spinning_reactor_glow" )
	PrecacheParticleSystem( $"p_car_rt01_spinning_reactor_glow" )
	PrecacheParticleSystem( $"P_car_reac_spinners_lvl4" )
	PrecacheParticleSystem( $"P_car_reac_spinners_3p" )
	PrecacheParticleSystem( $"P_car_rt01_reac_spinners_lvl4" )
	PrecacheParticleSystem( $"p_car_lvl4_spinning_reactor_glow" )




}

void function OnWeaponActivate_Car( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return
#if SERVER
	                                                  
	 
		                                           
		 
			                                                
		 
		    
		 
			                          
		 
	 
#endif

	#if CLIENT
		thread UpdatePoseParameter( weapon )
	#endif

#if CLIENT
	if ( InPrediction() && weapon.IsPredicted() )
#endif
	{
		             
		if ( weapon.HasMod( CAR_ALT_AMMO_MOD ) )
		{
			weapon.SetScriptVector( CAR_AMMO_EMISSIVE_LIGHT_COLOR )
		}
		else              
		{
			weapon.SetScriptVector( CAR_AMMO_EMISSIVE_HEAVY_COLOR )
		}
	}
}

void function OnWeaponDeactivate_Car( entity weapon )
{
}


void function OnWeaponReadyToFire_Car( entity weapon )
{
	if ( !IsValid( weapon ) )
		return

#if SERVER
	                                                      
	  	                                                
#endif
}

var function OnWeaponPrimaryAttack_weapon_Car( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	if ( !IsValid( weapon ) )
		return 0

	if ( !weapon.IsWeaponX() )
		return 0

	int clipCount = weapon.GetWeaponPrimaryClipCount()

	if ( clipCount > 0 )
	{
		weapon.FireWeapon_Default( attackParams.pos, attackParams.dir, 1.0, 1.0, false )
		return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
	}
	else if ( clipCount <= 0 )
	{
		entity player = weapon.GetWeaponOwner()

		if ( !IsValid(player) )
			return 0
#if SERVER
		                                     
#endif
#if CLIENT
		HandleCarDryFire( player, weapon, clipCount )
#endif
		return 0
	}

}

void function OnWeaponReloadFailed_Car( entity weapon )
{
#if SERVER
	                            
	                                       

	                         
		      

	                                     
#endif
}

#if CLIENT
void function Weapon_CAR_TryApplyAmmoSwap( entity player, entity weapon )
{
	if ( !IsValid( player ) || !IsValid( weapon ) )
		return

	if ( weapon.HasMod( CAR_AMMO_SWAP_MOD_FOR_RELOAD ) || weapon.IsReloading() )
		return

	Remote_ServerCallFunction( CMDNAME_CAR_AMMO_SWAP )
}
#endif

#if SERVER
                                                               
 
	                         
		      

	                                                                        

	                         
		      

	                                                     
		      

	                                         

	                                   
		      

	                              
		      

	                                                                              
	 
		                                                                                                
			                           

		                                
	 
 
#endif

#if SERVER
                                                            
 
	                                              
		      

	                            		                                                   
	                            		                                                  
	                    				                                   

	                                                     
	 
		                                               
		                                  
		                                                      
		                                                                                  
		                                                                                                                              
	 
	                                                         
	 
		                                            
		                                 
		                                                       
		                                                                                  
		                                                                                                                              
	 
	    
	 
		                                                                       
	 
 
#endif

#if SERVER
                                                                 
 
	                                              
		      

	                          
		      

	                            		                                                   
	                            		                                                  

	                            		                                                            
	                            		                           
	                            		                                          

	                         			                                                                                                 
	                          			                                    
	                                 	                                                 

	                            		                                    
	                            		                               

	                    				                                 


                        
	                                                                                             
	 
		                          
		      
	 
                              

	                                
	 
		                          
		      
	 

	                                                                                   
	 
		      
	 

	                     
	 
		                                                   
		 
			                           
		 
		                                                           
		 
			                           
		 
		                                                                                        
		 
			                                               
			                                    
			                                                        
			                                                                                  
			                                                                                                                              
		 
		                                                                                       
		 
			                                            
			                                 
			                                                       
			                                                                                  
			                                                                                                                              
		 
	 
 
#endif

#if SERVER
                                                                               
 
	                              
	 
		                         
			      

		                          
			      

		                                       
		                       
			      
                        
			                                                                
        

		                                                                
		                                                           
		                                                                               
		                                                                              
		                                                                                        
		                                                       
		                   			   

		                                           
			                                       
		                                                 
			                                      

		                                                                        


		                                
		                                                                                                                        
		                                                          
		                                     
			                              

		                                               
			                                                            

		                                
		 
			                                     
		 

		                                                        
		                                        
		                     
		 
			                                                                                                                                       
			                                                                

			                                                        
			                                               
		 

		               
		 
			                                                           
			                                
			 
				                                             
				                          
			 
		 
		    
		 
			                                                                                  
			                                  
			 
				                                             
				                          
			 
		 

                   
			                                                   

			                           
				                                                                                                               
        
	 
 
#endif

#if SERVER
                                                                                
 
	                                            
			      

	                                       
		                                            
	                                             
		                                             
 
#endif

#if SERVER
                                                                        
 
	                         
		      

	                                                    
		                                                
 
#endif

#if CLIENT
void function HandleCarDryFire( entity player, entity weapon, int clipCount )
{
	if ( !IsValid( player ) )
	{
		Warning( "CAR HandleCarDryFire reached with invalid player" )
		return
	}
	int currentHighcalStockPile 		= player.AmmoPool_GetCount( eAmmoPoolType.highcal )
	int currentLightStockPile   		= player.AmmoPool_GetCount( eAmmoPoolType.bullet )
	if ( clipCount <= 0 && currentHighcalStockPile <= 0 && currentLightStockPile <= 0 && player.IsInputCommandPressed(IN_ATTACK) )
	{
		weapon.DoDryfire()
	}
}
#endif

#if CLIENT
void function UpdatePoseParameter( entity weapon )
{
	AssertIsNewThread()

	if ( !IsValid( weapon ) )
		return

	weapon.EndSignal( "OnDestroy" )

	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) || !IsLocalViewPlayer( player ) )
		return

	player.EndSignal( "OnDeath" )

	bool inLightAmmoModeLastFrame = weapon.HasMod( CAR_ALT_AMMO_MOD )
	float swapAmmoTime = 0.0
	float swapAnimDuration = 0.25
	weapon.SetScriptPoseParam0( 0.0 )

	while( true )
	{
		bool inLightAmmoMode	= weapon.HasMod( CAR_ALT_AMMO_MOD )

		if( inLightAmmoMode != inLightAmmoModeLastFrame )
		{
			swapAmmoTime = Time()
			inLightAmmoModeLastFrame = inLightAmmoMode
		}

		if( Time() - swapAmmoTime <= swapAnimDuration )
		{
			float swapAnimFrac = Clamp( Time() - swapAmmoTime, 0.0, swapAnimDuration ) / swapAnimDuration
			float poseParam = inLightAmmoMode ? swapAnimFrac : 1.0 - swapAnimFrac
			weapon.SetScriptPoseParam0( poseParam )
		}

		WaitFrame()
	}
}
#endif
