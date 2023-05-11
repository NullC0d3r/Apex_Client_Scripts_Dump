global function InitPackInfoDialog
global function OpenPackInfoDialog

struct {
	var menu
	var infoPanel
}file

void function InitPackInfoDialog( var newMenuArg )
{
	var menu = newMenuArg
	file.menu = menu

	file.infoPanel = Hud_GetChild( menu, "InfoPanel" )

	AddMenuFooterOption( menu, LEFT, BUTTON_B, true, "#B_BUTTON_CLOSE", "#B_BUTTON_CLOSE" )
	SetDialog( menu, true )
}

void function OpenPackInfoDialog( var button )
{
	if ( GetActiveMenu() != file.menu )
		AdvanceMenu( GetMenu( "PackInfoDialog" ) )
}

