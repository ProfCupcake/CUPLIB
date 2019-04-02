params ["_loadOnJoin"];

waitUntil {player == player};

saveRequest = player;
invRequest = player;
player addEventHandler ["Respawn", {saveRequest = player; invRequest = player;}];

if (_loadOnJoin) then
{
	if (isNil {serverReady}) then {serverReady = false};
	waitUntil {serverReady};
	publicVariableServer invRequest;
};