                         
global function ClientCodeCallback_ProjectileCollision

const float NO_HIT_NPC_TIMEOUT = 2
const float POST_SHOOT_NPC_MAKE_HITS_MISSES_DURATION = 0.5

struct{
	entity playerTarget = null
	float playerNPCLastHitTime = 0
	array< entity > projectileSetHitmarkerWithPassthrough
} file

void function PassthroughProjectile_Thread( entity projectile )
{
	EndSignal( projectile, "OnDestroy" )

	OnThreadEnd(
		function() : ( projectile )
		{
			if ( file.projectileSetHitmarkerWithPassthrough.contains( projectile ) )
				file.projectileSetHitmarkerWithPassthrough.removebyvalue( projectile )
		}
	)

	WaitForever()
}

void function ClientCodeCallback_ProjectileCollision( entity projectile, vector pos, entity hitEnt, int hitbox, bool isPassthrough )
{
	if ( !IsValid( hitEnt ) )
		return

	bool isMiss = (hitbox == HITBOXINDEX_INVALID)
	bool isCritical = false
	if ( !isMiss && hitEnt.IsAnimatingEnt() )
		isCritical = (hitEnt.GetHitGroupOfHitBox( hitbox ) == HITGROUP_HEAD)

	entity player = projectile.GetOwner()

	if ( hitEnt.GetScriptName() == FIRING_RANGE_TARGET_FLIP_SCRIPTNAME && IsValid( player ) && player.IsPlayer() && player == GetLocalViewPlayer() )
		EmitSoundOnEntity( hitEnt, "Canyonlands_Scr_RangeTarget_Hit_1P" )

	if ( file.projectileSetHitmarkerWithPassthrough.contains( projectile ) )
	{
		                                                                                                                                                                                                                            
		return
	}

	if ( isPassthrough )
	{
		if ( !file.projectileSetHitmarkerWithPassthrough.contains( projectile ) )
			file.projectileSetHitmarkerWithPassthrough.append( projectile )

		thread PassthroughProjectile_Thread( projectile )
	}

	                  
	if ( ShouldShowTrainingHitIndicators() && !hitEnt.IsPlayer() )
	{
		                                       
		if ( player != GetLocalViewPlayer() )
			return

		if ( !isMiss )
		{
			if ( hitEnt.IsNPC() )
			{
				file.playerTarget = hitEnt
				file.playerNPCLastHitTime = Time()
			}
			else
			{
				if ( (file.playerNPCLastHitTime + POST_SHOOT_NPC_MAKE_HITS_MISSES_DURATION) >= Time() )
				{
					isMiss = true
				}
				else
				{
					file.playerTarget = null
				}
			}
		}

		if( isMiss )
		{
			if ( IsValid(file.playerTarget) && ( (file.playerNPCLastHitTime + NO_HIT_NPC_TIMEOUT) >= Time() ) )
			{
				hitEnt = file.playerTarget

				vector targetPos = hitEnt.GetOrigin()
				vector playerEyes = player.EyePosition()
				vector eyesToHitPosNormalized = Normalize(pos - playerEyes)
				float distToTarget = Distance(playerEyes, targetPos)
				pos = eyesToHitPosNormalized * distToTarget + playerEyes
			}
		}
		var hitDotRui = RuiCreate( $"ui/training_target_hit_dot.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0 )
		RuiSetResolutionToScreenSize( hitDotRui )
		RuiSetGameTime( hitDotRui, "startTime", Time() )
		RuiSetFloat3( hitDotRui, "pos", pos )
		RuiSetBool ( hitDotRui, "drawInWorldSpace", true )
		RuiSetBool( hitDotRui, "isCrit", isCritical )
		RuiSetBool( hitDotRui, "isMiss", isMiss )

		if ( GetCurrentPlaylistVarBool( "firing_range_hitmarker_pos_update_enabled", true ) )
		{
			thread UpdateHitMarkerPos( hitDotRui, pos, hitEnt )
		}
	}
}

void function UpdateHitMarkerPos( var rui, vector damagePos, entity target )
{
	EndSignal( target, "OnDeath", "OnDestroy" )
	vector offset = damagePos - target.GetOrigin()

	                                                                                                                      
	float endTime = Time() + 3.485
	while ( Time() < endTime )
	{
		                                                                            
		RuiSetFloat3( rui, "pos", offset + target.GetOrigin() )
		WaitFrame()
	}
}
      
