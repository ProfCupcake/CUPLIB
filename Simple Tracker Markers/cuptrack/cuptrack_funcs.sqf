CUPTRACK_addTrack = 
{
	// Input format: [target, marker text, colour, width of line]
	// TrackArray format: [target, dot marker name, line marker name, respawnEH]
	_target = _this select 0;
	if (isNil {_target}) exitWith 
	{
		if CUPTRACK_logging then {diag_log format ["[%2] CUPTRACK: Attempted to add tracking to %1, but unit does not appear to exist.", _target, time];};
	};
	_colour = "ColorBlack";
	_width = 2;
	_text = "";
	if !(isNil {_this select 2}) then {_colour = _this select 2;};
	if !(isNil {_this select 1}) then {_text = _this select 1;};
	if !(isNil {_this select 3}) then {_width = _this select 3;};
	_markdot = createMarkerLocal [format ["CUPTRACK_%1_dot", _target], position _target];
	_markdot setMarkerShapeLocal "ICON";
	_markdot setMarkerTypeLocal "mil_dot";
	_markdot setMarkerColorLocal _colour;
	_markdot setMarkerTextLocal _text;
	_markline = createMarkerLocal [format ["CUPTRACK_%1_line", _target], position _target];
	_markline setMarkerShapeLocal "RECTANGLE";
	_markline setMarkerSizeLocal [_width,0];
	_markline setMarkerColorLocal _colour;
	_EH = _target addEventHandler ["Respawn", CUPTRACK_respawnEH];
	_markArray = [_target, _markdot, _markline, _EH];
	CUPTRACK_trackArray pushBack _markArray;
	if CUPTRACK_logging then {diag_log format ["[%5] CUPTRACK: New track: %1, Text '%2', Colour '%3', Width %4", _target, _text, _colour, _width, time];};
};

CUPTRACK_trackLoop = 
{
	while {CUPTRACK_tracking} do
	{
		if (count CUPTRACK_trackArray > 0) then
		{
			diag_log format ["[%1] CUPTRACK: Marker update...", time];
			{
				_target = _x select 0;
				_markdot = _x select 1;
				_markline = _x select 2;
				_oldPos = getMarkerPos _markdot;
				_newPos = getPos _target;
				_oldX = _oldPos select 0;
				_oldY = _oldPos select 1;
				_newX = _newPos select 0;
				_newY = _newPos select 1;
				_markdot setMarkerPosLocal _newPos;
				_markline setMarkerPosLocal [(_oldX + _newX)/2, (_oldY + _newY)/2];
				_markline setMarkerSizeLocal [getMarkerSize _markline select 0, (sqrt((_oldX-_newX)^2 + (_oldY-_newY)^2))/2];
				_markline setMarkerDirLocal (_oldX-_newX) atan2 (_oldY-_newY);
				if CUPTRACK_logging then {diag_log format ["[%4] CUPTRACK: %1 | %2 -> %3", _target, _oldPos, _newPos, time];};
			} forEach CUPTRACK_trackArray;
			if CUPTRACK_logging then {diag_log format ["[%1] CUPTRACK: Updated.", time];};
		};
	sleep CUPTRACK_updateDelay;
	};
};

CUPTRACK_removeTrack = 
{
	_found = false;
	_return = nil;
	{
		if (_x select 0 == _this) exitWith
		{
			_found = true;
			_this removeEventHandler ["Respawn", _x select 3];
			_text = markerText (_x select 1);
			_colour = markerColor (_x select 1);
			_size = (markerSize (_x select 2)) select 0;
			_return = [_this, _text, _colour, _size];
			deleteMarkerLocal (_x select 1);
			deleteMarkerLocal (_x select 2);
			CUPTRACK_trackArray = CUPTRACK_trackArray - _x;
		};
	} forEach CUPTRACK_trackArray;
	if (_found) then
	{
		if CUPTRACK_logging then {diag_log format ["[%2] CUPTRACK: Removed tracking from %1", _this, time];};
	} else
	{
		if CUPTRACK_logging then {diag_log format ["[%2] CUPTRACK: Attempted to remove tracking from %1, but unit was not being tracked.", _this, time];};
	};
	_return
};

CUPTRACK_respawnEH = 
{
	if CUPTRACK_logging then {diag_log format ["[%1] CUPTRACK: Performing respawn fix on %2...", time, _this select 0];};
	{
		if (_x select 0 == _this select 1) exitWith
		{
			_x set [0, _this select 0];
		};
	} forEach CUPTRACK_trackArray;
	if CUPTRACK_logging then {diag_log format ["[%1] CUPTRACK: Respawn fix complete.", time];};
};