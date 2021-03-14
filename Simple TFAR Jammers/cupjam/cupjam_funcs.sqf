/** 
Array for jammers, formatted as follows:-
 - location/object
 - max range
 - min range
 - assigned CUPSIGNAL index (or nil, if CUPSIGNAL support is disabled)
 - direction
 - angle
**/
if (isServer) then
{
	CUPJAM_jammerList = [];
	publicVariable "CUPJAM_jammerList";
};

/**
Add new jammer
Parameters:
- location or object, required
- max range, default 250
- min range, default 25
- direction, default nil
- angle, default 60
**/
CUPJAM_addJammer = 
{
	params ["_pos", ["_maxRange", 250], ["_minRange", 25], "_direction", ["_angle", 60]];
	private ["_index", "_signalIndex"];
	if (typeName _pos == "ARRAY") then
	{
		if (isNil {_pos select 2}) then
		{
			_pos = [_pos select 0, _pos select 1, 0];
		};
	};
	_index = -1;
	private "_i";
	_i = 0;
	if (CUPJAM_signalSupport) then
	{
		if (isNil {_direction}) then
		{
			_signalIndex = [_pos, CUPJAM_signalFrequency, _maxRange*CUPJAM_signalMaxRangeMult, _minRange*CUPJAM_signalMinRangeMult, CUPSIGNAL_directional] call CUPSIGNAL_addSignal;
		} else
		{
			_signalIndex = [_pos, CUPJAM_signalFrequency, _maxRange*CUPJAM_signalMaxRangeMult, _minRange*CUPJAM_signalMinRangeMult, CUPSIGNAL_directional, _direction, _angle] call CUPSIGNAL_addSignal;
		};
	};
	while {_index < 0} do
	{
		if (isNil {CUPJAM_jammerList select _i}) then
		{
			if (isNil {_direction}) then 
			{
				CUPJAM_jammerList set [_i, [_pos, _maxRange, _minRange, _signalIndex, nil, _angle]];
			} else
			{
				CUPJAM_jammerList set [_i, [_pos, _maxRange, _minRange, _signalIndex, _direction, _angle]];
			};
			_index = _i;
		};
		_i = _i + 1;
	};
	publicVariable "CUPJAM_jammerList";
	_index
};

CUPJAM_removeJammer = 
{
	params ["_i"];
	(CUPJAM_jammerList select _i) params ["", "", "", "_signalIndex"];
	if (!isNil {_signalIndex}) then
	{
		_signalIndex call CUPSIGNAL_removeSignal;
	};
	CUPJAM_jammerList set [_i, nil];
	publicVariable "CUPJAM_jammerList";
};

CUPJAM_calculateJamFactorFromArray = 
{
	params ["_pos", "_maxRange", "_minRange", "", "_direction", "_angle"];
	private ["_distance", "_jamFactor"];
	if (typeName _pos == "CODE") then
	{
		_pos = _this call _pos;
	};
	_distance = player distance _pos;
	if (typeName _maxRange == "CODE") then
	{
		_maxRange = _this call _maxRange;
	};
	if (typeName _minRange == "CODE") then
	{
		_minRange = _this call _minRange;
	};
	_jamFactor = 1;
	if (_distance < _maxRange) then
	{
		private "_coneCheck";
		if (isNil {_direction}) then
		{
			_coneCheck = true;
		} else
		{
			_coneCheck = [_pos, _direction, _angle, _this] call CUPSIGNAL_coneCheck;
		};
	
		if (_coneCheck) then
		{
			if (_distance < _minRange) then
			{
				_jamFactor = 0;
			} else
			{
				_jamFactor = ((_distance-_minRange)/(_maxRange-_minRange))^CUPJAM_distanceExponent;
			};
		};
	};
	_jamFactor
};


// Cone check function, copied from CUPSIGNAL as it doesn't need to be changed for this
// maybe these two scripts should've just been put together, huh
CUPSIGNAL_coneCheck = 
{
	params ["_pos", "_forwards", "_angle", "_signalArray"];
	private ["_return", "_dirDiff"];
	if (typeName _forwards == "CODE") then
	{
		_forwards = _signalArray call _forwards; 
	};
	
	if (typeName _angle == "CODE") then
	{
		_angle = _signalArray call _angle;
	};
	
	if (typeName _forwards == "SCALAR") then
	{
		_dirDiff = abs (_forwards - (_pos getDir player));
		_return = (_dirDiff < _angle);
	};
	
	if (typeName _forwards == "ARRAY") then
	{
		_dirDiff = vectorMagnitude (_forwards vectorDiff (_pos vectorFromTo eyePos player));
		_return = (_dirDiff < (_angle/90));
	};
	
	_return
};

/**CUPJAM_calculateJamFactor = 
{
	
};**/

CUPJAM_tickLoop = 
{
	private ["_jamFactor"];
	while {true} do
	{
		_jamFactor = 1;
		{
			if (!isNil {_x}) then
			{
				_jamFactor = _jamFactor*(_x call CUPJAM_calculateJamFactorFromArray);
			};
		} forEach CUPJAM_jammerList;
		if (_jamFactor > 0) then
		{
			player setVariable ["tf_receivingDistanceMultiplicator", 1/_jamFactor];
		} else
		{
			player setVariable ["tf_receivingDistanceMultiplicator", 1000000];
		};
		player setVariable ["tf_sendingDistanceMultiplicator", _jamFactor];
		sleep 1;
	};
};