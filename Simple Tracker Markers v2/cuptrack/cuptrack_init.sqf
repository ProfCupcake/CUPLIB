CUPTRACK_defaultText = "";

CUPTRACK_defaultColour = "Default";

CUPTRACK_defaultLineWidth = 2;

CUPTRACK_defaultLineSegments = 1;

CUPTRACK_defaultTickRate = 15;

////////////////////////////////////////////////////////////////////////////

CUPTRACK_trackerList = createHashMap;
call compile preprocessfilelinenumbers "cuptrack\cuptrack_funcs.sqf";

[CUPTRACK_tick] call CBA_fnc_addPerFrameHandler;