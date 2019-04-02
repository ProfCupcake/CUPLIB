params ["_loadOnJoin", "_addForceSave"];

waitUntil {player == player};

saveRequest = player;
invRequest = player;
player addEventHandler ["Respawn", {saveRequest = player; invRequest = player;}];

if (_loadOnJoin) then
{
	if (isNil {serverReady}) then {serverReady = false};
	waitUntil {serverReady};
	if (alive player) then {publicVariableServer "invRequest";} else
	{
		spawnInvRequestHandler = player addEventHandler ["Respawn", {publicVariableServer "invRequest"; player removeEventHandler ["Respawn", spawnInvRequestHandler];}];
	};
};

if (_addForceSave) then
{
	forceSaveActionParams = ["<t color='#FF0000'>[ADMIN] Force save all loadouts</t>", {publicVariableServer "forceSave";}, nil, -1, false, true, "", "serverCommandAvailable '#kick'"];
	forceSaveAction = player addAction forceSaveActionParams;
	player addEventHandler ["Respawn", {_this select 1 removeAction forceSaveAction; forceSaveAction = player addAction forceSaveActionParams;}];
};