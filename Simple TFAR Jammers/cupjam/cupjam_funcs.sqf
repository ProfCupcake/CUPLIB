// Array for jammers, formatted as in CUPJAM_addJammer
if (isServer) then
{
	CUPJAM_jammerList = [];
	publicVariable "CUPJAM_jammerList";
};

/**
Add new jammer
Parameters:
- location or object, required
- min range, default 25
- max range, default 250
**/
CUPJAM_addJammer = 
{
	params ["_pos", ["_minRange", 25], ["_maxRange", 250]];
	private "_index";
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
	while {_index < 0} do
	{
		if (isNil {CUPJAM_jammerList select _i}) then
		{
			CUPJAM_jammerList set [_i, [_pos, _minRange, _maxRange]];
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
	CUPJAM_jammerList set [_i, nil];
	publicVariable "CUPJAM_jammerList";
};

CUPJAM_calculateJamFactorFromArray = 
{
	params ["_pos", "_minRange", "_maxRange"];
	private ["_distance", "_jamFactor"];
	_distance = player distance _pos;
	_jamFactor = 1;
	if (_distance < _maxRange) then
	{
		if (_distance < _minRange) then
		{
			_jamFactor = 0;
		} else
		{
			_jamFactor = ((_distance-_minRange)/(_maxRange-_minRange))^CUPJAM_distanceExponent;
		};
	};
	_jamFactor
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