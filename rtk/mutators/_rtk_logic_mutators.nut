globalize_all_functions


bool function RTKMutator_Not( bool input )
{
	return !input
}

bool function RTKMutator_Equal( float input, float other )
{
	return fabs( input - other ) < FLT_EPSILON
}

bool function RTKMutator_NotEqual( float input, float other )
{
	return !RTKMutator_Equal( input, other )
}

bool function RTKMutator_GreaterThan( float input, float other )
{
	return input > other
}

bool function RTKMutator_GreaterThanOrEqual( float input, float other )
{
	return input >= other
}

bool function RTKMutator_LessThan( float input, float other )
{
	return input < other
}

bool function RTKMutator_LessThanOrEqual( float input, float other )
{
	return input <= other
}

bool function RTKMutator_InRangeExclusive( float input, float lowerBound, float upperBound )
{
	float realMin = min( lowerBound, upperBound )
	float realMax = max( lowerBound, upperBound )
	return input > realMin && input < realMax
}

bool function RTKMutator_InRangeInclusive( float input, float lowerBound, float upperBound )
{
	float realMin = min( lowerBound, upperBound )
	float realMax = max( lowerBound, upperBound )
	return input >= realMin && input <= realMax
}
