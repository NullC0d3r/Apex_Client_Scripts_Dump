global function ShSpawnSquadSkyDive_Init
global function SpawnGroupSkydive_GetSquadSpawnDelay

#if SERVER
                                                   
                                          
#endif         

#if SERVER && DEV
                                                  
#endif                

struct
{
	#if SERVER
		                         
	#endif         
} file

void function ShSpawnSquadSkyDive_Init()
{
	if ( GetRespawnStyle() != eRespawnStyle.SPAWN_GROUP_SKYDIVE )
		return
	print( "Respawn style is SPAWN_GROUP_SKYDIVE\n" )

	#if SERVER
		                                                     

		                                                
		                                                                       

		                                            

		                                                                                   
		                                                                          
	#endif          
}

#if SERVER
                                 
 
	                 
 
#endif          

#if SERVER
                               
 
	                                                                                                       
	                         

	                                                 
	                                                
	                                                  
	                                              
	 
		                
		                                                                              
		                             
		                                
	 

	                              
 
#endif          

#if SERVER
                                                        
 
	                       
 
#endif         

        
int function SpawnSquadSkyDive_GetRemainingRespawnsForPlayer( entity player )
{
	return player.GetPlayerNetInt( "respawnsRemaining" )
}
            

#if SERVER
                                                                              
 
	                           
	                                                                               

                           
                                                  
                     
       

	                          
	 
		                                                                           
		                                                 
			                          
	 
	    
	 
		                                                                             
		                                                                             
		                                                              

		                                                     
			                                                        
	 
 
#endif          

#if SERVER
                                            
 
		                                                    
		                             
		 
			                                                                          
		 
 
#endif          

#if SERVER && DEV
                                                  
 
	                   

	             
	 
		                                    
		 
			                                                                                                
			                                                                                                              
		 
		      
	 
 
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

#if SERVER
                              
 
	                                                                                            
 
#endif         

float function SpawnGroupSkydive_GetSquadSpawnDelay( )
{
	return GetCurrentPlaylistVarFloat( "respawn_cooldown", 5.0 )
}