/**
	Set a unit to be tracked. If the unit is already being tracked, change the tracker's parameters
	Parameters:
	- Unit to be tracked - Required
	- Marker text - Optional, defaults to empty string
	- Marker colour - Optional, defaults to "Default", which is usually black
	- Width of line - Optional, defaults to 2
	- Number of line segments - Optional, defaults to 1, and must be at least 1
	- Update frequency in seconds - Optional, defaults to 15
**/
CUPTRACK_setTrack = 
{
	params ["_target", ["_text", CUPTRACK_defaultText], ["_colour", CUPTRACK_defaultColour], ["_lineWidth", CUPTRACK_defaultLineWidth], ["_lineSegments", CUPTRACK_defaultLineSegments], ["_tickRate", CUPTRACK_defaultTickRate]];
	if (_lineSegments < 1) then {_lineSegments = 1;};
	_targetStr = str _target;
	if (!isNil {CUPTRACK_trackerList get _targetStr}) then {_target call CUPTRACK_removeTrack;};
	_markerDot = createMarkerLocal [format ["CUPTRACK_%1_dot", _targetStr], position _target];
	_markerDot setMarkerShapeLocal "ICON";
	_markerDot setMarkerTypeLocal "mil_dot";
	_markerDot setMarkerColorLocal _colour;
	_markerDot setMarkerTextLocal _text;
	_lineArray = [];
	for "_i" from 1 to _lineSegments do
	{
		_currentLineArray = [];
		_currentLineArray pushBack (position _target);
		_markerLine = createMarkerLocal [format ["CUPTRACK_%1_line%2", _targetStr, _i], position _target];
		_markerLine setMarkerShapeLocal "RECTANGLE";
		_markerLine setMarkerSizeLocal [_lineWidth,0];
		_markerLine setMarkerColorLocal _colour;
		_currentLineArray pushBack _markerLine;
		_lineArray pushBack _currentLineArray;
	};
	_respawnEH = _target addMPEventHandler ["MPRespawn", {_this remoteExec ["CUPTRACK_handleRespawn"];}];
	_trackArray = [_target, _markerDot, _lineArray, 0, _tickRate, -1, _respawnEH];
	CUPTRACK_trackerList set [_targetStr, _trackArray];
};

/**
	Removes tracking from given unit
	_unit call CUPTRACK_removeTrack
**/
CUPTRACK_removeTrack = 
{
	_targetStr = str _this;
	_trackArray = CUPTRACK_trackerList get _targetStr;
	if (!isNil "_trackArray") then
	{
		_trackArray params ["_unit", "_markerDot", "_lineArray", "_nextLine", "_tickRate", "_nextTick", "_respawnEH"];
		deleteMarkerLocal _markerDot;
		{
			deleteMarkerLocal (_x select 1);
		} forEach _lineArray;
		_unit removeMPEventHandler _respawnEH;
		CUPTRACK_trackerList set [_targetStr, nil];
	};
};

/**
	Returns the tracker array for the given unit, as it would've been formatted for setTrack
	If the unit is not being tracked, returns nil
**/
CUPTRACK_getTrack = 
{
	_trackArray = CUPTRACK_trackerList get (str _this);
	if (isNil "_trackArray") exitWith {nil};
	_trackArray params ["_unit", "_markerDot", "_lineArray", "_nextLine", "_tickRate", "_nextTick", "_respawnEH"];
	_lineCount = count _lineArray;
	_markerText = markerText _markerDot;
	_markerColour = markerColor _markerDot;
	_lineWidth = (markerSize ((_lineArray select 0) select 1)) select 0;
	_returnArray = [_unit, _markerText, _markerColour, _lineWidth, _lineCount, _tickRate];
	_returnArray
};

CUPTRACK_tick = 
{
	{
		_y params ["_unit", "_markerDot", "_lineArray", "_nextLine", "_tickRate", "_nextTick", "_respawnEH"];
		if ((str _unit) != _x) then // unit variable name changed; update key
		{
			CUPTRACK_trackerList set [str _unit, _y];
			CUPTRACK_trackerList set [_x, nil];
		};
		if (time > _nextTick) then
		{
			_newPos = position _unit;
			_markerDot setMarkerPosLocal _newPos;
			_prevLine = _nextLine - 1;
			if (_prevLine == -1) then
			{
				_prevLine = (count _lineArray) - 1;
			};
			_oldPos = (_lineArray select _prevLine) select 0;
			_currentLineArray = _lineArray select _nextLine;
			_markerLine = _currentLineArray select 1;
			
			_oldX = _oldPos select 0;
			_oldY = _oldPos select 1;
			_newX = _newPos select 0;
			_newY = _newPos select 1;
			_markerLine setMarkerPosLocal [(_oldX + _newX)/2, (_oldY + _newY)/2];
			_markerLine setMarkerSizeLocal [getMarkerSize _markerLine select 0, (sqrt((_oldX-_newX)^2 + (_oldY-_newY)^2))/2];
			_markerLine setMarkerDirLocal (_oldX-_newX) atan2 (_oldY-_newY);
			
			_currentLineArray set [0, _newPos];
			_lineArray set [_nextLine, _currentLineArray];
			if ((_nextLine + 1) == count _lineArray) then
			{
				_nextLine = 0;
			} else
			{
				_nextLine = _nextLine + 1;
			};
			
			_nextTick = time + _tickRate;
			
			CUPTRACK_trackerList set [_x, [_unit, _markerDot, _lineArray, _nextLine, _tickRate, _nextTick]];
		};
	} forEach CUPTRACK_trackerList;
};

CUPTRACK_handleRespawn = 
{
	params ["_unit", "_corpse"];
	_trackArray = CUPTRACK_trackerList get (str _corpse);
	if !(isNil "_trackArray") then
	{
		_trackArray set [0, _unit];
	};
};
