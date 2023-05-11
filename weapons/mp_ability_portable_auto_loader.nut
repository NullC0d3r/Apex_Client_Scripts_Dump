global function MpAbilityPortableAutoLoader_Init
global function IsBallisticUltActive
global function DoesPlayerHaveAutoLoaderBuff
global function OnWeaponAttemptOffhandSwitch_portableAutoLoader
global function OnWeaponTossReleaseAnimEvent_ability_portable_auto_loader
global function OnWeaponActivate_ability_portable_auto_loader

const float AUTO_LOADER_DURATION = 30.0
const float AUTOLOADER_RANGE = 256.0
const vector AUTOLOADER_START_EFFECT_COLOR = <134, 182, 255>
const float AUTOLOADER_START_EFFECT_SIZE = 768.0
const float	MAX_DISTANCE = 512.0 * 512.0

const float ADDITIONAL_TIME = 5.0

int COCKPIT_AUTO_LOADER_SCREEN_FX
const asset AUTO_LOADER_1P_SCREEN_FX = $"P_clbr_ulti_screen"

const asset AUTO_LOADER_FLASH_FX = $"P_clbr_ulti_backpack_init"
const asset AUTO_LOADER_AURA_FX = $"P_clbr_ulti_buff_body"
const asset AUTO_LOADER_BEAM_FX = $"P_clbr_ulti_backpack_connect"
const asset AUTO_LOADER_BEAM_FX_INIT = $"P_clbr_ulti_backpack_cnct_init"

const asset AUTO_LOADER_BACKPACK_ARM_IDLE_L = $"P_clbr_ulti_backpack_arm_idle_l"
const asset AUTO_LOADER_BACKPACK_ARM_IDLE_R = $"P_clbr_ulti_backpack_arm_idle_r"
const asset AUTO_LOADER_BACKPACK_JET_IDLE = $"P_clbr_ulti_backpack_jet_idle"

const string BALLISTIC_ULT_ACTIVATED_1P = "Ballistic_Ult_Activate_1P"
const string BALLISTIC_ULT_ACTIVATED_3P_FRIENDLY = "Ballistic_Ult_Activate_3P_Friendly"
const string BALLISTIC_ULT_ACTIVATED_3P_ENEMY = "Ballistic_Ult_Activate_3P_Enemy"
const string BALLISTIC_ULT_DEACTIVATED_1P = "Ballistic_Ult_Deactivate_1P"
const string BALLISTIC_ULT_DEACTIVATED_3P_FRIENDLY = "Ballistic_Ult_Deactivate_3P_Friendly"
const string BALLISTIC_ULT_DEACTIVATED_3P_ENEMY = "Ballistic_Ult_Deactivate_3P_Enemy"
const string BALLISTIC_ULT_TEAMMATE_DEACTIVATED_3P_FRIENDLY = "Ballistic_Ult_Deactivate_Teammate_3P"
const string BALLISTIC_ULT_TEAMMATE_DEACTIVATED_3P_ENEMY = "Ballistic_Ult_Deactivate_Teammate_3P"
const string BALLISTIC_ULT_ENDING_SOON_1P = "Ballistic_Ult_5SecRemaining_1P"
const string BALLISTIC_ULT_TIME_ADDED = "Ballistic_Ult_TimeAdded_1P"
const string BALLISTIC_FRIEDNLY_NOTIFY_1P = "Ballistic_Ult_Activate_Teammate_1P"
const string BALLISTIC_FRIEDNLY_NOTIFY_3P = "Ballistic_Ult_Activate_Teammate_3P"
const string BALLISTIC_FRIENDLY_BUFF_DEACTIVATE = "Ballistic_Ult_Deactivate_Teammate_1P"

const string BALLISTIC_ULT_ACTIVE_NETVAR = "ballisticUltIsActive"

struct
{
	float autoLoaderDuration
	float additionalTime
} file

void function MpAbilityPortableAutoLoader_Init()
{
	PrecacheParticleSystem( AUTO_LOADER_1P_SCREEN_FX )
	COCKPIT_AUTO_LOADER_SCREEN_FX = PrecacheParticleSystem( AUTO_LOADER_1P_SCREEN_FX )
	PrecacheParticleSystem( AUTO_LOADER_FLASH_FX )
	PrecacheParticleSystem( AUTO_LOADER_AURA_FX )
	PrecacheParticleSystem( AUTO_LOADER_BEAM_FX )
	PrecacheParticleSystem( AUTO_LOADER_BACKPACK_ARM_IDLE_L )
	PrecacheParticleSystem( AUTO_LOADER_BACKPACK_ARM_IDLE_R )
	PrecacheParticleSystem( AUTO_LOADER_BACKPACK_JET_IDLE )
	PrecacheParticleSystem( AUTO_LOADER_BEAM_FX_INIT )

	RegisterSignal( "AutoLoaderEnded" )
	RegisterSignal( "EndUltBackpackVFX" )

	file.autoLoaderDuration = GetCurrentPlaylistVarFloat( "ballistic_ult_auto_loader_duration", AUTO_LOADER_DURATION )
	file.additionalTime = GetCurrentPlaylistVarFloat( "ballistic_ult_additional_time", ADDITIONAL_TIME )

	#if SERVER
		                                                        
		                                                                         
	#endif

	#if CLIENT
		RegisterConCommandTriggeredCallback( "+offhand4", AttemptSwapToSlingWhileUltIsActive )
		StatusEffect_RegisterEnabledCallback( eStatusEffect.has_auto_loader, AutoLoaderScreenVFXEnabled )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.has_auto_loader, AutoLoaderScreenVFXDisabled )
	#endif

	RegisterNetworkedVariable( BALLISTIC_ULT_ACTIVE_NETVAR, SNDC_PLAYER_GLOBAL, SNVT_BOOL )
}

void function OnWeaponActivate_ability_portable_auto_loader( entity weapon )
{
	#if SERVER
		                                       
		                                                           
	#endif
}

bool function IsBallisticUltActive( entity player )
{
	return player.GetPlayerNetBool( BALLISTIC_ULT_ACTIVE_NETVAR )
}

bool function DoesPlayerHaveAutoLoaderBuff( entity player )
{
	return StatusEffect_HasSeverity( player, eStatusEffect.has_auto_loader )
}

bool function OnWeaponAttemptOffhandSwitch_portableAutoLoader( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	if( IsBallisticUltActive( player ) )
		return false

	return true
}

var function OnWeaponTossReleaseAnimEvent_ability_portable_auto_loader( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	#if SERVER
		                                                                                        
		                                                        

		                                               
		                                                                                                                                                                                    
	#endif

	PlayerUsedOffhand( ownerPlayer, weapon )

	int ammoReq = weapon.GetAmmoPerShot()
	return ammoReq
}

#if SERVER
                                                               
 
	                         
		      

	                                                                                       

	                           

	                                                                           
	                                                                                                
	                                                                            

	                                         
	                                                                                

	                                                          
	                                   
	 
		                                                                                                                                        
		                   
		 
			                                 
			                                                                             
			                                                                                                                                

			                                  

			                                                                 
				                                           

			                                                     
			                                                                
		 
	 


	                                                            

	                                             
	 
		                                               
		                                                                                    
	 

	            
		                             
		 
			                                                                                   
			                                                   

			                                                                             
			                                                                                                  
			                                                                              

			                                          
			 
				                                                   
				                                                                                                  
				                                                            
				                                                           
				                                                         

				                                                  
				                                                                                                       

				                                        

				                                                          
				                                                                                             
				
				                       
				 
					                                                      
					                                 
					                                     

					                                                                   
						                                             

					                                                       
					                                                         
				 
			 

			                                                             

			                                  
		 
	 

	                                                                                                 

	                                
	 
		                                                                     

		                                 
		 
			                           
				        

			                        
				        

			                                         
				        

			                                                                           
			                                                                                  
			 
				                                           
				                                                                                 
			 
		 

		           

		                                                                                           
	 

	                                                                             
	                                
	 
		                                                                                     
		                   
			     

		           

		                                                                      
	 

	                              
	 
		                                                   
		                                                            
			      

		                                                                        
		 
			           
		 
	 
 

                                                       
 
	                                                                                       

	             
	 
		                                                   
		                          
		 
			                                                  
			                                        

			                     
			 
				                                                          
				                                                      
			 

			      
		 
		           
	 
 

                                                                
 
	                                                                               
	                                                          
	                                                                                  
	                                                          

	                                                                               
	                                                                                 

	                    
	                    

	                                                                        
	                                                                                                                                                                          
	                                                                                                    
	                                

	                                                                        
	                                                                                                                                                                          
	                                                                                                    
	                                

	                                                             
	                                                                     
	                                
	                                        
	                             

	                                                      
	                                                      
	                                                      
	                                                        
	                             
	                                  
	                                  
	                       

	                                                              
	                                                                      
	                                 
	                                         
	                              

	                                                          
	                                                          
	                                                          
	                                                             
	                                 
	                                     
	                                      
	                           

	                                                                                                              
		                        
			                

		                              
			                      

		                            
			                    

		                               
			                       

		                               
			                       

		                               
			                       
	   

	        

	      
 

                                                             
 
	                                                                                       

	              
	                  
	                  
	                       
	                       

	                                                                               
	                                                              
	                                                                                                                                                           
	                                                       
	                                                                                                     
	                                                                        
	                          

	                                                                               
	                                                                                                                                                                        
	                                                                                                  
	                              

	                                                                               
	                                                                               
	                                                                                                                                                                        
	                                                                                                  
	                              

	                                                                             
	                                                                               
	                                                                                                                                                                         
	                                                                                                       
	                                   

	                                                                             
	                                                                                                                                                                         
	                                                                                                       
	                                   

	            
		                                                                                       
		 
			                        
				                 

			                            
				                     

			                            
				                     

			                                 
				                          

			                                 
				                          
		 
	 

	             
 

                                                                                                           
 
	                                  
		      

	                                                   
		      

	                                 
		                                                    
	                                                                                         

	                                                                                    

	                                  
	 
		                                                                                 
		                                                                                                           
	 


	                                 

	                                                            
	                                                                

	                                                                                                                   
	                             
	                                                        

	                                      
		                                                                 

	            
		                                                    
		 
			                                                                  

			                          
				                      

			                                                                     
			                                                           
			                                                           

			                                  
			 
				                                                                                                                             
				                                                                                                       
				                                                                                       

				                         
					                                    
			 

			                                                                                   
			                                    
			 
				                                     
				 
					                                 
				 
			 
		 
	 

	                                                  
	 
		                                                                         
		                        
		 
			                                             
			                                                              
			 
				                                      
				 
					                              

					                                                             
						                                                   
				 
			 
		 

		                                                                                                   

		                                                        
		 
			                                                                                 
			                           
		 
		                                                            
		 
			                            
			                                                           
		 

		           
	 
 

                                                                                          
 
	                           
		      

	                                               
		      

	                                        
	 
		                                                     
	 
 

                                                                                           
 
	                           
		      

	                                               
		      

	                                                     
 

                                                                                     
 
	                             
	                                                            

	                                 
	 
		                                               
		 
			                                                                                              
			                                                         

			                                                                     
			                                                                                    
			                                                                             

                             
			                                                                                                                
        
		 
	 
 
#endif         

#if CLIENT
void function OnPrimaryWeaponStatusUpdate_FastReloadIcon( entity player, var weaponRui, bool turnOn )
{
	if( turnOn )
	{
		RuiSetBool( weaponRui, "showPassiveBonusIconAmmo", true )
		RuiSetImage( weaponRui, "passiveBonusIconAmmo", $"rui/hud/character_abilities/icon_caliber_fast_reload_dongle_2x_size" )
		RuiSetBool( weaponRui, "showUltimateBonusWeaponInfo", true )
		RuiSetString( weaponRui, "ultimateBonusWeaponInfoText", Localize( "#MOD_FAST_RELOAD_NAME" ) )
	}
	else
	{
		RuiSetBool( weaponRui, "showPassiveBonusIconAmmo", false )
		RuiSetImage( weaponRui, "passiveBonusIconAmmo", $"" )
		RuiSetBool( weaponRui, "showUltimateBonusWeaponInfo", false )
		RuiSetString( weaponRui, "ultimateBonusWeaponInfoText", "" )
	}
}

void function AttemptSwapToSlingWhileUltIsActive( entity player )
{
	if ( player != GetLocalViewPlayer() || IsPlayerWeaponSlingEmpty( player ) || IsPlayerHoldingSlingWeapon( player ) )
		return

	if ( IsBallisticUltActive( player )  )
		Remote_ServerCallFunction( "ClientCallback_Sur_EquipSling" )
}

void function AutoLoaderScreenVFXEnabled( entity ent, int statusEffect, bool actuallyChanged )
{
	entity viewPlayer = GetLocalViewPlayer()
	if( viewPlayer != GetLocalClientPlayer() || ent != viewPlayer )
		return

	thread AutoLoader_1PFX_Thread( ent )
}

void function AutoLoaderScreenVFXDisabled( entity ent, int statusEffect, bool actuallyChanged )
{
	entity viewPlayer = GetLocalViewPlayer()
	if( viewPlayer != GetLocalClientPlayer() || ent != viewPlayer )
		return

	ent.Signal( "AutoLoaderEnded" )
}

void function AutoLoader_1PFX_Thread( entity player )
{
	player.EndSignal( "OnDeath", "OnDestroy", "BleedOut_OnStartDying", "AutoLoaderEnded" )

	int fxHandle
	fxHandle = StartParticleEffectOnEntityWithPos( player, COCKPIT_AUTO_LOADER_SCREEN_FX, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, player.EyePosition(), <0, 0, 0> )
	EffectSetIsWithCockpit( fxHandle, true )
	EffectSetControlPointVector( fxHandle, 1, <255, 255, 255> )
	EffectSetControlPointVector( fxHandle, 3, <0.8,0.8,0.8> )

	OnThreadEnd(
		function() : ( fxHandle )
		{
			if ( EffectDoesExist( fxHandle ) )
				EffectStop( fxHandle, false, true )
		}
	)

	for ( ;; )
	{
		if ( !EffectDoesExist( fxHandle ) )
			break

		EffectSetControlPointVector( fxHandle, 1, <1.0, 999, 0> )

		WaitFrame()
	}
}
#endif         
