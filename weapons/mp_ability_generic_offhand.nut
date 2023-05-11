global function MpGenericOffhand_Init
global function OnWeaponAttemptOffhandSwitch_GenericOffhand
global function GenericOffhand_AddSunglasses

#if CLIENT
global function Thread_GenericOffhand_PlaySunglassesVFX
#endif


global const string GENERIC_OFFHAND_WEAPON_NAME = "mp_ability_generic_offhand"
global const int GENERIC_OFFHAND_INDEX = 7
const asset SUNGLASSES_FX_ASSET    = $"P_heatwave_glasses_puton_1p"

global const float SUNGLASSES_FX_STARTUP = 0.90
global const float SUNGLASSES_FX_DURATION = 1


global function ActivateGenericOffhand

struct
{
	int sunglassesFXHandle
} file

void function MpGenericOffhand_Init()
{
	PrecacheWeapon( GENERIC_OFFHAND_WEAPON_NAME )
	PrecacheParticleSystem( SUNGLASSES_FX_ASSET )
}

bool function OnWeaponAttemptOffhandSwitch_GenericOffhand( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return false

	array <entity> activeWeapons = player.GetAllActiveWeapons()
	if ( activeWeapons.len() > 1 )
	{
		entity offhandWeapon = activeWeapons[1]

		if ( IsValid( offhandWeapon ) )
		{
			return false
		}
	}
	return true
}

void function ActivateGenericOffhand( entity player)
{
	entity weapon = player.GetOffhandWeapon( GENERIC_OFFHAND_INDEX )

	if ( !IsValid( weapon ) )
		return

	if ( weapon.GetWeaponClassName() != GENERIC_OFFHAND_WEAPON_NAME )
		return

                         
	if (!IsHeatwaveMode())
	{
		                                             
		weapon.RemoveMod( "sunglasses" )
	}
      

	thread __ActivateGenericOffhand( player )
}

void function __ActivateGenericOffhand( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.TrySelectOffhand( GENERIC_OFFHAND_INDEX )
#if CLIENT
                         
	if (IsHeatwaveMode())
		thread Thread_GenericOffhand_PlaySunglassesVFX(player)
                                   
#endif
}

void function GenericOffhand_AddSunglasses (entity player)
{
	entity weapon = player.GetOffhandWeapon( GENERIC_OFFHAND_INDEX )
	weapon.AddMod( "sunglasses" )
}

#if CLIENT
void function Thread_GenericOffhand_PlaySunglassesVFX (entity player)
{
		int damageFxID    = GetParticleSystemIndex( SUNGLASSES_FX_ASSET )
		entity cockpit = player.GetCockpit()
		wait(SUNGLASSES_FX_STARTUP)
		file.sunglassesFXHandle = StartParticleEffectOnEntity( cockpit, damageFxID , FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
		wait(SUNGLASSES_FX_DURATION)
		EffectStop(file.sunglassesFXHandle, false, true )
}
#endif

#if CLIENT
void function ColorCorrection_LerpWeight( int colorCorrection, float startWeight, float endWeight, float lerpTime = 0 )
{
	float startTime = Time()
	float endTime = startTime + lerpTime
	ColorCorrection_SetExclusive( colorCorrection, true )

	while ( Time() <= endTime )
	{
		WaitFrame()
		float weight = GraphCapped( Time(), startTime, endTime, startWeight, endWeight )
		ColorCorrection_SetWeight( colorCorrection, weight )
	}

	ColorCorrection_SetWeight( colorCorrection, endWeight )
}
#endif         