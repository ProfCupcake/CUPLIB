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
	+ receiver directionality (if true, signal strength weakens if looking away from signal; if false, signal strength is not affected by direction); default is set in init
	+ forwards direction; if this is set, then the signal is simulated as a cone facing this direction. Nil by default (i.e. disabled). This can be either a number, defining a constant azimuth; a vector, defining a constant 3D direction; or a code block, which should return one of the previous two arguments. Cone behaviour depends on the type of direction set: if it's a number it is 2D (ignores height), if it's a vector it is 3D. This parameter description is very long, thanks for reading it. I hope it at least partially makes sense. 
	+ signal angle; only matters if the forwards direction is set. Defines the angle of the signal cone, in degrees. Note that it works like radius, so the actual angle is double this number. Default 60. 
	+ arbitrary; allows you to pass arguments in to be used by any of the other parameters, if they are code
Returns an index pointing to this signal in the list
**/
CUPSIGNAL_addSignal = 
{
	params ["_pos", "_freq", ["_maxRange",CUPSIGNAL_defaultMaxRange], ["_minRange",CUPSIGNAL_defaultMinRange], ["_directional",CUPSIGNAL_directional], "_forwards", ["_angle", CUPSIGNAL_defaultConeAngle], ["_args", []]];
	private ["_index", "_signalArray"];
	if (typeName _pos == "ARRAY") then
	{
		if (isNil {_pos select 2}) then
		{
			_pos = [_pos select 0, _pos select 1, 0];
		};
		_pos = AGLtoASL _pos;
	};
	_index = -1;
	
	_signalArray = [_pos, _freq, _maxRange, _minRange, _directional];
	
	if (isNil {_forwards}) then
	{
		_signalArray = _signalArray + [nil, _angle, _args];
	} else
	{
		_signalArray  = _signalArray + [_forwards, _angle, _args];
	};
	
	private "_i";
	_i = 0;
	while {_index < 0} do
	{
		if (isNil {CUPSIGNAL_signalList select _i}) then
		{
			CUPSIGNAL_signalList set [_i, _signalArray];
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
	params ["_pos", "_freq", "_maxRange", "_minRange", "_directional", "_forwards", "_angle", "_args"];
	private ["_distance","_strength"];
	if (typeName _pos == "CODE") then
	{
		_pos = _args call _pos;
	};
	if CUPSIGNAL_3D then
	{
		if (typeName _pos == "ARRAY") then
		{
			_distance = player distance ASLtoAGL _pos;
		} else
		{
			_distance = player distance _pos;
		};
	} else
	{
		_distance = player distance2D _pos;
	};
	if (typeName _pos == "OBJECT") then
	{
		_pos = getPosASL _pos;
	};
	
	if (typeName _maxRange == "CODE") then
	{
		_maxRange = _args call _maxRange;
	};
	
	if (typeName _minRange == "CODE") then
	{
		_minRange = _args call _minRange;
	};
	
	_strength = 0;
	if (_distance < _maxRange) then
	{
		private "_coneCheck";
		if (isNil {_forwards}) then
		{
			_coneCheck = true;
		} else
		{
			_coneCheck = [_pos, _forwards, _angle, _args] call CUPSIGNAL_coneCheck;
		};
		
		if (_coneCheck) then
		{
			
			if (typeName _freq == "CODE") then
			{
				_freq = _args call _freq;
			};
			
			if (_distance > _minRange) then
			{
				_strength = (1-(_distance-_minRange)/(_maxRange-_minRange));
				_strength = _strength^CUPSIGNAL_distanceExponent;
				
				if (typeName _directional == "CODE") then
				{
					_directional = _args call _directional;
				};
				
				if (_directional) then
				{
					private ["_dirDiff","_dirCoeff"];
					if CUPSIGNAL_3D then 
					{
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
		};
		_strength = _strength*CUPSIGNAL_maxStrength;
	};
	_strength
};

/**
Given a position (PositionASL), a direction (number, vector, or code returning those), and an angle, checks that the local player is in that cone
Also passed the full signal array as parameter 3, to be passed into the forwards angle code
**/
CUPSIGNAL_coneCheck = 
{
	params ["_pos", "_forwards", "_angle", "_args"];
	private ["_return", "_dirDiff"];
	if (typeName _forwards == "CODE") then
	{
		_forwards = _args call _forwards; 
	};
	
	if (typeName _angle == "CODE") then
	{
		_angle = _args call _angle;
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

/**

saving the following for later...

//First Zues
_curatorModule = allCurators select 0;
//Unit who is Zeus
_curatorUnit = getAssignedCuratorUnit _curatorModule;
//Zues editable Units
_curatorObjects = curatorEditableObjects _curatorModule select { typeOf _x isKindOf "CAManBase" };
//Zues remoteControlled Unit [ unit ] OR []
_curatorControlledUnit = _curatorObjects select { _x getVariable "bis_fnc_moduleremotecontrol_owner" isEqualTo _curatorUnit };

from https://forums.bohemia.net/forums/topic/220229-find-zeus-controlled-unit/
**/