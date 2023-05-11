                         
global function Sh_RankedScoring_Init
global function Ranked_GetPointsForPlacement
global function Ranked_GetPenaltyPointsForAbandon
global function Ranked_GetParticipationMutlipler
global function Ranked_GetNumProvisionalMatchesCompleted
global function Ranked_GetNumProvisionalMatchesRequired
global function Ranked_HasCompletedProvisionalMatches

#if SERVER
                                                      
#endif

global function LoadLPBreakdownFromPersistance

global const RANKED_LP_PROMOTION_BONUS = 250
global const RANKED_LP_DEMOTION_PENALITY = 150
global const float PARTICIPATION_MODIFIER = 0.5
global const int RANKED_NUM_PROVISIONAL_MATCHES = 10

global struct RankLadderPointsBreakdown
{
	                                                                                   
	                                                                                

	bool wasInProvisonalGame			                                                                   
	bool wasAbandoned					                               
	bool lossForgiveness				                                                            
	int  damage							                                       

	int  knockdown						                                           
	int  knockdownAssist				                                                  

	int kills							                                      
	int assists							                                        
	int participation					                                                                      

	int killsUnique = 0					                             
	int assistUnique = 0				                              
	int participationUnique = 0			                                      

	int placement						                                                 
	int placementScore					                                             

	#if SERVER
		                                            
		                                              
		                                                    
		                                                
		                                                      
	#endif

	                                            
	                                                       
	int killBonus = 0                                                    
	int convergenceBonus = 0                                                   
	int skillDiffBonus = 0                                                    
	int provisionalMatchBonus = 0                                                                            
	int promotionBonus = 0							                                         

	int demotionPenality = 0						                                    
	int penaltyPointsForAbandoning = 0				                                   
	int demotionProtectionAdjustment = 0			                                            
	int lossProtectionAdjustment = 0				                                        

	         
	int startingLP
	int netLP
	int finalLP
}

global struct RankedPlacementScoreStruct
{
	                                 
	int   placementPosition
	int   placementPoints
}

struct
{
	array< RankedPlacementScoreStruct > placementScoringData
} file


void function Sh_RankedScoring_Init()
{
	Ranked_InitPlacementScoring()
}

void function Ranked_InitPlacementScoring()
{
	                                                             
	var dataTable = GetDataTable( $"datatable/ranked_placement_scoring.rpak" )                 
	int numRows   = GetDataTableRowCount( dataTable )

	file.placementScoringData.clear()

	#if DEV && SERVER
	                                            
	 
		                                             
	 
	#endif

	for ( int i = 0; i < numRows; ++i )
	{
		RankedPlacementScoreStruct placementScoringData
		placementScoringData.placementPosition            = GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "placement" ) )
		placementScoringData.placementPoints              = GetDataTableInt( dataTable, i, GetDataTableColumnByName( dataTable, "placementPoints" ) )
		file.placementScoringData.append( placementScoringData )

		#if DEV && SERVER
		                                            
		 
			                                                                                                                                                                
		 
		#endif
	}
}


bool function Ranked_HasCompletedProvisionalMatches( entity player )
{
	return ( Ranked_GetNumProvisionalMatchesCompleted( player ) >= Ranked_GetNumProvisionalMatchesRequired() )
}

int function Ranked_GetNumProvisionalMatchesRequired()
{
	if ( GetConVarBool( "ranked_disable_placement_matches" ) )
		return 0

	return GetCurrentPlaylistVarInt( "ranked_num_provisional_matches", RANKED_NUM_PROVISIONAL_MATCHES )
}

int function Ranked_GetNumProvisionalMatchesCompleted( entity player )
{
#if UI
	if ( !IsFullyConnected() )
		return 0
#endif

#if CLIENT
	if ( !IsConnected() )
		return 0
#endif

	#if UI
		return GetPersistentVarAsInt( "rankedProvisionalMatchesCompleted" )
	#else
		return player.GetPersistentVarAsInt( "rankedProvisionalMatchesCompleted" )
	#endif

	unreachable
}

int function Ranked_GetPointsForPlacement( int placement )
{
	int lookupPlacement    = minint( file.placementScoringData.len() - 1, placement )
	int csvValue           = file.placementScoringData[ lookupPlacement ].placementPoints
	string playlistVarName = "rankedPointsForPlacement_" + lookupPlacement

	return GetCurrentPlaylistVarInt( playlistVarName, csvValue )
}


float function Ranked_GetParticipationMutlipler( )
{
	return GetCurrentPlaylistVarFloat( "ranked_participation_mod", PARTICIPATION_MODIFIER )
}

int function Ranked_GetPenaltyPointsForAbandon( )
{
	                                                         
	string playlistVarString      = "ranked_abandon_cost"
	return GetCurrentPlaylistVarInt( playlistVarString, 2 * Ranked_GetCostForEntry() )
}

#if SERVER

                                                                                                              

	       
		                                                                                    
		                                                                              
		                                                                                    
		                                                                                                        
		                                                                                       
		                                                                        
		                                                                                                                
		                                                                                                          
		                                                                                                      
		                                                                                                                   
		                                                                       
		                                                                              
		                                                                            
		                                                                                   
		                                                                             
		                                                                    
	      

	                                                                                                          

	                                                                                                       
	                                                                                                   
	                                                                                                                
	                                                                 
	                                                                            

	                                                                      
	                                                                             
	                                                                           
	                                                                                  


 
#endif         

void function LoadLPBreakdownFromPersistance ( RankLadderPointsBreakdown breakdown , entity player)
{
	                                                               
	                                    
	                                                                                      
	                    		                                                     
	breakdown.placement 				   = player.GetPersistentVarAsInt( "lastGameRank" )
	breakdown.placementScore 			   = GetRankedGameData( player, "lastGamePlacementScore" )

	breakdown.wasInProvisonalGame          = Ranked_GetNumProvisionalMatchesCompleted( player ) <= Ranked_GetNumProvisionalMatchesRequired()
	breakdown.penaltyPointsForAbandoning   = GetRankedGameData( player,  "lastGamePenaltyPointsForAbandoning" )
	breakdown.lossProtectionAdjustment     = GetRankedGameData ( player, "lastGameLossProtectionAdjustment"  )
	breakdown.demotionProtectionAdjustment = GetRankedGameData ( player, "lastGameTierDerankingProtectionAdjustment" )
	breakdown.startingLP                   = GetRankedGameData ( player, "lastGameStartingScore" )
	breakdown.netLP 					   = GetRankedGameData ( player, "lastGameScoreDiff" )

	breakdown.killBonus                    = GetRankedGameData ( player, "lastGameBonus[0]" )
	breakdown.convergenceBonus             = GetRankedGameData ( player, "lastGameBonus[1]" )
	breakdown.skillDiffBonus               = GetRankedGameData ( player, "lastGameBonus[2]" )
	breakdown.provisionalMatchBonus               = GetRankedGameData ( player, "lastGameBonus[3]" )

	breakdown.finalLP 					   = breakdown.startingLP + breakdown.netLP

	breakdown.demotionPenality 			   = ( GetCurrentRankedDivisionFromScore( breakdown.finalLP ).tier.index  < GetCurrentRankedDivisionFromScore( breakdown.startingLP ).tier.index )
													? GetCurrentPlaylistVarInt ( "ranked_tier_demotion_penality", RANKED_LP_DEMOTION_PENALITY )
													: 0

	#if DEV
		PrintRankLadderPointsBreakdown (breakdown, 1, "LoadLPBreakdownFromPersistance" )
	#endif
}