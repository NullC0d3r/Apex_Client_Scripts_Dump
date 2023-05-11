global function InitPostGameWeaponTrialCelebrationsMenu
global function OpenPostGameWeaponTrialCelebrationsMenu
global function ClosePostGameWeaponTrialCelebrationsMenu

struct
{
	var menu

	bool buttonsRegistered = false                                                                                                                            
} file

void function InitPostGameWeaponTrialCelebrationsMenu( var menu )
{
	RegisterSignal( "EndPostGameWeaponTrialCelebrations" )

	file.menu = menu

	SetGamepadCursorEnabled( menu, false )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, PostGameWeaponTrialCelebrationsMenu_OnOpen )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, PostGameWeaponTrialCelebrationsMenu_OnClose )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, PostGameWeaponTrialCelebrationsMenu_OnNavigateBack )
}

void function PostGameWeaponTrialCelebrationsMenu_OnOpen()
{
	UI_SetPresentationType( ePresentationType.WEAPON_TRIAL_CELEBRATIONS )

	if ( !file.buttonsRegistered )
	{
		RegisterButtonPressedCallback( BUTTON_A, ClosePostGameWeaponTrialCelebrationsMenu )
		RegisterButtonPressedCallback( KEY_SPACE, ClosePostGameWeaponTrialCelebrationsMenu )
		file.buttonsRegistered = true
	}
}

void function PostGameWeaponTrialCelebrationsMenu_OnClose()
{
	if ( file.buttonsRegistered )
	{
		DeregisterButtonPressedCallback( BUTTON_A, ClosePostGameWeaponTrialCelebrationsMenu )
		DeregisterButtonPressedCallback( KEY_SPACE, ClosePostGameWeaponTrialCelebrationsMenu )
		file.buttonsRegistered = false
	}
}

void function PostGameWeaponTrialCelebrationsMenu_OnNavigateBack()
{
	ClosePostGameWeaponTrialCelebrationsMenu( null )
}

void function OpenPostGameWeaponTrialCelebrationsMenu()
{
	AdvanceMenu( file.menu )
}

void function ClosePostGameWeaponTrialCelebrationsMenu( var unused )
{
	if ( GetActiveMenu() == file.menu )
		CloseActiveMenu()
}
