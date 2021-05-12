CUPZEUS_commandConfig = missionConfigFile >> "CUPZEUS" >> "commands";

CUPZEUS_doChatCommand = 
{
	private ["_command", "_parameters"];
	_command = _this select 0;
	_parameters = _this select [1, count _this];
	
	_code = getText (CUPZEUS_commandConfig >> _command >> "code");
	
	if (_code == "") exitWith {call CUPZEUS_commandNotRecognised;};
	
	_parameters call compile _code;
};

CUPZEUS_commandNotRecognised = 
{
	systemChat 'CUPZEUS command not recognised. Try "!z help".';
};

CUPZEUS_commandHelp = 
{
	params ["_command"];
	if (!isNil "_command") then
	{
		systemChat format ['Help for command "!z %1":', _command];
		_commandHelp = getArray (CUPZEUS_commandConfig >> _command >> "help");
		if (count _commandHelp == 0) exitWith {systemChat "Command either doesn't exist or doesn't have help text.";};
		{
			systemChat _x;
		} forEach _commandHelp;
	} else
	{
		_commandList = "";
		for "_i" from 0 to ((count CUPZEUS_commandConfig) - 1) do
		{
			if (_i > 0) then {_commandList = _commandList + ", ";};
			_curString = (str (CUPZEUS_commandConfig select _i)) select [(count str CUPZEUS_commandConfig) + 1];
			_commandList = _commandList + _curString;
		};
		systemChat "Commands:-";
		systemChat _commandList;
		systemChat 'Type "!z help <command>" to view help for specific commands.';
	};
};

CUPZEUS_commandRequest = 
{
	if (isNull (getAssignedCuratorLogic player)) then
	{
		systemChat "Requesting Zeus...";
		player remoteExec ["CUPZEUS_handleRequest", 2];
	} else
	{
		systemChat "You already have Zeus!";
	};
};

CUPZEUS_commandRelinquish = 
{
	if (isNull (getAssignedCuratorLogic player)) then
	{
		systemChat "You do not have Zeus!";
	} else
	{
		player remoteExec ["CUPZEUS_handleRelinquish", 2];
	};
};

CUPZEUS_commandList = 
{
	player remoteExec ["CUPZEUS_handleListRequest", 2];
};

waitUntil {!isNull (findDisplay 46)};
systemChat "CUPZEUS chat commands enabled.";
systemChat 'Type "!z help" to get a list of commands';