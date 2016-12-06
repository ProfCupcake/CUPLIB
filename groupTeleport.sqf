/*
Group teleport script. 
Will teleport a unit to the given position, then teleport the rest of their group to a position relative to them. 

input: Array:
	0 - Unit to be teleported
	1 - Position to be teleported to (3D)
	2 - Maximum distance (m) to teleport group members - Optional, default 25.
		Anyone beyond this distance will not be teleported with the others.

output: nothing

[unit, position, <distance>] execVM "groupTeleport.sqf";

by Professor Cupcake
*/

_unit = _this select 0;
_pos = _this select 1;
if (size _this < 3) then {_dist = 25;} else {_dist = _this select 2;};

//Generate array of displacements
//Format: [[unit, disp], [unit, disp],...]
//Ignores z-coord
_dispArray = [];
{
	if (_unit distance _x < _dist) then
	{
		_displacement = position _unit vectorDiff position _x;
		_displacement set [2, 0]; //Set z to 0
		_dispArray pushBack [_x, _displacement]
	};
} foreach units _unit;

{
	(_x select 0) setPos (_pos vectorAdd (_x select 1));
} foreach _dispArray;