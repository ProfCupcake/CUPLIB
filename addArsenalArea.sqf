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

_box = _this select 0;
_dist = _this select 1;

_checkArsenalDistance = 
{
	_return = false;
	if (player distance _box <= _dist) then {_return = true;};
	_return
};

_arsenalActionParams = ["Virtual Arsenal", {["Open",true] spawn BIS_fnc_arsenal},nil,1.5,true,true,"","call _checkArsenalDistance"];
_arsenalAction = player addAction _arsenalActionParams;
player addEventHandler ["Killed", {player removeAction _arsenalAction;}];
player addEventHandler ["Respawn", {_arsenalAction = player addAction _arsenalActionParams;}];

if !(isNil "ace_arsenal_fnc_openBox") then
{
	_aceArsenalActionParams = ["ACE Arsenal", {[player, player, true] spawn ace_arsenal_fnc_openBox;}, nil, 1.5, true, true, "", "call _checkArsenalDistance"];
	_aceArsenalAction = player addAction _aceArsenalActionParams;
	player addEventHandler ["Killed", {player removeAction _aceArsenalAction;}];
	player addEventHandler ["Respawn", {_aceArsenalAction = player addAction _aceArsenalActionParams;}];
};