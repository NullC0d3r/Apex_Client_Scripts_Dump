global function InitCustomMatchSettingsPanel
global function InitCustomMatchSettingsListPanel
global function InitCustomMatchScrollableSettingsPanel
global function InitCustomMatchScrollableSettingsInternalPanel

global function CustomMatchSettings_OnOpen
struct
{
	var panel
	var modeSelectPanel
	var mapSelectPanel
	var optionsSelectPanel

	var selectOptionsPanel
	var scrollFrame
	var scrollBar
	var contentPanel
	var cancelButton
	var submitButton

} file

void function InitCustomMatchSettingsPanel( var panel )
{
	file.panel = panel

	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, CustomMatchSettings_OnOpen )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, CustomMatchSettings_OnClose )

	file.modeSelectPanel 	= Hud_GetChild( panel, "ModeSelectPanel" )
	var settingsSelectPanel = Hud_GetChild( panel, "SettingsSelectPanel" )

	Hud_Show( file.modeSelectPanel )
	Hud_Show( settingsSelectPanel )

	AddPanelFooterOption( panel, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
	AddPanelFooterOption( panel, LEFT, BUTTON_A, true, "#A_BUTTON_SELECT" )
}

void function InitCustomMatchSettingsListPanel( var panel )
{
	var scrollableSettingsPanel = Hud_GetChild( panel, "SelectOptions" )
	Hud_Show( scrollableSettingsPanel )

	var scrollableSettingsInternalPanel = Hud_GetChild( scrollableSettingsPanel, "ContentPanel" )
	Hud_Show( scrollableSettingsInternalPanel )

	file.mapSelectPanel 	= Hud_GetChild( scrollableSettingsInternalPanel, "MapSelectPanel" )
	file.optionsSelectPanel = Hud_GetChild( scrollableSettingsInternalPanel, "OptionsSelectPanel" )

	Hud_Show( file.mapSelectPanel )
	Hud_Show( file.optionsSelectPanel )

	file.submitButton 		= Hud_GetChild( panel, "SubmitButton" )
	file.cancelButton 		= Hud_GetChild( panel, "CancelButton" )
	AddButtonEventHandler( file.submitButton, UIE_CLICK, SubmitButton_OnClick )
	AddButtonEventHandler( file.cancelButton, UIE_CLICK, CancelButton_OnClick )
}

void function InitCustomMatchScrollableSettingsPanel( var panel )
{
	file.selectOptionsPanel = panel

	file.scrollBar = Hud_GetChild( panel, "ScrollBar" )
	file.scrollFrame = Hud_GetChild( panel, "ScrollFrame" )
	file.contentPanel = Hud_GetChild( panel, "ContentPanel" )

	ScrollPanel_InitPanel( panel )
	ScrollPanel_InitScrollBar( panel, file.scrollBar, true, true )

	var rui = Hud_GetRui( file.scrollBar )
	RuiSetColorAlpha( rui, "scrollBarColor", SrgbToLinear( < 0.69, 0.69, 0.69 > ), 1 )
	RuiSetColorAlpha( rui, "backgroundColor", SrgbToLinear( < 1, 1, 1 > ), 0.05 )

	ScrollPanel_SetActive( panel, true )
}

void function InitCustomMatchScrollableSettingsInternalPanel( var panel )
{

}

void function CustomMatchSettings_OnOpen( var panel )
{
	CustomMatch_LockLocalSettings( true )
	CustomMatch_RefreshPlaylists()
	ToggleRenameButtonVisibility()
	AddCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_PLAYLIST, Callback_OnPlaylistChanged )
	Callback_OnPlaylistChanged( CUSTOM_MATCH_SETTING_PLAYLIST, CustomMatch_GetSetting( CUSTOM_MATCH_SETTING_PLAYLIST ) )

	                              
	AddCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_PLAYLIST, CustomMatch_ShowSettingsCancelButton )
	AddCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_CHAT_PERMISSION, CustomMatch_ShowSettingsCancelButton )
	AddCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_RENAME_TEAM, CustomMatch_ShowSettingsCancelButton )
	AddCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_SELF_ASSIGN, CustomMatch_ShowSettingsCancelButton )
	AddCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_AIM_ASSIST, CustomMatch_ShowSettingsCancelButton )
	AddCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_ANONYMOUS_MODE, CustomMatch_ShowSettingsCancelButton )
	AddCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_MATCH_STATUS, CustomMatch_ShowSettingsCancelButton )
}

void function CustomMatchSettings_OnClose( var panel )
{
	CustomMatch_RestoreSettings()
	CustomMatch_LockLocalSettings( false )
	RemoveCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_PLAYLIST, Callback_OnPlaylistChanged )

	                              
	RemoveCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_PLAYLIST, CustomMatch_ShowSettingsCancelButton )
	RemoveCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_CHAT_PERMISSION, CustomMatch_ShowSettingsCancelButton )
	RemoveCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_RENAME_TEAM, CustomMatch_ShowSettingsCancelButton )
	RemoveCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_SELF_ASSIGN, CustomMatch_ShowSettingsCancelButton )
	RemoveCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_AIM_ASSIST, CustomMatch_ShowSettingsCancelButton )
	RemoveCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_ANONYMOUS_MODE, CustomMatch_ShowSettingsCancelButton )
	RemoveCallback_OnCustomMatchSettingChanged( CUSTOM_MATCH_SETTING_MATCH_STATUS, CustomMatch_ShowSettingsCancelButton )
}

void function SubmitButton_OnClick( var button )
{
	if ( CustomMatch_IsLocalAdmin() )
	{
		CustomMatch_SubmitSettings()
		Hud_SetVisible(file.cancelButton, false )
	}
	else
		Warning( "Local player is not a custom match administrator." )

}

void function OnConfirmDialogResult( int result )
{
	switch ( result )
	{
		case eDialogResult.YES:
			CustomMatch_RestoreSettings()
			Hud_SetVisible(file.cancelButton, false )
	}
}

void function CancelButton_OnClick( var button )
{
	ConfirmDialogData data
	data.headerText = "#CUSTOMMATCH_UNDO_CHANGES"
	data.messageText = "#CUSTOMMATCH_UNDO_CHANGES_DESC"
	data.resultCallback = OnConfirmDialogResult

	OpenConfirmDialogFromData( data )
	AdvanceMenu( GetMenu( "ConfirmDialog" ) )
}

void function CustomMatchSettings_OnNavigateBack( var panel )
{
	                                                                                        
	CustomMatch_RestoreSettings()
}

                                                                                      
                             
                                                                                      

void function Callback_OnPlaylistChanged( string _, string value )
{
	if( value == "" )
		return

	CustomMatchPlaylist playlist 	= expect CustomMatchPlaylist( CustomMatch_GetPlaylist( value ) )
	CustomMatchMap map 				= expect CustomMatchMap( CustomMatch_GetMap( playlist.mapIndex ) )
	CustomMatchCategory category 	= expect CustomMatchCategory( CustomMatch_GetCategory( playlist.categoryIndex ) )

	var modeSelected 	= GetButton( Hud_GetChild( file.modeSelectPanel, "SelectModeGrid" ), playlist.categoryIndex )


	var mapSelected 	= GetButton( Hud_GetChild( file.mapSelectPanel, "SelectMapGrid" ), category.maps.find( map ) )
	if( mapSelected == null )
		return

	Hud_SetNavRight( file.modeSelectPanel, mapSelected )
	Hud_SetNavLeft( file.mapSelectPanel, modeSelected )

	                          
	var mapSelectPanel = Hud_GetChild( file.contentPanel, "MapSelectPanel" )
	var mapSubHeader = Hud_GetChild( mapSelectPanel, "SelectMapSubHeader" )

	var optionsPanel = Hud_GetChild( file.contentPanel, "OptionsSelectPanel" )
	int mapRows = int( ceil( category.maps.len() / 3.0 ) )
	if( mapRows < 1 )
		mapRows = 1

	int extraPadding  = (mapRows > 1)? ( mapRows -1 ) * 30: 20
	int mapNewHeight = ( Hud_GetHeight(mapSelected) * mapRows) + Hud_GetHeight(mapSubHeader) + extraPadding


	array<var> buttonArray = GetPanelElementsByClassname( optionsPanel, "SettingScrollSizer" )
	int optionsHeight = 0
	foreach( var b in buttonArray )
	{
		if( Hud_IsVisible( b ) )
			optionsHeight += Hud_GetHeight(b) + Hud_GetBaseY( b )

	}

	int panelHeight = mapNewHeight + optionsHeight

	Hud_SetHeight( mapSelectPanel, mapNewHeight )
	Hud_SetHeight( file.contentPanel, panelHeight )

	ScrollPanel_Refresh( file.selectOptionsPanel )
}

void function Callback_OnSettingChanged( var button, string setting, string value )
{
	Hud_SetDialogListSelectionValue( button, value )
}

var function GetButton( var menuGrid, int index )
{
	Assert( index < Hud_GetButtonCount( menuGrid ) )
	if ( index < Hud_GetButtonCount( menuGrid ) )
		return Hud_GetButton( menuGrid, index )
	return null
}

void function CustomMatch_ShowSettingsCancelButton(string setting, string value)
{
	Hud_SetVisible(file.cancelButton, CustomMatch_GetSetting(setting) != value )
}