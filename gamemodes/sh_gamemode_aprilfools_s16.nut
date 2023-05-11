                                
                                                                                                                                                       
                                                                                        

                                                          

global function AprilFools_S16_Init
global function IsAprilFools_S16

#if CLIENT || SERVER
global function AprilFools_S16_ShouldOverridePing
#endif                    

#if CLIENT
global function ServerCallback_AprilFools_S16_TriggerMozamPingOnClient
#endif          

#if SERVER
                                                          
#endif          

#if DEV && SERVER
                                       
#endif

#if SERVER
                                
                                               
                                   
                                      

                                             
                                               
                                             
                                              
                                              

                                             

                                                                                                                                             
                                                                                                                                                    
#endif          

#if CLIENT || SERVER
                                                                                                
const string MOZAMBIQUE_WEAPON_REF = "mp_weapon_shotgun_pistol_gold"

const string ENERGY_MOZAMBIQUE_WEAPON_REF = "mp_weapon_shotgun_pistol_energy"
const string HEAVY_MOZAMBIQUE_WEAPON_REF = "mp_weapon_shotgun_pistol_heavy"
const string LIGHT_MOZAMBIQUE_WEAPON_REF = "mp_weapon_shotgun_pistol_light"
const string SNIPER_MOZAMBIQUE_WEAPON_REF = "mp_weapon_shotgun_pistol_sniper"
const string ARROW_MOZAMBIQUE_WEAPON_REF = MOZAMBIQUE_WEAPON_REF                               

                                                                                                                                                                                                   
const array < string > MOZAM_REFS_ARRAY = [ MOZAMBIQUE_WEAPON_REF, ENERGY_MOZAMBIQUE_WEAPON_REF, HEAVY_MOZAMBIQUE_WEAPON_REF, LIGHT_MOZAMBIQUE_WEAPON_REF, SNIPER_MOZAMBIQUE_WEAPON_REF ]
                                                                                                                            
                                
const string MOZAMBIQUE_WEAPON_REF_NESSIE = "mp_weapon_shotgun_pistol_april_fools"
const array < string > NO_OVERRIDE_WEAPON_REFS = [ MOZAMBIQUE_WEAPON_REF, ENERGY_MOZAMBIQUE_WEAPON_REF, HEAVY_MOZAMBIQUE_WEAPON_REF, LIGHT_MOZAMBIQUE_WEAPON_REF, SNIPER_MOZAMBIQUE_WEAPON_REF, "mp_weapon_shotgun_pistol", MOZAMBIQUE_WEAPON_REF_NESSIE ]
     
                                                                                                                                                                                                                            
                                      
#endif                    

const int INVALID_PING_TYPE = -1

#if DEV
global const bool APRILFOOLS_S16_DISPLAY_DEBUG = false
const float APRILFOOLS_S16_DEBUG_DRAW_DURATION = 60.0
#endif       

#if SERVER
                                      
                            
 
	        
                                 
		       
                                       
	      
 

                                                                
                                                                
 
	                                                                  
                                 
		                                                                  
                                       
 

      
 
                                 
		                           
                                       
	                                                                                  
	                                                                                                                  
	                                       
	                             
	                            
	                            
	                             
	                            

                                 
		                             
                                       
      
#endif          

void function AprilFools_S16_Init()
{
	#if SERVER
                                  
			                                                                                                                                                                                       
			                               

			                                                              
			                                                     
				                                                                        
                                        
	#endif          

	if ( !IsAprilFools_S16() )
		return

	#if SERVER
		                                      
		                                         

		                                          
			                                           
	#endif

	Remote_RegisterServerFunction( "ClientCallback_AprilFools_S16_OverridePing", "entity", "int", 0, ePingType._count )
	Remote_RegisterClientFunction( "ServerCallback_AprilFools_S16_TriggerMozamPingOnClient", "entity" )
}

#if SERVER
                                                                                                                                                            
                                                    
 
	                                                                                                                                                                                                                                            

	                                                        
	                                          
	 
		                                          
		 
			                                          
		 
	       
		                                        
		 
			                                                                                                                                         
		 
	             
	 

	                                                   
	                                                                                                                                                 
	                                                                                                                                              
	                                                                                                                                              
	                                                                                                                                                 
	                                                                                                                                              

                                 
		                                                                                                                                                 
		                                                                   

		       
			                                                                                                  
			 
				                                                                                                                                                                  
			 
		             
                                       
 
#endif          

bool function IsAprilFools_S16()
{
	return GetCurrentPlaylistVarBool( "is_april_fools_s16", false )
}

#if CLIENT || SERVER
bool function AprilFools_S16_shouldAllowPlayerPingKill()
{
	return GetCurrentPlaylistVarBool( "april_fools_s16_is_player_ping_kill_enabled", false )
}
#endif                    

#if CLIENT || SERVER
float function AprilFools_S16_GetPingOverrideChance()
{
	return GetCurrentPlaylistVarFloat( "april_fools_s16_ping_override_chance", 1.0 )
}
#endif                    

#if CLIENT || SERVER
float function AprilFools_S16_GetSpawnAmmoChance()
{
	return GetCurrentPlaylistVarFloat( "april_fools_s16_spawn_ammo_chance", 0.0 )
}
#endif                    

#if CLIENT || SERVER
bool function AprilFools_S16_MozamReskinEnabled()
{
	return GetCurrentPlaylistVarBool( "april_fools_s16_mozam_reskin_enabled", true )
}
#endif                    

#if CLIENT || SERVER
                                                                     
bool function AprilFools_S16_ShouldOverridePing( int pingType, entity pingedEnt )
{
	bool shouldOverridePingData = false

	switch( pingType )
	{
		                                                                                                                                                                   
		case ePingType.LOOT:
			shouldOverridePingData = AprilFools_S16_ShouldOverrideLootPing( pingedEnt )
			break

		                                                          
                     
		case ePingType.HOVERVEHICLE:
		case ePingType.HOVERVEHICLE_ALLY:
		case ePingType.HOVERVEHICLE_ENEMY:
		case ePingType.HOVERVEHICLE_NAG:
			shouldOverridePingData = true
			break
      
		                                                                         
		case ePingType.ZIPLINE:
                
			if ( pingType != ePingType.ZIPRAIL && !( pingedEnt.Zipline_IsCurvedZipline() ) )
      
			{
				shouldOverridePingData = true
			}
			break

		                                                           
		case ePingType.FLYER:
		case ePingType.FLYER_CAGED:
		case ePingType.PING_PROWLER:
		case ePingType.PING_SPIDER:
			shouldOverridePingData = true
			break

		                                             
		case ePingType.ENEMY_LOOTSOURCE:
                   
		case ePingType.STORY_MARVIN:
		case ePingType.LOOT_MARVIN:
                         
			shouldOverridePingData = true
			break

		                                                                                              
		case ePingType.LOOT_DRONE:
			entity drone = GetLootDroneForHitEnt( pingedEnt )
			if ( IsValid( drone ) )
				shouldOverridePingData = true
			break

		                                                                                                
		case ePingType.LOOT_ROLLER:
			entity roller = GetLootRollerForHitEnt( pingedEnt )
			if ( IsValid( roller ) )
				shouldOverridePingData = true
			break

		                                                                                                          
		case ePingType.DOOR:
		case ePingType.DOOR_OPEN:
			shouldOverridePingData = AprilFools_S16_CanDoorBeDestroyed( pingedEnt )
			break

		                                                                   
		case ePingType.ENEMY_GENERAL :
		case ePingType.ENEMY_SPECIFIC :
                           
		case ePingType.ENEMY_HEALING_HEALTH :
		case ePingType.ENEMY_HEALING_SHIELD :
      
		case ePingType.ENEMY_REVIVING :
		case ePingType.ENEMY_TETHERED :
		case ePingType.VALK_ULT_ENEMY_TAKING_OFF :
		case ePingType.VANTAGE_SPOTS_ENEMY :
		case ePingType.BLEEDOUT :
			if ( AprilFools_S16_shouldAllowPlayerPingKill() || AprilFools_S16_CanNPCEnemyPingBeOverridden( pingedEnt ) )                                                     
				shouldOverridePingData = true
			break

		default:
			shouldOverridePingData = false
			break
	}

	                                                                              
	if ( shouldOverridePingData )
	{
		float randVal = RandomFloat( 1.0 )
		if ( AprilFools_S16_GetPingOverrideChance() < randVal )
			shouldOverridePingData = false
	}

	#if DEV
		if ( APRILFOOLS_S16_DISPLAY_DEBUG  )
		{
			string enumName = GetEnumString( "ePingType", pingType )
			printf("APRILFOOLS_S16: AprilFools_S16_ShouldOverridePing called for pingtype: " + enumName + " pingEnt: " + pingedEnt + " should Override the Ping: " + shouldOverridePingData )
		}
	#endif       

	return shouldOverridePingData
}
#endif                    

#if CLIENT || SERVER
                                                                                           
bool function AprilFools_S16_ShouldOverrideLootPing( entity pingEnt )
{
	bool shouldReplaceLoot = false

	if ( IsValid( pingEnt ) )
	{
		LootData data = SURVIVAL_Loot_GetLootDataByIndex( pingEnt.GetSurvivalInt() )

		if ( SURVIVAL_Loot_IsRefValid( data.ref ) )
		{
			                                                                                                                                                                    
			if ( data.lootType == eLootType.ORDNANCE || data.lootType == eLootType.MARVIN_ARM )
			{
				shouldReplaceLoot = true
			}
			else if ( data.lootType == eLootType.MAINWEAPON )
			{
				                                                          
				shouldReplaceLoot = true
				foreach ( ref in NO_OVERRIDE_WEAPON_REFS )
				{
					if ( data.baseWeapon == ref || data.ref == ref )
					{
						shouldReplaceLoot = false
						break
					}
				}
			}
		}
	}

	#if DEV
		if ( APRILFOOLS_S16_DISPLAY_DEBUG )
			printf("APRILFOOLS_S16: AprilFools_S16_ShouldOverrideLootPing called for pingEnt: " + pingEnt + " and should replace loot: " + shouldReplaceLoot )
	#endif       

	return shouldReplaceLoot
}
#endif                    

#if CLIENT || SERVER
                                                                                                           
bool function AprilFools_S16_CanDoorBeDestroyed( entity pingEnt )
{
	bool shouldReplaceDoor = false
	string doorScriptName

	if ( IsValid( pingEnt ) )
	{
		doorScriptName = pingEnt.GetScriptName()

		if ( doorScriptName == "" || ( doorScriptName != "survival_door_model" && doorScriptName != "survival_door_plain" && doorScriptName != "survival_door_sliding" && doorScriptName != "survival_door_blockable" ) )
			shouldReplaceDoor = true
	}

	#if DEV
		if ( APRILFOOLS_S16_DISPLAY_DEBUG )
			printf("APRILFOOLS_S16: AprilFools_S16_CanDoorBeDestroyed called for pingEnt: " + pingEnt + " the script name is: " + doorScriptName + " and shouldReplaceDoor: " + shouldReplaceDoor )
	#endif       

	return shouldReplaceDoor
}
#endif                    

#if SERVER || CLIENT
                                                                       
bool function AprilFools_S16_CanNPCEnemyPingBeOverridden( entity pingEnt )
{
	bool shouldAllowEnemyPing = false

	if ( IsValid( pingEnt ) && pingEnt.IsNPC() )
	{
		string pingEntAISettingsName = pingEnt.GetAISettingsName()

		switch( pingEntAISettingsName )
		{
			case "npc_soldier_spcore_rifleman":
			case "npc_soldier_spcore_shotgunner":
			case "npc_boss_guts":
			case "npc_training_dummy":
			case "npc_dummie_combat":
                                  
			case "npc_nessie":
        
			case "npc_soldier_spcore_sniper":
			case "npc_spectre_outlands":
			case "npc_stalker_outlands":
			case "npc_super_spectre_melee":
			case "npc_drone_plasma":
			case "npc_frag_drone_outlands":
			case "npc_frag_drone_treasure_tick":
			case "npc_titan_outlands":
			case "npc_marvin":
			             
                     
			case "npc_prowler":
        
                    
                     
        
                           
			case "npc_spider_jungle":
        
			case "npc_soldier_infected":
				shouldAllowEnemyPing = true
				break
			default:
				break
		}
	}

	#if DEV
		if ( APRILFOOLS_S16_DISPLAY_DEBUG )
			printf("APRILFOOLS_S16: AprilFools_S16_CanNPCEnemyPingBeOverridden called for pingEnt: " + pingEnt + " and shouldAllowEnemyPing: " + shouldAllowEnemyPing )
	#endif       

	return shouldAllowEnemyPing
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

#if SERVER
                                                              
                                                                     
 
	              
	                       

	                                                    
	                                                      
	 
		                    
	 

	                                            
	                                          
	                                                               
	                        
	                                                      
	 
		                     
		                              
		 
			                
			     
		 
	 
	
	                                                                                                                                
	                                                                                                                                               
	                                                                                                                                                        
	                                                                                                                                                                   
	                                                   
	 
		                                                        
	 
	    
	 
		                                                       
	 

	                
 
#endif          

#if CLIENT
                                                                                    
void function ServerCallback_AprilFools_S16_TriggerMozamPingOnClient( entity mozamEnt )
{
	entity localPlayer = GetLocalClientPlayer()

	if ( !IsValid( localPlayer ) || !IsValid( mozamEnt ) )
		return

	Send_PingLoot( localPlayer, mozamEnt, null )
}
#endif          

                                
#if SERVER
                                                                     
                                                               
 
	                      
		      

	                              

	              
		      

	                                                       

	                                                                                         
	 
		                          

		                                                                                       
		                                                                                                                          
			                                                                     
	 
 
#endif          
                                      

#if SERVER
                                                                 
 
	                   
	 
		                                  
			                                                                                                
			     

		                                 
			                                                                                                     
			     

		                                 
			                                                                                                
			     

		                                  
			                                                                                                     
			     
	 
 

                                                                
 
	        
	                     
	 
		                                                    
		                                                        
		                                              
	 
 
#endif

#if DEV && SERVER
                                                      
 
	                                  

	                            
		                            
		                            
		                             
		                             
		                            
	 

	               
	                                     

	                              
	 
		                                                   
		                
	 
 
#endif
                                      
