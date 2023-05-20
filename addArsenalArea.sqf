/*
Adds an Arsenal area. 
That is, a circular zone around an object in which the Virtual Arsenal can be accessed. 
The action is attached to the player, not an object. 
This means that players can access the arsenal without having to look down at an ammobox or whatever.
It does still need an object to be the centre of the area. 

Input: Array:
	0 - The arsenal object
	1 - The maximum distance from the object for the Arsenal to be accessible

Output: nothing

[object, distance] execVM "addArsenalArea.sqf";

It is recommended to apply this script in initPlayerLocal.sqf

by Professor Cupcake
*/

params ["_box", "_dist"];

if (isNil "CUPARS_arsenalAreas") then
{
	CUPARS_arsenalAreas = [[_box, _dist]];
	if !(isNil "ace_arsenal_fnc_openBox") then
	{
		CUPARS_aceArsenalActionParams = ["ACE Arsenal", {[player, player, true] spawn ace_arsenal_fnc_openBox;}, nil, 1.5, true, true, "", "call CUPARS_checkArsenalDistance"];
		CUPARS_aceArsenalAction = player addAction CUPARS_aceArsenalActionParams;
		player addEventHandler ["Killed", {player removeAction CUPARS_aceArsenalAction;}];
		player addEventHandler ["Respawn", {CUPARS_aceArsenalAction = player addAction CUPARS_aceArsenalActionParams;}];
	};

	CUPARS_arsenalActionParams = ["Virtual Arsenal", {["Open",true] spawn BIS_fnc_arsenal},nil,1.5,true,true,"","call CUPARS_checkArsenalDistance"];
	CUPARS_arsenalAction = player addAction CUPARS_arsenalActionParams;
	player addEventHandler ["Killed", {player removeAction CUPARS_arsenalAction;}];
	player addEventHandler ["Respawn", {CUPARS_arsenalAction = player addAction CUPARS_arsenalActionParams;}];
	
	CUPARS_checkArsenalDistance = 
	{
		_return = false;
		{
			_x params ["_box", "_dist"];
			if (player distance _box <= _dist) exitWith {_return = true;};
		} foreach CUPARS_arsenalAreas;
		_return
	};
} else
{
	CUPARS_arsenalAreas pushBack [_box, _dist];
};