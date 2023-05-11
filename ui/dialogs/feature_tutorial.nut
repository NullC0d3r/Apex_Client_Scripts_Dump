global function InitFeatureTutorialDialog

global function OpenFeatureTutorialDialog
global function FeatureHasTutorialTabs
global function FeatureTutorial_GetGameModeName
global function GetPlaylist_UIRules

global function UI_OpenFeatureTutorialDialog
global function UI_CloseFeatureTutorialDialog
global function AddCallback_UI_FeatureTutorialDialog_PopulateTabsForMode
global function AddCallback_UI_FeatureTutorialDialog_SetTitle
global function UI_FeatureTutorialDialog_BuildDetailsData

const string SFX_MENU_OPENED = "UI_Menu_Focus_Large"

global struct featureTutorialData
{
	string          title
	string		 	description
	asset			image
}

global struct featureTutorialTab
{
	string                       tabName
	array< featureTutorialData > rules
}

struct {
	var                         menu
	bool                        tabsInitialized = false
	array< featureTutorialTab > tabs
	var                         contentElm
	string                      feature = ""

	table < string, array< featureTutorialTab > functionref() > featureTutorialPopulateTabsFunction
	table < string, string functionref() > featureTutorialSetTitleFunction
} file

void function InitFeatureTutorialDialog( var newMenuArg )
{
	var menu = newMenuArg
	file.menu = menu

	SetPopup( menu, true )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, FeatureTutorialDialog_OnOpen )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, FeatureTutorialDialog_OnClose )

	AddCallback_OnTabChanged( FeatureTutorialDialog_OnTabChanged )

	file.contentElm = Hud_GetChild( menu, "DialogContent" )

	AddMenuFooterOption( menu, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
}

void function FeatureTutorialDialog_OnOpen()
{
	                                         
	file.tabs = GetFeatureTutorial()

	if( file.tabs.len() == 0 )                                   
	{
		if ( GetActiveMenu() == file.menu )
		{
			printf( "menu_FeatureTutorialDialog: Attempted to Open About Screen with empty Tabs, Closing" )
			CloseActiveMenu()
		}
	}
	else
	{
		if ( !file.tabsInitialized )
		{
			TabData tabData = GetTabDataForPanel( file.menu )
			tabData.centerTabs = true

			foreach( int idx, tab in file.tabs)
			{
				if( tab.rules.len() > 0 )
					AddTab( file.menu, null, tab.tabName )
			}

			file.tabsInitialized = true
		}

		TabData tabData        = GetTabDataForPanel( file.menu )
		tabData.centerTabs = true
		SetTabDefsToSeasonal( tabData )
		SetTabBackground( tabData, Hud_GetChild( file.menu, "TabsBackground" ), eTabBackground.STANDARD )

		UpdateMenuTabs()

		EmitUISound( SFX_MENU_OPENED )
		SetRTKDataModel( 0 )
	}
}

void function FeatureTutorialDialog_OnClose()
{
	ClearTabs( file.menu )
	UpdateMenuTabs()

	file.tabs.clear()
	file.tabsInitialized = false
}

void function FeatureTutorialDialog_OnTabChanged()
{
	if ( GetActiveMenu() != file.menu )
		return

	TabData tabData = GetTabDataForPanel( file.menu )

	SetRTKDataModel( tabData.activeTabIdx )
}

void function SetRTKDataModel( int index )
{
	var featureTutorialModel = RTKDataModel_GetOrCreateScriptStruct( RTK_MODELTYPE_MENUS, "featureTutorial", "featureTutorialTab" )

	if( index <= file.tabs.len() - 1 )
		RTKStruct_SetValue( featureTutorialModel, file.tabs[index] )

	string title = ""
	if( FeatureHasTutorialTitle( file.feature ) )
	{
		string functionref() populateTitleFunc = file.featureTutorialSetTitleFunction[ file.feature ]
		title = populateTitleFunc()
	}

	RuiSetString( Hud_GetRui( file.contentElm ), "messageText", title )
}

string function FeatureTutorial_GetGameModeName()
{
	string playlist = GetPlaylist()
	return GetPlaylistVarString( playlist, "name", "" )
}

                                                                                             
void function AddCallback_UI_FeatureTutorialDialog_PopulateTabsForMode( array< featureTutorialTab > functionref() func, string ruleSet )
{
	file.featureTutorialPopulateTabsFunction[ ruleSet ] <- func
}

void function AddCallback_UI_FeatureTutorialDialog_SetTitle( string functionref() func, string ruleSet )
{
	file.featureTutorialSetTitleFunction[ ruleSet ] <- func
}

void function OpenFeatureTutorialDialog( var button, string feature = "" )
{
	UI_OpenFeatureTutorialDialog( feature )
}

void function UI_OpenFeatureTutorialDialog( string feature = "" )
{
	if ( !IsFullyConnected() )
		return

	file.feature = feature

	if( !FeatureHasTutorialTabs( file.feature ) )
		return

	AdvanceMenu( GetMenu( "FeatureTutorialDialog" ) )
}


void function UI_CloseFeatureTutorialDialog()
{
	if ( GetActiveMenu() == file.menu )
	{
		CloseActiveMenu()
	}
	else if ( MenuStack_Contains( file.menu ) )
	{
		if( IsDialog( GetActiveMenu() ) )
		{
			                                                                                                  
			CloseAllMenus()
		}
		else
		{
			                                                                                                                                                
			MenuStack_Remove( file.menu )
		}
	}
}


void function FeatureTutorialDialog_Cancel( var button )
{
	CloseAllToTargetMenu( file.menu )
	CloseActiveMenu()
}


string function GetPlaylist()
{
	if ( IsLobby() )
		return Lobby_GetSelectedPlaylist()
	else
		return GetCurrentPlaylistName()

	unreachable
}

string function GetPlaylist_UIRules()
{
	if( !IsFullyConnected() )
		return ""

	return GetPlaylistVarString( GetPlaylist(), "ui_rules", "" )
}

bool function FeatureHasTutorialTabs( string feature )
{
	return (feature in file.featureTutorialPopulateTabsFunction)
}

bool function FeatureHasTutorialTitle( string feature )
{
	return (feature in file.featureTutorialSetTitleFunction)
}

array< featureTutorialTab > function GetFeatureTutorial()
{
	array< featureTutorialTab > tabs

	if ( !FeatureHasTutorialTabs( file.feature ) )
		return tabs

	array< featureTutorialTab > functionref() populateTabsFunc = file.featureTutorialPopulateTabsFunction[ file.feature ]
	tabs = populateTabsFunc()
	return tabs
}

featureTutorialData function UI_FeatureTutorialDialog_BuildDetailsData( string title = "", string description = "", asset image = $"" )
{
	featureTutorialData data
	data.title = title
	data.description = description
	data.image = image

	return data
}