// Default antenna range, in metres
CUPRIG_defaultRange = 50000;

// How long, in seconds, it takes to rig a (new) antenna
CUPRIG_rigTime = 15;

// How long, in seconds, it takes to disable a rigged antenna
CUPRIG_disableTime = 0.8;

// How long, in seconds, it takes to re-enable an antenna that was already rigged before
CUPRIG_reenableTime = 0.8;

// List of antenna classes to ignore
CUPRIG_antennaBlacklist = [
	"Land_Radar_F",
	"Land_Radar_Small_F"
];

// Array of ranges and rig times assigned to antenna classes
// You can use this to set defaults on a per-class basis (e.g. if you want larger antennae to have a greater range, or make small ones quicker to rig)
// Array is formatted accordingly: [classname, [range, rig time]]
// Both are optional; you can set only the range (ommitting the rig time), or you can set only the rig time (by setting the range as nil), or both of course. 
CUPRIG_rangeArray = [
	["example1", [5000]],
	["example2", [50000, 30]],
	["example3", [nil, 5]]
];

/////////////////////////////////////////////////////////////////

call compile preprocessfilelinenumbers "cuprig\cuprig_funcs.sqf";

CUPRIG_rangeMap = createHashMapFromArray CUPRIG_rangeArray;

_transmitterList = nearestTerrainObjects [[worldSize/2, worldSize/2], ["TRANSMITTER"], worldSize, false]; 

{
	if !(typeOf _x in CUPRIG_antennaBlacklist) then
	{
		private ["_args", "_range", "_rigTime"];
		_args = CUPRIG_rangeMap get (typeOf _x);
		if (isNil "_args") then
		{
			_args = [];
		};
		_args params [["_range", CUPRIG_defaultRange], ["_rigTime", CUPRIG_rigTime]];
		[_x, _range, _rigTime] call CUPRIG_addRigActions;
	};
} forEach _transmitterList;