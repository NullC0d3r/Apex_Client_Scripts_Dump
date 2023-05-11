globalize_all_functions

asset function RTKMutator_PickAssetFromTwo( int input, asset option0, asset option1 )
{
	return input == 1 ? option1 : option0
}