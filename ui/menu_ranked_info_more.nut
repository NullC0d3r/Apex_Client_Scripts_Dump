global function InitRankedInfoMoreMenu
global function OpenRankedInfoMorePage

struct
{
	var menu
} file

void function InitRankedInfoMoreMenu( var newMenuArg )                                               
{
	var menu = GetMenu( "RankedInfoMoreMenu" )
	file.menu = menu

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, OnRankedInfoMoreMenu_Open )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnRankedInfoMoreMenu_Close )

	AddMenuEventHandler( menu, eUIEvent.MENU_SHOW, OnRankedInfoMoreMenu_Show )
	AddMenuEventHandler( menu, eUIEvent.MENU_HIDE, OnRankedInfoMoreMenu_Hide )

	AddMenuFooterOption( menu, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
}

void function OpenRankedInfoMorePage( var button )
{
	AdvanceMenu( file.menu )
}

void function OnRankedInfoMoreMenu_Open()
{
	UI_SetPresentationType( ePresentationType.WEAPON_CATEGORY )
	
	int currentScore                     = GetPlayerRankScore( GetLocalClientPlayer() )
	array<SharedRankedTierData> tiers    = Ranked_GetTiers()
	int ladderPosition                   = Ranked_GetLadderPosition( GetLocalClientPlayer() )
	SharedRankedDivisionData currentRank = GetCurrentRankedDivisionFromScoreAndLadderPosition( currentScore, ladderPosition )
	SharedRankedTierData currentTier     = currentRank.tier
	
	var mainRui = Hud_GetRui( Hud_GetChild( file.menu, "InfoMain" ) )
	
	                       
	                                     
	   
	  	                            
	  	                                 
	  	                                                                                                                
	  	                                                 
	   

	var rankedScoringTableRui = Hud_GetRui( Hud_GetChild( file.menu, "RankedScoringTable" ) )
	RuiSetInt( rankedScoringTableRui, "fourteenthPlaceRP", Ranked_GetPointsForPlacement( 14 ) )
	RuiSetInt( rankedScoringTableRui, "eleventhPlaceRP", Ranked_GetPointsForPlacement( 11 ) )
	RuiSetInt( rankedScoringTableRui, "tenthPlaceRP", Ranked_GetPointsForPlacement( 10 ) )
	RuiSetInt( rankedScoringTableRui, "ninthPlaceRP", Ranked_GetPointsForPlacement( 9 ) )
	RuiSetInt( rankedScoringTableRui, "eighthPlaceRP", Ranked_GetPointsForPlacement( 8 ) )
	RuiSetInt( rankedScoringTableRui, "seventhPlaceRP", Ranked_GetPointsForPlacement( 7 ) )
	RuiSetInt( rankedScoringTableRui, "sixthPlaceRP", Ranked_GetPointsForPlacement( 6 ) )
	RuiSetInt( rankedScoringTableRui, "fifthPlaceRP", Ranked_GetPointsForPlacement( 5 ) )	
	RuiSetInt( rankedScoringTableRui, "fourthPlaceRP", Ranked_GetPointsForPlacement( 4 ) )
	RuiSetInt( rankedScoringTableRui, "thirdPlaceRP", Ranked_GetPointsForPlacement( 3 ) )
	RuiSetInt( rankedScoringTableRui, "secondPlaceRP", Ranked_GetPointsForPlacement( 2 ) )
	RuiSetInt( rankedScoringTableRui, "firstPlaceRP", Ranked_GetPointsForPlacement( 1 ) )
	
	                                                                                                                    
	                                                                                                                  
	                                                                                                              
	                                                                                                                
	                                                                                                              
	  
	                                                                                                              
	                                                                                                               
	                                                                                                              
	                                                                                                               
	                                                                                                              

	                                                                                                                               
	                                                                                                                            
	                                                                                                                           
	                                                                                                                           
	  	                                                                                                                         
	
	
	
	
    Hud_SetVisible( Hud_GetChild( file.menu, "PanelArt" ), false )
	                                                       
	                                                                 
	                                                                                                                                                                                                                           
}

void function OnRankedInfoMoreMenu_Close()
{

}

void function OnRankedInfoMoreMenu_Show()
{

}

void function OnRankedInfoMoreMenu_Hide()
{

}