global function InitCharacterAbilitiesPanel

global function SetCharacterSkillsPanelLegend

struct
{
	ItemFlavor& character
	bool showGladCard = false

	var activePanel
} file

void function InitCharacterAbilitiesPanel( var panel )
{
	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, CharacterAbilitiesPanel_OnShow )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, CharacterAbilitiesPanel_OnHide )

	var parentMenu = GetParentMenu( panel )

	if(parentMenu == GetMenu( "SurvivalInventoryMenu" )  )
		InitLegendPanelInventory( panel )
	else
	{
		AddPanelFooterOption( panel, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
	}
}


void function CharacterAbilitiesPanel_OnShow( var panel )
{
	file.activePanel = panel
	SetUpGladCard( panel )

	UpdateCharacterAbilities( panel )
	EmitUISound( "UI_Menu_Legend_Details" )
}

void function UpdateCharacterAbilities( var panel )
{
	if( panel == null )
		return

	string character  = ItemFlavor_GetCharacterRef( file.character )

	var contentElm = Hud_GetChild( panel, "ContentRui" )
	var contentRui = Hud_GetRui( contentElm )

	if ( LoadoutSlot_IsReady( ToEHI( GetLocalClientPlayer() ), Loadout_Character() ) )
	{
		CharacterHudUltimateColorData colorData = CharacterClass_GetHudUltimateColorData( file.character )
		RuiSetColorAlpha( contentRui, "ultimateColor", SrgbToLinear( colorData.ultimateColor ), 1 )
		RuiSetColorAlpha( contentRui, "ultimateColorHighlight", SrgbToLinear( colorData.ultimateColorHighlight ), 1 )
               
                                                                           
    
                                
                                                        
                                                         
                                                         
                                                           
                                                        
                                                         

                                           
                          
     
                                                                                        
     
    
        
	}

	float damageScale = CharacterClass_GetDamageScale( file.character )

	if ( damageScale < 1.0 )
	{
		int percent        = int( ((1.0 - damageScale) * 100) + 0.5 )
		string finalString = Localize( "#SPECIAL_PERK_N_N", Localize( "#PAS_FORTIFIED" ), Localize( "#PAS_FORTIFIED_DESC", percent ) )
		RuiSetImage( contentRui, "specialPerkIcon", $"rui/hud/passive_icons/juggernaut" )
		RuiSetString( contentRui, "specialPerkDesc", finalString )
	}
	else if ( damageScale > 1.0 )
	{
		int percent        = int( (fabs( 1.0 - damageScale ) * 100) + 0.5 )
		string finalString = Localize( "#SPECIAL_PERK_N_N", Localize( "#PAS_LOW_PROFILE" ), Localize( "#PAS_LOW_PROFILE_DESC", percent ) )
		RuiSetImage( contentRui, "specialPerkIcon", $"rui/hud/passive_icons/low_profile" )
		RuiSetString( contentRui, "specialPerkDesc", finalString )
	}
	else
	{
		RuiSetImage( contentRui, "specialPerkIcon", $"" )
		RuiSetString( contentRui, "specialPerkDesc", "" )
	}

                    
		if( IsValidItemFlavorCharacterRef( character ) )
		{
			int characterRole = CharacterClass_GetRole( file.character )
			string roleTitle = Localize( CharacterClass_GetRoleTitle( characterRole ) ).toupper()

			if ( roleTitle == "" )
			{
				RuiSetImage( contentRui, "rolePerkIcon", $"" )
				RuiSetString( contentRui, "rolePerkName", "" )

				                 
				RuiSetString( contentRui, "perk1Name", "" )
				RuiSetString( contentRui, "perk2Name", "" )
				RuiSetString( contentRui, "perk3Name", "" )

				RuiSetString( contentRui, "perk1Desc", "" )
				RuiSetString( contentRui, "perk2Desc", "" )
				RuiSetString( contentRui, "perk3Desc", "" )

				RuiSetImage( contentRui, "perk1Icon", $"" )
				RuiSetImage( contentRui, "perk2Icon", $"" )
				RuiSetImage( contentRui, "perk3Icon", $"" )
			}
			else
			{
				RuiSetImage( contentRui, "rolePerkIcon", CharacterClass_GetCharacterRoleImage( file.character )  )
				RuiSetString( contentRui, "rolePerkName", roleTitle )

				               
				RuiSetString( contentRui, "perk1Name", replace( Localize( CharacterClass_GetRolePerkShortDescriptionAtIndex( characterRole, 0 ) ), "\n", "" ) )
				RuiSetString( contentRui, "perk2Name", replace( Localize( CharacterClass_GetRolePerkShortDescriptionAtIndex( characterRole, 1 ) ), "\n", "" ) )
				RuiSetString( contentRui, "perk3Name", replace( Localize( CharacterClass_GetRolePerkShortDescriptionAtIndex( characterRole, 2 ) ), "\n", "" ) )

				RuiSetString( contentRui, "perk1Desc", CharacterClass_GetRolePerkDescriptionAtIndex( characterRole, 0 ) )
				RuiSetString( contentRui, "perk2Desc", CharacterClass_GetRolePerkDescriptionAtIndex( characterRole, 1 ) )
				RuiSetString( contentRui, "perk3Desc", CharacterClass_GetRolePerkDescriptionAtIndex( characterRole, 2 ) )

				RuiSetImage( contentRui, "perk1Icon", CharacterClass_GetRolePerkIconAtIndex( characterRole, 0 ) )
				RuiSetImage( contentRui, "perk2Icon", CharacterClass_GetRolePerkIconAtIndex( characterRole, 1 ) )
				RuiSetImage( contentRui, "perk3Icon", CharacterClass_GetRolePerkIconAtIndex( characterRole, 2 ) )

			}
		}
       

	ItemFlavor ornull passiveAbility = null
	foreach ( ItemFlavor ability in CharacterClass_GetPassiveAbilities( file.character ) )
	{
		if ( CharacterAbility_ShouldShowDetails( ability ) )
		{
			                                  
			passiveAbility = ability
			break
		}
	}
	expect ItemFlavor( passiveAbility )

	RuiSetImage( contentRui, "passiveIcon", ItemFlavor_GetIcon( passiveAbility ) )
	RuiSetString( contentRui, "passiveName", Localize( ItemFlavor_GetLongName( passiveAbility ) ) )
	RuiSetString( contentRui, "passiveDesc", Localize( ItemFlavor_GetLongDescription( passiveAbility ) ) )
	RuiSetString( contentRui, "passiveType", Localize( "#PASSIVE" ) )

	RuiSetImage( contentRui, "tacticalIcon", ItemFlavor_GetIcon( CharacterClass_GetTacticalAbility( file.character ) ) )
	RuiSetString( contentRui, "tacticalName", Localize( ItemFlavor_GetLongName( CharacterClass_GetTacticalAbility( file.character ) ) ) )
	RuiSetString( contentRui, "tacticalDesc", Localize( ItemFlavor_GetLongDescription( CharacterClass_GetTacticalAbility( file.character ) ) ) )
	RuiSetString( contentRui, "tacticalType", Localize( "#TACTICAL" ) )

	RuiSetImage( contentRui, "ultimateIcon", ItemFlavor_GetIcon( CharacterClass_GetUltimateAbility( file.character ) ) )
	RuiSetString( contentRui, "ultimateName", Localize( ItemFlavor_GetLongName( CharacterClass_GetUltimateAbility( file.character ) ) ) )
	RuiSetString( contentRui, "ultimateDesc", Localize( ItemFlavor_GetLongDescription( CharacterClass_GetUltimateAbility( file.character ) ) ) )
	RuiSetString( contentRui, "ultimateType", Localize( "#ULTIMATE" ) )

	if ( GetLastMenuNavDirection() == MENU_NAV_FORWARD )
		RuiSetGameTime( contentRui, "initTime", ClientTime() )
}

void function CharacterAbilitiesPanel_OnHide( var panel )
{
	file.activePanel = null
	var elem = Hud_GetChild( panel, "GCard" )
	RunClientScript( "UICallback_DestroyClientGladCardData", elem )
}

void function SetCharacterSkillsPanelLegend( ItemFlavor character, bool showGladCard = false )
{
	file.character = character
	file.showGladCard = showGladCard
	UpdateCharacterAbilities( file.activePanel )
}


void function SetUpGladCard( var panel )
{
	var contentElm = Hud_GetChild( panel, "ContentRui" )
	var gladCardeElem = Hud_GetChild( panel, "GCard" )

	if( file.showGladCard )
	{
		UIScaleFactor scaleFactor = GetContentScaleFactor( GetMenu( "MainMenu" ) )

		Hud_Show( gladCardeElem )
		Hud_SetX( contentElm, 160 * scaleFactor.x )
		int emptyTeamMemberIndex = 0
		var nullMuteButton = null
		var nullMutePingButton = null
		var nullInviteButton = null
		var nullReportButton = null
		var nullBlockButton = null
		var nullOverlayButton = null
		var nullDisconnectedElem = null
		var nullObfuscatedID = null
		RunClientScript( "UICallback_PopulateClientGladCard", panel, gladCardeElem, nullMuteButton, nullMutePingButton, nullReportButton, nullBlockButton, nullInviteButton, nullOverlayButton, nullDisconnectedElem, nullObfuscatedID, emptyTeamMemberIndex, ClientTime(), eGladCardPresentation.FRONT_CLEAN )
	}
	else
	{
		Hud_SetX( contentElm, 0 )
		Hud_Hide( gladCardeElem )
	}
}
