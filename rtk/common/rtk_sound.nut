global function RTKSound_OnUpdate

global struct RTKSound_Properties
{
	string sound = ""
	bool play = false
	float delay = 0
}

struct PrivateData
{
	bool hasPlayed = false
}

void function RTKSound_OnUpdate( rtk_behavior self, float dt )
{
	PrivateData p
	self.Private( p )

	string sound = self.PropGetString( "sound" )
	bool play = self.PropGetBool( "play" )
	float delay = self.PropGetFloat( "delay" )

	if( !play )
		p.hasPlayed = false

	if( sound != "" && play && !p.hasPlayed )
	{
		p.hasPlayed = true
		thread RTKSound_PlayThread(self, sound, delay)
	}
}

void function RTKSound_PlayThread( rtk_behavior self, string sound, float delay )
{
	wait( delay )

	if (self.GetPanel().IsActiveSelf())
		EmitUISound( sound )
}