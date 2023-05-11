global function RTKWeaponMasteryLevel_OnInitialize


void function RTKWeaponMasteryLevel_OnInitialize( rtk_behavior self )
{
	bool enableWeaponMastery =  Mastery_IsEnabled()
	if( enableWeaponMastery )
		self.GetPanel().SetBindingRootPath( RTKDataModelType_GetDataPath( RTK_MODELTYPE_COMMON, "overall", true, [ "weapons", "mastery" ] ) )
	else
		self.GetPanel().SetBindingRootPath( "" )
}