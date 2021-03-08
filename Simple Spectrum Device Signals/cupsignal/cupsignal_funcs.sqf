/**
List of signals, stored identically to the "addSignal" parameters
**/
CUPSIGNAL_signalList = [];

/**
Add new signal to be tracked.
Parameters:-
	- position of signal (can be either 2D position array or an object)
	- frequency of signal
	+ maximum range (signal will attenuate to 0 at this range); default is set in init
	+ minimum range (within this range, signal is 100% strength); default is set in init
	+ directionality (if true, signal strength weakens if looking away from signal; if false, signal strength is not affected by direction); default is set in init
Returns an index pointing to this signal in the list
**/
CUPSIGNAL_addSignal = 
{
	params ["_pos", "_freq", ["_maxRange",CUPSIGNAL_defaultMaxRange], ["_minRange",CUPSIGNAL_defaultMinRange], ["_directional",CUPSIGNAL_directional]];
	private "_index";
	_index = -1;
	private "_i";
	_i = 0;
	while {_index < 0} do
	{
		if (isNil {CUPSIGNAL_signalList select _i}) then
		{
			CUPSIGNAL_signalList set [_i, [_pos, _freq, _maxRange, _minRange, _directional]];
			_index = _i;
		};
		_i = _i + 1;
	};
	_index
};

/**
Removes the signal with the given index
**/
CUPSIGNAL_removeSignal = 
{
	params ["_i"];
	CUPSIGNAL_signalList set [_i, nil];
};

/**
Central signal update loop
**/
CUPSIGNAL_tickLoop = 
{
	while {true} do
	{
		if ("hgun_esd_" in currentWeapon player) then
		{
			private "_values";
			_values = [];
			{
				if !(isNil {_x}) then
				{
					_x params ["_pos", "_freq", "_maxRange", "_minRange", "_directional"];
					private ["_distance","_strength"];
					_distance = player distance2D _pos;
					if (_distance < _maxRange) then
					{
						if (_distance > _minRange) then
						{
							_strength = (1-(_distance/(_maxRange-_minRange)))*100;
							if (_directional) then
							{
								private ["_dirDiff","_dirCoeff"];
								_dirDiff = (player getDir _pos) - (direction player);
								if (_dirDiff < 0) then {_dirDiff = _dirDiff*-1;};
								_dirCoeff = (1-(_dirDiff/CUPSIGNAL_maxAngle)) max 0;
								_strength = _strength*_dirCoeff;
							};
						} else 
						{
							_strength = 100;
						};
						_values pushBack _freq;
						_values pushBack _strength;
					};
				};
			} forEach CUPSIGNAL_signalList;
			missionNamespace setVariable ["#EM_Values", _values];
		};
	sleep 0.1;
	};
};

