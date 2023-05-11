global function InitCharacterEmotesPanel
global function CharacterEmotesPanel_SetHintSub

global function EmotesPanel_CreateTabs
global function EmotesPanel_DestroyTabs

struct SectionDef
{
	var button
	var panel
	var listPanel
	int index
}

struct
{
	var panel
	var headerRui

	array<SectionDef> sections
	int               activeSectionIndex = 0
	table<int, array<int> > sectionToFilters
	table<int, bool functionref() > sectionIsValidFunc


	TabDef& emotesTabDef
	TabDef& holoSpraysTabDef
	TabDef& quipsTabDef
	TabDef& skyDiveTabDef

	bool addedSkydiveNewness = false

	ItemFlavor ornull lastNewnessCharacter
} file

void function InitCharacterEmotesPanel( var panel )
{
	file.panel = panel
	file.headerRui = Hud_GetRui( Hud_GetChild( panel, "Header" ) )

	SetPanelTabTitle( panel, "#SOCIAL_WHEEL" )
	RuiSetString( file.headerRui, "title", "" )
	RuiSetString( file.headerRui, "collected", "" )

	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, EmotesPanel_OnShow )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, EmotesPanel_OnHide )

	AddCallback_OnTopLevelCustomizeContextChanged( panel, EmotesPanel_OnCustomizeContextChanged )

	HudElem_SetRuiArg( Hud_GetChild( file.panel, "HintMKB" ), "textBreakWidth", 400.0 )
	HudElem_SetRuiArg( Hud_GetChild( file.panel, "HintGamepad" ), "textBreakWidth", 400.0 )
}

void function EmotesPanel_CreateTabs()
{
	file.emotesTabDef = AddTab( file.panel, Hud_GetChild( file.panel, "EmotesPanel" ), "#EMOTES" )
	SetTabBaseWidth( file.emotesTabDef, 160 )

	file.holoSpraysTabDef = AddTab( file.panel, Hud_GetChild( file.panel, "HoloSpraysPanel" ), "#HOLOS" )
	SetTabBaseWidth( file.holoSpraysTabDef, 210 )

	file.quipsTabDef = AddTab( file.panel, Hud_GetChild( file.panel, "LinePanel" ), "#QUIPS" )
	SetTabBaseWidth( file.quipsTabDef, 140 )

	file.skyDiveTabDef = AddTab( file.panel, Hud_GetChild( file.panel, "SkydiveEmotesPanel" ), "#SKYDIVE_EMOTES" )
	SetTabBaseWidth( file.skyDiveTabDef, 240 )
	file.skyDiveTabDef.visible = HasEquippableSkydiveEmotes()
	file.skyDiveTabDef.enabled = HasEquippableSkydiveEmotes()

	TabData tabData = GetTabDataForPanel( file.panel )
	tabData.centerTabs = true
	SetTabBackground( tabData, Hud_GetChild( file.panel, "TabsBackground" ), eTabBackground.STANDARD )
	SetTabDefsToSeasonal(tabData)
}

void function EmotesPanel_DestroyTabs()
{
	ClearTabs( file.panel )
}

void function EmotesPanel_OnShow( var panel )
{
	UI_SetPresentationType( ePresentationType.CHARACTER_QUIPS )

	file.activeSectionIndex = 0

	CharacterEmotesPanel_Update()

	for ( int i = 0; i < MAX_FAVORED_QUIPS; i++ )
		AddCallback_ItemFlavorLoadoutSlotDidChange_SpecificPlayer( LocalClientEHI(), Loadout_FavoredQuip( GetTopLevelCustomizeContext(), i ), OnFavoredQuipChanged )

	CharacterEmotesPanel_SetHintSub( "#HINT_SOCIAL_ANTI_PEEK" )

	foreach ( sectionIndex, sectionDef in file.sections )
	{
		bool functionref() isValidFunc = file.sectionIsValidFunc[ sectionIndex ]

		if ( isValidFunc != null )
			Hud_SetVisible( sectionDef.button, isValidFunc() )
	}

	TabData tabData = GetTabDataForPanel( file.panel )

	SetTabNavigationCallback( tabData,  Tabs_OnChanged )

	if ( GetLastMenuNavDirection() == MENU_NAV_FORWARD )
	{
		ActivateTab( tabData, 0 )
		thread AnimateInSmallTabBar( tabData )
	}
}


void function EmotesPanel_OnHide( var panel )
{
	ClearNewnessCallbacks()
	TabData tabData = GetTabDataForPanel( panel )
	HideVisibleTabBodies( tabData )

	RunClientScript( "ClearBattlePassItem" )

	for ( int i = 0; i < MAX_FAVORED_QUIPS; i++ )
		RemoveCallback_ItemFlavorLoadoutSlotDidChange_SpecificPlayer( LocalClientEHI(), Loadout_FavoredQuip( GetTopLevelCustomizeContext(), i ), OnFavoredQuipChanged )
}

void function Tabs_OnChanged( TabDef tabDef )
{
	if( tabDef == file.emotesTabDef )
	{
		QuipPanel_SetItemTypeFilter( [ eItemType.character_emote ] )
	}
	else if( tabDef == file.holoSpraysTabDef )
	{
		QuipPanel_SetItemTypeFilter( [ eItemType.emote_icon ] )
	}
	else if( tabDef == file.quipsTabDef )
	{
		QuipPanel_SetItemTypeFilter( [ eItemType.gladiator_card_kill_quip, eItemType.gladiator_card_intro_quip ] )
	}
	else if( tabDef == file.skyDiveTabDef )
	{
		QuipPanel_SetItemTypeFilter( [ eItemType.skydive_emote ] )
	}
}

void function CharacterEmotesPanel_SetHintSub( string hintSub )
{
	if ( hintSub != "" )
		hintSub = "\n\n" + Localize( hintSub )

	RunClientScript( "SetHintTextOnHudElem", Hud_GetChild( file.panel, "HintMKB" ), "#HINT_SOCIAL_WHEEL_MKB", hintSub )
	RunClientScript( "SetHintTextOnHudElem", Hud_GetChild( file.panel, "HintGamepad" ), "#HINT_SOCIAL_WHEEL_GAMEPAD", hintSub )
}


void function OnFavoredQuipChanged( EHI playerEHI, ItemFlavor flavor )
{
	UpdateFooterOptions()
}


void function EmotesPanel_OnCustomizeContextChanged( var panel )
{
	if ( !IsPanelActive( file.panel ) )
		return

	CharacterEmotesPanel_Update()
}


void function CharacterEmotesPanel_Update()
{
	UpdateNewnessCallbacks()

	ItemFlavor character = GetTopLevelCustomizeContext()
	ItemFlavor characterSkin = LoadoutSlot_GetItemFlavor( LocalClientEHI(), Loadout_CharacterSkin( character ) )
	RunClientScript( "UIToClient_PreviewCharacterSkin", ItemFlavor_GetGUID( characterSkin ), ItemFlavor_GetGUID( character ) )
}


void function UpdateNewnessCallbacks()
{
	if ( !IsTopLevelCustomizeContextValid() )
		return

	ClearNewnessCallbacks()

	ItemFlavor character = GetTopLevelCustomizeContext()

	Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterEmotesStandingEmotesSectionButton[character], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "EmotesPanel" ) )
	Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterEmotesHolospraySectionButton[character], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "HoloSpraysPanel" ) )
	Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterKillQuipSectionButton[character], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "LinePanel" ) )

	bool hasEquippableSkydiveEmotes = HasEquippableSkydiveEmotes()
	if( hasEquippableSkydiveEmotes )
	{
		file.skyDiveTabDef.visible = hasEquippableSkydiveEmotes
		file.skyDiveTabDef.enabled = hasEquippableSkydiveEmotes
		file.addedSkydiveNewness = true
		Newness_AddCallbackAndCallNow_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterEmotesSkydiveEmotesSectionButton[character], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "SkydiveEmotesPanel" ) )
	}

	file.lastNewnessCharacter = character
}


void function ClearNewnessCallbacks()
{
	if ( file.lastNewnessCharacter == null )
		return

	ItemFlavor character = expect ItemFlavor( file.lastNewnessCharacter )

	Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterEmotesStandingEmotesSectionButton[character], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "EmotesPanel" ) )
	Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterEmotesHolospraySectionButton[character], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "HoloSpraysPanel" ) )
	Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterKillQuipSectionButton[character], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "LinePanel" ) )
	if( file.addedSkydiveNewness )
	{
		Newness_RemoveCallback_OnRerverseQueryUpdated( NEWNESS_QUERIES.CharacterEmotesSkydiveEmotesSectionButton[character], OnNewnessQueryChangedUpdatePanelTab, GetPanel( "SkydiveEmotesPanel" ) )
		file.addedSkydiveNewness = false
	}

	file.lastNewnessCharacter = null
}
