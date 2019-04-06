/**
Script designed for very specific circumstances...
Will allow players to spawn in your normal start position for first spawn, then delete that spawn and set it to a second spawn. 
The intention is that the second spawn is in a holding area or other such place that you want players to spawn at, but not start in. 
This is necessary due to how the "select respawn position" option works (you start dead, then spawn in). 

--- IF YOU ARE NOT USING "SELECT RESPAWN POSITION", THIS SCRIPT IS UNNECESSARY ---

Input: Array:
	0 - Object. The start marker. MUST be a Game Logic object. Position doesn't matter. 
	1 - Object. The respawn marker (the "second spawn"). MUST be a Game Logic object. Position matters - this marks the second spawn location. 
	2 - String. Name of the start position. Optional, defaults to "Start Position". 
	3 - String. Name of the respawn. Optional, defaults to "Holding Area". 

Output: none.

Example call:

[startMarker, holdMarker, "Start Position", "Holding Area"] call compile preprocessfilelinenumbers "singleSpawnHandler.sqf";

by Professor Cupcake
**/

params ["_startMarker", "_holdMarker", ["_startDesc", "Start Position"], ["_holdDesc", "Holding Area"]];

CUP_holdMarker = _holdMarker;
CUP_holdDesc = _holdDesc;

if (isNil{CUP_holdingAreaSpawn}) then
{
	waitUntil {player == player};
	_startMarker setPos getPos player; 
	_startMarker setDir getDir player;
	CUP_homeBaseSpawn = [player, _startMarker, _startDesc] call BIS_fnc_addRespawnPosition;
	CUP_homeBaseSingleSpawnEH = player addEventHandler ["Respawn", 
	{
		0 spawn
		{
			params ["_holdMarker", "_holdDesc"];
			sleep 1;
			CUP_homeBaseSpawn call BIS_fnc_removeRespawnPosition;
			CUP_holdingAreaSpawn = [player, CUP_holdMarker, CUP_holdDesc] call BIS_fnc_addRespawnPosition;
			player removeEventHandler ["Respawn", CUP_homeBaseSingleSpawnEH];
		};
	}];
};
