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
	sleep CUPSIGNAL_tickDelay;
	};
};

/**
New version of TFAR integration, with ranges set to actual radio range
Parameters:
- SW range multiplier, default 1
- LR range multiplier, default 1
- radio minimum range, default 1
**/
CUPSIGNAL_enableTFARIntegration = 
{
	params [["_SWrangeMult", 1], ["_LRrangeMult", 1], ["_minRange", 1]];
	CUPSIGNAL_SWrangeMult = _SWrangeMult;
	CUPSIGNAL_LRrangeMult = _LRrangeMult;
	CUPSIGNAL_minRadioSignalRange = _minRange;
	
	["radioSpectrumSignalEH", "OnTangent", 
	{
		params ["_unit", "_radio", "_radioUsed", "_additionalChannel", "_buttonDown"];
		private ["_freq","_minRange","_maxRange"];
		_minRange = CUPSIGNAL_minRadioSignalRange;
		if (_radioUsed == 0) then
		{
			/*
			_maxRange = getNumber (configfile >> "CfgWeapons" >> _radio >> "tf_range");
			_maxRange = _maxRange * (player getVariable "tf_sendingDistanceMultiplicator");
			_maxRange = _maxRange * CUPSIGNAL_SWrangeMult;
			*/
			
			_maxRange = false call CUPSIGNAL_calculateRadioRange;
			
			_minRange = _minRange * CUPSIGNAL_SWrangeMult;
			
			if (_additionalChannel) then
			{
				_freq = [_radio, (_radio call TFAR_fnc_getAdditionalSwChannel)+1] call TFAR_fnc_getChannelFrequency;
			} else
			{
				_freq = (call TFAR_fnc_activeSwRadio) call TFAR_fnc_getSwFrequency;
			};
		};
		if (_radioUsed == 1) then
		{
			/*
			_maxRange = getNumber (configFile >> "CfgVehicles" >> typeOf (_radio select 0) >> "tf_range");
			_maxRange = _maxRange * (player getVariable "tf_sendingDistanceMultiplicator");
			_maxRange = _maxRange * CUPSIGNAL_LRrangeMult;
			*/
			
			_maxRange = true call CUPSIGNAL_calculateRadioRange;
			
			_minRange = _minRange * CUPSIGNAL_LRrangeMult;
			
			if (_additionalChannel) then
			{
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
				if (CUPSIGNAL_debug) then {systemChat format ["%1 started transmitting! Freq: %2, Radio: %3, Range: %4",_unit,_freq,_radio, _maxRange];};
				_unit setVariable ["CUPSIGNAL_radioSignalIndex", [_unit, parseNumber _freq, _maxRange, _minRange] call CUPSIGNAL_addSignal];
			} else
			{
				if (CUPSIGNAL_debug) then {systemChat format ["%1 stopped transmitting! Freq: %2, Radio: %3, Range: %4",_unit,_freq,_radio, _maxRange];};
				_unit getVariable "CUPSIGNAL_radioSignalIndex" call CUPSIGNAL_removeSignal;
			};
		};
	}, player] call TFAR_fnc_addEventHandler;
};

/**
Calculates range for given radio from radio config, sendingDistanceMultiplicator, and SWrangeMult
Requires TFARintegration to have been run first
Parameter: true if using LR, false if using SW
**/
CUPSIGNAL_calculateRadioRange = 
{
	private ["_range", "_radio"];
	if (_this) then
	{
		_radio = call TFAR_fnc_activeLrRadio;
		_range = getNumber (configFile >> "CfgVehicles" >> typeOf (_radio select 0) >> "tf_range");
		_range = _range * (player getVariable "tf_sendingDistanceMultiplicator");
		_range = _range * CUPSIGNAL_LRrangeMult;
	} else
	{
		_radio = call TFAR_fnc_activeSwRadio;
		_range = getNumber (configfile >> "CfgWeapons" >> _radio >> "tf_range");
		_range = _range * (player getVariable "tf_sendingDistanceMultiplicator");
		_range = _range * CUPSIGNAL_SWrangeMult;
	};
	_range
};

/**
Old version of TFAR integration, with preset ranges
Kept for no particular reason, really
Paramters:
- min SW range, default 1
- max SW range, default 500
- min LR range, default 5
- max LR range, default 2500
**/
CUPSIGNAL_enableTFARIntegrationOld = 
{
	params [["_minSWrange", 1], ["_maxSWrange", 500], ["_minLRrange", 5], ["_maxLRrange", 2500]];
	CUPSIGNAL_minSWrange = _minSWrange;
	CUPSIGNAL_maxSWrange = _maxSWrange;
	CUPSIGNAL_minLRrange = _minLRrange;
	CUPSIGNAL_maxLRrange = _maxLRrange;
	
	["radioSpectrumSignalEH", "OnTangent", 
	{
		params ["_unit", "_radioClass", "_radioUsed", "_additionalChannel", "_buttonDown"];
		private ["_freq","_minRange","_maxRange"];
		if (_radioUsed == 0) then
		{
			_minRange = CUPSIGNAL_minSWrange;
			_maxRange = CUPSIGNAL_maxSWrange;
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
			_minRange = CUPSIGNAL_minLRrange;
			_maxRange = CUPSIGNAL_maxLRrange;
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
				if (CUPSIGNAL_debug) then {systemChat format ["%1 started transmitting! Freq: %2, Radio: %3, Range: %4",_unit,_freq,_radioClass,_maxRange];};
				_unit setVariable ["CUPSIGNAL_radioSignalIndex", [_unit, parseNumber _freq, _maxRange, _minRange] call CUPSIGNAL_addSignal];
			} else
			{
				if (CUPSIGNAL_debug) then {systemChat format ["%1 started transmitting! Freq: %2, Radio: %3, Range: %4",_unit,_freq,_radioClass,_maxRange];};
				_unit getVariable "CUPSIGNAL_radioSignalIndex" call CUPSIGNAL_removeSignal;
			};
		};
	}, player] call TFAR_fnc_addEventHandler;
};

/**
Adds the action to the player to toggle Spectrum transmit mode
**/
CUPSIGNAL_addTransmitAction = 
{
	params [["_maxRange", 100], ["_minRange", 1], ["_angle", 60]];
	CUPSIGNAL_transmitMaxRange = _maxRange;
	CUPSIGNAL_transmitMinRange = _minRange;
	CUPSIGNAL_transmitAngle = _angle;
	private "_actionIndex";
	CUPSIGNAL_actionCondition = {"hgun_esd_" in currentWeapon player};
	_actionIndex = player addAction ["Toggle Transmit Mode", CUPSIGNAL_toggleTransmit, nil, 1.5, false, true, "defaultAction", "call CUPSIGNAL_actionCondition"];
	player setVariable ["CUPSIGNAL_transmitActionIndex", _actionIndex];
	player addEventHandler ["Respawn", CUPSIGNAL_handleRespawn];
};

CUPSIGNAL_setupJammerAntenna = 
{
	params [["_maxRange", 250], ["_minRange", 25], ["_angle", 60], ["_antenna", "muzzle_antenna_03_f"]];
	CUPSIGNAL_jammerMaxRange = _maxRange;
	CUPSIGNAL_jammerMinRange = _minRange;
	CUPSIGNAL_jammerAngle = _angle;
	CUPSIGNAL_jammerAntenna = _antenna;
};

/**
Respawn EH, used to re-set the action after a respawn
**/
CUPSIGNAL_handleRespawn = 
{
	params["_unit", "_corpse"];
	private "_actionIndex";
	_corpse removeAction (_corpse getVariable "CUPSIGNAL_transmitActionIndex");
	_actionIndex = _unit addAction ["Toggle Transmit Mode", CUPSIGNAL_toggleTransmit, nil, 1.5, false, true, "defaultAction", "call CUPSIGNAL_actionCondition"]; 
	_unit setVariable ["CUPSIGNAL_transmitActionIndex", _actionIndex];
};

/**
Toggles transmission mode
**/
CUPSIGNAL_toggleTransmit = 
{
	if (isNil {player getVariable "CUPSIGNAL_transmitSignalIndex"}) then
	{
		if ("hgun_esd_" in currentWeapon player) then
		{
			if (CUPSIGNAL_debug) then {systemChat "weapon valid";};
			_antenna = handgunItems player select 0;
			if (_antenna != "") then
			{
				if (CUPSIGNAL_debug) then {systemChat "antenna valid";};
				private ["_freqRange", "_minFreq", "_maxFreq", "_transFreq"];
				_freqRange = CUPSIGNAL_freqRanges get _antenna;
				_minFreq = missionNamespace getVariable "#EM_SelMin";
				_maxFreq = missionNamespace getVariable "#EM_SelMax";
				_transFreq = (_minFreq + _maxFreq)/2;
				if ((_transFreq > (_freqRange select 0)) and {_transFreq < (_freqRange select 1)}) then
				{
					if (CUPSIGNAL_debug) then {systemChat "frequency valid";};
					private "_signalIndex";
					if (!(isNil {CUPSIGNAL_jammerAntenna}) and {_antenna == CUPSIGNAL_jammerAntenna}) then
					{
						_signalIndex = [{eyePos _this}, CUPSIGNAL_jammerMaxRange, CUPSIGNAL_jammerMinRange, {_this weaponDirection currentWeapon _this}, CUPSIGNAL_jammerAngle, player, true, _transFreq] call CUPJAM_addJammer;
					} else
					{
						_signalIndex = [{eyePos _this}, _transFreq, CUPSIGNAL_transmitMaxRange, CUPSIGNAL_transmitMinRange, true, {_this weaponDirection currentWeapon _this}, CUPSIGNAL_transmitAngle, player] call CUPSIGNAL_addSignal;
					};
					player setVariable ["CUPSIGNAL_transmitSignalIndex", _signalIndex];
					missionNamespace setVariable ["#EM_Transmit", true];
					[_transFreq, _antenna] spawn CUPSIGNAL_transmitCheckLoop;
				};
			};
		};
	} else
	{
		if (!(isNil {CUPSIGNAL_jammerAntenna}) and {(handgunItems player select 0) == CUPSIGNAL_jammerAntenna}) then
		{
			(player getVariable "CUPSIGNAL_transmitSignalIndex") call CUPJAM_removeJammer;
			player setVariable ["CUPSIGNAL_transmitSignalIndex", nil];
		} else
		{
			(player getVariable "CUPSIGNAL_transmitSignalIndex") call CUPSIGNAL_removeSignal;
			player setVariable ["CUPSIGNAL_transmitSignalIndex", nil];
		};
		missionNamespace setVariable ["#EM_Transmit", false];
	};
};

/**
Continuously checks that the Spectrum transmission is still valid, and ends it if not
Parameters:
	- transmit frequency
**/
CUPSIGNAL_transmitCheckLoop = 
{
	params ["_transFreq", "_transAntenna"];
	private ["_isValid", "_curAntenna", "_curFreq", "_minFreq", "_maxFreq"];
	if (CUPSIGNAL_debug) then {systemChat "check loop starting";};
	_isValid = true;
	while {_isValid} do
	{
		if (isNil {player getVariable "CUPSIGNAL_transmitSignalIndex"}) then
		{
			_isValid = false;
			if (CUPSIGNAL_debug) then {systemChat "variable nil";};
		} else
		{
			if !("hgun_esd_" in currentWeapon player) then
			{
				_isValid = false;
				if (CUPSIGNAL_debug) then {systemChat "weapon changed";};
			} else
			{
				_curAntenna = handgunItems player select 0;
				if (_curAntenna != _transAntenna) then
				{
					_isValid = false;
					if (CUPSIGNAL_debug) then {systemChat "antenna changed";};
				} else
				{
					_minFreq = missionNamespace getVariable "#EM_SelMin";
					_maxFreq = missionNamespace getVariable "#EM_SelMax";
					_curFreq = (_minFreq + _maxFreq)/2;
					if (_curFreq != _transFreq) then
					{
						_isValid = false;
						if (CUPSIGNAL_debug) then {systemChat "freq changed";};
					} else
					{
						if (CUPSIGNAL_debug) then {hintSilent format ["Transmission still valid.\nTrans Freq: %1\nSel Freq:%2",_transFreq, _curFreq];};
					};
				};
			};
		};
		sleep CUPSIGNAL_tickDelay;
	};
	if (CUPSIGNAL_debug) then 
	{
		hintSilent "";
		systemChat "check loop broken";
	};
	if !(isNil {player getVariable "CUPSIGNAL_transmitSignalIndex"}) then
	{
		if (!(isNil {CUPSIGNAL_jammerAntenna}) and {_transAntenna == CUPSIGNAL_jammerAntenna}) then
		{
			(player getVariable "CUPSIGNAL_transmitSignalIndex") call CUPJAM_removeJammer;
			player setVariable ["CUPSIGNAL_transmitSignalIndex", nil]; 
		} else
		{
			(player getVariable "CUPSIGNAL_transmitSignalIndex") call CUPSIGNAL_removeSignal;
			player setVariable ["CUPSIGNAL_transmitSignalIndex", nil];
		};
		missionNamespace setVariable ["#EM_Transmit", false];
	};
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