
#if SERVER || CLIENT || UI
global function VendingMachine_LevelInit
#endif                          

#if SERVER
                                               
                                                 
                                                  
                                              
                                           

                                         	                             
                                          	                              

       
                                         
             
#endif          

#if SERVER || CLIENT
global function IsVendingMachine
global function IsVendingMachineUnsafe
#endif                    

#if SERVER || CLIENT
const string VENDING_MACHINE_DISABLED_PLAYLIST_VAR = "vending_machine_disabled"

global const string VENDING_MACHINE_SCRIPTNAME = "vending_machine"
global const string VENDING_MACHINE_MOVER_SCRIPTNAME = "vending_machine_mover"
global const string VENDING_MACHINE_CLOSE_CMD = "ClientCallback_CloseVendingMachine"
const string VENDING_MACHINE_OPEN_CMD = "ClientCallback_OpenVendingMachine"

                                   
const asset SUPPLY_BOX = DEATH_BOX

const asset BLACK_MARKET_MODEL = $"mdl/props/loba_loot_stick/loba_loot_stick.rmdl"
const asset BLACK_MARKET_WARP_BEAM_FX = $"P_item_warp_travel"

const bool VENDING_MACHINE_DEBUG = false
#endif                    

#if CLIENT
const string FAKEBOX_SCRIPTNAME = "fakebox"
#endif          

struct {
	#if SERVER
		                                                  
	#endif          

	#if CLIENT
		array< entity > vendingMachinesFake
	#endif          
} file


#if SERVER || CLIENT || UI
void function VendingMachine_LevelInit()
{
	
	#if SERVER || CLIENT
		                           
		                                     
		PrecacheScriptString( VENDING_MACHINE_SCRIPTNAME )
		Remote_RegisterServerFunction( VENDING_MACHINE_OPEN_CMD, "typed_entity", "prop_loot_grabber" )
		Remote_RegisterServerFunction( VENDING_MACHINE_CLOSE_CMD, "typed_entity", "prop_loot_grabber" )
	#endif                    

	#if SERVER
		                                                         

		                                                                 

	#endif          

	#if CLIENT
		AddCreateCallback( "prop_loot_grabber", OnPropScriptCreated )
		AddCallback_ClientOnPlayerConnectionStateChanged( CL_VendingMachineHighlight_Init )
	#endif         

	                                                                    

	RegisterSignal( "highlightSupplyBox" )
}
#endif                          


#if SERVER
                                                                                                            
 
	                                                                                                   
		      

	                            

	                     
	 
		                                                    
		                                    
		                                                          
		                                                           

		                                                
		                                   
		                                        
		                                           

		                                   

		                                  
		                                  

		                                              
		                         
			                                                                         
		                               

		                                     
		                                     

		                                                                

		                               

		                                                                                

		                                                             
		                                                                                              
		                                                                                                                  

		                                    
		               
		 
			                                   
		 
		                                  
		 
			                                               
		 
		    
		 
			                               
		 

		                             
		 
			                                        
			 
				                                                                                    
				                                          
				                                 
			 
		 

		                                                                        
		                                                                            
		                                                                                               
	 

	                          
	                                          
	                                                                          
	                                                       

	                                        

	             
	 
		                                                
		                                                                                                                                                                         

		        
	 
 

                                                               
 
	
 

#endif          


#if CLIENT
void function ManageVendingMachineAmbientGeneric_Thread( entity ent )
{
	EndSignal( ent, "OnDestroy" )

	entity soundEmitter = CreateClientSideAmbientGeneric( ent.GetWorldSpaceCenter(), "Loba_Ultimate_Cane_Active_Loop", 2000 )
	soundEmitter.SetEnabled( true )
	CopyRealmsFromTo( ent, soundEmitter )
	soundEmitter.SetParent( ent, "", true, 0.0 )

	OnThreadEnd( function () : ( soundEmitter ) {
		if ( IsValid( soundEmitter ) )
			soundEmitter.Destroy()
	} )

	WaitForever()
}

void function OnPropScriptCreated( entity ent )
{
	if ( ent.GetScriptName() == VENDING_MACHINE_SCRIPTNAME )
	{
		AddEntityCallback_GetUseEntOverrideText( ent, GetVendingMachineUsePromptText )
		SetCallback_CanUseEntityCallback( ent, CanUseVendingMachine )
		AddCallback_OnUseEntity_ClientServer( ent, OnVendingMachineUsed )
		SetCallback_ShouldUseBlockReloadCallback( ent, VendingMachine_ShouldUseBlockReload )

		                                                         

		CL_VendingMachineFake_Create( ent.GetOrigin(), ent.GetAngles() )
	}
}

void function CL_VendingMachineFake_Create( vector pos, vector angles )
{
	                                                             
	entity fakeBox = CreateClientSidePropDynamic( pos, angles, SUPPLY_BOX  )
	fakeBox.SetScriptName( FAKEBOX_SCRIPTNAME )
	fakeBox.SetSkin( fakeBox.GetSkinIndexByName( "firing_range_mu1" ))

	file.vendingMachinesFake.append( fakeBox )
}

void function CL_VendingMachineHighlight_Init( entity player )
{
	                                           
	foreach( fakeBox in file.vendingMachinesFake )
	{
		thread Do_Highlight_Thread( fakeBox )
	}
}

void function Do_Highlight_Thread( entity fakeBox )
{
	if( !IsValid( fakeBox ) )
		return

	fakeBox.Signal( "highlightSupplyBox" )
	fakeBox.EndSignal( "highlightSupplyBox" )
	fakeBox.EndSignal( "OnDestroy" )

	const float HIGHLIGHT_PERIOD = 5

	SetSurvivalPropHighlight( fakeBox, "firingrange_supplybox", false )

	while( IsValid( fakeBox ) )
	{
		                                                                                                                
		FiringRangeSupplyBoxHighlight( fakeBox )
		wait( HIGHLIGHT_PERIOD )
	}
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
string function GetVendingMachineUsePromptText( entity device )
{
	return "#VENDING_MACHINE_USE_HINT"
}
#endif          


#if SERVER || CLIENT
bool function CanUseVendingMachine( entity player, entity ent, int useFlags )
{
	return SURVIVAL_PlayerAllowedToPickup( player )
}
#endif                    

#if SERVER || CLIENT
bool function IsVendingMachine( entity ent )
{
	if ( IsValid(ent) && ent.GetNetworkedClassName() == "prop_loot_grabber" )
	{
		return ent.IsVendingMachine()
	}

	return false
}

                                                                             
bool function IsVendingMachineUnsafe( entity ent )
{
	return ent.IsVendingMachine()
}
#endif                    

#if SERVER || CLIENT
bool function VendingMachine_ShouldUseBlockReload( entity player, entity ent )
{
	return false;
}
#endif                    


#if SERVER || CLIENT
void function OnVendingMachineUsed( entity vendingMachine, entity player, int useInputFlags )
{
	if ( !IsBitFlagSet( useInputFlags, USE_INPUT_LONG ) )
		return

	if ( IsBitFlagSet( useInputFlags, USE_INPUT_ALT ) )
		return

	#if CLIENT
		if ( Survival_IsGroundlistOpen() )
			return
	#endif

	thread (void function() : ( vendingMachine, player ) {
		ExtendedUseSettings settings
		settings.duration = 0.3
		settings.disableWeaponTypes = WPT_TACTICAL | WPT_ULTIMATE | WPT_CONSUMABLE
		settings.loopSound = "UI_Survival_PickupTicker"
		settings.successSound = ""
		#if CLIENT
			settings.displayRui = $"ui/extended_use_hint.rpak"
			settings.displayRuiFunc = void function( entity vendingMachine, entity player, var rui, ExtendedUseSettings settings )
			{
				RuiSetString( rui, "holdButtonHint", settings.holdHint )
				RuiSetString( rui, "hintText", settings.hint )
				RuiSetGameTime( rui, "startTime", Time() )
				RuiSetGameTime( rui, "endTime", Time() + settings.duration )
			}
			settings.icon = $""
			settings.hint = "#PROMPT_OPEN"
			settings.successFunc = void function( entity vendingMachine, entity player, ExtendedUseSettings settings )
			{
				OpenSurvivalGroundList( player, vendingMachine, eGroundListBehavior.NEARBY, eGroundListType.VENDINGMACHINE )
				Remote_ServerCallFunction( VENDING_MACHINE_OPEN_CMD, vendingMachine )
			}
		#endif

		#if CLIENT
			EndSignal( clGlobal.levelEnt, "ClearSwapOnUseThread" )
		#endif
		EndSignal( vendingMachine, "OnDestroy" )
		waitthread ExtendedUse( vendingMachine, player, settings )
	})()
}
#endif                    

#if SERVER
                                                                                                      
 
	                                                                  
 

                                                        
 
	                      
	 
		                                                                                   
	 
 
#endif          


