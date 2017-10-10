/**
Tests if a unit's currently selected weapon is suppressed. 
Uses manually compiled lists to check. 
Currently supports vanilla and RHS. 
Only works on infantry - all other units will return false. 

Input: unit - the unit whose weapon is to be checked

Output: boolean - true if suppressed, false otherwise

suppressed = unit call compile preprocessfilelinenumbers "isWeaponSuppressed.sqf";

by Professor Cupcake
**/

if !(_this isKindOf "Man") exitWith {false};

if (currentMuzzle _this != currentWeapon _this) exitWith {false}; //If alternate muzzle (e.g. grenade launcher, the Type-115's underslung .50), assume it's not suppressed

_primaryWeapons = [
	"srifle_DMR_04_F",
	"srifle_DMR_04_Tan_F",
	"rhs_weap_vss",
	"rhs_weap_vss_grip",
	"rhs_weap_vss_grip_npz",
	"rhs_weap_vss_npz",
	"rhs_weap_asval",
	"rhs_weap_asval_grip",
	"rhs_weap_asval_grip_npz",
	"rhs_weap_asval_npz"
];

_primaryAttachments = [
	"rhs_acc_dtk4long",
	"rhs_acc_dtk4short",
	"rhs_acc_dtk4screws",
	"rhs_acc_pbs1",
	"rhs_acc_pbs4",
	"rhs_acc_tgpa",
	"rhsusf_acc_nt4_black",
	"rhsusf_acc_nt4_tan",
	"rhsusf_acc_rotex5_grey",
	"rhsusf_acc_rotex5_tan",
	"rhsusf_acc_M2010S",
	"rhsusf_acc_M2010S_d",
	"rhsusf_acc_M2010S_sa",
	"rhsusf_acc_M2010S_wd",
	"rhsusf_acc_SR25S",
	"rhsgref_sdn6_suppressor",
	"rhsusf_acc_rotex_mp7_aor1",
	"rhsusf_acc_rotex_mp7",
	"rhsusf_acc_rotex_mp7_desert",
	"rhsusf_acc_rotex_mp7_winter",
	"rhs_acc_tgpv",
	"rhs_acc_tgpv2"
];

_handguns = [
];

_handgunAttachments = [
	"rhs_acc_6p9_suppressor",
	"rhsusf_acc_omega9k"
];

_return = false;

if (currentWeapon _this == primaryWeapon _this) then
{
	if (primaryWeapon _this in _primaryWeapons) then
	{
		_return = true;
	} else
	{
		{
			// All vanilla suppressors begin with "muzzle_snds_", so we can just test for that
			if (_x select [0,12] == "muzzle_snds_") exitWith {_return = true;};
			if (_x in _primaryAttachments) exitWith {_return = true;};
		} foreach (primaryWeaponItems _this);
	};
};

if (currentWeapon _this == handgunWeapon _this) then
{
	if (handgunWeapon _this in _handguns) then
	{
		_return = true;
	} else
	{
		{
			// All vanilla suppressors begin with "muzzle_snds_", so we can just test for that
			if (_x select [0,12] == "muzzle_snds_") exitWith {_return = true;};
			if (_x in _handgunAttachments) exitWith {_return = true;};
		} foreach (handgunItems _this);
	};
};

_return
