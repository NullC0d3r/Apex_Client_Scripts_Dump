global function InitCustomMatchShareTokenPanel
global function SetCustomMatchShareToken
global function ToggleVisibilityShareToken

struct
{
	var panel
	var accessTokenField
	var toggleButton
	var accessTokenLabel
	bool isAccessTokenHidden = true
	bool isAdmin = true
	bool isVisible = true
} file

void function InitCustomMatchShareTokenPanel( var panel )
{
	file.panel = panel

	                                                                   
	file.accessTokenField = Hud_GetChild( file.panel, "ShareTokenTextEntryCode" )

	                                               
	file.accessTokenLabel = Hud_GetChild( file.panel, "ShareTokenHeader" )
	Hud_SetText( file.accessTokenLabel, Localize( "#CUSTOMMATCH_ACCESS_TOKEN_LABEL" ) )

	                                                                       
	file.toggleButton = Hud_GetChild( file.panel, "ShareTokenToggleButton" )
	AddButtonEventHandler( file.toggleButton, UIE_CLICK, RevealShareToken_OnClick )
}

void function RenameToggleButton()
{
	RuiSetString( Hud_GetRui( file.toggleButton ), "buttonText", file.isAccessTokenHidden ? Localize( "#CUSTOMMATCH_ACCESS_TOKEN_REVEAL" ) : Localize( "#CUSTOMMATCH_ACCESS_TOKEN_HIDE" ) )
}

void function ToggleVisibilityShareToken( bool isVisible )
{
	file.isVisible = isVisible
	Hud_SetVisible( file.panel, file.isAdmin ? file.isVisible : false )
}

void function SetCustomMatchShareToken( bool isAdmin )
{
	                                    
	file.isAdmin = isAdmin
	ToggleVisibilityShareToken( file.isVisible )

	                                                      
	Hud_SetText( file.accessTokenField, GetConVarString( "customMatch_playerToken" ) )

	                                                  
	RenameToggleButton()
}

void function RevealShareToken_OnClick ( var button )
{
	                     
	file.isAccessTokenHidden = !Hud_GetTextHidden( file.accessTokenField )
	Hud_SetTextHidden( file.accessTokenField, file.isAccessTokenHidden )

	                                               
	RenameToggleButton()
}