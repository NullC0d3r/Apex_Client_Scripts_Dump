                             

global function MpAbilityRedeployBalloon_Init

global function OnWeaponPrimaryAttack_redeploy_balloon
global function OnWeaponActivate_redeploy_balloon
global function OnWeaponDeactivate_redeploy_balloon
global function OnWeaponPrimaryAttackAnimEvent_redeploy_balloon
global function OnObjectPlacementCanPlace_redeploy_balloon
#if CLIENT
global function OnCreateClientOnlyModel_redeploy_balloon
#endif

global function IsRedeployBalloonEnt
global function GetRedeployBalloonForHitEnt

#if SERVER
                                                     
#endif

#if DEV && SERVER
                                         
#endif

#if CLIENT
global function ServerToClient_OnZiplineMount
global function ServerToClient_OnZiplineStop
#endif

          
const string REDEPLOY_BALLOON_PLAYLIST_HEIGHT = "redeploy_balloon_height"
const string REDEPLOY_BALLOON_PLAYLIST_HEALTH = "redeploy_balloon_health"
const string REDEPLOY_BALLOON_PLAYLIST_DAMAGE_FX_ENABLED = "redeploy_balloon_damage_fx"
const string REDEPLOY_BALLOON_PLAYLIST_LIFETIME = "redeploy_balloon_lifetime_sec"
const string REDEPLOY_BALLOON_PLAYLIST_ZIPLINE_SCALE = "redeploy_balloon_zipline_scale"
const string REDEPLOY_BALLOON_PLAYLIST_SKYDIVE_VEL = "redeploy_balloon_skydive_vel"
const string REDEPLOY_BALLOON_PLAYLIST_WEIGHT_BURY_DIST = "redeploy_balloon_weight_bury"
const string REDEPLOY_BALLOON_PLAYLIST_DEPLOY_VEL = "redeploy_balloon_deploy_vel"
const string REDEPLOY_BALLOON_PLAYLIST_DEPLOY_TRACE_TIME = "redeploy_balloon_deploy_trace_time"
const string REDEPLOY_BALLOON_PLAYLIST_SKYDIVE_TRIGGER_HEIGHT = "redeploy_balloon_skydive_height"

         
const string SIG_REDEPLOY_BALLOON_STOP_PLACEMENT = "RedeployBalloon_StopPlacement"
const string SIG_REDEPLOY_BALLOON_STOP_ZIPLINE = "RedeployBalloon_StopZipline"

              
global const string REDEPLOY_BALLOON_WEAPON_REF = "mp_ability_redeploy_balloon"
const string REDEPLOY_BALLOON_BASE_SCRIPT_NAME = "redeploy_balloon_base"
const string REDEPLOY_BALLOON_MOVER_SCRIPTNAME = "redeploy_balloon_mover"
const string REDEPLOY_BALLOON_INFLATABLE_SCRIPT_NAME = "redeploy_balloon_inflatable"
const string REDEPLOY_BALLOON_WEIGHT_SCRIPT_NAME = "redeploy_balloon_weight"
const string REDEPLOY_BALLOON_ZIPLINE_SCRIPT_NAME = "redeploy_balloon_zipline"
const string REDEPLOY_BALLOON_WAYPOINT_SCRIPT_NAME = "redeploy_balloon_waypoint"
const string REDEPLOY_BALLOON_PUSH_TRIGGER_SCRIPT_NAME = "redeploy_balloon_slip_trigger"
const string REDEPLOY_BALLOON_WEIGHT_PUSH_SCRIPT_NAME = "redeploy_balloon_weight_push"
const string REDEPLOY_BALLOON_AIR_PUSH_SCRIPT_NAME = "redeploy_balloon_air_push"
global const string REDEPLOY_BALLOON_SKYDIVE_TRIGGER_SCRIPT_NAME = "redeploy_balloon_skydive_trigger"

      
const int REDEPLOY_BALLOON_HEIGHT = 3700
const int REDEPLOY_BALLOON_HEALTH = 1800
const int REDEPLOY_BALLOON_NO_AIRDROP_RADIUS = 500

const float REDEPLOY_BALLOON_DEPLOY_VEL = 1280
const float REDEPLOY_BALLOON_DEPLOY_TRACE_TIME = 1.6

const float REDEPLOY_BALLOON_LIFETIME_SEC = 25
const int REDEPLOY_BALLOON_LIFETIME_MIN_HEALTH = 1

const int REDEPLOY_BALLOON_ZIPLINE_FADE_DISTANCE = 24000
const int _PROTO_REDEPLOY_BALLOON_BANNER_FADE_DISTANCE = 40000

                                                             
const float REDEPLOY_BALLOON_WEIGHT_BURY_DIST = -21
const vector REDEPLOY_BALLOON_WEIGHT_BURY_DIST_VEC = <0, 0, REDEPLOY_BALLOON_WEIGHT_BURY_DIST>                          

const bool USE_OBJECT_PLACER = false

          
const int REDEPLOY_BALLOON_WAYPOINT_MIN_DISTANCE = 120
const int REDEPLOY_BALLOON_WAYPOINT_MAX_DISTANCE = 4000
const int REDEPLOY_BALLOON_WAYPOINT_LONG_MAX_DISTANCE = 25000                                   
const int REDEPLOY_BALLOON_WAYPOINT_MIN_DISTANCE_SQR = REDEPLOY_BALLOON_WAYPOINT_MIN_DISTANCE * REDEPLOY_BALLOON_WAYPOINT_MIN_DISTANCE
const int REDEPLOY_BALLOON_WAYPOINT_MAX_DISTANCE_SQR = REDEPLOY_BALLOON_WAYPOINT_MAX_DISTANCE * REDEPLOY_BALLOON_WAYPOINT_MAX_DISTANCE
const int REDEPLOY_BALLOON_WAYPOINT_LONG_MAX_DISTANCE_SQR = REDEPLOY_BALLOON_WAYPOINT_LONG_MAX_DISTANCE * REDEPLOY_BALLOON_WAYPOINT_LONG_MAX_DISTANCE

const vector REDEPLOY_BALLOON_INVALID_PLACEMENT_MIN_AREA = <-25, -25, 0>
const vector REDEPLOY_BALLOON_INVALID_PLACEMENT_MAX_AREA = <25, 25, 50>

     
const asset RUI_REDEPLOY_BALLOON_WAYPOINT = $"ui/redeploy_balloon_hp_meter_cockpit.rpak"
const asset RUI_REDEPLOY_BALLOON_HUD = $"ui/redeploy_balloon_hp_status.rpak"

                 
const float REDEPLOY_BALLOON_SKYDIVE_TRIGGER_RADIUS = 32
const float REDEPLOY_BALLOON_SKYDIVE_TRIGGER_HALF_HEIGHT = 80

const float REDEPLOY_BALLOON_PUSH_TRIGGER_RADIUS = 300
const float REDEPLOY_BALLOON_PUSH_TRIGGER_HALF_HEIGHT = 100
const float REDEPLOY_BALLOON_PUSH_TRIGGER_STRENGTH = 350.0
const vector REDEPLOY_BALLOON_PUSH_TRIGGER_OFFSET = <0, 0, 400>

const float REDEPLOY_BALLOON_WEIGHT_PUSH_RADIUS = 20
const float REDEPLOY_BALLOON_WEIGHT_PUSH_HALF_HEIGHT = 80
const float REDEPLOY_BALLOON_WEIGHT_PUSH_STRENGTH = 180.0
const vector REDEPLOY_BALLOON_WEIGHT_PUSH_OFFSET = <0, 0, 80>

const float REDEPLOY_BALLOON_AIR_PUSH_RADIUS = 320
const float REDEPLOY_BALLOON_AIR_PUSH_HALF_HEIGHT = 420
const float REDEPLOY_BALLOON_AIR_PUSH_STRENGTH = 300.0
const vector REDEPLOY_BALLOON_AIR_PUSH_OFFSET = <0, 0, 180>

        
                                    
const float REDEPLOY_BALLOON_ZIPLINE_SCALE = 1.4

                     
const float REDEPLOY_BALLOON_ZIPLINE_DEPLOY_SEC = 1.15
const float REDEPLOY_BALLOON_BASE_DEPLOY_SEC = 3.85
const float REDEPLOY_BALLOON_BASE_DEPLOY_ACCEL = 0.75
const float REDEPLOY_BALLOON_BASE_DEPLOY_DECEL = 2.25

const float REDEPLOY_BALLOON_SKYDIVE_VEL = 1315               

const float REDEPLOY_BALLOON_DAMAGE_BLINK_SEC = 0.5
const float REDEPLOY_BALLOON_TAKING_DAMAGE_SEC = 0.5

        
const asset MDL_REDEPLOY_BALLOON_INFLATABLE = $"mdl/props/evac_tower_balloon/evac_tower_balloon.rmdl"                                                         
const asset MDL_REDEPLOY_BALLOON_BASE = $"mdl/props/evac_tower_rocket/evac_tower_rocket.rmdl"                                            
const asset MDL_REDEPLOY_BALLOON_WEIGHT = $"mdl/props/evac_tower_weight/evac_tower_weight.rmdl"                                         
                                                                                       

     
const asset VFX_REDEPLOY_BALLOON_LAUNCH_TRAIL = $"P_evacB_launch"
const asset VFX_REDEPLOY_BALLOON_LAUNCH = $"P_evacB_launch_engage"
                                                                        
const asset VFX_REDEPLOY_BALLOON_INFLATE = $"P_evacB_airburst"
const asset VFX_REDEPLOY_BALLOON_DESTROYED = $"P_evacB_destroy"
const asset VFX_REDEPLOY_BALLOON_WEIGHT_DESTROYED = $"P_evacB_sys_exp"
const asset VFX_REDEPLOY_BALLOON_AR_DROP = $"P_ar_evacB_point"                                                 

const asset VFX_REDEPLOY_BALLOON_DAMAGED = $"P_rmp_smoke_pink_diag"
                                                                                                 
                                                                     

const string VFX_REDPLOY_BALLOON_WEIGHT_IMPACT_TABLE = "evac_tower_anchor_impact"

       
const string SFX_REDEPLOY_BALLOON_LAUNCH = "Survival_EvacTower_BlastOff"                             
const string SFX_REDEPLOY_BALLOON_INFLATE = "Survival_EvacTower_Balloon_Inflate"                    
const string SFX_REDEPLOY_BALLOON_ZIPLINE_EXTEND = "Survival_EvacTower_Anchor_Incoming"
const string SFX_REDEPLOY_BALLOON_DEATH = "Survival_EvacTower_Balloon_Explode"                       
const string SFX_REDEPLOY_BALLOON_WEIGHT_DEATH = "Survival_EvacTower_Zipline_Snap"                  
const string SFX_REDEPLOY_BALLOON_AR = "Survival_EvacTower_AR_Landing_Marker"                   

                                         
const asset MAT_ASSET_REDEPLOY_BALLOON_ZIPLINE = $"cable/zipline"                  
const string MAT_REDEPLOY_BALLOON_ZIPLINE = "cable/zipline"                  

       
const string ANIM_REDEPLOY_BALLOON_DEPLOY = "evac_balloon_deploy"

struct RedeployBalloonPlacementInfo
{
	vector origin
	vector angles
	vector surfaceNormal
	bool   failed
	bool   hide
	string failReason
}

struct {
	#if SERVER
		                                    
	#endif

	#if CLIENT
		var waypointRui
	#endif

	int   height = REDEPLOY_BALLOON_HEIGHT
	float deployVel = REDEPLOY_BALLOON_DEPLOY_VEL
	float deployTraceTime = REDEPLOY_BALLOON_DEPLOY_TRACE_TIME

	#if SERVER
		                                       
		                                                  
		                                                    
		                                                
		                                                       
		                                                                              
	#endif
}
file

void function MpAbilityRedeployBalloon_Init()
{
	PrecacheModel( MDL_REDEPLOY_BALLOON_INFLATABLE )
	PrecacheModel( MDL_REDEPLOY_BALLOON_BASE )
	PrecacheModel( MDL_REDEPLOY_BALLOON_WEIGHT )
	                                                  

	PrecacheScriptString( REDEPLOY_BALLOON_INFLATABLE_SCRIPT_NAME )
	PrecacheScriptString( REDEPLOY_BALLOON_PUSH_TRIGGER_SCRIPT_NAME )
	PrecacheScriptString( REDEPLOY_BALLOON_SKYDIVE_TRIGGER_SCRIPT_NAME )
	PrecacheScriptString( REDEPLOY_BALLOON_WAYPOINT_SCRIPT_NAME )
	PrecacheScriptString( REDEPLOY_BALLOON_WEIGHT_PUSH_SCRIPT_NAME )
	PrecacheScriptString( REDEPLOY_BALLOON_AIR_PUSH_SCRIPT_NAME )
	PrecacheScriptString( REDEPLOY_BALLOON_WEIGHT_SCRIPT_NAME )
	PrecacheScriptString( REDEPLOY_BALLOON_ZIPLINE_SCRIPT_NAME )

	PrecacheImpactEffectTable( VFX_REDPLOY_BALLOON_WEIGHT_IMPACT_TABLE )

	PrecacheParticleSystem( VFX_REDEPLOY_BALLOON_LAUNCH_TRAIL )
	PrecacheParticleSystem( VFX_REDEPLOY_BALLOON_LAUNCH )
	  	                                                        
	PrecacheParticleSystem( VFX_REDEPLOY_BALLOON_INFLATE )
	PrecacheParticleSystem( VFX_REDEPLOY_BALLOON_DESTROYED )
	PrecacheParticleSystem( VFX_REDEPLOY_BALLOON_WEIGHT_DESTROYED )
	PrecacheParticleSystem( VFX_REDEPLOY_BALLOON_AR_DROP )
	                                                       

	PrecacheParticleSystem( VFX_REDEPLOY_BALLOON_DAMAGED )

	PrecacheMaterial( MAT_ASSET_REDEPLOY_BALLOON_ZIPLINE )

	Remote_RegisterClientFunction( "ServerToClient_OnZiplineMount", "entity" )
	Remote_RegisterClientFunction( "ServerToClient_OnZiplineStop" )

	#if CLIENT
		RegisterSignal( SIG_REDEPLOY_BALLOON_STOP_PLACEMENT )
		RegisterSignal( SIG_REDEPLOY_BALLOON_STOP_ZIPLINE )
		AddCreateCallback( PLAYER_WAYPOINT_CLASSNAME, OnWaypointCreated )
		AddCreateCallback( "prop_dynamic", OnPropDynamicCreate )

		RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.REDEPLOY_BALLOON, MINIMAP_OBJECT_RUI, MinimapPackage_RedeplyBalloon, FULLMAP_OBJECT_RUI, MinimapPackage_RedeplyBalloon )
	#endif

	#if SERVER
		                                                          
		                                                        
	#endif

	file.height          = GetCurrentPlaylistVarInt( REDEPLOY_BALLOON_PLAYLIST_HEIGHT, REDEPLOY_BALLOON_HEIGHT )
	file.deployVel       = GetCurrentPlaylistVarFloat( REDEPLOY_BALLOON_PLAYLIST_DEPLOY_VEL, REDEPLOY_BALLOON_DEPLOY_VEL )
	file.deployTraceTime = GetCurrentPlaylistVarFloat( REDEPLOY_BALLOON_PLAYLIST_DEPLOY_TRACE_TIME, REDEPLOY_BALLOON_DEPLOY_TRACE_TIME )

	#if SERVER
		                                                                                                   
		                                                                                                                  
		                                                                                                                         
		                                                                                                                   
		                                                                                                                                   
		                                                                                                                                                            
	#endif
}

#if SERVER
                                                      
 
	                      
 
#endif

void function OnWeaponActivate_redeploy_balloon( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	#if CLIENT

		#if !USE_OBJECT_PLACER
			RedployBalloon_BeginPlacement( ownerPlayer )
		#endif

		RunUIScript( "CloseSurvivalInventoryMenu" )

		if ( !InPrediction() )
			return
	#endif

	int skinIndex = weapon.GetSkinIndexByName( "evac_tower_clacker" )
	if ( skinIndex != -1 )
		weapon.SetSkin( skinIndex )
}

void function OnWeaponDeactivate_redeploy_balloon( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	#if CLIENT
		RedeployBalloon_EndPlacement( ownerPlayer )
		if ( !InPrediction() )                             
			return
	#endif
}

bool function IsRedeployBalloonEnt( entity ent )
{
	return ent.GetScriptName() == REDEPLOY_BALLOON_INFLATABLE_SCRIPT_NAME
}

entity function GetRedeployBalloonForHitEnt( entity hitEnt )
{
	if ( !IsValid( hitEnt ) )
		return null

	                                                 
	if ( hitEnt.GetScriptName() == REDEPLOY_BALLOON_WEIGHT_SCRIPT_NAME || hitEnt.GetScriptName() == REDEPLOY_BALLOON_ZIPLINE_SCRIPT_NAME )
		return hitEnt.GetOwner()

	if ( hitEnt.GetScriptName() == REDEPLOY_BALLOON_INFLATABLE_SCRIPT_NAME )
		return hitEnt

	return null
}

           
#if CLIENT
void function OnCreateClientOnlyModel_redeploy_balloon( entity weapon, entity model, bool validHighlight )
{
	if ( validHighlight )
		DeployableModelHighlight( model )
	else
		DeployableModelInvalidHighlight( model )
}

void function RedployBalloon_BeginPlacement( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return

	thread RedeployBalloon_Placement_Thread( player )
}

void function RedeployBalloon_EndPlacement( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return

	player.Signal( SIG_REDEPLOY_BALLOON_STOP_PLACEMENT )
}

void function RedeployBalloon_Placement_Thread( entity player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( SIG_REDEPLOY_BALLOON_STOP_PLACEMENT )

	entity proxy = CreateProxy( MDL_REDEPLOY_BALLOON_BASE )
	proxy.EnableRenderAlways()
	proxy.Show()
	DeployableModelHighlight( proxy )
	proxy.SetFadeDistance( 320000 )                             

	string[1] displayedHint = [""]

	OnThreadEnd(
		function() : ( proxy, displayedHint )
		{
			if ( IsValid( proxy ) )
				thread DestroyProxy_Thread( proxy )

			if ( displayedHint[0] != "" )
				HidePlayerHint( displayedHint[0] )
		}
	)

	                                                                           

	while ( true )
	{
		RedeployBalloonPlacementInfo placementInfo = RedeployBalloon_GetPlacementInfo ( player )

		proxy.SetOrigin( placementInfo.origin )
		proxy.SetAngles( placementInfo.angles )

		string hint = "#REDEPLOY_BALLOON_USE_PROMPT"

		if ( !placementInfo.failed )
			DeployableModelHighlight( proxy )
		else
		{
			DeployableModelInvalidHighlight( proxy )
			hint = "#REDEPLOY_BALLOON_INVALID_PLACEMENT"
		}

		if ( placementInfo.hide )
		{
			hint = "#REDEPLOY_BALLOON_INVALID_PLACEMENT"
			proxy.Hide()
		}
		else
			proxy.Show()

		if ( hint != displayedHint[0] )
		{
			if ( displayedHint[0] != "" )
				HidePlayerHint( displayedHint[0] )
			if ( hint != "" )
				AddPlayerHint( 60.0, 0, $"", hint )
			displayedHint[0] = hint
		}

		WaitFrame()
	}
}

entity function CreateProxy( asset modelName )
{
	entity modelEnt = CreateClientSidePropDynamic( <0, 0, 0>, <0, 0, 0>, modelName )
	modelEnt.kv.renderamt   = 255
	modelEnt.kv.rendermode  = 3
	modelEnt.kv.rendercolor = "255 255 255 255"

	modelEnt.Anim_Play( "ref" )
	modelEnt.Hide()

	return modelEnt
}

void function DestroyProxy_Thread( entity proxy )
{
	Assert( IsNewThread(), "Must be threaded off" )
	proxy.EndSignal( "OnDestroy" )

	                                                  
	        
	                                   
	  	          

	proxy.Destroy()
}
#endif

bool function OnObjectPlacementCanPlace_redeploy_balloon( entity weapon, vector origin, vector angles, entity parentTo )
{
	entity player = weapon.GetOwner()
	return VerifyAirdropPoint( origin, angles.y, true, player )
}


            
var function OnWeaponPrimaryAttack_redeploy_balloon( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return RedeployBallon_PlaceBalloon( weapon, attackParams )
}

int function RedeployBallon_PlaceBalloon( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity player = weapon.GetWeaponOwner()
	Assert( player.IsPlayer() )

	#if USE_OBJECT_PLACER
		                                          
		                                                        
		                                                        
	#else
		RedeployBalloonPlacementInfo placementInfo = RedeployBalloon_GetPlacementInfo( player )
	#endif


	if ( placementInfo.failed )
		return 0

	#if SERVER
		                                                                                    
		                                                  
		 
			                                   
			        
		 

		                                                                                   

		                                                                             
	#else
		PlayerUsedOffhand( player, weapon )
		RedeployBalloon_EndPlacement( weapon )
	#endif

	#if SERVER
		                                                

		                                                                                     

		                                                                 
	#endif

	int ammoReq = weapon.GetAmmoPerShot()
	return ammoReq
}

#if SERVER

                                                                    
 
	                                                   
	                                                                    
	                                                       
	                                                       
	                                             
	                                            
	                                        
	                                                                    

	                                                                     

	      
	                                      

	                        

	              
 

                                                                        
 
	                                                                                                   
	                                        
	                       
	                               

	                               

	           
 

                                                            
 
	                                                                                                       
	                                                           

	                         
	                                

	                                        
	                                                                                       

	             
 

                                                                              
 
	                                                                                                       

	                              
	                              
	                                                                   

	                            
	                                        

	                               
	                  
	                          
	                             
	                                    
	                                             
	                                                    

	                                     

	                                      
	                                   
	                                         
	                                        
	                                           

	                                          
	                                 
	                                             
	                                            
	                                             
	                                             

	                                                             
	                             
	                                            

	                                                                            

	                 
 

                                                                                                                                         
 
	                                                
	                                
	                                  
	                                  
	                                         
	                                         
	                                     
	                        
	                                
	                                  
	                                                     

	                     

	           
 

                                                                                   
 
	                                            
	                                         
	                                         
	                                     
	                                          
	                        
	                                
	                                  

	                     

	           
 

                                                   
 
	                                                                         
	                                                               
	                                                                                          
	                                            
	                                                  
	                                                  
	                               
	                                                         
	                                        
	                                          
	                                
	                                        
	                                                  

	               
 
#endif

#if SERVER
                                                                                         
 
	                                                               
 

                                                                                           
 
	                        
		      

	                                                

	                        
	                                              

	                                                                                                                                                                       

	            
		                             
		 
			                              
				                      
		 
	 

	                                                           

	               
	                                                                                  

	                     
	                                                                                       
 

                                                                                       
 
	                                                                
	                                                                                                                            
	                                                                                            
	                                                                                                 

	                                                                                

	                                          
	                                   

	            
		                                                    
		 
			                                 
				                         
			                          
				                  

			                                                        
		 
	 

	                                                                           
 

                                                                                                                
 
	                        
		      

	                                                   

	                           
	                             

	                                                                                                         
	                       

	                                

	                            
	                              

	                                             
	                                                                              
		                                      
		                                 
		                                      
		                                      
		                                    

	            
		                                     
		 
			                      
			 
				                                                      
				              
			 
			                       
				               

			                         
				                 
		 
	 

	                                           

	                                                      
	                                                                     
	                               

	                                                                                                                                                                                  
	                             

	                                                                                                                                               
	                                  
	                             

	                                                                                                                                     

	                                                                                                                                          

	                                     
 

                                                                                                                      
 
	                        
		      

	                                                          
	                                                             
	                                                                                     
		                                          
		                                      

	                                  
	                               

	                            
	                                 

	                              
	                                
	                                 
	                                   

	            
		                                          
		 
			                         
				                 
			                            
				                    
			                      
				              
		 
	 

	                                                 

	                                                                                                                                                                    
	                                    
	                              

	                                                    

	                                                                                            

	                                                                          
	                                     

	                 

	                  
	                                                                                                                               
 


                                                                                                                                                 
 
	                                                              

	                                 
	                                   

	                                                             
	                                                                            
	                         
	                                               

	                                                                  
	                                                                         
	                                                        
	                                  
	                                     
	                                                       
	                                                                                             
	                                                                                       
	                                                 
	                                                 
	                                                  
	                                                                                           

	                                   

	                                                                            

	                                   
	                                     

	                                                 
	                                                    
	                                

	                                                                          

	                                    
	                                    

	                                            
	                                          

	                             
	                           

	                                                                                                  

	                              
	                                             
	                             

	                                     

	                                                      
	                             
	                              
	                         

	                                                                

	                                      

	                             
	                               

	                     
	                                        

	                                                                              
		                                         
		                                    
		                                         
		                                         
		                                       

	                                    
	              

	                                              
	                                

	                                                                          

	                                        

	                                      
	                                                                                         
	                                               
	                               
	                                                                                
	                                          
	                               
	                                                
	                                        
	                             
	 
		                                                 
	 
	                                           

	            
		                                                                                             
		 
			                                          
			                              
				                      
			                            
				                    
			                        
			 
				                                                                                  
				                                                                                                                                                                   
				                                   
				                                                                
				                
			 
			                       
				               
			                          
				                  
			                      
				              
			                            
				                    
		 
	 

	                         

	             
	                                 

	        

	                                                                            
	                                                        
	                                     

	                                                         

	              

	        

	                      
	                               
	                             

	                        
	                    
	               

	                                                   
	                                          

	                                                     
	                                                                                                                                                         
	       
	                                                                                                                                                  

	                                              
	                                              
	 
		             
	 
	    
	 
		                             

		                                                    
		                                                                        

		                                   
		 
			                  
			                                                         
			                        
			 
				                                                                             
				                                              
				 
					                                                            
					                                  
				 

				                                                
					           

				                                                           
				                         
				                                  
				     
			 
			    
			 
				                                                            
				                                    
				                                  
			 
		 
	 
 

                                                                             
 
	                                       
	 
		                                   
		                                                                              
		                                
		 
			                                               
			                                                                               
		 
	 
 

                                                            
 
	                                                

	                          
		      

	                                       
	 
		                                   
		                                                                    
	 
 
#endif


#if SERVER
                                                                         
 
	                      
		      

	                                                      
	                                                    

	                           
		      

	                                                                            

	                          
	 
		                                                           
		                                                                          
		                                                       

		                
			                                                         

		                                 
			                                           
			                                             
			                                   
			                                                                                       
			                                     
			                                   
			                                                  
	 

	                                                                       
	                                 
 

                                                                                   
 
	                                                                      
	                                 
		      

	                                                                                                                            

	                                               
	                                                             

	                    
		                                         
 

                                                                     
 
	                                                                                                   
	                                                       
	                                    
	 
		                                                                                     
			          
	 
	           
 

                                                                   
 
	                                                       
	                                    
	 
		                                                                                   
			          
	 
	           
 

                                                                                  
 
	                
	 
		                                                                                                                                                                    
		                                       
		                                                                                               
		      
	 

	                                            
	                                                     
	                                               
	                                                       
	                                                      

	                                          
	                                  
	                                

	                                                        
	 
		                               
		                                                            
		                     
			      
		                     
		                                        
	 
	                                                              
	 
		                               
		                                                            
		                     
			      
		                     
		                                        
	 
 

                                                         
 
	                                                
	                     
	 
		                 
		                                      

		                 
		                                    

		               
		                                    
	 

	                         
	                
 

                                                                  
 
	                                                                                              
	                                      
 

                                                
 
	                              
	                               
 

                                                                    
 
	                                                                           
	                        
	                                                          
 

                                                                                                   
 
	                                   
	                                              
	                                                                     
	                                       
	                                       
 
#endif

#if CLIENT

void function OnWaypointCreated( entity wp )
{
	int wpType = wp.GetWaypointType()

	if ( wpType == eWaypoint.REDEPLOY_BALLOON_LIFE )
	{
		thread RedeployBalloon_UpdateWaypoint_Thread( wp )
	}
}

void function OnPropDynamicCreate( entity prop )
{
	if ( prop.GetScriptName() == REDEPLOY_BALLOON_WEIGHT_SCRIPT_NAME )
		AddRefEntAreaToInvalidOriginsForPlacingPermanentsOnto( prop, REDEPLOY_BALLOON_INVALID_PLACEMENT_MIN_AREA, REDEPLOY_BALLOON_INVALID_PLACEMENT_MAX_AREA )
}


void function RedeployBalloon_UpdateWaypoint_Thread( entity wp )
{
	entity player = GetLocalViewPlayer()

	if ( !IsValid( player ) || !IsValid( wp ) )
		return

	wp.SetDoDestroyCallback( true )
	wp.EndSignal( "OnDeath" )
	wp.EndSignal( "OnDestroy" )

	float width  = 220
	float height = 220
	vector right = <0, 1, 0> * height * 0.5
	vector fwd   = <1, 0, 0> * width * 0.5 * -1.0
	vector org   = <0, 0, 0>

	var topo = RuiTopology_CreatePlane( org - right * 0.5 - fwd * 0.5, fwd, right, true )
	RuiTopology_SetParent( topo, wp )

	array<var> ruis

	var rui = RuiCreate( RUI_REDEPLOY_BALLOON_WAYPOINT, topo, RUI_DRAW_WORLD, 1 )

	ruis.append( rui )

	bool isOwned = IsFriendlyTeam( wp.GetTeam(), player.GetTeam() )

	var bottomRui = CreateCockpitPostFXRui( RUI_REDEPLOY_BALLOON_WAYPOINT, 1 )
	RuiTrackFloat3( bottomRui, "playerAngles", player, RUI_TRACK_EYEANGLES_FOLLOW )
	RuiTrackFloat3( bottomRui, "worldPos", wp, RUI_TRACK_ABSORIGIN_FOLLOW )
	RuiSetFloat3( bottomRui, "offset", <0, 0, -file.height> )                                            
	RuiTrackFloat( bottomRui, "curHP", wp, RUI_TRACK_WAYPOINT_FLOAT, 0 )
	RuiTrackFloat( bottomRui, "maxHP", wp, RUI_TRACK_WAYPOINT_FLOAT, 1 )
	RuiTrackGameTime( bottomRui, "playerDamage", wp, RUI_TRACK_WAYPOINT_GAMETIME, 3 )
	                                                                           
	ruis.append( bottomRui )

	var topRui = CreateCockpitPostFXRui( RUI_REDEPLOY_BALLOON_WAYPOINT, 1 )
	RuiTrackFloat3( topRui, "playerAngles", player, RUI_TRACK_EYEANGLES_FOLLOW )
	RuiTrackFloat3( topRui, "worldPos", wp, RUI_TRACK_ABSORIGIN_FOLLOW )
	RuiSetFloat3( topRui, "offset", <0, 0, 200> )                                         
	RuiTrackFloat( topRui, "curHP", wp, RUI_TRACK_WAYPOINT_FLOAT, 0 )
	RuiTrackFloat( topRui, "maxHP", wp, RUI_TRACK_WAYPOINT_FLOAT, 1 )
	RuiTrackGameTime( topRui, "playerDamage", wp, RUI_TRACK_WAYPOINT_GAMETIME, 3 )
	RuiSetBool( topRui, "hideIcon", true )                                            
	RuiSetBool( topRui, "useTight", true )
	                                                                           
	ruis.append( topRui )

	OnThreadEnd(
		function() : ( topo, ruis )
		{
			foreach ( rui in ruis )
				RuiDestroy( rui )
			RuiTopology_Destroy( topo )
		}
	)

	while ( IsValid( wp ) )
	{
		                  
		bool displayBottomRui = wp.GetWaypointInt( 0 ) == 1
		bool displayTopRui    = false
		bool isInRange        = false

		if ( IsValid( player ) )
		{
			float dist = Distance2DSqr( player.EyePosition(), wp.GetOrigin() )
			isInRange = (dist > REDEPLOY_BALLOON_WAYPOINT_MIN_DISTANCE_SQR) && (dist < REDEPLOY_BALLOON_WAYPOINT_MAX_DISTANCE_SQR)

			displayBottomRui = displayBottomRui && isInRange
			if ( displayBottomRui && !isOwned )                                                                           
			{
				TraceResults results = TraceLine( player.EyePosition(), wp.GetOrigin() - <0, 0, file.height>, [player, wp.GetParent()], TRACE_MASK_VISIBLE, TRACE_COLLISION_GROUP_NONE )
				displayBottomRui = results.fraction > 0.95
			}

			               
			if ( isInRange || (dist < REDEPLOY_BALLOON_WAYPOINT_LONG_MAX_DISTANCE_SQR && PlayerIsInADS( player )) )
			{
				TraceResults results = TraceLine( player.EyePosition(), wp.GetOrigin(), [player, wp.GetParent()], TRACE_MASK_VISIBLE, TRACE_COLLISION_GROUP_NONE )
				displayTopRui = results.fraction > 0.95
			}
		}

		RuiSetBool( bottomRui, "isVisible", displayBottomRui )
		RuiSetBool( topRui, "isVisible", displayTopRui )

		WaitFrame()

		player = GetLocalViewPlayer()
	}
}

void function RedeployBalloon_UpdateZiplineHUD_Thread( entity player, entity waypoint )
{
	if ( !IsValid( player ) || !IsValid( waypoint ) )
		return

	player.EndSignal( SIG_REDEPLOY_BALLOON_STOP_ZIPLINE )
	waypoint.EndSignal( "OnDeath" )
	waypoint.EndSignal( "OnDestroy" )

	if ( player != GetLocalViewPlayer() )
		return

	var rui = CreateCockpitPostFXRui( RUI_REDEPLOY_BALLOON_HUD, HUD_Z_BASE )

	RuiTrackFloat( rui, "curHP", waypoint, RUI_TRACK_WAYPOINT_FLOAT, 0 )
	RuiTrackFloat( rui, "maxHP", waypoint, RUI_TRACK_WAYPOINT_FLOAT, 1 )
	RuiTrackGameTime( rui, "playerDamage", waypoint, RUI_TRACK_WAYPOINT_GAMETIME, 3 )

	OnThreadEnd(
		function() : (rui)
		{
			RuiDestroyIfAlive( rui )
		}
	)

	WaitForever()
}

void function ServerToClient_OnZiplineMount( entity waypoint )
{
	if ( GetLocalViewPlayer() != GetLocalClientPlayer() )
		return

	thread RedeployBalloon_UpdateZiplineHUD_Thread( GetLocalViewPlayer(), waypoint )
}

void function ServerToClient_OnZiplineStop()
{
	if ( GetLocalViewPlayer() != GetLocalClientPlayer() )
		return

	Signal( GetLocalViewPlayer(), SIG_REDEPLOY_BALLOON_STOP_ZIPLINE )
}

void function MinimapPackage_RedeplyBalloon( entity ent, var rui )
{
	#if MINIMAP_DEBUG
		printt( "Adding 'rui/hud/evac_tower/evac_tower_minimap' icon to minimap" )
	#endif
	RuiSetImage( rui, "defaultIcon", $"rui/hud/evac_tower/evac_tower_minimap" )
	RuiSetImage( rui, "clampedDefaultIcon", $"rui/hud/evac_tower/evac_tower_minimap" )
	RuiSetBool( rui, "useTeamColor", false )
	RuiSetFloat( rui, "iconBlend", 1.0 )
}
#endif

#if SERVER
                                                                                                                  
 
	                                                    
	 
		      
	 

	                               
	                                    

	                                                                         
	                                                                                                                                                                          

	                              
	 
		                                                                                
		 
			           
		 
	 

	                                                                                                                       
	                                                                                                            
	                                                  
	 
		                             
		 
			                                        
			                                                                                         
		 
		    
		 
			                                                                                                                                                                           
		 
	 
 
#endif

#if SERVER
                                                                             
 
	                                         

	                                                                                                                           
	                                                  
	                                                                        
	                                                                                         
 
#endif

#if SERVER && DEV
                                                                       
 
	                                                           
 
#endif

var function OnWeaponPrimaryAttackAnimEvent_redeploy_balloon( entity ent, WeaponPrimaryAttackParams params )
{
	                 
	                                                                                                            
	                                                                                                                     
	  
	                                
	                                                                                                                 
	                                                                                               
	  
	                                 
	  	                                                                                                                                                     
	  			                                                                                                                                                                  
	                                                                            
	  
	                                                                                                
	                                                                                          
	                                                                                             
	  
	                                                              
	                                                                                          
	  	                                                                                                                                                                                                                              
	  	                                                                  

	                                                                  
	                                                                                                                                   

	return 0                                                                                                                        
}

RedeployBalloonPlacementInfo function RedeployBalloon_GetPlacementInfo( entity player )
{
	const MAX_UP_ANGLE = -20
	const MAX_DOWN_ANGLE = 75
	const MIN_DIST_SQR = 72 * 72
	const PARENT_VELOCITY = <0, 0, 0>
	const SIGHT_TRACE_OFFSET = <0, 0, 48>
	const EYE_ANGLE_PITCH_OFFSET = 0

	bool failed = false
	bool hide   = false

	RedeployBalloonPlacementInfo placementInfo
	vector startPos        = player.EyePosition()
	vector flatForward     = FlattenVec( player.GetViewVector() )
	vector placementAngles = ClampAngles( VectorToAngles( flatForward ) + <0, 180, 0> )

	vector eyeAngles = player.EyeAngles()

	GravityLandData landData
	float pitch = GraphCapped( eyeAngles.x + EYE_ANGLE_PITCH_OFFSET, MAX_UP_ANGLE, MAX_DOWN_ANGLE, 0, 1 )
	pitch = PlacementEasing( pitch )

	float clampedPitch      = GraphCapped( pitch, 0, 1, MAX_UP_ANGLE, MAX_DOWN_ANGLE )
	vector clampedEyeAngles = < clampedPitch, eyeAngles.y, eyeAngles.z >
	vector objectVelocity   = AnglesToForward( clampedEyeAngles ) * file.deployVel

	landData = GetGravityLandData( startPos, PARENT_VELOCITY, objectVelocity, file.deployTraceTime, false )

	TraceResults traceResults = landData.traceResults

	vector origin = traceResults.endPos

	if ( !IsValid( traceResults.hitEnt ) )
	{
		origin = landData.points.top()
		failed = true
	}

	if ( DistanceSqr( player.GetOrigin(), origin ) < MIN_DIST_SQR )
	{
		failed = true
		hide   = true
	}

	                                                  
	if ( !failed )
	{
		const boundsMin = <-230, -230, 100>
		const boundsMax = <230, 230, 585>
		vector pos              = origin + <0, 0, file.height>
		TraceResults airResults = TraceHull( pos, pos, boundsMin, boundsMax, [ ], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )

		failed = airResults.fraction < 1.0
		                                                                                    
	}

	if ( !failed && !VerifyAirdropPoint( origin, placementAngles.y, true, player ) )
	{
		failed = true
	}

	placementInfo.origin        = origin
	placementInfo.angles        = placementAngles
	placementInfo.surfaceNormal = traceResults.surfaceNormal
	placementInfo.failed        = failed
	placementInfo.hide          = hide
	return placementInfo
}

                         
float function PlacementEasing( float frac )
{
	                                                                                                                  
	                                                                                     

	Assert( frac >= 0.0 && frac <= 1.0 )

	const float CUT_POINT = 1
	const float DIVISIONS = 2
	const float MID_VALUE = 0.35

	frac *= DIVISIONS
	if ( frac < CUT_POINT )
		return Tween_QuadEaseOut( frac / CUT_POINT ) * MID_VALUE
	return MID_VALUE + Tween_QuadEaseIn( (frac - CUT_POINT) / (DIVISIONS - CUT_POINT) ) * (1 - MID_VALUE)
}

                                  