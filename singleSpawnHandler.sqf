// I wouldn't use this yet. 

// Also it may get super-reworked soon, as I've realised there are probably better ways to do this

// (there are definitely better ways to do this)

params ["_startMarker", "_holdMarker", ["_startDesc", "Start Position"], ["_holdDesc", "Holding Area"]];

if (isNil{CUP_homeBaseSpawn}) then
{
	waitUntil {player == player};
	_startMarker setPos getPos player; 
	_startMarker setDir getDir player;
	CUP_homeBaseSpawn = [player, _startMarker, _startDesc] call BIS_fnc_addRespawnPosition;
	CUP_homeBaseSingleSpawnEH = player addEventHandler ["Respawn", 
	{
		0 spawn
		{
			sleep 1;
			[player, 0] call BIS_fnc_removeRespawnPosition;
			CUP_seaPlatformSpawn = [player, _holdMarker, _holdDesc] call BIS_fnc_addRespawnPosition;
			player removeEventHandler ["Respawn", CUP_homeBaseSingleSpawnEH];
		};
	}];
};