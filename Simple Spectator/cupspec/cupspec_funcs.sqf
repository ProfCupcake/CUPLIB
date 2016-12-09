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
  _playerlist = 0 call CUPSPEC_generateList;
  {
    if (isNil {CUPSPEC_spectating}) exitWith
    {
      CUPSPEC_spectating = _playerlist select 0;
      CUPSPEC_mode = CUPSPEC_modeList select 0;
      CUPSPEC_index = 0;
      hint "To switch target, press your Move Right or Move Left key. \nTo stop spectating, press your Reload key.";
    };
    if (_x == CUPSPEC_spectating) exitWith
    {
      if ((_forEachIndex + _this) == count _playerlist) then
      {
        CUPSPEC_spectating = _playerlist select 0;
        CUPSPEC_index = 0;
      } else
      {
        if ((_forEachIndex + _this) == -1) then
        {
          CUPSPEC_spectating = _playerlist select ((count _playerList) - 1);
          CUPSPEC_index = count _playerList - 1;
        } else
        {
          CUPSPEC_spectating = _playerlist select (_forEachIndex + _this);
          CUPSPEC_index = _forEachIndex + _this;
        };
      };
    };
  } forEach _playerlist;
  player setVariable ["CUPSPEC_spectating", CUPSPEC_spectating, true];
  CUPSPEC_spectating switchCamera CUPSPEC_mode;
  player enableSimulation false; 
  systemchat format ["Now spectating '%1' (%2/%3)", name CUPSPEC_spectating, CUPSPEC_index + 1, count _playerList];
};

CUPSPEC_inputEH = 
{
  //hint "EH";
  _return = false;
  if (CUPSPEC_spectating == CUPSPEC_spectating) then
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