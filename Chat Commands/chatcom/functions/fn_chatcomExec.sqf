/*****************************************************************************
Function name: RWT_fnc_chatcomExec;
Authors: longbow
License: MIT License
Version: 1.0

Dependencies:
	NONE

Changelog:
	=== 1.0 === 09-Oct-2016
		Initial release

Description:
	Functions executes a command, defined in rwt_chatcom class, and
        passes arguments to it.

Arguments:
	ARRAY [_COM,_ARG1,..,_ARG_N]
		_COM - STRING, name of command from rwt_chatcom class
		_ARG1-_ARGN - STRING, optional arguments to command

Returns:
	NOTHING

*****************************************************************************/

// read command name
private _com = _this select 0;
// check if supplied command is a valid command, defined in config and
// that it has 'code' property
if (!isText (getMissionConfig "rwt_chatcom" >> "commands" >> _com >> "code")) exitWith
{
    ["RWT_CHATCOM: %1", "Invalid command"] call BIS_fnc_error;
};
// store arguments for command
private _args = _this select [1,count _this];
private _processedArgs = [];
private _concatArray = [];
private _curString = "";
{
	if (count _curString > 0) then
	{
		if ((_x select [count _x - 1]) == '"') then
		{
			_curString = _curString + " " + (_x select [0, count _x - 1]);
			_processedArgs pushBack _curString;
			_curString = "";
		} else
		{
			_curString = _curString + " " + _x;
		};
	} else
	{
		if ((_x select [0,1]) == '"') then
		{
			_curString = (_x select [1]);
		} else
		{
			_processedArgs pushBack _x;
		};
	};
} forEach _args;

if (count _curString > 0) then
{
	_processedArgs pushBack _curString;
};

// execute command
_processedArgs call compile getText (getMissionConfig "rwt_chatcom" >> "commands" >> _com >> "code");

