global function RTKPostGameWeaponTrialCelebrations_OnInitialize
global function RTKPostGameWeaponTrialCelebrations_OnDestroy
#if DEV
global function DEV_TestWeaponTrialCelebrationSounds
#endif       

global struct RTKPostGameWeaponTrialCelebrations_Properties
{
	rtk_behavior animator
	rtk_panel trialsList
	rtk_behavior trialsTweenStagger
}

global struct RTKWeaponTrialCelebrationRuiArgs
{
	asset  weaponIcon
	string weaponName
	string weaponLevel
	float  startTime
}

struct PrivateData
{
	int                                              menuGUID = -1
	var                                              postGameWeaponTrialCelebrationsModel
	array<MasteryWeapon_TrialStatusChangesPerWeapon> weaponTrialStatusChanges
	int                                              lastProcessedTrialIndex = -1
}

void function RTKPostGameWeaponTrialCelebrations_OnInitialize( rtk_behavior self )
{
	PrivateData p
	self.Private( p )

	p.postGameWeaponTrialCelebrationsModel = RTKDataModelType_CreateStruct( RTK_MODELTYPE_MENUS, "postGameWeaponTrialCelebrations" )
	var weaponModel  = RTKStruct_GetOrCreateEmptyStruct( p.postGameWeaponTrialCelebrationsModel, "weapon" )
	var ruiArgsModel = RTKStruct_AddStructProperty( weaponModel, "ruiArgs", "RTKWeaponTrialCelebrationRuiArgs" )
	var trialsModel  = RTKStruct_AddArrayOfStructsProperty( p.postGameWeaponTrialCelebrationsModel, "trials", "MasteryWeapon_TrialQueryResult" )

	self.GetPanel().SetBindingRootPath( "&menus.postGameWeaponTrialCelebrations" )

	RTKPostGameWeaponTrialCelebrations_PresentCelebrations( self )

	int menuGUID = AssignMenuGUID()
	p.menuGUID = menuGUID
	                                                                                                                                               
	RTKFooters_Add( menuGUID, CENTER, BUTTON_INVALID, "#A_BUTTON_CONTINUE", BUTTON_INVALID, "#A_BUTTON_CONTINUE", ClosePostGameWeaponTrialCelebrationsMenu )
	RTKFooters_Update()
}

void function RTKPostGameWeaponTrialCelebrations_PresentCelebrations( rtk_behavior self )
{
	rtk_behavior animator = self.PropGetBehavior( "animator" )
	string bgAnim         = "EnterScene"
	if ( RTKAnimator_HasAnimation( animator, bgAnim ) )
		RTKAnimator_PlayAnimation( animator, bgAnim )

	thread PresentCelebrationsThread( self )
}

void function PresentCelebrationsThread( rtk_behavior self )
{
	EndSignal( uiGlobal.signalDummy, "EndPostGameWeaponTrialCelebrations" )

	PrivateData p
	self.Private( p )

	p.weaponTrialStatusChanges        = Mastery_GetWeaponTrialStatusChanges()                                              
	rtk_behavior tweenStaggerBehavior = self.PropGetBehavior( "trialsTweenStagger" )
	Assert( tweenStaggerBehavior != null )

	foreach ( entry in p.weaponTrialStatusChanges )
	{
		array<MasteryWeapon_TrialQueryResult> trialList
		int numTrialsToProcess = 0

		foreach ( trialStatusChange in entry.trialStatusChangeList )
		{
			trialList.append( trialStatusChange.state1 )

			if ( trialStatusChange.statusChange != eWeaponTrialStatusChangeType.NONE )
				numTrialsToProcess++
		}

		var trialsModel = RTKStruct_GetArray( p.postGameWeaponTrialCelebrationsModel, "trials" )
		RTKArray_SetValue( trialsModel, trialList )
		                                                                        
		rtk_panel trialsListPanel = self.PropGetPanel( "trialsList" )
		while ( trialsListPanel.GetChildren().len() <= 0 )
			WaitFrame()

		array<rtk_panel> trialPanels = trialsListPanel.GetChildren()
		array<rtk_behavior> trialRenderGroups

		foreach ( trialIndex, trialStatusChange in entry.trialStatusChangeList )
		{
			rtk_behavior renderGroup = trialPanels[trialIndex].FindBehaviorByTypeName( "RenderGroup" )
			renderGroup.SetActive( trialStatusChange.state1.trialData.isUnlocked == false )
			trialRenderGroups.append( renderGroup )
		}

		RTKPostGameWeaponTrialCelebrations_InitWeaponTrialData( self, entry )

		foreach ( trialIndex, trialStatusChange in entry.trialStatusChangeList )
		{
			if ( trialStatusChange.statusChange == eWeaponTrialStatusChangeType.NONE )
				continue

			if ( p.lastProcessedTrialIndex == -1 )
			{
				trialsListPanel.SetPositionX( GetTrialsListXPositionForTrial( trialIndex ) )

				                            
				tweenStaggerBehavior.SetActive( false )
				tweenStaggerBehavior.SetActive( true )
				EmitUISound( "UI_Menu_WeaponMastery_CardBottomSlide" )
				wait 2.2668                                
			}
			else
			{
				CenterTrial( self, trialIndex )
				wait 0.3337                                   
				trialRenderGroups[trialIndex].SetActive( false )
			}

			wait 0.4                                      
			AnimateTrialStatusChange( trialPanels[trialIndex], trialStatusChange.statusChange )
			RTKArray_SetValueAt( trialsModel, trialIndex, trialStatusChange.state2 )

			p.lastProcessedTrialIndex = trialIndex
			numTrialsToProcess--
			if ( numTrialsToProcess > 0 )
				wait 2                                                                            
		}

		wait 3

		p.lastProcessedTrialIndex = -1
	}
}

void function CenterTrial( rtk_behavior self, int trialIndex )
{
	Assert( trialIndex >= 0 )

	PrivateData p
	self.Private( p )

	rtk_behavior animator = self.PropGetBehavior( "animator" )
	var animations        = animator.PropGetArray( "tweenAnimations" )
	string animationName  = "CenterTrial"
	var centerTrialAnim   = null

	for ( int i = 0; i < RTKArray_GetCount( animations ); i++ )
	{
		var animation = RTKArray_GetStruct( animations, i )

		if ( RTKStruct_GetString( animation, "name" ) == animationName )
		{
			centerTrialAnim = animation
			break
		}
	}

	if ( centerTrialAnim != null )
	{
		var tweens                  = RTKStruct_GetArray( centerTrialAnim, "tweens" )
		var tween                   = RTKArray_GetStruct( tweens, 0 )
		int trialIndexForStartValue = p.lastProcessedTrialIndex == -1 ? trialIndex : p.lastProcessedTrialIndex

		RTKStruct_SetFloat( tween, "startValue", GetTrialsListXPositionForTrial( trialIndexForStartValue ) )
		RTKStruct_SetFloat( tween, "endValue", GetTrialsListXPositionForTrial( trialIndex ) )

		RTKAnimator_PlayAnimation( animator, animationName )
		EmitUISound( "UI_Menu_WeaponMastery_CardSlide" )
	}
}

float function GetTrialsListXPositionForTrial( int trialIndex )
{
	                                                                                          
	float defaultPosition = -230.0
	float singleOffset = 500.0
	float position = defaultPosition - ( singleOffset * trialIndex )

	return position
}

void function AnimateTrialStatusChange( rtk_panel trialPanel, int statusChangeType )
{
	Assert( statusChangeType == eWeaponTrialStatusChangeType.UNLOCKED || statusChangeType == eWeaponTrialStatusChangeType.COMPLETED )

	rtk_behavior animator = trialPanel.FindBehaviorByTypeName( "Animator" )
	string animationName  = statusChangeType == eWeaponTrialStatusChangeType.UNLOCKED ? "Unlock" : "Complete"
	string soundName      = statusChangeType == eWeaponTrialStatusChangeType.UNLOCKED ? "UI_Menu_WeaponMastery_Trial_Unlocked" : "UI_Menu_WeaponMastery_Trial_Complete"

	RTKAnimator_PlayAnimation( animator, animationName )
	EmitUISound( soundName )
}

void function RTKPostGameWeaponTrialCelebrations_InitWeaponTrialData( rtk_behavior self, MasteryWeapon_TrialStatusChangesPerWeapon weaponTrialsData )
{
	PrivateData p
	self.Private( p )

	ItemFlavor weaponItem = weaponTrialsData.weapon
	int weaponLevel = Mastery_GetWeaponLevel( weaponItem )

	                                                                                                                                
	                                                                               
	RTKWeaponTrialCelebrationRuiArgs ruiArgs
	ruiArgs.weaponIcon  = WeaponItemFlavor_GetHudIcon( weaponItem )
	ruiArgs.weaponName  = Localize( ItemFlavor_GetShortName( weaponItem ) ).toupper()
	ruiArgs.weaponLevel = Localize( "#HUD_LEVEL_N", weaponLevel ).toupper()
	ruiArgs.startTime   = ClientTime()

	var weaponModel = RTKStruct_GetStruct( p.postGameWeaponTrialCelebrationsModel, "weapon" )
	var ruiArgsModel = RTKStruct_GetStruct( weaponModel, "ruiArgs" )
	RTKStruct_SetValue( ruiArgsModel, ruiArgs )

	EmitUISound( weaponLevel <= 80 ? "UI_Menu_WeaponMastery_LevelUp_Generic" : "UI_Menu_WeaponMastery_LevelUp_100" )

	                                                 
	                                                                         
	  	                                            
	  
	                                                                                          
	                                             
}

void function RTKPostGameWeaponTrialCelebrations_OnDestroy( rtk_behavior self )
{
	Signal( uiGlobal.signalDummy, "EndPostGameWeaponTrialCelebrations" )

	PrivateData p
	self.Private( p )

	RTKDataModelType_DestroyStruct( RTK_MODELTYPE_MENUS, "postGameWeaponTrialCelebrations" )

	RTKFooters_RemoveAll( p.menuGUID )
	RTKFooters_Update()
}

#if DEV
void function DEV_TestWeaponTrialCelebrationSounds( int weaponLevel )
{
	thread DEV_TestWeaponTrialCelebrationSoundsThread( weaponLevel )
}

void function DEV_TestWeaponTrialCelebrationSoundsThread( int weaponLevel )
{
	string levelUpSound = weaponLevel != 100 ? "UI_Menu_WeaponMastery_LevelUp_Generic" : "UI_Menu_WeaponMastery_LevelUp_100"
	string completeSound = "UI_Menu_WeaponMastery_Trial_Complete"
	string unlockedSound = "UI_Menu_WeaponMastery_Trial_Unlocked"
	string slideSound = "UI_Menu_WeaponMastery_CardSlide"

	printt( "Playing:", levelUpSound )
	EmitUISound( levelUpSound )

	wait 2.903
	printt( "Playing:", completeSound )
	EmitUISound( completeSound )

	wait 0.7006
	printt( "Playing:", slideSound )
	EmitUISound( slideSound )

	wait 0.9009
	printt( "Playing:", unlockedSound )
	EmitUISound( unlockedSound )
}
#endif       