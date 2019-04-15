params ["_dbName", ["_loadOnJoin", true], ["_saveOnQuit", false], ["_addForceSave", false]];

if (isNil {_dbName}) exitWith {diag_log "cupinv error: no db name defined";};

if (isServer) then {[_dbName, _saveOnQuit] call compile preprocessfilelinenumbers "cupinv\serverInit.sqf";};

if (hasInterface) then {[_loadOnJoin, _addForceSave] call compile preprocessfilelinenumbers "cupinv\playerInit.sqf";};