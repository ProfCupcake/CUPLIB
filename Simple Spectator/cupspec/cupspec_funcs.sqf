CUPSPEC_addSpectateObject = 
{
	_range = 25;
	if (count _this >= 2) then {_range = _this select 1;};
	//title, script, arguments, priority, showWindow, hideOnUse, shortcut, condition
	_this select 0 addAction [format ["<t color='%1'>Begin Spectating</t>", CUPSPEC_actionColour], "cupspec\actions\spectateFromObject.sqf", _range, 5, true, true, "", "true"];
};

CUPSPEC_spectateFromObject = 
{
	_specObj = _this select 0;
	_specDist = _this select 1;
	[] call CUPSPEC_switchTarget;
	while {!(isNil {CUPSPEC_spectating})} do
	{
		if ((player distance _specObj) > _specDist) then
		{
			[] call CUPSPEC_stopSpectating;
		};
		sleep 1;
	};
};

CUPSPEC_stopSpectating = 
{
	CUPSPEC_spectating = nil;
	player setVariable ["CUPSPEC_spectating", nil, true];
	player switchCamera "INTERNAL";
	player enableSimulation true;
	systemchat "Spectation ended";
};

CUPSPEC_generateList = 
{
	_list = allPlayers - entities "HeadlessClient_F"; //Remove headless client(s), if any
	_list = _list - [player]; //Remove the local player
	{
		if !(alive _x) then {_list = _list - [_x];}; //Remove dead players
		if !(isNil {_x getVariable "CUPSPEC_spectating"}) then {_list = _list - [_x];}; //Remove players who are also spectating
		if !(_x call CUPSPEC_customCondition) then {_list = _list - [_x];}; //Remove players that do not satisfy the custom condition
	} forEach _list;
	_list
};

CUPSPEC_switchTarget = 
{
	_playerList = 0 call CUPSPEC_generateList;
	if (count _playerList < 1) exitWith
	{
		systemchat "Could not find a spectator target.";
		if (!(isNil {CUPSPEC_spectating})) then {[] spawn CUPSPEC_stopSpectating;};
	};
	if (!(isNil {CUPSPEC_spectating})) then {CUPSPEC_spectating removeMPEventHandler ["MPKilled", CUPSPEC_targetKilledEH_index];};
	{
		if (isNil {CUPSPEC_spectating}) exitWith
		{
			CUPSPEC_spectating = _playerList select 0;
			CUPSPEC_index = 0;
			hint "To switch target, press your Move Right or Move Left key. \nTo stop spectating, press your Reload key.";
		};
		if (_x == CUPSPEC_spectating) exitWith
		{
			if ((_forEachIndex + _this) == count _playerList) then
			{
				CUPSPEC_spectating = _playerList select 0;
				CUPSPEC_index = 0;
			} else
			{
				if ((_forEachIndex + _this) == -1) then
				{
					CUPSPEC_spectating = _playerList select ((count _playerList) - 1);
					CUPSPEC_index = count _playerList - 1;
				} else
				{
					CUPSPEC_spectating = _playerList select (_forEachIndex + _this);
					CUPSPEC_index = _forEachIndex + _this;
				};
			};
		};
	} forEach _playerList;
	CUPSPEC_targetKilledEH_index = CUPSPEC_spectating addMPEventHandler ["MPKilled", {call CUPSPEC_targetKilledEH;}];
	player setVariable ["CUPSPEC_spectating", CUPSPEC_spectating, true];
	switchCamera CUPSPEC_spectating;
	player enableSimulation false; 
	systemchat format ["Now spectating '%1' (%2/%3)", name CUPSPEC_spectating, CUPSPEC_index + 1, count _playerList];
};

CUPSPEC_inputEH = 
{
	//hint "EH";
	_return = false;
	if (!(isNil {CUPSPEC_spectating})) then
	{
		//hint "EHpi";
		_keycode = _this select 1;
		if (_keycode in (actionkeys "TurnRight")) then {1 spawn CUPSPEC_switchTarget;};
		if (_keycode in (actionkeys "TurnLeft")) then {-1 spawn CUPSPEC_switchTarget;};
		if (_keycode in (actionkeys "ReloadMagazine")) then {[] spawn CUPSPEC_stopSpectating;};
		_return = true;
	};
	_return
};

CUPSPEC_targetKilledEH = 
{
	if (_this select 0 == CUPSPEC_spectating) then
	{
		systemchat format ["Target '%1' was killed.", name CUPSPEC_spectating];
		1 spawn CUPSPEC_switchTarget;
	};
};