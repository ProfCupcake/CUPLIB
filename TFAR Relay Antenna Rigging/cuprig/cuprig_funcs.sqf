CUPRIG_doRigAntenna = 
{
	params ["_target", "_caller", "_actionId", "_args"];
	_args params ["_range"];
	[_target, _range] call TFAR_antennas_fnc_initRadioTower;
	_target setVariable ["CUPRIG_rigged", true, true];
	hint format ["Antenna enabled\nRange: %1m", _range];
};

CUPRIG_canRigAntenna = 
{
	_rigged = _this getVariable "CUPRIG_rigged";
	(isNil "_rigged")
};

CUPRIG_canReenableAntenna = 
{
	_rigged = _this getVariable "CUPRIG_rigged";
	if (isNil "_rigged") exitWith {false};
	!_rigged
};

CUPRIG_doDisableAntenna = 
{
	params ["_target", "_caller", "_actionId", "_args"];
	[_target] call TFAR_antennas_fnc_deleteRadioTower;
	_target setVariable ["CUPRIG_rigged", false, true];
};

CUPRIG_canDisableAntenna = 
{
	_rigged = _this getVariable "CUPRIG_rigged";
	if (isNil "_rigged") exitWith {false};
	_rigged
};

CUPRIG_addRigActions = 
{
	params ["_target", ["_range", CUPRIG_defaultRange], ["_rigTime", CUPRIG_rigTime]];
	[
		_target, // action target
		"rig relay antenna", // action text
		"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa", // idle icon
		"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa", // progress icon
		"_target call CUPRIG_canRigAntenna", // start condition
		"_target call CUPRIG_canRigAntenna", // progress condition
		{}, // start code
		{}, // progress tick code
		CUPRIG_doRigAntenna, // complete code
		{}, // interrupt code
		[_range], // arguments
		_rigTime, // duration
		1.5, // priority
		false // remove on completion
	] remoteExec ["BIS_fnc_holdActionAdd", 0, true];
	
	[
		_target, // action target
		"disable relay antenna", // action text
		"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa", // idle icon
		"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa", // progress icon
		"_target call CUPRIG_canDisableAntenna", // start condition
		"_target call CUPRIG_canDisableAntenna", // progress condition
		{}, // start code
		{}, // progress tick code
		CUPRIG_doDisableAntenna, // complete code
		{}, // interrupt code
		[_range], // arguments
		CUPRIG_disableTime, // duration
		1.5, // priority
		false // remove on completion
	] remoteExec ["BIS_fnc_holdActionAdd", 0, true];
	
	[
		_target, // action target
		"enable relay antenna", // action text
		"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa", // idle icon
		"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_connect_ca.paa", // progress icon
		"_target call CUPRIG_canReenableAntenna", // start condition
		"_target call CUPRIG_canReenableAntenna", // progress condition
		{}, // start code
		{}, // progress tick code
		CUPRIG_doRigAntenna, // complete code
		{}, // interrupt code
		[_range], // arguments
		CUPRIG_reenableTime, // duration
		1.5, // priority
		false // remove on completion
	] remoteExec ["BIS_fnc_holdActionAdd", 0, true];
};