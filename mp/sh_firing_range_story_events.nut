#if SERVER || CLIENT
global function ShFiringRangeStoryEvents_Init
global function S16T_GetPhase
#endif

struct RealmStoryData
{
}


struct
{
	table< int,  RealmStoryData > realmStoryDataByRealmTable
} file


const S16T_PROP_P1_SCRIPTNAME = "s16t_prop_p1"
const S16T_PROP_P2_SCRIPTNAME = "s16t_prop_p2"
const S16T_PROP_P3_SCRIPTNAME = "s16t_prop_p3"
const S16T_MPROP_P3_SCRIPTNAME = "s16t_mprop_p3"

const S16_MPROP_DIALOGUE = [ "bc_billboardObjectM_character_gibraltar", "bc_billboardObjectM_character_rampart", "bc_billboardObjectM_character_mirage" ]
const S16_MPROP_MDL = $"mdl/domestic/magazine_pile_02.rmdl"

global enum S16T_PHASE
{
	DISABLED,
	PHASE1,
	PHASE2,
	PHASE3,
}

                                                                                                                                    
                                                                                                                                    
                                                                                                                                    
                                                                                                                                    
  
                               
                            
                            
                            
                            
                            
                            
  
                                                                                                                                    
                                                                                                                                    
                                                                                                                                    
                                                                                                                                    

#if SERVER || CLIENT
void function ShFiringRangeStoryEvents_Init()
{
	if ( GetMapName() != "mp_rr_canyonlands_staging" )                                                  
		return

	#if SERVER
		                                                                                  
		                                                         
		                              
	#endif

	if ( !IsFiringRangeGameMode() )
		return

	AddCallback_EntitiesDidLoad( EntitiesDidLoad )

	#if CLIENT
		AddCreateCallback( "prop_script", S16T_CLMagazineCreated )
	#endif

	PrecacheScriptString( S16T_MPROP_P3_SCRIPTNAME )
}
#endif

#if SERVER || CLIENT
void function EntitiesDidLoad()
{

}
#endif                    

#if SERVER || CLIENT
int function S16T_GetPhase()
{
	if ( !IsFiringRangeGameMode() )
		return S16T_PHASE.DISABLED

	#if DEV
	int devPhase = GetCurrentPlaylistVarInt( "s16t_debug_phase", -1 )
	if ( devPhase != -1 )
		return devPhase
	#endif

	int unixTimeNow = GetUnixTimestamp()
	if ( unixTimeNow >=  expect int( GetCurrentPlaylistVarTimestamp( "s16t_p3_active", UNIX_TIME_FALLBACK_2038 ) ) )
	{
		return S16T_PHASE.PHASE3
	}
	else if ( unixTimeNow >=  expect int( GetCurrentPlaylistVarTimestamp( "s16t_p2_active", UNIX_TIME_FALLBACK_2038 ) ) )
	{
		return S16T_PHASE.PHASE2
	}
	else if ( unixTimeNow >=  expect int( GetCurrentPlaylistVarTimestamp( "s16t_p1_active", UNIX_TIME_FALLBACK_2038 ) ) )
	{
		return S16T_PHASE.PHASE1
	}

	return S16T_PHASE.DISABLED
}
#endif

#if SERVER
                                                              
 
	                       
		      

	                           

	                              
	 
		                              
			                                   
				             
			     
		                              
			                                                                 
				             
			     
		                              
			                                 
				             
			     
		        
			     
	 
 

                                                  
 
	                       
		      

	                                           
		       

	                                                      
	 
		                                                                                                     
		                     
		                                                  

		                    
		                                                                                                       
		                                                  
		                                                                        

		                                                                 
		                                                                    
	 
 
#endif

#if CLIENT
void function S16T_CLMagazineCreated( entity ent )
{
	if ( !IsValid ( ent ) )
		return

	if ( ent.GetScriptName() ==  S16T_MPROP_P3_SCRIPTNAME )
	{
		SetCallback_CanUseEntityCallback( ent, S16T_MagazineCanUse )
		AddCallback_OnUseEntity_ClientServer( ent, S16T_MagazineOnUse )
	}
}
#endif

#if SERVER || CLIENT
bool function S16T_MagazineCanUse( entity player, entity ent, int useFlags )
{
	if ( !IsValid(player) )
		return false

	if ( !IsPlayerOneOfCharacters( player, ["character_gibraltar", "character_rampart", "character_mirage"] ) )
		return false

	return true
}
#endif

#if SERVER || CLIENT
void function S16T_MagazineOnUse( entity ent, entity player, int useFlags )
{
	if ( !IsValid(player) )
		return

	#if SERVER
		                                                         
		 
			                                                                                          
		 
		                                                            
		 
			                                                                                        
		 
		                                                           
		 
			                                                                                       
		 
	#endif
	
}
#endif         



