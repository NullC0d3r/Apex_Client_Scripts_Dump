globalize_all_functions

float function RTKMutator_Add( float input, float x )
{
	return input + x
}

float function RTKMutator_Subtract( float input, float x )
{
	return input - x
}

float function RTKMutator_Multiply( float input, float x )
{
	return input * x
}

vector function RTKMutator_MultiplyByVector( float input, vector x )
{
	return input * x
}

float function RTKMutator_Divide( float input, float x )
{
	if	( x == 0 )
		return 0
	return input / x
}

float function RTKMutator_Modulo( float input, float x )
{
	return input % x
}

float function RTKMutator_Abs( float input )
{
	return fabs( input )
}

float function RTKMutator_Lerp( float input, float a, float b )
{
	return a + ( ( b - a ) * input )
}

float function RTKMutator_Clamp( float input, float a, float b )
{
	return clamp( input, a, b )
}

float function RTKMutator_Clamp01( float input )
{
	return clamp( input, 0.0, 1.0 )
}

vector function RTKMutator_AddVectors( vector input, vector x )
{
	return input + x
}

vector function RTKMutator_SubtractVectors( vector input, vector x )
{
	return input - x
}

vector function RTKMutator_ScaleVector( vector input, float x )
{
	return input * x
}

vector function RTKMutator_LerpVector( float input, vector a, vector b )
{
	return a + ( ( b - a ) * input )
}

vector function RTKMutator_ClampVector( vector input, vector a, vector b )
{
	return < clamp( input.x, a.x, b.x ), clamp( input.y, a.y, b.y ), clamp( input.z, a.z, b.z ) >
}

int function RTKMutator_FloatToInt( float input )
{
	return int( input );
}

vector function RTKMutator_PickVectorFromTwo( int input, vector option0, vector option1 )
{
	return input == 1 ? option1 : option0
}

float function RTKMutator_PickFloatFromTwo( int input, float option0, float option1 )
{
	return input == 1 ? option1 : option0
}
