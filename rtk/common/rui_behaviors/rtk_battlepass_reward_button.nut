global function RTKBattlePassRewardButton_InitMetaData
global function RTKBattlePassRewardButton_OnInitialize
global function RTKBattlePassRewardButton_OnDrawBegin
global function RTKBattlePassRewardButton_OnDestroy

global struct RTKBattlePassRewardButton_Properties
{
	asset battlepassRewardRui

	rtk_behavior button

	int quantity = 0
	int level = 0

	bool isOwned = false
	bool isTall = false

	int flavGUID = 0
}

void function RTKBattlePassRewardButton_InitMetaData( string behaviorType, string structType )
{
	RTKMetaData_BehaviorIsRuiBehavior( behaviorType, true )

	RTKMetaData_SetAllowedBehaviorTypes( structType, "button", [ "Button" ] )
}

void function RTKBattlePassRewardButton_OnInitialize( rtk_behavior self )
{
	self.AddPropertyCallback( "battlepassRewardRui", UpdateBattlePassRewardRuiAsset )

	rtk_behavior ornull button = self.PropGetBehavior( "button" )
	if ( button != null )
	{
		self.AutoSubscribe( button, "onPressed", function( rtk_behavior button, int keycode, int prevState ) : ( self ) {
			BattlePassRewardButton_OnActivate( self )
		} )

		self.AutoSubscribe( button, "onHighlighted", function( rtk_behavior button, int prevState ) : ( self ) {
			BattlePassRewardButton_OnFocus( self, true )
		} )

		self.AutoSubscribe( button, "onIdle", function( rtk_behavior button, int prevState ) : ( self ) {
			BattlePassRewardButton_OnFocus( self, false )
		} )
	}

	UpdateBattlePassRewardRuiAsset( self )
}

void function RTKBattlePassRewardButton_OnDestroy( rtk_behavior self )
{
	rtk_panel panel = self.GetPanel()

	if ( panel.HasRui() )
		panel.DestroyRui()
}

void function BattlePassRewardButton_OnActivate( rtk_behavior self )
{
	if( !IsValidItemFlavGUID( self ) )
		return

	BattlePassReward item = GetBattlePassRewardItemFlav( self )

	if ( ItemFlavor_GetType( item.flav ) == eItemType.loadscreen )
	{
		LoadscreenPreviewMenu_SetLoadscreenToPreview( item.flav )
		AdvanceMenu( GetMenu( "LoadscreenPreviewMenu" ) )
	}
	else if ( ItemFlavor_GetType( item.flav ) == eItemType.gladiator_card_badge )
	{
		SetChallengeRewardPresentationModeActive( item.flav, item.quantity, 0,
			"",
			"",
			item.isOwned,
			true
		)
	}
	else if ( InspectItemTypePresentationSupported( item.flav ) )
	{
		RunClientScript( "ClearBattlePassItem" )
		SetBattlePassItemPresentationModeActive( item )
	}
}

void function BattlePassRewardButton_OnFocus( rtk_behavior self, bool value )
{
	rtk_panel panel = self.GetPanel()

	if ( panel.HasRui() )
	{
		panel.SetRuiArgBool( "isFocused", value )
	}
}

void function UpdateBattlePassRewardRuiAsset( rtk_behavior self )
{
	rtk_panel panel = self.GetPanel()

	asset battlepassRewardRuiAsset = expect asset( self.rtkprops.battlepassRewardRui )

	if ( battlepassRewardRuiAsset != "" )
		panel.CreateRui( battlepassRewardRuiAsset )
	else if ( panel.HasRui() )
		panel.DestroyRui()
}

void function RTKBattlePassRewardButton_OnDrawBegin( rtk_behavior self )
{
	rtk_panel panel = self.GetPanel()

	if ( panel.HasRui() && IsValidItemFlavGUID( self ) )
	{
		BattlePassReward item = GetBattlePassRewardItemFlav( self )

		        
		panel.SetRuiArgBool( "isRewardBar", false )
		panel.SetRuiArgBool( "showCharacterIcon", false )
		panel.SetRuiArgBool( "forceShowRarityBG", false )
		panel.SetRuiArgBool( "forceFullIcon", false )
		panel.SetRuiArgBool( "hideBackground", false )
		panel.SetRuiArgBool( "isPremiumBPOwned", false )
		panel.SetRuiArgBool( "isPassPanel", false )
		panel.SetRuiArgBool( "isSelected", false )

		panel.SetRuiArgInt( "forceFocusShineMarker", 0 )
		panel.SetRuiArgInt( "panelPos", 0 )
		panel.SetRuiArgInt( "bpLevel", -1 )

		panel.SetRuiArgImage( "buttonImageSecondLayer", $"" )
		panel.SetRuiArgImage( "characterIcon", $"" )
		panel.SetRuiArgString( "itemCountString", "" )

		panel.SetRuiArgFloat2( "buttonImageSecondLayerOffset", <0.0, 0.0, 0.0> )

		                    
		bool isRewardLootBox = ( ItemFlavor_GetType( item.flav ) == eItemType.account_pack )
		panel.SetRuiArgBool( "isLootBox", isRewardLootBox )

		panel.SetRuiArgBool( "isPremium", item.isPremium )
		if( ItemFlavor_HasQuality( item.flav  ) )
			panel.SetRuiArgInt( "rarity", ItemFlavor_GetQuality( item.flav ) )

		bool isRewardCurrency = ( ItemFlavor_GetType( item.flav ) == eItemType.account_currency )
		if( isRewardCurrency )
			panel.SetRuiArgString( "itemCountString", string( item.quantity ) )

		panel.SetRuiArgImage( "buttonImage", CustomizeMenu_GetRewardButtonImage( item.flav ) )
		panel.SetRuiArgBool( "isOwned", item.isOwned )

		asset rewardImage = CustomizeMenu_GetRewardButtonImage( item.flav )
		if ( ShouldDisplayTallButton( item.flav ) && item.isTall )                 
		{
			panel.SetHeight( panel.GetWidth() * 1.5 )

			if ( ItemFlavor_GetType( item.flav ) != eItemType.character_skin )
			{
				asset icon = GetCharacterIconToDisplay( item.flav )
				panel.SetRuiArgBool( "showCharacterIcon", icon != $""  )
				panel.SetRuiArgImage( "characterIcon", icon )
				panel.SetRuiArgFloat2( "characterIconSize", <35, 35, 0> )

				                                                                                                                        
				                         
				                                                                 
				   
				  	                                         
				  	 
						                                                                                      
						                                                              
						                                                    
						  
						                                             
						                                                          
						  
						                       
						   
						  	                                                                                         
						  	                                                                                    
						  	                                              
						  	                                                            
						  	                                                                        
						   
				  	 
				   
			}
			else
			{
				panel.SetRuiArgBool( "forceFullIcon", true )
			}
		}

	}
}

bool function IsValidItemFlavGUID( rtk_behavior self )
{
	int flavGUID = self.PropGetInt( "flavGUID" )
	return IsValidItemFlavorGUID(flavGUID)
}

BattlePassReward function GetBattlePassRewardItemFlav( rtk_behavior self )
{
	BattlePassReward item

	if( IsValidItemFlavGUID( self ) )
	{
		item.quantity = self.PropGetInt( "quantity" )
		item.level = self.PropGetInt( "level" )
		item.flav = GetItemFlavorByGUID( self.PropGetInt( "flavGUID" ) )
		item.isOwned = self.PropGetBool( "isOwned" )
		item.isTall = self.PropGetBool( "isTall" )
	}
	return item
}
