                   
global function InitCharacterRolesPanel

struct
{
	var             panel
	array<var>  	rolePanelsRui
	var             titleRui
	array<var>		legendsListRuis
} file

void function InitCharacterRolesPanel( var panel )
{
	file.panel = panel

	file.rolePanelsRui = GetPanelElementsByClassname(file.panel, "RoleInfoPanel")
	file.legendsListRuis = GetPanelElementsByClassname( file.panel, "LegendsLists" )

	AddPanelEventHandler( file.panel, eUIEvent.PANEL_SHOW, RoleInfoDialog_OnShow )
	AddPanelEventHandler( file.panel, eUIEvent.PANEL_HIDE, RoleInfoDialog_OnHide )

	AddPanelFooterOption( file.panel, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
}

void function RoleInfoDialog_OnShow( var panel )
{
	EmitUISound( "UI_Menu_Legend_Details" )

	array<ItemFlavor> allValidCharacters
	foreach( ItemFlavor itemFlav in GetAllCharacters() )
	{
		if ( !ItemFlavor_ShouldBeVisible( itemFlav, null, GetConVarInt( "mtx_svEdition" ) ) )
			continue

		allValidCharacters.push(itemFlav)
	}

	array<ItemFlavor> orderedCharacters = GetCharacterButtonOrder( allValidCharacters, NUM_CHARACTER_SELECT_BUTTONS )
	array<int> characterRoleSize = GetCharacterRoleSize(orderedCharacters)

	int legendIndex = 0

	foreach (index, rolePanel in file.rolePanelsRui)
	{
		var panelRui = Hud_GetRui(rolePanel)
		int roleId = int(Hud_GetScriptID( rolePanel ))

		RuiSetGameTime( panelRui, "initTime", ClientTime() )
		RuiSetString( panelRui, "roleTitle", CharacterClass_GetRoleTitle(roleId) )
		RuiSetString( panelRui, "roleSubtitle", CharacterClass_GetRoleSubtitle(roleId) )
		RuiSetString( panelRui, "roleDescription1", CharacterClass_GetRolePerkDescriptionAtIndex(roleId,0) )
		RuiSetString( panelRui, "roleDescription2", CharacterClass_GetRolePerkDescriptionAtIndex(roleId,1) )
		RuiSetString( panelRui, "roleDescription3", CharacterClass_GetRolePerkDescriptionAtIndex(roleId,2) )
		RuiSetImage( panelRui, "roleIcon", CharacterClass_GetRoleIcon(roleId) )
		RuiSetColorAlpha( panelRui, "roleColor", CharacterClass_GetRoleColor( roleId ), 1.0 )
		
		if (index < file.legendsListRuis.len())
		{
			var legendsList = file.legendsListRuis[index]
			Hud_InitGridButtons( legendsList, characterRoleSize[index] )
			var scrollPanel = Hud_GetChild( legendsList, "ScrollPanel" )

			for (int i= 0; i < characterRoleSize[index]; i++ )
			{
				var button = Hud_GetChild( scrollPanel, ("GridButton" + i) )
				var buttonRui = Hud_GetRui( button )
				RuiSetFloat( buttonRui, "animationOffset", 0.15 )
				RuiSetGameTime( buttonRui, "initTime", ClientTime() )
				RuiSetImage( buttonRui, "legendPortrait", CharacterClass_GetGalleryPortrait( orderedCharacters[legendIndex] ) )
				legendIndex++
			}


		}
	}
}


void function RoleInfoDialog_OnHide( var panel )
{
}

      