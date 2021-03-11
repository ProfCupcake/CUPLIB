/**
List of signals, stored identically to the "addSignal" parameters
**/
if (isServer) then
{
	CUPSIGNAL_signalList = [];
	publicVariable "CUPSIGNAL_signalList";
};

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
	if (typeName _pos == "ARRAY") then
	{
		if (isNil {_pos select 2}) then
		{
			_pos = [_pos select 0, _pos select 1, 0];
		};
		_pos = ASLtoAGL _pos;
	};
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
	publicVariable "CUPSIGNAL_signalList";
	_index
};

/**
Removes the signal with the given index
**/
CUPSIGNAL_removeSignal = 
{
	params ["_i"];
	CUPSIGNAL_signalList set [_i, nil];
	publicVariable "CUPSIGNAL_signalList";
};

/**
Takes array formatted from signalList and calculates signal strength for local player
**/
CUPSIGNAL_calculateStrengthFromArray = 
{
	params ["_pos", "_freq", "_maxRange", "_minRange", "_directional"];
	private ["_distance","_strength"];
	if CUPSIGNAL_3D then
	{
		_distance = player distance _pos;
	} else
	{
		_distance = player distance2D _pos;
	};
	_strength = 0;
	if (_distance < _maxRange) then
	{
		if (_distance > _minRange) then
		{
			_strength = (1-(_distance-_minRange)/(_maxRange-_minRange));
			_strength = _strength^CUPSIGNAL_distanceExponent;
			if (_directional) then
			{
				private ["_dirDiff","_dirCoeff"];
				if CUPSIGNAL_3D then 
				{
					if (typeName _pos == "OBJECT") then
					{
						_pos = getPosASL _pos;
					};
					
					_dirDiff = vectorMagnitude ((player weaponDirection currentWeapon player) vectorDiff (eyePos player vectorFromTo _pos));
					_dirCoeff = (1-(_dirDiff/CUPSIGNAL_maxAngleVM)) max 0;
				} else
				{
					_dirDiff = abs ((player getDir _pos) - (direction player));
					_dirCoeff = (1-(_dirDiff/CUPSIGNAL_maxAngle)) max 0;
				};
				
				_dirCoeff = _dirCoeff^CUPSIGNAL_directionExponent;
				_strength = _strength*_dirCoeff;
			};
		} else 
		{
			_strength = 1;
		};
		_strength = _strength*CUPSIGNAL_maxStrength;
	};
	_strength
};

/**
Calculates signal strength from given signal index
Usage example: 

strength = 2 call CUPSIGNAL_calculateSignalStrength;

If signal index does not exist, returns -1.
**/
CUPSIGNAL_calculateSignalStrength = 
{
	private ["_strength", "_signalArray"];
	_strength = -1;
	_signalArray = CUPSIGNAL_signalList select _this;
	if !(isNil {_signalArray}) then
	{
		_strength = _signalArray call CUPSIGNAL_calculateStrengthFromArray;
	};
	_strength
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
			private "_equippedAntenna";
			_equippedAntenna = handgunItems player select 0;
			if ((isNil {CUPSIGNAL_equippedAntenna}) or {(_equippedAntenna != CUPSIGNAL_equippedAntenna)}) then
			{
				private "_freqRanges";
				if (_equippedAntenna == "") then
				{
					_freqRanges = [0,0];
				} else
				{
					_freqRanges = CUPSIGNAL_freqRanges get _equippedAntenna;
					if (isNil {_freqRanges}) then
					{
						_freqRanges = CUPSIGNAL_defaultFreqRange;
					};
				};
				missionNamespace setVariable ["#EM_FMin", _freqRanges select 0];
				missionNamespace setVariable ["#EM_FMax", _freqRanges select 1];
				CUPSIGNAL_equippedAntenna = _equippedAntenna;
			};
			private "_values";
			_values = [];
			{
				if !(isNil {_x}) then
				{
						_x params ["", "_freq"];
						private "_strength";
						_strength = _x call CUPSIGNAL_calculateStrengthFromArray;
						_values pushBack _freq;
						_values pushBack _strength;
				};
			} forEach CUPSIGNAL_signalList;
			missionNamespace setVariable ["#EM_Values", _values];
		};
	sleep 0.1;
	};
};

/**
Enables TFAR integration
Paramters:
- min SW range, default 1
- max SW range, default 500
- min LR range, default 5
- max LR range, default 2500
**/
CUPSIGNAL_enableTFARIntegration = 
{
	params [["_minSWrange", 1], ["_maxSWrange", 500], ["_minLRrange", 5], ["_maxLRrange", 2500]];
	["radioSpectrumSignalEH", "OnTangent", 
	{
		params ["_unit", "_radioClass", "_radioUsed", "_additionalChannel", "_buttonDown"];
		private ["_freq","_minRange","_maxRange"];
		if (_radioUsed == 0) then
		{
			_minRange = _minSWrange;
			_maxRange = _maxSWrange;
			if (_additionalChannel) then
			{
				private "_radio";
				_radio = (call TFAR_fnc_activeSwRadio);
				_freq = [_radio, (_radio call TFAR_fnc_getAdditionalSwChannel)+1] call TFAR_fnc_getChannelFrequency;
			} else
			{
				_freq = (call TFAR_fnc_activeSwRadio) call TFAR_fnc_getSwFrequency;
			};
		};
		if (_radioUsed == 1) then
		{
			_minRange = _minLRrange;
			_maxRange = _maxLRrange;
			if (_additionalChannel) then
			{
				private "_radio";
				_radio = (call TFAR_fnc_activeLrRadio);
				_freq = [_radio, (_radio call TFAR_fnc_getAdditionalLrChannel)+1] call TFAR_fnc_getChannelFrequency;
			} else
			{
				_freq = (call TFAR_fnc_activeLrRadio) call TFAR_fnc_getLrFrequency;
			};
		};
		if (!isNil {_freq}) then
		{
			if (_buttonDown) then
			{
				if (CUPSIGNAL_debug) then {systemChat format ["%1 started transmitting! Freq: %2",_unit,_freq];};
				_unit setVariable ["CUPSIGNAL_radioSignalIndex", [_unit, parseNumber _freq] call CUPSIGNAL_addSignal];
			} else
			{
				if (CUPSIGNAL_debug) then {systemChat format ["%1 stopped transmitting! Freq: %2",_unit,_freq];};
				_unit getVariable "CUPSIGNAL_radioSignalIndex" call CUPSIGNAL_removeSignal;
			};
		};
	}, player] call TFAR_fnc_addEventHandler;
};