params ["_dbName", "_saveOnQuit"];

invDB = ["new", _dbName] call OO_INIDBI;

if (isNil {invDB}) exitWith
{
	"invDB initialisation failed" remoteExec ["hint"];
};

invExport = compile preprocessfilelinenumbers "cupinv\invExport.sqf";

invRequestHandler = 
{
	_player = _this select 1;
	_invSend = ["read", [getPlayerUID _player, "inv", ""]] call invDB;
	if (_invSend == "") exitWith {"Inventory load failed." remoteExec ["hint", owner _player];};
	if (count _invSend > 2732) then
	{
		_invSendArray = [_invSend, 2732] call compile preprocessfilelinenumbers "cupinv\splitLongString.sqf";
		_invSend = "";
		{
			_newPart = ["decodeBase64", _x] call invDB;
			_invSend = _invSend + _newPart;
		} foreach _invSendArray;
	} else
	{
		_invSend = ["decodeBase64", _invSend] call invDB;
	};
	_invSend = compile _invSend;
	_invSend remoteExec ["call", owner _player];
	"Inventory loaded." remoteExec ["hint", owner _player];
};
"invRequest" addPublicVariableEventHandler invRequestHandler;

saveRequestHandler = 
{
	_player = _this select 1; //Get player from publicVariable call
	_invSave = [_player, "script", false] call invExport;
	if (count _invSave > 2048) then //Handle oversized loadout string
	{
		_invSaveArray = [_invSave, 2048] call compile preprocessfilelinenumbers "cupinv\splitLongString.sqf";
		_invSave = "";
		{
			_newPart = ["encodeBase64", _x] call invDB;
			_invSave = _invSave + _newPart;
		} foreach _invSaveArray;
	} else
	{
		_invSave = ["encodeBase64", _invSave] call invDB;
	};
	_saveSuccess = ["write", [getPlayerUID _player, "inv", _invSave]] call invDB;
	if (_saveSuccess) then {"Inventory saved." remoteExec ["hint", owner _player];}
	else {"Inventory save failed." remoteExec ["hint", owner _player];};
};
"saveRequest" addPublicVariableEventHandler saveRequestHandler;

disconnectHandler = 
{
	_player = _this select 0;
	_invSave = [_player, "script", false] call invExport;
	if (count _invSave > 2048) then 
	{
		_invSaveArray = [_invSave, 2048] call compile preprocessfilelinenumbers "cupinv\splitLongString.sqf";
		_invSave = "";
		{
			_newPart = ["encodeBase64", _x] call invDB;
			_invSave = _invSave + _newPart;
		} foreach _invSaveArray;
	} else
	{
		_invSave = ["encodeBase64", _invSave] call invDB;
	};
	_saveSuccess = ["write", [_this select 2 "inv", _invSave]] call invDB;
	if (_saveSuccess) then {diag_log format ["Successful save on disconnect (UID %1)", _this select 2];}
	else {diag_log format ["Unsuccessful save on disconnect (UID %1)", _this select 2];};
};
if (_saveOnQuit) then {addMissionEventHandler ["HandleDisconnect", disconnectHandler];};

forceSaveHandler = 
{
	{
		[nil, _x] call saveRequestHandler;
	} foreach allPlayers;
};
"forceSave" addPublicVariableEventHandler forceSaveHandler;

serverReady = true;
publicVariable "serverReady";