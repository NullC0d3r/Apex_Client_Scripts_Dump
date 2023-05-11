#if UI
global function IsPrivateMatchPostGameMenuValid
global function OpenPrivateMatchPostGameMenu
global function ClosePrivateMatchPostGameMenu
#endif

#if UI
global function InitSetTeamNameDialogMenu
global function DisplaySetTeamNameDialog
#endif

const int TEAM_NAME_MIN_LENGTH = 3

struct PlacementStruct
{
	var           headerPanel
	var           listPanel
	int           teamIndex
	int			  teamPlacement
	int           teamSize
	int           teamDisplayNumber

	array<var>      _listButtons

	array<PrivateMatchStatsStruct> playerPlacementData
}

enum ePlacementSortingMethod
{
	BY_PLACEMENT,
	BY_TEAM_INDEX,

	_count
}

struct
{
	var menu

	var continueButton

	var decorationRui
	var menuHeaderRui

	var teamRosterPanel

	bool wasPartyMember = false                                                                                                                                                                                                                
	bool disableNavigateBack = false

	bool skippableWaitSkipped = false

	int xpChallengeTier = -1
	int xpChallengeValue = -1

	var    setTeamNameDialog
	int    setTeamNameDialog_teamIndex
	var    TextEntryCodeBox
	string setTeamNameDialog_teamName

	table< int, PlacementStruct > teamPlacement

	var sortingMethodButton
	int sortingMethod = ePlacementSortingMethod.BY_PLACEMENT
} file

#if UI
bool function IsPrivateMatchPostGameMenuValid( bool checkTime = false )
{
	                                                                                                                  
	  	            
	  
	                                  
	  	            
	  
	                                                                                                          
	  	            

	return true
}


void function OpenPrivateMatchPostGameMenu( var button )
{
	Assert( IsPrivateMatchPostGameMenuValid() )

	AdvanceMenu( file.menu )
}


void function ClosePrivateMatchPostGameMenu( var button )
{
	if ( GetActiveMenu() == file.menu )
		thread CloseActiveMenu()
}
#endif


#if UI

void function InitSetTeamNameDialogMenu( var menu )
{
	file.setTeamNameDialog = menu

	SetDialog( menu, true )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, SetTeamName_OnOpen )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, SetTeamName_OnClose )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, SetTeamName_OnNavigateBack )

	var panel = Hud_GetChild( file.setTeamNameDialog, "SetTeamNameBox" )
	RegisterSignal( Hud_GetHudName( panel ) )
	file.TextEntryCodeBox = Hud_GetChild( panel, "TextEntryCode" )
	InitTextEntry( panel, RenameTeamOnTextEntry )
}

void function InitTextEntry( var panel, void functionref( string entryCode ) activateCallback )
{
	var connectButton = Hud_GetChild( panel, "ConnectButton" )
	Hud_AddEventHandler( connectButton, UIE_CLICK, SaveButton_OnClick )
	HudElem_SetRuiArg( connectButton, "buttonText", "#TOURNAMENT_SAVE_TEAM_NAME" )

	var frame = Hud_GetChild( panel, "ConnectBoxFrame" )
	HudElem_SetRuiArg( frame, "titleText", "#TOURNAMENT_RENAME_TEAM" )
	HudElem_SetRuiArg( frame, "subtitleText", "#TOURNAMENT_TEAM_NAME" )
	InitButtonRCP( frame )

	var textEntry = file.TextEntryCodeBox

	Hud_AddEventHandler( connectButton, UIE_CLICK, void function( var button ) : ( textEntry, activateCallback ) {
		string entryCode = Hud_GetUTF8Text( file.TextEntryCodeBox )
		activateCallback( entryCode )
	} )
}

void function DisplaySetTeamNameDialog( int teamIndex, string teamName )
{
	file.setTeamNameDialog_teamIndex = teamIndex
	file.setTeamNameDialog_teamName = teamName

	AdvanceMenu( file.setTeamNameDialog )
}

void function SetTeamName_OnOpen()
{
	UI_SetPresentationType( ePresentationType.WEAPON_CATEGORY )

	Hud_SetEnabled( file.TextEntryCodeBox, true )
	Hud_SetFocused( file.TextEntryCodeBox )
	Hud_SetUTF8Text( file.TextEntryCodeBox, file.setTeamNameDialog_teamName )
	Hud_SetTextEntryTitle( file.TextEntryCodeBox, "#TOURNAMENT_TEAM_NAME" )
	RegisterButtonPressedCallback( KEY_ENTER, SaveButton_OnClick )

	thread TournamentSetTeamNameMenu_Update( Hud_GetChild( file.setTeamNameDialog, "SetTeamNameBox" ) )
}

void function TournamentSetTeamNameMenu_Update( var panel )
{
	string signalName = Hud_GetHudName( panel )

	Signal( uiGlobal.signalDummy, signalName )
	EndSignal( uiGlobal.signalDummy, signalName )

	var textEntry     = Hud_GetChild( panel, "TextEntryCode" )
	var connectButton = Hud_GetChild( panel, "ConnectButton" )

	while ( true )
	{
		string entryCode = Hud_GetUTF8Text( textEntry )
		Hud_SetEnabled( connectButton, entryCode.len() >= TEAM_NAME_MIN_LENGTH )

		WaitFrame()
	}
}

void function RenameTeamOnTextEntry( string entryCode )
{
	file.setTeamNameDialog_teamName = entryCode

	Hud_SetUTF8Text( file.TextEntryCodeBox, entryCode )

	if ( CanRunClientScript() )
		RunClientScript( "SetTeamName_OnOnSave", file.setTeamNameDialog_teamIndex, entryCode )

	if ( GetActiveMenu() == file.setTeamNameDialog )
		CloseActiveMenu()
}


void function SaveButton_OnClick( var button )
{
	string newTeamName = Hud_GetUTF8Text( file.TextEntryCodeBox )
	if ( CanRunClientScript() )
		RunClientScript( "SetTeamName_OnOnSave", file.setTeamNameDialog_teamIndex, newTeamName )

	if ( GetActiveMenu() == file.setTeamNameDialog )
		CloseActiveMenu()
}


void function SetTeamName_OnClose()
{
	DeregisterButtonPressedCallback( KEY_ENTER, SaveButton_OnClick )

	Signal( uiGlobal.signalDummy, Hud_GetHudName(  Hud_GetChild( file.setTeamNameDialog, "SetTeamNameBox" ) ) )
}


void function SetTeamName_OnNavigateBack()
{
	CloseActiveMenu()
}
#endif

